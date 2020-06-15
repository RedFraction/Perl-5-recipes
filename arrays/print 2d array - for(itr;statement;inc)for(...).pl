#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;

my @arr = (
    [1, 1011, 5, 3, 8, 5, 2, 54, 12, 543, 21],
    ['lets', 'make', 'some', 'noise', 'like', 'grange', 'acum', 'alike']
);

my sub print_2d {
	my @array_2d=@_;
	for(my $i = 0; $i <= $#array_2d; $i++){
	   for(my $j = 0; $j <= $#{$array_2d[$i]} ; $j++){
	      print "$array_2d[$i][$j] ";
	   }
	   print "\n";
	}
}

print_2d(@arr);
