#!perl
use strict;
use warnings;
use Test::More tests => 3 * 2;
use Filesys::Virtual::Plain;
use Filesys::Virtual::SSH;
use File::Slurp::Tree;
use Cwd;

if (eval { require Test::Differences; 1 }) {
    *is_deeply = \&Test::Differences::eq_or_diff;
}

# A comparitive test against Filesys::Virtual::Plain, more so I
# understand the api as Filesys::Virtual is low on docs

my $start_tree = { foo => "I r foo\n" };

for my $class (map { "Filesys::Virtual::$_" } qw( Plain SSH )) {
    my $root = cwd().'/t/test_root';
    spew_tree( $root => $start_tree );
    isa_ok( my $vfs = $class->new({
        host => 'localhost',
        cwd => '/',
        root_path => $root,
        home_path => '/home',
    }), $class );

    is( $vfs->cwd, "/", "cwd" );
    is_deeply( [ $vfs->list( "/" ) ], [qw( . .. ), keys %$start_tree], "list test_root" );
}

