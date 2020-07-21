#!/usr/bin/perl -w
use strict;

use Digest::SHA qw(sha256);

my $URL = "yandexnavi://build_route_on_map?lat_to=55.5996520&lon_to=37.7258730";
my $CLIENT = "karapuz228";

sub Url2SHA256{

    my %params = !(@_ % 2) ? @_ : ();

    my $url = $params{ 'url' } || '';

    return $url ? Digest::SHA->sha256_hex($url) : undef;
}

sub UpgradeNavLink{

    my %params = !(@_ % 2) ? @_ : ();

    my $url     = $params{ 'url' } || '';
    my $client  = $params{ 'clientID' } || '';

    return unless $url || $client;

    my $prepare_url = $url . "&client=$client";

    my $signature = Url2SHA256(url => $prepare_url);

    return $prepare_url . "&signature=$signature";
}

print UpgradeNavLink (url => $URL, clientID => $CLIENT);

