#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;
use v5.26;

use strict;
use warnings;

my $file = '/home/redfraction/Desktop/_Perl/iteract with files/_testFiles/index.txt';
open my $info, $file or die "Could not open $file: $!";

while( my $line = <$info>)  {   
    print $line;    
    last if $. == 50; # Стоп слово =)
    
}

close $info if $info;

#Другой способ с использованием своего счетчика
#my $count = 0;
#while( my $line = <$info>)  {   
#    print $line;    
#    last if ++$count == 2;
#}

if ( open my $info , "/path/to/file.txt" ) {
	my @rows = <$info>;
	close $info if $info;
}
close $info if $info;
