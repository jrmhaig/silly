BEGIN;

SELECT tap.plan(2);

SELECT tap.eq(CellShouldSurvive(2), TRUE, 'Live cell with 2 neighbours lives');
SELECT tap.eq(CellShouldSurvive(3), TRUE, 'Live cell with 3 neighbours lives');

CALL tap.finish();
ROLLBACK;
