/datum/preferences/proc/ui_data_character_sheet_character_select(mob/user)
	var/list/data = list()

	// clever way to reduce data: only send the character slots if they wanna see it
	if(LAZYACCESS(tgui_shared_states, "character_select"))
		var/list/all_slots = list()
		if(path)
			var/savefile/S = new /savefile(path)
			if(S)
				for(var/i in 1 to max_save_slots)
					var/name
					var/suffix
					var/species_name
					S.cd = "/character[i]"
					S["real_name"] >> name
					S["topjob"] >> suffix
					S["species"] >> species_name
					UNTYPED_LIST_ADD(all_slots, list(
						"index" = i,
						"real_name" = name,
						"topjob" = suffix,
						"species" = species_name,
					))

		data["slots"] = all_slots
	else
		data["slots"] = null

	data["favorited_slots"] = favorited_slots

	return data