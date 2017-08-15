postgresql-number
=================
Christoph Berg <cb@df7cb.de>

*Variable-width integer datatype for PostgreSQL*

[![Build Status](https://travis-ci.org/ChristophBerg/postgresql-number.svg?branch=master)](https://travis-ci.org/ChristophBerg/postgresql-number)

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
		('-128', '128'),
		('-129', '129'),
		('-32896', '32896'),
		('-32897', '32897'),
		('-8421504', '8421504'),
		('-8421505', '8421505'),
		('-2155905152', '2155905152'),
		('-2155905153', '2155905153'),
		('-551911719040', '551911719040'),
		('-551911719041', '551911719041'),
		('-141289400074368', '141289400074368'),
		('-141289400074369', '141289400074369'),
		('-36170086419038336', '36170086419038336'),
		('-36170086419038337', '36170086419038337'),
		('-9223372036854775808', '9223372036854775807');

SELECT n1, n2, pg_column_size(n1), pg_column_size(n2) FROM num;
          n1          |         n2          | pg_column_size | pg_column_size
----------------------+---------------------+----------------+----------------
                      | 0                   |                |              1
 -1                   | 1                   |              2 |              2
 -128                 | 128                 |              2 |              2
 -129                 | 129                 |              3 |              3
 -32896               | 32896               |              3 |              3
 -32897               | 32897               |              4 |              4
 -8421504             | 8421504             |              4 |              4
 -8421505             | 8421505             |              5 |              5
 -2155905152          | 2155905152          |              5 |              5
 -2155905153          | 2155905153          |              6 |              6
 -551911719040        | 551911719040        |              6 |              6
 -551911719041        | 551911719041        |              7 |              7
 -141289400074368     | 141289400074368     |              7 |              7
 -141289400074369     | 141289400074369     |              8 |              8
 -36170086419038336   | 36170086419038336   |              8 |              8
 -36170086419038337   | 36170086419038337   |              9 |              9
 -9223372036854775808 | 9223372036854775807 |              9 |              9
(17 rows)
```

License
-------
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
