CREATE EXTENSION libversion;

-- Test comparison
SELECT version_compare_simple('0.1', '1.0');
SELECT version_compare_simple('1.0', '0.1');
SELECT version_compare_simple('1.0', '1.0');

SELECT version_compare_simple('1.0', '1.0.0');
SELECT version_compare_simple('1.0', '1.0a');
SELECT version_compare_simple('1.0', '1..0');
