#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;

my $user = $ENV{USER}
     || $ENV{LOGNAME}
     || getlogin()
     || (getpwuid($<))[0]
     || "Unknown uid number $<";
     
print $user;
     







