/// Customizer entry representing a saved/loaded information about a /datum/customizer_choice and its related information.
/datum/customizer_entry
	/// Used for identification.
	var/customizer_type
	var/customizer_choice_type
	var/accessory_type
	var/accessory_colors
	var/disabled = FALSE

/datum/customizer_entry/ui_data(mob/user)
	return list(
		"customizer_choice_type" = customizer_choice_type,
		"accessory_type" = accessory_type,
		"accessory_colors" = color_string_to_list(accessory_colors),
	)

/datum/customizer_entry/proc/load_from_list(list/data)
	if(!islist(data))
		return FALSE

	customizer_type = sanitize_path(data["customizer_type"], /datum/customizer, initial(customizer_type))
	customizer_choice_type = sanitize_path(data["customizer_choice_type"], /datum/customizer_choice, initial(customizer_choice_type))
	accessory_type = sanitize_path(data["accessory_type"], /datum/sprite_accessory, initial(accessory_type))
	accessory_colors = data["accessory_colors"]
	disabled = sanitize_bool(data["disabled"], initial(disabled))

	return TRUE

/datum/customizer_entry/proc/deserialize(list/data, datum/preferences/prefs)
	if(!load_from_list(data))
		return FALSE

	var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
	if(!customizer)
		return FALSE
	customizer.validate_entry(prefs, src)

	return TRUE

/datum/customizer_entry/proc/serialize()
	. = list()
	.["type"] = type
	.["customizer_type"] = customizer_type
	.["customizer_choice_type"] = customizer_choice_type
	.["accessory_type"] = accessory_type
	.["accessory_colors"] = accessory_colors
	.["disabled"] = disabled
