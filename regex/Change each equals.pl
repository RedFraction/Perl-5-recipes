#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;
use v5.26;

my $abc = "/foo/foo/foo/undefined";
$abc =~ s/(\/foo)/\/bar/g; #Вся магия в последнем операторе - 'g';
print $abc;