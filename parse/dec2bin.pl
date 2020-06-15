#!/usr/bin/perl
use strict;
use utf8;
use Data::Dumper;
use v5.26;

my sub charAt{
    return substr $_[0], $_[1]-1, 1;
}

my sub Dec2Bin($){
    my $in = shift;

    my $sum = 0;
    
    #my $in = reverse($in);
    
    for(my $i = 0; $i < length($in);$i++){

        my $char = charAt($in, $i);

        if($char == 1) {

            if($i - 1 == -1){
                print 2 ** ($i - 1) . "\n";
            }
            else{
                print 2 ** 0;
            }
        }else{
            next;
        }
    }

    #print $sum;
}

my sub read{
    return(<STDIN>);
}
print 2 ** 0;
print '=';
Dec2Bin read;

#{
#    print "\n\nСhoose your destiny:\n - 1. Dec to bin,\n - 2. Bin to Dec,\n - 3. Bin to hex\nYour destiny: ";
#
#    given(<STDIN>){
#        when (1){
#            print "Введите число: ";
#            Dec2Bin read;
#        }
#        when (2){print "Not work at all, try later";}
#        when (3){print "Not work at all, try later";}
#        when (0){exit;}
#    }
#}
