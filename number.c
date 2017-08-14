/*
Copyright (c) 2017, PostgreSQL Global Development Group
Author: Christoph Berg <cb@df7cb.de>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "postgres.h"
#include "fmgr.h"
#include <inttypes.h> /* PRId64 */

#include "number.h"

/* module initialization */

PG_MODULE_MAGIC;

/* internal functions */

static Number *
number_from_int64 (int64_t l)
{
	Number		*n;

	if (l == 0)
	{
		n = palloc(VARHDRSZ + 0);
		SET_VARSIZE(n, VARHDRSZ + 0);
		return n;
	}

	if (l > 0) {
		l -= 1;
	}

	if (l >= INT8_MIN && l <= INT8_MAX)
	{
		int8_t c = l;
		n = palloc(VARHDRSZ + 1);
		SET_VARSIZE(n, VARHDRSZ + 1);
		memcpy(&n->data, &c, 1);
		return n;
	}

	if (l > 0) {
		l -= 1 << 7;
	} else {
		l += 1 << 7;
	}

	if (l >= INT16_MIN && l <= INT16_MAX)
	{
		int16_t i = l;
		n = palloc(VARHDRSZ + 2);
		SET_VARSIZE(n, VARHDRSZ + 2);
		memcpy(&n->data, &i, 2);
		return n;
	}

	if (l > 0) {
		l -= 1 << 15;
	} else {
		l += 1 << 15;
	}

	if (l >= INT24_MIN && l <= INT24_MAX)
	{
		int32_t i = l;
		n = palloc(VARHDRSZ + 3);
		SET_VARSIZE(n, VARHDRSZ + 3);
		memcpy(&n->data, &i, 3); /* little endian */
		return n;
	}

	if (l > 0) {
		l -= 1 << 23;
	} else {
		l += 1 << 23;
	}

	if (l >= INT32_MIN && l <= INT32_MAX)
	{
		int32_t i = l;
		n = palloc(VARHDRSZ + 4);
		SET_VARSIZE(n, VARHDRSZ + 4);
		memcpy(&n->data, &i, 4);
		return n;
	}

	if (l > 0) {
		l -= 1L << 31;
	} else {
		l += 1L << 31;
	}

	if (l >= INT40_MIN && l <= INT40_MAX)
	{
		n = palloc(VARHDRSZ + 5);
		SET_VARSIZE(n, VARHDRSZ + 5);
		memcpy(&n->data, &l, 5); /* little endian */
		return n;
	}

	if (l > 0) {
		l -= 1L << 39;
	} else {
		l += 1L << 39;
	}

	if (l >= INT48_MIN && l <= INT48_MAX)
	{
		n = palloc(VARHDRSZ + 6);
		SET_VARSIZE(n, VARHDRSZ + 6);
		memcpy(&n->data, &l, 6); /* little endian */
		return n;
	}

	if (l > 0) {
		l -= 1L << 47;
	} else {
		l += 1L << 47;
	}

	if (l >= INT56_MIN && l <= INT56_MAX)
	{
		n = palloc(VARHDRSZ + 7);
		SET_VARSIZE(n, VARHDRSZ + 7);
		memcpy(&n->data, &l, 7); /* little endian */
		return n;
	}

	if (l > 0) {
		l -= 1L << 55;
	} else {
		l += 1L << 55;
	}

	n = palloc(VARHDRSZ + 8);
	SET_VARSIZE(n, VARHDRSZ + 8);
	memcpy(&n->data, &l, 8);
	return n;
}

