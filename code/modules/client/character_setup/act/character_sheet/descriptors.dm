/datum/preferences/proc/ui_act_character_sheet_descriptors(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui.user

	switch(action)
		if("choose_descriptor")
			var/choice_type = text2path(params["type"])
			if(!(choice_type in pref_species.descriptor_choices))
				return CHARACTER_ACT_DATA_UPDATE
			var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
			if(!choice)
				return CHARACTER_ACT_DATA_UPDATE
			var/list/picklist = list()
			for(var/desc_type in choice.descriptors)
				var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(desc_type)
				picklist[descriptor.name] = desc_type
			var/picked_descriptor_name = tgui_input_list(user, "Describe my [lowertext(choice.name)]", "Describe myself", picklist)
			if(!picked_descriptor_name)
				return CHARACTER_ACT_DATA_UPDATE
			var/picked_type = picklist[picked_descriptor_name]
			var/datum/descriptor_entry/entry = get_descriptor_entry_for_choice(choice_type)
			entry.descriptor_type = picked_type
			return CHARACTER_ACT_DATA_UPDATE

		if("custom_descriptor_prefix")
			var/static/list/full_translation = CUSTOM_PREFIX_TRANSLATION_LIST
			var/static/list/full_input = CUSTOM_PREFIX_INPUT_LIST
			var/static/list/article_translation = CUSTOM_ARTICLE_TRANSLATION_LIST
			var/static/list/article_input = CUSTOM_ARTICLE_INPUT_LIST
			var/static/list/article_only_types = CUSTOM_DESCRIPTOR_ARTICLE_ONLY
			var/static/list/custom_descriptor_types = CUSTOM_DESCRIPTOR_TYPE_LIST
			var/index = text2num(params["index"])
			var/datum/custom_descriptor_entry/custom_entry = custom_descriptors[index]
			var/is_article_only = (custom_descriptor_types[index] in article_only_types)
			var/translation = is_article_only ? article_translation : full_translation
			var/input_list = is_article_only ? article_input : full_input
			var/current_prefix_text = translation["[custom_entry.prefix_type]"]
			if(!current_prefix_text)
				current_prefix_text = is_article_only ? "a" : "Has a"
			var/new_prefix_text = tgui_input_list(user, "Choose the article", "Describe myself", input_list, current_prefix_text)
			if(!new_prefix_text)
				return
			custom_entry.prefix_type = input_list[new_prefix_text]

		if("custom_descriptor_content")
			var/index = text2num(params["index"])
			var/datum/custom_descriptor_entry/custom_entry = custom_descriptors[index]
			var/new_content = tgui_input_text(user, "Describe the feature", "Describe myself", custom_entry.content_text)
			if(!new_content)
				return CHARACTER_ACT_DATA_UPDATE
			new_content = STRIP_HTML_SIMPLE(lowertext(new_content), CUSTOM_DESCRIPTOR_TEXT_LENGTH)
			custom_entry.content_text = new_content
			return CHARACTER_ACT_DATA_UPDATE

		if("print_descriptor_setup")
			// wow this sucks
			var/mob/living/temp = new /mob/living(null)
			temp.pronouns = pronouns
			apply_descriptors(temp)
			var/list/desc_lines = build_cool_description(temp.get_mob_descriptors(FALSE, null), temp)
			QDEL_NULL(temp)
			var/output = ""
			if(!(user.client?.prefs?.full_examine))
				output = "<details><summary>[span_info("Details")]</summary>"
			for(var/line in desc_lines)
				output += span_info(line)
				output += "<br>"
			if(!(user.client?.prefs?.full_examine))
				if(length(desc_lines))
					output += "</details>"
			to_chat(user, output)
			return CHARACTER_ACT_DATA_UPDATE

		if("preview_examine")
			var/datum/examine_panel/preview_examine_panel = new(user)
			preview_examine_panel.pref = src
			preview_examine_panel.holder = user
			preview_examine_panel.viewing = user
			preview_examine_panel.ui_interact(user)
			return CHARACTER_ACT_DATA_UPDATE

		if("save_flavortext")
			var/new_flavortext = params["val"]
			if(new_flavortext == "")
				flavortext = null
				flavortext_cached = null
			else
				flavortext = new_flavortext
				flavortext_cached = parsemarkdown_basic(html_encode(flavortext), hyperlink = TRUE)
			to_chat(user, span_notice("Successfully updated flavortext."))
			log_game("[user] has set their flavortext.")
			return CHARACTER_ACT_DATA_UPDATE

		if("save_ooc_notes")
			var/new_val = params["val"]
			if(new_val == "")
				ooc_notes = null
				ooc_notes_cached = null
			else
				ooc_notes = new_val
				ooc_notes_cached = parsemarkdown_basic(html_encode(ooc_notes), hyperlink = TRUE)
			to_chat(user, span_notice("Successfully updated OOC notes."))
			log_game("[user] has set their OOC notes.")
			return CHARACTER_ACT_DATA_UPDATE

		if("save_nsfwflavortext")
			var/new_val = params["val"]
			if(new_val == "")
				nsfwflavortext = null
				nsfwflavortext_cached = null
			else
				nsfwflavortext = new_val
				nsfwflavortext_cached = parsemarkdown_basic(html_encode(nsfwflavortext), hyperlink = TRUE)
			to_chat(user, span_notice("Successfully updated NSFW flavortext."))
			log_game("[user] has set their NSFW flavortext.")
			return CHARACTER_ACT_DATA_UPDATE

		if("save_erpprefs")
			var/new_val = params["val"]
			if(new_val == "")
				erpprefs = null
				erpprefs_cached = null
			else
				erpprefs = new_val
				erpprefs_cached = parsemarkdown_basic(html_encode(erpprefs), hyperlink = TRUE)
			to_chat(user, span_notice("Successfully updated ERP Preferences."))
			log_game("[user] has set their ERP Preferences.")
			return CHARACTER_ACT_DATA_UPDATE

		if("img_gallery")
			if(img_gallery.len >= 3)
				to_chat(user, "You already have three images in your gallery!")
				return CHARACTER_ACT_DATA_UPDATE

			to_chat(user, span_notice("Please use a relatively SFW image [span_bold("of your character")] to maintain immersion level. Lastly, [span_bold("do not use a real life photo or use any image that is less than serious.")]"))
			to_chat(user, span_notice("If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser."))
			to_chat(user, span_notice("Keep in mind that all three images are displayed next to eachother and justified to fill a horizontal rectangle. As such, vertical images work best."))
			to_chat(user, span_notice("You can only have a maximum of [span_bold("THREE IMAGES")] in your gallery at a time."))

			var/new_galleryimg = tgui_input_text(user, "Input the image link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "Gallery Image",  encode = FALSE)

			if(new_galleryimg == null)
				return CHARACTER_ACT_DATA_UPDATE
			if(new_galleryimg == "")
				new_galleryimg = null
				return CHARACTER_ACT_DATA_UPDATE
			if(!valid_headshot_link(user, new_galleryimg))
				to_chat(user, span_notice("Invalid image link. Make sure it's a direct link from a valid host (gyazo, discord, lensdump, imgbox, catbox)."))
				new_galleryimg = null
				return CHARACTER_ACT_DATA_UPDATE
			img_gallery += new_galleryimg
			to_chat(user, span_notice("Successfully added image to gallery."))
			log_game("[user] has added an image to their gallery: '[new_galleryimg]'.")
			return CHARACTER_ACT_DATA_UPDATE

		if("nsfw_img_gallery")
			if(nsfw_img_gallery.len >= 3)
				to_chat(user, "You already have three images in your NSFW gallery!")
				return CHARACTER_ACT_DATA_UPDATE

			to_chat(user, span_notice("Please use an explicit image [span_bold("of your character")] only when it fits the character and server rules."))
			to_chat(user, span_notice("If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser."))
			to_chat(user, span_notice("Keep in mind that all three images are displayed next to eachother and justified to fill a horizontal rectangle. As such, vertical images work best."))
			to_chat(user, span_notice("You can only have a maximum of [span_bold("THREE IMAGES")] in your NSFW gallery at a time."))

			var/new_galleryimg_nsfw = tgui_input_text(user, "Input the image link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "NSFW Gallery Image",  encode = FALSE)

			if(new_galleryimg_nsfw == null)
				return CHARACTER_ACT_DATA_UPDATE
			if(new_galleryimg_nsfw == "")
				new_galleryimg_nsfw = null
				return CHARACTER_ACT_DATA_UPDATE
			if(!valid_headshot_link(user, new_galleryimg_nsfw))
				to_chat(user, span_notice("Invalid image link. Make sure it's a direct link from a valid host (gyazo, discord, lensdump, imgbox, catbox)."))
				new_galleryimg_nsfw = null
				return CHARACTER_ACT_DATA_UPDATE
			nsfw_img_gallery += new_galleryimg_nsfw
			to_chat(user, span_notice("Successfully added image to NSFW gallery."))
			log_game("[user] has added an image to their NSFW gallery: '[new_galleryimg_nsfw]'.")
			return CHARACTER_ACT_DATA_UPDATE

		if("clear_gallery")
			if(!img_gallery.len)
				to_chat(user, "You don't have any images in your gallery to clear!")
				return CHARACTER_ACT_DATA_UPDATE
			var/dachoice = tgui_alert(user, "Do you really want to clear your image gallery?", "Clear Gallery", list("Yae", "Nae"))
			if(dachoice == "Nae")
				return CHARACTER_ACT_DATA_UPDATE
			img_gallery = list()
			to_chat(user, span_notice("Successfully cleared image gallery."))
			log_game("[user] has cleared their image gallery.")
			return CHARACTER_ACT_DATA_UPDATE

		if("clear_nsfw_gallery")
			if(!nsfw_img_gallery.len)
				to_chat(user, "You don't have any images in your NSFW gallery to clear!")
				return CHARACTER_ACT_DATA_UPDATE
			var/dachoice_nsfw = tgui_alert(user, "Do you really want to clear your NSFW image gallery?", "Clear NSFW Gallery", list("Yae", "Nae"))
			if(dachoice_nsfw == "Nae")
				return CHARACTER_ACT_DATA_UPDATE
			nsfw_img_gallery = list()
			to_chat(user, span_notice("Successfully cleared NSFW image gallery."))
			log_game("[user] has cleared their NSFW image gallery.")
			return CHARACTER_ACT_DATA_UPDATE

		if("rumour")
			to_chat(user, span_notice("Rumours are things others might know, or think they know about you, they don't necessarily have to be precise, or even true. But remember that they can provide a hint to another player on how to interact with, or even think about your character.\n<b>Avoid explicit bodily descriptions, though rumors like \"sleeps around a lot\" are fine.</b>"))
			var/new_rumour = tgui_input_text(user, "Input rumours about your character: (400 Character Limit)", "Rumours", rumour, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(new_rumour == null)
				return CHARACTER_ACT_DATA_UPDATE
			if(new_rumour == "")
				rumour = null
				return CHARACTER_ACT_DATA_UPDATE
			if(length(new_rumour) > 400)
				to_chat(user, span_warning("Rumours cannot exceed 400 characters."))
				return CHARACTER_ACT_DATA_UPDATE
			rumour = new_rumour
			to_chat(user, span_notice("Successfully updated Rumours"))
			log_game("[user] has set their rumour'.")
			return CHARACTER_ACT_DATA_UPDATE

		if("gossip")
			to_chat(user, span_notice("Gossip is rumours spread around, and known only in Noble circles, only other well-born individuals are aware of it. Gossip, similarly to standard rumours does not need to be precise or true, but remember that it can provide hints and avenues for other Nobles to interact with, and judge your Character.\n<b>Avoid explicit bodily descriptions, though rumors like \"sleeps around a lot\" are fine.</b>"))
			var/new_gossip = tgui_input_text(user, "Input noble gossip about your character: (400 Character Limit)", "Noble Gossip", noble_gossip, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(new_gossip == null)
				return CHARACTER_ACT_DATA_UPDATE
			if(new_gossip == "")
				noble_gossip = null
				return CHARACTER_ACT_DATA_UPDATE
			if(length(new_gossip) > 400)
				to_chat(user, span_notice("Noble gossip cannot exceed 400 characters."))
				return CHARACTER_ACT_DATA_UPDATE
			noble_gossip = new_gossip
			to_chat(user, span_notice("Successfully updated Noble Gossip"))
			log_game("[user] has set their noble gossip'.")
			return CHARACTER_ACT_DATA_UPDATE

		if("rumour_preview")
			var/msg = ""
			if(length(rumour))
				var/rumour_display = rumour
				rumour_display = html_encode(rumour_display)
				rumour_display = parsemarkdown_basic(rumour_display, hyperlink = TRUE)
				msg += "<b>You recall what you heard around Town about [real_name]...</b><br>[rumour_display]"
			if(length(noble_gossip))
				if(msg)
					msg += "<br><br>"
				var/gossip_display = noble_gossip
				gossip_display = html_encode(gossip_display)
				gossip_display = parsemarkdown_basic(gossip_display, hyperlink = TRUE)
				msg += "<b>You recall what the other Blue-bloods hushed about [real_name]...</b><br>[gossip_display]"
			if(msg)
				to_chat(user, span_info("[msg]"))
			else
				to_chat(user, span_warning("Your rumors and noble gossip entries are empty."))
			return CHARACTER_ACT_DATA_UPDATE

		if("examine_theme")
			var/list/all_themes = get_tgui_themes()
			var/list/choices = list("None (Use Viewer's)")
			for(var/theme_key in all_themes)
				if(theme_key == "trey_liam")
					continue
				choices += all_themes[theme_key]
			var/current_display = "None (Use Viewer's)"
			if(examine_theme)
				current_display = all_themes[examine_theme] || examine_theme
			var/picked = tgui_input_list(user, "Choose the theme others see on your examine panel:", "Examine Theme", choices, current_display)
			if(!picked)
				return
			if(picked == "None (Use Viewer's)")
				examine_theme = null
			else
				for(var/theme_key in all_themes)
					if(all_themes[theme_key] == picked)
						examine_theme = theme_key
						break
			return CHARACTER_ACT_DATA_UPDATE

		if("ooc_extra")
			to_chat(user, span_notice("Add a link from a suitable host (catbox, etc) to an mp3 to embed in your flavor text."))
			to_chat(user, span_notice("If the song doesn't  play properly, ensure that it's a direct link that opens properly in a browser."))
			to_chat(user, "<font color='#d6d6d6'>Leave blank to clear your current song.</font>")
			to_chat(user, span_danger("Abuse of this will get you banned."))
			var/new_extra_link = tgui_input_text(user, "Input the accessory link (https, hosts: discord, catbox):", "Song URL", ooc_extra, encode = FALSE)
			if(new_extra_link == null)
				return CHARACTER_ACT_DATA_UPDATE
			if(new_extra_link == "")
				new_extra_link = null
				ooc_extra = null
				to_chat(user, span_notice("Successfully deleted OOC Extra."))
				return CHARACTER_ACT_DATA_UPDATE
			var/static/list/valid_extensions = list("mp3")
			if(!valid_headshot_link(user, new_extra_link, FALSE, valid_extensions))
				new_extra_link = null
				return CHARACTER_ACT_DATA_UPDATE

			var/list/value_split = splittext(new_extra_link, ".")

			// extension will always be the last entry
			var/extension = value_split[length(value_split)]
			if((extension in valid_extensions))
				ooc_extra = new_extra_link
				to_chat(user, span_notice("Successfully updated Song URL."))
				log_game("[user] has set their Song URL to '[ooc_extra]'.")
			return CHARACTER_ACT_DATA_UPDATE

		if("change_artist")
			var/new_artist = tgui_input_text(user, "Input your song's artist:", "Song Artist", song_artist,  encode = FALSE)
			if(new_artist == null)
				return CHARACTER_ACT_DATA_UPDATE
			if(new_artist == "")
				return CHARACTER_ACT_DATA_UPDATE
			song_artist = new_artist
			to_chat(user, span_notice("Successfully updated song artist."))
			log_game("[user] has set their song artist.")
			return CHARACTER_ACT_DATA_UPDATE

		if("change_title")
			var/new_title = tgui_input_text(user, "Input your song's title:", "Song title", song_title,  encode = FALSE)
			if(new_title == null)
				return CHARACTER_ACT_DATA_UPDATE
			if(new_title == "")
				return CHARACTER_ACT_DATA_UPDATE
			song_title = new_title
			to_chat(user, span_notice("Successfully updated song title."))
			log_game("[user] has set their song title.")
			return CHARACTER_ACT_DATA_UPDATE
