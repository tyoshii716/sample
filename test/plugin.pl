#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use JSON::XS qw( encode_json decode_json );

sub main {
    my @args = @_;
    my $hoge = $$;

    # init
    mkdir "save" if ! -d "save";

    # get saved value
    print Dumper reduce('scalar');
    #print Dumper reduce('array');
    print Dumper reduce('arrayref');
    #print Dumper reduce('hash');
    print Dumper reduce('hashref');


    if ( int(rand(2))  < 1 ) {
        save( $hoge, 'scalar' );
        #save( @args, "array"  );
        save( \@args, "arrayref" );
        #save( hoge => $hoge, args => \@args, "hash" );
        save( { hoge => $hoge, args => \@args }, "hashref" );
    }
    else {
        DEMOLISH();
    }

    
}

sub DEMOLISH {
    warn "DEMOLISH";
    `rm -rf save`;
}

sub save {
    warn "save";
    my $val = shift;
    my $key = shift;
    my $file = sprintf("save/%s", $key);

    if( ! defined $val ) {
        warn "not specified save value";
        return 0;
    }

    open my $FH, ">", $file
        or die "failed open save file";

    if ( ref $val ) {
        print $FH encode_json( $val );
    }
    else {
        print $FH $val;    
    }

    close $FH;
}

sub reduce {
    warn "reduce";
    my $key  = shift;
    my $file = sprintf("save/%s", $key);

    return undef if ! -f $file;

    open my $FH, '<', $file
        or die "failed open file";
    my $content = do { local $/; <$FH> };
    close $FH;

    return $content;
}

main( @ARGV );
