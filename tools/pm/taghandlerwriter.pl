#!/usr/bin/perl
# -*- mode: perl; perl-indent-level: 2; indent-tabs-mode: nil -*-
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

##
## TODO: Make a separate module from parse_my_file.
## TODO: Make a separate module for code and docs generation.
##

use strict;
use warnings;

use File::Spec;
use Getopt::Long;
use IO::File;

sub year_seq ()
{
  my $first_year = 2011;
  my $last_year = (localtime time)[5] + 1900;

  return join ', ', $first_year .. $last_year;
}

my $glob_magic_toplevel = 'top-level';
my $glob_script_name = (File::Spec->splitpath ($0))[2];
my $glob_header =
'## This file was generated by ' . $glob_script_name . ' script.
##
## Copyright ' . year_seq . ' Krzesimir Nowak
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
##';

##
## If no parameters are passed then it returns a newline.
## If one parameter is passed then it returns the parameter with newline
## appended to it.
##
sub nl
{
  return (shift or '') . "\n";
}

##
## Takes a line, parses it and gets a name of tag.
##
sub get_tag_from_line ($)
{
  my $line_pair = shift;
  my $line = $line_pair->[1];

  $line = substr ($line, 2);
  if ($line =~ /[^a-zA-Z0-9_:-]/)
  {
    print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': The only allowed characters in tags are a-z, A-Z, 0-9, underscore, colon and dash.');
  }

  return $line;
}

##
## Takes a line and macro store, applies macros to the line and returns it.
sub apply_macros ($$)
{
  my ($line_pair, $macros) = @_;
  my $plain_line = $line_pair->[1];

  while ($plain_line =~ /!([^!]*?)!/)
  {
    my $used_macro = $1;

    unless ($used_macro)
    {
      print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': Cannot use empty macro.');
      exit 1;
    }
    if ($used_macro =~ /[^a-zA-Z0-9_]/)
    {
      print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': The only allowed characters in tags are a-z, A-Z, 0-9, and underscore.');
      exit 1;
    }
    unless (exists $macros->{$used_macro})
    {
      print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': Use of the unknown macro `' . $used_macro . '\'.');
      exit 1;
    }

    $plain_line =~ s/!$used_macro!/$macros->{$used_macro}/g;
  }
  return $plain_line;
}

##
## Takes a line and macro store, parses the line and gets a list of attributes.
## Macro store is used in case of macro usage in line.
##
sub get_attributes_from_line ($$)
{
  my ($line_pair, $macros) = @_;
  my $plain_line = apply_macros ($line_pair, $macros);

  $plain_line = substr ($plain_line, 2);

  my @entries = split (',', $plain_line);
  my $name = undef;
  my $mode = undef;
  my $value = undef;
  my @attributes = ();
  my %mode_to_bool =
  (
    't' => 1,
    'f' => 0
  );

  for my $entry (@entries)
  {
    if ($entry =~ /^\[/)
    {
      if (defined $name or defined $mode or defined $value)
      {
        print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': Badly formed attributes - probably previous attribute triplet is not closed.');
        exit 1;
      }

      $name = substr ($entry, 1);
    }
    elsif ($entry =~ /\]$/)
    {
      unless (defined $mode)
      {
        print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': Badly formed attributes - no mode defined.');
        exit 1;
      }

      $value = substr ($entry, 0, length ($entry) - 1);

      if ($value eq '')
      {
        $value = undef;
      }

      my $attribute =
      {
        'name' => $name,
        'mandatory' => $mode,
        'default_value' => $value
      };

      push @attributes, $attribute;
      $name = undef;
      $mode = undef;
      $value = undef;
    }
    else
    {
      unless (defined $name)
      {
        print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': Badly formed attributes - no name defined.');
        exit 1;
      }

      unless (exists $mode_to_bool{$entry})
      {
        print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': Badly formed attributes - expected either `t\' or `f\' in mode field.');
        exit 1;
      }

      $mode = $mode_to_bool{$entry};
    }
  }

  if (defined $name or defined $mode or defined $value)
  {
    print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': Badly formed attributes - line ended too early.');
    exit 1;
  }

  @attributes = sort { $a->{'name'} cmp $b->{'name'} } @attributes;

  return \@attributes;
}

