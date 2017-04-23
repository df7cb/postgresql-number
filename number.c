/*
Copyright (c) 2017, PostgreSQL Global Development Group

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
#include <limits.h>

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
	}
	else if (l >= INT8_MIN && l <= INT8_MAX)
	{
		int8_t c = l;
		n = palloc(VARHDRSZ + 1);
		SET_VARSIZE(n, VARHDRSZ + 1);
		memcpy(&n->data, &c, 1);
	}
	else if (l >= INT16_MIN && l <= INT16_MAX)
	{
		int16_t i = l;
		n = palloc(VARHDRSZ + 2);
		SET_VARSIZE(n, VARHDRSZ + 2);
		memcpy(&n->data, &i, 2);
	}
	else if (l >= INT24_MIN && l <= INT24_MAX)
	{
		int32_t i = l;
		n = palloc(VARHDRSZ + 3);
		SET_VARSIZE(n, VARHDRSZ + 3);
		memcpy(&n->data, &i, 3); /* little endian */
	}
	else if (l >= INT32_MIN && l <= INT32_MAX)
	{
		int32_t i = l;
		n = palloc(VARHDRSZ + 4);
		SET_VARSIZE(n, VARHDRSZ + 4);
		memcpy(&n->data, &i, 4);
	}
	else if (l >= INT40_MIN && l <= INT40_MAX)
	{
		n = palloc(VARHDRSZ + 5);
		SET_VARSIZE(n, VARHDRSZ + 5);
		memcpy(&n->data, &l, 5); /* little endian */
	}
	else if (l >= INT48_MIN && l <= INT48_MAX)
	{
		n = palloc(VARHDRSZ + 6);
		SET_VARSIZE(n, VARHDRSZ + 6);
		memcpy(&n->data, &l, 6); /* little endian */
	}
	else if (l >= INT56_MIN && l <= INT56_MAX)
	{
		n = palloc(VARHDRSZ + 7);
		SET_VARSIZE(n, VARHDRSZ + 7);
		memcpy(&n->data, &l, 7); /* little endian */
	}
	else
	{
		n = palloc(VARHDRSZ + 8);
		SET_VARSIZE(n, VARHDRSZ + 8);
		memcpy(&n->data, &l, 8);
	}

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
			return *c;
		}
		case VARHDRSZ + 2:
		{
			int16_t i;
			memcpy(&i, VARDATA_ANY(n), 2);
			return i;
		}
		case VARHDRSZ + 3:
		{
			int32_t i = 0;
			memcpy(&i, VARDATA_ANY(n), 3);
			return (i<<8)>>8;
		}
		case VARHDRSZ + 4:
		{
			int32_t i;
			memcpy(&i, VARDATA_ANY(n), 4);
			return i;
		}
		case VARHDRSZ + 5:
		{
			int64_t i;
			memcpy(&i, VARDATA_ANY(n), 5);
			return (i<<24)>>24;
		}
		case VARHDRSZ + 6:
		{
			int64_t i;
			memcpy(&i, VARDATA_ANY(n), 6);
			return (i<<16)>>16;
		}
		case VARHDRSZ + 7:
		{
			int64_t i;
			memcpy(&i, VARDATA_ANY(n), 7);
			return (i<<8)>>8;
		}
		case VARHDRSZ + 8:
		{
			int64_t i;
			memcpy(&i, VARDATA_ANY(n), 8);
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
	PG_RETURN_POINTER(number_from_int64(atol(str)));
}

PG_FUNCTION_INFO_V1(number_out);

Datum
number_out(PG_FUNCTION_ARGS)
{
	Number  *n = (Number *) PG_GETARG_VARLENA_P(0);
	PG_RETURN_CSTRING(psprintf("%ld", number_to_int64(n)));
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
