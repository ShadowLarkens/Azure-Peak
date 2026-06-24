/datum/preferences/proc/ui_data_character_sheet_body(mob/user)
	// Data that doesn't require any conditionals goes inline here!
	var/list/data = list(
		"body_type" = ui_data_bodytype(),
		"species_base_name" = pref_species.base_name,
		"species_sub_name" = pref_species.sub_name,
		"species_check" = spec_check(user),
		// Appearance Data
		"use_skintones" = pref_species.use_skintones,
		"skin_tone_wording" = pref_species.skin_tone_wording,
		"use_mutcolor" = (MUTCOLORS in pref_species.species_traits) || (MUTCOLORS_PARTSONLY in pref_species.species_traits),
		"mcolor" = features["mcolor"],
		"mcolor2" = features["mcolor2"],
		"mcolor3" = features["mcolor3"],
		"body_size" = (features["body_size"] * 100),
		// Taur stuff
		"taur_type" = taur_type,
		"taur_color" = taur_color,
		"allowed_taur_types" = pref_species.allowed_taur_types,
	)

	if(LAZYLEN(pref_species.custom_selection))
		var/race_bonus_display
		if(race_bonus)
			for(var/bonus in pref_species.custom_selection)
				if(bonus == race_bonus)
					race_bonus_display = bonus
					break
		data["race_bonus"] = "[race_bonus_display]"
	else
		data["race_bonus"] = null

	var/obj/item/bodypart/taur/T = taur_type
	var/taur_name = ispath(T) ? T::name : "None"
	data["taur_name"] = taur_name

	return data

/// Gets the body type as a user friendly string
/datum/preferences/proc/ui_data_bodytype()
	var/bodytype = null
	if(!(AGENDER in pref_species.species_traits))
		if(gender == MALE)
			bodytype = "Masculine"
		else if(gender == FEMALE)
			bodytype = "Feminine"
		else
			bodytype = "Other"
	return bodytype