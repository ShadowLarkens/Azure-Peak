/datum/preferences/proc/ui_act_character_sheet_villain(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui.user

	switch(action)
		if("lich_headshot")
			to_chat(user, span_notice("Please use a relatively SFW image of the head and shoulder area to maintain immersion level. Lastly, [span_bold("do not use a real life photo or use any image that is less than serious.")]"))
			to_chat(user, span_notice("If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser."))
			to_chat(user, span_notice("Keep in mind that the photo will be downsized to 325x325 pixels, so the more square the photo, the better it will look."))
			var/new_lich_headshot_link = tgui_input_text(user, "Input the Lich headshot link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "Lich Headshot", lich_headshot_link,  encode = FALSE)
			if(new_lich_headshot_link == null)
				return CHARACTER_ACT_DATA_UPDATE
			if(new_lich_headshot_link == "")
				lich_headshot_link = null
				return CHARACTER_ACT_DATA_UPDATE
			if(!valid_headshot_link(user, new_lich_headshot_link))
				lich_headshot_link = null
				return CHARACTER_ACT_DATA_UPDATE
			lich_headshot_link = new_lich_headshot_link
			to_chat(user, span_notice("Successfully updated lich headshot picture"))
			log_game("[user] has set their lich Headshot image to '[lich_headshot_link]'.")
			return CHARACTER_ACT_DATA_UPDATE

		if("vampire_headshot")
			to_chat(user, span_notice("Please use a relatively SFW image of the head and shoulder area to maintain immersion level. Lastly, [span_bold("do not use a real life photo or use any image that is less than serious.")]"))
			to_chat(user, span_notice("If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser."))
			to_chat(user, span_notice("Keep in mind that the photo will be downsized to 325x325 pixels, so the more square the photo, the better it will look."))
			var/new_vampire_headshot_link = tgui_input_text(user, "Input the vampire headshot link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "Vampire Headshot", vampire_headshot_link,  encode = FALSE)
			if(new_vampire_headshot_link == null)
				return CHARACTER_ACT_DATA_UPDATE
			if(new_vampire_headshot_link == "")
				vampire_headshot_link = null
				return CHARACTER_ACT_DATA_UPDATE
			if(!valid_headshot_link(user, new_vampire_headshot_link))
				vampire_headshot_link = null
				return CHARACTER_ACT_DATA_UPDATE
			vampire_headshot_link = new_vampire_headshot_link
			to_chat(user, span_notice("Successfully updated vampire headshot picture"))
			log_game("[user] has set their vampire Headshot image to '[vampire_headshot_link]'.")
			return CHARACTER_ACT_DATA_UPDATE

		if("vampire_hair")
			var/new_vampirehair = input(user, "Choose your character's vampire hair color:", "Character Preference", vampire_hair) as color|null
			if(new_vampirehair)
				vampire_hair = new_vampirehair
			return CHARACTER_ACT_DATA_UPDATE

		if("vampire_eyes")
			var/new_vampireeyes = input(user, "Choose your character's vampire eye color:", "Character Preference", vampire_eyes) as color|null
			if(new_vampireeyes)
				vampire_eyes = new_vampireeyes
			return CHARACTER_ACT_DATA_UPDATE

		if("vampire_skin")
			var/new_vampireskin = input(user, "Choose your character's vampire skin color:", "Character Preference", vampire_skin) as color|null
			if(new_vampireskin)
				vampire_skin = new_vampireskin
			return CHARACTER_ACT_DATA_UPDATE

		if("vampire_ears")
			var/new_vampireears = input(user, "Choose your character's vampire ear color:", "Character Preference", vampire_ears) as color|null
			if(new_vampireears)
				vampire_ears = new_vampireears
			return CHARACTER_ACT_DATA_UPDATE

		if("vampire_hair_clear")
			vampire_hair = null
			return CHARACTER_ACT_DATA_UPDATE

		if("vampire_eyes_clear")
			vampire_eyes = null
			return CHARACTER_ACT_DATA_UPDATE

		if("vampire_skin_clear")
			vampire_skin = null
			return CHARACTER_ACT_DATA_UPDATE

		if("vampire_ears_clear")
			vampire_ears = null
			return CHARACTER_ACT_DATA_UPDATE

		if("qsr_pref")
			qsr_pref = !qsr_pref
			return CHARACTER_ACT_DATA_UPDATE

		if("preset_bounty_toggle")
			preset_bounty_enabled = !preset_bounty_enabled
			return CHARACTER_ACT_DATA_UPDATE

		if("preset_bounty_poster_key")
			var/list/poster_choices = list()
			for(var/key in GLOB.bounty_posters)
				poster_choices[GLOB.bounty_posters[key]] = key
			var/choice = tgui_input_list(user, "Who placed a bounty on you?", "Bounty Poster", poster_choices, preset_bounty_poster_key)
			if(choice)
				preset_bounty_poster_key = poster_choices[choice]
			return CHARACTER_ACT_DATA_UPDATE

		if("preset_bounty_severity_key")
			var/list/sev_choices = list()
			for(var/key in GLOB.wretch_severities)
				sev_choices[GLOB.wretch_severities[key]] = key
			var/choice = tgui_input_list(user, "How severe are your crimes?", "Bounty Amount", sev_choices, preset_bounty_severity_key)
			if(choice)
				preset_bounty_severity_key = sev_choices[choice]
			return CHARACTER_ACT_DATA_UPDATE

		if("preset_bounty_severity_b_key")
			var/list/sev_choices = list()
			for(var/key in GLOB.bandit_severities)
				sev_choices[GLOB.bandit_severities[key]] = key
			var/choice = tgui_input_list(user, "How notorious are you?", "Bounty Amount", sev_choices, preset_bounty_severity_b_key)
			if(choice)
				preset_bounty_severity_b_key = sev_choices[choice]
			return CHARACTER_ACT_DATA_UPDATE

		if("preset_bounty_crime")
			preset_bounty_crime = tgui_input_text(user, "What is your crime?", "Crime", preset_bounty_crime)
			return CHARACTER_ACT_DATA_UPDATE
