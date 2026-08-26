/// All names have similar rules for deserializing (reject_bad_name)
/datum/preference/name
	abstract_type = /datum/preference/name
	savefile_identifier = PREFERENCE_CHARACTER
	zod_schema = "z.string()"
	zod_schema_constant = "z.object({ '%SAVEFILE_KEY%_max_len': z.number() })"

	// Name specific options
	var/allow_numbers = FALSE
	var/maximum_value_length = MAX_NAME_LEN

/datum/preference/name/is_valid(value)
	return istext(value) && !isnull(reject_bad_name(value, allow_numbers, maximum_value_length))

/datum/preference/name/deserialize(input, datum/preferences/preferences)
	// This is like this instead of coercing everything to text to follow the double-deserialize rule.
	return istext(input) ? reject_bad_name(input, allow_numbers, maximum_value_length) : null

// Only used for unit tests
/datum/preference/name/create_invalid_values()
	// Same as /datum/preference/text/create_invalid_values()
	// Plus numbers if those aren't allowed
	return list(/datum/preference/name, "", repeat_string(maximum_value_length + 1, "A")) \
		+ allow_numbers ? list() : "a1234"

/datum/preference/name/get_ui_data(deserialized_value)
	return deserialized_value

/datum/preference/name/get_constant_ui_data()
	return list("[savefile_key]_max_len" = maximum_value_length)

// Concrete subtypes
/datum/preference/name/real_name
	savefile_key = "real_name"
	// We need to know body_type for random_unique_name to produce cisgender results
	dependencies = list(
		/datum/preference/choiced/body_type
	)

// Only used for unit tests
/datum/preference/name/real_name/create_default_value()
	return "Real Name"

/datum/preference/name/real_name/create_informed_default_value(datum/preferences/preferences)
	return random_unique_name(preferences.read_preference(/datum/preference/choiced/body_type))

/datum/preference/name/nickname
	savefile_key = "nickname"
	// We default to matching the real_name
	dependencies = list(
		/datum/preference/name/real_name
	)

// Only used for unit tests
/datum/preference/name/nickname/create_default_value()
	return "Real Name"

/datum/preference/name/nickname/create_informed_default_value(datum/preferences/preferences)
	var/value = preferences.read_preference(/datum/preference/name/real_name)
	// to_chat(world, "nickname read value: [value]")
	return value
