\echo Use "CREATE EXTENSION libversion" to load this file. \quit

--
-- Standalone functions
--

CREATE FUNCTION version_compare_simple(text, text)
RETURNS int4
AS '$libdir/libversion', 'wrap_version_compare_simple'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

--
-- Custom type support
--

--
-- Most I/O functions, and a few others, piggyback on the "text" type
-- functions via the implicit cast to text.
--

--
-- Shell type to keep things a bit quieter.
--

CREATE TYPE versiontext;

--
--  Input and output functions.
--
CREATE FUNCTION versiontextin(cstring)
RETURNS versiontext
AS 'textin'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontextout(versiontext)
RETURNS cstring
AS 'textout'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontextrecv(internal)
RETURNS versiontext
AS 'textrecv'
LANGUAGE internal STABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontextsend(versiontext)
RETURNS bytea
AS 'textsend'
LANGUAGE internal STABLE STRICT PARALLEL SAFE;

--
--  The type itself.
--

CREATE TYPE versiontext (
    INPUT          = versiontextin,
    OUTPUT         = versiontextout,
    RECEIVE        = versiontextrecv,
    SEND           = versiontextsend,
    INTERNALLENGTH = VARIABLE,
    STORAGE        = extended,
    -- make it a non-preferred member of string type category
    CATEGORY       = 'S',
    PREFERRED      = false,
    COLLATABLE     = true
);

--
-- Type casting functions for those situations where the I/O casts don't
-- automatically kick in.
--

CREATE FUNCTION versiontext(bpchar)
RETURNS versiontext
AS 'rtrim1'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontext(boolean)
RETURNS versiontext
AS 'booltext'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontext(inet)
RETURNS versiontext
AS 'network_show'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

--
--  Implicit and assignment type casts.
--

CREATE CAST (versiontext AS text)    WITHOUT FUNCTION AS IMPLICIT;
CREATE CAST (versiontext AS varchar) WITHOUT FUNCTION AS IMPLICIT;
CREATE CAST (versiontext AS bpchar)  WITHOUT FUNCTION AS ASSIGNMENT;
CREATE CAST (text AS versiontext)    WITHOUT FUNCTION AS ASSIGNMENT;
CREATE CAST (varchar AS versiontext) WITHOUT FUNCTION AS ASSIGNMENT;
CREATE CAST (bpchar AS versiontext)  WITH FUNCTION versiontext(bpchar)  AS ASSIGNMENT;

--
-- Operator Functions.
--

CREATE FUNCTION versiontext_eq( versiontext, versiontext )
RETURNS bool
AS '$libdir/libversion'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontext_ne( versiontext, versiontext )
RETURNS bool
AS '$libdir/libversion'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontext_lt( versiontext, versiontext )
RETURNS bool
AS '$libdir/libversion'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontext_le( versiontext, versiontext )
RETURNS bool
AS '$libdir/libversion'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontext_gt( versiontext, versiontext )
RETURNS bool
AS '$libdir/libversion'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontext_ge( versiontext, versiontext )
RETURNS bool
AS '$libdir/libversion'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

--
-- Operators.
--

CREATE OPERATOR = (
    LEFTARG    = VERSIONTEXT,
    RIGHTARG   = VERSIONTEXT,
    COMMUTATOR = =,
    NEGATOR    = <>,
    PROCEDURE  = versiontext_eq,
    RESTRICT   = eqsel,
    JOIN       = eqjoinsel,
    HASHES,
    MERGES
);

CREATE OPERATOR <> (
    LEFTARG    = VERSIONTEXT,
    RIGHTARG   = VERSIONTEXT,
    NEGATOR    = =,
    COMMUTATOR = <>,
    PROCEDURE  = versiontext_ne,
    RESTRICT   = neqsel,
    JOIN       = neqjoinsel
);

CREATE OPERATOR < (
    LEFTARG    = VERSIONTEXT,
    RIGHTARG   = VERSIONTEXT,
    NEGATOR    = >=,
    COMMUTATOR = >,
    PROCEDURE  = versiontext_lt,
    RESTRICT   = scalarltsel,
    JOIN       = scalarltjoinsel
);

CREATE OPERATOR <= (
    LEFTARG    = VERSIONTEXT,
    RIGHTARG   = VERSIONTEXT,
    NEGATOR    = >,
    COMMUTATOR = >=,
    PROCEDURE  = versiontext_le,
    RESTRICT   = scalarltsel,
    JOIN       = scalarltjoinsel
);

CREATE OPERATOR >= (
    LEFTARG    = VERSIONTEXT,
    RIGHTARG   = VERSIONTEXT,
    NEGATOR    = <,
    COMMUTATOR = <=,
    PROCEDURE  = versiontext_ge,
    RESTRICT   = scalargtsel,
    JOIN       = scalargtjoinsel
);

CREATE OPERATOR > (
    LEFTARG    = VERSIONTEXT,
    RIGHTARG   = VERSIONTEXT,
    NEGATOR    = <=,
    COMMUTATOR = <,
    PROCEDURE  = versiontext_gt,
    RESTRICT   = scalargtsel,
    JOIN       = scalargtjoinsel
);

