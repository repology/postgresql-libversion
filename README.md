# postgresql-libversion

[![Build Status](https://travis-ci.org/repology/postgresql-libversion.svg?branch=master)](https://travis-ci.org/repology/postgresql-libversion)

PostgreSQL extension with support for version string comparison through [libversion](https://github.com/repology/libversion).

## API

The extension implements:

* `version_compare2(text, text)` function which takes two strings, compares
  them as versions and returns integer -1 if second version is greater, 1
  if first version is greater and 0 if versions are equal.
* `version_compare4(text, text, int, int)`, which does the same, additionally
  allowing to specify flags for either side of comparison to tune it.
  See [libversion documentation](https://github.com/repology/libversion#api)
  for complete description of flags. Here, flag values are provided as functions:
  * `VERSIONFLAG_P_IS_PATCH()`,
  * `VERSIONFLAG_ANY_IS_PATCH()`
* `versiontext` type which behaves just like `text`, but compares
  as version strings.

## Synopsis

```
postgres=# CREATE EXTENSION libversion;
CREATE EXTENSION
postgres=# SELECT version_compare2('1.10', '1.2');
1
postgres=# SELECT version_compare2('1.0', '1.0.0');
0
postgres=# SELECT version_compare4('1.0p1', '1.0', VERSIONFLAG_P_IS_PATCH(), 0);
1
postgres=# SELECT '1.10'::versiontext > '1.2'::versiontext;
t
postgres=# SELECT '1.0'::versiontext = '1.0.0'::versiontext;
t
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
* Contains code from PostgreSQL 9.6 citext extension

## License

[MIT](COPYING)
