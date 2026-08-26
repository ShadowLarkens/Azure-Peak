//! Modeled after, but distinct from, /tg/ preferences

/// An assoc list list of types to instantiated `/datum/preference` instances
GLOBAL_LIST_INIT(preference_entries, init_valid_subtypes_by_path(/datum/preference))
/// An assoc list of preference entries by their `savefile_key`
GLOBAL_LIST_INIT(preference_entries_by_key, init_preference_entries_by_key())

/proc/init_preference_entries_by_key()
	var/list/output = list()
	for(var/preference_type in GLOB.preference_entries)
		var/datum/preference/P = GLOB.preference_entries[preference_type]
		output[P.savefile_key] = P
	return output

/// Returns a flat list of /datum/preference with dependencies resolved
/// Named this way to match /tg/ which uses priority sorting instead of dependency chains.
/// Modeled after subsystems.
/proc/get_preferences_in_priority_order()
	// This function is a one-shot, only the first call will actually sort.
	var/static/list/sorted_prefs
	if(sorted_prefs)
		return sorted_prefs

	// Deassocify our list (needed later to debug circular preferences, may also speed things up?)
	var/list/all_preference_entries = list()
	for(var/path in GLOB.preference_entries)
		all_preference_entries += GLOB.preference_entries[path]

	// Allows preferences to declare other preferences that must initialize after them.
	for(var/datum/preference/pref as anything in all_preference_entries)
		for(var/dependent_type in pref.dependents)
			if(!ispath(dependent_type, /datum/preference))
				stack_trace("ERROR: Preferences: preference `[pref.type]` has an invalid dependent: `[dependent_type]`. Skipping")
				continue
			var/datum/preference/dependent = GLOB.preference_entries[dependent_type]
			dependent.dependencies |= pref.type
		pref.dependents = list()

	// Constructs a reverse-dependency graph.
	for(var/datum/preference/pref as anything in all_preference_entries)
		for(var/dependency_type in pref.dependencies)
			if(!ispath(dependency_type, /datum/preference))
				stack_trace("ERROR: Preferences: preference `[pref.type]` has an invalid dependency: `[dependency_type]`. Skipping")
				continue
			var/datum/preference/dependency = GLOB.preference_entries[dependency_type]
			dependency.dependents += pref

	// Topological sorting algorithm
	var/list/counts = new(length(all_preference_entries))
	var/list/unsorted_prefs = list()
	var/index = 1
	for(var/datum/preference/pref as anything in all_preference_entries)
		counts[index] = length(pref.dependencies)
		pref.ordering_id = index
		// If there's no dependencies, we can go in any order.
		if(counts[index] == 0)
			unsorted_prefs += pref
		index += 1

	sorted_prefs = list()
	while(length(unsorted_prefs) > 0)
		// End of the list has already had dependencies sorted
		var/datum/preference/pref = unsorted_prefs[unsorted_prefs.len]
		unsorted_prefs.len--
		sorted_prefs += pref
		// Loop over all dependents and reduce their count of dependencies remaining
		for(var/datum/preference/dependent as anything in pref.dependents)
			counts[dependent.ordering_id] -= 1
			// No dependencies remaining, sort their dependents
			if(counts[dependent.ordering_id] == 0)
				unsorted_prefs += dependent
	// Topological sorting algorithm end

	// The topological sorting algorithm will leave circular dependencies unresolved, so we have to resolve them now
	if(length(all_preference_entries) != length(sorted_prefs))
		var/list/circular_dependency = all_preference_entries - sorted_prefs
		var/list/debug_msg = list()
		var/list/usr_msg = list()
		for(var/datum/preference/pref as anything in circular_dependency)
			usr_msg += "[pref.type]"

		var/list/datum/preference/nodes = list(circular_dependency[1])
		var/list/loop = list()
		while(length(nodes) > 0)
			var/datum/preference/node = nodes[nodes.len]
			nodes.len--
			if(node in loop)
				loop += node
				break
			loop += node
			for(var/connected_path in node.dependencies)
				nodes += GLOB.preference_entries[connected_path]

		var/loop_position = 0
		for(var/datum/preference/node in loop)
			if(node == loop[loop.len])
				break
			loop_position++
		if(loop_position != 0)
			loop.Cut(1, loop_position + 1)

		for(var/datum/preference/pref as anything in loop)
			debug_msg += "[pref.type]"

		// Can't initialize them if they have circular dependencies, there's no real failsafe here.
		stack_trace("ERROR: CRITICAL: PREFERENCES: The following preferences have circular dependencies: [jointext(debug_msg, " -> ")]")
		to_world(span_boldannounce("CRITICAL: Failed to initialize preference [jointext(usr_msg, ", ")]"))

	return sorted_prefs

