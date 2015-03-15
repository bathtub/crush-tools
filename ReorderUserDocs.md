# Usage #

`reorder <options> [file(s)]`

the fields param is exclusive of swap and move - if -f and -m or -s are
specified, only -f will be used.

example: reorder -d : -s 1,3 -m 2,4 /etc/passwd

would swap fields 1 and 3, and then would move field 2 to position 4.

# Options #
|**Short Opt**|**Long Opt**|**Argument**|**Description**|
|:------------|:-----------|:-----------|:--------------|
|-h|--help|  |print this message and exit|
|-V|--version|  |print version info and exit|
|-v|--verbose|  |print verbose messages during execution|
|-d|--delim|

&lt;delim&gt;

 |specifies delimiting string|
|-s|--swap|

&lt;swap&gt;

 |specifies two fields to swap (ex: -s 1,3)|
|-m|--move|

&lt;move&gt;

 |specifies a field to move to a new position (ex: -s 3,1)|
|-f|--fields|

&lt;fields&gt;

 |specifies fields to use to create a new string (ex: -f 3,4,1,5,2)|
|-F|--field-labels|

<field\_labels>

 |a list of labels specifying the output field order|


---

back to UserDocs