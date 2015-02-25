BEGIN;

SELECT tap.plan(2);

SELECT tap.eq(CellShouldSurvive(0), FALSE, 'Live cell with no neighbours dies');
SELECT tap.eq(CellShouldSurvive(1), FALSE, 'Live cell with 1 neighbours dies');

CALL tap.finish();
ROLLBACK;
