#!/usr/bin/awk -f

{
	LINE = NR
	if (COL+0 < NF)
		COL = NF
	for (j = 1; j <= COL; j++) {
		FLD[LINE, j] = $j
		if (WID[j]+0 < length($j))
			WID[j] = length($j)
	}
}
