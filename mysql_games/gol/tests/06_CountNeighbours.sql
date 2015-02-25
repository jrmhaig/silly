BEGIN;

SELECT tap.plan(12);

DELETE FROM Cells;

-- No neighbouring cells
SELECT tap.eq(CountNeighbours(1,1), 0, 'No neighbouring cells found');

-- One live cell found
INSERT INTO Cells (x, y) VALUES (2, 2);
SELECT tap.eq(CountNeighbours(2,3), 1, 'One cell found above');
SELECT tap.eq(CountNeighbours(2,1), 1, 'One cell found below');
SELECT tap.eq(CountNeighbours(3,2), 1, 'One cell found left');
SELECT tap.eq(CountNeighbours(1,2), 1, 'One cell found right');
SELECT tap.eq(CountNeighbours(3,3), 1, 'One cell found above left');
SELECT tap.eq(CountNeighbours(1,3), 1, 'One cell found above right');
SELECT tap.eq(CountNeighbours(3,1), 1, 'One cell found below left');
SELECT tap.eq(CountNeighbours(1,1), 1, 'One cell found below right');
SELECT tap.eq(CountNeighbours(2,2), 0, 'Cell itself is not counted');

-- Probably want to do some other examples

-- All eight surrounding cells
INSERT INTO Cells (x, y) VALUES (2, 3), (2, 4), (3, 2), (3, 4), (4, 2), (4, 3), (4, 4);
SELECT tap.eq(CountNeighbours(3,3), 8, 'Eight surrounding cells found');
INSERT INTO Cells (x, y) VALUES (3, 3);
SELECT tap.eq(CountNeighbours(3,3), 8, 'Only eight surrounding cells found');

CALL tap.finish();
ROLLBACK;
