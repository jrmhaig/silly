DROP TABLE IF EXISTS `Help`;
DROP TABLE IF EXISTS `SpeechResponse`;
DROP TABLE IF EXISTS `Room`;
DROP TABLE IF EXISTS `GiveResponse`;
DROP TABLE IF EXISTS `Exits`;
DROP TABLE IF EXISTS `Directions`;
DROP TABLE IF EXISTS `Objects`;
DROP TABLE IF EXISTS `Characters`;
DROP TABLE IF EXISTS `ActionSpeech`;
DROP TABLE IF EXISTS `Rooms`;
--
-- Table structure for table `Rooms`
--

CREATE TABLE `Rooms` (
  `Id` int(10) unsigned NOT NULL auto_increment,
  `Name` varchar(255) NOT NULL,
  `Description` text,
  PRIMARY KEY  (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

--
-- Table structure for table `Characters`
--

CREATE TABLE `Characters` (
  `Id` int(10) unsigned NOT NULL auto_increment,
  `Name` varchar(255) NOT NULL,
  `RoomId` int(10) unsigned default NULL,
  `Main` tinyint(4) default NULL,
  `Sleep` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`Id`),
  KEY `RoomId` (`RoomId`),
  CONSTRAINT `Characters_ibfk_1` FOREIGN KEY (`RoomId`) REFERENCES `Rooms` (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Table structure for table `Objects`
--

CREATE TABLE `Objects` (
  `Id` int(10) unsigned NOT NULL auto_increment,
  `Name` varchar(255) default NULL,
  `Description` text,
  `RoomId` int(10) unsigned default NULL,
  `CharacterId` int(10) unsigned default NULL,
  PRIMARY KEY  (`Id`),
  KEY `RoomId` (`RoomId`),
  KEY `CharacterId` (`CharacterId`),
  CONSTRAINT `Objects_ibfk_1` FOREIGN KEY (`RoomId`) REFERENCES `Rooms` (`Id`),
  CONSTRAINT `Objects_ibfk_2` FOREIGN KEY (`CharacterId`) REFERENCES `Characters` (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

--
-- Table structure for table `ActionSpeech`
--

CREATE TABLE `ActionSpeech` (
  `Id` int(10) unsigned NOT NULL auto_increment,
  `Speech` varchar(255) NOT NULL,
  PRIMARY KEY  (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Table structure for table `Directions`
--

CREATE TABLE `Directions` (
  `Direction` varchar(255) NOT NULL,
  PRIMARY KEY  (`Direction`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `Exits`
--

CREATE TABLE `Exits` (
  `FromRoomId` int(10) unsigned NOT NULL,
  `ToRoomId` int(10) unsigned NOT NULL,
  `Direction` varchar(255) NOT NULL,
  `Locked` tinyint(4) NOT NULL default '0',
  `KeyId` tinyint(4) default NULL,
  UNIQUE KEY `FromRoomId` (`FromRoomId`,`Direction`),
  KEY `ToRoomId` (`ToRoomId`),
  KEY `Direction` (`Direction`),
  CONSTRAINT `Exits_ibfk_1` FOREIGN KEY (`FromRoomId`) REFERENCES `Rooms` (`Id`),
  CONSTRAINT `Exits_ibfk_2` FOREIGN KEY (`ToRoomId`) REFERENCES `Rooms` (`Id`),
  CONSTRAINT `Exits_ibfk_3` FOREIGN KEY (`Direction`) REFERENCES `Directions` (`Direction`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `GiveResponse`
--

CREATE TABLE `GiveResponse` (
  `ObjectId` int(10) unsigned NOT NULL,
  `CharacterId` int(10) unsigned NOT NULL,
  `Action` varchar(50) default NULL,
  `ActionId` int(10) unsigned NOT NULL,
  `Rank` int(10) unsigned NOT NULL,
  KEY `ObjectId` (`ObjectId`),
  KEY `CharacterId` (`CharacterId`),
  CONSTRAINT `GiveResponse_ibfk_1` FOREIGN KEY (`ObjectId`) REFERENCES `Objects` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `GiveResponse_ibfk_2` FOREIGN KEY (`CharacterId`) REFERENCES `Characters` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `Room`
--

CREATE TABLE `Room` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Table structure for table `SpeechResponse`
--

CREATE TABLE `SpeechResponse` (
  `CharacterId` int(10) unsigned NOT NULL,
  `WordMatch` varchar(255) default NULL,
  `ResponseId` int(10) unsigned NOT NULL,
--  `Response` varchar(255) NOT NULL,
  KEY `CharacterId` (`CharacterId`),
  CONSTRAINT `SpeechResponse_ibfk_1` FOREIGN KEY (`CharacterId`) REFERENCES `Characters` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `SpeechResponse_ibfk_2` FOREIGN KEY (`ResponseId`) REFERENCES `ActionSpeech` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `Help`
--

CREATE TABLE `Help` (
  `Command` varchar(255) default NULL,
  `Arguments` varchar(255) default NULL,
  `Description` varchar(255) default NULL
) ENGINE=InnoDB;

--
-- Dumping data for table `Help`
--
LOCK TABLE `Help` WRITE;
INSERT INTO `Help` VALUES
  ("GO","Direction","Move in the specified direction (North, South, East, West, Up, Down)"),
  ("PICK_UP","Object","Pick up an object"),
  ("PUT_DOWN","Object","Drop an object"),
  ("GIVE_TO","Object,Character","Give an object to another character"),
  ("INVENTORY","","Show the objects you are carrying"),
  ("LOOK_AT","Object","Display the description of an object"),
  ("LOCK_DOOR","Direction,Key","Lock a door"),
  ("UNLOCK_DOOR","Direction,Key","Unlock a door"),
  ("LOOK_AROUND","","Show the desciption of your current position"),
  ("SAY_TO","Character,Speech","Say something to another character"),
  ("WAIT","","Wait for one turn"),
  ("HELP","","Display this list");
UNLOCK TABLES;

--
-- Dumping data for table `Rooms`
--

LOCK TABLES `Rooms` WRITE;
INSERT INTO `Rooms` VALUES
  (1,'Hall','You are standing in the main hall of the house.  The front door is south.'),
  (2,'Dining room','You are standing in the dining room.  The beautiful aroma of cooking food comes from the door leading west.'),
  (3,'Lounge','You are standing in the lounge.  Through the window you can see the world outside that has not yet been created.'),
  (4,'Kitchen','You are standing in the kitchen.  There are various implements here that could be used as weapons.'),
  (5,'Cellar stairs - top','You are at the top of a flight of stairs.'),
  (6,'Cellar stairs - bottom','You are at the bottom of a flight of stairs.'),
  (7,'Main cellar','You are in a large wine cellar.'),
  (8,'Outside','Congratulations, you have managed to find your way out.');
UNLOCK TABLES;

--
-- Dumping data for table `Characters`
--

LOCK TABLES `Characters` WRITE;
INSERT INTO `Characters` VALUES
  (1,'Fred',1,1,0),
  (2,'Matt the pirate',2,0,1);
UNLOCK TABLES;

--
-- Dumping data for table `ActionSpeech`
--

LOCK TABLES `ActionSpeech` WRITE;
INSERT INTO `ActionSpeech` VALUES
  (1,'Aaar, a bottle o\' the old Redbeard\'s best!'),
  (2,'Yo ho ho and a ... erm ...'),
  (3,'Arrr, yous\'ll be wantin\' my private key');
UNLOCK TABLES;

--
-- Dumping data for table `SpeechResponse`
--

LOCK TABLES `SpeechResponse` WRITE;
INSERT INTO `SpeechResponse` VALUES
  (2,NULL,2),
  (2,'key',3),
  (2,'front',3),
  (2,'door',3),
  (2,'outside',3);
UNLOCK TABLES;

--
-- Dumping data for table `Directions`
--

LOCK TABLES `Directions` WRITE;
INSERT INTO `Directions` VALUES ('Down'),('East'),('North'),('South'),('Up'),('West');
UNLOCK TABLES;

--
-- Dumping data for table `Exits`
--

LOCK TABLES `Exits` WRITE;
INSERT INTO `Exits` VALUES
  (1,2,'North',0,NULL),
  (1,3,'West',0,NULL),
  (1,8,'South',1,4),
  (2,1,'South',0,NULL),
  (2,4,'West',0,NULL),
  (3,1,'East',0,NULL),
  (4,2,'East',0,NULL),
  (4,5,'West',1,2),
  (5,6,'Down',0,NULL),
  (5,4,'East',1,2),
  (6,7,'East',0,NULL),
  (6,5,'Up',0,NULL),
  (7,6,'West',0,NULL),
  (8,1,'North',1,4);
UNLOCK TABLES;

--
-- Dumping data for table `Objects`
--

LOCK TABLES `Objects` WRITE;
INSERT INTO `Objects` VALUES
  (1,'Knife','A large kitchen knife that looks like it could do someone a nasty injury',4,NULL),
  (2,'Old brass key','A key which appears to be to a door lock',NULL,1),
  (3,'Bottle of rum','A bottle of \"Cap\'n Redbeard\'s Best Red Rum\"',7,NULL),
  (4,'Private key','Matt the pirate\'s private key',NULL,2);
UNLOCK TABLES;

--
-- Dumping data for table `GiveResponse`
--

LOCK TABLES `GiveResponse` WRITE;
INSERT INTO `GiveResponse` VALUES
  (3,2,'Say',1,1),
  (3,2,'Give',4,2);
UNLOCK TABLES;

