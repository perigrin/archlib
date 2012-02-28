#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'archlib',
    license     => 'perl',
    dist_author => 'Chad Granum <exodist7@gmail.com>',
    create_readme => 1,
    requires => {
        'Carp'         => 0,
        'Test::Simple' => '0.88',
        'Archive::Tar' => 0,
    },
    meta_merge => {
        resources => {
            repository  => 'http://github.com/exodist/archlib',
            bugtracker  => 'http://github.com/exodist/archlib/issues',
        },
    }
);

$build->create_build_script;
