/// Checks the "version" field against minimum and maximum supported versions, possibly in a specific slot.
/// Return values:
///		-3 if savefile_version == null
///		-2 if savefile_version < SAVEFILE_VERSION_MIN
///		-1 if savefile_version == SAVEFILE_VERSION_MAX
///		else, savefile_version, to pass to migrations.
/datum/preferences/proc/save_needs_update(datum/preference_storage_adapter/psa, slot_idx)
	var/savefile_version = psa.read("version", slot_idx)

	if(savefile_version == null)
		// This is important because BYOND savefiles will create keys when read
		// and also we wanna get rid of outdated data
		psa.delete_all(slot_idx)
		return -3
	if(savefile_version < SAVEFILE_VERSION_MIN)
		// This is important because BYOND savefiles will create keys when read
		// and also we wanna get rid of outdated data
		psa.delete_all(slot_idx)
		return -2
	if(savefile_version < SAVEFILE_VERSION_MAX)
		return savefile_version
	return -1

/// Called whenever a savefile is loaded, attempts to run migrations.
/// If this returns FALSE, the savefile cannot be loaded and defaults should be run.
/// This will read AND write to the savefile!
/datum/preferences/proc/try_migrate_savefile(datum/preference_storage_adapter/psa, slot_idx, backup = TRUE)
	var/needs_update = save_needs_update(psa, slot_idx)

	switch(needs_update)
		if(-3)
			// Normal path, indicates savefile had no version and is therefore empty.
			return FALSE
		if(-2)
			// Unhappy path, indicates savefile had a version we do not support migrations from.
			to_chat(parent,
				span_userdanger("CRITICAL ERROR: Unable to load or migrate [slot_idx != null ? "character slot '[slot_idx]'" : "preferences file"]. \
								Please contact an administrator to see if there is any path to data recovery."))
			return FALSE
		if(-1)
			// Happy path, version is what we expect it to be.
			return TRUE

	// Normal path, indicates savefile should be migrated.

	// Back that shit up in case something goes wrong
	var/backup_name = backup ? psa.create_backup() : null

	// Character is out of date.
	if(slot_idx != null)
		. = do_character_migrations(psa, needs_update, slot_idx)
		if(!.)
			to_chat(parent,
				span_userdanger("CRITICAL ERROR: Unable to load or migrate character slot '[slot_idx]' \
								from v[needs_update] to v[SAVEFILE_VERSION_MAX]. \
								Please contact an administrator to see if there is any path to data recovery. \
								[backup_name ? "A backup has been created at [backup_name]." : ""]"))
		return

	// Global file is out of date.
	. = do_pref_migrations(psa, needs_update)
	if(!.)
		to_chat(parent,
			span_userdanger("CRITICAL ERROR: Unable to load or migrate preferences file from v[needs_update] to v[SAVEFILE_VERSION_MAX]. \
							Please contact an administrator to see if there is any path to data recovery. \
							[backup_name ? "A backup has been created at [backup_name]." : ""]"))
	return

/// Called when we have an out of date savefile to migrate from current_version -> SAVEFILE_VERSION_MAX.
/// Remember that this is run before anything has been loaded.
/// Returns TRUE if migrations succeeded, FALSE otherwise.
/datum/preferences/proc/do_pref_migrations(datum/preference_storage_adapter/psa, current_version)
	to_chat(parent, span_warning("Attempting to migrate preferences from v[current_version] to v[SAVEFILE_VERSION_MAX]..."))

	// Actual migration code

	// vSAVEFILE_VERSION_RESET_KEYBINDS: Whenever keybindings are fucked with massively, they need to be reset.
	// Note: <v29 does not have key_bindings.
	// TODO: /datum/preference/key_bindings will automatically fall back when loading invalid keys.
	if(current_version < SAVEFILE_VERSION_RESET_KEYBINDS)
		psa.delete("key_bindings", null)

	// Actual migration code end
	psa.write("version", SAVEFILE_VERSION_MAX, null)

	// Greedily update all character slots at the same time.
	for(var/slot_idx in 0 to MAX_SAVE_SLOTS_POSSIBLE)
		try_migrate_savefile(psa, slot_idx, backup = FALSE)

	to_chat(parent, span_notice("Successfully migrated preferences from v[current_version] to v[SAVEFILE_VERSION_MAX]."))
	return TRUE

/// Called when we have an out of date savefile to migrate from current_version -> SAVEFILE_VERSION_MAX.
/// Returns TRUE if migrations succeeded, FALSE otherwise.
/datum/preferences/proc/do_character_migrations(datum/preference_storage_adapter/psa, current_version, slot_idx)
	to_chat(parent, span_warning("Attempting to migrate character slot '[slot_idx]' from v[current_version] to v[SAVEFILE_VERSION_MAX]..."))

	// Actual migration code

	// v34: Species names changed
	if(current_version < 34)
		var/old_name = psa.read("species", slot_idx)
		var/new_name = null

		switch(old_name)
			if("Sissean")
				new_name = "Zardman"
			if("Vulpkian")
				new_name = "Venardine"

		if(new_name)
			psa.write("species", new_name, slot_idx)

	// v35: 3-slot loadout becomes gear_list
	if(current_version < 35)
		var/alist/old_keys = alist(
			"loadout" = "loadout_1_hex",
			"loadout2" = "loadout_2_hex",
			"loadout3" = "loadout_3_hex",
		)

		var/list/gear_list = list()
		for(var/k,v in old_keys)
			var/loadout_type = psa.read(k, slot_idx)
			if(!loadout_type || !ispath(loadout_type))
				continue

			var/datum/loadout_item/LI = GLOB.loadout_items[loadout_type]
			if(!LI || LI.name == "Parent loadout datum")
				continue

			var/list/meta = list()
			var/old_hex = psa.read(v, slot_idx)
			if(old_hex)
				if(old_hex[1] != "#")
					old_hex = "#[old_hex]"
				meta["color"] = old_hex
			gear_list[LI.name] = meta

			psa.delete(k, slot_idx)
			psa.delete(v, slot_idx)

		psa.write("gear_list", gear_list, slot_idx)

	// v36: Strip the old per-item favorite/hated food & drink data now that preferences are category flags
	if(current_version < 36)
		psa.delete("culinary_preferences", slot_idx)

	// v37: No more embedded datums
	if(current_version < 37)
		migration_v37_embedded_datums(psa, slot_idx)

	// Actual migration code end
	psa.write("version", SAVEFILE_VERSION_MAX, slot_idx)
	to_chat(parent, span_notice("Successfully migrated character slot '[slot_idx]' from v[current_version] to v[SAVEFILE_VERSION_MAX]."))

	return TRUE