static int64_t
number_to_int64 (Number *n)
{
	int		 size = VARSIZE_ANY(n);

	switch (size)
	{
		case VARHDRSZ + 0:
			return 0;
		case VARHDRSZ + 1:
		{
			int8_t *c = (void *) VARDATA_ANY(n);

			int64_t a = *c;
			if (a >= 0) {
				a += 1;
			}

			return a;
		}
		case VARHDRSZ + 2:
		{
			int16_t i;
			memcpy(&i, VARDATA_ANY(n), 2);

			int64_t a = i;
			if (a >= 0) {
				a += (1 << 7) + 1;
			} else {
				a -= (1 << 7);
			}

			return a;
		}
		case VARHDRSZ + 3:
		{
			int32_t i = 0;
			memcpy(&i, VARDATA_ANY(n), 3);

			int64_t a = (i<<8)>>8;
			if (a >= 0) {
				a += (1 << 15) + (1 << 7) + 1;
			} else {
				a -= (1 << 15) + (1 << 7);
			}

			return a;
		}
		case VARHDRSZ + 4:
		{
			int32_t i;
			memcpy(&i, VARDATA_ANY(n), 4);

			int64_t a = i;
			if (a >= 0) {
				a += (1 << 23) + (1 << 15) + (1 << 7) + 1;
			} else {
				a -= (1 << 23) + (1 << 15) + (1 << 7);
			}

			return a;
		}
		case VARHDRSZ + 5:
		{
			int64_t i;
			memcpy(&i, VARDATA_ANY(n), 5);
			i = (i<<24)>>24;

			if (i >= 0) {
				i += (1L << 31) + (1 << 23) + (1 << 15) + (1 << 7) + 1;
			} else {
				i -= (1L << 31) + (1 << 23) + (1 << 15) + (1 << 7);
			}

			return i;
		}
		case VARHDRSZ + 6:
		{
			int64_t i;
			memcpy(&i, VARDATA_ANY(n), 6);
			i = (i<<16)>>16;

			if (i >= 0) {
				i += (1L << 39) + (1L << 31) + (1 << 23) + (1 << 15) + (1 << 7) + 1;
			} else {
				i -= (1L << 39) + (1L << 31) + (1 << 23) + (1 << 15) + (1 << 7);
			}

			return i;
		}
		case VARHDRSZ + 7:
		{
			int64_t i;
			memcpy(&i, VARDATA_ANY(n), 7);
			i = (i<<8)>>8;

			if (i >= 0) {
				i += (1L << 47) + (1L << 39) + (1L << 31) + (1 << 23) + (1 << 15) + (1 << 7) + 1;
			} else {
				i -= (1L << 47) + (1L << 39) + (1L << 31) + (1 << 23) + (1 << 15) + (1 << 7);
			}

			return i;
		}
		case VARHDRSZ + 8:
		{
			int64_t i;
			memcpy(&i, VARDATA_ANY(n), 8);

			if (i >= 0) {
				i += (1L << 55) + (1L << 47) + (1L << 39) + (1L << 31) + (1 << 23) + (1 << 15) + (1 << 7) + 1;
			} else {
				i -= (1L << 55) + (1L << 47) + (1L << 39) + (1L << 31) + (1 << 23) + (1 << 15) + (1 << 7);
			}

			return i;
		}
		default:
			elog(ERROR, "Unexpected number length %d", size);
	}
}

/* functions */

PG_FUNCTION_INFO_V1 (number_in);

Datum
number_in (PG_FUNCTION_ARGS)
{
	char		*str = PG_GETARG_CSTRING(0);
	PG_RETURN_POINTER(number_from_int64(atoll(str)));
}

PG_FUNCTION_INFO_V1(number_out);

Datum
number_out(PG_FUNCTION_ARGS)
{
	Number  *n = (Number *) PG_GETARG_VARLENA_P(0);
	PG_RETURN_CSTRING(psprintf("%" PRId64, number_to_int64(n)));
}

PG_FUNCTION_INFO_V1 (number_from_int);

Datum
number_from_int (PG_FUNCTION_ARGS)
{
	int32_t		l = PG_GETARG_INT32(0);
	PG_RETURN_POINTER(number_from_int64(l));
}

PG_FUNCTION_INFO_V1 (number_from_bigint);

Datum
number_from_bigint (PG_FUNCTION_ARGS)
{
	int64_t		l = PG_GETARG_INT64(0);
	PG_RETURN_POINTER(number_from_int64(l));
}

PG_FUNCTION_INFO_V1 (number_to_bigint);

Datum
number_to_bigint (PG_FUNCTION_ARGS)
{
	Number  *n = (Number *) PG_GETARG_VARLENA_P(0);
	PG_RETURN_INT64(number_to_int64(n));
}

/* number-number comparisons */

#define number_comp(name, op)										\
PG_FUNCTION_INFO_V1(name);											\
																	\
Datum																\
name(PG_FUNCTION_ARGS)												\
{																	\
	int64_t a = number_to_int64((Number *) PG_GETARG_VARLENA_P(0));	\
	int64_t b = number_to_int64((Number *) PG_GETARG_VARLENA_P(1));	\
																	\
	PG_RETURN_BOOL(a op b);											\
}

number_comp(number_lt, <);
number_comp(number_le, <=);
number_comp(number_eq, ==);
number_comp(number_ne, !=);
number_comp(number_ge, >=);
number_comp(number_gt, >);

PG_FUNCTION_INFO_V1(number_cmp);

Datum
number_cmp(PG_FUNCTION_ARGS)
{
	int64_t a = number_to_int64((Number *) PG_GETARG_VARLENA_P(0));
	int64_t b = number_to_int64((Number *) PG_GETARG_VARLENA_P(1));

	if (a < b)
		PG_RETURN_INT32(-1);
	PG_RETURN_INT32(a > b);
}

