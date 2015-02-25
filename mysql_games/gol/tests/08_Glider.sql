BEGIN;

SELECT tap.plan(4);

DELETE FROM Cells;
INSERT INTO Cells (x, y) VALUES
  (2, 2),
  (3, 3),
  (1, 4),
  (2, 4),
  (3, 4);

-- First iteration
CALL Evolve();
SELECT tap.eq((SELECT COUNT(*) FROM Cells), 5, 'Glider evolves to 5 live cells');
-- There must be a better way of doing this
SELECT tap.eq((SELECT COUNT(*) FROM Cells WHERE
  (x = 1 AND y = 3)
  OR (x = 3 AND y = 3)
  OR (x = 2 AND y = 4)
  OR (x = 3 AND y = 4)
  OR (x = 2 AND y = 5)), 5, 'Glider evolves to the right 5 cells');

-- Second iteration
CALL Evolve();
SELECT tap.eq((SELECT COUNT(*) FROM Cells), 5, 'Glider evolves to 5 live cells');
SELECT tap.eq((SELECT COUNT(*) FROM Cells WHERE
  (x = 3 AND y = 3)
  OR (x = 1 AND y = 4)
  OR (x = 3 AND y = 4)
  OR (x = 2 AND y = 5)
  OR (x = 3 AND y = 5)), 5, 'Glider evolves to the right 5 cells');

CALL tap.finish();
ROLLBACK;
