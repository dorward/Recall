package Recall::Controller::Blog;
use Moose;
use namespace::autoclean;

use DateTime;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Recall::Controller::Blog - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 Blog homepage

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Recall::Controller::Blog in Blog.');

    # TODO: Render most recent blog entries

}

=head2 period

Show blog enteries for a given period

=cut

sub period :Private {
  my ( $self, $c) = @_;
  my $dt_start = $c->stash->{range}{start};
  my $dt_end = $c->stash->{range}{end};
  my @documents = $c->model("DB::Document")->get_first_published_between($dt_start, $dt_end);
  my %nearby = $c->model("DB::Document")->get_next_and_previous($dt_start, $dt_end);
  my @documents_data = map {
        {
            title => $_->title,
            uri => $self->get_url_for_document($c, $_)
        };
    } @documents;
  $c->stash->{documents} = \@documents_data;
  $c->stash->{nearby} = \%nearby;
}

=head2 year

Show blog entries for year

=cut

sub year :Path :Args(1) {
  my ( $self, $c, $year ) = @_;
  $c->stash->{title} = "Blog entries for " . $year;
  my $dt_start = DateTime->new(year => $year);
  my $dt_end = $dt_start->clone->add( years => 1, seconds => -1 );
  $c->stash->{range} = { start => $dt_start, end => $dt_end };
  $c->forward('period');
  foreach my $key (keys %{$c->stash->{nearby}}) {
    my $date = $c->stash->{nearby}{$key}->first_published->edited;
    my $value = { text => $date->year, uri => $c->uri_for($self->action_for('year'), [ $date->year ]) };
    $c->stash->{nearby}{$key} = $value;
  }
}

=head2 month

Show blog entries for month

=cut

sub month :Path :Args(2) {
  my ( $self, $c, $year, $month ) = @_;
  $c->stash->{title} = "Blog entries for $month, $year";
  my $dt_start = DateTime->new(year => $year, month => $month );
  my $dt_end = $dt_start->clone->add( months => 1, seconds => -1 );
  $c->stash->{range} = { start => $dt_start, end => $dt_end };
  $c->forward('period');
  foreach my $key (keys %{$c->stash->{nearby}}) {
    my $date = $c->stash->{nearby}{$key}->first_published->edited;
    my $value = { text => $date->strftime("%B %Y"), uri => $c->uri_for($self->action_for('month'), [ $date->year, $date->month ]) };
    $c->stash->{nearby}{$key} = $value;
  }
}

=head2 day

Show blog entries for day

=cut

sub day :Path :Args(3) {
  my ( $self, $c, $year, $month, $day ) = @_;
  $c->stash->{title} = "Blog entries for $day of $month, $year";
  my $dt_start = DateTime->new(year => $year, month => $month, day => $day );
  my $dt_end = $dt_start->clone->add( days => 1, seconds => -1 );
  $c->stash->{range} = { start => $dt_start, end => $dt_end };
  $c->forward('period');
  foreach my $key (keys %{$c->stash->{nearby}}) {
    my $date = $c->stash->{nearby}{$key}->first_published->edited;
    my $value = { text => $date->strftime("%A, %d of %B %Y"), uri => $c->uri_for($self->action_for('year'), [ $date->year, $date->month, $date->day ]) };
    $c->stash->{nearby}{$key} = $value;
  }
}



=head2 entry

Render a specific blog entry

=cut

sub entry :Path :Args(4) {
  my ( $self, $c, $year, $month, $day, $slug ) = @_;

  my $dt_start = DateTime->new(year => $year, month => $month, day => $day);
  my $dt_end = $dt_start->clone->add( days => 1, seconds => -1 );

  my ($document) = $c->model("DB::Document")->get_first_published_between($dt_start, $dt_end, slug => $slug);

  # 404 if there is no associated document
  $c->detach(qw/Root not_found/) unless ($document);

  # TODO - figure out cannonical URI for page and redirect to it if we aren't on it already

  # Populate the template
  $c->stash->{title} = $document->title;
  $c->stash->{body} = $document->html;
  $c->stash->{template} = 'blog/entry.tt';
}

=head2 get_url_for_document

Given a document, generates a URL for it

=cut

sub get_url_for_document :Private {
    my ($self, $c, $document) = @_;

    my $date = $document->first_published->edited;

    return $c->uri_for(
        $self->action_for('entry'), 
        [ $date->year, $date->month, $date->day, $document->slug ]
    );
}

=head1 AUTHOR

David Dorward,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
