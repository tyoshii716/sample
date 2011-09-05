#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use JSON::XS qw( decode_json );
use Data::Dumper;

my $did = $ARGV[0] || 'sports';
my $auth_info = do '.config.pl';

my $login_url = 'https://www.google.com/accounts/Login?hl=ja&continue=http://www.google.co.jp/';
my $cal_url = sprintf 'https://www.google.com/calendar/directory?pli1&did=%s', $did;

my $mech = WWW::Mechanize->new();

$mech->get( $login_url );
$mech->submit_form(
    form_number => 1,
    fields => $auth_info,
);

$mech->get( $cal_url );

print Dumper decode_json( $mech->content() );
