(*
Mounts a remote filesystem using sshfs, attempts to use local hostname if possible otherwise fallbacks to remote address.
*)

on mount(volumeName, username, localAddress, remoteAddress)
	if localAddress is not missing value and isHostAlive(localAddress) then
		set server to localAddress
	else
		set server to remoteAddress
	end if

	set workingDirectoryPath to "/"
	set volumesDirectoryPath to "/Volumes"

	set sshfsApplicationPath to "/usr/local/bin/sshfs"
	set options to "'auto_cache,reconnect,volname=" & volumeName & "'"
	set mountPoint to "/Volumes/" & toLowerCase(replace(volumeName, " ", "_"))

	if not fileExists(mountPoint) then
		do shell script "mkdir " & mountPoint
		do shell script sshfsApplicationPath & " " & username & "@" & server & ":" & workingDirectoryPath & " " & mountPoint & " -o " & options
	end if
end mount

on isHostAlive(host)
	try
		return (((do shell script "ping -c 1 " & host)'s paragraph 5's word 4) = "1")
	on error
		return false
	end try
end isHostAlive

on fileExists(fileName)
	tell application "Finder"
		return exists fileName as POSIX file
	end tell
end fileExists

on toLowerCase(str)
	set the comparison_string to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set the source_string to "abcdefghijklmnopqrstuvwxyz"
	set the output to ""

	repeat with char in str
		set x to the offset of char in the comparison_string
		set the output to (the output & char) as string
	end repeat

	return the output
end toLowerCase

on replace(str, search, replacement)
	set AppleScript's text item delimiters to the search
	set the item_list to every text item of str
	set AppleScript's text item delimiters to the replacement
	set str to the item_list as string
	set AppleScript's text item delimiters to ""
	return str
end replace