--
-- Support functions for indexing.
--

CREATE FUNCTION versiontext_cmp(versiontext, versiontext)
RETURNS int4
AS '$libdir/libversion'
LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION versiontext_hash(versiontext)
RETURNS int4
AS '$libdir/libversion'
LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;

--
-- The btree indexing operator class.
--

CREATE OPERATOR CLASS versiontext_ops
DEFAULT FOR TYPE VERSIONTEXT USING btree AS
    OPERATOR    1   <  (versiontext, versiontext),
    OPERATOR    2   <= (versiontext, versiontext),
    OPERATOR    3   =  (versiontext, versiontext),
    OPERATOR    4   >= (versiontext, versiontext),
    OPERATOR    5   >  (versiontext, versiontext),
    FUNCTION    1   versiontext_cmp(versiontext, versiontext);

--
-- The hash indexing operator class.
--

CREATE OPERATOR CLASS versiontext_ops
DEFAULT FOR TYPE versiontext USING hash AS
    OPERATOR    1   =  (versiontext, versiontext),
    FUNCTION    1   versiontext_hash(versiontext);

--
-- Aggregates.
--

CREATE FUNCTION versiontext_smaller(versiontext, versiontext)
RETURNS versiontext
AS '$libdir/libversion'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION versiontext_larger(versiontext, versiontext)
RETURNS versiontext
AS '$libdir/libversion'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE AGGREGATE min(versiontext)  (
    SFUNC = versiontext_smaller,
    STYPE = versiontext,
    SORTOP = <,
    PARALLEL = SAFE,
    COMBINEFUNC = versiontext_smaller
);

CREATE AGGREGATE max(versiontext)  (
    SFUNC = versiontext_larger,
    STYPE = versiontext,
    SORTOP = >,
    PARALLEL = SAFE,
    COMBINEFUNC = versiontext_larger
);

--
-- VERSIONTEXT pattern matching.
--

CREATE FUNCTION texticlike(versiontext, versiontext)
RETURNS bool AS 'texticlike'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION texticnlike(versiontext, versiontext)
RETURNS bool AS 'texticnlike'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION texticregexeq(versiontext, versiontext)
RETURNS bool AS 'texticregexeq'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION texticregexne(versiontext, versiontext)
RETURNS bool AS 'texticregexne'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR ~ (
    PROCEDURE = texticregexeq,
    LEFTARG   = versiontext,
    RIGHTARG  = versiontext,
    NEGATOR   = !~,
    RESTRICT  = icregexeqsel,
    JOIN      = icregexeqjoinsel
);

CREATE OPERATOR ~* (
    PROCEDURE = texticregexeq,
    LEFTARG   = versiontext,
    RIGHTARG  = versiontext,
    NEGATOR   = !~*,
    RESTRICT  = icregexeqsel,
    JOIN      = icregexeqjoinsel
);

CREATE OPERATOR !~ (
    PROCEDURE = texticregexne,
    LEFTARG   = versiontext,
    RIGHTARG  = versiontext,
    NEGATOR   = ~,
    RESTRICT  = icregexnesel,
    JOIN      = icregexnejoinsel
);

CREATE OPERATOR !~* (
    PROCEDURE = texticregexne,
    LEFTARG   = versiontext,
    RIGHTARG  = versiontext,
    NEGATOR   = ~*,
    RESTRICT  = icregexnesel,
    JOIN      = icregexnejoinsel
);

CREATE OPERATOR ~~ (
    PROCEDURE = texticlike,
    LEFTARG   = versiontext,
    RIGHTARG  = versiontext,
    NEGATOR   = !~~,
    RESTRICT  = iclikesel,
    JOIN      = iclikejoinsel
);

CREATE OPERATOR ~~* (
    PROCEDURE = texticlike,
    LEFTARG   = versiontext,
    RIGHTARG  = versiontext,
    NEGATOR   = !~~*,
    RESTRICT  = iclikesel,
    JOIN      = iclikejoinsel
);

CREATE OPERATOR !~~ (
    PROCEDURE = texticnlike,
    LEFTARG   = versiontext,
    RIGHTARG  = versiontext,
    NEGATOR   = ~~,
    RESTRICT  = icnlikesel,
    JOIN      = icnlikejoinsel
);

CREATE OPERATOR !~~* (
    PROCEDURE = texticnlike,
    LEFTARG   = versiontext,
    RIGHTARG  = versiontext,
    NEGATOR   = ~~*,
    RESTRICT  = icnlikesel,
    JOIN      = icnlikejoinsel
);

--
-- Matching versiontext to text.
--