/* number-bigint comparisons */

#define number_bigint_comp(name, op)								\
PG_FUNCTION_INFO_V1(name);											\
																	\
Datum																\
name(PG_FUNCTION_ARGS)												\
{																	\
	int64_t a = number_to_int64((Number *) PG_GETARG_VARLENA_P(0));	\
	int64_t b = PG_GETARG_INT64(1);									\
																	\
	PG_RETURN_BOOL(a op b);											\
}

number_bigint_comp(number_bigint_lt, <);
number_bigint_comp(number_bigint_le, <=);
number_bigint_comp(number_bigint_eq, ==);
number_bigint_comp(number_bigint_ne, !=);
number_bigint_comp(number_bigint_ge, >=);
number_bigint_comp(number_bigint_gt, >);

PG_FUNCTION_INFO_V1(number_bigint_cmp);

Datum
number_bigint_cmp(PG_FUNCTION_ARGS)
{
	int64_t a = number_to_int64((Number *) PG_GETARG_VARLENA_P(0));
	int64_t b = PG_GETARG_INT64(1);

	if (a < b)
		PG_RETURN_INT32(-1);
	PG_RETURN_INT32(a > b);
}

/* bigint-number comparisons */

#define bigint_number_comp(name, op)								\
PG_FUNCTION_INFO_V1(name);											\
																	\
Datum																\
name(PG_FUNCTION_ARGS)												\
{																	\
	int64_t a = PG_GETARG_INT64(0);									\
	int64_t b = number_to_int64((Number *) PG_GETARG_VARLENA_P(1));	\
																	\
	PG_RETURN_BOOL(a op b);											\
}

bigint_number_comp(bigint_number_lt, <);
bigint_number_comp(bigint_number_le, <=);
bigint_number_comp(bigint_number_eq, ==);
bigint_number_comp(bigint_number_ne, !=);
bigint_number_comp(bigint_number_ge, >=);
bigint_number_comp(bigint_number_gt, >);

PG_FUNCTION_INFO_V1(bigint_number_cmp);

Datum
bigint_number_cmp(PG_FUNCTION_ARGS)
{
	int64_t a = PG_GETARG_INT64(0);
	int64_t b = number_to_int64((Number *) PG_GETARG_VARLENA_P(1));

	if (a < b)
		PG_RETURN_INT32(-1);
	PG_RETURN_INT32(a > b);
}

/* number-int comparisons */

#define number_int_comp(name, op)									\
PG_FUNCTION_INFO_V1(name);											\
																	\
Datum																\
name(PG_FUNCTION_ARGS)												\
{																	\
	int64_t a = number_to_int64((Number *) PG_GETARG_VARLENA_P(0));	\
	int32_t b = PG_GETARG_INT32(1);									\
																	\
	PG_RETURN_BOOL(a op b);											\
}

number_int_comp(number_int_lt, <);
number_int_comp(number_int_le, <=);
number_int_comp(number_int_eq, ==);
number_int_comp(number_int_ne, !=);
number_int_comp(number_int_ge, >=);
number_int_comp(number_int_gt, >);

PG_FUNCTION_INFO_V1(number_int_cmp);

Datum
number_int_cmp(PG_FUNCTION_ARGS)
{
	int64_t a = number_to_int64((Number *) PG_GETARG_VARLENA_P(0));
	int32_t b = PG_GETARG_INT32(1);

	if (a < b)
		PG_RETURN_INT32(-1);
	PG_RETURN_INT32(a > b);
}

/* int-number comparisons */

#define int_number_comp(name, op)									\
PG_FUNCTION_INFO_V1(name);											\
																	\
Datum																\
name(PG_FUNCTION_ARGS)												\
{																	\
	int32_t a = PG_GETARG_INT32(0);									\
	int64_t b = number_to_int64((Number *) PG_GETARG_VARLENA_P(1));	\
																	\
	PG_RETURN_BOOL(a op b);											\
}

int_number_comp(int_number_lt, <);
int_number_comp(int_number_le, <=);
int_number_comp(int_number_eq, ==);
int_number_comp(int_number_ne, !=);
int_number_comp(int_number_ge, >=);
int_number_comp(int_number_gt, >);

PG_FUNCTION_INFO_V1(int_number_cmp);

Datum
int_number_cmp(PG_FUNCTION_ARGS)
{
	int32_t a = PG_GETARG_INT32(0);
	int64_t b = number_to_int64((Number *) PG_GETARG_VARLENA_P(1));

	if (a < b)
		PG_RETURN_INT32(-1);
	PG_RETURN_INT32(a > b);
}
