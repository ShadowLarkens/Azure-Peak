// This preference backend is modeled somewhat off Git.
// You have a Working Directory which contains the full current state.
// You have staged changes, which contain diffs of what have been changed, waiting for commit or undo.
//   You can bypass staging for preferences where it is appropriate, writing directly to storage.
// Finally, you have committed changes, which is the full state written to storage.
//
// To accomplish this in DM, each time you read a preference it will read from working_directory,
// each time you write a preference (normally) it will write to staged_changes, and each time you
// hit save, it will write staged_changes to disk.
//
// Another important thing to know: Full writes are the exception, not the rule. Most of the time,
// you are only updating a handful of keys at a time.


/////////////////////////////
// Public API              //
/////////////////////////////

/// Read a preference from the working directory.
/// REMEMBER: This can be called before working_directory is fully populated during loading!
/datum/preferences/proc/read_preference(datum/preference/pref)
	pref = GLOB.preference_entries[pref]
	if(!istype(pref))
		CRASH("Invalid preference path passed to read_preference: '[pref]'")

	var/list/working_directory

	switch(pref.savefile_identifier)
		if(PREFERENCE_PLAYER)
			working_directory = working_directory_pref
		if(PREFERENCE_CHARACTER)
			working_directory = working_directory_char
		else
			CRASH("Unsupported savefile identifier: '[pref.savefile_identifier]'")

	if(!(pref.savefile_key in working_directory))
		stack_trace("WARNING: Attempted to read '[pref.savefile_key]' when it was not in our working_directory. This could indicate a missing dependency!")

	return working_directory[pref.savefile_key]

/// Write a preference to working directory and stage or write it.
/datum/preferences/proc/write_preference(datum/preference/pref, raw_value, bypass_staging = FALSE)
	pref = GLOB.preference_entries[pref]
	if(!istype(pref))
		CRASH("Invalid preference datum/path passed to read_preference: '[pref]'")

	if(!pref.is_valid(raw_value, src))
		return FALSE

	var/list/working_directory
	var/list/staged

	switch(pref.savefile_identifier)
		if(PREFERENCE_PLAYER)
			working_directory = working_directory_pref
			staged = staged_changes_pref
		if(PREFERENCE_CHARACTER)
			working_directory = working_directory_char
			staged = staged_changes_char
		else
			CRASH("Unsupported savefile identifier: '[pref.savefile_identifier]'")

	working_directory[pref.savefile_key] = raw_value

	var/serialized_value = pref.serialize(raw_value)
	if(!bypass_staging)
		staged[pref.savefile_key] = serialized_value
	else if(psa_default)
		psa_default.write(pref.savefile_key, serialized_value, pref.savefile_identifier == PREFERENCE_PLAYER ? null : default_slot)
	else
		CRASH("Nowhere to write preference with bypass_staging = TRUE.")

	return TRUE

/// Used to inform us that some nested data inside `pref` has been changed in the working directory
/// and it should be persisted with whatever is in the working directory
/datum/preferences/proc/stage_preference(datum/preference/pref, bypass_staging = FALSE)
	var/list/current = read_preference(pref)
	return write_preference(pref, current, bypass_staging)

/// Reset a preference to it's informed default in the working directory and stage or write it.
/datum/preferences/proc/reset_preference(datum/preference/pref, bypass_staging = FALSE)
	var/datum/preference/P = GLOB.preference_entries[pref]
	if(!istype(P))
		CRASH("Invalid preference datum/path passed to read_preference: '[pref]'")

	return write_preference(pref, P.create_informed_default_value(src), bypass_staging)

/datum/preferences/proc/save_to_json()
	var/datum/preference_storage_adapter/generic_json/psa = new(list(), null)
	// TODO: Get other characters somehow?
	flush_wd_pref(psa)
	flush_wd_char(psa)
	return psa.get_json()

// Older APIs

// TODO: Support json import somewhere in here
/datum/preferences/proc/load_path(ckey, filename="preferences.sav")
	if(!ckey)
		return FALSE
	var/directory = "data/player_saves/[copytext(ckey,1,2)]/[ckey]"
	path = "[directory]/[filename]"

	// It's okay if the file doesn't exist, this could be a new player...
	if(!fexists(path))
		return FALSE

	var/savefile/S = new /savefile(path)
	// It's *not* okay if the file exists but doesn't load.
	if(!S)
		stack_trace("Tried to load bad savefile at '[path]'")
		return FALSE

	psa_default = new /datum/preference_storage_adapter/byond_savefile(S, directory)
	return TRUE

/datum/preferences/proc/load_preferences()
	if(!psa_default)
		return FALSE

	// Unable to migrate
	if(!try_migrate_savefile(psa_default))
		return FALSE

	load_preferences_old(psa_default.open_save)
	read_from_storage_pref(psa_default)
	return TRUE

