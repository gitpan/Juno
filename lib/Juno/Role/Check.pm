use strict;
use warnings;
package Juno::Role::Check;
{
  $Juno::Role::Check::VERSION = '0.008';
}
# ABSTRACT: Check role for Juno

use AnyEvent;
use Moo::Role;
use MooX::Types::MooseLike::Base qw<Str Num CodeRef ArrayRef>;
use namespace::autoclean;

with 'MooseX::Role::Loggable';

has hosts => (
    is      => 'ro',
    #isa     => ArrayRef[Str],
    isa     => ArrayRef,
    default => sub { [] },
);

has interval => (
    is      => 'ro',
    isa     => Num,
    default => sub {10},
);

has after => (
    is      => 'ro',
    isa     => Num,
    default => sub {0},
); 

has on_before => (
    is        => 'ro',
    isa       => CodeRef,
    predicate => 1,
);

has on_success => (
    is        => 'ro',
    isa       => CodeRef,
    predicate => 1,
);

has on_fail => (
    is        => 'ro',
    isa       => CodeRef,
    predicate => 1,
);

has on_result => (
    is        => 'ro',
    isa       => CodeRef,
    predicate => 1,
);

has watcher => (
    is      => 'ro',
    writer  => 'set_watcher',
    clearer => 1,
);

requires 'check';

sub run {
    my $self = shift;

    # keep a watcher per check
    $self->set_watcher( AnyEvent->timer(
        interval => $self->interval,
        $self->after ? (after => $self->after) : (),
        cb       => sub {
            $self->check;
        },
    ) );

    return 1;
}

1;



=pod

=head1 NAME

Juno::Role::Check - Check role for Juno

=head1 VERSION

version 0.008

=head1 DESCRIPTION

This role provides Juno checks with basic functionality they all share.

=head1 ATTRIBUTES

=head2 hosts

Custom per-check hosts list.

=head2 interval

Custom per-check interval.

=head2 after

Custom pre-check delay seconds

=head2 on_before

A callback for before an action occurs.

=head2 on_success

A callback for when an action succeeded.

=head2 on_fail

A callback for when an action failed.

=head2 on_result

A callback to catch any result.

This is useful if you have your own logic and don't count on the check to
decide if something is successful or not.

Suppose you run the HTTP check and you have a special setup where 403 Forbidden
is actually a correct result.

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


__END__

