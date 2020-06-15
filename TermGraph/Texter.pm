#!/usr/bin/perl -w
package Texter;

use strict;
use Data::Dumper;
use Term::ANSIColor;

### ----------------------------------------------------------------------- ###
### Упрощающие команды
sub println{
    my $output = @_ || '';
    print "@_\n";
}

sub dmp{
    if ( scalar @_ ) {
        foreach my $i ( @_ ){
            print Dumper($i);   
        }
    }
}
### ----------------------------------------------------------------------- ###

sub c_print{
    print color 
}

sub c_println{
    
}

my @arr = (123123,123,123,12,3,123,1,23);

1;