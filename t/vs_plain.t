#!perl
use strict;
use warnings;
use Test::More tests => 28;
use Filesys::Virtual::Plain;
use Filesys::Virtual::SSH;
use File::Slurp::Tree;
use Cwd;

if (eval { require Test::Differences; 1 }) {
    no warnings 'redefine';
    *is_deeply = \&Test::Differences::eq_or_diff;
}

# A comparitive test against Filesys::Virtual::Plain, more so I
# understand the api as Filesys::Virtual is low on docs

my $start_tree = {
    foo => "I r foo\n",
    bar => {
        baz => "I r not foo\n",
    },
};

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
    is_deeply( [ $vfs->list( "/" ) ],
               [ sort qw( . .. ), keys %$start_tree ],
               "list /" );

    is_deeply( [ $vfs->list( "" ) ],
               [ sort qw( . .. ), keys %$start_tree ],
               "list ''" );

    is_deeply( [ $vfs->list( "foo" ) ],
               [ "foo" ],
               "list foo" );

    is_deeply( [ $vfs->list( "i_do_not_exist" ) ],
               [ ],
               "list i_do_not_exist" );

    is_deeply( [ $vfs->list( "/bar" ) ],
               [ sort qw( . .. ), keys %{ $start_tree->{bar} } ],
               "list /bar" );

    is_deeply( [ $vfs->list( "/bar" ) ],
               [ sort qw( . .. ), keys %{ $start_tree->{bar} } ],
               "list bar" );

    is( $vfs->chdir( 'bar' ), "/bar", "chdir bar" );
    is( $vfs->cwd, "/bar", "cwd is /bar" );

    is_deeply( [ $vfs->list( "" ) ],
               [ sort qw( . .. ), keys %{ $start_tree->{bar} } ],
               "list ''" );

    is_deeply( [ $vfs->list( "/" ) ],
               [ sort qw( . .. ), keys %$start_tree ],
               "list /" );

    my @ls_al = $vfs->list_details("");
    is( scalar @ls_al, 3, "list_details pulled back 3 things");
    diag( $ls_al[2] );
    like( $ls_al[2], qr/\sbaz$/, "seemed to get bar" );

}


