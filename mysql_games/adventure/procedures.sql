DELIMITER ;;
DROP FUNCTION IF EXISTS `Character_Pick_Up`;;
CREATE FUNCTION `Character_Pick_Up`(CharId INT UNSIGNED, ObjId INT UNSIGNED) RETURNS varchar(255)
BEGIN
  SET @SamePlace=(SELECT IF(Objects.RoomId=Characters.RoomId,1,0) FROM Objects,Characters WHERE Objects.Id=ObjId AND Characters.Id=CharId);
  IF @SamePlace = 1
  THEN
    UPDATE Objects SET CharacterId=CharId,RoomId=NULL WHERE Id=ObjId;
    RETURN NULL;
  ELSE
    RETURN "That object is not here";
  END IF;
END ;;

DROP FUNCTION IF EXISTS `Character_Put_Down` ;;
CREATE FUNCTION `Character_Put_Down`(CharId INT UNSIGNED, ObjId VARCHAR(255)) RETURNS varchar(255)
BEGIN
  SET @Carried=(SELECT IF(CharacterId=CharId,1,0) FROM Objects WHERE Objects.Id=ObjId);
  IF @Carried = 1
  THEN
    SET @RoomId=(SELECT RoomId FROM Characters WHERE Id=CharId);
    UPDATE Objects SET RoomId=@RoomId,CharacterId=NULL WHERE Id=ObjId;
    RETURN NULL;
  ELSE
    RETURN "You do not have that object";
  END IF;
END ;;

DROP FUNCTION IF EXISTS `Main_Character_Id` ;;
CREATE FUNCTION `Main_Character_Id`() RETURNS int(10) unsigned
BEGIN
  SET @CharId=(SELECT Id FROM Characters WHERE Main=1);
  RETURN @CharId;
END ;;

DROP FUNCTION IF EXISTS `Move_Character` ;;
CREATE FUNCTION `Move_Character`(CharId INT UNSIGNED, Dir VARCHAR(255)) RETURNS int(10) unsigned
BEGIN
  SET @OldRoom=(SELECT RoomId FROM Characters WHERE Id=CharId);
  SET @NewRoom=(SELECT ToRoomId FROM Exits WHERE FromRoomId=@OldRoom AND Direction=Dir);
  IF @NewRoom IS NOT NULL
  THEN
    SET @Locked=(SELECT Locked FROM Exits WHERE FromRoomId=@OldRoom AND Direction=Dir);
    IF @Locked = 0
    THEN
      UPDATE Characters SET RoomId=@NewRoom WHERE Id=CharId;
      RETURN @NewRoom;
    ELSE
      SET @AdvMessage='The door is locked';
      RETURN NULL;
    END IF;
  ELSE
    SET @AdvMessage=CONCAT('No exit ',Dir);
    return NULL;
  END IF;
END ;;

