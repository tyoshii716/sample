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
my $dir_url = 'https://www.google.com/calendar/directory?pli1&did=%s';
my $cal_url = 'https://www.google.com/calendar/htmlembed?epr=3&chrome=NAVIGATION&src=%s';

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
my $res = fetch( { did => $category } );

########################
# output result for YAML
print Dump { category => [ $res ] };


### METHOD

###################################
# fetch specified category calendar
sub fetch {
    my $did_ref = shift;

    # set temp hashref
    my $name = shift;
    my $key  = shift;
    if ( $did_ref->{'did'} eq $category ) {
        $name = $category;
        $key  = 'event';
    }
    elsif ( $did_ref->{'did'} =~ m{^leagues:(.*)$} ) {
        $name = $1;
        $key  = 'league';
    }
    elsif ( $did_ref->{'did'} =~ m{^team} ) {
        $did_ref->{'title'} =~ m{\s-\s(.*)$};
        $name = $1 ? $1 : $did_ref->{'title'};
        $key  = 'calendar';
    }
    else {
        return '';
    }

    my $temp = { name => $name, $key => [] };

    # fetch 
    if ( $key eq 'calendar' ) {
        use Data::Dumper;
        my $res = fetch_dir( $did_ref->{'did'} );

        for ( @$res ) {
            my $html = fetch_cal( $_->{'did'} );
    
            $html =~ m{render\?cid=(.*?)%23sports};
            push @{ $temp->{$key} }, url_decode( $1 );
        }
    }
    else {
        my $res = fetch_dir( $did_ref->{'did'} );
        for ( @$res ) {
            push @{ $temp->{$key} }, fetch( $_ );
        }
    }

    $temp;
}

####################
# fetch calendar api
sub fetch_cal {
    my $src = shift;
    eval { $mech->get( sprintf $cal_url, $src ); };
    if ( $@ ) {
        warn $@;
        return '';
    }    

    return $mech->content();
}

##############################
# fetch directory api
sub fetch_dir {
    my $did = shift;

    eval { $mech->get( sprintf $dir_url, $did ); };
    if ( $@ ) {
        warn $@;
        return [];
    }    

    return $json->decode( $mech->content() );    
}

############
# url decode
sub url_decode {
    my $str = shift;
    $str =~ tr/+/ /;
    for ( 1 .. 2 ) {
        $str =~ s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2', $1)/eg;
    }
    return $str;
}
