#!./perl

use strict;
use warnings;
use Config; # to determine ivsize
use Test::More tests => 42;
use List::Util qw( uniqstr uniqint uniq );

use Tie::Array;

is_deeply( [ uniqstr ],
           [],
           'uniqstr of empty list' );

is_deeply( [ uniqstr qw( abc ) ],
           [qw( abc )],
           'uniqstr of singleton list' );

is_deeply( [ uniqstr qw( x x x ) ],
           [qw( x )],
           'uniqstr of repeated-element list' );

is_deeply( [ uniqstr qw( a b a c ) ],
           [qw( a b c )],
           'uniqstr removes subsequent duplicates' );

is_deeply( [ uniqstr qw( 1 1.0 1E0 ) ],
           [qw( 1 1.0 1E0 )],
           'uniqstr compares strings' );

{
    my $warnings = "";
    local $SIG{__WARN__} = sub { $warnings .= join "", @_ };

    is_deeply( [ uniqstr "", undef ],
               [ "" ],
               'uniqstr considers undef and empty-string equivalent' );

    ok( length $warnings, 'uniqstr on undef yields a warning' );

    is_deeply( [ uniqstr undef ],
               [ "" ],
               'uniqstr on undef coerces to empty-string' );
}

SKIP: {
    skip 'Perl 5.007003 with utf8::encode is required', 3 if $] lt "5.007003";
    my $warnings = "";
    local $SIG{__WARN__} = sub { $warnings .= join "", @_ };

    my $cafe = "cafe\x{301}";

    is_deeply( [ uniqstr $cafe ],
               [ $cafe ],
               'uniqstr is happy with Unicode strings' );

    SKIP: {
      skip "utf8::encode not available", 1
        unless defined &utf8::encode;
      utf8::encode( my $cafebytes = $cafe );

      is_deeply( [ uniqstr $cafe, $cafebytes ],
                [ $cafe, $cafebytes ],
                'uniqstr does not squash bytewise-equal but differently-encoded strings' );
    }

    is( $warnings, "", 'No warnings are printed when handling Unicode strings' );
}

is_deeply( [ uniqint ],
           [],
           'uniqint of empty list' );

is_deeply( [ uniqint 5, 5 ],
           [ 5 ],
           'uniqint of repeated-element list' );

is_deeply( [ uniqint 1, 2, 1, 3 ],
           [ 1, 2, 3 ],
           'uniqint removes subsequent duplicates' );

is_deeply( [ uniqint 6.1, 6.2, 6.3 ],
           [ 6 ],
           'uniqint compares as and returns integers' );

my $ls = 31;      # maximum left shift for 32-bit unity

if( $Config{ivsize} == 8 ) {
  $ls       = 63; # maximum left shift for 64-bit unity
}

# Populate @in with UV-NV pairs of equivalent values.
# Each of these values is exactly representable as 
# either a UV or an NV.

my @in = (1 << $ls, 2 ** $ls,
          1 << ($ls - 3), 2 ** ($ls - 3),
          5 << ($ls - 3), 5 * (2 ** ($ls - 3)));

my @correct = (1 << $ls, 1 << ($ls - 3), 5 << ($ls -3));

