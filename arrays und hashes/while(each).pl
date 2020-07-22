#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;

my %me = (
    'height' => 186,
    'age' => 21,
    'hates' => 'Some body like you',
    'drinks' => 'Jagermeister with \'Red Bull\'',
    'eat' => 'KFS\'s spicy chiken wings',
    'name' => 'Daniil'
);

my %newMe;

while (my ($k, $v) = each %me){ $newMe{$k} = $v }

print Dumper \%newMe;
