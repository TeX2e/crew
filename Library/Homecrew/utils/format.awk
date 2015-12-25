#!/usr/bin/awk -f

END {
	for (i = 1; i <= LINE; i++) {
		for (j = 1; j <= COL; j++) {
			printf("%" WID[j] "s", FLD[i, j])
			printf((j < COL) ? OFS : ORS)
		}
	}
}
