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

-- packed representation
SELECT n1, n2, pg_column_size(n1), pg_column_size(n2) FROM num;

-- casts
SELECT number(1); -- explicit call
SELECT 1::number; -- cast from int
SELECT 549755813887::number; -- cast from bigint
SELECT 1::number + 2::number; -- implicit cast to bigint

-- test number-number comparisons
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

-- test number-bigint comparisons
WITH
  va(a) AS (VALUES ('-1'::number), ('0'::number), ('1'::number)),
  vb(b) AS (VALUES ('-1'::bigint), ('0'::bigint), ('1'::bigint))
SELECT
  a, b,
  CASE WHEN number_bigint_cmp(a, b) < 0 THEN '<'
       WHEN number_bigint_cmp(a, b) = 0 THEN '='
       WHEN number_bigint_cmp(a, b) > 0 THEN '>'
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
EXPLAIN (COSTS OFF) SELECT * FROM numtab WHERE num = 1000::bigint;
EXPLAIN (COSTS OFF) SELECT * FROM numtab WHERE num = 1000::int;