if( $Config{ivsize} == 8 && $Config{nvsize} == 8 ) {

     # Add some more IV-NV pairs of equivalent values. Each of these
     # values is exactly representable as either an IV or an NV, and
     # they are samples of values that were problematic with respect
     # to uniqnum. We include them for completeness. These IV-NV pairs
     # also represent values whose absolutes are less than ~0 and can
     # be expressed either as $num << $shift or $num * (2 ** $shift),
     # where $num is less than 1 << 53 (ie less than 9007199254740992).


     push @in, ( 9007199254740991,     9.007199254740991e+15,       #   9007199254740991 << 0
                 9007199254740992,     9.007199254740992e+15,       #   1                << 53
                 9223372036854774784,  9.223372036854774784e+18,    #   9007199254740991 << 10
                 100000000000262144,   1.00000000000262144e+17,     #   762939453127     << 17
                 100000000001310720,   1.0000000000131072e+17,      #   762939453135     << 17
                 144115188075593728,   1.44115188075593728e+17,     #   549755813887     << 18
                 -9007199254740991,     -9.007199254740991e+15,     # -(9007199254740991 << 0 )
                 -9007199254740992,     -9.007199254740992e+15,     # -(1                << 53)
                 -9223372036854774784,  -9.223372036854774784e+18,  # -(9007199254740991 << 10)
                 -100000000000262144,   -1.00000000000262144e+17,   # -(762939453127     << 17)
                 -100000000001310720,   -1.0000000000131072e+17,    # -(762939453135     << 17)
                 -144115188075593728,   -1.44115188075593728e+17 ); # -(549755813887     << 18)

     push @correct, ( 9007199254740991,
                      9007199254740992,
                      9223372036854774784,
                      100000000000262144,
                      100000000001310720,
                      144115188075593728,
                      -9007199254740991,
                      -9007199254740992,
                      -9223372036854774784,
                      -100000000000262144,
                      -100000000001310720,
                      -144115188075593728 );
}

# uniqint should discard each of the NVs as being a
# duplicate of the preceding IV. 

is_deeply( [ uniqint @in],
           [ @correct],
           'uniqint correctly compares IVs that don\'t overflow NVs' );

# This test did not always pass.
# The 2 input values are NVs of distinct values.
# the 2 expected values are UVs with (respectively) the same values as the NVs.
is_deeply( [ uniqint ((2 ** $ls) + (2 ** ($ls - 1)),
                      (2 ** $ls) + (2 ** ($ls - 2))) ],
           [ (3 << ($ls - 1), 5 << ($ls - 2)) ],
            'uniqint correctly compares UVs that don\'t overflow NVs' );

my ( $nv1, $nv2, $nv3, $nv4, $uniq_count );

# Assign large integer values to $nv1 and $nv2 that differ by only 1 ULP and check that
# uniqint recognizes them as being unique. Both $nv1 and $nv2 are evaluated with full
# NV precision.
# Perl stringifies $nv1 and $nv2 to the same string - hence our interest in checking
# that $nv1 and $nv2 are, indeed, being recognized as unique.
#
# Same goes for $nv3 and $nv4, who also differ by only 1 ULP. 

if( $Config{nvsize} == 8 ) {
    # NV is either 'double' or 8-byte 'long double'
    $nv1 = 3.6893488147419095e19; # 0x1.ffffffffffffep+64 == ((1 << 53) - 2) * (2 ** 12)
    $nv2 = 3.6893488147419099e19; # 0x1.fffffffffffffp+64 == ((1 << 53) - 1) * (2 ** 12)

    if($Config{ivsize} == 4) {
        $nv3 = 9.007199254740992e+15; # 0x1.0000000000000p+53 ==  2 ** 53
        $nv4 = 9.007199254740994e+15; # 0x1.0000000000001p+53 == (2 ** 53) + 2
    }
    else {
        $nv3 = 1.8446744073709552e+19; # 0x1.0000000000000p+64 ==  2 ** 64
        $nv4 = 1.8446744073709556e+19; # 0x1.0000000000001p+64 == (2 ** 64) + (2 ** 12)
    }
}
elsif(length(sqrt(2)) > 25) {
    # NV is either IEEE 'long double' or '__float128' or doubledouble

    if(1 + (2 ** -1074) != 1) {
        # NV is doubledouble
        $nv1 = (2 ** 70) + 1; # 0x1p+70 + 1
        $nv2 = (2 ** 70) + 2; # 0x1p+70 + 2

        $nv3 = 8.1129638414606681695789005144064e+31; #  2 ** 106
        $nv4 = 8.1129638414606681695789005144066e+31; # (2 ** 106) + 2
    }
    else {
        # NV is either IEEE 'long double' or '__float128'
        $nv1 = 2.72225893536750770770699685945414517e+39; #0x1.fffffffffffffffffffffffffffep130
        $nv2 = 2.72225893536750770770699685945414543e+39; #0x1.ffffffffffffffffffffffffffffp130

        $nv3 = 1.0384593717069655257060992658440192e+34;
                                            # 0x2.0000000000000000000000000000p+112 ==  2 ** 113
        $nv4 = 1.0384593717069655257060992658440194e+34; #
                                            # 0x2.0000000000000000000000000002p+112 == (2 ** 113) + 2
    }
}
else {
    # NV is extended precision 'long double'
    $nv1 = 3.6893488147419103228e+19; # 0x0.fffffffffffffffep+65
    $nv2 = 3.689348814741910323e+19;  # 0x0.ffffffffffffffffp+65

    $nv3 = 1.8446744073709551616e+19; # 0x8.000000000000000p+61 ==  2 ** 64
    $nv4 = 1.8446744073709551618e+19; # 0x8.000000000000001p+61 == (2 ** 64) + 2
}

