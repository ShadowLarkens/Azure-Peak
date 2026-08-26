/// Migration from v36 to v37
/// For JSON compatibility, there can be no datums written directly to the file
/datum/preferences/proc/migration_v37_embedded_datums(datum/preference_storage_adapter/psa, slot_idx)
	migration_v37_embedded_datums_custom_descriptors(psa, slot_idx)
	migration_v37_embedded_datums_customizer_entries(psa, slot_idx)
	migration_v37_embedded_datums_descriptor_entries(psa, slot_idx)

/// Rewrite custom_descriptors
/datum/preferences/proc/migration_v37_embedded_datums_custom_descriptors(datum/preference_storage_adapter/psa, slot_idx)
	var/list/old = psa.read("custom_descriptors", slot_idx)

	var/list/new_list = list()
	for(var/datum/custom_descriptor_entry/DE as anything in old)
		UNTYPED_LIST_ADD(new_list, DE.serialize())

	psa.write("custom_descriptors", new_list, slot_idx)

/// Rewrite customizer_entries
/datum/preferences/proc/migration_v37_embedded_datums_customizer_entries(datum/preference_storage_adapter/psa, slot_idx)
	var/list/old = psa.read("customizer_entries", slot_idx)

	var/list/new_list = list()
	for(var/datum/customizer_entry/CE as anything in old)
		UNTYPED_LIST_ADD(new_list, CE.serialize())

	psa.write("customizer_entries", new_list, slot_idx)

/// Rewrite descriptor_entries
/datum/preferences/proc/migration_v37_embedded_datums_descriptor_entries(datum/preference_storage_adapter/psa, slot_idx)
	var/list/old = psa.read("descriptor_entries", slot_idx)

	var/list/new_list = list()
	for(var/datum/descriptor_entry/DE as anything in old)
		UNTYPED_LIST_ADD(new_list, DE.serialize())

	psa.write("descriptor_entries", new_list, slot_idx)
