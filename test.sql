CREATE TEMP TABLE ints    (i1 int,    i2 int,    i3 int,    i4 int,    i5 int,    i6 int,    i7 int,    i8 int   );
CREATE TEMP TABLE bigints (i1 bigint, i2 bigint, i3 bigint, i4 bigint, i5 bigint, i6 bigint, i7 bigint, i8 bigint);
CREATE TEMP TABLE numbers (i1 number, i2 number, i3 number, i4 number, i5 number, i6 number, i7 number, i8 number);

\set n1 1
\set n2 i

INSERT INTO ints    SELECT :n1, :n2, :n1, :n2, :n1, :n2, :n1, :n2 FROM generate_series(1, 100000) g(i);
INSERT INTO bigints SELECT :n1, :n2, :n1, :n2, :n1, :n2, :n1, :n2 FROM generate_series(1, 100000) g(i);
INSERT INTO numbers SELECT :n1, :n2, :n1, :n2, :n1, :n2, :n1, :n2 FROM generate_series(1, 100000) g(i);

\dt+
