test_number=09
description="user-specified key fields"

for i in `seq 0 ${#test_variants[*]}`; do
  outfile="$test_dir/test_$test_number.${test_variants[$i]}.actual"
  expected=$test_dir/test_$test_number.expected
  $bin ${test_variants[$i]} -a 2,3 -b 1,3 \
       -o "$outfile" \
       "$test_dir/test_$test_number.a" \
       "$test_dir/test_$test_number.b"

  if [ $? -ne 0 ] ||
     [ "`diff -q $outfile $expected`" ]; then
    test_status $test_number $i "$description" FAIL
  else
    test_status $test_number $i "$description" PASS
    rm "$outfile"
  fi
done