#!/usr/bin/perl -w
package Maper;

use strict;
use Data::Dumper;
use Term::ANSIColor;

### ----------------------------------------------------------------------- ###
### Упрощающие команды
sub println{
    my $output = @_ || '';
    print "@_\n";
}
### ----------------------------------------------------------------------- ###

my @map; 
my $x_len;
my $y_len;
my $bg_char;
my $def_f_color;
my $def_bg_color;

sub genMap{
    $x_len          = $_[0] || 0;
    $y_len          = $_[1] || 0;
    $bg_char        = $_[2] || ' ';
    my $f_color     = $_[3] || $def_f_color;
    my $bg_color    = $_[4] || $def_bg_color;
    
    foreach my $y ( 0 .. $y_len - 1 ) {
        foreach my $x ( 0 .. $x_len - 1 ) {
            $map[$x][$y] = " $bg_char";
        }
    }
}

sub printMap{ 
    foreach my $y ( 0 .. $y_len - 1 ){
        foreach my $x ( 0 .. $x_len - 1 ){
            print $map[$x][$y];
        }
        println;
    }
}

sub drawAt{
    my $xp      = $_[0]; 
    my $yp      = $_[1]; 
    my $char    = $_[2] || $bg_char;
    
    $map[$xp][$yp] = $char;
}

sub drawCircle{
    ### TODO: Just make it work!
}

### Отрисовка прямоугольника по двум заданным заданным координатам
sub drawRectangle{
    my $xs      = $_[0]; 
    my $ys      = $_[1];
    my $xe      = $_[2]; 
    my $ye      = $_[3];
    my $char    = $_[4] || $bg_char || ' ';
    
    foreach my $y ( $ys .. $ye ) {
        foreach my $x ( $xs .. $xe ) {
            $map[$x][$y] = " $char";
        }
    }
}



1;


