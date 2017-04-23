#ifndef _NUMBER_H
#define _NUMBER_H 1

#define INT24_MIN (-(1LL<<23))
#define INT24_MAX ((1LL<<23)-1)
#define INT40_MIN (-(1LL<<39))
#define INT40_MAX ((1LL<<39)-1)
#define INT48_MIN (-(1LL<<47))
#define INT48_MAX ((1LL<<47)-1)
#define INT56_MIN (-(1LL<<55))
#define INT56_MAX ((1LL<<55)-1)

/* type def */

typedef struct Number {
	char		vl_len_[4];
	char		data[FLEXIBLE_ARRAY_MEMBER];
} Number;

#endif /* _NUMBER_H */
