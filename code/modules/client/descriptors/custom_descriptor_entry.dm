/datum/custom_descriptor_entry
	var/prefix_type = CUSTOM_PREFIX_HAS_A
	var/content_text = "feature"

/datum/custom_descriptor_entry/proc/deserialize(list/data, datum/preferences/prefs)
	if(!islist(data))
		return FALSE

	prefix_type = sanitize_integer(data["prefix_type"], 1, CUSTOM_PREFIX_AMOUNT, initial(prefix_type))
	content_text = STRIP_HTML_SIMPLE(LOWER_TEXT(sanitize_text(data["content_text"], initial(content_text))), CUSTOM_DESCRIPTOR_TEXT_LENGTH)

	return TRUE

/datum/custom_descriptor_entry/proc/serialize()
	. = list()

	.["prefix_type"] = prefix_type
	.["content_text"] = content_text
