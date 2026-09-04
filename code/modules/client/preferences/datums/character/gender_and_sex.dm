// Model to use, masc or fem, uses BYOND gender value for legacy reasons
/datum/preference/choiced/body_type
	// Named this way for historical reasons
	savefile_key = "gender"
	savefile_identifier = PREFERENCE_CHARACTER

// Default will be random as desired
/datum/preference/choiced/body_type/init_possible_values()
	return list(MALE, FEMALE)
