#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use JSON::XS;
use YAML;
local $YAML::UseHeader = 0;
local $YAML::CompressSeries = 1;
local $YAML::SortKeys = 0;

############################################
# get argument about fetch calendar category
my $category = $ARGV[0] || 'sports';

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
# fetch each category calendar
my $result = {
    category => [
        name => $category,
    ],
};
fetch_calendar( $category, $result );

########################
# output result for YAML
print Dump $result;


### METHOD

###################################
# fetch specified category calendar
sub fetch_calendar {
    my $category = shift;
    my $res = fetch_cal( $category );

    use Data::Dumper;
    print Dumper $res;
    exit;
}

##############################
# fetch calendar/directory api
sub fetch_cal {
    my $did = shift;
    $mech->get( sprintf $cal_url, $did );

    return $json->decode( $mech->content() );    
}
