#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use feature 'say';
use FFmpeg::Thumbnail;

########################################################################################################################
#### EXTRACT IMAGE FROM VIDEO FRAME AT FIXED TIME ######################################################################
########################################################################################################################

my $path = '/home/redfraction/Desktop/_dev_null/_Perl/Video'; #source video path/file.name

my $baz = FFmpeg::Thumbnail->new( { video => "$path/test.avi" } );
$baz->output_width( 320 ); #px
$baz->output_height( 240 ); #px

foreach (25 .. 35) {
$baz->offset( $_ ); # Delay from start in seconds
$baz->create_thumbnail( undef, "$path/tmbnl$_.png"); #extract path/file.name
}