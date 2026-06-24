// In this folder, all of our different pages are split up into separate sub-procs

/datum/preferences/proc/ui_data_character_sheet(mob/user)
	var/list/data = list()

	data += ui_data_character_sheet_character_select(user)
	data += ui_data_character_sheet_main(user)
	data += ui_data_character_sheet_body(user)
	data += ui_data_character_sheet_customizers(user)
	data += ui_data_character_sheet_markings(user)
	data += ui_data_character_sheet_descriptors(user)
	data += ui_data_character_sheet_classes(user)
	data += ui_data_character_sheet_villain(user)

	return data

/* INSTRUCTIONS FOR DOWNSTREAM:
Add a new override in your modular folder that looks like this:
/datum/preferences/ui_data_character_sheet(mob/user)
	var/list/data = ..()
	data += ui_data_downstream(user)
	return data
*/