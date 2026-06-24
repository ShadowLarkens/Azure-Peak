/datum/preferences/proc/ui_data_game_settings(mob/user)
	var/list/data = list()

	data["tgui_theme"] = get_tgui_theme_display_name()
	data["parchment_skin"] = get_parchment_skin_display_name()
	data["statbrowser_theme"] = get_statbrowser_theme_display_name()
	data["tgui_input"] = tgui_pref
	data["tgui_lock"] = tgui_lock
	data["ambientocclusion"] = ambientocclusion
	data["windowflashing"] = windowflashing
	data["clientfps"] = clientfps
	data["auto_fit_viewport"] = auto_fit_viewport
	data["schizo_voice"] = (toggles & SCHIZO_VOICE)
	data["no_storyteller_events"] = no_storyteller_events
	
	// TODO: this belongs in sanitization
	if(is_banned_from(user.ckey, ROLE_SYNDICATE))
		be_special = list()

	var/list/antags = list()
	for(var/key in GLOB.special_roles_rogue)
		var/days_remaining = null
		if(ispath(GLOB.special_roles_rogue[key]) && CONFIG_GET(flag/use_age_restriction_for_jobs)) //If it's a game mode antag, check if the player meets the minimum age
			days_remaining = get_remaining_days(user.client)
		
		UNTYPED_LIST_ADD(antags, list(
			"key" = key,
			"banned" = is_banned_from(user.ckey, key),
			"days_remaining" = days_remaining,
			"enabled" = (key in be_special),
		))

	data["antags"] = antags

	return data
