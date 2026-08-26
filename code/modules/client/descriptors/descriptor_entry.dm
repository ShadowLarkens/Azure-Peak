/datum/descriptor_entry
	// The choice type this entry belongs to
	var/descriptor_choice_type
	// The chosen descriptor type this entry got
	var/descriptor_type

/datum/descriptor_entry/proc/set_values(choice_type, desc_type)
	descriptor_choice_type = choice_type
	descriptor_type = desc_type

/datum/descriptor_entry/proc/load_from_list(list/data)
	if(!islist(data))
		return FALSE

	descriptor_type = sanitize_path(data["descriptor_type"], /datum/mob_descriptor, initial(descriptor_type))
	descriptor_choice_type = sanitize_path(data["descriptor_choice_type"], /datum/descriptor_choice, initial(descriptor_choice_type))

	return TRUE

/datum/descriptor_entry/proc/sanitize()
	var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(descriptor_choice_type)
	if(!choice)
		return FALSE

	if(!(descriptor_type in choice.descriptors))
		descriptor_type = choice.default_descriptor || pick(choice.descriptors)

	return TRUE

/datum/descriptor_entry/proc/deserialize(list/data, datum/preferences/prefs)
	if(!load_from_list(data))
		return FALSE
	if(!sanitize())
		return FALSE
	return TRUE

/datum/descriptor_entry/proc/serialize()
	. = list()

	.["descriptor_type"] = descriptor_type
	.["descriptor_choice_type"] = descriptor_choice_type
