package Recall::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Recall::Schema::DB',
    
    connect_info => {
        dsn => 'dbi:mysql:recall',
        user => 'recall',
        password => 'recall',
        quote_names => q{1},
    }
);

=head1 NAME

Recall::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Recall>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Recall::Schema::DB>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.6

=head1 AUTHOR

David Dorward

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