##
## Takes a line and macro store, parses the line and gets a list of kids.
## Macro store is used in case of macro usage in line.
##
sub get_kids_from_line ($$)
{
  my ($line_pair, $macros) = @_;
  my $plain_line = apply_macros ($line_pair, $macros);
  my @kids = sort (split (',', substr ($plain_line, 2)));


  return \@kids;
}

##
## Takes a line and macro store, parses the line and gets a list of parents.
## Macro store is used in case of macro usage in line.
##
sub get_parents_from_line ($$)
{
  my ($line_pair, $macros) = @_;
  my $plain_line = apply_macros ($line_pair, $macros);
  my @parents = sort (split (',', substr ($plain_line, 2)));

  return \@parents;
}

##
## Takes a line and macro store, parses the line and adds new macro to store.
##
sub add_new_macro ($$)
{
  my ($line_pair, $macros) = @_;
  my $line = substr ($line_pair->[1], 2);
  my $first_comma = index ($line, ',');

  if ($first_comma < 1)
  {
    print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': Empty macro name is not allowed.');
    exit 1;
  }

  my $macro_name = substr ($line, 0, $first_comma);

  if (exists $macros->{$macro_name})
  {
    print STDERR nl ('`' . $line_pair->[1] . '\' at line ' . $line_pair->[0] . ': Macro `' . $macro_name . '\' was already defined.');
    exit 1;
  }

  my $macro_value = substr (apply_macros ($line_pair, $macros), 2 + $first_comma + 1);

  $macros->{$macro_name} = $macro_value;
}

##
## Takes a filename, parses the file of given name and creates a structure
## that looks as follows:
## $tag =>
## {
##   'attributes' => [{'name' => attr1, 'mandatory' => 0/1, 'default_value' => ?/undef}, ...],
##   'kids' => [tag1, ...]
##   'parents' => [parent1, ...]
## }
##
sub parse_my_file ($)
{
  my $filename = shift;
  my $fd = IO::File->new ($filename, 'r');

  unless (defined $fd)
  {
    print STDERR nl ('Could not open file `' . $filename . '\' for reading.');
    exit 1;
  }

  my @contents = $fd->getlines;

  $fd->close;

  my $current_tag = undef;
  my $current_attributes = undef;
  my $current_kids = undef;
  my $current_parents = undef;
  my %structure = ();
  my %macros = ();
  my $line_no = 0;

  for my $line (@contents)
  {
    chomp $line;
    ++$line_no;
    next unless $line;
    next if $line =~ /^#/;

    my $line_pair = [$line_no, $line];

    if ($line =~ /^t\^/)
    {
      if (defined $current_tag or defined $current_attributes or defined $current_kids or defined $current_parents)
      {
        print STDERR nl ('`' . $line . '\' at line ' . $line_no . ': Previous block was not finished.');
        exit 1;
      }
      $current_tag = get_tag_from_line ($line_pair);

      if (exists $structure{$current_tag})
      {
        print STDERR nl ('`' . $line . '\' at line ' . $line_no . ': Tag `' . $current_tag . '\' was already defined.');
        exit 1;
      }
    }
    elsif ($line =~ /^a\^/)
    {
      unless (defined $current_tag)
      {
        print STDERR nl ('`' . $line . '\' at line ' . $line_no . ': Expected t^.');
        exit 1;
      }

      $current_attributes = get_attributes_from_line ($line_pair, \%macros);
    }
    elsif ($line =~ /^k\^/)
    {
      unless (defined $current_attributes)
      {
        print STDERR nl ('`' . $line . '\' at line ' . $line_no . ': Expected a^.');
        exit 1;
      }

      $current_kids = get_kids_from_line ($line_pair, \%macros);
    }
    elsif ($line =~ /^p\^/)
    {
      unless (defined $current_kids)
      {
        print STDERR nl ('`' . $line . '\' at line ' . $line_no . ': Expected k^.');
        exit 1;
      }

      $current_parents = get_parents_from_line ($line_pair, \%macros);
      $structure{$current_tag} =
      {
        'attributes' => $current_attributes,
        'kids' => $current_kids,
        'parents' => $current_parents
      };

      $current_tag = undef;
      $current_attributes = undef;
      $current_kids = undef;
      $current_parents = undef;
    }
    elsif ($line =~ /^m\^/)
    {
      add_new_macro ($line_pair, \%macros);
    }
    else
    {
      print STDERR nl ('`' . $line . '\' at line ' . $line_no . ': Could not parse this line.');
      exit 1;
    }
  }
  return \%structure;
}

