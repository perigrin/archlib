#!/usr/bin/perl
use strict;
use warnings;

use Test::More;

use Cwd;
use Archive::Tar;
unless( eval 'require Archive::Peek::External; 1' ) {
    plan skip_all => 'Requires  Archive::Peek::External';
    exit;
}

BEGIN {
    my $dir = getcwd;
    chdir "t/inc";
    Archive::Tar->create_archive( '../inc.tar.bz2', COMPRESS_BZIP,
        'ArchLibTest.pm', );
    chdir $dir;
}

$ENV{ARCHLIB_TAR_ORDER}='Archive::Peek::External';
use_ok 'archlib', 't/inc.tar.bz2';
use_ok 'ArchLibTest';

if ( can_ok( __PACKAGE__, qw/archlibtest/ ) ) {
    is( archlibtest(), "ArchLibTest", "Imported function" );
}

ok( unlink('t/inc.tar.bz2'), "Cleanup" );
done_testing;
