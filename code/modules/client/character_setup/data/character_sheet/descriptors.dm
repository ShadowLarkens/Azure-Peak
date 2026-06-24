/datum/preferences/proc/ui_data_character_sheet_descriptors(mob/user)
	// Data that doesn't require any conditionals goes inline here!
	var/list/data = list(
		"ooc_extra" = ooc_extra,
		"song_artist" = song_artist,
		"song_title" = song_title,
		"img_gallery_len" = LAZYLEN(img_gallery),
		"nsfw_img_gallery_len" = LAZYLEN(nsfw_img_gallery),
		// text
		"flavortext" = flavortext,
		"nsfwflavortext" = nsfwflavortext,
		"ooc_notes" = ooc_notes,
		"erpprefs" = erpprefs,
	)

	var/list/descriptor_data = list()
	for(var/choice_type in pref_species.descriptor_choices)
		var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
		var/datum/descriptor_entry/entry = get_descriptor_entry_for_choice(choice_type)
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(entry.descriptor_type)
		UNTYPED_LIST_ADD(descriptor_data, list(
			"name" = choice.name,
			"type" = choice_type,
			"descriptor" = descriptor.name,
		))
	data["descriptors"] = descriptor_data

	var/list/descriptors_custom = list()
	for(var/i in 1 to CUSTOM_DESCRIPTOR_AMOUNT)
		// Ugly, I know
		if(i == 1)
			if(!has_descriptor_type_in_entries(/datum/mob_descriptor/prominent/custom/one))
				continue
		else if(i == 2)
			if(!has_descriptor_type_in_entries(/datum/mob_descriptor/prominent/custom/two))
				continue
		else
			continue
		var/static/list/translation = CUSTOM_PREFIX_TRANSLATION_LIST
		var/datum/custom_descriptor_entry/custom_entry = custom_descriptors[i]
		UNTYPED_LIST_ADD(descriptors_custom, list(
			"index" = i,
			"translation" = translation["[custom_entry.prefix_type]"],
			"descriptor" = custom_entry.content_text,
		))
	data["descriptors_custom"] = descriptors_custom

	var/examine_theme_name = "None (Use Viewer's)"
	if(examine_theme)
		var/list/all_themes = get_tgui_themes()
		examine_theme_name = all_themes[examine_theme] || examine_theme
	data["examine_theme"] = examine_theme_name

	// clever way to reduce data: only send the markdown if they wanna see it
	if(LAZYACCESS(tgui_shared_states, "preview_flavortext"))
		data["flavortext_cached"] = flavortext_cached
	else
		data["flavortext_cached"] = null

	if(LAZYACCESS(tgui_shared_states, "preview_nsfwflavortext"))
		data["nsfwflavortext_cached"] = nsfwflavortext_cached
	else
		data["nsfwflavortext_cached"] = null

	if(LAZYACCESS(tgui_shared_states, "preview_ooc_notes"))
		data["ooc_notes_cached"] = ooc_notes_cached
	else
		data["ooc_notes_cached"] = null

	if(LAZYACCESS(tgui_shared_states, "preview_erpprefs"))
		data["erpprefs_cached"] = erpprefs_cached
	else
		data["erpprefs_cached"] = null

	return data
