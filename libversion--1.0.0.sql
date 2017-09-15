\echo Use "CREATE EXTENSION libversion" to load this file. \quit

--
-- Standalone functions
--

CREATE FUNCTION version_compare_simple(text, text)
RETURNS int4
AS '$libdir/libversion', 'wrap_version_compare_simple'
LANGUAGE C IMMUTABLE STRICT;
