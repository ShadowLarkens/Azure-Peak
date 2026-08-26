/datum/preference_storage_adapter

/datum/preference_storage_adapter/Destroy(force, ...)
	// Flush whatever we need to when we're destroyed
	flush()
	. = ..()

// Primitives to implement
/// Reads a specific key from storage.
/// Returns the according value or null.
/datum/preference_storage_adapter/proc/read_by_key(key)
	CRASH("`read_by_key` was not implemented on [type]!")

/// Reads a specific key from storage with optional slot_idx.
/// Returns the according value or null.
/datum/preference_storage_adapter/proc/read(key, slot_idx)
	CRASH("`read` was not implemented on [type]!")

/// Writes a given key and serialized value to storage.
/// Returns TRUE if write succeeded, FALSE otherwise.
/datum/preference_storage_adapter/proc/write_kv(key, serialized_value)
	CRASH("`write_kv` was not implemented on [type]!")

/// Writes a value to storage, with optional slot_idx
/datum/preference_storage_adapter/proc/write(key, serialized_value, slot_idx)
	CRASH("`write` was not implemented on [type]!")

/// Deletes a key
/datum/preference_storage_adapter/proc/delete_key(key)
	CRASH("`delete_key` was not implemented on [type]!")

/// Deletes a key, with optional slot_idx
/datum/preference_storage_adapter/proc/delete(key, slot_idx)
	CRASH("`delete` was not implemented on [type]!")

/datum/preference_storage_adapter/proc/delete_all(slot_idx)
	CRASH("`delete_all` was not implemented on [type]!")

/// Flush current changes to storage (optional; BYOND savefiles don't need to do this)
/// Mostly used for any future SQL or permanent JSON files
/datum/preference_storage_adapter/proc/flush()
	return

/// Optional: Create a backup file.
/// Returns backup file name.
/datum/preference_storage_adapter/proc/create_backup()
	return

// Helpers
/// Writes all key/value pairs in `data` to storage. Must be preserialized.
/datum/preference_storage_adapter/proc/write_all(list/serialized_data, slot_idx)
	var/failed = FALSE

	for(var/savefile_key in serialized_data)
		var/serialized_value = serialized_data[savefile_key]
		if(!write(savefile_key, serialized_value, slot_idx))
			failed = TRUE

	flush()
	return failed



// BYOND Savefile
/datum/preference_storage_adapter/byond_savefile
	/// The actual savefile we're operating with
	var/savefile/open_save
	/// The directory to create backups in.
	var/savefile_directory

/datum/preference_storage_adapter/byond_savefile/New(savefile/S, savefile_directory)
	. = ..()
	open_save = S
	src.savefile_directory = savefile_directory

/datum/preference_storage_adapter/byond_savefile/Destroy(force)
	. = ..()
	open_save = null

/datum/preference_storage_adapter/byond_savefile/create_backup()
	if(savefile_directory)
		var/filename = "backup_[rustg_unix_timestamp()].sav"
		fcopy(open_save, "[savefile_directory]/[filename]")
		return filename

// Read
/datum/preference_storage_adapter/byond_savefile/read_by_key(key)
	// to_chat(world, "savefile adapter read_by_key([key]) and cd [open_save.cd]")
	open_save[key] >> .

/datum/preference_storage_adapter/byond_savefile/read(key, slot_idx)
	if(!isnull(slot_idx))
		open_save.cd = "/character[slot_idx]"
	else
		open_save.cd = "/"

	return read_by_key(key)

// Write
/datum/preference_storage_adapter/byond_savefile/write_kv(key, serialized_value)
	// to_chat(world, "savefile adapter write_kv([key], [serialized_value]) and cd [open_save.cd]")
	open_save[key] << serialized_value
	return TRUE

/datum/preference_storage_adapter/byond_savefile/write(key, serialized_value, slot_idx)
	if(!isnull(slot_idx))
		open_save.cd = "/character[slot_idx]"
	else
		open_save.cd = "/"

	return write_kv(key, serialized_value)

// Delete
/datum/preference_storage_adapter/byond_savefile/delete_key(key)
	open_save.dir.Remove(key)
	return TRUE

/datum/preference_storage_adapter/byond_savefile/delete(key, slot_idx)
	if(!isnull(slot_idx))
		open_save.cd = "/character[slot_idx]"
	else
		open_save.cd = "/"

	return delete_key(key)

/datum/preference_storage_adapter/byond_savefile/delete_all(slot_idx)
	if(!isnull(slot_idx))
		open_save.cd = "/character[slot_idx]"
	else
		open_save.cd = "/"

	// This will clear the current directory completely
	open_save.dir.Cut()
	return TRUE

// Anything that can be turned into a BYOND assoc list can be represented here in-memory
// flush_cb will be called with json_encode'd text
/datum/preference_storage_adapter/generic_json
	/// Used for a BYOND-like stateful API, we store character prefs by setting a prefix
	var/prefix
	/// Internal representation
	var/list/internal_list
	/// Callback for flushing to the underlying storage
	var/datum/callback/flush_cb

/datum/preference_storage_adapter/generic_json/New(list/internal_list, datum/callback/flush_cb)
	. = ..()
	src.internal_list = internal_list
	src.flush_cb = flush_cb

/datum/preference_storage_adapter/generic_json/Destroy(force, ...)
	. = ..()
	internal_list = null
	flush_cb = null

// Read
/datum/preference_storage_adapter/generic_json/read_by_key(key)
	return internal_list["[prefix || ""][key]"]

/datum/preference_storage_adapter/generic_json/read(key, slot_idx)
	if(!isnull(slot_idx))
		prefix = "character[slot_idx]/"
	else
		prefix = ""

	return read_by_key(key)

// Write
/datum/preference_storage_adapter/generic_json/write_kv(key, serialized_value)
	internal_list["[prefix || ""][key]"] = serialized_value
	return TRUE

/datum/preference_storage_adapter/generic_json/write(key, serialized_value, slot_idx)
	if(!isnull(slot_idx))
		prefix = "character[slot_idx]/"
	else
		prefix = ""

	return write_kv(key, serialized_value)

// Delete
/datum/preference_storage_adapter/generic_json/delete_key(key)
	internal_list -= "[prefix || ""][key]"
	return TRUE

/datum/preference_storage_adapter/generic_json/delete(key, slot_idx)
	if(!isnull(slot_idx))
		prefix = "character[slot_idx]/"
	else
		prefix = ""

	return delete_key(key)

/datum/preference_storage_adapter/generic_json/delete_all(slot_idx)
	if(!isnull(slot_idx))
		prefix = "character[slot_idx]/"
	else
		prefix = ""

	if(!prefix)
		internal_list = list()
	else
		internal_list -= prefix
	return TRUE

// Flush
/datum/preference_storage_adapter/generic_json/proc/get_json()
	// TODO: remove pretty print flag
	return json_encode(internal_list, JSON_PRETTY_PRINT)

/datum/preference_storage_adapter/generic_json/flush()
	return flush_cb?.InvokeAsync(get_json())
