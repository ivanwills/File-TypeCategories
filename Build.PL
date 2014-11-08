use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'File::TypeCategories',
    license           => 'perl',
    dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
    dist_version_from => 'lib/File/TypeCategories.pm',
    requires          => {
        'perl'             => 5.008,
    },
    build_requires => {
        'Test::More'       => 0,
        'Test::NoWarnings' => 0,
    },
    share_dir => {
        dist => [
            'config',
        ],
    },
    add_to_cleanup     => [ 'File-TypeCategories-*' ],
    create_makefile_pl => 'traditional',
    create_license     => 1,
    meta_merge => {
        resources => {
            repository => 'git://github.com/ivanwills/File-TypeCategories.git',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=File::TypeCategories',
        },
    },
);

$builder->create_build_script();