CREATE FUNCTION texticlike(versiontext, text)
RETURNS bool AS 'texticlike'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION texticnlike(versiontext, text)
RETURNS bool AS 'texticnlike'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION texticregexeq(versiontext, text)
RETURNS bool AS 'texticregexeq'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION texticregexne(versiontext, text)
RETURNS bool AS 'texticregexne'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR ~ (
    PROCEDURE = texticregexeq,
    LEFTARG   = versiontext,
    RIGHTARG  = text,
    NEGATOR   = !~,
    RESTRICT  = icregexeqsel,
    JOIN      = icregexeqjoinsel
);

CREATE OPERATOR ~* (
    PROCEDURE = texticregexeq,
    LEFTARG   = versiontext,
    RIGHTARG  = text,
    NEGATOR   = !~*,
    RESTRICT  = icregexeqsel,
    JOIN      = icregexeqjoinsel
);

CREATE OPERATOR !~ (
    PROCEDURE = texticregexne,
    LEFTARG   = versiontext,
    RIGHTARG  = text,
    NEGATOR   = ~,
    RESTRICT  = icregexnesel,
    JOIN      = icregexnejoinsel
);

CREATE OPERATOR !~* (
    PROCEDURE = texticregexne,
    LEFTARG   = versiontext,
    RIGHTARG  = text,
    NEGATOR   = ~*,
    RESTRICT  = icregexnesel,
    JOIN      = icregexnejoinsel
);

CREATE OPERATOR ~~ (
    PROCEDURE = texticlike,
    LEFTARG   = versiontext,
    RIGHTARG  = text,
    NEGATOR   = !~~,
    RESTRICT  = iclikesel,
    JOIN      = iclikejoinsel
);

CREATE OPERATOR ~~* (
    PROCEDURE = texticlike,
    LEFTARG   = versiontext,
    RIGHTARG  = text,
    NEGATOR   = !~~*,
    RESTRICT  = iclikesel,
    JOIN      = iclikejoinsel
);

CREATE OPERATOR !~~ (
    PROCEDURE = texticnlike,
    LEFTARG   = versiontext,
    RIGHTARG  = text,
    NEGATOR   = ~~,
    RESTRICT  = icnlikesel,
    JOIN      = icnlikejoinsel
);

CREATE OPERATOR !~~* (
    PROCEDURE = texticnlike,
    LEFTARG   = versiontext,
    RIGHTARG  = text,
    NEGATOR   = ~~*,
    RESTRICT  = icnlikesel,
    JOIN      = icnlikejoinsel
);

--
-- Matching versiontext in string comparison functions.
-- XXX TODO Ideally these would be implemented in C.
--

CREATE FUNCTION regexp_matches( versiontext, versiontext ) RETURNS SETOF TEXT[] AS $$
    SELECT pg_catalog.regexp_matches( $1::pg_catalog.text, $2::pg_catalog.text );
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE ROWS 1;

CREATE FUNCTION regexp_matches( versiontext, versiontext, text ) RETURNS SETOF TEXT[] AS $$
    SELECT pg_catalog.regexp_matches( $1::pg_catalog.text, $2::pg_catalog.text, $3 )
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE ROWS 10;

CREATE FUNCTION regexp_replace( versiontext, versiontext, text ) returns TEXT AS $$
    SELECT pg_catalog.regexp_replace( $1::pg_catalog.text, $2::pg_catalog.text, $3 );
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION regexp_replace( versiontext, versiontext, text, text ) returns TEXT AS $$
    SELECT pg_catalog.regexp_replace( $1::pg_catalog.text, $2::pg_catalog.text, $3 )
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION regexp_split_to_array( versiontext, versiontext ) RETURNS TEXT[] AS $$
    SELECT pg_catalog.regexp_split_to_array( $1::pg_catalog.text, $2::pg_catalog.text )
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION regexp_split_to_array( versiontext, versiontext, text ) RETURNS TEXT[] AS $$
    SELECT pg_catalog.regexp_split_to_array( $1::pg_catalog.text, $2::pg_catalog.text, $3 )
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION regexp_split_to_table( versiontext, versiontext ) RETURNS SETOF TEXT AS $$
    SELECT pg_catalog.regexp_split_to_table( $1::pg_catalog.text, $2::pg_catalog.text );
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION regexp_split_to_table( versiontext, versiontext, text ) RETURNS SETOF TEXT AS $$
    SELECT pg_catalog.regexp_split_to_table( $1::pg_catalog.text, $2::pg_catalog.text, $3 )
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION strpos( versiontext, versiontext ) RETURNS INT AS $$
    SELECT pg_catalog.strpos( $1::pg_catalog.text, $2::pg_catalog.text );
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION replace( versiontext, versiontext, versiontext ) RETURNS TEXT AS $$
    SELECT pg_catalog.regexp_replace( $1::pg_catalog.text, $2::pg_catalog.text, $3::pg_catalog.text );
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION split_part( versiontext, versiontext, int ) RETURNS TEXT AS $$
    SELECT pg_catalog.split_part( $1::pg_catalog.text, $2::pg_catalog.text, $3 )
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION translate( versiontext, versiontext, text ) RETURNS TEXT AS $$
    SELECT pg_catalog.translate( $1::pg_catalog.text, $2::pg_catalog.text, $3 )
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;
