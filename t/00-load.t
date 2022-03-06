#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;

BEGIN {
    use_ok( 'File::TypeCategories' );
    use_ok( 'File::TypeCategories::Git' );
}

diag( "Testing File::TypeCategories $File::TypeCategories::VERSION, Perl $], $^X" );
done_testing();
