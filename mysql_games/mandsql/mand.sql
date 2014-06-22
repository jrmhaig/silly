DROP PROCEDURE IF EXISTS itrt;
DROP PROCEDURE IF EXISTS populate;
DROP TABLE IF EXISTS points;

CREATE TABLE points (
  c_re DOUBLE,
  c_im DOUBLE,
  z_re DOUBLE DEFAULT 0,
  z_im DOUBLE DEFAULT 0,
  znew_re DOUBLE DEFAULT 0,
  znew_im DOUBLE DEFAULT 0,
  steps INT DEFAULT 0,
  active CHAR DEFAULT 1
);

DELIMITER |

CREATE PROCEDURE itrt (IN n INT)
BEGIN
  label: LOOP
    UPDATE points
      SET
        znew_re=POWER(z_re,2)-POWER(z_im,2)+c_re,
        znew_im=2*z_re*z_im+c_im,
        steps=steps+1
      WHERE active=1;
    UPDATE points SET
        z_re=znew_re,
        z_im=znew_im,
        active=IF(POWER(z_re,2)+POWER(z_im,2)>4,0,1)
      WHERE active=1;
    SET n = n - 1;
    IF n > 0 THEN
      ITERATE label;
    END IF;
    LEAVE label;
  END LOOP label;
END|

CREATE PROCEDURE populate (
  r_min DOUBLE,
  r_max DOUBLE,
  r_step DOUBLE,
  i_min DOUBLE,
  i_max DOUBLE,
  i_step DOUBLE)
BEGIN
  DELETE FROM points;
  SET @rl = r_min;
  SET @a = 0;
  rloop: LOOP
    SET @im = i_min;
    SET @b = 0;
    iloop: LOOP
      INSERT INTO points (c_re, c_im)
        VALUES (@rl, @im);
      SET @b=@b+1;
      SET @im=i_min + @b * i_step;
      IF @im < i_max THEN
        ITERATE iloop;
      END IF;
      LEAVE iloop;
    END LOOP iloop;
      SET @a=@a+1;
    SET @rl=r_min + @a * r_step;
    IF @rl < r_max THEN
      ITERATE rloop;
    END IF;
    LEAVE rloop;
  END LOOP rloop;

END|

DELIMITER ;