DROP PROCEDURE IF EXISTS `GIVE_TO` ;;
CREATE PROCEDURE `GIVE_TO`(ObjName varchar(255),CharName varchar(255))
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE Act varchar(50);
  DECLARE ActId int unsigned;
  DECLARE cur CURSOR FOR
    SELECT Action,ActionId
    FROM GiveResponse
      LEFT JOIN Characters ON GiveResponse.CharacterId=Characters.Id
      LEFT JOIN Objects ON GiveResponse.ObjectId=Objects.Id
    WHERE Characters.Name=CharName AND Objects.Name=ObjName
    ORDER BY Rank ASC;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  SET @Given=0;

  SET @Owns=(SELECT Id FROM Objects WHERE Name=ObjName AND CharacterId=Main_Character_Id());
  SET @SameRoom=(SELECT Characters.RoomId FROM Characters JOIN Characters AS CharactersCopy ON Characters.RoomId=CharactersCopy.RoomId WHERE Characters.Name=CharName AND CharactersCopy.Main=1);

  IF @Owns IS NULL
  THEN
    SELECT CONCAT("You do not have ",ObjName) AS Message;
  ELSEIF @SameRoom IS NULL
  THEN
    SELECT CONCAT(CharName," is not here") AS Message;
  ELSE
    OPEN cur;
    REPEAT
      FETCH cur INTO Act,ActId;
      IF NOT done
      THEN
        IF @Given=0
        THEN
          UPDATE Objects,Characters SET Objects.CharacterId=Characters.Id WHERE Objects.Name=ObjName AND Characters.Name=CharName;
          SET @Given=1;
        END IF;
        IF Act='Say'
        THEN
          SELECT Speech AS Response FROM ActionSpeech WHERE Id=ActId;
        ELSEIF Act='Give'
        THEN
          SET @ObjectName=(SELECT Objects.Name FROM Objects RIGHT JOIN Characters ON Objects.CharacterId=Characters.Id WHERE Objects.Id=ActId AND Characters.Name=CharName);
          IF @ObjectName IS NULL
          THEN
            SELECT CONCAT(CharName,' says; I had something to give you but I lost it.') AS Message;
          ELSE
            SELECT CONCAT(CharName,' gives you ',@ObjectName) AS Message;
            UPDATE Objects SET CharacterId=Main_Character_Id() WHERE Id=ActId;
          END IF;
        END IF;
      ELSEIF @Given=0
      THEN
        SELECT CONCAT(CharName,' is not interested.') AS Message;
      END IF;
    UNTIL done END REPEAT;
    CLOSE cur;
    UPDATE Characters SET Sleep=Sleep+1 WHERE Name=CharName;
    CALL Next_Turn(1);
  END IF;
END ;;

DROP PROCEDURE IF EXISTS `GO` ;;
CREATE PROCEDURE `GO`(Dir VARCHAR(255))
BEGIN
  SET @CharId=(SELECT Id FROM Characters WHERE Main=1);
  IF @CharId = NULL
  THEN
    SELECT "Error: No main character";
  ELSE
    SET @NewRoom=(SELECT Move_Character(@CharId, Dir)); 
    IF @NewRoom IS NULL
    THEN
      SELECT @AdvMessage AS Message;
    ELSE
      CALL LOOK_AROUND;
    END IF;
    CALL Next_Turn(1);
  END IF;
END ;;

DROP PROCEDURE IF EXISTS `INVENTORY` ;;
CREATE PROCEDURE `INVENTORY`()
BEGIN
  SET @CharId=(SELECT Main_Character_Id());
  SELECT Name AS "You are holding" FROM Objects WHERE CharacterId=@CharId;
END ;;

DROP PROCEDURE IF EXISTS `LOOK_AROUND` ;;
CREATE PROCEDURE `LOOK_AROUND`()
BEGIN
  SET @CharId=(SELECT Main_Character_Id());
  SET @Room=(SELECT RoomId FROM Characters WHERE Id=@CharId);
  SELECT Description AS "Location" FROM Rooms WHERE Id=@Room;
  SELECT Name AS "You can see" FROM Objects WHERE RoomId=@Room UNION
        SELECT Name FROM Characters WHERE RoomId=@Room AND Id != @CharId;
  SELECT Direction AS "There are exits to the" FROM Exits WHERE FromRoomId=@Room;
END ;;

DROP PROCEDURE IF EXISTS `LOOK_AT` ;;
CREATE PROCEDURE `LOOK_AT`(ObjectName VARCHAR(255))
BEGIN
  SET @CharId=(SELECT Main_Character_Id());
  SET @Room=(SELECT RoomId FROM Characters WHERE Id=@CharId);
  SET @Desc=(SELECT Description FROM Objects WHERE Name=ObjectName AND
                (RoomId=@Room OR CharacterId=@CharId));
  IF @Desc IS NULL
  THEN
    SELECT CONCAT("There is no ", ObjectName, " here") AS Message;
  ELSE
    SELECT @Desc AS Description;
  END IF;
  CALL Next_Turn(1);
END ;;

