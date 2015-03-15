# Introduction #

The CRUSH toolkit was designed for use against data feeds which have potential to change in format.  Even if you get a warning with sufficient time to change the code, it would be better to be able to just accept the changes without having to do any development work.

# Detecting the Delimiter #

If your data feed has a configurable field separator, it is best to dynamically determine what the delimiter string is at run-time.  Assuming the data feed contains a header line which can contain alpha-numeric characters, hyphens, and underscores, you can define shell functions as below

```
function get_file_header {
  if test -z "$1" -o ! -r "$1"; then return 1; fi
  local _cat=cat
  if test "${1: -3:3}" = ".gz" -o "${1: -2:2}" = ".Z"; then
    _cat="gunzip -c"
  fi
  $_cat "$1" | head -1
}

function get_file_delimiter {
  local header=`get_file_header $1`
  if test -z "$header"; then return 1; fi
  echo "$header" | egrep -o '[^-_a-zA-Z0-9]' | head -1
}
```

As we'll see below, it is useful to be able to extract the header line separately.  If there is any possibility at all that the delimiter will be a white-space character, then remember to quote all dereferences of your delimiter and header variables.   All of CRUSH utilities look for an environment variable `$DELIMITER`, which if defined, will be used as the field separator when the `-d` commandline option is not present.  So in your application code, you may have something like this:

```
files=`findfiles -s $start_date -e $end_date -d $dir -g "*.gz"`
DELIMITER=`get_file_delimiter $files`
export DELIMITER

# [process $files here ...]
```


# Detecting field location #

For data sets which contain a header row with predictable values, it is possible to use this as meta-data to locate required fields at run-time.  As of the 2009-01 release, all CRUSH utilities accept field labels as an alternative to indexes on the command-line.  Locating indexes dynamically can still be useful when processing the data with standard Unix tools.

```
function locate_field {
  local label="$1"
  local file="$2"
  local header=`get_file_header "$file"` || return 1
  local delim=`get_file_delimiter "$file"` || return 1
  local index=`indexof -s "$header" -d "$delim" -l "$label"`
  echo "$index"
  if test $index -eq 0; then return 1; fi
  return 0
}
```

This uses the CRUSH utility "`index`" to find the location of a field with the specified label.  This lets you do things like

```
aal2d access_log > access.log

DELIMITER=`get_file_delimiter access.log`
export DELIMITER
i_auth_name=`locate_field "Auth-User" access.log`
i_user_agent=`locate_field "User-Agent" access.log`

if test $i_auth_name -eq 0 -o $i_user_agent -eq 0; then
  echo "$0: required fields missing!" >&2
  exit 1 # assuming this is in a script file
fi

aggregate -p -k $i_auth_name,$i_user_agent -c 1 access.log
# equivalent to "aggregate -K Auth-User,User-Agent -c 1 access.log"

```

Now if we go make tweaks to the aal2d and/or our apache log format output, our script will continue working just fine as long as the "Auth-User" and "User-Agent" fields aren't removed altogether.


---

Back to ApplicationDevelopmentWithCrush