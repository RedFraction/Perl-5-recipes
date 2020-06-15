#!/usr/bin/perl
use strict;
use Data::Dumper;
use v5.26.1;
use Desktop::Notify;
use File::ChangeNotify;
use Gtk3 -init;

my $window = Gtk3::Window->new ('toplevel');
my $button = Gtk3::Button->new ('Create notify');

### Setting up button onClick listener
$button->signal_connect(clicked => \&showNotify);

### Config window
{
    $window->set_title('NOTIFYZER 3000');
    $window->set_default_size(480, 320);
    ### Setting up default close operation
    sub quit_function {
        print "--- Window has been closed ---\n";
        Gtk3->main_quit;
        return 0;
    }
    $window->signal_connect(delete_event => \&quit_function);
}

### Add window elements
{
    $window->add($button);
    $window->set_border_width(20);
}

### Show window
$window->show_all;
Gtk3::main;

sub showNotify {
    ### Initilize global variables
    my $notify = Desktop::Notify->new;

    ### Create notification template
    my $note = $notify->create(
        summary => 'NOTIFYZER 3000',
        body => '! Hello, it\'s me !',
        timeout => 1000
    );

    $note->show();
}

### File edit/or any change listener

### Initilize listner
# my $listener = File::ChangeNotify->instantiate_watcher(
#     directories => [ '/home/redfraction/Desktop/Sandbox/' ], # Set directories (or/and files) to watch
#     filter      => qr/\.(?:dat)$/ #Set filter for file name and extension
# );

### Start listening
#while ( my @events = $listener->wait_for_events ) {
#$note->show(); # Show notification
#}
#$note->close();