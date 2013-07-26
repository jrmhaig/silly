mandsql
=======

Install
-------

Install the database with:

  $ mysql -uUSERNAME -pPASSWORD DATABASE < mand.sql

This creates a table called 'points' and two stored procedures, 'populate' and
'itrt'.

Use
---

Populate the database with:

  mysql> CALL populate( r_min, r_max, r_step, i_min, i_max, i_step );

* r_min  - lower bound on the real axis
* r_max  - upper bound on the real axis
* r_step - step size on the real axis
* i_min  - lower bound on the imaginary axis
* i_max  - upper bound on the imaginary axis
* i_step - step size on the imaginary axis

For example, for a 800x800 resolution image of the entire set:

  mysql> CALL populate( -2.5, 1.5, 0.005, -2, 2, 0.005 );

Then to make one iteration on every point in the data set:

  mysql> CALL itrt( 1 );

or five iterations:

  mysql> CALL itrt( 5 );

(You get the idea)

To plot the data use:

  $ ./plot.pl

and enter the details as required. Note, this does not create the Mandelbrot
set but rather plots the data that is already in the database.
