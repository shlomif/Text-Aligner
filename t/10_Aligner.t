use Test;
use strict;

my $n_tests;
use Text::Aligner;

# MaxKeeper
BEGIN { $n_tests += 7 }

my $mk = Text::Aligner::MaxKeeper->new;
ok( $mk->max, undef);
$mk->remember( $_) for 0, 5, 3, -1, 5, 1;
ok( $mk->max, 5);
$mk->forget( -1);
ok( $mk->max, 5);
$mk->forget( 5);
ok( $mk->max, 5);
$mk->forget( 5);
ok( $mk->max, 3);
$mk->remember( 3);
$mk->remember( 2);
$mk->forget( 3);
ok( $mk->max, 3);
$mk->forget( 3);
ok( $mk->max, 2);

# _compile_alispec
BEGIN { $n_tests += 6 }

BEGIN { *_compile_alispec = \ &Text::Aligner::_compile_alispec }
my @specs = qw( left center right num);
ok( ref( ( _compile_alispec( $_))[ 1]), 'CODE') for @specs, 0.5, 'num(,)', sub {};

# expected positions for combinations of string/specification
BEGIN { $n_tests += 12*7 } # number of strings * number of specs

my @strings =    ( '', qw( x xy xyx xxxyxxxxxx 0 1 1. 12.13 .9 123 6,3));
my %ans = (
    left     =>  [ 0,  qw( 0  0   0          0 0 0  0     0  0   0   0)],
    center   =>  [ 0,  qw( 0  1   1          5 0 0  1     2  1   1   1)],
    right    =>  [ 0,  qw( 1  2   3         10 1 1  2     5  2   3   3)],
    num      =>  [ 0,  qw( 1  2   3         10 1 1  1     2  0   3   3)],
    'num(,)' =>  [ 0,  qw( 1  2   3         10 1 1  2     5  2   3   1)],
    qr/x/    =>  [ 0,  qw( 0  0   0          0 1 1  2     5  2   3   3)],
    qr/y/    =>  [ 0,  qw( 1  1   1          3 1 1  2     5  2   3   3)],

);

while ( my ( $spec, $ans) = each %ans ) {
    my @ans = @$ans;
    my $use_spec = $spec;
    $use_spec = qr/$use_spec/ if $use_spec =~ /\(\?/; # de-stringify Regex
    my $code = ( _compile_alispec( $use_spec))[ 1]; # the width is not tested
    for my $str ( @strings ) {
        my $wanted = shift @ans;
        my $got = $code->( $str);
        my $showstr = "'$str'";
        ok( "($spec, $showstr) -> $got", "($spec, $showstr) -> $wanted");
    }
}

# Text::Aligner class
BEGIN { $n_tests += 1 }

my $ali = Text::Aligner->new;
ok( ref $ali, 'Text::Aligner');

use constant STRINGS =>
#   undef, '', ' ', qw( Z xxZ xxxxxxxxxZ 0 19 .1 9. 9.11 11119.1 1119.11111);
# reduced sample for distribution
    undef, qw( Z xxxxZ 0 9.11 1119.111111);

use constant SPECS => qw( left center right num auto);

BEGIN {
    my $nstr = @{ [ STRINGS ]};
    my $nspec = @{ [ SPECS ]};
    $n_tests += $nspec*( $nstr + 2*$nstr*$nstr); # according to proram below
}

for my $spec ( SPECS ) {
    my $ali = Text::Aligner->new( $spec);
    for my $str ( STRINGS ) {
        my $res = $ali->justify( $str);
        my $diag = 'ok';
        $diag = "new $spec-aligner justifies '$str' to '$res'" unless
        $str eq $res;
        ok( $diag, 'ok');
    }
    for my $init ( STRINGS ) {
        $ali->alloc( $init);
        for my $str ( STRINGS ) {
            my $res = $ali->justify( $str);
            my $diag = '';
            if ( length( $res) != length( $init) ) {
                $diag = "$spec-aligner with '$init' justifies '$str' to '$res' (length)";
            }
            ok( $diag, '');
            $diag = '';
            if ( $spec =~ /num/ and $str =~ /[9Z]/ and $init =~ /[9Z]/ ) {
                my $initloc = index( $init, '9');
                $initloc = index( $init, 'Z') if $init =~ /Z/;
                my $resloc = index( $res, '9');
                $resloc = index( $res, 'Z') if $res =~ /Z/;
                $diag = ( $initloc != $resloc);
            }
            $diag = "$spec-aligner with '$init' justifies '$str' to '$res' (pos)" if $diag;
            ok( $diag, '');
        }
        $ali->_forget( $init);
    }
}

# align() function
BEGIN { $n_tests += 15 }
use Text::Aligner qw( align);
ok( defined &align);

# Basic functionality
my @col = qw( just a test!);
my @save_col = @col; # copy for later
my @res = align( '', @col);
ok( $res[ 0], 'just ');
ok( $res[ 1], 'a    ');
ok( $res[ 2], 'test!');

# scalar context
my $res = align( 'right', @col);
ok( $res, " just\n    a\ntest!\n");

# original unchanged?
ok( join( '|', @col), join( '|', @save_col));

# in-place alignment
align( '', @col);
ok( $col[ 0], 'just ');
ok( $col[ 1], 'a    ');
ok( $col[ 2], 'test!');

# scalar deref (not sure i like this feature)
@col = @save_col;
my $scalar = 'now';
align( '', $col[ 0], \ $col[ 1], $col[ 2], \ $scalar);
ok( $col[ 0], 'just ');
ok( $col[ 1], 'a    ');
ok( $col[ 2], 'test!');
ok( $scalar,  'now  ');

# fail as expected?
eval { align( '', 'wirdnix') };
ok( $@, qr/Modification of a read-only value/ );

BEGIN { plan tests => $n_tests }
