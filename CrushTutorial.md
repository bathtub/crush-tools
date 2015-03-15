# CRUSH Tutorial #

Here we will demonstrate some of the data-processing capabilities of the CRUSH toolkit.  We will primarily focus on processing access logs from an Apache web server, since such a data source is commonly available.


## Reading the log file ##

It is common to need to write a small amount of custom code for a processing task using CRUSH.  In this case, the need arises almost immediately for dealing with the Apache access logs due to the fact that the default format of the files is not really character-delimited.  A simple Perl script will transform that data into something that's easier to handle with CRUSH.

For an Apache httpd configuration of

```
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %b" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
```

This script, named `aal2d` ("Apache access log to delimited") does the trick:

```
#!/usr/bin/perl -w
use strict;
my $output_delim = $ENV{DELIMITER} || chr(0xfe);

# (dropping the RFC 1413 identity field)
print join($output_delim,
           qw(IP Auth-User Time Request Response Size Referrer User-Agent)),
      qq(\n);

while (<>) {
  /([\d\.]+) - ([^ ]+) \[([^\]]+)\] "([^"]+)" (\d+) (\d+|-) "([^"]+)" "([^"]+)"/;
  print join($output_delim,
             ($1, $2, $3, $4, $5,
              $6 eq '-' ? 0 : $6,
              $7 eq '-' ? '' : $7,
              $8)),
        qq(\n);
}

exit(0);
```

The default delimiter 'þ' is used here for its low probability of collision with actual data.  Now that we've gotten that out of the way, we can start doing interesting things with the data.

