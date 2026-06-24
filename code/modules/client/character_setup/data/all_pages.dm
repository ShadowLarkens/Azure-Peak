/datum/preferences/proc/ui_data_all_pages(mob/user)
	var/list/data = list()

	data["current_tab"] = current_tab

	return data
