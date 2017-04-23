postgresql-number
=================
Christoph Berg <cb@df7cb.de>

*Variable-width integer datatype for PostgreSQL*

The PostgreSQL `number` datatype stores 64-bit integer values efficiently using
a variable-length representation on disk. Depending on the value, between 1
(for zero) and 9 bytes (for values beyond +-2^55) are used.

The datatype does not provide any operators. Instead, casts from `int` and
`bigint`, and to `bigint` (implicit) are provided for interfacing with the
PostgreSQL type system.

Example
-------
```
CREATE EXTENSION number;

CREATE TABLE num (
	n1 number,
	n2 number
);

INSERT INTO num
	VALUES (NULL, '0'),
		('-1', '1'),
		('-128', '127'),
		('-129', '128'),
		('-32768', '32767'),
		('-32769', '32768'),
		('-8388608', '8388607'),
		('-8388609', '8388608'),
		('-2147483648', '2147483647'),
		('-2147483649', '2147483648'),
		('-549755813888', '549755813887'),
		('-549755813889', '549755813888'),
		('-140737488355328', '140737488355327'),
		('-140737488355329', '140737488355328'),
		('-36028797018963968', '36028797018963967'),
		('-36028797018963969', '36028797018963968'),
		('-9223372036854775808', '9223372036854775807');

SELECT n1, n2, pg_column_size(n1), pg_column_size(n2) FROM num;
          n1          |         n2          | pg_column_size | pg_column_size
----------------------+---------------------+----------------+----------------
                      | 0                   |                |              1
 -1                   | 1                   |              2 |              2
 -128                 | 127                 |              2 |              2
 -129                 | 128                 |              3 |              3
 -32768               | 32767               |              3 |              3
 -32769               | 32768               |              4 |              4
 -8388608             | 8388607             |              4 |              4
 -8388609             | 8388608             |              5 |              5
 -2147483648          | 2147483647          |              5 |              5
 -2147483649          | 2147483648          |              6 |              6
 -549755813888        | 549755813887        |              6 |              6
 -549755813889        | 549755813888        |              7 |              7
 -140737488355328     | 140737488355327     |              7 |              7
 -140737488355329     | 140737488355328     |              8 |              8
 -36028797018963968   | 36028797018963967   |              8 |              8
 -36028797018963969   | 36028797018963968   |              9 |              9
 -9223372036854775808 | 9223372036854775807 |              9 |              9
(17 rows)
```

License
-------
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
