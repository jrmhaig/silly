adventure
=========

Introduction
------------

The files included are:

* tables.sql
* procedures.sql
* startup.sh

Before starting, you should have MySQL installed on the local machine and a
database called 'Adventure'. Edit startup.sh to use your mysql admin user and
password. Then, to begin, run

    $ startup.sh

Yes, it is trivially easy to cheat. What did you expect?

Playing
-------

A very simple text adventure written in MySQL comprising 8 rooms in a house
where the object is to find the way out.

The following commands are implemented:

* Go - move in a specified direction
* Pick_up - pick up an object
* Put_down - put down an object
* Give_to - give an object to another character
* Inventory - list objects carried
* Look_at - show the description of an object
* Look_around - show the description of the current location
* Lock_door - use a key to lock a door
* Unlock_door - use a key to unlock a door
* Say_to - speak to another character
* Wait - wait for one turn
* Help - list commands 

In addition, there is another character walking round at random, with which the
player must interact (on a very basic level) to complete the game.
