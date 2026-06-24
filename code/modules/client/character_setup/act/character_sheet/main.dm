/datum/preferences/proc/ui_act_character_sheet_main(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui.user
	
	switch(action)
		if("real_name")
			var/new_name = tgui_input_text(user, "The name of this vessel?", "IDENTITY", real_name, encode = FALSE)
			if(new_name)
				new_name = reject_bad_name(new_name)
				if(new_name)
					real_name = new_name
				else
					to_chat(user, span_warning("Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ', . and ,."))
			return CHARACTER_ACT_DATA_UPDATE

		if("randomize_real_name")
			real_name = pref_species.random_name(gender,1)
			return CHARACTER_ACT_DATA_UPDATE

		if("nickname")
			var/new_name = tgui_input_text(user, "Choose your character's nickname (For Highlighting):", "NICKNAME", nickname, encode = FALSE)
			if(new_name)
				new_name = reject_bad_name(new_name)
				if(new_name)
					nickname = new_name
				else
					to_chat(user, span_warning("Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ', . and ,."))
			return CHARACTER_ACT_DATA_UPDATE

		if("highlight_color")
			var/new_color = color_pick_sanitized(user, "Choose your character's nickname highlight color:", "Character Preference", "#"+highlight_color)
			if(new_color)
				highlight_color = new_color
			return CHARACTER_ACT_DATA_UPDATE

		if("voice_color")
			var/new_voice = input(user, "Choose your character's voice color:", "Character Preference","#"+voice_color) as color|null
			if(new_voice)
				if(color_hex2num(new_voice) < 230)
					to_chat(user, span_warning("This voice color is too dark for mortals."))
					return
				voice_color = sanitize_hexcolor(new_voice)
			return CHARACTER_ACT_DATA_UPDATE

		if("pronouns")
			var/pronouns_input = tgui_input_list(user, "Choose your character's pronouns", "PRONOUNS", GLOB.pronouns_list, pronouns)
			if(pronouns_input)
				pronouns = pronouns_input
				ResetJobs() // TODO: wtf?
				to_chat(user, span_warning("Your character's pronouns are now [pronouns]."))
				to_chat(user, span_warning("<b>Your classes have been reset.</b>"))
			return CHARACTER_ACT_DATA_UPDATE

		if("titles")
			if(titles_pref == TITLES_M)
				titles_pref = TITLES_F
			else
				titles_pref = TITLES_M
			to_chat(user, span_warning("Your character's titles are now [titles_pref]."))
			return CHARACTER_ACT_DATA_UPDATE

		if("clothespref")
			if(clothes_pref == CLOTHES_M)
				clothes_pref = CLOTHES_F
			else
				clothes_pref = CLOTHES_M
			to_chat(user, span_warning("Your character's clothes are now [clothes_pref]."))
			return CHARACTER_ACT_DATA_UPDATE

		// TODO: in-menu 
		if("origin")
			var/list/virtue_choices = list()
			for(var/path as anything in GLOB.virtues)
				var/datum/virtue/V = GLOB.virtues[path]
				if(!V.name)
					continue
				if(V.name == virtue_origin.name)
					continue
				if(!istype(V, /datum/virtue/origin))
					continue
				if(V.restricted == TRUE)
					if((pref_species.type in V.races))
						continue
				if(istype(V, /datum/virtue/origin/racial))
					if(!(pref_species.type in V.races))
						continue
				virtue_choices[V.name] = V

			var/result = tgui_input_list(user, "From where do you come?", "ORIGINS", virtue_choices, virtue_origin)
			if(result)
				var/datum/virtue/virtue_chosen = virtue_choices[result]
				virtue_origin = virtue_chosen
				to_chat(user, process_virtue_text(virtue_chosen))
			return CHARACTER_ACT_DATA_UPDATE

		if("originhelp")
			var/list/dat = list()
			dat += "<b>Origin Description:</b><br>"
			dat += "[virtue_origin.origin_desc]"
			var/datum/browser/popup = new(user, "Race Help", nwidth = 600, nheight = 450)
			popup.set_content(dat.Join())
			popup.open(FALSE)
			return CHARACTER_ACT_DATA_UPDATE

		if("extra_language")
			var/static/list/selectable_languages = list(
				/datum/language/elvish,
				/datum/language/dwarvish,
				/datum/language/orcish,
				/datum/language/hellspeak,
				/datum/language/draconic,
				/datum/language/celestial,
				/datum/language/raneshi,
				/datum/language/grenzelhoftian,
				/datum/language/kazengunese,
				/datum/language/lingyuese,
				/datum/language/etruscan,
				/datum/language/gronnic,
				/datum/language/otavan,
				/datum/language/aavnic,
			)
			var/list/choices = list("None")
			for(var/language in selectable_languages)
				if(language in pref_species.languages)
					continue
				var/datum/language/a_language = new language()
				choices[a_language.name] = language

			var/chosen_language = tgui_input_list(user, "Choose your character's extra language:", "EXTRA LANGUAGE", choices, extra_language)
			if(chosen_language)
				if(chosen_language == "None")
					extra_language = "None"
				else
					extra_language = choices[chosen_language]
			return CHARACTER_ACT_DATA_UPDATE

		// TODO: in-menu
		if("statpack")
			var/list/statpacks_available = list()
			var/list/statpack_descriptions = list()
			for(var/path as anything in GLOB.statpacks)
				var/datum/statpack/statpack = GLOB.statpacks[path]
				if(!statpack.name)
					continue
				var/index = statpack.name
				if(length(statpack.stat_array))
					var/modifier_string = statpack.generate_modifier_string()
					index += " [modifier_string]"
					statpack_descriptions[index] = modifier_string
				statpacks_available[index] = statpack

			statpacks_available = sort_list(statpacks_available)

			var/statpack_input = tgui_input_list(user, "How shall your strengths manifest?", "STATPACK", statpacks_available, statpack, descriptions = statpack_descriptions)
			if(statpack_input)
				var/datum/statpack/statpack_chosen = statpacks_available[statpack_input]
				statpack = statpack_chosen
				to_chat(user, span_purple("[statpack.name]"))
				to_chat(user, span_purple("[statpack.description_string()]"))
			return CHARACTER_ACT_DATA_UPDATE

		if("age")
			var/new_age = tgui_input_list(user, "Choose your character's age (18-[pref_species.max_age])", "YILS LIVED", pref_species.possible_ages, age)
			if(new_age)
				age = new_age
				switch(age)
					if(AGE_ADULT)
						to_chat(user, "You preside in your 'prime', whatever this may be, and gain no bonus nor endure any penalty for your time spent alive.")
					if(AGE_MIDDLEAGED)
						to_chat(user, "Muscles ache and joints begin to slow as Aeon's grasp begins to settle upon your shoulders. (-1 SPD, +1 WIL +1 FOR)")
					if(AGE_OLD)
						to_chat(user, "In a place as lethal as PSYDONIA, the elderly are all but marvels... or beneficiaries of the habitually privileged. (-1 STR, -2 SPE, -1 PER, -2 CON, +2 INT, +1 FOR)")
				ResetJobs() // TODO: almost certain this is not necessary...
				to_chat(user, span_warning("Classes reset."))
			return CHARACTER_ACT_DATA_UPDATE

		if("domhand")
			if(domhand == 1)
				domhand = 2
			else
				domhand = 1
			return CHARACTER_ACT_DATA_UPDATE

		if("combat_music") // if u change shit here look at /client/verb/combat_music() too
			if(!combat_music_helptext_shown)
				to_chat(user, span_notice(span_bold("Combat Music Override\n")) + \
				span_notice("Options other than \"Default\" override whatever the game dynamically sets for you, \
				which is influenced by your job class, villain status, or certain events.\n\
				You can change this later through \"Combat Mode Music\" in the Options tab.\""))
				combat_music_helptext_shown = TRUE
			var/track_select = tgui_input_list(user, "To you, the Signal sounds like:", "COMBAT MUSIC", GLOB.cmode_tracks_by_name, combat_music?.name)
			if(track_select)
				combat_music = GLOB.cmode_tracks_by_name[track_select]
				to_chat(user, span_notice("Selected track: <b>[track_select]</b>."))
				if(combat_music.desc)
					to_chat(user, "<i>[combat_music.desc]</i>")
				if(combat_music.credits)
					to_chat(user, span_info("Song name: <b>[combat_music.credits]</b>"))
			return CHARACTER_ACT_DATA_UPDATE

		if("dnr_pref")
			dnr_pref = !dnr_pref
			return CHARACTER_ACT_DATA_UPDATE

		if("culinary_prefs")
			show_culinary_ui(user)
			return CHARACTER_ACT_DATA_UPDATE

		if("familiar_prefs")
			familiar_prefs.fam_show_ui()
			return CHARACTER_ACT_DATA_UPDATE

		if("faith")
			var/list/faiths_named = list()
			for(var/path as anything in GLOB.preference_faiths)
				var/datum/faith/faith = GLOB.faithlist[path]
				if(!faith.name)
					continue
				faiths_named[faith.name] = faith
			var/faith_input = tgui_input_list(user, "The world rots. Which truth you bear?", "FAITH", faiths_named)
			if(faith_input)
				var/datum/faith/faith = faiths_named[faith_input]
				to_chat(user, "<font color='yellow'>Faith: [faith.name]</font>")
				to_chat(user, "Background: [faith.desc]")
				to_chat(user, "<font color='red'>Likely Worshippers: [faith.worshippers]</font>")
				selected_patron = GLOB.patronlist[faith.godhead] || GLOB.patronlist[pick(GLOB.patrons_by_faith[faith_input])]
			return CHARACTER_ACT_DATA_UPDATE

		if("patron")
			var/list/patrons_named = list()
			for(var/path as anything in GLOB.patrons_by_faith[selected_patron?.associated_faith || initial(default_patron.associated_faith)])
				var/datum/patron/patron = GLOB.patronlist[path]
				if(!patron.name)
					continue
				patrons_named[patron.name] = patron
			var/god_input = tgui_input_list(user, "The first amongst many.", "PATRON", patrons_named, selected_patron?.name)
			if(god_input)
				selected_patron = patrons_named[god_input]
				to_chat(user, "<font color='yellow'>Patron: [selected_patron]</font>")
				to_chat(user, "<font color='#FFA500'>Domain: [selected_patron.domain]</font>")
				to_chat(user, "Background: [selected_patron.desc]")
				to_chat(user, "<font color='red'>Likely Worshippers: [selected_patron.worshippers]</font>")
			return CHARACTER_ACT_DATA_UPDATE

		if("voicetype")
			var/voicetype_input = tgui_input_list(user, "Choose your character's voice type", "VOICE TYPE", GLOB.voice_types_list, voice_type)
			if(voicetype_input)
				voice_type = voicetype_input
				to_chat(user, span_warning("Your character will now vocalize with a [lowertext(voice_type)] affect."))
			return CHARACTER_ACT_DATA_UPDATE

		if("voicepack")
			var/voicepack_input = tgui_input_list(user, "Choose your character's emote voice pack", "VOICE PACK", GLOB.voice_packs_list, voice_pack)
			if(voicepack_input)
				voice_pack = voicepack_input
				if(voicepack_input != "Default")
					to_chat(user, span_warning("Your character will now audibly emote with a [lowertext(voicepack_input)] affect.") + span_notice("<br>This will override your Voice Identity and Class-specific voice packs."))
				else
					to_chat(user, span_warning("Your character will now audibly emote in accordance to their Voice Identity and any Racial / Class-specific voice packs."))
			return CHARACTER_ACT_DATA_UPDATE

		if("voice_pitch")
			var/new_voice_pitch = tgui_input_number(user, "Choose your character's voice pitch ([MIN_VOICE_PITCH] to [MAX_VOICE_PITCH], lower is deeper):", "Voice Pitch", voice_pitch, 1.35, 0.8, round_value = FALSE)
			if(new_voice_pitch)
				if(new_voice_pitch < MIN_VOICE_PITCH || new_voice_pitch > MAX_VOICE_PITCH)
					to_chat(user, span_warning("Value must be between [MIN_VOICE_PITCH] and [MAX_VOICE_PITCH]."))
					return
				voice_pitch = new_voice_pitch
			return CHARACTER_ACT_DATA_UPDATE

		if("voicepack_preview")
			var/datum/voicepack/VP = get_effective_voicepack()
			var/modifier
			if(age == AGE_OLD)
				modifier = "old"
			var/voiceline = VP.get_sound(pick(VP.preview), modifier)
			if(islist(voiceline) && length(voiceline) > 1)
				voiceline = pick(voiceline)
			user.playsound_local(user, voiceline, 100, frequency = voice_pitch)
			return CHARACTER_ACT_DATA_UPDATE

		if("voicepack_preview_emote")
			var/datum/voicepack/VP = get_effective_voicepack()
			var/modifier
			if(age == AGE_OLD)
				modifier = "old"

			var/emote_picked = tgui_input_list(user, "Choose emote to preview", "Voicepack Preview", VP.preview)
			if(emote_picked)
				var/voiceline = VP.get_sound(emote_picked, modifier)
				if(islist(voiceline) && length(voiceline) > 1)
					voiceline = pick(voiceline)
				user.playsound_local(user, voiceline, 100, frequency = voice_pitch)
			return CHARACTER_ACT_DATA_UPDATE

		if("select_virtue")
			// Note: we are always allowed to select whatever we want for virtuetwo,
			// as apply_prefs_virtue will just ignore it if we're not virtuous.
			var/key = params["key"]
			if(!(key in list("virtue1", "virtue2"))) // INSTRUCTIONS FOR DOWNSTREAM: Add virtue3
				return CHARACTER_ACT_DATA_UPDATE

			var/list/already_taken = list(virtue.name, virtuetwo.name) // INSTRUCTIONS FOR DOWNSTREAM: Add virtuethree
			
			var/list/virtue_choices = list()
			for(var/path as anything in GLOB.virtues)
				var/datum/virtue/V = GLOB.virtues[path]
				if(!V.name)
					continue
				if(istype(V, /datum/virtue/origin))
					continue
				if(V.unlisted)
					continue
				if(!V.stackable && !istype(V, /datum/virtue/none))
					if(V.name in already_taken)
						continue
				if(istype(V, /datum/virtue/heretic) && !istype(selected_patron, /datum/patron/inhumen))
					continue
				if(V.restricted == TRUE)
					if((pref_species.type in V.races))
						continue
				if(V.virtuous_only && !statpack.virtuous)
					continue
				virtue_choices[V.name] = V

			var/result = tgui_input_list(user, "What strength shall you wield?", "VIRTUES", virtue_choices)

			if(result)
				var/datum/virtue/virtue_chosen = virtue_choices[result]
				switch(key)
					if("virtue1")
						virtue = new virtue_chosen.type
					if("virtue2")
						virtuetwo = new virtue_chosen.type
					// INSTRUCTIONS FOR DOWNSTREAM: Uncomment
					// if("virtue3")
					// 	virtuethree = new virtue_chosen.type

				to_chat(user, process_virtue_text(virtue_chosen))

				var/list/virtues = list(virtue, virtuetwo) // INSTRUCTIONS FOR DOWNSTREAM: Add virtuethree

				if(skin_tone == SKIN_COLOR_ROT)
					var/should_rot = FALSE
					for(var/datum/virtue/combat/rotcured/R as anything in virtues)
						should_rot = TRUE
						break
					if(!should_rot)
						var/new_tone = random_skin_tone()
						skin_tone = new_tone
						features["mcolor"] = sanitize_hexcolor(new_tone)
						try_update_mutant_colors()
			return CHARACTER_ACT_PREVIEW_UPDATE

		if("subvirtue")
			// Note: we are always allowed to select whatever we want for virtuetwo,
			// as apply_prefs_virtue will just ignore it if we're not virtuous.
			var/key = params["key"]
			if(!(key in list("virtue1", "virtue2"))) // INSTRUCTIONS FOR DOWNSTREAM: Add virtue3
				return TRUE
		
			var/datum/virtue/relevant_virtue
			switch(key)
				if("virtue1")
					relevant_virtue = virtue
				if("virtue2")
					relevant_virtue = virtuetwo
				// INSTRUCTIONS FOR DOWNSTREAM: Uncomment
				// if("virtue3")
				// 	relevant_virtue = virtuethree

			var/task = params["task"]
			switch(task)
				if("add")
					if(length(relevant_virtue.picked_choices) < relevant_virtue.max_choices)
						var/list/subchoices = relevant_virtue.extra_choices.Copy()
						for(var/choice in subchoices)
							if(choice in relevant_virtue.picked_choices)
								subchoices.Remove(choice)
						var/result = tgui_input_list(user, "What strength shall you wield?", "VIRTUES", subchoices)
						if(result)
							relevant_virtue.picked_choices.Add(result)
				if("remove")
					var/index = text2num(params["index"])
					if(index && (index >= 1) && (index <= relevant_virtue.picked_choices.len))
						var/v_to_remove = relevant_virtue.picked_choices[index]
						relevant_virtue.picked_choices.Remove(v_to_remove)
			return CHARACTER_ACT_DATA_UPDATE

		if("charflaw")
			var/task = params["task"]
			switch(task)
				// TODO: in-menu
				if("add")
					for(var/datum/charflaw/_existing in charflaws)
						if(istype(_existing, /datum/charflaw/noflaw))
							charflaws.Remove(_existing)
							break

					if(charflaws.len >= MAX_VICES)
						to_chat(user, "I can't be any more flawed.")
						return

					var/list/cf_list = GLOB.character_flaws.Copy()

					for(var/key in cf_list)
						if(cf_list[key] == /datum/charflaw/noflaw)
							cf_list.Remove(key)
						else
							var/datum/charflaw/cf = cf_list[key]
							cf = new cf()
							if(length(cf.restricted_species) && (pref_species.type in cf.restricted_species))
								cf_list.Remove(key)

					for(var/datum/charflaw/cf in charflaws)
						for(var/key in cf_list)
							if(cf_list[key] == cf.type && !istype(cf, /datum/charflaw/randflaw))
								cf_list.Remove(key)
								break

					var/result = tgui_input_list(user, "What burden will you bear? (You can select up to 3 vices)", "FLAWS", cf_list)
					if(result)
						result = cf_list[result]
						var/datum/charflaw/C = new result()
						charflaws.Add(C)
						if(C.desc)
							to_chat(user, span_info(C.desc))

				if("remove")
					var/index = text2num(params["index"])
					if(index && (index >= 1) && (index <= charflaws.len))
						var/datum/charflaw/cf_to_remove = charflaws[index]
						charflaws.Remove(cf_to_remove)
						to_chat(user, span_notice("Vice removed: [cf_to_remove.name]."))

					if(!charflaws.len)
						var/datum/charflaw/no_flaw = new /datum/charflaw/noflaw()
						charflaws.Add(no_flaw)
						to_chat(user, span_info("No vices selected. 'No Flaw' has been automatically selected."))

			return CHARACTER_ACT_DATA_UPDATE

		if("charflaw_averse_choice")
			var/choice = tgui_input_list(user, "Who do you loathe?", "AVERSION", GLOB.averse_factions, averse_chosen_faction)
			if(choice)
				averse_chosen_faction = choice
			return CHARACTER_ACT_DATA_UPDATE

		if("open_loadout")
			var/datum/loadout_menu/LM = new(user.client)
			LM.ui_interact(user)
			return CHARACTER_ACT_DATA_UPDATE

		if("barksound")
			var/list/woof_woof = list()
			for(var/path in GLOB.bark_list)
				var/datum/bark/B = GLOB.bark_list[path]
				if(initial(B.ignore))
					continue
				if(initial(B.ckeys_allowed))
					var/list/allowed = initial(B.ckeys_allowed)
					if(!allowed.Find(user.client.ckey))
						continue
				woof_woof[initial(B.name)] = initial(B.id)
			var/new_bork = tgui_input_list(user, "Choose your desired vocal bark", "Character Preference", woof_woof, bark_id)
			if(new_bork)
				bark_id = woof_woof[new_bork]
				var/datum/bark/B = GLOB.bark_list[bark_id] //Now we need sanitization to take into account bark-specific min/max values
				bark_speed = round(clamp(bark_speed, initial(B.minspeed), initial(B.maxspeed)), 1)
				bark_pitch = clamp(bark_pitch, initial(B.minpitch), initial(B.maxpitch))
				bark_variance = clamp(bark_variance, initial(B.minvariance), initial(B.maxvariance))
			return CHARACTER_ACT_DATA_UPDATE

		if("barkspeed")
			var/datum/bark/B = GLOB.bark_list[bark_id]
			if(!B)
				to_chat(user, span_danger("ERROR: Vocal bark set to an invalid option."))
				return CHARACTER_ACT_DATA_UPDATE
			var/borkset = tgui_input_number(user, "Choose your desired bark speed (Higher is slower, lower is faster).", "Character Preference", bark_speed, B.maxspeed, B.minspeed)
			if(!isnull(borkset))
				bark_speed = borkset
			return CHARACTER_ACT_DATA_UPDATE

		if("barkpitch")
			var/datum/bark/B = GLOB.bark_list[bark_id]
			if(!B)
				to_chat(user, span_danger("ERROR: Vocal bark set to an invalid option."))
				return CHARACTER_ACT_DATA_UPDATE
			var/borkset = tgui_input_number(user, "Choose your desired baseline bark pitch.", "Character Preference", bark_pitch, B.minpitch, B.maxpitch, round_value = FALSE)
			if(!isnull(borkset))
				bark_pitch = borkset
			return CHARACTER_ACT_DATA_UPDATE

		if("barkvary")
			var/datum/bark/B = GLOB.bark_list[bark_id]
			if(!B)
				to_chat(user, span_danger("ERROR: Vocal bark set to an invalid option."))
				return CHARACTER_ACT_DATA_UPDATE
			var/borkset = tgui_input_number(user, "Choose your desired baseline bark variance.", "Character Preference", bark_variance, B.minvariance, B.maxvariance, round_value = FALSE)
			if(!isnull(borkset))
				bark_variance = borkset
			return CHARACTER_ACT_DATA_UPDATE

		if("barkpreview")
			var/datum/bark/B = GLOB.bark_list[bark_id]
			if(!B)
				to_chat(user, span_danger("ERROR: Vocal bark set to an invalid option."))
				return CHARACTER_ACT_DATA_UPDATE
			if(B?.soundpath)
				user.playsound_local(user, vol = 70, vary = TRUE, frequency = BARK_DO_VARY(bark_pitch, bark_variance), S = B.soundpath)
			else
				to_chat(user, span_warning("Your current bark has no sound."))
			return CHARACTER_ACT_DATA_UPDATE
