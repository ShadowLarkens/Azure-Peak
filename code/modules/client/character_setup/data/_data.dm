// Note: Because of set_autoupdate(FALSE), ui_static_data is basically useless,
// everything should just go in the non-autoupdating ui_data.

/datum/preferences/ui_data(mob/user)
	var/list/data = ui_data_all_pages(user)

	data += ui_data_for_tab(user)

	return data

/datum/preferences/proc/ui_data_for_tab(mob/user)
	switch(current_tab)
		if(0)
			. = ui_data_character_sheet(user)
		if(1)
			. = ui_data_game_settings(user)
		if(2)
			. = ui_data_ooc_prefs(user)
		if(3)
			. = ui_data_keybinds(user)
