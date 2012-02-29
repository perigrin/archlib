#!/usr/bin/perl
use strict;
use warnings;

use Test::More;

use Cwd;
use Archive::Tar;
BEGIN {
    my $dir = getcwd;
    chdir "t/inc";
    Archive::Tar->create_archive(
        '../inc.tar.gz',
        COMPRESS_GZIP,
        'ArchLibTest.pm',
    );
    chdir $dir;
}
$ENV{ARCHLIB_TAR_ORDER} = 'Archive::Tar';
use_ok 'archlib', 't/inc.tar.gz';
use_ok 'ArchLibTest';

can_ok( __PACKAGE__, qw/archlibtest/ );
is( archlibtest(), "ArchLibTest", "Imported function" );

ok( unlink( 't/inc.tar.gz' ), "Cleanup" );

done_testing;
