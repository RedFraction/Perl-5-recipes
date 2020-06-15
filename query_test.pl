#!/usr/bin/perl -wb
use strict;
use utf8;
use Data::Dumper;

my $res = 0;

sub f1{
    print ( (2+2) + f2());
}

sub f2{
     (2+2);
}