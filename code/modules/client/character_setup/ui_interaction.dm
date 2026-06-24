/datum/preferences
	// 0 = character settings, 1 = game preferences
	var/current_tab = 0

/datum/preferences/proc/ShowChoicesTgui(mob/user, tabchoice)
	if(!user || !user.client)
		return

	if(tabchoice == 4)
		current_tab = 0
	else if(tabchoice)
		current_tab = tabchoice

	ui_interact(user)

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		character_preview_view = create_character_preview_view(user)
		ui = new(user, src, "CharacterSetup", "Preferences")
		// Note: Because of this, ui_static_data is basically useless,
		// everything should just go in the non-autoupdating ui_data
		ui.set_autoupdate(FALSE)
		ui.open()
		character_preview_view.display_to(user, ui.window)

/datum/preferences/ui_state(mob/user)
	return GLOB.tgui_always_state

// This makes sure that no one but our owner can interact or see us
/datum/preferences/ui_status(mob/user, datum/ui_state/state)
	return user.client == parent ? UI_INTERACTIVE : UI_CLOSE

/datum/preferences/ui_close(mob/user)
	. = ..()
	user << browse(null, "window=preferences") // TODO: merk
	close_subwindows(user)
	QDEL_NULL(character_preview_view)