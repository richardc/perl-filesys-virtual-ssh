package Filesys::Virtual::SSH;
use strict;
use warnings;
use base qw( Filesys::Virtual Class::Accessor::Chained::Fast );
__PACKAGE__->mk_accessors(qw( cwd root_path home_path host ));
our $VERSION = '0.01';

=head1 NAME

Filesys::Virtual::SSH -

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

sub list {
    my $self = shift;
    my $path = shift;
    my $final_path = $self->root_path . $path;

    my @files = `ls -a $final_path`;
    chomp (@files);
    return @files;
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
