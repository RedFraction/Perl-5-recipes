#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;
use Time::HiRes;
my %hash;

foreach(0..1000000){
	$hash{$_} = $_;	
}

my $t1 = Time::HiRes::gettimeofday();

my $res;

foreach my $key (keys %hash){
	$res += $key;
}

#while( my ( $key ) = each %hash){
#	$res += $key;
#}

print (Time::HiRes::gettimeofday() - $t1);
# while(each)
# 0.341415882110596
# 0.33899188041687
# 0.342120170593262
# 0.355626106262207
# 0.345046997070312
# ~ 0,3446 sec
#
# foreach()
# 0.513411998748779
# 0.470009803771973
# 0.469343900680542
# 0.471575021743774
# 0.474606990814209
# ~ 0,4797 sec
#
#


