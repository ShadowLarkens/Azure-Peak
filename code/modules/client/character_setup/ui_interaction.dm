/datum/preferences
	var/current_tab = PREFERENCE_TAB_CHARACTER_SHEET

// kept for legacy reasons
/datum/preferences/proc/ShowChoices(mob/user, tabchoice = null)
	if(!user || !user.client)
		return

	if(tabchoice != null)
		current_tab = tabchoice

	ui_interact(user)

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		character_preview_view = create_character_preview_view(user)
		ui = new(user, src, "PreferencesMenu", "Preferences")
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
	close_subwindows(user)
