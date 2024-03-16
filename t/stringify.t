use strict;
use warnings;
use Math::JS;
use Test::More;

my $ryu = Math::JS::USE_RYU;
if($ryu) {
  warn "\nFYI: Stringifying the values of Math::JS objects uses Math::Ryu version $Math::Ryu::VERSION\n";
}
else {
  warn "\nFYI: Stringifying the values of Math::JS objects uses sprintf(\"%.17g\", val)\n";
}

my $pinf = 2 ** 1500;
my $ninf = -$pinf;
my $nan = $pinf / $ninf;

cmp_ok($nan, '!=', $nan, "NaN != NaN");

my $js = Math::JS->new($pinf);
cmp_ok("$js", 'eq', 'Infinity', "Inf displays as expected");

$js = Math::JS->new($ninf);
cmp_ok("$js", 'eq', '-Infinity', "-Inf displays as expected");

$js = Math::JS->new($nan);
cmp_ok("$js", 'eq', 'nan', "NaN displays as expected");

$js = Math::JS->new(1 / 10);
my $got = $ryu ? '0.1' : '0.10000000000000001';
cmp_ok("$js", 'eq', $got, "0.1 displays as expected");

$js = Math::JS->new(2 ** 0.5);
cmp_ok("$js", 'eq', '1.4142135623730951' , "sqrt(2) displays as expected");

$js = Math::JS->new(1.4 / 10);
cmp_ok("$js", 'eq', '0.13999999999999999' , "1.4 / 10 displays as expected");

# Avoid the following  on perls older than 5.30.0 because
# these older perls may not assign the given values correctly.

if($] < 5.03) {
  warn "Avoiding remaining tests because this perl ($]) can assign incorrect values\n";
  done_testing;
  exit 0;
}

$js = Math::JS->new(1e+23);
$got = $ryu ? '1e+23' : sprintf("%.17g", 1e+23);
cmp_ok("$js", 'eq', $got, "1e+23 displays as expected");

$js = Math::JS->new(2 ** -1074);
$got = $ryu ? '5e-324' : sprintf("%.17g", 2 ** -1074);
cmp_ok("$js", 'eq', $got, "2 ** -1074 displays as expected");

$js = Math::JS->new(0.123);
cmp_ok("$js", 'eq', '0.123', "0.123 displays as expected");

$js = Math::JS->new(0.1234);
cmp_ok("$js", 'eq', '0.1234', "0.1234 displays as expected");

$js = Math::JS->new((2 ** 53) - 1);
cmp_ok("$js", 'eq', '9007199254740991', "9007199254740991 displays as expected");

$js = Math::JS->new(9007199254740991.0);
cmp_ok("$js", 'eq', '9007199254740991', "9007199254740991.0 displays as expected");

$js = Math::JS->new(4294967297);
cmp_ok("$js", 'eq', '4294967297', "4294967297 displays as expected");

# The next 2 tests always use sprintf() - which can (rarely)
# produce the wrong format - though the represented value will
# be correct.
# Math::Ryu is never used with these 2 tests.
# We TODO these tests on systems where they will fail.

TODO: {

  local $TODO = '"%.21g" formats 1e19 and 1e21 incorrectly'
    if sprintf("%.21g", 9e20) ne '900000000000000000000';

  $js = Math::JS->new(1e19);
  cmp_ok("$js", 'eq', '1' . '0' x 19, "1e+19 displays as expected");

  $js = Math::JS->new(9e20);
  cmp_ok("$js", 'eq', '9' . '0' x 20, "9e+20 displays as expected");
}

# Having possibly avoided the last 2 tests, we can at least check
# that $js == the expected value:
my $expected = $ryu ? '9' . '0' x 20 : '4294967297';
cmp_ok("$js", '==', $expected, "strings are evaluated as expected");
$js = Math::JS->new(1e19);
cmp_ok("$js", '==', '1' . '0' x 19, "1e+19 is evaluated as expected");

$js = Math::JS->new(1e21);
if($ryu) {
  cmp_ok("$js", 'eq', '1e+21', "1e+21 displays as expected");
}
else {
  # With "%.17g" formatting, the exponent can be either "+21" or "+021".
  like("$js", qr/^1e\+0?21$/, "1e21 displays as expected");
}


done_testing();

__END__


