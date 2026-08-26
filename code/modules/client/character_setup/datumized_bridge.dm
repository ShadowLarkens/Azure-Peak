/datum/preferences
	var/list/requested_prefs = list()

	// Used so that out of order updates get rejected
	// Honestly not sure if this is possible?? theoretically TCP is in-order, but in practice BYOND fucks up a lot
	var/req_client_revisions_by_session = list()

/datum/preferences/proc/ui_act_datum_prefs(action, list/params, datum/tgui/ui, datum/ui_state/state)
	switch(action)
		if("update_requested_prefs")
			// This basically just lets us know if the client's global state got reset by ctrl-r or whatever
			var/session_id = sanitize_text(params["session_id"], "unknown")
			var/latest_client_revision = req_client_revisions_by_session[session_id] || 0

			// Reject out-of-order update requests
			var/client_revision = text2num(params["client_revision"])
			if(client_revision < latest_client_revision)
				return

			// Merk old sessions (hilariously not multiuser safe)
			// This is fine because we only really care about the latest session
			req_client_revisions_by_session = list()
			req_client_revisions_by_session[session_id] = client_revision

			// Update our requested_prefs list
			var/list/new_requested_prefs = SANITIZE_LIST(params["requested_prefs"])
			for(var/i in 1 to length(new_requested_prefs))
				new_requested_prefs[i] = sanitize_path(new_requested_prefs[i], /datum/preference, null)
			removeNullsFromList(new_requested_prefs)
			requested_prefs = new_requested_prefs

			// And trigger a data update
			return CHARACTER_ACT_DATA_UPDATE

/datum/preferences/proc/ui_data_datum_prefs(mob/user)
	var/list/data = list(
		"datumized" = null,
	)

	var/list/datumized_data = list()
	for(var/pref_path in requested_prefs)
		var/datum/preference/P = GLOB.preference_entries[pref_path]
		if(!P)
			continue

		var/deserialized_value = read_preference(pref_path)
		datumized_data[P.savefile_key] = P.get_ui_data(deserialized_value)
	data["datumized"] = datumized_data

	return data
