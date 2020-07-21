#!/usr/bin/perl -w
use strict;
use utf8;

my @CornerPoints = (
	'1:1', '4:4', '6:2'
);

my $cX;
my $cY;
my $corners;

foreach(@CornerPoints){
	my ($x, $y) = split(":", $_);
	$cX += $x;
	$cY += $y;
	$corners++;
}

print "x = " . $cX / $corners . " | y = " . $cY / $corners;