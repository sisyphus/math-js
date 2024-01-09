use strict;
use warnings;
use Math::JS;
use Test::More;

warn "\nFYI: Overloading uses Math::MPFR::nvtoa\n" if Math::JS::USE_NVTOA;
warn "\nFYI: Overloading uses Math::RYU\n" if Math::JS::USE_RYU;
warn "\nFYI: Overloading uses sprintf(\"%.17g\", val)\n" unless (Math::JS::USE_NVTOA);

if(Math::JS::USE_NVTOA) {
  warn "FYI: Using mpfr-", Math::MPFR::MPFR_VERSION_STRING(), "\n";
}

for(1/10, 2 ** 0.5, 1.4 / 10, 1e+23, 2 ** -1074) {
  my $js = Math::JS->new($_);
  if(Math::JS::USE_NVTOA) {

    cmp_ok("$js", 'eq', Math::MPFR::nvtoa($js->{val}), "$js stringifies as expected");
    my $ok = 0;
    $ok = 1 if ("$js" eq '0.1' || "$js" eq '1.4142135623730951' || "$js" eq '0.13999999999999999' || "$js" =~ /^1e\+23$/i || "$js" =~ /^5e-324$/i);
    cmp_ok($ok, '==', 1, "Found a match for $js");
  }
  elsif(Math::JS::USE_RYU) {

  }
  else {
    cmp_ok("$js", 'eq', sprintf("%.17g", $js->{val}), "$js stringifies as expected");
    my $ok = 0;
    my $problematic = '0.13999999999999999';
    $ok = 1 if ("$js" eq '0.10000000000000001' || "$js" eq '1.4142135623730951' || "$js" eq $problematic
                 || "$js" =~ /^9.9999999999999992e\+22$/i || "$js" =~ /^4.9406564584124654e-324$/i);
    cmp_ok($ok, '==', 1, "Found a match for $js");
  }
}

done_testing();

__END__


