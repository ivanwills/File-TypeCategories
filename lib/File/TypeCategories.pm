package File::TypeCategories;

# Created on: 2014-11-07 16:39:51
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use strict;
use warnings;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use Type::Tiny;
use Types::Standard -types;
use File::ShareDir qw/dist_dir/;
use YAML qw/LoadFile/;

our $VERSION = 0.01;
our %warned_once;

has ignore => (
    is      => 'rw',
    isa     => ArrayRef[Str],
    default => sub{[qw{ ignore }]},
);
has include => (
    is  => 'rw',
    isa => ArrayRef[Str],
);
has exclude => (
    is  => 'rw',
    isa => ArrayRef[Str],
);
has include_type => (
    is      => 'rw',
    isa     => ArrayRef[Str],
    default => sub{[]},
);
has exclude_type => (
    is      => 'rw',
    isa     => ArrayRef[Str],
    default => sub{[]},
);
has symlinks => (
    is      => 'rw',
    isa     => Bool,
    default => 0,
);
has links => (
    is      => 'rw',
    isa     => HashRef,
    default => sub {{}},
);

has type_suffixes => (
    is      => 'rw',
    isa     => HashRef,
    default => sub {{}},
);

sub BUILD {
    my ($self) = @_;

    $ENV{HOME} ||= $ENV{USERPROFILE};
    my $dir = dist_dir('File-TypeCategories');
    my $config_name = '.type_categories.yml';

    for my $config_dir ($dir, $ENV{HOME}, '.') {
        my $config_file = "$config_dir/$config_name";
        next if !-f $config_file;

        my ($conf) = LoadFile($config_file);

        for my $file_type ( keys %{ $conf } ) {
            $self->type_suffixes->{$file_type} ||= {};
            for my $setting ( keys %{ $conf->{$file_type} } ) {
                if ( $setting =~ s/^[+]//xms ) {
                    push @{ $self->type_suffixes->{$file_type}{$setting} }
                         , ref $conf->{$file_type}{$setting} eq 'ARRAY'
                         ? @{ $conf->{$file_type}{$setting} }
                         : $conf->{$file_type}{$setting};
                }
                else {
                    $self->type_suffixes->{$file_type}{$setting}
                         = ref $conf->{$file_type}{$setting} eq 'ARRAY'
                         ? $conf->{$file_type}{$setting}
                         : [ $conf->{$file_type}{$setting} ];
                }
            }
        }
    }

    return;
}

sub file_ok {
    my ($self, $file) = @_;

    for my $ignore (@{ $self->ignore }) {
        return 0 if $self->types_match($file, $ignore);
    }

    return 1 if -d $file;

    my $possible = 0;
    my $matched = 0;
    if ( @{ $self->include_type }) {
        for my $type (@{ $self->include_type }) {
            my $match = $self->types_match($file, $type);
            $possible-- if $match == 2;
            $matched += $match;
        }
        return 0 if $matched <= 0;
    }

    if (!$matched) {
        for my $type (@{ $self->exclude_type }) {
            my $match = $self->types_match($file, $type);
            return 0 if $match && $match != 2;
            $possible++ if $match == 2;
        }
        return 0 if $possible > 0;
    }

    if ($self->include) {
        my $matches = 0;
        for my $include (@{ $self->include }) {
            $matches ||= $file =~ /$include/;
            last if $matches;
        }
        return 0 if !$matches;
    }

    if ($self->exclude) {
        for my $exclude (@{ $self->exclude }) {
            return 0 if $file =~ /$exclude/;
        }
    }

    return 1;
}

sub types_match {
    my ($self, $file, $type) = @_;

    my $types = $self->type_suffixes;

    warn "No type $type" if !exists $types->{$type} && !$warned_once{$type}++;
    return 0 if !exists $types->{$type};

    for my $suffix ( @{ $types->{$type}{definite} } ) {
        return 3 if $file =~ /$suffix/;
    }

    for my $suffix ( @{ $types->{$type}{possible} } ) {
        return 2 if $file =~ /$suffix/;
    }

    if ( $types->{$type}{bang} ) {
        if ( open my $fh, '<', $file ) {
            my $line = <$fh>;
            close $fh;
            return 3 if $line && $line =~ /$types->{$type}{bang}/;
        }
    }

    return 1 if $types->{$type}{none} && $file !~ m{ [^/] [.] [^/]+ $}xms;

    for my $other ( @{ $types->{$type}{other_types} } ) {
        my $match = $self->types_match($file, $other);
        return $match if $match;
    }

    return 0;
}



1;

__END__

=head1 NAME

File::TypeCategories - Determine if files match a specific type

=head1 VERSION

This documentation refers to File::TypeCategories version 0.01

=head1 SYNOPSIS

   use File::TypeCategories;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

A C<File::TypeCategories> object can be used to test if files match the defined
categories.

=head1 SUBROUTINES/METHODS

=over 4

=item C<BUILD ()>

Loads the config file when new is called

=item C<file_ok ($file)>

Determins if a file matches the current config

=item C<types_match ($file, $type)>

Checks if a file matches C<$type>

=back

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2014 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
