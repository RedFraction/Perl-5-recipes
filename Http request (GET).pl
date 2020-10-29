#!/usr/bin/perl -w
use strict;
use utf8;
use Data::Dumper;
 
use HTTP::Request ();
use JSON::MaybeXS qw(encode_json);
use LWP::UserAgent();
use feature 'say';
 
my $url = 'https://alpha.strd.ru/index.shtml';
my $header = ['Content-Type' => 'application/json; charset=UTF-8'];
my $data = {foo => 'bar', baz => 'quux'};
my $encoded_data = encode_json($data);
 
my $r = HTTP::Request->new('POST', $url, $header);
# at this point, we could send it via LWP::UserAgent
my $jar;
my $ua = LWP::UserAgent->new(
    cookie_jar        => $jar,
    protocols_allowed => ['http', 'https'],
    timeout           => 10,
    agent	      => 'Mozilla/5.0'
);
$ua->agent('Mozilla/5.0');
my $res = $ua->request($r);

say Dumper $res;


