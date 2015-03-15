# Error handling #

Properly handling errors is an important part of writing reliable applications.  To make sure it is done consistently without rendering the application code unreadable, it is worthwhile to have some functions for dealing with common cases.

The variable "`$?`" contains the exit code of the most recently completed command, so that can be checked for simple statements.  And it is automatically used when using logical `&&` and `||` operators.

```
. /path/to/crushlib.sh || {
  echo "$0: failed to source crushlib.sh" >&2
  exit 1
}

files=`find_not_processed -l "$logfile" -d "$source_dir" -g \*.log`
if test $? -ne 0; then
  warn "failed to locate files"
  exit 1
fi
```

But when dealing with pipelines, you may need to do a little more work.  After a pipeline has executed, "`$?`" usually contains the exit code of the last element of the pipeline.  If errors occurred in some other element, this is insufficient for error detection.  Bash provides a couple of different options.

  * Check the `PIPESTATUS` variable.  This is an array of exit codes from each of the pipeline members.  If all applications in the pipeline can be expected to exit 0 on success, you can define a function to handle errors like this:

```
function DIE_ON_PIPE_ERROR {
  local exit_codes="${PIPESTATUS[*]}"
  local exit_code
  for exit_code in $exit_codes; do
    if test $exit_code -ne 0; then
      warn "$*"
      exit $exit_code
    fi
  done
  return 0
}
```

> Which can be used like so, taking care to call `DIE_ON_PIPE_ERROR` before any other commands can overwrite the value of the `PIPESTATUS` array:

```
zcat $files |
  grepfield -f 1 ".+" |
  aggregate -k 1-4 -s 5 \
  > $WORKING_DIR/tmp/$$_tmpfile.log

DIE_ON_PIPE_ERROR "line $LINENO: error processing data"
```

  * Set the "`pipefail`" option, which causes "`$?`" to contain the last non-zero exit code in the pipeline.  This option was added in Bash version 3.

```
set -o pipefail
# ...
zcat $files |
  grepfield -f 1 ".+" |
  aggregate -k 1-4 -s 5 \
  > $WORKING_DIR/tmp/$$_tmpfile.log

if test $? -ne 0; then
  warn "line $LINENO: error processing data"
  exit 1
fi
```


Note that the assumption that non-zero exit codes indicate a failure is not necessarily reliable.  Perhaps the most common example is the exit code used by `grep(1)` when no matches are found.  It is up to the developer to determine whether a function like `DIE_ON_PIPE_ERROR` can be used in light of such circumstances.

The examples here are not portable to shells other than Bash.  Check your shell's manual for information about how to apply these concepts in such environments.


---

Back to ApplicationDevelopmentWithCrush