##
## Takes tag name and transforms it so it can be used as a function name.
##
sub func_from_tag ($)
{
  my $tag = shift;
  my $func_tag = lc ($tag);

  $func_tag =~ s/\W+/_/g;

  return $func_tag;
}

##
## Takes data structure, output directory, package prefix and writes handlers
## for every tag's attributes.
##
sub write_tag_handlers ($$$)
{
  my ($merge, $output_dir, $package_prefix) = @_;
  my $pm = 'Tags';
  my $tags_handlers_name = File::Spec->catfile ($output_dir, 'Common', $pm . '.pm');
  my $tags_handlers_fd = IO::File->new ($tags_handlers_name, 'w');

  unless (defined $tags_handlers_fd)
  {
    print STDERR nl ('Failed to open ' . $tags_handlers_name . ' for writing.');
    exit 1;
  }

  print STDOUT nl ('Writing ' . $tags_handlers_name . '.');

  my $package_name = $package_prefix . '::Common::' . $pm;
  my $contents = nl ($glob_header) .
                 nl () .
                 nl ('package ' . $package_name . ';') .
                 nl () .
                 nl ('use strict;') .
                 nl ('use warnings;') .
                 nl () .
                 nl ('use ' . $package_prefix . '::Common::Misc;') .
                 nl ();
  my @handlers = ();

  while (my ($tag, $desc) = each (%{$merge}))
  {
    if ($tag eq $glob_magic_toplevel)
    {
      next;
    }

    my $attributes = $desc->{'attributes'};
    my @mandatory_atts = ();
    my @optional_atts = ();

    foreach my $att (@{$attributes})
    {
      my $att_name = $att->{'name'};
      my $default_value = $att->{'default_value'};

      unless (defined $default_value)
      {
        $default_value = 'undef';
      }

      my $pair = [$att_name, $default_value];

      if ($att->{'mandatory'})
      {
        push @mandatory_atts, $pair;
      }
      else
      {
        push @optional_atts, $pair;
      }
    }

    my $handler .= nl ('sub get_' . func_from_tag ($tag) . '_params (%)') .
                   nl ('{') .
                   nl ('  return ' . $package_prefix . '::Common::Misc::extract_values') .
                   nl ('  [');

    {
      my @att_lines = ();

      foreach my $att (@mandatory_atts)
      {
        push @att_lines, '    [\'' . $att->[0] . '\', ' . $att->[1] . ']';
      }
      $handler .= nl (join ((nl ','), @att_lines)) .
                  nl ('  ],') .
                  nl ('  [');
      @att_lines = ();

      foreach my $att (@optional_atts)
      {
        push @att_lines, '    [\'' . $att->[0] . '\', ' . $att->[1] . ']';
      }
      $handler .= nl (join ((nl ','), @att_lines)) .
                  nl ('  ],') .
                  nl ('  @_;') .
                  nl ('}') .
                  nl ();
      push @handlers, $handler;
    }
  }

  $contents .= nl (join nl, sort (@handlers)) .
               nl ('1; # indicate proper module load.');
  $tags_handlers_fd->print ($contents);
  $tags_handlers_fd->close;
}

##
## This unreadable function takes tag as a parameter and transforms it so it
## can be used as a package name.
##
sub module_from_tag ($)
{
  # - splits 'foo-BAR:bAz' to 'foo', 'BAR' and 'bAz'
  # - changes 'foo' to 'Foo', 'BAR' to 'Bar' and 'bAz' to 'Baz'
  # - joins 'Foo', 'Bar' and 'Baz' into one string 'FooBarBaz'
  # - returns the joined string
  return join '', map { ucfirst lc } (split /\W+/, shift);
}

