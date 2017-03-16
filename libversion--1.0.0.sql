\echo Use "CREATE EXTENSION libversion" to load this file. \quit

CREATE FUNCTION version_compare(text, text) RETURNS integer
AS '$libdir/libversion'
LANGUAGE C IMMUTABLE STRICT;
