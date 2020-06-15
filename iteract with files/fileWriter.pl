#!/usr/bin/perl -w
use strict;
use utf8;
 
my $str = <<END;
I'll kill you when you dreams to night... 
END
 
my $filename = '/home/redfraction/Desktop/_Perl/iteract with files/_testFiles/writeRightNow.txt';
 
open(FH, '>', $filename) or die $!;
 
print FH $str;
 
close(FH);
 
print "Writing to file successfully!\n";