DROP PROCEDURE IF EXISTS `Next_Turn` ;;
CREATE PROCEDURE `Next_Turn`(Turns INT UNSIGNED)
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE CharId int unsigned;
  DECLARE CharName varchar(255);
  DECLARE RmId int unsigned;
  DECLARE cur CURSOR FOR SELECT Id,Name,RoomId FROM Characters WHERE Main=0 AND Sleep<=0;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  SET @i=0;
  SET @mainRoomId=(SELECT RoomId FROM Characters WHERE Main=1);
  WHILE @i < Turns DO
    UPDATE Characters SET Sleep=Sleep-1 WHERE Main=0;
    OPEN cur;
    REPEAT
      FETCH cur INTO CharId,CharName,RmId;
      IF NOT done
      THEN
        SET @Dir=(SELECT Direction FROM Exits WHERE FromRoomId=RmId ORDER BY RAND() LIMIT 1);
        SET @NewRoom=(SELECT Move_Character(CharId, @Dir));
        IF @NewRoom = @mainRoomId
        THEN
          SELECT CONCAT(CharName," enters the room") AS Message;
        ELSEIF RmId = @mainRoomId
        THEN
          IF @NewRoom IS NOT NULL
          THEN
            SELECT CONCAT(CharName," goes ",@Dir) AS Message;
          ELSE
            SELECT CONCAT(CharName," tries to go ",@Dir," but ",@AdvMessage) AS Message;
          END IF;
        END IF;
        UPDATE Characters SET Sleep=Sleep+1 WHERE Id=CharId;
      END IF;
    UNTIL done END REPEAT;
    CLOSE cur;
    SET @i=@i+1;
  END WHILE;
END ;;

DROP PROCEDURE IF EXISTS `PICK_UP` ;;
CREATE PROCEDURE `PICK_UP`(Object VARCHAR(255))
BEGIN
  SET @CharId=(SELECT Main_Character_Id());
  SET @ObjId=(SELECT Id FROM Objects WHERE Name=Object);
  IF @ObjId IS NULL
  THEN
    SET @ObjId=(SELECT Id FROM Characters WHERE Name=Object AND RoomId=Main_Character_Room());
    IF @ObjId IS NULL
    THEN
      SELECT "That object is not here" AS Message;
    ELSE
      SELECT CONCAT(Object," doesn't like being picked up") AS Message;
    END IF;
  ELSE
    SET @Response=(SELECT Character_Pick_Up(@CharId, @ObjId));
    IF @Response IS NOT NULL
    THEN
      SELECT @Response;
    END IF;
    CALL Next_Turn(1);
  END IF;
END ;;

DROP PROCEDURE IF EXISTS `PUT_DOWN` ;;
CREATE PROCEDURE `PUT_DOWN`(Object VARCHAR(255))
BEGIN
  SET @CharId=(SELECT Main_Character_Id());
  SET @ObjId=(SELECT Id FROM Objects WHERE Name=Object);
  IF @ObjId IS NULL
  THEN
    SELECT "You do not have that object";
  ELSE
    SET @Response=(SELECT Character_Put_Down(@CharId, @ObjId));
    IF @Response IS NOT NULL
    THEN
      SELECT @Response;
    END IF;
    CALL Next_Turn(1);
  END IF;
END ;;

DROP PROCEDURE IF EXISTS `SAY_TO` ;;
CREATE PROCEDURE `SAY_TO`(CharName varchar(255),Speech varchar(255))
BEGIN
  SET @CharId=(SELECT Characters.Id FROM Characters RIGHT JOIN Characters AS CharactersCopy ON Characters.RoomId=CharactersCopy.RoomId WHERE Characters.Name=CharName AND CharactersCopy.Main=1);
  IF @CharId IS NULL
  THEN
    SELECT CONCAT("Cannot see ",CharName) AS Message;
  ELSE
    SELECT ActionSpeech.Speech AS Response FROM SpeechResponse JOIN ActionSpeech ON ResponseId=ActionSpeech.Id WHERE CharacterId=@CharId AND (Speech LIKE CONCAT('%',WordMatch,'%') OR WordMatch IS NULL) ORDER BY WordMatch DESC LIMIT 1;
  END IF;
  UPDATE Characters SET Sleep=Sleep+1 WHERE Name=CharName;
  CALL Next_Turn(1);
END ;;

