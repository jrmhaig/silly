-- Table
DROP TABLE IF EXISTS Cells;

CREATE TABLE Cells(
  x INTEGER,
  y INTEGER,
  candidate BOOLEAN DEFAULT FALSE,
  UNIQUE(x, y, candidate)
);

-- Functions
DELIMITER ;;
DROP FUNCTION IF EXISTS CellShouldSurvive;
DROP FUNCTION IF EXISTS CellShouldBecomeAlive;
DROP FUNCTION IF EXISTS CountNeighbours;
DROP PROCEDURE IF EXISTS Evolve;

CREATE FUNCTION CellShouldSurvive(numNeighbours INTEGER) RETURNS BOOLEAN
BEGIN
  RETURN numNeighbours = 2 OR numNeighbours = 3;
END ;;

CREATE FUNCTION CellShouldBecomeAlive(numNeighbours INTEGER) RETURNS BOOLEAN
BEGIN
  RETURN numNeighbours = 3;
END ;;

CREATE FUNCTION CountNeighbours(x_in INTEGER, y_in INTEGER) RETURNS INTEGER
BEGIN
  RETURN (SELECT COUNT(*)
            FROM Cells
            WHERE candidate = FALSE
              AND x >= x_in - 1
              AND x <= x_in + 1
              AND y >= y_in - 1
              AND y <= y_in + 1
              AND (x != x_in OR y != y_in));
END;;

CREATE PROCEDURE Evolve()
BEGIN
  -- Survival of living cells
  INSERT INTO Cells (x, y, candidate)
    SELECT x, y, TRUE
      FROM Cells
      WHERE CellShouldSurvive(CountNeighbours(x, y)) IS TRUE
        AND candidate IS FALSE;

  -- Generation of new cells
  -- Strictly, this should check to see if the cell is dead but
  -- CellShouldSurvive will always be true if CellShouldBecomeAlive is true
  -- and the unique key constraint prevents a cell being added twice.
  INSERT INTO Cells (x, y, candidate)
    SELECT i, j, TRUE
      FROM
        (SELECT x-1 AS i, y-1 AS j from Cells
         UNION SELECT x AS i, y-1 AS j from Cells
         UNION SELECT x+1 AS i, y-1 AS j from Cells
         UNION SELECT x-1 AS i, y AS j from Cells
         UNION SELECT x+1 AS i, y AS j from Cells
         UNION SELECT x-1 AS i, y+1 AS j from Cells
         UNION SELECT x AS i, y+1 AS j from Cells
         UNION SELECT x+1 AS i, y+1 AS j from Cells) Candidates
      WHERE CellShouldBecomeAlive(CountNeighbours(i, j))
      ON DUPLICATE KEY UPDATE candidate=candidate;

  -- Clear old grid
  DELETE FROM Cells WHERE candidate IS FALSE;

  -- Set new grid to current
  UPDATE Cells SET candidate=FALSE;
END;;

DELIMITER ;
