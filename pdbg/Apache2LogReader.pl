#!/usr/bin/perl
use strict;
use utf8;
use v5.26;
use feature 'say';

use Data::Dumper;
use Term::ANSIColor;

my ($arg1, $arg2) = @ARGV;
say $arg1 . $arg2;
my $log_list = [
    '/media/wslog/apache2/error.log',
    '/media/wslog/apache2/4s2.error.log',
    '-',
    '/media/wslog/apache2/alpha.error.log',
    '/media/wslog/apache2-alpha/error.log',
    '-',
    '/media/wslog/apache2/sigma.error.log',
    '/media/wslog/apache2-sigma/error.log',
];

my $file;

say "Choose log file:";

for(my $i = 1; $i < @{$log_list} + 1; $i++){
    if ( $log_list->[$i - 1] ne '-' ){
        say "    $i\:$log_list->[$i - 1]" if $log_list->[$i - 1] ne '-';
    }else{
        say "--------------------------------------------------------";
    }
}
print "Choose: "; my $input = readline();

$file = $log_list->[$input - 1] if $input;

writeOut();

sub writeOut {
    # File reader setup
    my $offset = 0;
    my $filesize = -s $file;
    my $count;
    my $num_of_lines = 5; #Read last 40 lines

    my @out;

    # Terminal coloring
    my $txt_red     = color('bold red');
    my $txt_green   = color('bold green');
    my $txt_blue    = color('bold blue');
    my $txt_mag     = color('bold magenta');
    my $txt_ylw     = color('bold yellow');
    my $txt_res     = color('reset');

    open my $info, $file or die "Could not open $file: $!";

    ### Start reading from other side
    while (abs($offset) < $filesize) {
        my $line = "";

        ### Read by line
        while (abs($offset) < $filesize) {
            seek $info, $offset, 2;
            $offset -= 1;
            my $char = getc $info;
            last if $char eq "\n";
            $line = $char . $line;
        }

        $line =~ s!\\n!\n!gm;

        #Mark DateAndTime
        $line =~ s!(\[(Mon|Tue|Wed|Thu|Fri|Sat|Sun) (Jan|Feb|Mar|May|Apr|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\ (\d\d)\ (\d\d\:\d\d\:\d\d.(\d){0,6}) (\d){4}\])!$txt_mag$1$txt_res!gm;

        #Mark "ERROR"
        $line =~ s!\[:error\]!$txt_red\[:ERROR]$txt_res!gm;

        #Mark "PID .."
        $line =~ s!\[pid\ ([0-9]{0,6})\]!$txt_red\[PID $1\]$txt_res!gm;

        #Mark "At line .."
        $line =~ s!line ([0-9]{0,6})\.$!$txt_red at line $1.$txt_res!gm;

        #Mark path and script\module
        # $line =~ s!((\/[a-zA-Z0-9\-\.]+)+.p(l|m))!$txt_res$1$txt_res!g;

        # Mark only script\module
        $line =~ s!(\/([a-zA-Z0-9\-\.]+).p(l|m))!/$txt_ylw$2.p$3$txt_res!g;

        #Mark error explain
        $line =~ s!^([a-zA-Z\ \-\"\$\_ \(\?\)]+)!$txt_blue$1$txt_res!gm;

        push @out => $line, "\n";

        $count++;
        last if $count > $num_of_lines;
    }

    @out = reverse @out;
    print "@out";

}
