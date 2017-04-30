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

-- number-number comparisons

CREATE FUNCTION number_lt(number, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_le(number, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_eq(number, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_ne(number, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_ge(number, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_gt(number, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR <  (leftarg = number, rightarg = number, procedure = number_lt, commutator = >,  negator = >=, restrict = scalarltsel, join = scalarltjoinsel);
CREATE OPERATOR <= (leftarg = number, rightarg = number, procedure = number_le, commutator = >=, negator = >,  restrict = scalarltsel, join = scalarltjoinsel);
CREATE OPERATOR =  (leftarg = number, rightarg = number, procedure = number_eq, commutator = =,  negator = <>, restrict = eqsel,       join = eqjoinsel);
CREATE OPERATOR <> (leftarg = number, rightarg = number, procedure = number_ne, commutator = <>, negator = =,  restrict = neqsel,      join = neqjoinsel);
CREATE OPERATOR >= (leftarg = number, rightarg = number, procedure = number_ge, commutator = <=, negator = <,  restrict = scalargtsel, join = scalargtjoinsel);
CREATE OPERATOR >  (leftarg = number, rightarg = number, procedure = number_gt, commutator = <,  negator = <=, restrict = scalargtsel, join = scalargtjoinsel);

CREATE FUNCTION number_cmp(number, number) RETURNS int4 AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR FAMILY number_ops_family USING btree;

CREATE OPERATOR CLASS number_ops
	DEFAULT FOR TYPE number USING btree FAMILY number_ops_family AS
		OPERATOR 1 < ,
		OPERATOR 2 <= ,
		OPERATOR 3 = ,
		OPERATOR 4 >= ,
		OPERATOR 5 > ,
		FUNCTION 1 number_cmp(number, number);

-- number-bigint comparisons

CREATE FUNCTION number_bigint_lt(number, bigint) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_bigint_le(number, bigint) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_bigint_eq(number, bigint) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_bigint_ne(number, bigint) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_bigint_ge(number, bigint) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_bigint_gt(number, bigint) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR <  (leftarg = number, rightarg = bigint, procedure = number_bigint_lt, commutator = >,  negator = >=, restrict = scalarltsel, join = scalarltjoinsel);
CREATE OPERATOR <= (leftarg = number, rightarg = bigint, procedure = number_bigint_le, commutator = >=, negator = >,  restrict = scalarltsel, join = scalarltjoinsel);
CREATE OPERATOR =  (leftarg = number, rightarg = bigint, procedure = number_bigint_eq, commutator = =,  negator = <>, restrict = eqsel,       join = eqjoinsel);
CREATE OPERATOR <> (leftarg = number, rightarg = bigint, procedure = number_bigint_ne, commutator = <>, negator = =,  restrict = neqsel,      join = neqjoinsel);
CREATE OPERATOR >= (leftarg = number, rightarg = bigint, procedure = number_bigint_ge, commutator = <=, negator = <,  restrict = scalargtsel, join = scalargtjoinsel);
CREATE OPERATOR >  (leftarg = number, rightarg = bigint, procedure = number_bigint_gt, commutator = <,  negator = <=, restrict = scalargtsel, join = scalargtjoinsel);

CREATE FUNCTION number_bigint_cmp(number, bigint) RETURNS int4 AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

-- bigint-number comparisons

CREATE FUNCTION bigint_number_lt(bigint, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION bigint_number_le(bigint, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION bigint_number_eq(bigint, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION bigint_number_ne(bigint, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION bigint_number_ge(bigint, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION bigint_number_gt(bigint, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR <  (leftarg = bigint, rightarg = number, procedure = bigint_number_lt, commutator = >,  negator = >=, restrict = scalarltsel, join = scalarltjoinsel);
CREATE OPERATOR <= (leftarg = bigint, rightarg = number, procedure = bigint_number_le, commutator = >=, negator = >,  restrict = scalarltsel, join = scalarltjoinsel);
CREATE OPERATOR =  (leftarg = bigint, rightarg = number, procedure = bigint_number_eq, commutator = =,  negator = <>, restrict = eqsel,       join = eqjoinsel);
CREATE OPERATOR <> (leftarg = bigint, rightarg = number, procedure = bigint_number_ne, commutator = <>, negator = =,  restrict = neqsel,      join = neqjoinsel);
CREATE OPERATOR >= (leftarg = bigint, rightarg = number, procedure = bigint_number_ge, commutator = <=, negator = <,  restrict = scalargtsel, join = scalargtjoinsel);
CREATE OPERATOR >  (leftarg = bigint, rightarg = number, procedure = bigint_number_gt, commutator = <,  negator = <=, restrict = scalargtsel, join = scalargtjoinsel);

CREATE FUNCTION bigint_number_cmp(bigint, number) RETURNS int4 AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

-- number-int comparisons

CREATE FUNCTION number_int_lt(number, int) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_int_le(number, int) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_int_eq(number, int) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_int_ne(number, int) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_int_ge(number, int) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION number_int_gt(number, int) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR <  (leftarg = number, rightarg = int, procedure = number_int_lt, commutator = >,  negator = >=, restrict = scalarltsel, join = scalarltjoinsel);
CREATE OPERATOR <= (leftarg = number, rightarg = int, procedure = number_int_le, commutator = >=, negator = >,  restrict = scalarltsel, join = scalarltjoinsel);
CREATE OPERATOR =  (leftarg = number, rightarg = int, procedure = number_int_eq, commutator = =,  negator = <>, restrict = eqsel,       join = eqjoinsel);
CREATE OPERATOR <> (leftarg = number, rightarg = int, procedure = number_int_ne, commutator = <>, negator = =,  restrict = neqsel,      join = neqjoinsel);
CREATE OPERATOR >= (leftarg = number, rightarg = int, procedure = number_int_ge, commutator = <=, negator = <,  restrict = scalargtsel, join = scalargtjoinsel);
CREATE OPERATOR >  (leftarg = number, rightarg = int, procedure = number_int_gt, commutator = <,  negator = <=, restrict = scalargtsel, join = scalargtjoinsel);

CREATE FUNCTION number_int_cmp(number, int) RETURNS int4 AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

-- int-number comparisons

CREATE FUNCTION int_number_lt(int, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION int_number_le(int, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION int_number_eq(int, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION int_number_ne(int, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION int_number_ge(int, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION int_number_gt(int, number) RETURNS bool AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR <  (leftarg = int, rightarg = number, procedure = int_number_lt, commutator = >,  negator = >=, restrict = scalarltsel, join = scalarltjoinsel);
CREATE OPERATOR <= (leftarg = int, rightarg = number, procedure = int_number_le, commutator = >=, negator = >,  restrict = scalarltsel, join = scalarltjoinsel);
CREATE OPERATOR =  (leftarg = int, rightarg = number, procedure = int_number_eq, commutator = =,  negator = <>, restrict = eqsel,       join = eqjoinsel);
CREATE OPERATOR <> (leftarg = int, rightarg = number, procedure = int_number_ne, commutator = <>, negator = =,  restrict = neqsel,      join = neqjoinsel);
CREATE OPERATOR >= (leftarg = int, rightarg = number, procedure = int_number_ge, commutator = <=, negator = <,  restrict = scalargtsel, join = scalargtjoinsel);
CREATE OPERATOR >  (leftarg = int, rightarg = number, procedure = int_number_gt, commutator = <,  negator = <=, restrict = scalargtsel, join = scalargtjoinsel);

CREATE FUNCTION int_number_cmp(int, number) RETURNS int4 AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

-- operator family

ALTER OPERATOR FAMILY number_ops_family USING btree ADD
	-- number-bigint comparisons
	OPERATOR 1 <  (number, bigint),
	OPERATOR 2 <= (number, bigint),
	OPERATOR 3 =  (number, bigint),
	OPERATOR 4 >= (number, bigint),
	OPERATOR 5 >  (number, bigint),
	FUNCTION 1 number_bigint_cmp(number, bigint),

	-- bigint-number comparisons
	OPERATOR 1 <  (bigint, number),
	OPERATOR 2 <= (bigint, number),
	OPERATOR 3 =  (bigint, number),
	OPERATOR 4 >= (bigint, number),
	OPERATOR 5 >  (bigint, number),
	FUNCTION 1 bigint_number_cmp(bigint, number),

	-- number-int comparisons
	OPERATOR 1 <  (number, int),
	OPERATOR 2 <= (number, int),
	OPERATOR 3 =  (number, int),
	OPERATOR 4 >= (number, int),
	OPERATOR 5 >  (number, int),
	FUNCTION 1 number_int_cmp(number, int),

	-- int-number comparisons
	OPERATOR 1 <  (int, number),
	OPERATOR 2 <= (int, number),
	OPERATOR 3 =  (int, number),
	OPERATOR 4 >= (int, number),
	OPERATOR 5 >  (int, number),
	FUNCTION 1 int_number_cmp(int, number);

