/client/verb/export_savefile()
	set name = "Export Preferences"
	set desc = "Export your preferences to a file."
	set category = "OOC"
	if(!prefs.path)
		return

	if(alert(src, "Are you sure you want to export your preferences? This will create a file on your computer that contains your preferences.", "Export Preferences", "Yes", "No") == "No")
		return

	if(!fexists(prefs.path))
		to_chat(src, span_warning("No savefile, what?!"))
		return

	var/file_name = "[ckey].sav"
	var/exportable_file = file(prefs.path)

	DIRECT_OUTPUT(src, ftp(exportable_file, file_name))

/client/verb/export_savefile_txt()
	set name = "Export Preferences as text"
	set desc = "Export your preferences to a file."
	set category = "OOC"

	if(!fexists(prefs.path))
		to_chat(src, span_warning("No savefile, what?!"))
		return

	fdel("tmp/[ckey].txt")
	var/savefile/S = new(prefs.path)
	S.ExportText("/", "tmp/[ckey].txt")

	DIRECT_OUTPUT(src, ftp("tmp/[ckey].txt", "[ckey].txt"))
