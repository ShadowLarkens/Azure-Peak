/datum/preferences/proc/ui_data_popup_taur_type(mob/user)
	var/datum/species/pref_species = read_preference(/datum/preference/species)
	var/list/data = list(
		"available" = pref_species.get_taur_list(),
		"taur_type" = taur_type,
	)

	return data