/datum/preferences/proc/load_character(slot)
	if(!psa_default)
		return FALSE

	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))

	// Whether or not we can migrate, we want this to be the default slot.
	if(slot != default_slot)
		default_slot = slot
		psa_default.write("default_slot", default_slot, null)

	// Unable to migrate
	if(!try_migrate_savefile(psa_default, slot))
		return FALSE

	load_character_old(psa_default.open_save, slot)
	read_from_storage_char(psa_default, slot)
	return TRUE

/datum/preferences/proc/save_preferences()
	if(!psa_default)
		return FALSE

	flush_staged_pref(psa_default)
	return save_preferences_old(psa_default.open_save)

/datum/preferences/proc/save_character()
	if(!psa_default)
		return FALSE

	flush_staged_char(psa_default)
	return save_character_old(psa_default.open_save)

/////////////////////////////
// Private API Below this! //
/////////////////////////////
/datum/preferences
	// TODO: genericize this
	var/datum/preference_storage_adapter/byond_savefile/psa_default

	/// Full current state of general preferences
	/// list("[savefile_key]" = deserialized data)
	var/list/working_directory_pref = list()
	// TODO: this should probably have prev too if we want to be able to undo
	/// List of values to save on next commit
	/// list("[savefile_key]" = "serialized_data")
	var/list/staged_changes_pref = list()

	/// Full current state of character preferences
	/// list("[savefile_key]" = deserialized data)
	var/list/working_directory_char = list()
	// TODO: this should probably have prev too if we want to be able to undo
	/// List of values to save on next commit
	/// list("[savefile_key]" = "serialized_data")
	var/list/staged_changes_char = list()

/datum/preferences/proc/read_from_storage(datum/preference_storage_adapter/psa, list/working_directory, slot_idx)
	if(!islist(working_directory))
		working_directory = list()

	var/loading_character = !isnull(slot_idx)

	for(var/datum/preference/pref as anything in get_preferences_in_priority_order())
		// Filter prefs
		switch(pref.savefile_identifier)
			if(PREFERENCE_PLAYER)
				if(loading_character)
					continue
			if(PREFERENCE_CHARACTER)
				if(!loading_character)
					continue
			else
				CRASH("Unsupported savefile identifier: '[pref.savefile_identifier]'")

		var/serialized_possibly_evil_value = psa.read(pref.savefile_key, slot_idx)
		// Allow nulls in if the pref says so. This allows deserialize to only return null
		// when it wants to create a default.
		if(isnull(serialized_possibly_evil_value) && pref.null_is_valid)
			working_directory[pref.savefile_key] = null
			return

		// Deserialize
		var/deserialized = pref.deserialize(serialized_possibly_evil_value, src)
		// If it's null because we didn't read it or it was invalid or whatever,
		// create an informed default.
		if(isnull(deserialized))
			deserialized = pref.create_informed_default_value(src)
		// to_chat(world, "final setting [deserialized] for [pref.type]")
		working_directory[pref.savefile_key] = deserialized

/datum/preferences/proc/read_from_storage_pref(datum/preference_storage_adapter/psa)
	// No old values pls
	working_directory_pref = list()
	staged_changes_pref = list() // Clear staged
	read_from_storage(psa, working_directory_pref, null)

/datum/preferences/proc/read_from_storage_char(datum/preference_storage_adapter/psa, slot_idx)
	// No old values pls
	working_directory_char = list()
	staged_changes_char = list() // Clear staged
	read_from_storage(psa, working_directory_char, slot_idx)

/// Flushes all staged_changes_pref to storage.
/// Returns TRUE if flush succeeded, FALSE otherwise.
/datum/preferences/proc/flush_staged_pref(datum/preference_storage_adapter/psa)
	return psa.write_all(staged_changes_pref, null)

/// Flushes entire working_directory_pref to storage, such as in the case of JSON export.
/// Returns TRUE if flush succeeded, FALSE otherwise.
/datum/preferences/proc/flush_wd_pref(datum/preference_storage_adapter/psa)
	. = TRUE

	for(var/savefile_key in working_directory_pref)
		var/datum/preference/pref = GLOB.preference_entries_by_key[savefile_key]
		var/serialized_value = pref.serialize(working_directory_pref[savefile_key])
		if(!psa.write(serialized_value, null))
			. = FALSE

	psa.flush()

/// Flushes all staged_changes_char to storage.
/// Returns TRUE if flush succeeded, FALSE otherwise.
/datum/preferences/proc/flush_staged_char(datum/preference_storage_adapter/psa)
	return psa.write_all(staged_changes_char, default_slot)

/// Flushes entire working_directory_char to storage, such as in the case of JSON export.
/// Returns TRUE if flush succeeded, FALSE otherwise.
/datum/preferences/proc/flush_wd_char(datum/preference_storage_adapter/psa)
	. = TRUE

	for(var/savefile_key in working_directory_char)
		var/datum/preference/pref = GLOB.preference_entries_by_key[savefile_key]
		var/serialized_value = pref.serialize(working_directory_char[savefile_key])
		if(!psa.write(serialized_value, default_slot))
			. = FALSE

	psa.flush()
