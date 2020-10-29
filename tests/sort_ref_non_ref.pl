#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;
use Time::HiRes;

my @arr = [0,1,2,3,4,5];

foreach my $i (0..1_000_000_00){
    $arr[$i] = int(rand(1000));
} 

my $t1 = Time::HiRes::gettimeofday;

@arr = sort{ $a <=> $b } @arr;

my $t2 = Time::HiRes::gettimeofday();

print $t2  - $t1;