SKIP: {
    # $nv1 and $nv2 should have been assigned different values, but perl could be buggy:
    skip ( 'perl incorrectly assigned identical values to both test variables', 2 ) if $nv1 == $nv2;

    $uniq_count = uniqint( $nv1, $nv2 );
    is( $uniq_count, 2, 'uniqint detects uniqueness of Nvs that differ by 1 ULP (1st test)' );

    # Also check the negatives.
    $uniq_count = uniqint( -$nv1, -$nv2 );
    is( $uniq_count, 2, 'uniqint detects uniqueness of Nvs that differ by 1 ULP (1st -ve test)' );
}

SKIP: {
    # $nv3 and $nv4 should have been assigned different values, but perl could be buggy:
    skip ( 'perl incorrectly assigned identical values to both test variables', 2 ) if $nv3 == $nv4;

    $uniq_count = uniqint( $nv3, $nv4 );
    is( $uniq_count, 2, 'uniqint detects uniqueness of Nvs that differ by 1 ULP (2nd test)' );

    # Also check the negatives.
    $uniq_count = uniqint( -$nv3, -$nv4 );
    is( $uniq_count, 2, 'uniqint detects uniqueness of Nvs that differ by 1 ULP (2nd -ve test)' );
}

# Hard to know for sure what an Inf is going to be. Lets make one
my $Inf = 0 + 1E1000;
my $NaN;
$Inf **= 1000 while ( $NaN = $Inf - $Inf ) == $NaN;

is_deeply( [ uniqint 1 << $ls, -(1 << $ls), 0, 1, 12345, $Inf, -$Inf, $NaN, 0, $Inf, $NaN, -$Inf ],
           [ 1 << $ls, -(1 << $ls), 0, 1, 12345, $Inf, -$Inf, $NaN ],
           'uniqint handles the special values of +-Inf and Nan' );

# The next 2 tests did not always pass.
# Increment $ls to one greater than maximum allowed left shift 
$ls++;

my @u = uniqint(2 ** $ls, -(2 ** $ls));

cmp_ok($u[0], '==', 2 ** $ls,    "uniqint handles 2 ** $ls correctly");
cmp_ok($u[1], '==', -(2 ** $ls), "uniqint handles -(2 ** $ls) correctly");

# Another test that did not always pass:
# $nv1 == $nv2 if nvsize == 8.
# Else $nv1 != $nv2.
$nv1 = 2 ** 64;
$nv2 = 1.8446744073709551615e+19;

my $uniq_count1 = uniqint($nv1, $nv2);
my $uniq_count2 = uniqint(-$nv1, -$nv2);

if($nv1 == $nv2) {
    is( $uniq_count1, 1, 'uniqint detects that 2 ** 64 == 1.8446744073709551615e+19' );
    is( $uniq_count2, 1, 'uniqint detects that -(2 ** 64) == -1.8446744073709551615e+19' );
}
else {
    is( $uniq_count1, 2, 'uniqint detects that 2 ** 64 != 1.8446744073709551615e+19' );
    is( $uniq_count2, 2, 'uniqint detects that -(2 ** 64) != -1.8446744073709551615e+19' );
}