##
## Takes data structure, output directory, package prefix and writes handlers
## for every tag's children.
##
sub write_tag_modules ($$$$)
{
  my ($merge, $output_dir, $package_prefix, $api_package_prefix) = @_;

  foreach my $tag (sort keys %{$merge})
  {
    my $pm = module_from_tag ($tag);
    my $tags_module_name = File::Spec->catfile ($output_dir, $pm . '.pm');
    my $tags_module_fd = IO::File->new ($tags_module_name, 'w');

    unless (defined $tags_module_fd)
    {
      print STDERR nl ('Failed to open ' . $tags_module_name . ' for writing.');
      exit 1;
    }

    print STDOUT nl ('Writing ' . $tags_module_name . '.');

    my $kids = $merge->{$tag}{'kids'};
    my $package_name = $package_prefix . '::' . $pm;
    my @api_uses = ();
    my @handler_uses = ();
    my @start_bodies = ();
    my @end_bodies = ();
    my @start_store = ();
    my @end_store = ();
    my @subhandlers = ();

    foreach my $kid (@{$kids})
    {
      my $kid_module = $package_prefix . '::' . module_from_tag ($kid);
      my $kid_object = $api_package_prefix . '::' . module_from_tag ($kid);
      my $kid_func = func_from_tag ($kid);
      my $kid_start = '_' . $kid_func . '_start';
      my $kid_end = '_' . $kid_func . '_end';
      my $api_use = 'use ' . $kid_object . ';';
      my $handler_use = 'use ' . $kid_module . ';';
      my $start_body = nl ('sub ' . $kid_start . ' ($$%)') .
                       nl ('{') .
                       nl ('  my ($self, $parser, %atts_vals) = @_;') .
                       nl ('  my $params = ' . $package_prefix . '::Common::Tags::get_' . $kid_func . '_params %atts_vals;') .
                       nl ('  my $state = $parser->get_current_state;') .
                       nl ('  my $object = ' . $kid_object . '->new_with_params ($params);') .
                       nl () .
                       nl ('  $state->push_object ($object);') .
                       nl ('  $self->_call_start_hooks (\'' . $kid . '\');') .
                       nl ('}');
      my $end_body = nl ('sub ' . $kid_end . ' ($$)') .
                     nl ('{') .
                     nl ('  my ($self, $parser) = @_;') .
                     nl () .
                     nl ('  $self->_call_end_hooks (\'' . $kid . '\');') .
                     nl () .
                     nl ('  my $state = $parser->get_current_state;') .
                     nl ('  my $object = $state->get_current_object;') .
                     nl () .
                     nl ('  $state->pop_object;') .
                     nl () .
                     nl ('  my $parent_object = $state->get_current_object;') .
                     nl ('  my $count = $parent_object->get_g_' . $kid_func . '_count;') .
                     nl ('  my $name = ' . $package_prefix . '::Common::Misc::get_object_name $object, $count;') .
                     nl () .
                     nl ('  $parent_object->add_g_' . $kid_func . ' ($name, $object);') .
                     nl ('}');
      my $start_store_member = '    \'' . $kid . '\' => \\&' . $kid_start;
      my $end_store_member = '    \'' . $kid . '\' => \\&' . $kid_end;
      my $subhandler = '    \'' . $kid . '\' => \'' . $kid_module . '\'';

      push @api_uses, $api_use;
      push @handler_uses, $handler_use;
      push @start_bodies, $start_body;
      push @end_bodies, $end_body;
      push @start_store, $start_store_member;
      push @end_store, $end_store_member;
      push @subhandlers, $subhandler;
    }

    my $contents = nl ($glob_header) .
                   nl () .
                   nl ('package ' . $package_name . ';') .
                   nl () .
                   nl ('use strict;') .
                   nl ('use warnings;') .
                   nl () .
                   nl ('use parent qw (' . $package_prefix . '::Common::Base);') .
                   nl () .
                   nl (join nl, @api_uses) .
                   nl () .
                   nl ('use ' . $package_prefix . '::Common::Misc;') .
                   nl ('use ' . $package_prefix . '::Common::Store;') .
                   nl ('use ' . $package_prefix . '::Common::Tags;') .
                   nl () .
                   nl (join nl, @handler_uses) .
                   nl () .
                   nl ('##') .
                   nl ('## private:') .
                   nl ('##') .
                   nl (join nl, @start_bodies) .
                   nl (join nl, @end_bodies) .
                   nl ('##') .
                   nl ('## public:') .
                   nl ('##') .
                   nl ('sub new ($)') .
                   nl ('{') .
                   nl ('  my $type = shift;') .
                   nl ('  my $class = (ref $type or $type or \'' . $package_name . '\');') .
                   nl ('  my $start_store = ' . $package_prefix . '::Common::Store->new') .
                   nl ('  ({') .
                   nl (join ((nl ','), @start_store)) .
                   nl ('  });') .
                   nl ('  my $end_store = ' . $package_prefix . '::Common::Store->new') .
                   nl ('  ({') .
                   nl (join ((nl ','), @end_store)) .
                   nl ('  });') .
                   nl ('  my $subhandlers =') .
                   nl ('  {') .
                   nl (join ((nl ','), @subhandlers)) .
                   nl ('  };') .
                   nl ('  my $self = $class->SUPER::new ($start_store, $end_store, $subhandlers);') .
                   nl () .
                   nl ('  return bless $self, $class;') .
                   nl ('}') .
                   nl () .
                   nl ('1; # indicate proper module load.');
    $tags_module_fd->print ($contents);
    $tags_module_fd->close;
  }
}

