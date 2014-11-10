#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings qw/warning had_no_warnings/;
use File::TypeCategories;

$ENV{HOME} = 'config';
files_ok();
files_nok();
files_exclude();
files_include();
files_perl();
types_match();
done_testing();

sub files_ok {
    my $files = File::TypeCategories->new();
    my @ok_files = qw{
        /blah/file
        /blah/file~other
        /blah/logo
        /blah/test.t
    };

    for my $file (@ok_files) {
        ok($files->file_ok($file), $file);
    }

    return;
}

sub files_nok {
    my $files = File::TypeCategories->new();
    my @nok_files = qw{
        /blah/CVS
        /blah/CVS/thing
        /blah/file.copy
        /blah/file~
        /blah/.git
        /blah/logs
    };

    for my $file (@nok_files) {
        ok(!$files->file_ok($file), $file);
    }

    return;
}

sub files_exclude {
    my $files = File::TypeCategories->new( exclude => [qw{/test/}] );

    ok($files->file_ok("perl/test"), 'not excluded');
    ok(!$files->file_ok("perl/test/"), 'excluded');

    return;
}

sub files_include {
    my $files = File::TypeCategories->new( include => [qw{/test/}] );

    ok(!$files->file_ok("perl/test"), 'excluded');
    ok($files->file_ok("perl/test/"), 'not excluded');

    return;
}

sub files_perl {
    my $files = File::TypeCategories->new( include_type => [qw{perl}] );

    ok($files->file_ok("bin/tfind"), 'not excluded');

    $files = File::TypeCategories->new( exclude_type => [qw{perl}] );

    ok(!$files->file_ok("bin/tfind"), 'excluded');

    return;
}

sub types_match {
    my $files = File::TypeCategories->new( include_type => [qw{perl}] );

    is(warning { $files->types_match('tfind', 'bad type') }, "No type 'bad type'\n", 'Missing type warned');
    $files->types_match('tfind', 'bad type');
    had_no_warnings('Second call doesn\'t warn');

    ok  $files->types_match('test.t'         , 'perl'), 'test.t          perl test';
    ok !$files->types_match('t/.does.nothing', 'perl'), 't/.does.nothing not perl';
    ok !$files->types_match('t/perlcriticrc' , 'perl'), 't/perlcriticrc  not perl';
    ok  $files->types_match('bin/tfind'      , 'perl'), 'bin/tfind       is perl';

    return;
}
