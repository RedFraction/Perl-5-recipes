#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;
use Time::HiRes;

my %hash;
my $a;

#Подготовка нагрузочных данных
{
    foreach( 0 .. 1000000){
        $hash{$_} = rand;
    }
}

my $t1 = Time::HiRes::gettimeofday();
######
{
    for ( my $i = 0; $i > scalar keys %hash; $i++ ){
        $a += $v;
    }
    print $a;
}
######
print "\n" . (Time::HiRes::gettimeofday() - $t1);