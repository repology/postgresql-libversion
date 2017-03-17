# postgres-libversion

[![Build Status](https://travis-ci.org/repology/postgresql-libversion.svg?branch=master)](https://travis-ci.org/repology/postgresql-libversion)

PostgreSQL extension to support version comparison through [libversion](https://github.com/repology/libversion).

## API

The extension exposes whole libversion
[API](https://github.com/repology/libversion#api) which is currently
a singe function taking two version strings as text arguments and
returning integer -1 if second version is greater, 1 if first version
is greated and 0 if versions are equal.

```
postgres=# \df version_compare_simple
                                 List of functions
 Schema |          Name          | Result data type | Argument data types |  Type
--------+------------------------+------------------+---------------------+--------
 public | version_compare_simple | integer          | text, text          | normal
(1 row)
```

## Synopsis

```
postgres=# create extension libversion;
CREATE EXTENSION
postgres=# select version_compare_simple('0.9', '1.0');
 version_compare_simple
------------------------
                     -1
(1 row)
```

## Installation

The extension uses standard PostgreSQL Makefile infrastructure.

Run

```
make && make install
```

to build and install. The build requires
[libversion](https://github.com/repology/libversion) and
[pkgconfig](https://www.freedesktop.org/wiki/Software/pkg-config/)
installed.

## Author

* [Dmitry Marakasov](https://github.com/AMDmi3) <amdmi3@amdmi3.ru>

## License

[MIT](COPYING)
