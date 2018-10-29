\echo Use "ALTER EXTENSION libversion UPDATE TO '1.2'" to load this file. \quit

CREATE FUNCTION version_compare2(text, text)
RETURNS int4
AS '$libdir/libversion', 'wrap_version_compare2'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION version_compare4(text, text, int4, int4)
RETURNS int4
AS '$libdir/libversion', 'wrap_version_compare4'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION VERSIONFLAG_P_IS_PATCH()
RETURNS int4
AS '$libdir/libversion', 'wrap_VERSIONFLAG_P_IS_PATCH'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION VERSIONFLAG_ANY_IS_PATCH()
RETURNS int4
AS '$libdir/libversion', 'wrap_VERSIONFLAG_ANY_IS_PATCH'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
