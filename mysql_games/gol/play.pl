#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Term::ReadKey;
use List::Util qw(min max);

print "MySQL username: ";
my $user = <STDIN>;
print "MySQL password: ";
ReadMode('noecho');
my $pass = <STDIN>;
ReadMode('restore');
print "\nMySQL database: ";
my $dbase = <STDIN>;
chomp($user, $pass, $dbase);

my $db = DBI->connect("dbi:mysql:$dbase",$user,$pass) or die "$!";

my $clear = $db->prepare("DELETE FROM Cells");
$clear->execute();

my @cells = (
#    # Blinker
#    [1, 3],
#    [2, 3],
#    [3, 3],

#    # Glider
#    [6, 2],
#    [7, 3],
#    [5, 4],
#    [6, 4],
#    [7, 4],

#    # R Pentomino
#    [2, 1],
#    [3, 1],
#    [1, 2],
#    [2, 2],
#    [2, 3],

    # Die hard
    [1, 2],
    [2, 2],
    [2, 3],
    [7 ,1],
    [6 ,3],
    [7 ,3],
    [8 ,3],

#    # Acorn
#    [2, 1],
#    [4, 2],
#    [1, 3],
#    [2, 3],
#    [5, 3],
#    [6, 3],
#    [7, 3],
  );
my $setup = $db->prepare("INSERT INTO Cells (x, y) VALUES (?, ?)");
for my $cell (@cells) {
  $setup->execute($cell->[0], $cell->[1]);
}

my $range = $db->prepare("SELECT MIN(x)-1, MAX(x)+1, MIN(y)-1, MAX(y)+1 FROM Cells");
my $cells = $db->prepare("SELECT x, y FROM Cells ORDER BY y ASC, x ASC");
my $evolve = $db->prepare("CALL Evolve()");

my ($min_x, $max_x, $min_y, $max_y, $i, $j, $x, $y, $cell);
# Set these if the grid size is to be fixed (see below)
my $x_low = -6; 
my $x_high = 13; 
my $y_low = -4; 
my $y_high = 20; 

my $x_range_low = 0;
my $x_range_high = 0;
my $y_range_low = 0;
my $y_range_high = 0;
my $step = 1;
while ( 1 ) {
  $range->execute();
  $cell = $range->fetchrow_arrayref;
  ($min_x, $max_x, $min_y, $max_y) = @$cell;
  if (! defined($min_x)) {
    print "Dead!\n\n";
    print "  x range: $x_range_low .. $x_range_high\n";
    print "  y range: $y_range_low .. $y_range_high\n";
    exit 0;
  }
  $x_range_low = min($x_range_low, $min_x);
  $x_range_high = max($x_range_high, $max_x);
  $y_range_low = min($y_range_low, $min_y);
  $y_range_high = max($y_range_high, $max_y);
  $cells->execute();
  
  print "($step)\n";
  $step += 1;
  $cell = $cells->fetchrow_arrayref();
  if ($cell) {
    $x = $cell->[0];
    $y = $cell->[1];
  }
  # To fix the grid size use the following two lines instead of the next two
  # and set the variables as appropriate above
  #for($j=$y_low; $j<=$y_high; $j++) {
  #  for($i=$x_low; $i<=$x_high; $i++) {
  for($j=$min_y; $j<=$max_y; $j++) {
    for($i=$min_x; $i<=$max_x; $i++) {
      if ($x == $i && $y == $j) {
        print "o";
        $cell = $cells->fetchrow_arrayref;
        if ($cell) {
          $x = $cell->[0];
          $y = $cell->[1];
        }
      } else {
        print ".";
      }
    }
    print "\n";
  }
  print "X: $min_x .. $max_x\n";
  print "Y: $min_y .. $max_y\n";

  # Use these two lines to allow control of the evolution
  #print "\n Go ";
  #<STDIN>;
  $evolve->execute();
  print "\n";
  sleep(1);
}
