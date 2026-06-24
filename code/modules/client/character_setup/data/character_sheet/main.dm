/datum/preferences/proc/ui_data_character_sheet_main(mob/user)
	// Data that doesn't require any conditionals goes inline here!
	var/list/data = list(
		// Core data
		"slot" = loaded_slot,
		"real_name" = real_name,
		"headshot_link" = headshot_link,
		"pq" = get_playerquality(parent.ckey, text = TRUE),
		"hide_pq" = FALSE, // INSTRUCTIONS FOR DOWNSTREAM: Override!
		"triumphs" = user.get_triumphs(),
		"agevet" = user.check_agevet(),

		// Identity Data
		"nickname" = nickname,
		"highlight_color" = highlight_color,
		"pronouns" = pronouns,
		"titles_pref" = titles_pref,
		"clothes_pref" = clothes_pref,
		"statpack_name" = statpack.name,
		"age" = age,
		"domhand" = domhand,
		"combat_music" = (combat_music.shortname ? combat_music.shortname : combat_music.name),
		"dnr_pref" = dnr_pref,
		"voice_type" = voice_type,
		"voice_color" = voice_color,
		"voice_pitch" = voice_pitch,
		"bark_id" = bark_id,
		"bark_speed" = bark_speed,
		"bark_pitch" = bark_pitch,
		"bark_variance" = bark_variance,
	)

	if(character_preview_view)
		data["character_preview_view"] = character_preview_view.assigned_map
	else
		data["character_preview_view"] = null
	
	if(istype(virtue_origin, /datum/virtue/none))
		virtue_origin = GLOB.virtues[/datum/virtue/origin/unknown]
	data["virtue_origin"] = "[virtue_origin]"

	var/datum/language/selected_lang
	var/lang_output = "None"
	if(ispath(extra_language, /datum/language))
		selected_lang = extra_language
		lang_output = initial(selected_lang.name)

	data["free_language"] = lang_output

	var/datum/faith/selected_faith = GLOB.faithlist[selected_patron?.associated_faith]
	data["selected_faith"] = selected_faith?.name
	data["selected_patron"] = selected_patron?.name

	// TODO: this should be in sanitization
	if(!voice_pack)
		voice_pack = "Default"
	data["voice_pack"] = voice_pack

	var/datum/bark/B = GLOB.bark_list[bark_id]
	if(B)
		data["bark_name"] = B.name
	else
		data["bark_name"] = null

	// TODO: this should be in sanitization
	clean_virtues()
	// TODO: n virtues - combine into a list too
	data["virtue"] = virtue.ui_data(user)

	if(statpack.virtuous)
		data["virtue2"] = virtuetwo.ui_data(user)
	else
		// TODO: this should be in sanitization
		virtuetwo = GLOB.virtues[/datum/virtue/none]
		data["virtue2"] = null

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

	if(!averse_chosen_faction)
		averse_chosen_faction = "Inquisition"
	data["has_averse"] = has_averse
	data["averse_chosen_faction"] = averse_chosen_faction

	return data
