#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;
use DBI;

print map "$_\n",DBI->available_drivers;
