MODULES = number
EXTENSION = number
DATA = number--1.sql
REGRESS = extension number

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

number.o: number.c number.h
