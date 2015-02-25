BEGIN;

SELECT tap.plan(4);

DELETE FROM Cells;
INSERT INTO Cells (x, y) VALUES (1, 3), (2, 3), (3, 3);

-- First iteration: horizontal bar to vertical bar
CALL Evolve();
SELECT tap.eq((SELECT COUNT(*) FROM Cells), 3, 'Blinker evolves to 3 live cells');
-- There must be a better way of doing this
SELECT tap.eq((SELECT COUNT(*) FROM Cells WHERE (x = 2 AND y = 2) OR (x = 2 AND y = 3) OR (x = 2 AND y = 4)), 3, 'Blinker evolves to 3 vertical cells');

-- Second iteration: vertical bar to horizontal bar
CALL Evolve();
SELECT tap.eq((SELECT COUNT(*) FROM Cells), 3, 'Blinker evolves to 3 live cells');
SELECT tap.eq((SELECT COUNT(*) FROM Cells WHERE (x = 1 AND y = 3) OR (x = 2 AND y = 3) OR (x = 3 AND y = 3)), 3, 'Blinker evolves to 3 horizontal cells');

CALL tap.finish();
ROLLBACK;
