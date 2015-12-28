#!/usr/bin/awk -f

BEGIN {
	str1 = ARGV[1];
  str2 = ARGV[2];
  split(str1, str1_ary, "")
  split(str2, str2_ary, "")
  print leven(str1_ary, str2_ary)
}

# compute a levenshtein distance between 2 strings
# example:
# 
#   split("bcaabc", str1_ary, "")
#   split("abbdc",  str2_ary, "")
#   dist = leven(str1_ary, str2_ary)
# 
function leven(ary1, ary2,    table, k1, k2) {
  len1 = length(ary1)
  len2 = length(ary2)
  for (k1 = 0; k1 <= len1; k1++) { table[k1][0 ] = k1; }
  for (k2 = 0; k2 <= len2; k2++) { table[0 ][k2] = k2; }
  for (k1 = 1; k1 <= len1; k1++) {
    for (k2 = 1; k2 <= len2; k2++) {
      v0 = table[k1-1][k2-1]
      v1 = table[k1  ][k2-1]
      v2 = table[k1-1][k2  ]
      table[k1][k2] = v0
      if (ary1[k1] == ary2[k2]) continue
      if (v0 > v1) table[k1][k2] = v1;
      if (v0 > v2) table[k1][k2] = v2;
      table[k1][k2]++
    }
  }
  return table[len1][len2]
}
