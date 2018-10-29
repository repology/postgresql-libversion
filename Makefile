EXTENSION = libversion
DATA = libversion--1.0.0.sql libversion--1.0.0--1.1.0.sql libversion--1.1.0--1.2.0.sql libversion--1.2.0.sql

MODULE_big = libversion
REGRESS = libversion

PG_CPPFLAGS = `pkg-config --cflags libversion`
SHLIB_LINK = `pkg-config --libs libversion`

OBJS = libversion.o

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
