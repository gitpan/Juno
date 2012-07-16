use strict;
use warnings;
package Juno::Check::SNMP;
{
  $Juno::Check::SNMP::VERSION = '0.005';
}
# ABSTRACT: an SNMP check for Juno

use Carp;
use Any::Moose;
use namespace::autoclean;

with 'Juno::Role::Check';

BEGIN {
    {
        eval 'use AnyEvent::SNMP';
        $@ and croak 'AnyEvent::SNMP is required for this check';
    }

    {
        eval 'use Net::SNMP';
        $@ and croak 'Net::SNMP is required for this check';
    }
};

has hostname => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has community => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has version => (
    is       => 'ro',
    isa      => 'Int',
    required => 1
);

has oid => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has session => (
    is         => 'ro',
    isa        => 'Net::SNMP',
    lazy_build => 1
);

sub _build_session {
    my $self = shift;

    my ( $session, $error ) = Net::SNMP->session(
        -hostname    => $self->hostname,
        -community   => $self->community,
        -version     => $self->version,
        -nonblocking => 1,
    );

    defined $session or die "ERROR creating session: $error.\n";

    return $session;
}

sub check {
    my $self = shift;

    $self->has_on_before
        and $self->on_before->($self);

    $self->session->get_request(
        -varbindlist    => [ $self->oid ],
        -callback       => sub {
            $self->has_on_result
                and $self->on_result->( $self, @_ );
        },
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=head1 NAME

Juno::Check::SNMP - an SNMP check for Juno

=head1 VERSION

version 0.005

=head1 AUTHORS

=over 4

=item *

Sawyer X <xsawyerx@cpan.org>

=item *

Adam Balali <adamba@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Sawyer X.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

