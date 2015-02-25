BEGIN;

SELECT tap.plan(5);

SELECT tap.eq(CellShouldSurvive(4), FALSE, 'Live cell with 4 neighbours dies');
SELECT tap.eq(CellShouldSurvive(5), FALSE, 'Live cell with 5 neighbours dies');
SELECT tap.eq(CellShouldSurvive(6), FALSE, 'Live cell with 6 neighbours dies');
SELECT tap.eq(CellShouldSurvive(7), FALSE, 'Live cell with 7 neighbours dies');
SELECT tap.eq(CellShouldSurvive(8), FALSE, 'Live cell with 8 neighbours dies');

CALL tap.finish();
ROLLBACK;
