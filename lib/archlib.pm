package archlib;
use strict;
use warnings;

use Archive::Tar;
use Carp qw/croak/;

our $VERSION = '0.001';
our @ARCHINC;
our $TAR = Archive::Tar->new;

unshift @INC => \&find;

sub import {
    my $class = shift;
    for my $item ( @_ ) {
        croak "No such archive '$item'"
            unless -e $item;

        push @ARCHINC => $item;
    }
}

sub find {
    my ( $sub, $mod ) = @_;
    for my $arch ( @ARCHINC ) {
        $TAR->read( $arch );
        next unless $TAR->contains_file( $mod );
        my @data = split /\n/, $TAR->get_content( $mod );
        return sub {
            return 0 unless @data;
            $_ = shift( @data );
            return 1;
       }
    }
    return;
}

1;

__END__

=head1 NAME

archlib - Add tar archive to @INC path

=head1 SYNOPSIS

    use archlib 'path/to/archive1.tar.gz';
    use archlib 'path/to/archive2.tar.bz2';

    use Module::In::Archive1;
    use Module::In::Archive2;

    ...


=head1 ARCHIVE SPECIFICATIONS

The root of the archive is the root of the search path, ie:

    archive1.tar.bz2:
     TopLevel.pm
     My/Module.pm
     DeeperPath/To/Module.pm

You must B<NOT> put everything into a 'lib' directory.

=head1 UNDER THE HOOD

This module will unshift a subroutine into @INC. This routine will
iterate all archives that have been added looking for each module
loaded. If the module is not present in any archive other @INC entries will be
checked. The module maintains a package variable containing the list of
archives.

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2012 Chad Granum

archlib is free software; Standard perl licence.

archlib is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.
