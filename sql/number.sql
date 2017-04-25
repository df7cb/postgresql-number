-- unpacked representation
SELECT '0'::number, pg_column_size('0'::number);
SELECT '1'::number, pg_column_size('1'::number);
SELECT '-1'::number, pg_column_size('-1'::number);

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

-- packed representation
SELECT n1, n2, pg_column_size(n1), pg_column_size(n2) FROM num;

-- casts
SELECT number(1); -- explicit call
SELECT 1::number; -- cast from int
SELECT 549755813887::number; -- cast from bigint
SELECT 1::number + 2::number; -- implicit cast to bigint

-- test comparisons
WITH
  v(u) AS (VALUES ('-1'::number), ('0'::number), ('1'::number)),
  va(a) AS (SELECT * FROM v),
  vb(b) AS (SELECT * FROM v)
SELECT
  a, b,
  CASE WHEN number_cmp(a, b) < 0 THEN '<'
       WHEN number_cmp(a, b) = 0 THEN '='
       WHEN number_cmp(a, b) > 0 THEN '>'
  END AS cmp,
  a < b  AS lt, a <= b AS le,
  a = b  AS eq, a <> b AS ne,
  a >= b AS ge, a > b  AS gt
FROM
  va CROSS JOIN vb;

-- test btree index
CREATE TABLE numtab (num number);
INSERT INTO numtab SELECT generate_series(-100000, 100000);
ANALYZE numtab;
CREATE INDEX ON numtab(num);
SELECT * FROM numtab WHERE num = 1000::number;
EXPLAIN (COSTS OFF) SELECT * FROM numtab WHERE num = 1000::number;
EXPLAIN (COSTS OFF) SELECT * FROM numtab WHERE num = 1000;
