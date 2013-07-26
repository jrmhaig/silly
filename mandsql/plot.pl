#!/usr/bin/perl

use strict;
use warnings;
use GD;
use DBI;
use Term::ReadKey;

print "MySQL username: ";
my $user = <STDIN>;
print "MySQL password: ";
ReadMode('noecho');
my $pass = <STDIN>;
ReadMode('restore');
print "\nMySQL database: ";
my $dbase = <STDIN>;
print "Image filename: ";
my $file = <STDIN>;
chomp($user, $pass, $dbase, $file);

my $db = DBI->connect("dbi:mysql:$dbase",$user,$pass) or die "$!";

my $row;
# Find width and height.
# It is assumed that all rows are equal and and columns are equal.
my $height = $db->prepare("SELECT COUNT(c_re) FROM points GROUP BY c_re LIMIT 1");
$height->execute();
$row = $height->fetchrow_arrayref;
my $ymax = $row->[0];
my $width = $db->prepare("SELECT COUNT(c_im) FROM points GROUP BY c_im LIMIT 1");
$width->execute();
$row = $width->fetchrow_arrayref;
my $xmax = $row->[0];

# Find ranges of real and imaginary values.
# It is assumed that steps are regular.
my $bounds = $db->prepare("SELECT MIN(c_re), MAX(c_re), MIN(c_im), MAX(c_im) FROM points");
$bounds->execute();
$row = $bounds->fetchrow_arrayref;
my $rmin = $row->[0];
my $imin = $row->[2];
# Note, the range needs to be for one extra point to make the calculation
# below work.
my $rrange = $xmax * ( $row->[1] - $rmin ) / ( $xmax - 1 );
my $irange = $ymax * ( $row->[3] - $imin ) / ( $ymax - 1 );

print "\n";
print "Height:          $ymax px\n";
print "Width:           $xmax px\n";
print "Real range:      $rrange [$rmin, " . ($rmin+$rrange) . ")\n";
print "Imaginary range: $irange [$imin, " . ($imin+$irange) . ")\n";

my $BitMap = GD::Image->new($xmax,$ymax);
# Define colours to use (in RGB)
my $black = $BitMap->colorAllocate(0,0,0);
my @cols = (
    $BitMap->colorAllocate(50,0,0),
    $BitMap->colorAllocate(0,50,0),
    $BitMap->colorAllocate(0,0,50),
    $BitMap->colorAllocate(100,50,0),
    $BitMap->colorAllocate(0,100,50),
    $BitMap->colorAllocate(50,0,100),
    $BitMap->colorAllocate(200,100,50),
    $BitMap->colorAllocate(50,200,100),
    $BitMap->colorAllocate(100,50,200),
  );

# This calculation coverts the real and imaginary parts into (x, y) pixel 
# positions.
my $query = $db->prepare("SELECT ROUND(?*(c_re-?)/?) AS re, ROUND(?*(c_im-?)/?) AS im, steps, active from points");
$query->execute($xmax, $rmin, $rrange, $ymax, $imin, $irange);

print "\n";
while ( $row = $query->fetchrow_hashref ) {
  print "\r( $row->{re}, $row->{im} )";
  if ( $row->{active} == 1 ) {
    $BitMap->setPixel( $row->{re}, $row->{im}, $black);
  } else {
    $BitMap->setPixel( $row->{re}, $row->{im}, $cols[$row->{steps} % @cols]);
  }
}
print "\rWriting file '$file'";
open my $fh, ">", $file or die "$!";
print $fh $BitMap->png;
close($fh);
print " - DONE\n";
