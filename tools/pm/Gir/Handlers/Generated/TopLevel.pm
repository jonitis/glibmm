## This file was generated by taghandlerwriter.pl script.
##
## Copyright 2011 Krzesimir Nowak
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
##

package Gir::Handlers::Generated::TopLevel;

use strict;
use warnings;

use parent qw(Gir::Handlers::Generated::Common::Base);

use Gir::Handlers::Generated::Common::Store;
use Gir::Handlers::Generated::Common::Tags;
use Gir::Handlers::Generated::Repository;

##
## private virtuals
##
sub _repository_start_impl ($$$)
{
  my $self = shift;

  unless ($self->_is_start_ignored ('repository'))
  {
    #TODO: throw something.
    print STDERR 'Gir::Handlers::Generated::TopLevel::_repository_start_impl not implemented.' . "\n";
    exit (1);
  }
}

sub _repository_end_impl ($$)
{
  my $self = shift;

  unless ($self->_is_end_ignored ('repository'))
  {
    #TODO: throw something.
    print STDERR 'Gir::Handlers::Generated::TopLevel::_repository_end_impl not implemented.' . "\n";
    exit (1);
  }
}

sub _setup_handlers ($)
{
  my $self = shift;

  $self->_set_handlers
  (
    Gir::Handlers::Generated::Common::Store->new
    ({
      'repository' => \&_repository_start
    }),
    Gir::Handlers::Generated::Common::Store->new
    ({
      'repository' => \&_repository_end
    })
  );
}

sub _setup_subhandlers ($)
{
  my $self = shift;

  $self->_set_subhandlers
  (
    $self->_generate_subhandlers
    ([
      'repository'
    ])
  );
}

##
## private (sort of)
##
sub _repository_start ($$@)
{
  my ($self, $parser, @atts_vals) = @_;
  my $params = Gir::Handlers::Generated::Common::Tags::get_repository_params (@atts_vals);

  $self->_repository_start_impl ($parser, $params);
}

sub _repository_end ($$)
{
  my ($self, $parser) = @_;

  $self->_repository_end_impl ($parser);
}

##
## public
##
sub new ($)
{
  my $type = shift;
  my $class = (ref ($type) or $type or 'Gir::Handlers::Generated::TopLevel');
  my $self = $class->SUPER::new ();

  return bless ($self, $class);
}

1; # indicate proper module load.