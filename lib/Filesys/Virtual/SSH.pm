package Filesys::Virtual::SSH;
use strict;
use warnings;
use File::Basename qw( basename );
use Filesys::Virtual::Plain ();
use base qw( Filesys::Virtual Class::Accessor::Fast );
__PACKAGE__->mk_accessors(qw( cwd root_path home_path host ));
our $VERSION = '0.01';

=head1 NAME

Filesys::Virtual::SSH -

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

# HACKY - mixin these from the ::Plain class, they only deal with the
# mapping of root_path, cwd, and home_path, so they should be safe
*_path_from_root = \&Filesys::Virtual::Plain::_path_from_root;
*_resolve_path   = \&Filesys::Virtual::Plain::_resolve_path;

sub list {
    my $self = shift;
    my $final_path = $self->_path_from_root( shift );

    my @files = `ls -a $final_path 2> /dev/null`;
    chomp (@files);
    return map { basename $_ } @files;
}

sub list_details {
    my $self = shift;
    my $final_path = $self->_path_from_root( shift );

    my @lines = `ls -al $final_path 2> /dev/null`;
    shift @lines; # I don't care about 'total 42'
    chomp @lines;
    return @lines;
}

sub chdir {
    my $self = shift;
    my $to   = shift;

    my $new_cwd   = $self->_resolve_path( $to );
    my $full_path = $self->_path_from_root( $to );
    # XXX check that full_path is a directory
    return $self->cwd( $new_cwd );
}

# well if ::Plain can't be bothered either
sub modtime { return (0, "") }

sub stat {
    my $self = shift;
    my $file = $self->_path_from_root( shift );

    my $stat = `perl -e'print join ",", stat "$file"'`;
    return split /,/, $stat;
}

sub size {
    my $self = shift;
    return ( $self->stat( shift ))[7];
}

sub test {
    my $self = shift;
    my $test = shift;
    my $file = $self->_path_from_root( shift );
    my $stat = `perl -e'print -$test "$file"'`;
    return $stat;
}

=head1 AUTHOR

Richard Clamp <richardc@unixbeard.net>

=head1 COPYRIGHT

Copyright 2004 Richard Clamp.  All Rights Reserved.

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.


=head1 BUGS

None known.

Bugs should be reported to me via the CPAN RT system.
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Filesys::Virtual::SSH>.

=head1 SEE ALSO

Filesys::Virtual, POE::Component::Server::FTP


=cut

1;
