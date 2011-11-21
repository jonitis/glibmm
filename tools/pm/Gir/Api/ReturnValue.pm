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

package Gir::Api::ReturnValue;

use strict;
use warnings;

use parent qw(Gir::Api::Common::Base);

use Gir::Api::Array;
use Gir::Api::Attribute;
use Gir::Api::Doc;
use Gir::Api::Type;
use Gir::Api::Varargs;

sub new ($)
{
  my $type = shift;
  my $class = (ref ($type) or $type or 'Gir::Api::ReturnValue');
  my $groups =
  [
    'group_array',
    'group_attribute',
    'group_doc',
    'group_type',
    'group_varargs'
  ];
  my $attributes =
  [
    'attribute_skip',
    'attribute_transfer_ownership'
  ];
  my $self = $class->SUPER::new ($groups, $attributes);

  bless ($self, $class);
  return $self;
}

sub new_with_params ($$)
{
  my ($type, $params) = @_;
  my $self = Gir::Api::ReturnValue::new ($type);

  $self->set_a_skip($params->{'skip'});
  $self->set_a_transfer_ownership($params->{'transfer-ownership'});

  return $self;
}

sub get_g_array_by_name ($$)
{
  my ($self, $name) = @_;

  return $self->_get_group_member_by_name ('group_array', $name);
}

sub get_g_attribute_by_name ($$)
{
  my ($self, $name) = @_;

  return $self->_get_group_member_by_name ('group_attribute', $name);
}

sub get_g_doc_by_name ($$)
{
  my ($self, $name) = @_;

  return $self->_get_group_member_by_name ('group_doc', $name);
}

sub get_g_type_by_name ($$)
{
  my ($self, $name) = @_;

  return $self->_get_group_member_by_name ('group_type', $name);
}

sub get_g_varargs_by_name ($$)
{
  my ($self, $name) = @_;

  return $self->_get_group_member_by_name ('group_varargs', $name);
}


sub get_g_array_by_index ($$)
{
  my ($self, $index) = @_;

  return $self->_get_group_member_by_index ('group_array', $index);
}

sub get_g_attribute_by_index ($$)
{
  my ($self, $index) = @_;

  return $self->_get_group_member_by_index ('group_attribute', $index);
}

sub get_g_doc_by_index ($$)
{
  my ($self, $index) = @_;

  return $self->_get_group_member_by_index ('group_doc', $index);
}

sub get_g_type_by_index ($$)
{
  my ($self, $index) = @_;

  return $self->_get_group_member_by_index ('group_type', $index);
}

sub get_g_varargs_by_index ($$)
{
  my ($self, $index) = @_;

  return $self->_get_group_member_by_index ('group_varargs', $index);
}


sub get_g_array_count ($)
{
  my $self = shift;

  return $self->_get_group_member_count ('group_array');
}

sub get_g_attribute_count ($)
{
  my $self = shift;

  return $self->_get_group_member_count ('group_attribute');
}

sub get_g_doc_count ($)
{
  my $self = shift;

  return $self->_get_group_member_count ('group_doc');
}

sub get_g_type_count ($)
{
  my $self = shift;

  return $self->_get_group_member_count ('group_type');
}

sub get_g_varargs_count ($)
{
  my $self = shift;

  return $self->_get_group_member_count ('group_varargs');
}


sub add_g_array ($$$)
{
  my ($self, $member_name, $member) = @_;

  $self->_add_member_to_group ('group_array', $member_name, $member);
}

sub add_g_attribute ($$$)
{
  my ($self, $member_name, $member) = @_;

  $self->_add_member_to_group ('group_attribute', $member_name, $member);
}

sub add_g_doc ($$$)
{
  my ($self, $member_name, $member) = @_;

  $self->_add_member_to_group ('group_doc', $member_name, $member);
}

sub add_g_type ($$$)
{
  my ($self, $member_name, $member) = @_;

  $self->_add_member_to_group ('group_type', $member_name, $member);
}

sub add_g_varargs ($$$)
{
  my ($self, $member_name, $member) = @_;

  $self->_add_member_to_group ('group_varargs', $member_name, $member);
}


sub get_a_skip ($)
{
  my ($self) = @_;

  return $self->_get_attribute ('attribute_skip');
}

sub get_a_transfer_ownership ($)
{
  my ($self) = @_;

  return $self->_get_attribute ('attribute_transfer_ownership');
}


sub set_a_skip ($$)
{
  my ($self, $value) = @_;

  $self->_set_attribute ('attribute_skip', $value);
}

sub set_a_transfer_ownership ($$)
{
  my ($self, $value) = @_;

  $self->_set_attribute ('attribute_transfer_ownership', $value);
}


1; # indicate proper module load.