##
## Takes data structure, output directory, package prefix and writes API objects
## for every tag.
##
sub write_api_objects ($$$)
{
  my ($merge, $output_dir, $package_prefix) = @_;

  foreach my $tag (sort keys %{$merge})
  {
    my $pm = module_from_tag ($tag);
    my $api_module_name = File::Spec->catfile ($output_dir, $pm . '.pm');
    my $api_module_fd = IO::File->new ($api_module_name, 'w');

    unless (defined $api_module_fd)
    {
      print STDERR nl ('Failed to open ' . $api_module_name . ' for writing.');
      exit 1;
    }

    print STDOUT nl ('Writing ' . $api_module_name . '.');

    my $tag_desc = $merge->{$tag};
    my $kids = $tag_desc->{'kids'};
    my $package_name = $package_prefix . '::' . $pm;
    my @uses = ();
    my @groups = ();
    my @get_group_member_by_name_subs = ();
    my @get_group_member_by_index_subs = ();
    my @get_group_member_count_subs = ();
    my @add_member_to_group_subs = ();

    foreach my $kid (@{$kids})
    {
      my $kid_func = func_from_tag ($kid);
      my $kid_group = 'group_' . $kid_func;
      my $use = 'use ' . $package_prefix . '::' . module_from_tag ($kid) . ';';
      my $group = '    \'' . $kid_group . '\'';
      my $get_group_member_by_name_sub = nl ('sub get_g_' . $kid_func . '_by_name ($$)') .
                                         nl ('{') .
                                         nl ('  my ($self, $name) = @_;') .
                                         nl () .
                                         nl ('  return $self->_get_group_member_by_name (\'' . $kid_group . '\', $name);') .
                                         nl ('}');
      my $get_group_member_by_index_sub = nl ('sub get_g_' . $kid_func . '_by_index ($$)') .
                                          nl ('{') .
                                          nl ('  my ($self, $index) = @_;') .
                                          nl () .
                                          nl ('  return $self->_get_group_member_by_index (\'' . $kid_group . '\', $index);') .
                                          nl ('}');
      my $get_group_member_count_sub = nl ('sub get_g_' . $kid_func . '_count ($)') .
                                       nl ('{') .
                                       nl ('  my $self = shift;') .
                                       nl () .
                                       nl ('  return $self->_get_group_member_count (\'' . $kid_group . '\');') .
                                       nl ('}');
      my $add_member_to_group_sub = nl ('sub add_g_' . $kid_func . ' ($$$)') .
                                    nl ('{') .
                                    nl ('  my ($self, $member_name, $member) = @_;') .
                                    nl ('') .
                                    nl ('  $self->_add_member_to_group (\'' . $kid_group .'\', $member_name, $member);') .
                                    nl ('}');

      push @uses, $use;
      push @groups, $group;
      push @get_group_member_by_name_subs, $get_group_member_by_name_sub;
      push @get_group_member_by_index_subs, $get_group_member_by_index_sub;
      push @get_group_member_count_subs, $get_group_member_count_sub;
      push @add_member_to_group_subs, $add_member_to_group_sub;
    }

    my $atts = $tag_desc->{'attributes'};
    my @attributes = ();
    my @get_attribute_subs = ();
    my @set_attribute_subs = ();
    my @set_params = ();

    foreach my $att (@{$atts})
    {
      my $name = $att->{'name'};
      my $attribute_func = func_from_tag ($name);
      my $attribute_name = 'attribute_' . $attribute_func;
      my $attribute = '    \'' . $attribute_name . '\'';
      my $set_attribute_sub_name = 'set_a_' . $attribute_func;
      my $get_attribute_sub = nl ('sub get_a_' . $attribute_func . ' ($)') .
                              nl ('{') .
                              nl ('  my ($self) = @_;') .
                              nl () .
                              nl ('  return $self->_get_attribute (\'' . $attribute_name . '\');') .
                              nl ('}');
      my $set_attribute_sub = nl ('sub ' . $set_attribute_sub_name . ' ($$)') .
                              nl ('{') .
                              nl ('  my ($self, $value) = @_;') .
                              nl () .
                              nl ('  $self->_set_attribute (\'' . $attribute_name . '\', $value);') .
                              nl ('}');
      my $set_param = '  $self->' . $set_attribute_sub_name . ' ($params->{\'' . $name . '\'});';

      push @attributes, $attribute;
      push @get_attribute_subs, $get_attribute_sub;
      push @set_attribute_subs, $set_attribute_sub;
      push @set_params, $set_param;
    }

    my $contents = nl ($glob_header) .
                   nl () .
                   nl ('package ' . $package_name . ';') .
                   nl () .
                   nl ('use strict;') .
                   nl ('use warnings;') .
                   nl () .
                   nl ('use parent qw (' . $package_prefix . '::Common::Base);') .
                   nl () .
                   nl (join nl, @uses) .
                   nl () .
                   nl ('sub new ($)') .
                   nl ('{') .
                   nl ('  my $type = shift;') .
                   nl ('  my $class = (ref $type or $type or \'' . $package_name . '\');') .
                   nl ('  my $groups =') .
                   nl ('  [') .
                   nl (join ((nl ','), @groups)) .
                   nl ('  ];') .
                   nl ('  my $attributes =') .
                   nl ('  [') .
                   nl (join ((nl ','), @attributes)) .
                   nl ('  ];') .
                   nl ('  my $self = $class->SUPER::new ($groups, $attributes);') .
                   nl () .
                   nl ('  bless $self, $class;') .
                   nl ('  return $self;') .
                   nl ('}') .
                   nl () .
                   nl ('sub new_with_params ($$)') .
                   nl ('{') .
                   nl ('  my ($type, $params) = @_;') .
                   nl ('  my $self = ' . $package_name . '::new $type;') .
                   nl () .
                   nl (join nl, @set_params) .
                   nl () .
                   nl ('  return $self;') .
                   nl ('}') .
                   nl () .
                   nl (join nl, @get_group_member_by_name_subs) .
                   nl () .
                   nl (join nl, @get_group_member_by_index_subs) .
                   nl () .
                   nl (join nl, @get_group_member_count_subs) .
                   nl () .
                   nl (join nl, @add_member_to_group_subs) .
                   nl () .
                   nl (join nl, @get_attribute_subs) .
                   nl () .
                   nl (join nl, @set_attribute_subs) .
                   nl () .
                   nl ('1; # indicate proper module load.');

    $api_module_fd->print ($contents);
    $api_module_fd->close;
  }
}

