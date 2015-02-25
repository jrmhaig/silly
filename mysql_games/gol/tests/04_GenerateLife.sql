BEGIN;

SELECT tap.plan(9);

SELECT tap.eq(CellShouldBecomeAlive(0), FALSE, 'Dead cell with no neighbours remains dead');
SELECT tap.eq(CellShouldBecomeAlive(1), FALSE, 'Dead cell with 1 neighbour remains dead');
SELECT tap.eq(CellShouldBecomeAlive(2), FALSE, 'Dead cell with 2 neighbours remains dead');
SELECT tap.eq(CellShouldBecomeAlive(3), TRUE, 'Dead cell with 3 neighbours becomes alive');
SELECT tap.eq(CellShouldBecomeAlive(4), FALSE, 'Dead cell with 4 neighbours remains dead');
SELECT tap.eq(CellShouldBecomeAlive(5), FALSE, 'Dead cell with 5 neighbours remains dead');
SELECT tap.eq(CellShouldBecomeAlive(6), FALSE, 'Dead cell with 6 neighbours remains dead');
SELECT tap.eq(CellShouldBecomeAlive(7), FALSE, 'Dead cell with 7 neighbours remains dead');
SELECT tap.eq(CellShouldBecomeAlive(8), FALSE, 'Dead cell with 8 neighbours remains dead');

CALL tap.finish();
ROLLBACK;
