/datum/preferences/proc/ui_data_character_sheet_customizers(mob/user)
	var/list/data = list()

	var/list/customizers = pref_species.customizers
	if(!customizers)
		return data

	var/list/customizers_data = list()
	for(var/customizer_type in customizers)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer.is_allowed(src))
			continue
		var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_type)
		if(!entry)
			stack_trace("Missing customizer entry in preferences for customizer [customizer_type]")
			continue
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)

		UNTYPED_LIST_ADD(customizers_data, list(
			"name" = customizer.name,
			"type" = customizer_type,
			"disabled" = entry.disabled,
			"allows_disabling" = customizer.allows_disabling,
			// TODO: Unfuck this
			"customizer_choices_enabled" = length(customizer.customizer_choices) > 1,
			"choices" = choice.tgui_pref_choices(src, entry, customizer_type)
		))
	data["customizers"] = customizers_data

	return data