##
## Takes tag name and transforms it so it can be used as an XML name.
##
sub xml_from_tag ($)
{
  my $tag = shift;
  my $func_tag = lc ($tag);

  $func_tag =~ s/\W+/-/g;

  return $func_tag;
}

##
## Takes data structure and writes docs for every tag into gi-gir-reference.xml.
##
sub write_docs ($)
{
  my $merge = shift;
  my $docs_name = 'gi-gir-reference.xml';
  my $docs_fd = IO::File->new ($docs_name, 'w');

  unless (defined $docs_fd)
  {
    print STDERR nl ('Failed to open ' . $docs_name . ' for writing.');
    exit 1;
  }

  print STDOUT nl ('Writing ' . $docs_name . '.');

  my $contents = nl ('<chapter id="gi-gir-reference">') .
                 nl () .
                 nl ('  <title>The GIR XML format</title>') .
                 nl () .
                 nl ('  <para>') .
                 nl ('    This chapter describes the GIR XML markup format.') .
                 nl ('  </para>');
  my @refsects = ();

  foreach my $tag (sort keys %{$merge})
  {
    if ($tag eq $glob_magic_toplevel)
    {
      next;
    }

    my $desc = $merge->{$tag};
    my $parents = $desc->{'parents'};
    my @parent_links = [];

    foreach my $parent (@{$parents})
    {
      my $parent_link = '      <link linkend="gi-gir-' . xml_from_tag ($parent) . '">' . $parent . '</link>';

      push @parent_links, $parent_link;
    }

    my $refsect = nl ('    <refsect2 id="gi-gir-' . xml_from_tag ($tag) . '">') .
                  nl ('      <title><emphasis>' . $tag . '</emphasis> node</title>') .
                  nl ();
    my $parent_string = undef;

    if (@parent_links > 1)
    {
      $parent_string = '      Parent nodes:';
    }
    elsif (@parent_links == 1)
    {
      $parent_string = '      Parent node:';
    }

    if (defined $parent_string)
    {
      $refsect .= nl ($parent_string) .
                  nl (join ((nl ','), @parent_links) . '.');
    }

    my $kids = $desc->{'kids'};
    my @kid_links = [];

    foreach my $kid (@{$kids})
    {
      my $kid_link = '      <link linkend="gi-gir-' . xml_from_tag ($kid) . '">' . $kid . '</link>';

      push @kid_links, $kid_link;
    }

    if (@{$kids})
    {
      $refsect .= nl ('      Possible children:') .
                  nl (join ((nl ','), @kid_links) . '.');
    }

    my $attributes = $desc->{'attributes'};
    my @mandatory_atts = ();
    my @optional_atts = ();

    foreach my $att (@{$attributes})
    {
      my $att_name = $att->{'name'};
      my $default_value = $att->{'default_value'};
      my $att_string = $att_name;

      if (defined $default_value)
      {
        $att_string .= ' (' . $default_value . ')';
      }

      if ($att->{'mandatory'})
      {
        push @mandatory_atts, $att_string;
      }
      else
      {
        push @optional_atts, $att_string;
      }
    }

    if (@mandatory_atts)
    {
      $refsect .= nl ('      Mandatory attributes (mandatory value when such exists):') .
                  nl (join ((nl ','), @mandatory_atts) . '.');
    }
    if (@optional_atts)
    {
      $refsect .= nl ('      Optional attributes (default value when attribute is not specified):') .
                  nl (join ((nl ','), @optional_atts) . '.');
    }

    $refsect .= nl ('      <example>') .
                nl ('        <title>A GIR fragment showing an namespace node</title>') .
                nl ('        <programlisting><![CDATA[') .
                nl ('        TODO]]></programlisting>') .
                nl ('      </example>') .
                nl () .
                nl ('    </refsect2>');
    push @refsects, $refsect;
  }

  $contents .= nl (join nl, sort (@refsects)) .
               nl ('</chapter>');
  $docs_fd->print ($contents);
  $docs_fd->close;
}

