#!/usr/bin/awk -f

BEGIN {
  log_1 = ARGV[1];
  log_2 = ARGV[2];

  while ((getline < log_1) > 0) {
    before[$1] = $2;
  }
  close(log_1);

  while ((getline < log_2) > 0) {
    after[$1] = $2
  }
  close(log_2);

  for (pkg in before) {
    if (before[pkg] == after[pkg]) continue
    if (after[pkg] != "") {
      update[pkg] = pkg " " before[pkg] " -> " after[pkg]
    } else {
      remove[pkg] = pkg " " before[pkg]
    }
  }

  for (pkg in after) {
    if (pkg in before) {
      continue
    } else {
      new[pkg] = pkg " " after[pkg]
    }
  }

  if (length(update) != 0) {
    output++
    print "==> Update Formulae"
    for (pkg in update) {
      print update[pkg]
    }
  }
  if (length(new) != 0) {
    output++
    print "==> New Formulae"
    for (pkg in new) {
      print new[pkg]
    }
  }
  if (length(remove) != 0) {
    output++
    print "==> Remove Formulae"
    for (pkg in remove) {
      print remove[pkg]
    }
  }
  if (output == 0) {
    print "Already up-to-date."
  }
}
