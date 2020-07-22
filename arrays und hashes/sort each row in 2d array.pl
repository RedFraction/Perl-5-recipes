#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;

my @arr = (
	[1, 1011, 5, 3, 8, 5, 2, 54, 12, 543, 21],
	['lets', 'make', 'some', 'noise', 'like', 'grange', 'arrive', 'alike']
);

my sub print_2d {
my @array_2d=@_;
my @secLrArr = ();

for(my $i = 0; $i <= $#array_2d; $i++){

	for(my $j = 0; $j <= $#{$array_2d[$i]} ; $j++){
		@secLrArr[$j] = $array_2d[$i][$j];
	}

	if ($i == 0) {
		@secLrArr = sort{($a <=> $b)} @secLrArr;
	}

	if($i == 1){
 	   @secLrArr = sort{($b cmp $a)} @secLrArr;
	}

	print Dumper @secLrArr;
	print "-------------------\n";
	#@arr[$i] = @secLrArr;

	@secLrArr = ();

	}
}

print_2d(@arr);









