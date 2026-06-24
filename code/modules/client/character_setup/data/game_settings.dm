/datum/preferences/proc/ui_data_game_settings(mob/user)
	// TODO: this belongs in sanitization
	if(is_banned_from(user.ckey, ROLE_SYNDICATE))
		be_special = list()

	var/list/data = list(
		"tgui_theme" = get_tgui_theme_display_name(),
		"parchment_skin" = get_parchment_skin_display_name(),
		"statbrowser_theme" = get_statbrowser_theme_display_name(),
		"tgui_input" = tgui_pref,
		"tgui_lock" = tgui_lock,
		"ambientocclusion" = ambientocclusion,
		"windowflashing" = windowflashing,
		"clientfps" = clientfps,
		"auto_fit_viewport" = auto_fit_viewport,
		"schizo_voice" = (toggles & SCHIZO_VOICE),
		"no_storyteller_events" = no_storyteller_events,
		"admin_prefs" = ui_data_admin_prefs(user),
		"antags" = list(),
	)

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

/proc/get_parchment_skins()
	var/static/list/skins = list(
		"vellum" = "Vellum",
		"parchment" = "Parchment",
		"leatherbound" = "Leatherbound",
	)
	return skins

/proc/get_statbrowser_themes()
	var/static/list/themes = list(
		"dark" = "Matte Black",
		"light" = "Leatherbound",
	)
	return themes

// Get the display name of the current TGUI theme
/datum/preferences/proc/get_tgui_theme_display_name()
	var/list/themes = get_tgui_themes()
	return themes[tgui_theme] || tgui_theme

/datum/preferences/proc/get_parchment_skin_display_name()
	var/list/skins = get_parchment_skins()
	return skins[parchment_skin] || skins["leatherbound"]

/datum/preferences/proc/get_statbrowser_theme_display_name()
	var/list/themes = get_statbrowser_themes()
	return themes[statbrowser_theme] || themes["dark"]

/datum/preferences/proc/ui_data_admin_prefs(mob/user)
	if(!user.client.holder)
		return null

	return list(
		"sound_adminhelp" = toggles & SOUND_ADMINHELP,
		"sound_prayers" = toggles & SOUND_PRAYERS,
		"announce_login" = toggles & ANNOUNCE_LOGIN,
		"combohud_lighting" = toggles & COMBOHUD_LIGHTING,
		"show_dsay" = chat_toggles & CHAT_DSAY,
		"show_prayer" = chat_toggles & CHAT_PRAYER,
		"allow_asaycolor" = CONFIG_GET(flag/allow_admin_asaycolor),
		"asaycolor" = asaycolor,
		"auto_deadmin_players" = CONFIG_GET(flag/auto_deadmin_players),
		"deadmin_player" = toggles & DEADMIN_ALWAYS,
		"auto_deadmin_antagonists" = CONFIG_GET(flag/auto_deadmin_antagonists),
		"deadmin_antagonist" = toggles & DEADMIN_ANTAGONIST,
		"auto_deadmin_heads" = CONFIG_GET(flag/auto_deadmin_heads),
		"deadmin_head" = toggles & DEADMIN_POSITION_HEAD,
	)