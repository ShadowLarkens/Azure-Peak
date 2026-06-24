/datum/preferences/proc/ui_data_character_sheet_identity(mob/user)
	// TODO: this should all be in sanitization
	if(istype(virtue_origin, /datum/virtue/none))
		virtue_origin = GLOB.virtues[/datum/virtue/origin/unknown]

	if(!voice_pack)
		voice_pack = "Default"

	clean_virtues()
	if(!statpack.virtuous)
		virtuetwo = GLOB.virtues[/datum/virtue/none]

	if(!averse_chosen_faction)
		averse_chosen_faction = "Inquisition"

	var/list/data = list(
		"species_base_name" = pref_species.base_name,
		"species_sub_name" = pref_species.sub_name,
		"species_check" = spec_check(user),
		"race_bonus" = null,

		"nickname" = nickname,
		"highlight_color" = highlight_color,
		"age" = age,

		"pronouns" = pronouns,
		"titles_pref" = titles_pref,
		"clothes_pref" = clothes_pref,

		"statpack_name" = statpack.name,
		"domhand" = domhand,
		"combat_music" = (combat_music.shortname ? combat_music.shortname : combat_music.name),
		"dnr_pref" = dnr_pref,

		"virtue_origin" = "[virtue_origin]",
		"free_language" = "None",

		"voice_type" = voice_type,
		"voice_color" = voice_color,
		"voice_pack" = voice_pack,
		"voice_pitch" = voice_pitch,

		"bark_id" = bark_id,
		"bark_name" = null,
		"bark_speed" = bark_speed,
		"bark_pitch" = bark_pitch,
		"bark_variance" = bark_variance,

		// TODO: n virtues - combine into a list too
		"virtue" = virtue.ui_data(user),
		"virtue2" = statpack.virtuous ? virtuetwo.ui_data(user) : null,
	)

	// Subprocs
	data += ui_data_character_sheet_identity_charflaws(user)

	// Inline data
	if(LAZYLEN(pref_species.custom_selection))
		var/race_bonus_display
		if(race_bonus)
			for(var/bonus in pref_species.custom_selection)
				if(bonus == race_bonus)
					race_bonus_display = bonus
					break
		data["race_bonus"] = "[race_bonus_display]"

	if(ispath(extra_language, /datum/language))
		var/datum/language/selected_lang = extra_language
		data["free_language"] = selected_lang::name

	var/datum/faith/selected_faith = GLOB.faithlist[selected_patron?.associated_faith]
	data["selected_faith"] = selected_faith?.name
	data["selected_patron"] = selected_patron?.name

	var/datum/bark/B = GLOB.bark_list[bark_id]
	if(B)
		data["bark_name"] = B::name

	return data

/datum/preferences/proc/ui_data_character_sheet_identity_charflaws(mob/user)
	var/list/data = list(
		"charflaws" = list(),
		"has_averse" = FALSE,
		"averse_chosen_faction" = averse_chosen_faction,
	)

	var/has_extra_vice = FALSE
	for(var/i in 1 to LAZYLEN(charflaws))
		var/datum/charflaw/cf = charflaws[i]
		if(!cf)
			continue
		if(!cf.needs_extra_vice)
			has_extra_vice = TRUE

	var/has_averse = FALSE
	var/list/charflaws_data = list()
	for(var/i in 1 to LAZYLEN(charflaws))
		var/datum/charflaw/cf = charflaws[i]
		if(!cf)
			continue
		if(istype(cf, /datum/charflaw/averse))
			has_averse = TRUE
		UNTYPED_LIST_ADD(charflaws_data, list(
			"index" = i,
			"name" = "[cf]",
			"warning" = cf.needs_extra_vice && !has_extra_vice,
		))

	data["charflaws"] = charflaws_data
	data["has_averse"] = has_averse

	return data
