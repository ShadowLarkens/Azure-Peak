// In this folder, all of our different pages are split up into separate sub-procs

/datum/preferences
	COOLDOWN_DECLARE(ui_refresh_cooldown)

/datum/preferences/proc/ui_act_character_sheet(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ui_act_character_sheet_all_pages(action, params, ui, state)
	if(.)
		return

	. = ui_act_character_sheet_main(action, params, ui, state)
	if(.)
		return

	. = ui_act_character_sheet_body(action, params, ui, state)
	if(.)
		return

	. = ui_act_character_sheet_customizers(action, params, ui, state)
	if(.)
		return

	. = ui_act_character_sheet_markings(action, params, ui, state)
	if(.)
		return

	. = ui_act_character_sheet_descriptors(action, params, ui, state)
	if(.)
		return

	. = ui_act_character_sheet_classes(action, params, ui, state)
	if(.)
		return

	. = ui_act_character_sheet_villain(action, params, ui, state)
	if(.)
		return

/* INSTRUCTIONS FOR DOWNSTREAM:
Add a new override in your modular folder that looks like this:
/datum/preferences/ui_act_character_sheet(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	// helpers/switch(action) as needed
*/

/datum/preferences/proc/ui_act_character_sheet_all_pages(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui.user

	switch(action)
		if("favorite_slot")
			var/index = sanitize_integer(text2num(params["index"]), 0, max_save_slots, -1)
			if(index == -1)
				return CHARACTER_ACT_DATA_UPDATE

			favorited_slots += index
			save_preferences()
			return CHARACTER_ACT_DATA_UPDATE
		if("unfavorite_slot")
			var/index = sanitize_integer(text2num(params["index"]), 0, max_save_slots, -1)
			if(index == -1)
				return CHARACTER_ACT_DATA_UPDATE

			favorited_slots -= index
			save_preferences()
			return CHARACTER_ACT_DATA_UPDATE
		if("reorder_favorited_slots")
			var/list/new_list = params["slots"]
			if(!islist(new_list) || length(new_list) > max_save_slots)
				return CHARACTER_ACT_DATA_UPDATE
			// try to filter out href exploits
			if(length(new_list))
				if(!isnum(new_list[1]))
					return CHARACTER_ACT_DATA_UPDATE
			favorited_slots = new_list
			return CHARACTER_ACT_DATA_UPDATE
		if("changeslot_index")
			var/index = sanitize_integer(text2num(params["index"]), 0, max_save_slots, -1)
			if(index == -1)
				return CHARACTER_ACT_DATA_UPDATE

			close_subwindows(user)

			if(!load_character(index))
				random_character(null, FALSE, FALSE)
				save_character()
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("playerquality")
			check_pq_menu(user.ckey)
			return CHARACTER_ACT_DATA_UPDATE
		if("triumphs")
			user.show_triumphs_list()
			return CHARACTER_ACT_DATA_UPDATE
		if("agevet")
			if(!user.check_agevet())
				to_chat(user, span_info("- You are a whitelisted player with full access to the server's features. If you'd also like to show others that you've been <b>AGE-VERIFIED</b> with a censored ID, you can open a ticket in Azure Peak's <b>#vet-here</b> channel. If you are already verified on Discord, but not in-game, ahelp. Note that this is a purely optional process, and - besides awarding a special header for your flavortext - doesn't affect you in any other way."))
			else
				to_chat(user, span_love("- You have been successfully <b>AGE-VERIFIED!</b>"))
			return CHARACTER_ACT_DATA_UPDATE
		if("lore_primer")
			LorePopup(user)
			return CHARACTER_ACT_DATA_UPDATE
		if("changelog")
			user.client.changelog()
			return CHARACTER_ACT_DATA_UPDATE
		if("save")
			save_preferences()
			save_character()
			to_chat(user, span_notice("CHARACTER SAVED."))
			return CHARACTER_ACT_DATA_UPDATE
		if("load")
			load_preferences()
			load_character()
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("refresh_character_preview")
			if(!COOLDOWN_FINISHED(src, ui_refresh_cooldown))
				return
			COOLDOWN_START(src, ui_refresh_cooldown, 5 SECONDS)
			// outer ui_act handles this for us~!
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("rotate_character_preview")
			character_preview_view?.setDir(turn(character_preview_view.dir, -90))
			// TODO: test if this works
			return CHARACTER_ACT_DATA_UPDATE
		if("headshot")
			to_chat(user, span_notice("Please use a relatively SFW image of the head and shoulder area to maintain immersion level. Lastly, [span_bold("do not use a real life photo or use any image that is less than serious.")]"))
			to_chat(user, span_notice("If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser."))
			to_chat(user, span_notice("Keep in mind that the photo will be downsized to 325x325 pixels, so the more square the photo, the better it will look."))
			var/new_headshot_link = tgui_input_text(user, "Input the headshot link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "Headshot", headshot_link,  encode = FALSE)
			if(new_headshot_link == null)
				return
			if(new_headshot_link == "")
				headshot_link = null
				return
			if(!valid_headshot_link(user, new_headshot_link))
				headshot_link = null
				return
			headshot_link = new_headshot_link
			to_chat(user, span_notice("Successfully updated headshot picture"))
			log_game("[user] has set their Headshot image to '[headshot_link]'.")
			return CHARACTER_ACT_DATA_UPDATE
