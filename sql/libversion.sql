CREATE EXTENSION libversion;

--
-- Test standalone functions
--

-- version_compare_simple
SELECT version_compare_simple('0.1', '1.0') AS t;
SELECT version_compare_simple('1.0', '0.1') AS t;
SELECT version_compare_simple('1.0', '1.0') AS t;

SELECT version_compare_simple('1.0', '1.0.0') AS t;
SELECT version_compare_simple('1.0', '1.0a') AS t;
SELECT version_compare_simple('1.0', '1..0') AS t;

--
-- Test type
--

-- =
SELECT '1.0'::versiontext = '1.0'::versiontext AS t;
SELECT '1.0'::versiontext = '1.0.0'::versiontext AS t;
SELECT '1.0'::versiontext = '1..0'::versiontext AS t;
SELECT '1.0'::versiontext = '0.1'::versiontext AS f;

-- <>
SELECT '1.0'::versiontext <> '1.0'::versiontext AS f;
SELECT '1.0'::versiontext <> '1.0.0'::versiontext AS f;
SELECT '1.0'::versiontext <> '1..0'::versiontext AS f;
SELECT '1.0'::versiontext <> '0.1'::versiontext AS t;

-- <
SELECT '1.0'::versiontext < '1.00'::versiontext AS f;
SELECT '1.0'::versiontext < '1.010'::versiontext AS t;

-- <=
SELECT '1.0'::versiontext <= '1.00'::versiontext AS t;
SELECT '1.0'::versiontext <= '1.010'::versiontext AS t;

-- >
SELECT '1.0'::versiontext > '1.00'::versiontext AS f;
SELECT '1.0'::versiontext > '1.010'::versiontext AS f;

-- >=
SELECT '1.0'::versiontext >= '1.00'::versiontext AS t;
SELECT '1.0'::versiontext >= '1.010'::versiontext AS f;

-- implicit conversion to text
SELECT '1.0'::versiontext = '1.0'::text AS t;
SELECT '1.0.0'::versiontext = '1.0'::text AS f; -- text wins
SELECT '1.0.0'::text = '1.0'::versiontext AS f; -- text wins

-- test aggregate functions and sort ordering
CREATE TEMP TABLE srt (
   ver versiontext PRIMARY KEY
);

INSERT INTO srt (ver)
VALUES ('1.100'), ('1.20'), ('1.3'), ('1.0patch10'), ('1.0patch2'), ('1.0alpha1'), ('1.0beta1'), ('1.0pre1'), ('0.9'), ('0.10'), ('1.0'), ('1.0a'), ('1.0b');

-- min/max
SELECT MIN(ver) AS "0.9" FROM srt;
SELECT MAX(ver) AS "1.100" FROM srt;

-- sorting
set enable_seqscan = off;
SELECT ver FROM srt ORDER BY ver;
reset enable_seqscan;
set enable_indexscan = off;
SELECT ver FROM srt ORDER BY ver;
reset enable_indexscan;
set enable_seqscan = off;
SELECT ver FROM srt ORDER BY ver DESC;
reset enable_seqscan;
set enable_indexscan = off;
SELECT ver FROM srt ORDER BY ver DESC;
reset enable_indexscan;