##
## This is where script begins - this function parses parameters, then parses
## file given as parameter and outputs some files.
##
sub main ()
{
  my $output_dir = undef;
  my $package_prefix = undef; # Gir::Handlers
  my $api_package_prefix = undef; # Gir::Api
  my $api_output_dir = undef;
  my $file_to_parse = ();
  my $generate_docs = 0;
  my $help = 0;
  my $opt_parse_result = GetOptions ('output-dir|o=s' => \$output_dir,
                                     'package-prefix|p=s' => \$package_prefix,
                                     'api-package-prefix|a=s' => \$api_package_prefix,
                                     'api-output-dir|d=s' => \$api_output_dir,
                                     'generate-docs|g' => \$generate_docs,
                                     'help|h' => \$help,
                                     'input-file|i=s' => \$file_to_parse
                                    );

  if (not $opt_parse_result or not $file_to_parse or not $output_dir or
      not $package_prefix or not $api_package_prefix or not $api_output_dir
      or $help
     )
  {
    print STDERR nl ($glob_script_name . ' PARAMS') .
                 nl ('PARAMS:') .
                 nl ('  --help | -h - this help') .
                 nl ('  --output-dir=<name> | -o <name> - output directory') .
                 nl ('  --package-prefix=<prefix> | -p <prefix> - prefix for package names') .
                 nl ('  --api-package-prefix=<prefix> | -a <prefix> - prefix for api package names') .
                 nl ('  --api-output-dir=<name> | -d <name> - output directory for api packages') .
                 nl ('  [--input-file=<filename> | -i <filename> - name of file containing a description of structure]') .
                 nl ('  [--generate-docs | -g - generate documentation]');
    exit not $help;
  }

  print STDOUT nl ('Parsing ' . (File::Spec->splitpath ($file_to_parse))[2] . '.');

  my $structure = parse_my_file ($file_to_parse);

  write_tag_handlers ($structure, $output_dir, $package_prefix);
  write_tag_modules ($structure, $output_dir, $package_prefix, $api_package_prefix);
  write_api_objects ($structure, $api_output_dir, $api_package_prefix);
  if ($generate_docs)
  {
    write_docs ($structure);
  }

  exit 0;
}

# Go!
main;
