/datum/preference/descriptors
	savefile_key = "descriptor_entries"
	savefile_identifier = PREFERENCE_CHARACTER
	zod_schema = "z.array(z.object({ name: z.string(), type: z.string(), selected: z.string() }))"
	zod_schema_constant = "z.object({ descriptors: z.record(z.string(), z.object({ name: z.string() })), descriptor_choices: z.record(z.string(), z.object({ name: z.string(), descriptors: z.array(z.string()) })) })"

	dependencies = list(
		/datum/preference/species
	)

/// the deserialize(deserialize(V)) rule means that we have to support the already-deserialized format
/// this is an extreme best-effort deserializer, it will try to supplement the list and scrape as much data as it can
/datum/preference/descriptors/deserialize(list/input, datum/preferences/preferences)
	if(istext(input))
		input = safe_json_decode(input)

	if(!islist(input))
		// we can't parse whatever this is, fall back to create_informed_default_value
		return null

	var/datum/species/pref_species = preferences.read_preference(/datum/preference/species)
	var/list/required_descriptors = pref_species.descriptor_choices.Copy()

	var/list/deserialized_entries = list()
	for(var/i in 1 to length(input))
		var/entry = input[i]
		if(istext(entry))
			entry = safe_json_decode(entry)

		// we need a descriptor entry before we can validate
		var/datum/descriptor_entry/DE = entry
		if(!istype(DE))
			if(!islist(entry))
				// We can't parse this, reject this value completely
				continue

			DE = new()
			if(!DE.deserialize(entry, src))
				// Something was horribly wrong with this entry, reject it
				continue
		else
			// If we got a descriptor_entry already, run sanitization again
			if(!DE.sanitize())
				// Something was horribly wrong with this entry, reject it
				continue

		// We now have a happy clean entry to further validate
		if(!(DE.descriptor_choice_type in required_descriptors))
			// We don't want this descriptor, silently drop it
			continue

		// We want this descriptor, add it to our list
		required_descriptors -= DE.descriptor_choice_type
		deserialized_entries += DE

	// Second pass: We need to create anything left in required_descriptors
	for(var/choice_type in required_descriptors)
		deserialized_entries += create_default_value_for_choice(choice_type)

	// Finally, we're good!
	return deserialized_entries

/// Only ever called with raw/deserialized values
/datum/preference/descriptors/is_valid(list/value, datum/preferences/preferences)
	if(!islist(value))
		return FALSE

	var/datum/species/pref_species = preferences.read_preference(/datum/preference/species)
	var/list/required_descriptors = pref_species.descriptor_choices.Copy()

	for(var/datum/descriptor_entry/entry as anything in value)
		if(!istype(entry))
			// Who knows what they passed us
			return FALSE
		if(!(entry.descriptor_choice_type in required_descriptors))
			// Found something out of place!
			return FALSE

		// Only one allowed of each type.
		required_descriptors -= entry.descriptor_choice_type

	// Missing something!
	if(length(required_descriptors))
		return FALSE

	return TRUE

/// Only ever called after is_valid passes
/datum/preference/descriptors/serialize(list/input)
	var/list/serialized_entries = list()
	for(var/datum/descriptor_entry/entry as anything in input)
		UNTYPED_LIST_ADD(serialized_entries, entry.serialize())
	return serialized_entries

/// Creation logic for default entry of a given DESCRIPTOR_CHOICE
/datum/preference/descriptors/proc/create_default_value_for_choice(choice_type)
	var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
	var/datum/descriptor_entry/entry = new /datum/descriptor_entry()

	if(choice.default_descriptor)
		entry.set_values(choice_type, choice.default_descriptor)
	else
		entry.set_values(choice_type, pick(choice.descriptors))

	return entry

/datum/preference/descriptors/create_default_value()
	return list()

/datum/preference/descriptors/create_invalid_values()
	return list("warf", @#[{ descriptor_type: "WOOF" }]#)

/datum/preference/descriptors/create_informed_default_value(datum/preferences/preferences)
	var/datum/species/pref_species = preferences.read_preference(/datum/preference/species)

	var/list/deserialized_entries = list()
	for(var/choice_type in pref_species.descriptor_choices)
		deserialized_entries += create_default_value_for_choice(choice_type)
	return deserialized_entries

// UI data
/datum/preference/descriptors/get_ui_data(list/deserialized_value, datum/preferences/preferences)
	var/list/data = list()

	// Thanks to our deserialize implementation, we can be confident that this matches what our pref_species wants
	// and we're only harboring valid entries
	for(var/datum/descriptor_entry/DE in deserialized_value)
		var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(DE.descriptor_choice_type)
		UNTYPED_LIST_ADD(data, list(
			"name" = choice.name,
			"type" = choice.type,
			"selected" = DE.descriptor_type,
		))

	return data

/datum/preference/descriptors/get_constant_ui_data()
	var/list/data = list(
		"descriptors" = null,
		"descriptor_choices" = null,
	)

	var/list/descriptors_data = list()
	for(var/type in GLOB.mob_descriptors)
		var/datum/mob_descriptor/descriptor = GLOB.mob_descriptors[type]
		descriptors_data[type] = descriptor.constant_ui_data()
	data["descriptors"] = descriptors_data

	var/list/descriptor_choices_data = list()
	for(var/type in GLOB.descriptor_choices)
		var/datum/descriptor_choice/choice = GLOB.descriptor_choices[type]
		descriptor_choices_data[type] = choice.constant_ui_data()
	data["descriptor_choices"] = descriptor_choices_data

	return data
