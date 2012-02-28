#!/usr/bin/perl
use strict;
use warnings;

use Test::More;

use lib 't/inc';
use ArchLibTest;

can_ok( __PACKAGE__, qw/archlibtest/ );
is( archlibtest(), "ArchLibTest", "Imported function" );

done_testing;
