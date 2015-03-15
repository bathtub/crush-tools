# Usage #

`mergekeys <options> file1 file2`

Input files must be sorted by key fields.

If -a and -b are not specified, the first line of each file will be examined
to determine common fields.  In this case, all key fields must precede all
mergeable fields.  A header line in each file is required in either case.

# Options #
|**Short Opt**|**Long Opt**|**Argument**|**Description**|
|:------------|:-----------|:-----------|:--------------|
|-h|--help|  |print this message and exit|
|-V|--version|  |print version info and exit|
|-v|--verbose|  |print verbose messages during execution|
|-a|--left-keys|

<left\_keys>

 |list of key fields in left-hand file|
|-A|--left-labels|

<left\_key\_labels>

 |list of key labels in left-hand file|
|-b|--right-keys|

<right\_keys>

 |list of key fields in right-hand file|
|-B|--right-labels|

<right\_key\_labels>

 |list of key labels in right-hand file|
|-i|--inner|  |inner join - i.e. drop lines that do not have a match in both files|
|-r|--right|  |right outer join - i.e. drop lines in the first file that do not have a match in the second file|
|-l|--left|  |left outer join - i.e. drop lines in the second file that do not have a match in the first file|
|-D|--default|

<merge\_default>

 |for outer joins, the defaut value to put in unmatched merge fields|
|-d|--delim|

&lt;delim&gt;

 |delimiting string for both input files|
|-o|--outfile|

&lt;outfile&gt;

 |name of file for output|


---

back to UserDocs