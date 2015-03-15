# Introduction #

For jobs that run periodically, you may be faced with figuring out what data needs to be consumed by the application.  CRUSH was developed in an environment where data files are published daily, and applications run at a particular frequency (e.g. daily, weekly, or monthly), and they need to either process files for an exact date range or process all data which has not yet been processed.

# Finding data within a particular date range #

For this discussion, we will assume that daily data feeds exist somewhere on disk, and those files contain date stamps in their names.

The `date(1)` utility provides a basic means of calculating date ranges, assuming they can be defined in terms of the current date.

```
date_fmt="+%Y-%m-%d"
# end processing with yesterday's data
enddate=`date -d "-1 days" "$date_fmt"`
# process a week's worth
startdate=`date -d "-6 days $enddate" "$date_fmt"`
```

From here, you have a few options.  One is to loop through each date using `dates_in_range`, building the filename based on the date (Dates\_in\_rangeUserDocs).

```
for d in `dates_in_range -s $startdate -e $enddate`; do
  input_filename="$source_dir/$d.dat"
  # process file...
done
```

Another option is to use `findfiles` to identify the files directly (FindfilesUserDocs).

```
files=`findfiles -d "$source_dir" -g "*.dat" -s $startdate -e $enddate`
# process files...
```

When using the latter method, it may be a good idea to make sure you found as many files as you expected.  Extending the previous example:

```
files=`findfiles -d "$source_dir" -g "*.dat" -s $startdate -e $enddate`
n_files=`echo $files | wc -w`
n_dates=`deltadays $startdate $enddate`
if [ $n_files -ne $n_dates ]; then
  warn "incorrect number of files found: $n_files instead of $n_dates"
  exit 1
fi
# process files...
```

Here we have used `deltadays` to tell us how many days there are in the date range (DeltadaysUserDocs).  That way the processing date range can be modified in the code or overridden by the user without impacting this part of the application.

# Finding all files needing to be processed #

The other usage pattern when looking for input data is to identify any files which have not yet been processed.  CRUSH handles this by letting the user keep a log file containing data which has been processed, and then scanning a directory for items not in that file.  This is done with the `find_not_processed` utility (Find\_not\_processedUserDocs).

```
already_done_log="$WORKING_DIR/processed.log"
files=`find_not_processed -d "$source_dir" -l "$already_done_log" -g "*.dat" -p`
for f in $files; do
  # process $f...
  basename $f >> $already_done_log
done
```

Even if processing files which could be located by date, this pattern is useful when you need to have your application get itself caught up if it misses a day of processing.


---

Back to ApplicationDevelopmentWithCrush