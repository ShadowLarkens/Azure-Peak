/datum/preferences/proc/ui_act_character_sheet_customizers(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(action != "change_customizer")
		return

	var/mob/user = ui.user
	//needs_update = TRUE
	var/customizer_type = text2path(params["customizer"])
	var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_type)
	if(!entry)
		return CHARACTER_ACT_DATA_UPDATE
	var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
	var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
	switch(params["customizer_task"])
		if("toggle_missing")
			if(customizer.allows_disabling)
				entry.disabled = !entry.disabled
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("change_choice")
			var/list/choice_list = list()
			for(var/choice_type in customizer.customizer_choices)
				var/datum/customizer_choice/iter_choice = CUSTOMIZER_CHOICE(choice_type)
				choice_list[iter_choice.name] = choice_type
			var/chosen_input = tgui_input_list(user, "Choose your [lowertext(customizer.name)]:", "Character Preference", choice_list)
			if(!chosen_input)
				return CHARACTER_ACT_DATA_UPDATE
			var/choice_type = choice_list[chosen_input]
			if(choice_type == choice.type)
				return CHARACTER_ACT_DATA_UPDATE
			customizer_entries -= entry
			customizer_entries += customizer.create_customizer_entry(src, choice_type)
			return CHARACTER_ACT_PREVIEW_UPDATE
		else
			choice.handle_tgui_act(params, ui, src, entry, customizer_type)
			return CHARACTER_ACT_PREVIEW_UPDATE