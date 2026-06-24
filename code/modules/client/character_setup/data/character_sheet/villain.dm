/datum/preferences/proc/ui_data_character_sheet_villain(mob/user)
	var/list/data = list(
		"antag_banned" = is_banned_from(user.ckey, ROLE_SYNDICATE),
		"lich_headshot_link" = lich_headshot_link,
		"vampire_headshot_link" = vampire_headshot_link,
		"vampire_skin" = vampire_skin,
		"vampire_eyes" = vampire_eyes,
		"vampire_hair" = vampire_hair,
		"vampire_ears" = vampire_ears,
		"qsr_pref" = qsr_pref,
		"preset_bounty_enabled" = preset_bounty_enabled,
		"preset_bounty_crime" = preset_bounty_crime,
	)
	
	// TODO: this belongs in sanitization
	if(preset_bounty_poster_key && !GLOB.bounty_posters[preset_bounty_poster_key])
		preset_bounty_poster_key = null

	if(preset_bounty_severity_key && !GLOB.wretch_severities[preset_bounty_severity_key])
		preset_bounty_severity_key = null

	if(preset_bounty_severity_b_key && !GLOB.bandit_severities[preset_bounty_severity_b_key])
		preset_bounty_severity_b_key = null

	data["bounty_posters"] = GLOB.bounty_posters[preset_bounty_poster_key]
	data["wretch_severities"] = GLOB.wretch_severities[preset_bounty_severity_key]
	data["bandit_severities"] = GLOB.bandit_severities[preset_bounty_severity_b_key]

	return data