DROP PROCEDURE IF EXISTS `UNLOCK_DOOR` ;;
CREATE PROCEDURE `UNLOCK_DOOR`(Dir VARCHAR(255), KeyName VARCHAR(255))
BEGIN
  SET @CharId=(SELECT Main_Character_Id());
  SET @Room=(SELECT RoomId FROM Characters WHERE Id=@CharId);
  IF(SELECT FromRoomId FROM Exits WHERE FromRoomId=@Room AND Direction=Dir) IS NULL
  THEN
    SELECT "There is no door in that direction" AS Message;
  ELSEIF(SELECT Locked FROM Exits WHERE FromRoomId=@Room AND Direction=Dir) = 0
  THEN
    SELECT "That door is not locked" AS Message;
  ELSE
    SET @UseKeyId=(SELECT Id FROM Objects WHERE Name=KeyName);
    IF @UseKeyId IS NULL
    THEN
      SELECT CONCAT("You are not holding the ", KeyName) AS Message;
    ELSEIF(SELECT KeyId FROM Exits WHERE FromRoomId=@Room AND Direction=Dir) != @UseKeyId
    THEN
      SELECT CONCAT("The ", KeyName, " does not unlock this door") AS Message;
    ELSE
      UPDATE Exits SET Locked=0 WHERE FromRoomId=@Room AND Direction=Dir;
      SELECT "The door opens";
    
      SET @ToRoom=(SELECT ToRoomId FROM Exits WHERE FromRoomId=@Room AND Direction=Dir);
      UPDATE Exits SET Locked=0 WHERE ToRoomId=@Room AND FromRoomId=@ToRoom;
    END IF;
  END IF;
  CALL Next_Turn(1);
END ;;

DROP PROCEDURE IF EXISTS `LOCK_DOOR` ;;
CREATE PROCEDURE `LOCK_DOOR`(Dir VARCHAR(255), KeyName VARCHAR(255))
BEGIN
  SET @CharId=(SELECT Main_Character_Id());
  SET @Room=(SELECT RoomId FROM Characters WHERE Id=@CharId);
  IF(SELECT FromRoomId FROM Exits WHERE FromRoomId=@Room AND Direction=Dir) IS NULL
  THEN
    SELECT "There is no door in that direction" AS Message;
  ELSEIF(SELECT Locked FROM Exits WHERE FromRoomId=@Room AND Direction=Dir) = 1
  THEN
    SELECT "That door is already locked" AS Message;
  ELSE
    SET @UseKeyId=(SELECT Id FROM Objects WHERE Name=KeyName);
    IF @UseKeyId IS NULL
    THEN
      SELECT CONCAT("You are not holding the ", KeyName) AS Message;
    ELSEIF(SELECT KeyId FROM Exits WHERE FromRoomId=@Room AND Direction=Dir) != @UseKeyId
    THEN
      SELECT CONCAT("The ", KeyName, " does not lock this door") AS Message;
    ELSE
      UPDATE Exits SET Locked=1 WHERE FromRoomId=@Room AND Direction=Dir;
      SELECT "The door locks";
    
      SET @ToRoom=(SELECT ToRoomId FROM Exits WHERE FromRoomId=@Room AND Direction=Dir);
      UPDATE Exits SET Locked=1 WHERE ToRoomId=@Room AND FromRoomId=@ToRoom;
    END IF;
  END IF;
  CALL Next_Turn(1);
END ;;

DROP PROCEDURE IF EXISTS `HELP` ;;
CREATE PROCEDURE `HELP`()
BEGIN
  SELECT Command,Arguments,Description FROM Help;
END ;;

DROP FUNCTION IF EXISTS `Main_Character_Room` ;;
CREATE FUNCTION `Main_Character_Room`() RETURNS int(10) unsigned
BEGIN
  SET @RmId=(SELECT RoomId FROM Characters WHERE Main=1);
  RETURN @RmId;
END ;;

DROP PROCEDURE IF EXISTS `WAIT` ;;
CREATE PROCEDURE `WAIT`()
BEGIN
  CALL Next_Turn(1);
END ;;

DELIMITER ;
