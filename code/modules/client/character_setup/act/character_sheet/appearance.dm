/datum/preferences/proc/ui_act_character_sheet_appearance(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ui_act_character_sheet_appearance_body(action, params, ui, state)
	if(.)
		return

	. = ui_act_character_sheet_appearance_customizers(action, params, ui, state)
	if(.)
		return

	. = ui_act_character_sheet_appearance_markings(action, params, ui, state)
	if(.)
		return


/datum/preferences/proc/ui_act_character_sheet_appearance_body(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui.user

	switch(action)
		if("bodytype")
			var/pickedGender = "male"
			if(gender == "male")
				pickedGender = "female"
			if(pickedGender && pickedGender != gender)
				gender = pickedGender
				to_chat(user, span_warning("Your character will now use a [friendlyGenders[pickedGender]] sprite."))
			genderize_customizer_entries()
			return CHARACTER_ACT_PREVIEW_UPDATE
		// TODO: in-menu selection
		if("species")
			var/list/species = list()
			for(var/A in GLOB.roundstart_races)
				var/datum/species/race = GLOB.species_list[A]
				race = new race()
				if(user.client)
					if(race.patreon_req > user.client.patreonlevel())
						continue
					if(race.is_subrace == TRUE)
						continue
					if(race.base_name == pref_species.base_name)
						continue
				else
					continue
				species[race.base_name] += race

			species = sortList(species)

			var/result = tgui_input_list(user, "By what shape are you bound?", "RACE", species) // TODO: default

			if(result)
				var/datum/virtue/race_chosen = species[result]
				set_new_race(race_chosen, user)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("subspecies")
			var/list/species = list()
			for(var/A in GLOB.roundstart_races)
				var/datum/species/race = GLOB.species_list[A]
				race = new race()
				if(user.client)
					if(race.base_name != pref_species.base_name)
						continue
					if(race.sub_name == pref_species.sub_name)
						continue
				else
					continue
				species[race.sub_name] += race

			var/result = tgui_input_list(user, "By what shape are you bound?", "SUBRACE", species) // TODO: default

			if(result)
				var/datum/virtue/subrace_chosen = species[result]
				set_new_race(subrace_chosen, user)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("race_bonus_select")
			if(length(pref_species.custom_selection))
				var/choice = tgui_input_list(user, "What has fate blessed your race with?", "BONUS", pref_species.custom_selection, race_bonus)
				if(choice)
					race_bonus = choice
			return CHARACTER_ACT_DATA_UPDATE
		// TODO: in-menu selection
		if("taur_type")
			var/list/species_taur_list = pref_species.get_taur_list()
			if(!LAZYLEN(species_taur_list))
				taur_type = null
				to_chat(user, span_warning("There are no available taur bodies for this species."))
				return CHARACTER_ACT_DATA_UPDATE

			var/list/taur_selection = list("None")
			for(var/obj/item/bodypart/taur/tt as anything in pref_species.get_taur_list())
				taur_selection[tt::name] = tt

			var/obj/item/bodypart/taur/current_taur = taur_type
			var/new_taur_type = tgui_input_list(user, "Choose your character's taur body", "TAUR BODY", taur_selection, current_taur ? current_taur::name : null)
			if(!new_taur_type)
				return CHARACTER_ACT_DATA_UPDATE

			if(new_taur_type == "None")
				taur_type = null
			else
				taur_type = taur_selection[new_taur_type]

			var/obj/item/bodypart/taur/tt = taur_type
			to_chat(user, span_red("Your character now has [tt ? tt::name : "no taurtype."]."))
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("taur_color")
			var/new_taur_color = color_pick_sanitized(user, "Choose your character's taur color:", "Character Preference", "#"+taur_color)
			if(new_taur_color)
				taur_color = sanitize_hexcolor(new_taur_color)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("s_tone")
			var/listy = pref_species.get_skin_list()
			if(istype(virtue, /datum/virtue/combat/second_chance) || istype(virtuetwo, /datum/virtue/combat/second_chance))
				listy["Rotten"] = SKIN_COLOR_ROT
			var/new_s_tone = tgui_input_list(user, "Choose your character's skin tone:", "SKINTONE", listy)
			if(new_s_tone)
				skin_tone = listy[new_s_tone]
				features["mcolor"] = sanitize_hexcolor(skin_tone)
				try_update_mutant_colors()
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("mutant_color")
			var/new_mutantcolor = color_pick_sanitized(user, "Choose your character's mutant #1 color:", "Character Preference","#"+features["mcolor"])
			if(new_mutantcolor)
				features["mcolor"] = new_mutantcolor
				try_update_mutant_colors()
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("mutant_color2")
			var/new_mutantcolor = color_pick_sanitized(user, "Choose your character's mutant #2 color:", "Character Preference","#"+features["mcolor2"])
			if(new_mutantcolor)
				features["mcolor2"] = new_mutantcolor
				try_update_mutant_colors()
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("mutant_color3")
			var/new_mutantcolor = color_pick_sanitized(user, "Choose your character's mutant #3 color:", "Character Preference","#"+features["mcolor3"])
			if(new_mutantcolor)
				features["mcolor3"] = new_mutantcolor
				try_update_mutant_colors()
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("body_size")
			var/new_body_size = tgui_input_number(user, "Choose your desired sprite size:\n([BODY_SIZE_MIN*100]%-[BODY_SIZE_MAX*100]%), Warning: May make your character look distorted", "Character Preference", features["body_size"]*100)
			if(new_body_size)
				new_body_size = clamp(new_body_size * 0.01, BODY_SIZE_MIN, BODY_SIZE_MAX)
				features["body_size"] = new_body_size
			return CHARACTER_ACT_PREVIEW_UPDATE

/datum/preferences/proc/try_update_mutant_colors()
	reset_body_marking_colors()
	reset_all_customizer_accessory_colors()

/datum/preferences/proc/ui_act_character_sheet_appearance_customizers(action, list/params, datum/tgui/ui, datum/ui_state/state)
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

/datum/preferences/proc/ui_act_character_sheet_appearance_markings(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui.user

	switch(action)
		if("marking_use_preset")
			var/confirm = alert(usr, "Are you sure you want to use a preset (This will clear your existing markings)?", "Markings Preset", "Yes", "No")
			if(confirm && confirm == "Yes")
				var/list/candidates = marking_sets_for_species(pref_species)
				if(length(candidates) == 0)
					return CHARACTER_ACT_DATA_UPDATE
				var/desired_set = tgui_input_list(user, "Choose your new body markings:", "Character Preference", candidates)
				if(desired_set)
					var/datum/body_marking_set/BMS = GLOB.body_marking_sets[desired_set]
					body_markings = assemble_body_markings_from_set(BMS, features, pref_species)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("marking_reset_color")
			var/zone = params["key"]
			var/name = params["name"]
			if(!body_markings[zone] || !body_markings[zone][name])
				return CHARACTER_ACT_DATA_UPDATE
			var/datum/body_marking/BM = GLOB.body_markings[name]
			body_markings[zone][name] = BM.get_default_color(features, pref_species)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("marking_change_color")
			var/zone = params["key"]
			var/name = params["name"]
			if(!body_markings[zone] || !body_markings[zone][name])
				return CHARACTER_ACT_DATA_UPDATE
			var/color = body_markings[zone][name]
			var/new_color = color_pick_sanitized(user, "Choose your markings color:", "Character Preference","#[color]")
			if(new_color)
				if(!body_markings[zone] || !body_markings[zone][name])
					return CHARACTER_ACT_DATA_UPDATE
				body_markings[zone][name] = sanitize_hexcolor(new_color, 6)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("marking_move_up")
			var/zone = params["key"]
			var/name = params["name"]
			var/list/marking_list = LAZYACCESS(body_markings, zone)
			var/current_index = LAZYFIND(marking_list, name)
			if(!current_index || --current_index < 1)
				return CHARACTER_ACT_DATA_UPDATE
			var/marking_content = marking_list[name]
			marking_list -= name
			marking_list.Insert(current_index, name)
			marking_list[name] = marking_content
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("marking_move_down")
			var/zone = params["key"]
			var/name = params["name"]
			var/list/marking_list = LAZYACCESS(body_markings, zone)
			var/current_index = LAZYFIND(marking_list, name)
			if(!current_index || ++current_index > length(marking_list))
				return CHARACTER_ACT_DATA_UPDATE
			var/marking_content = marking_list[name]
			marking_list -= name
			marking_list.Insert(current_index, name)
			marking_list[name] = marking_content
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("add_marking")
			var/zone = params["key"]
			if(!GLOB.body_markings_per_limb[zone])
				return CHARACTER_ACT_DATA_UPDATE
			var/list/possible_candidates = marking_list_of_zone_for_species(zone, pref_species)
			if(body_markings[zone])
				//To prevent exploiting hrefs to bypass the marking limit
				if(body_markings[zone].len >= MAXIMUM_MARKINGS_PER_LIMB)
					return CHARACTER_ACT_DATA_UPDATE
				//Remove already used markings from the candidates
				for(var/keyed_name in body_markings[zone])
					possible_candidates -= keyed_name
			if(possible_candidates.len == 0)
				return CHARACTER_ACT_DATA_UPDATE
			var/desired_marking = tgui_input_list(user, "Choose your new marking to add:", "Character Preference", possible_candidates)
			if(desired_marking)
				var/datum/body_marking/BD = GLOB.body_markings[desired_marking]
				if(!body_markings[zone])
					body_markings[zone] = list()
				body_markings[zone][BD.name] = BD.get_default_color(features, pref_species)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("remove_marking")
			var/zone = params["key"]
			var/name = params["name"]
			if(!body_markings[zone] || !body_markings[zone][name])
				return CHARACTER_ACT_DATA_UPDATE
			body_markings[zone] -= name
			if(body_markings[zone].len == 0)
				body_markings -= zone
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("change_marking")
			var/zone = params["key"]
			var/changing_name = params["name"]
			var/list/possible_candidates = marking_list_of_zone_for_species(zone, pref_species)
			if(body_markings[zone])
				//Remove already used markings from the candidates
				for(var/keyed_name in body_markings[zone])
					possible_candidates -= keyed_name
			if(possible_candidates.len == 0)
				return CHARACTER_ACT_DATA_UPDATE
			var/desired_marking = tgui_input_list(user, "Choose a marking to change the current one to:", "Character Preference", possible_candidates)
			if(desired_marking)
				if(!body_markings[zone] || !body_markings[zone][changing_name])
					return CHARACTER_ACT_DATA_UPDATE
				var/held_index = LAZYFIND(body_markings[zone], changing_name)
				var/datum/body_marking/BD = GLOB.body_markings[desired_marking]
				var/marking_content
				marking_content = BD.get_default_color(features, pref_species)
				body_markings[zone] -= changing_name
				body_markings[zone].Insert(held_index, desired_marking)
				body_markings[zone][desired_marking] = marking_content
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("marking_reset_all_colors")
			reset_body_marking_colors()
			return CHARACTER_ACT_PREVIEW_UPDATE

/datum/preferences/proc/validate_body_markings()
	//validating body markings
	for(var/zone in body_markings)
		for(var/name in body_markings[zone])
			if(!(name in GLOB.body_markings_per_limb[zone]))
				body_markings[zone] -= name

/datum/preferences/proc/reset_body_marking_colors()
	for(var/zone in body_markings)
		var/list/bml = body_markings[zone]
		for(var/key in bml)
			var/datum/body_marking/BM = GLOB.body_markings[key]
			bml[key] = BM.get_default_color(features, pref_species)