{
    my $warnings = "";
    local $SIG{__WARN__} = sub { $warnings .= join "", @_ };

    is_deeply( [ uniqint 0, undef ],
               [ 0 ],
               'uniqint considers undef and zero equivalent' );

    ok( length $warnings, 'uniqint on undef yields a warning' );

    is_deeply( [ uniqint undef ],
               [ 0 ],
               'uniqint on undef coerces to zero' );
}

SKIP: {
    skip('UVs are not reliable on this perl version', 2) unless $] ge "5.008000";

    my $maxbits = $Config{ivsize} * 8 - 1;

    # An integer guaranteed to be a UV
    my $uv = 1 << $maxbits;
    is_deeply( [ uniqint $uv, $uv + 1 ],
               [ $uv, $uv + 1 ],
               'uniqint copes with UVs' );

    my $nvuv = 2 ** $maxbits;
    is_deeply( [ uniqint $nvuv, 0 ],
               [ int($nvuv), 0 ],
               'uniqint copes with NVUV dualvars' );
}

is_deeply( [ uniq () ],
           [],
           'uniq of empty list' );

{
    my $warnings = "";
    local $SIG{__WARN__} = sub { $warnings .= join "", @_ };

    is_deeply( [ uniq "", undef ],
               [ "", undef ],
               'uniq distintinguishes empty-string from undef' );

    is_deeply( [ uniq undef, undef ],
               [ undef ],
               'uniq considers duplicate undefs as identical' );

    ok( !length $warnings, 'uniq on undef does not warn' );
}

is( scalar( uniqstr qw( a b c d a b e ) ), 5, 'uniqstr() in scalar context' );

{
    package Stringify;

    use overload '""' => sub { return $_[0]->{str} };

    sub new { bless { str => $_[1] }, $_[0] }

    package main;

    my @strs = map { Stringify->new( $_ ) } qw( foo foo bar );

    is_deeply( [ map "$_", uniqstr @strs ],
               [ map "$_", $strs[0], $strs[2] ],
               'uniqstr respects stringify overload' );
}

SKIP: {
    skip('int overload requires perl version 5.8.0', 1) unless $] ge "5.008000";

    package Googol;

    use overload '""' => sub { "1" . ( "0"x100 ) },
                 'int' => sub { $_[0] },
                 fallback => 1;

    sub new { bless {}, $_[0] }

    package main;

    is_deeply( [ uniqint( Googol->new, Googol->new ) ],
               [ "1" . ( "0"x100 ) ],
               'uniqint respects int overload' );
}

{
    package DestroyNotifier;

    use overload '""' => sub { "SAME" };

    sub new { bless { var => $_[1] }, $_[0] }

    sub DESTROY { ${ $_[0]->{var} }++ }

    package main;

    my @destroyed = (0) x 3;
    my @notifiers = map { DestroyNotifier->new( \$destroyed[$_] ) } 0 .. 2;

    my @uniqstr = uniqstr @notifiers;
    undef @notifiers;

    is_deeply( \@destroyed, [ 0, 1, 1 ],
               'values filtered by uniqstr() are destroyed' );

    undef @uniqstr;
    is_deeply( \@destroyed, [ 1, 1, 1 ],
               'all values destroyed' );
}

{
    "a a b" =~ m/(.) (.) (.)/;
    is_deeply( [ uniqstr $1, $2, $3 ],
               [qw( a b )],
               'uniqstr handles magic' );
}

{
    my @array;
    tie @array, 'Tie::StdArray';
    @array = (
        ( map { ( 1 .. 10 ) } 0 .. 1 ),
        ( map { ( 'a' .. 'z' ) } 0 .. 1 )
    );

    my @u = uniq @array;
    is_deeply(
        \@u,
        [ 1 .. 10, 'a' .. 'z' ],
        'uniq uniquifies mixed numbers and strings correctly in a tied array'
    );
}
