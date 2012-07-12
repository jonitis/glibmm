## This file was generated by taghandlerwriter.pl script.
##
## Copyright 2011, 2012 Krzesimir Nowak
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

package Gir::Handlers::Namespace;

use strict;
use warnings;

use parent qw (Gir::Handlers::Common::Base);

use Gir::Api::Alias;
use Gir::Api::Bitfield;
use Gir::Api::Callback;
use Gir::Api::Class;
use Gir::Api::Constant;
use Gir::Api::Enumeration;
use Gir::Api::Function;
use Gir::Api::GlibBoxed;
use Gir::Api::Interface;
use Gir::Api::Record;
use Gir::Api::Union;

use Gir::Handlers::Common::Misc;
use Gir::Handlers::Common::Store;
use Gir::Handlers::Common::Tags;

use Gir::Handlers::Alias;
use Gir::Handlers::Bitfield;
use Gir::Handlers::Callback;
use Gir::Handlers::Class;
use Gir::Handlers::Constant;
use Gir::Handlers::Enumeration;
use Gir::Handlers::Function;
use Gir::Handlers::GlibBoxed;
use Gir::Handlers::Interface;
use Gir::Handlers::Record;
use Gir::Handlers::Union;

##
## private:
##
sub _alias_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_alias_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::Alias->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('alias');
}

sub _bitfield_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_bitfield_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::Bitfield->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('bitfield');
}

sub _callback_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_callback_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::Callback->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('callback');
}

sub _class_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_class_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::Class->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('class');
}

sub _constant_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_constant_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::Constant->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('constant');
}

sub _enumeration_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_enumeration_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::Enumeration->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('enumeration');
}

sub _function_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_function_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::Function->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('function');
}

sub _glib_boxed_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_glib_boxed_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::GlibBoxed->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('glib:boxed');
}

sub _interface_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_interface_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::Interface->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('interface');
}

sub _record_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_record_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::Record->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('record');
}

sub _union_start ($$%)
{
  my ($self, $parser, %atts_vals) = @_;
  my $params = Gir::Handlers::Common::Tags::get_union_params %atts_vals;
  my $state = $parser->get_current_state;
  my $object = Gir::Api::Union->new_with_params ($params);

  $state->push_object ($object);
  $self->_call_start_hooks ('union');
}

sub _alias_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('alias');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_alias_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_alias ($name, $object);
}

sub _bitfield_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('bitfield');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_bitfield_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_bitfield ($name, $object);
}

sub _callback_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('callback');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_callback_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_callback ($name, $object);
}

sub _class_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('class');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_class_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_class ($name, $object);
}

sub _constant_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('constant');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_constant_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_constant ($name, $object);
}

sub _enumeration_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('enumeration');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_enumeration_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_enumeration ($name, $object);
}

sub _function_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('function');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_function_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_function ($name, $object);
}

sub _glib_boxed_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('glib:boxed');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_glib_boxed_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_glib_boxed ($name, $object);
}

sub _interface_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('interface');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_interface_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_interface ($name, $object);
}

sub _record_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('record');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_record_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_record ($name, $object);
}

sub _union_end ($$)
{
  my ($self, $parser) = @_;

  $self->_call_end_hooks ('union');

  my $state = $parser->get_current_state;
  my $object = $state->get_current_object;

  $state->pop_object;

  my $parent_object = $state->get_current_object;
  my $count = $parent_object->get_g_union_count;
  my $name = Gir::Handlers::Common::Misc::get_object_name $object, $count;

  $parent_object->add_g_union ($name, $object);
}

##
## public:
##
sub new ($)
{
  my $type = shift;
  my $class = (ref $type or $type or 'Gir::Handlers::Namespace');
  my $start_store = Gir::Handlers::Common::Store->new
  ({
    'alias' => \&_alias_start,
    'bitfield' => \&_bitfield_start,
    'callback' => \&_callback_start,
    'class' => \&_class_start,
    'constant' => \&_constant_start,
    'enumeration' => \&_enumeration_start,
    'function' => \&_function_start,
    'glib:boxed' => \&_glib_boxed_start,
    'interface' => \&_interface_start,
    'record' => \&_record_start,
    'union' => \&_union_start
  });
  my $end_store = Gir::Handlers::Common::Store->new
  ({
    'alias' => \&_alias_end,
    'bitfield' => \&_bitfield_end,
    'callback' => \&_callback_end,
    'class' => \&_class_end,
    'constant' => \&_constant_end,
    'enumeration' => \&_enumeration_end,
    'function' => \&_function_end,
    'glib:boxed' => \&_glib_boxed_end,
    'interface' => \&_interface_end,
    'record' => \&_record_end,
    'union' => \&_union_end
  });
  my $subhandlers =
  {
    'alias' => 'Gir::Handlers::Alias',
    'bitfield' => 'Gir::Handlers::Bitfield',
    'callback' => 'Gir::Handlers::Callback',
    'class' => 'Gir::Handlers::Class',
    'constant' => 'Gir::Handlers::Constant',
    'enumeration' => 'Gir::Handlers::Enumeration',
    'function' => 'Gir::Handlers::Function',
    'glib:boxed' => 'Gir::Handlers::GlibBoxed',
    'interface' => 'Gir::Handlers::Interface',
    'record' => 'Gir::Handlers::Record',
    'union' => 'Gir::Handlers::Union'
  };
  my $self = $class->SUPER::new ($start_store, $end_store, $subhandlers);

  return bless $self, $class;
}

1; # indicate proper module load.