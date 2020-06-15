#!/usr/bin/perl -w
#no warnings 'all';
use utf8;
use Data::Dumper;
use strict;

my @arr = ("!dlrow", "gnikcuf", "olleH");

@arr = scalar reverse @arr;

print Dumper @arr;