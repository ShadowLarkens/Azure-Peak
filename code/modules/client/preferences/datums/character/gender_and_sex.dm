// Model to use, masc or fem, uses BYOND gender value for legacy reasons
/datum/preference/choiced/body_type
	// Named this way for historical reasons
	savefile_key = "gender"
	savefile_identifier = PREFERENCE_CHARACTER

// Default will be random as desired
/datum/preference/choiced/body_type/init_possible_values()
	return list(MALE, FEMALE)


// Pronouns to use
/datum/preference/choiced/pronouns
	savefile_key = "pronouns"
	savefile_identifier = PREFERENCE_CHARACTER

	dependencies = list(
		// So we can make them
		// Cis By Default™
		/datum/preference/choiced/body_type
	)

/datum/preference/choiced/pronouns/init_possible_values()
	return GLOB.pronouns_list

/datum/preference/choiced/pronouns/create_informed_default_value(datum/preferences/preferences)
	// Cis By Default™
	switch(preferences.read_preference(/datum/preference/choiced/body_type))
		if(MALE)
			return HE_HIM
		else
			return SHE_HER
