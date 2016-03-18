These scripts have been written in such a way as to not contain any personal details (such as usernames, passwords, ip addresses etc). To accomplish this I’ve had to write these scripts as functions which are then called from another script (not published on this GitHub repo). Basically all this means is the scripts will not always be plug-and-play (may require some modification to get running).

# Handling binary AppleScript files

Create the following shell script in `/usr/local/bin` and name it `git-ascr-filter`.

```
#!/bin/sh
if [ $# -ne 2 ]; then
    echo "Usage: $0 --clean/--smudge FILE">&2
    exit 1
else
    if [ "$1" = "--clean" ]; then
        osadecompile "$2" | sed 's/[[:space:]]*$//'
    elif [ "$1" = "--smudge" ]; then
        TMPFILE=`mktemp -t tempXXXXXX`
        if [ $? -ne 0 ]; then
            echo "Error: \`mktemp' failed to create a temporary file.">&2
            exit 3
        fi
        if ! mv "$TMPFILE" "$TMPFILE.scpt" ; then
            echo "Error: Failed to create a temporary SCPT file.">&2
            rm "$TMPFILE"
            exit 4
        fi
        TMPFILE="$TMPFILE.scpt"
        # Compile the AppleScript source on stdin.
        if ! osacompile -l AppleScript -o "$TMPFILE" ; then
            rm "$TMPFILE"
            exit 5
        fi
        cat "$TMPFILE" && rm "$TMPFILE"
    else
        echo "Error: Unknown mode '$1'">&2
        exit 2
    fi
fi
```

Once saved, ensure you `chmod a+x` on the script.
Now make sure you are in the same directory as the repository and run:

```
git config filter.ascr.clean "git-ascr-filter --clean %f"
git config filter.ascr.smudge "git-ascr-filter --smudge %f"
```

Finally, add this to `.gitattributes`:

```
*.scpt filter=ascr
```

Credit: http://stackoverflow.com/a/14425009