EXTENSION = libversion
DATA = libversion--1.0.0.sql
MODULE_big = libversion

PG_CPPFLAGS = `pkg-config --cflags libversion` -I bar
SHLIB_LINK += `pkg-config --libs libversion` -L foo

OBJS = libversion.o

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