In the examples that follow, a relative path to "access\_log" is used.  To operate against a live Apache web log, `cd` to `/var/log/httpd`, or [download the example data file](http://crush-tools.googlecode.com/files/access_log.tar.gz) and run the commands from the directory where that file is kept.

## Simple aggregations ##

Let's say we want to know how many hits we're getting from each logged-in user.  The `aggregate` (AggregateUserDocs) utility is designed for this purpose.

```
aal2d access_log | aggregate -p -k 2 -c 1

# Or for CRUSH release 2009-01 or greater:

aal2d access_log | aggregate -K Auth-User -C IP
```

Refer to the AggregateUserDocs for details, but we're basically aggregating using field  2 as the key and counting all populated instances of field 1.

The output is something like

```
Auth-UserþIP
-þ1127
bvanhornþ103
hoofoosþ303
hotshotþ3
shadrackþ13
snimþ12
sunnyjimþ141
```

If we wanted to get that broken out by day, we can convert the time format using `convdate` (ConvdateUserDocs) to contain only the date and add that as a key field.

```
aal2d access_log |
  convdate -f 3 -i "%d/%b/%Y:%H:%M:%S %z" -o "%Y-%m-%d" |
  aggregate -p -k 3,2 -c 1

# Or for CRUSH release 2009-01 or greater:

aal2d access_log |
  convdate -F Time -i "%d/%b/%Y:%H:%M:%S %z" -o "%Y-%m-%d" |
  aggregate -K Time,Auth-User -C IP
```

The `convdate` call takes strings like "08/Jul/2008:04:27:26 -0600" and turns them into strings like "2008-07-08", giving us

```
TimeþAuth-UserþIP
2008-07-06þ-þ28
2008-07-06þhoofoosþ78
2008-07-06þsunnyjimþ17
2008-07-07þ-þ569
2008-07-07þhoofoosþ93
2008-07-07þshadrackþ6
2008-07-07þsnimþ11
2008-07-08þ-þ188
2008-07-08þbvanhornþ59
2008-07-08þhoofoosþ21
2008-07-08þshadrackþ7
2008-07-08þsunnyjimþ45
2008-07-09þ-þ342
2008-07-09þbvanhornþ44
2008-07-09þhoofoosþ111
2008-07-09þhotshotþ3
2008-07-09þsnimþ1
2008-07-09þsunnyjimþ79
```


## More formatting ##

In the example of login-page-hits by day, if you have a small number of users you may wish to have a column for each user and a row for each date.  The `pivot` (PivotUserDocs) utility handles this:

```
aal2d access_log |
  convdate -f 3 -i "%d/%b/%Y:%H:%M:%S %z" -o "%Y-%m-%d" |
  aggregate -p -k 3,2 -c 1 |
  pivot -k -f 1 -p 2 -v 3

# Or for CRUSH release 2009-01 or greater:

aal2d access_log |
  convdate -F Time -i "%d/%b/%Y:%H:%M:%S %z" -o "%Y-%m-%d" |
  aggregate -K Time,Auth-User -C IP
  pivot -F Time -P Auth-User -A IP
```

Now we get an output of

```
Timeþ-: IPþbvanhorn: IPþhoofoos: IPþhotshot: IPþshadrack: IPþsnim: IPþsunnyjim: IP
2008-07-06þ28þ0þ78þ0þ0þ0þ17
2008-07-07þ569þ0þ93þ0þ6þ11þ0
2008-07-08þ188þ59þ21þ0þ7þ0þ45
2008-07-09þ342þ44þ111þ3þ0þ1þ79
```

Piping the same command to `csvformat` (CsvformatUserDocs) will produce a CSV file suitable for viewing in your favorite spreadsheet application.  We can use `translate_field` (Translate\_fieldUserDocs) to change all of the requests not associated with a login session to "Anonymous".  And to turn the "IP" header in the aggregation output into something meaningful, we could use the standard `sed(1)` utility on just the header line:

```
# CRUSH 2008-10 and earlier:
aal2d access_log |
  (read header;
   echo "$header" | sed -e 's/IP/Page-Views/';
   cat -) |
  convdate -f 3 -i "%d/%b/%Y:%H:%M:%S %z" -o "%Y-%m-%d" |
  translate_field -f 2 -m '-=Anonymous' |
  aggregate -p -k 3,2 -c 1 |
  pivot -k -f 1 -p 2 -v 3 |
  csvformat 
```

Or we could add a `-l` option to the aggregate call:

```
# CRUSH 2009-01 and later:
aal2d access_log |
  convdate -F Time -i "%d/%b/%Y:%H:%M:%S %z" -o "%Y-%m-%d" |
  translate_field -F Auth-User -m '-=Anonymous' |
  aggregate -K Time,Auth-User -C IP -l Page-Views|
  pivot -k -F Time -P Auth-User -A Page-Views |
  csvformat 
```


Output:

```
"Time","Anonymous: Page-Views","bvanhorn: Page-Views","hoofoos: Page-Views","hotshot: Page-Views","shadrack: Page-Views","snim: Page-Views","sunnyjim: Page-Views"
"2008-07-06","28","0","78","0","0","0","17"
"2008-07-07","569","0","93","0","6","11","0"
"2008-07-08","188","59","21","0","7","0","45"
"2008-07-09","342","44","111","3","0","1","79"
```


## Joining Datasets ##

Many times it is necessary to join different datasets together.  One way of doing this is with the `mergekeys` utility (MergekeysUserDocs), which uses column headers to join sorted data sets.  Say you have a file named `food.log` containing

```
Auth-UserþFavorite-Food
bvanhornþEggs
hoofoosþHam
hotshotþFish
shadrackþCake
snimþSoup
sunnyjimþFrankfurters
```

And you want to join this into the first aggregation above (page-views by user).

```
aal2d access_log | aggregate -p -k 2 -c 1 > page_views.log
# or...
aal2d access_log | aggregate -K Auth-User -C IP > page_views.log
# and then:
mergekeys page_views.log food.log | csvformat
```

And you get

```
"Auth-User","IP","Favorite-Food"
"-","1127",""
"bvanhorn","103","Eggs"
"hoofoos","303","Ham"
"hotshot","3","Fish"
"shadrack","13","Cake"
"snim","12","Soup"
"sunnyjim","141","Frankfurters"
```

Note that currently `mergekeys` requires that
  * the two files should have the same column labels for all key fields
  * all key fields occur at the beginning of the lines in both files
  * both files be sorted by the key fields


## So... ##

By building up pipelines of CRUSH and standard Unix utilities, complicated transformations and formatting can be accomplished with straight-forward shell scripting.