#!/usr/bin/perl
use strict;
use warnings;

use Test::More;

use Cwd;
BEGIN {
    unless( eval 'require Archive::Zip; 1' ) {
        plan skip_all => 'Requires Archive::Zip';
        exit;
    }
    Archive::Zip->import( qw/:ERROR_CODES :CONSTANTS/ );
}

BEGIN {
    my $dir = getcwd;
    chdir "t/inc";
    my $zip = Archive::Zip->new();
    $zip->addFile( 'ArchLibTest.pm' );
    my $result = $zip->writeToFileNamed('../inc.zip');
    die "Could not write zip"
        unless $result == AZ_OK;
    chdir $dir;
}

use_ok 'archlib', 't/inc.zip';
use_ok 'ArchLibTest';

if( can_ok( __PACKAGE__, qw/archlibtest/ )) {
    is( archlibtest(), "ArchLibTest", "Imported function" );
}

ok( unlink( 't/inc.zip' ), "Cleanup" );
done_testing;
