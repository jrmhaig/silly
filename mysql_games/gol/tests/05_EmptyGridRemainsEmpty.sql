BEGIN;

SELECT tap.plan(1);

-- Ensure grid is empty of all cells
DELETE FROM Cells;
CALL Evolve();
SELECT tap.eq((SELECT COUNT(*) FROM Cells), 0, 'Empty grid remains empty');

CALL tap.finish();
ROLLBACK;
