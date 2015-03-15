# Usage #

`translate_fields <options> <-f <N>> [options] [file ...]`

  * Mappings passed to -m are specified as "K=V" pairs where K is a possible value for the field, and V is the translation.
  * Replacing is the default behavior, but for replacement to occur in addition to appending or prepending, -r must be specified.
  * If no mapping is supplied for a field value, the value is unchanged (the header is preserved unless a mapping is specified for the header value)

The file specified by -e may have statements like
```
  $mapping{hello} = 'salve';
  $mapping{world} = 'orbis terrae';
```
or
```
  %mapping = ("hello" => "salve", "world" => "orbis terrae");
```
The latter will nullify any -m parameters passed on the commandline.


# Options #
|**Short Opt**|**Long Opt**|**Argument**|**Description**|
|:------------|:-----------|:-----------|:--------------|
|-h|--help|  |print this message and exit|
|-d|--delim|

&lt;delim&gt;

 |field separator string (default: 0xfe)|
|-f|--field|

&lt;field&gt;

 |index of field to translate|
|-a|--append|  |append the translated field after the original field|
|-p|--prepend|  |prepend the translated field before the original field|
|-r|--replace|  |replace the original field with the translated field|
|-m|--map|

&lt;map&gt;

 |specifies a translation mapping for a possible field value (may be specified multiple times)|
|-e|--external|

&lt;external&gt;

 |specifies a file containing perl expressions which define mappings in the hashtable "%mapping"|
|-x|--xpression|

&lt;xpression&gt;

 |specifies a list of regular expressions to apply to the specified input field|


---

back to UserDocs