/// Represents an individual preference.
/datum/preference
	/// Do not instantiate if type matches this.
	abstract_type = /datum/preference

	/// The key inside the savefile to use.
	/// This is also sent to the UI.
	/// Once you pick this, don't change it.
	var/savefile_key

	/// What savefile should this preference be read from?
	/// Valid values are PREFERENCE_CHARACTER and PREFERENCE_PLAYER.
	/// See the documentation in [code/__DEFINES/preferences.dm].
	var/savefile_identifier

	/// Used for dm_tgui_type_bridge generation, will generate zod TypeScript code like this:
	/// const PreferenceData = z.object({
	///   [savefile_key]: zod_schema,
	/// }).exactOptional()
	///
	/// There are a few globals available:
	///  - z is the global zod variable.
	///  - typepath is a custom validator for, well, typepaths.
	///  - ref is a custom validator for the "\ref[datum]" syntax.
	///
	/// See https://zod.dev/api for instructions on how to make a schema.
	/// This should match your /ui_data or it'll cause a runtime error!
	var/zod_schema = "z.never()"
	/// Same as zod_schema but for your constant data in the JSON
	/// Will generate code like this: const ConstantPreferenceData = z.object({ ...(zod_schema_constant), })
	/// You can also use %SAVEFILE_KEY% for text replacement of your savefile_key, since dynamic strings are not permitted
	var/zod_schema_constant = ""

	/// List of other /datum/preference typepaths
	/// which must be loaded before this.
	var/list/dependencies = list()

	/// List of other /datum/preference typepaths
	/// which must be loaded after this.
	/// May be used directly, but will also be populated at runtime.
	var/list/dependents

	// TODO: This can probably be replaced with an assoc typepath list
	/// ID of the preference. Set automatically when the dependency graph is evaluated. Used primarily in determining order.
	var/ordering_id = 0

	/// If this is a character preference, should we update the character preview
	/// when this preference is updated?
	var/should_update_preview = TRUE

	/// When deserialize returns null, should we call create_informed_default_value?
	var/null_is_valid = FALSE

/// Called on the saved input when retrieving.
/// Also called by the value sent from the user through UI.
/// Do not trust input: sanitization must be done inline before return.
/// Input is the value inside the savefile, output is to tell other code
/// what the value is.
/// This is useful either for more optimal data saving or for migrating
/// older data.
/// Must be overridden by subtypes.
/// Can return null if no value was found, this will prompt create_informed_default_value
/// Also note, deserialize(deserialize(V)) MUST equal deserialize(V).
/datum/preference/proc/deserialize(input, datum/preferences/preferences)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`deserialize()` was not implemented on [type]!")

/// Called on the input while saving.
/// Input is the current value, output is what to save in the savefile.
/datum/preference/proc/serialize(input)
	SHOULD_NOT_SLEEP(TRUE)
	return input

/// Produce a default, potentially random value for when no value for this
/// preference is found in the savefile.
/// This MUST be overriden by subtypes for unit testing.
/datum/preference/proc/create_default_value()
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`create_default_value()` was not implemented on [type]!")

/// This MUST be overriden by subtypes for unit testing.
/// Creates one or more values in a list which should all fail is_valid.
/// Used for more thorough testing of the double-deserialize rule.
/datum/preference/proc/create_invalid_values()
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`create_invalid_values()` was not implemented on [type]!")

