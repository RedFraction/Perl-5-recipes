#!/usr/bin/perl
use strict;
use utf8;
use Data::Dumper;

my $qualificator = 13;

foreach my $i (0 .. 9) {
    foreach my $j (0 .. 9) {
        foreach my $k (0 .. 9) {
            if($i + $j + $k == $qualificator){
                print "i=$i j=$j k=$k == $qualificator\n";
            }
        }
    }
}