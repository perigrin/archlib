package archlib;
use strict;
use warnings;

#use Archive::Tar;
use Carp qw/croak/;
use List::Util qw/first/;

our $VERSION = '0.002';
our @ARCHINC;
our %CONF;
our $HAVE_ZIP = 0;

BEGIN {
    if( eval 'require Archive::Zip; 1' ) {
         Archive::Zip->import(qw/:ERROR_CODES :CONSTANTS/);
         $HAVE_ZIP = 1;
    }
    else {
        # Fake the constants to satisfy the compiler...
        *AZ_OK = sub { croak "Should not see" };
    }
}

# configure 'zip' handler
BEGIN {
    $CONF{zip} = $HAVE_ZIP ? sub {
        my ( $file ) = @_;
        my $it = Archive::Zip->new;
        croak "Could not open archive '$file'"
            unless $it->read( $file ) == AZ_OK;

        return sub {
            my ( $mod ) = @_;
            my $member = $it->memberNamed($mod);
            return unless $member;
            return split /\n/, $it->contents($member);
        };
    } : sub { croak "Install Archive::Zip for zip support" },
}

# Configure 'tar' handler.
BEGIN {
    my @order = $ENV{ARCHLIB_TAR_ORDER}
    ? split( /\s/, $ENV{ARCHLIB_TAR_ORDER} )
    : qw(Archive::Peek::Libarchive Archive::Peek::External Archive::Tar);

    my $tarmod = first { eval "require $_; 1" } @order;

    if ( $tarmod eq 'Archive::Tar' ) {
        $CONF{'tar'} = sub {
            my ( $file ) = @_;
            my $it = $tarmod->new;
            $it->read( $file );

            return sub {
                my ( $mod ) = @_;
                return unless $it->contains_file($mod);
                return split /\n/, $it->get_content($mod);
            };
        }
    }
    else {
        $CONF{'tar'} = sub {
            my ( $file ) = @_;
            my $it = $tarmod->new( filename => $file );

            return sub {
                my ( $mod ) = @_;
                return unless $it->file($mod);
                return split /\n/, $it->file($mod);
            };
        };
    }
}

unshift @INC => sub {
    my ( $sub, $mod ) = @_;

    for my $arch (@ARCHINC) {
        my @data = $arch->( $mod );
        next unless @data;

        return sub {
            return 0 unless @data;
            $_ = shift(@data);
            return 1;
        };
    }
    return;
};

sub import {
    my $class = shift;
    $class->add_archive( $_ ) for @_;
}

sub add_archive {
    my $class = shift;
    my ( $archive ) = @_;
    croak "No such archive '$archive'"
        unless -e $archive;

    my $type = $class->arch_type( $archive );

    push @ARCHINC => $CONF{$type}->( $archive );
}

sub arch_type {
    my $class = shift;
    my ( $archive ) = @_;
    return 'tar' if $archive =~ m/\.tar(\.bz2|\.gz)?$/i;
    return 'zip' if $archive =~ m/\.zip$/;
    croak "Unknown archive type: '$archive'";
}


1;

__END__

=head1 NAME

archlib - Add tar archive to @INC path

=head1 SYNOPSIS

    use archlib 'path/to/archive1.tar.gz';
    use archlib 'path/to/archive2.tar.bz2';
    use archlib 'path/to/archive3.zip';

    use Module::In::Archive1;
    use Module::In::Archive2;
    use Module::In::Archive3;

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

=head1 ARCHIVE MANAGEMENT

=head2 TAR.*

Will try the following in order, you may also specify your own list in the
C<$ENV{ARCHLIB_TAR_ORDER}> environment variable.

=over 4

=item Archive::Peek::Libarchive

=item Archive::Peek::External

=item Archive::Tar

=back

=head2 ZIP

Uses L<Archive::Zip> if it is installed, otherwise it will ask you to install
it in an error message.

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 CONTRIBUTORS

Chris Prather L<chris@prather.org>

=head1 COPYRIGHT

Copyright (C) 2012 Chad Granum

archlib is free software; Standard perl licence.

archlib is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.
