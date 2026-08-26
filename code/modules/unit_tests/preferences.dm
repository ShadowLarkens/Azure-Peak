// Tests for the new datumized preference system.

// All concrete preference datums should have unique keys.
/datum/unit_test/preference_datums_unique/Run()
	// This is basically rebuilding GLOB.preference_entries_by_key but with override detection
	var/list/datum/preference/preference_entries_by_key = list()

	// GLOB.preference_entries is already a list of valid_subtypesof
	for(var/path in GLOB.preference_entries)
		var/datum/preference/P = GLOB.preference_entries[path]
		if(P.savefile_key in preference_entries_by_key)
			var/datum/preference/existing = preference_entries_by_key[P.savefile_key]
			TEST_FAIL("Savefile key conflict: '[P.savefile_key]' is used by '[path]' and '[existing.type]'.")
		preference_entries_by_key[P.savefile_key] = P

// All concrete preference datums should return the same value for deserialize(deserialize(V)) and deserialize(V)
/datum/unit_test/preference_datums_deserialization_correct/Run()
	for(var/path in GLOB.preference_entries)
		var/datum/preference/P = GLOB.preference_entries[path]
		var/default_value = P.create_default_value()
		TEST_CHECK_EQUAL(\
			json_encode(P.deserialize(default_value)),\
			json_encode(P.deserialize(P.deserialize(default_value))),\
			"[path] did not deserialize their own valid deserialized value.")

		var/list/invalid_values = P.create_invalid_values()
		for(var/value in invalid_values)
			TEST_CHECK(!P.is_valid(value), "[path]/create_invalid_value returned '[value]' and it passes is_valid.")

			TEST_CHECK_EQUAL(\
				json_encode(P.deserialize(value)),\
				json_encode(P.deserialize(P.deserialize(value))),\
				"[path] did not deserialize their own invalid deserialized value.")
