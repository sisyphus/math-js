# Test that the overloaded operators work correctly when the
# third arg is true, and the order of the args switches about.

use strict;
use warnings;
use Math::JS;
use Test::More;

my $js0 = Math::JS->new(7);

my $t = 0;
for my $js1(121 + $js0, 135 - $js0, 2 ** $js0, 135 ^ $js0) {
  $t++;
  cmp_ok(ref($js1), 'eq', 'Math::JS', "Test $t: isa Math::JS object");
  cmp_ok($js1, '==', 128, "Test $t: value is 128");
}

for my $js1(31 & $js0, 3 | $js0) {
  $t++;
  cmp_ok(ref($js1), 'eq', 'Math::JS', "Test $t: isa Math::JS object");
  cmp_ok($js1, '==', 7, "Test $t: value is 7");
}

for my $js1(98 / $js0, 2 * $js0) {
  $t++;
  cmp_ok(ref($js1), 'eq', 'Math::JS', "Test $t: isa Math::JS object");
  cmp_ok($js1, '==', 14, "Test $t: value is 14");
}

done_testing();
