#!/usr/bin/perl

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use Test::More;
use Test::Warnings;
use Path::Tiny;
use Data::Dumper qw/Dumper/;

my $module = 'File::TypeCategories::Git';
use_ok( $module );


ignore_ok();
done_testing();

sub ignore_ok {
    my $git_ignore = $module->new( common_dirs => [] );

    my $ignore = $git_ignore->ignores(path(Path::Tiny->cwd, 't'), 1);
    is((scalar @{$ignore->{Config}}), 1, 'Only find the file expected');
    is((scalar @{$ignore->{definite}}), 1, 'Get the full list of ignores');

    is($ignore->{definite}[0], '[.]test[.].*', 'Pass config correctly');

    return;
}
