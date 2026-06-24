/datum/preferences/proc/ui_act_character_sheet_body(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui.user

	switch(action)
		if("bodytype")
			var/pickedGender = "male"
			if(gender == "male")
				pickedGender = "female"
			if(pickedGender && pickedGender != gender)
				gender = pickedGender
				to_chat(user, span_warning("Your character will now use a [friendlyGenders[pickedGender]] sprite."))
				//random_character(gender)
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
			if(istype(virtue, /datum/virtue/combat/rotcured) || istype(virtuetwo, /datum/virtue/combat/rotcured))
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
