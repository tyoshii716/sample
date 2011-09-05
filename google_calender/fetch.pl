#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use JSON::XS;

#################
# Email && Passwd
my $auth_info = do '.config.pl';

############
# fetch url
my $login_url = 'https://www.google.com/accounts/Login?hl=ja&continue=http://www.google.co.jp/';
my $cal_url = 'https://www.google.com/calendar/directory?pli1&did=%s';

##########################
# mechanize : google login
my $mech = WWW::Mechanize->new();

$mech->get( $login_url );
$mech->submit_form(
    form_number => 1,
    fields => $auth_info,
);

####################
# create json object
my $json = JSON::XS->new()->pretty(1)->allow_nonref();

################################
# fetch sports category calendar
my $category_json = fetch_calendar_directory( 'sports' );
# print $json->encode( $category_json );

############################
# write category/sports.json
mkdir 'category'; 
open my $CATEGORY_FH, '>', 'category/sports.json';
print $CATEGORY_FH $json->encode( $category_json );
close $CATEGORY_FH;

########################
# fetch leagues calendar
my $leagues_json_hash;
for ( @{ $category_json } ) {
    $leagues_json_hash->{$_->{'did'}} = fetch_calendar_directory( $_->{'did'} );
}

##########################
# write leagues/XXXXX.json
mkdir 'leagues';
for my $league_did ( keys %{ $leagues_json_hash } ) {
    open my $LEAGUES_FH, '>', 'leagues/'.$league_did;
    print $LEAGUES_FH $json->encode( $leagues_json_hash->{$league_did} );
    print $json->encode( $leagues_json_hash->{$league_did} );
}


### METHOD

##############################
# fetch calendar/directory api
sub fetch_calendar_directory {
    my $did = shift;
    $mech->get( sprintf $cal_url, $did );

    return $json->decode( $mech->content() );    
}