/// Produce a default, potentially random value for when no value for this
/// preference is found in the savefile.
/// Unlike create_default_value(), will provide the preferences object if you
/// need to use it.
/// If not overriden, will call create_default_value() instead.
/datum/preference/proc/create_informed_default_value(datum/preferences/preferences)
	return create_default_value()

/// Checks that a given raw/already deserialized value is valid.
/// Must be overriden by subtypes.
/// Any type can be passed through.
/datum/preference/proc/is_valid(value, datum/preferences/preferences)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`is_valid()` was not implemented for [type]!")

/// UI data for the preferences menu to use
/datum/preference/proc/get_ui_data(deserialized_value)
	// Return null if you want to completely exclude this from the data package
	return null

/// Constant UI data for the preferences menu to use
/datum/preference/proc/get_constant_ui_data()
	// Return null if you want to completely exclude this from the data package
	return null

// We DO NOT implement read/write, that's up to the backend to figure out!

// Subtypes for different data types

/// A string-based preference accepting arbitrary string values entered by the user, with a maximum length.
/datum/preference/text
	abstract_type = /datum/preference/text
	zod_schema = "z.string()"
	zod_schema_constant = "z.object({ '%SAVEFILE_KEY%_max_len': z.number() })"

	/// What is the maximum length of the value allowed in this field?
	var/maximum_value_length = 256

	/// Should we strip HTML the input or simply restrict it to the maximum_value_length?
	var/should_strip_html = TRUE

/datum/preference/text/deserialize(input, datum/preferences/preferences)
	// Follow the double-deserialize rule.
	if(!istext(input))
		return ""
	return should_strip_html ? STRIP_HTML_SIMPLE(input, maximum_value_length) : copytext(input, 1, PREVENT_CHARACTER_TRIM_LOSS(maximum_value_length))

/datum/preference/text/create_default_value()
	return ""

/datum/preference/text/is_valid(value, datum/preferences/preferences)
	return istext(value) && length(value) < maximum_value_length

// Only used for unit tests
/datum/preference/text/create_invalid_values()
	// Typepaths are never gonna be good.
	// Empty strings should be tested too.
	// Also over the maximum length!
	return list(/datum/preference/text, repeat_string(maximum_value_length + 1, "A"))

/datum/preference/text/get_ui_data(deserialized_value)
	return deserialized_value

/datum/preference/text/get_constant_ui_data()
	return list("[savefile_key]_max_len" = maximum_value_length)

/// A preference that is a choice of one option among a fixed set.
/// Used for preferences such as clothing.
/datum/preference/choiced
	abstract_type = /datum/preference/choiced
	zod_schema = "z.string()"
	zod_schema_constant = "z.object({ '%SAVEFILE_KEY%_choices': z.array(z.any()) })"

	/// get_choices returns this after initial computation of choices
	var/list/cached_choices

/// Returns a list of every possible value.
/// This must be overriden by `/datum/preference/choiced` subtypes.
/datum/preference/choiced/proc/init_possible_values()
	CRASH("`init_possible_values()` was not implemented for [type]!")

/// Returns a list of every possible value.
/// The first time this is called, will run `init_values()`.
/// Return value can be in the form of:
/// - A flat list of raw values, such as list(MALE, FEMALE, PLURAL).
/// - An assoc list of raw values to atoms/icons.
/datum/preference/choiced/proc/get_choices()
	// Override `init_values()` instead.
	SHOULD_NOT_OVERRIDE(TRUE)

	if(isnull(cached_choices))
		cached_choices = init_possible_values()
		ASSERT(cached_choices.len)

	return cached_choices

/datum/preference/choiced/is_valid(value, datum/preferences/preferences)
	return value in get_choices()

/datum/preference/choiced/deserialize(input, datum/preferences/preferences)
	return sanitize_inlist(input, get_choices(), create_default_value())

/datum/preference/choiced/create_default_value()
	return pick(get_choices())

// Only used for unit tests
/datum/preference/choiced/create_invalid_values()
	return list("!!ALMOST_CERTAINLY_INVALID!!")

/datum/preference/choiced/get_ui_data(deserialized_value)
	return deserialized_value

/datum/preference/choiced/get_constant_ui_data()
	return list("[savefile_key]_choices" = get_choices())
