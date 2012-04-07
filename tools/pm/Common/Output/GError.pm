# -*- mode: perl; perl-indent-level: 2; indent-tabs-mode: nil -*-
# gmmproc - Common::Output::GError module
#
# Copyright 2012 glibmm development team
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
#

package Common::Output::GError;

use strict;
use warnings;

sub nl
{
  return Common::Output::Shared::nl @_;
}

sub _output_gerror ($$$)
{
  my ($wrap_parser, $cpp_type, $members) = @_;
  my $string_members = Common::Output::Shared::convert_members_to_strings ($members);
  my $section_manager = $wrap_parser->get_section_manager;
  my $namespaces = $wrap_parser->get_namespaces;
  my $wrap_init = 'wrap_init()';

  if (@{$namespaces})
  {
    $wrap_init = '::' . $namespaces->[0] . '::' . $wrap_init;
  }

  my $code_string = nl ('class ' . $cpp_type . ' : public Glib::Error') .
                    nl ('{') .
                    nl ('public:') .
                    nl ('  enum Code') .
                    nl ('  {') .
                    nl (join nl (','), @{$string_members}) .
                    nl ('  };') .
                    nl () .
                    nl ('  ' . $cpp_type . '(Code error_code, const Glib::ustring& error_message);') .
                    nl ('  explicit ' . $cpp_type . '(GError* gobject);') .
                    nl ('  Code code() const;') .
                    nl () .
                    nl (Common::Output::Shared::doxy_skip_begin) .
                    nl ('private:') .
                    nl () .
                    nl ('  static void throw_func(GError* gobject);') .
                    nl () .
                    nl ('  friend void ' . $wrap_init . '; // uses throw_func()') .
                    nl (Common::Output::Shared::doxy_skip_end) .
                    nl ('};') .
                    nl ();

  $section_manager->append_string_to_section ($code_string, $wrap_parser->get_main_section);
}

sub _output_gerror_gtype_h ($$$)
{
  my ($wrap_parser, $cpp_type, $get_type_func) = @_;

  Common::Output::Shared::output_enum_gtype_func_h $wrap_parser, $cpp_type, Common::Output::Shared::ENUM_TYPE, $get_type_func;
}

sub _output_gerror_impl ($$$)
{
  my ($wrap_parser, $cpp_type, $domain) = @_;
  my $container_cpp_type = Common::Output::Shared::get_full_cpp_type $wrap_parser;
  my $full_cpp_type = join '::', $container_cpp_type, $cpp_type;
  my $section_manager->get_section_manager;
  my $code_string = nl (Common::Output::Shared::open_namespaces $wrap_parser) .
                    nl ($full_cpp_type . '::' . $cpp_type . '(' . $full_cpp_type . '::Code error_code, const Glib::ustring& error_message)') .
                    nl (':') .
                    nl ('  Glib::Error(g_quark_from_static_string ("' . $domain . '"), error_code, error_message)') .
                    nl ('{}') .
                    nl () .
                    nl ($full_cpp_type . '::' . $cpp_type . '(GError* gobject)') .
                    nl (':') .
                    nl ('  Glib::Error(gobject)') .
                    nl ('{}') .
                    nl () .
                    nl ($full_cpp_type . '::Code ' . $full_cpp_type . '::code() const') .
                    nl ('{') .
                    nl ('  return static_cast<Code>(Glib::Error::code());') .
                    nl ('}') .
                    nl () .
                    nl ('// static') .
                    nl ('void ' . $full_cpp_type . '::throw_func(GError* gobject)') .
                    nl ('{') .
                    nl ('  throw ' . $full_cpp_type . '(gobject);') .
                    nl ('}') .
                    nl () .
                    Common::Output::Shared::close_namespaces $wrap_parser;
  my $section = Common::Output::Shared::get_section $wrap_parser, Common::Sections::CC_END;

  $section_manager->append_string_to_section ($code_string, $section);
}

sub _output_gerror_gtype_cc ($$$)
{
  my ($wrap_parser, $cpp_type, $get_type_func) = @_;

  Common::Output::Shared::output_enum_gtype_func_cc ($wrap_parser, $cpp_type, $get_type_func);
}

sub output ($$$$$)
{
  my ($wrap_parser, $cpp_type, $members, $domain, $get_type_func) = @_;

  _output_gerror $wrap_parser, $cpp_type, $members;
  _output_gerror_gtype_h $wrap_parser, $cpp_type, $get_type_func;
  _output_gerror_impl $wrap_parser, $cpp_type, $domain;
  _output_gerror_gtype_cc $wrap_parser, $cpp_type, $get_type_func;
}

1; # indicate proper module load.