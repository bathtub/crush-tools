# Introduction #

Writing reliable applications using the CRUSH toolkit is mostly about writing reliable shell scripts.  Here are a few things you might want to do to get started.

# A central library #

Throughout the deep-dive we'll be defining shell functions to handle certain aspects of application development.  These can be put into a centralized library and sourced by all of your applications.  The source for these functions is available at http://crush-tools.googlecode.com/svn/trunk/contrib/crushlib.sh

# Scheduling considerations #

If you are running your applications from `cron` or some other scheduling system, you have to be careful to ensure that the environment in which the applications run is defined properly.  You can do this in the centralized library as well by exporting environment variables related, for example, to databases, locales, etc.

Another issue with applications run from `cron` is that you generally can't rely on relative paths to files to work properly.  If your application needs to access files in the same location as the application script itself (e.g. temporary files or state data), you will want to be able to refer to those resources with an absolute path while avoiding maintenance problems should the code location change.  In the central library, you can do

```
WORKING_DIR=`dirname $0`
export WORKING_DIR
```

and use `$WORKING_DIR` as the fully-qualified path to those resources.

# Error reporting #

With scheduled jobs, it is not always obvious what application is producing errors or warnings.  To avoid extra typing, I like to define the following:

```
function warn {
  echo -e "$0: $*" >&2
}
```

This precedes the warning message with the application filename to give context to the error messages which could be recieved in emails from `cron`.

# Avoiding multiple application instances #

If an application requires that only one instance of itself exist at one time, an easy way to manage that is to define a function like

```
# check whether all of a list of processes are actually alive
function verify_pid {
  if [ -z "$*" ]; then
    return 1
  fi
  nprocs=`ps -p $* | (read header; cat) | wc -l`
  if [ $nprocs -eq $# ]; then
    return 0
  fi
  return 1
}

function assert_single_instance {
  local pidfile="${1:-$0.pid}"
  if [ ! -e "$pidfile" ]; then
    echo $$ > "$pidfile" 
    return 0
  fi
  # check for stale pid file, and print warning if running from the console
  verify_pid `cat "$pidfile"` && \
    { if test -t 1; then warn "this process is already running"; fi
      exit 1
    }
  echo $$ > "$pidfile"
  return 0
}

function cleanup_pidfile {
  local exit_code=$?
  local pidfile="${1:-$0.pid}"
  if test -e "$pidfile" -a `cat "$pidfile"` -eq $$; then
    rm $pidfile
  fi
  return $exit_code
}
```

Ensuring that only one instance of your application is active at one time is then a simple matter of including a couple of lines in your application code.

```
assert_single_instance
trap 'cleanup_pidfile; exit $?' EXIT TERM INT HUP QUIT
```

In some cases, this trap could go into the global library.


---

Back to ApplicationDevelopmentWithCrush