#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;


my $outstr = '';



sub writeToOutputFile{
	
	
my $out = 
<<END;
$outstr 
END
	my $filename = '/home/redfraction/Desktop/_dev_null/_Perl/iteract with files/_testFiles/writeRightNow.txt';
	 
	open(FH, '>', $filename) or die $!;
	 
	print FH $str;
	 
	close(FH);
	 
	print "Writing to file successfully!\n";
	
}

