# Introduction #

Data processing tasks can be classified filtering, transforming, merging/joining, or formatting.  CRUSH also has some miscellaneous utilities to make certain shell-scripting tasks easier.

Many of the CRUSH tools behave similarly to standard Unix utilities, but they have some specialized functionality and possibly some improved usability.

# Filtering #

Filtering data involves the removal of non-interesting records.

  * `grepfield` is like the `grep(1)` utility, but it operates against a specific field in a stream of delimited data.
  * `funiq` is similar to the `uniq(1)`, but it operates against specific fields in a stream of delimited data.
  * `cutfield` removes specific fields of a data stream, much like an inverted version of the `cut(1)` utility
  * `truncfield` truncates the values of fields in a data stream.
  * `subtotal` inserts roll-up lines for adjacent blocks of lines with common key fields.

# Transforming #

Data transformations change the "shape" of the data in some way.

  * `aggregate` calculates sums, counts, and averages of metric fields for each distinct values of a set of key fields.  It does not rely on the input being sorted, and holds the set of keys and metrics in memory.
  * `aggregate2` is better when there are too many distinct keys to hold in memory.  The input must be pre-sorted, but the memory footprint is much smaller than `aggregate`'s.
  * `reorder` changes the order of fields in each line.  When used with the `-f` option, it is a replacement for `cut(1)` which produces output in the requested order rather than the original input order.  It can also move or swap individual fields.
  * `add_field` creates a new field with a set value.
  * `calcfield` creates a new field based on an expression calculated against existing fields.
  * `translate_field` maps a new value onto existing values in a field.


# Merging and Joining #

  * `deltaforce` updates a large data set in one file with incremental updates from another file.
  * `mergekeys` joins two sorted files with some fields in common ("keys"), appending the non-common fields to each line.


# Formatting #

  * `pivot` takes distinct values from a set of fields and turns them into new columns.
  * `csvformat` turns delimited text into CSV (comma-separated values) format compatible with spreadsheet applications.
  * `convdate` changes the format of a field containing a date/time value.


# Miscellaneous #

  * `buffer` gathers input in memory and outputs it all at once to a file.  This is useful when you want to output to a file which is being used as input.  When using the shell's output redirection operator (`>`), the output file is opened for writing and truncated before the pipeline is executed.
  * `dates_in_range` prints out all of the dates falling within a specified start/end range.
  * `deltadays` prints the number of days within a start/end range.
  * `dbstream` executes a database query and prints the results as a delimited text stream.
  * `foreach_parallel` is like a parallelized `for` loop in shell.  It executes a block of code against multiple input values in parallel.
  * `find_not_processed` and `findfiles` may be used to locate input data files.
  * `indexof` reads a column-label header line to find the index of a particular field



---

Back to ApplicationDevelopmentWithCrush