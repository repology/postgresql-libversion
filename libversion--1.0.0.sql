\echo Use "CREATE EXTENSION libversion" to load this file. \quit

CREATE FUNCTION version_compare_simple(text, text) RETURNS integer
AS '$libdir/libversion', 'wrap_version_compare_simple'
LANGUAGE C IMMUTABLE STRICT;
