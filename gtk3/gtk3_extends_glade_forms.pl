#! /usr/bin/perl
use strict;
use warnings;
use diagnostics;
use feature ':5.14';
use Gtk3 qw{-init};
use Glib qw/TRUE FALSE/;
use Data::Dumper;

my $builder = Gtk3::Builder->new();
$builder->add_from_file("/home/redfraction/Desktop/Sandbox/main.glade");
$builder->connect_signals(undef);
my $window = $builder->get_object("window1"); ### NOT OBJECT TYPE, IT'S ID!
$window->show_all;
Gtk3::main;