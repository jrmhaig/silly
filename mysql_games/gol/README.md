# Conway's Game of Life in MySQL

A MySQL implementation of Conway's Game of Life, built using Test Driven
Development, with the
[MyTAP unit testing framework.](https://github.com/theory/mytap)

## Set up

To set up, create a database for the Game of Life and a user. For example:

    mysql> CREATE DATABASE GoL;
    mysql> GRANT ALL PRIVILEGES ON GoL.* TO 'gol'@'localhost' IDENTIFIED BY 'password';

Install MyTAP:

    $ mysql -uroot -p < mytap/mytap.sql

and grant `SELECT` and `EXECUTE` privileges to the user created above:

    mysql> GRANT SELECT, EXECUTE ON tap.* TO 'gol'@'localhost';

## Execute the tests

Execute the tests with

    $ ./run_tests.sh <user> <password> <database>

The table definition and functions are defined in `gol.sql` and these are
automatically loaded by `run_tests.sh`.

## Run the Game of Life

The `play.pl` script uses the database to display the evolution. Edit the code
to set up the grid as required.
