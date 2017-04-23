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
