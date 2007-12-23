package Package::FromData;
use strict;
use warnings;
use feature ':5.10';

1;
__END__

=head1 NAME

Package::FromData - generate a package with methods and variables from
a data structure

=head1 SYNOPSIS

Given a data structure like this:

  my $packages = { 
      'Foo::Bar' => {
          constructors   => ['new'],        # my $foo_bar = Foo::Bar->new
          static_methods => {               # Foo::Bar->method
              next_word => [                # Foo::Bar->next_word
                  ['foo']       => 'bar',   # Foo::Bar->next_word('foo') = bar
                  ['hello']     => 'world',
                  [qw/bar baz/] => 'baz',   # Foo::Bar->next_word(qw/foo bar/) 
                                            #    = baz
                  'default_value'
              ],
              one => [ 1 ],                 # Foo::Bar->one = 1
          },
          methods => {
              wordify => [ '...' ],         # $foo_bar->wordify = '...'
                                            # Foo::Bar->wordify = <exception>
          
              # baz always returns Foo::Bar::Baz->new
              baz     => [ { new => 'Foo::Bar::Baz' } ],
          },
          functions => {
              map_foo_bar => [ 'foo' => 'bar', 'bar' => 'foo' ]
          }
          variables => {
              "$VERSION" => '42',           # $Foo::Bar::VERSION
              "@ISA"     => ['Foo'],        # @Foo::Bar::ISA
              "%FOO"     => {Foo => 'Bar'}, # %Foo::Bar::FOO
          },
      },
  };

and some code like this:

   use Package::FromData;
   create_package_from_data($packages);

create the package C<Foo::Bar> and the functions as specified above.

After you C<create_package_from_data>, you can use C<Foo::Bar> as though
it were a module you wrote:

   my $fb = Foo::Bar->new       # blessed hash reference
   $fb->baz                     # a new Foo::Bar::Baz
   $fb->wordify                 # '...'
   $fb->next_word('foo')        # 'bar'
   Foo::Bar->next_word('foo')   # 'bar'
   Foo::Bar->baz                # <exception>, it's an instance method
   Foo::Bar::map_foo_bar('foo') # 'bar'
   $Foo::Bar::VERSION           # '42'

Not a very useful package, but you get the idea.

=head1 DESCRIPTION

This module creates a package with predefined methods, functions, and
variables from a data structure.  It's used for testing (mock objects)
or experimenting.  The idea is that you define a package containing
functions that return values based on keys, and the rest of your app
uses this somehow.  (I use it so that C<< Jifty->... >> or 
C<< Catalyst.uri_for >> will work in templates being served via
L<App::TemplateServer|App::TemplateServer>.)

=head2 THE TOP

The top level data structure is a hash of package names / package
definition hash pairs.

=head2 PACKAGE DEFINITION HASHES

Each package is defined by a package definition hash.  This can contain
a few keys:

=head3 constructors

An arrayref of constructors to be generated.  The generated code looks like:

   sub <the name> {
       my $class = shift;
       return bless {}, $class;
   }

=head3 functions

The functions key should point to a hash of function names / function
definiton array pairs.

=head4 FUNCTION DEFINITION ARRAYS

The function definition array is a list of pairs followed by an
optional single value.  The pairs are treated like a @_ => result of
function hash, and the optional single element is used as a default
return value.

The pairs are of the form ARRAYREF => SCALAR|ARRAYREF|SEPECIAL.  To make
C<function('foo','bar')> return C<baz>, you would add a pair like C<[
'foo', 'bar' ], 'baz'> to the definition hash.  To return a bare list,
use a arrayref; C<['foo','bar'], ['foo','bar']>.  To return a
reference to a list, nest an arrayref in the arrayref; C<foo('bar') =
['baz']>.

To return different values in scalar or list context, pass a hash as
the definion:

    { scalar => '42', list => [qw/contents of the list/] }

To return a hashref, just say C<< [{ ... }] >>.

=head3 methods

Like functions, but the first argument (<$self>) is ignored.

=head2 static_methods

Like methods, but can be invoked against the class name instead of 
and instance of the class.

=head2 variables

A hash of variable name (including sigil) / value pairs.  Keys
starting with @ or % must point to the appropriate reference type.

=head1 EXPORTS

C<create_package_from_data>

=head1 FUNCTIONS

=head2 create_package_from_data

See L</DESCRIPTION> above.

=head1 BUGS

Probably.  Report them to RT.

=head1 CODE REPOSITORY

The git repository is at L<http://git.jrock.us/> and can be cloned:

    git clone git://git.jrock.us/Package-FromData

=head1 AUTHOR

Jonathan Rockway C<< <jrockway@cpan.org> >>

=head1 COPYRIGHT

Copyright (c) 2007, Jonathan Rockway.  This module free software.  You may
redistribute it under the same terms as Perl itself.
