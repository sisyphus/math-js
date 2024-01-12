use strict;
use warnings;
use Math::JS;
use Test::More;

warn "\nFYI: Overloading uses sprintf(\"%.17g\", val)\n";

for(1/10, 2 ** 0.5, 1.4 / 10, 1e+23, 2 ** -1074) {
  my $js = Math::JS->new($_);

  cmp_ok("$js", 'eq', sprintf("%.17g", $js->{val}), "$js stringifies as expected");
  my $ok = 0;
  $ok = 1 if ("$js" eq '0.10000000000000001' || "$js" eq '1.4142135623730951' || "$js" eq '0.13999999999999999'
               || "$js" =~ /^9.9999999999999992e\+0?22$/i || "$js" =~ /^4.9406564584124654e-324$/i);
  cmp_ok($ok, '==', 1, "Found a match for $js");
  $ok = 0;
  $ok = 1 if ("$js" == 0.1 || "$js" == 1.4142135623730951 || "$js" == 0.13999999999999999
               || "$js" == 1e+23 || "$js" == 5e-324);
  cmp_ok($ok, '==', 1, "Found equivalence for $js");

}

done_testing();

__END__


