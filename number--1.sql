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

-- type definition

CREATE TYPE number;

CREATE OR REPLACE FUNCTION number_in(cstring)
	RETURNS number
	AS 'MODULE_PATHNAME'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION number_out(number)
	RETURNS cstring
	AS 'MODULE_PATHNAME'
	LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE number (
	internallength = variable,
	input = number_in,
	output = number_out,
	category = 'N',
	storage = external
);

-- constructors

CREATE FUNCTION number(int)
	RETURNS number
	AS 'MODULE_PATHNAME', 'number_from_int'
	LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION number(bigint)
	RETURNS number
	AS 'MODULE_PATHNAME', 'number_from_bigint'
	LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION number_to_bigint(number)
	RETURNS bigint
	AS 'MODULE_PATHNAME', 'number_to_bigint'
	LANGUAGE C IMMUTABLE STRICT;

-- casts

CREATE CAST (int AS number)
	WITH FUNCTION number(int)
	AS ASSIGNMENT;

CREATE CAST (bigint AS number)
	WITH FUNCTION number(bigint)
	AS ASSIGNMENT;

CREATE CAST (number AS bigint)
	WITH FUNCTION number_to_bigint(number)
	AS IMPLICIT;

-- comparisons

CREATE FUNCTION number_lt(number, number) RETURNS bool
   AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_le(number, number) RETURNS bool
   AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_eq(number, number) RETURNS bool
   AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_ne(number, number) RETURNS bool
   AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_ge(number, number) RETURNS bool
   AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_gt(number, number) RETURNS bool
   AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR < (
	leftarg = number, rightarg = number, procedure = number_lt,
	commutator = > , negator = >= ,
	restrict = scalarltsel, join = scalarltjoinsel
);
CREATE OPERATOR <= (
	leftarg = number, rightarg = number, procedure = number_le,
	commutator = >= , negator = > ,
	restrict = scalarltsel, join = scalarltjoinsel
);
CREATE OPERATOR = (
	leftarg = number, rightarg = number, procedure = number_eq,
	commutator = = , negator = <> ,
	restrict = eqsel, join = eqjoinsel
);
CREATE OPERATOR <> (
	leftarg = number, rightarg = number, procedure = number_ne,
	commutator = <> , negator = = ,
	restrict = neqsel, join = neqjoinsel
);
CREATE OPERATOR >= (
	leftarg = number, rightarg = number, procedure = number_ge,
	commutator = <= , negator = < ,
	restrict = scalargtsel, join = scalargtjoinsel
);
CREATE OPERATOR > (
	leftarg = number, rightarg = number, procedure = number_gt,
	commutator = < , negator = <= ,
	restrict = scalargtsel, join = scalargtjoinsel
);

CREATE FUNCTION number_cmp(number, number)
	RETURNS int4
	AS 'MODULE_PATHNAME'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS number_ops
	DEFAULT FOR TYPE number USING btree AS
		OPERATOR 1 < ,
		OPERATOR 2 <= ,
		OPERATOR 3 = ,
		OPERATOR 4 >= ,
		OPERATOR 5 > ,
		FUNCTION 1 number_cmp(number, number);

