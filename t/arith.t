# Use JS calculator at https://playcode.io/new
use strict;
use warnings;

use Math::JS;
use Test::More;

my %classify = (2 => 'uint32', 3 => 'sint32', 4 => 'number'); # Duplicate of JS.pm's %classify

cmp_ok(Math::JS->new(2147483648),  '==',  2147483648, "test 1");
cmp_ok(Math::JS->new(-2147483648), '==', -2147483648, "test 2");

my $x = Math::JS->new(1073741824);
my $y = Math::JS->new(1073741824);

cmp_ok($x + $y, '==', 2147483648, '1073741824 + 1073741824 => 2147483648');

$y += 2; # 1073741826

cmp_ok($x + $y,               '==', 2147483650, '1073741824 + 1073741824 => 2147483650');
cmp_ok($x + (($y / 2)   * 2), '==', 2147483650, '1073741824 + ((1073741826 /  2)  * 2) => 2147483650');
cmp_ok($x + (($y >> 1)  * 2), '==', 2147483650, '1073741824 + ((1073741826 >> 1)  * 2) => 2147483650');
cmp_ok($x + (($y >> 1) << 1), '==', 2147483650, '1073741824 + ((1073741826 >> 1) << 1) => 2147483650');
cmp_ok((($x >> 1) << 1) + (($y >> 1) << 1), '==', 2147483650, '((1073741824 >> 1) << 1) + ((1073741826 >> 1) << 1) => 2147483650');
cmp_ok((($x >> 1) *  2) + (($y >> 1)  * 2), '==', 2147483650, '((1073741824 >> 1) *  2) + ((1073741826 >> 1) *  2) => 2147483650');
cmp_ok(($x >> 1) * 4, '==', 2147483648, '((1073741824 >> 1) * 4 => 2147483648');

cmp_ok(($x >> 1) + ($x >> 1) + ($x >> 1) + ($x >> 1), '==', 2147483648, "addition and multiplication agree");
cmp_ok($x << 1, '==', -2147483648, '1073741824 << 1 => -2147483648');
cmp_ok($x  * 2, '==',  2147483648, '1073741824  * 2 =>  2147483648');

$x = Math::JS->new(2147483648);
cmp_ok($x->{type}, 'eq', 'uint32', '2147483648 is uint32');

my $t = Math::JS ->new(2147483648);

cmp_ok($t->{type}, 'eq', 'uint32', "2147483648 is 'uint32'" );

my $rs = $t >> 1;
cmp_ok($rs, '==', -1073741824, "2147483648 >> 1 is -1073741824");
cmp_ok($rs->{type}, 'eq', 'sint32', "2147483648 >> 1 is 'sint32'");

$rs = $t >> 10;
cmp_ok($rs, '==', -2097152, "2147483648 >> 10 is -2097152");
cmp_ok($rs->{type}, 'eq', 'sint32', "2147483648 >> 10 is 'sint32'");

##############################################################
$t = Math::JS->new(4294967291);
cmp_ok($t->{type}, 'eq', 'uint32', "4294967291 is 'uint32'");
$rs = $t >> 2;
cmp_ok($rs, '==', -2, "4294967291 >> 2 is -2");
cmp_ok($rs->{type}, 'eq', 'sint32', "4294967291 >> 2 is  'sint32'");

$rs = $t >> 3;
cmp_ok($rs, '==', -1, "4294967291 >> 3 is -1");
cmp_ok($rs->{type}, 'eq', 'sint32', "4294967291 >> 3 is  'sint32'");

$t = Math::JS->new(-12345678);
cmp_ok($t->{type}, 'eq', 'sint32', "-12345678 is 'sint32'");
$rs = $t >> 6;
cmp_ok($rs, '==', -192902, "-12345678 >> 6 is -192902");
cmp_ok($rs->{type}, 'eq', 'sint32', "-12345678 >> 6 is  'sint32'");
###############################################################

$t = $x >> 1;
cmp_ok($t->{type}, 'eq', 'sint32', '2147483648 >> 1 is sint32');
cmp_ok(($t + $t)->{type}, 'eq', 'sint32', "'sint32' as expected");
cmp_ok(($x >> 1) + ($x >> 1), '==', -2147483648,  '(2147483648 >> 1) + (2147483648 >> 1) => -2147483648');
cmp_ok(($x >> 1) * 2, '==', -2147483648,  '(2147483648 >> 1) * 2 => -2147483648');

cmp_ok(Math::JS->new(-16) << 2, '==', -64, '-16 << 2 => -64');
cmp_ok(Math::JS->new(1169367104) << 5, '==', -1234958336, '1169367104 << 5 => -1234958336');
cmp_ok((Math::JS->new(2147483648) >> 1) * 2, '==', -2147483648, '(2147483648 >> 1) * 2 => -2147483648');
cmp_ok((Math::JS->new(536870912)  << 1) * 2, '==',  2147483648, '(536870912 <<  1) * 2 =>  2147483648');
cmp_ok(Math::JS->new(536870912) << 1, '==', 1073741824, '536870912 << 1 => 1073741824');
cmp_ok(Math::JS->new(536870912) << 2, '==', -2147483648, '536870912 << 2 => -2147483648');
cmp_ok(Math::JS->new(33554432) ** 2, '==', 1125899906842624,  '33554432 ** 2 => 1125899906842624');
cmp_ok((Math::JS->new(33554432) >> 1) ** 2, '==', 281474976710656,  '(33554432 >> 1) ** 2 => 281474976710656');
cmp_ok((Math::JS->new(16777216) << 1) ** 2, '==', 1125899906842624,  '(16777216 << 1) ** 2 => 1125899906842624');

cmp_ok((Math::JS->new(2147483648) >> 1) + (Math::JS->new(2147483648) >> 1), '==', -2147483648,
        '(2147483648 >> 1) + (2147483648 >> 1) => -2147483648');

cmp_ok((Math::JS->new(536870912) << 1) + (Math::JS->new(536870912) << 1), '==', 2147483648,
        '(536870912 << 1) + (536870912 << 1) => 2147483648');

cmp_ok((Math::JS->new(536870912) << 1) + (Math::JS->new(2147483648) >> 1), '==', 0,
        '(536870912 << 1) + (2147483648 >> 1) => 0');

cmp_ok((Math::JS->new(2147483648) >> 1) + (Math::JS->new(536870912) << 1), '==', 0,
        '(2147483648 >> 1) + (536870912 << 1) => 0');

cmp_ok(Math::JS->new(536870912) << 1, '==',  1073741824, '536870912  << 1 =>  1073741824');
cmp_ok(Math::JS->new(2147483648) >> 1, '==', -1073741824, '2147483648  >> 1 => -1073741824');

cmp_ok(Math::JS->new(-1) << 31, '==', -2147483648,  '-1 << 31 => -2147483648');
cmp_ok(Math::JS->new(-1) << 63, '==', -2147483648,  '-1 << 63 => -2147483648');
cmp_ok(Math::JS->new(-1) << 40, '==', -256,  '-1 << 40 => -256');
cmp_ok(Math::JS->new(-1) << 50, '==', -262144,  '-1 << 50 => -262144');

cmp_ok(Math::JS->new(9007199254740900) / 7, '==', 1286742750677271.5, '9007199254740900 / 7 => 1286742750677271.5');

for(0..33) {
  cmp_ok(Math::JS->new(-2147483648) >> $_, '==', -2147483648 / (2 ** ($_ % 32)), "-2147483648 >> $_ is as expected");
}

for(1..31, 33) {
  cmp_ok(Math::JS->new(-2147483647) >> $_, '==', -2147483648 / (2 ** ($_ % 32)), "-2147483647 >> $_ is as expected");
}

for(0, 32) {
  cmp_ok(Math::JS->new(-2147483647) >> $_, '==', -2147483647, "-2147483647 >> $_ is -2147483647");
}

cmp_ok(Math::JS->new(4294967295) & Math::JS->new(429496729), '==', 429496729, '4294967295 & 429496729 => 429496729');
cmp_ok(Math::JS->new(2147483648) & Math::JS->new(429496729), '==', 0, '2147483648 & 429496729 => 0');
cmp_ok(Math::JS->new(2147483647) & Math::JS->new(429496729), '==', 429496729, '2147483647 & 429496729 => 429496729');
cmp_ok(Math::JS->new(-1) & Math::JS->new(429496729), '==', 429496729, '-1 & 429496729 => 429496729');

cmp_ok(Math::JS->new(4294967290) >> 1, '==', -3, '4294967290 >> 1 => -3');
cmp_ok(Math::JS->new(4294967291) >> 1, '==', -3, '4294967291 >> 1 => -3');
cmp_ok(Math::JS->new(4294967292) >> 1, '==', -2, '4294967292 >> 1 => -2');
cmp_ok(Math::JS->new(4294967293) >> 1, '==', -2, '4294967293 >> 1 => -2');
cmp_ok(Math::JS->new(4294967294) >> 1, '==', -1, '4294967294 >> 1 => -1');
cmp_ok(Math::JS->new(4294967295) >> 1, '==', -1, '4294967295 >> 1 => -1');

cmp_ok(~Math::JS->new(0), '==', -1, "~0 == -1");
cmp_ok(~Math::JS->new(Math::JS::MAX_ULONG), '==', 0, "~MAX_ULONG == 0");
cmp_ok(~Math::JS->new(Math::JS::MAX_SLONG), '==', -2147483648, "~MAX_SLONG == -2147483648");
cmp_ok(~Math::JS->new(Math::JS::MIN_ULONG), '==', 2147483647, "~MIN_ULONG == 2147483647");
cmp_ok(~Math::JS->new(Math::JS::MIN_SLONG), '==', 2147483647, "~MIN_SLONG == 2147483647");
cmp_ok(~Math::JS->new(Math::JS::LOW_31BIT), '==', -1073741825, "~LOW_31BIT == -1073741825");
cmp_ok(~Math::JS->new(1111111111), '==', -1111111112, "~1111111111 == -1111111112");

my $new = Math::JS->new(Math::JS::MAX_ULONG) ^ Math::JS->new(Math::JS::MIN_SLONG);
cmp_ok($new, '==', 2147483647, "4294967295 ^ -2147483648 == 2147483647");
cmp_ok($new->{type}, 'eq', 'sint32', "4294967295 ^ -2147483648 returns 'sint32'");

$new = Math::JS->new(Math::JS::MIN_SLONG) ^ Math::JS->new(Math::JS::MAX_ULONG);
cmp_ok($new, '==', 2147483647, "-2147483648 ^ 4294967295 == 2147483647");
cmp_ok($new->{type}, 'eq', 'sint32', "-2147483648 ^ 4294967295 returns 'sint32'");

$new = Math::JS->new(4294967295) ^ Math::JS->new(100);
cmp_ok($new, '==', -101, "4294967295 ^ 100 == -101");
cmp_ok($new->{type}, 'eq', 'sint32', "4294967295 ^ 100 returns 'sint32'");

$new = Math::JS->new(3294967295) ^ Math::JS->new(1000);
cmp_ok($new,  '==', -999999977, "294967295 ^ 1000 == -999999977");
cmp_ok($new->{type}, 'eq', 'sint32', "294967295 ^ 1000 returns 'sint32'");
my $n2 = $new << 1;
cmp_ok($n2, '==', -1999999954, "-999999977 << 1 => -1999999954");
my $n3 = $new >> 1;
cmp_ok($n3, '==', -499999989, "-999999977 >> 1 => -499999989");

cmp_ok(Math::JS->new(3294967295) ^ Math::JS->new(10000), '==', -1000008977, "3294967295 ^ 10000 == -1000008977");
cmp_ok(Math::JS->new(94967295) ^ Math::JS->new(100000),  '==', 94933855, "94967295 ^ 100000 == 94933855");
cmp_ok(Math::JS->new(94967295) ^ Math::JS->new(-100000), '==', -94933857, "94967295 ^ -100000 == -94933857");
cmp_ok(Math::JS->new(-94967295) ^ Math::JS->new(200000), '==', -95033535, "94967295 ^ 200000 == -95033535");
cmp_ok(Math::JS->new(429496) ^ Math::JS->new(-100734),   '==', -459974, "429496 ^ -100734 == -459974");

cmp_ok((Math::JS->new( 1073741824) << 1) >> 1, '==', -1073741824, "( 1073741824 << 1) >> 1 => -1073741824");  # +LR
cmp_ok((Math::JS->new( 1073741824) >> 1) << 1, '==',  1073741824, "( 1073741824 >> 1) << 1 =>  1073741824");  # +RL
cmp_ok((Math::JS->new(-1073741824) << 1) >> 1, '==', -1073741824, "(-1073741824 << 1) >> 1 => -1073741824");  # -LR
cmp_ok((Math::JS->new(-1073741824) >> 1) << 1, '==', -1073741824, "(-1073741824 >> 1) << 1 => -1073741824");  # -RL

cmp_ok((Math::JS->new( 1073741823) << 1) >> 1, '==',  1073741823, "( 1073741823 << 1) >> 1 => -1073741824");  # +LR
cmp_ok((Math::JS->new( 1073741823) >> 1) << 1, '==',  1073741822, "( 1073741823 >> 1) << 1 =>  1073741822");  # +RL
cmp_ok((Math::JS->new(-1073741823) << 1) >> 1, '==', -1073741823, "(-1073741823 << 1) >> 1 => -1073741823");  # -LR
cmp_ok((Math::JS->new(-1073741823) >> 1) << 1, '==', -1073741824, "(-1073741823 >> 1) << 1 => -1073741824");  # -RL

my $in = Math::JS::MAX_ULONG;
cmp_ok((Math::JS->new($in) >> 1) << 1, '==', -2, "(MAX_ULONG >> 1) << 1 => -2");
cmp_ok((Math::JS->new(-$in) >> 1) << 1, '==', 0, "(-MAX_ULONG >> 1) << 1 => 0");
cmp_ok(Math::JS->new(-$in) >> 1, '==', 0, "-MAX_ULONG >> 1 => 0");

$in = Math::JS::MIN_SLONG; # -2147483648
cmp_ok((Math::JS->new($in) >> 1) << 1, '==', $in, "(-2147483648 >> 1) << 1 => $in");
cmp_ok((Math::JS->new($in) << 1) >> 1, '==', 0,   "(-2147483648 << 1) >> 1 => 0");
cmp_ok((Math::JS->new(-$in) >> 1) << 1, '==', $in, "(2147483648 >> 1) << 1 => $in");
cmp_ok((Math::JS->new(-$in) << 1) >> 1, '==', 0,   "(2147483648 << 1) >> 1 => 0");

$in = Math::JS::MAX_SLONG; # 2147483647
cmp_ok((Math::JS->new($in) >> 1) << 1, '==', 2147483646, "(2147483647 >> 1) << 1 => 2147483646");
cmp_ok((Math::JS->new($in) << 1) >> 1, '==', -1,   "(2147483647 << 1) >> 1 => -1");
cmp_ok((Math::JS->new(-$in) >> 1) << 1, '==', -2147483648, "(-2147483647 >> 1) << 1 => -2147483648");
cmp_ok((Math::JS->new(-$in) << 1) >> 1, '==', 1,   "(-2147483647 << 1) >> 1 => 1");

cmp_ok(Math::JS->new(-21474836) << 1, '==', -42949672,     "-21474836 << 1 => -42949672");
cmp_ok(Math::JS->new(-21474836) << 2, '==', -85899344,     "-21474836 << 2 => -85899344");
cmp_ok(Math::JS->new(-21474836) << 3, '==', -171798688,   "-21474836 << 3 => -171798688");
cmp_ok(Math::JS->new(-21474836) << 4, '==', -343597376,   "-21474836 << 4 => -343597376");
cmp_ok(Math::JS->new(-21474836) << 5, '==', -687194752,   "-21474836 << 5 => -687194752");
cmp_ok(Math::JS->new(-21474836) << 6, '==', -1374389504, "-21474836 << 6 => -1374389504");
cmp_ok((Math::JS->new(-21474836) << 6)->{type}, 'eq', 'sint32', "-21474836 << 6 is 'sint32'");
cmp_ok(Math::JS->new(-21474836) << 7, '==',  1546188288, "-21474836 << 7 =>  1546188288");
cmp_ok(Math::JS->new(-21474836) << 8, '==', -1202590720, "-21474836 << 8 => -1202590720");

for(
  Math::JS->new(Math::JS::MAX_ULONG),
  Math::JS->new(Math::JS::MAX_SLONG),
  Math::JS->new(Math::JS::MIN_ULONG),
  Math::JS->new(Math::JS::MIN_SLONG),
  Math::JS->new(Math::JS::LOW_31BIT),
) {
  cmp_ok($_ >> 0, '==', unpack( 'l', pack 'l',$_->{val} ), "$_ >> 0 == " . unpack 'l', pack 'l', $_->{val});
  cmp_ok($_ << 0, '==', unpack( 'l', pack 'l',$_->{val} ), "$_ << 0 == " . unpack 'l', pack 'l', $_->{val});

  cmp_ok($_ & $_, '==', unpack( 'l', pack 'l',$_->{val} ), "$_ & $_ == " . unpack 'l', pack 'l', $_->{val});
  cmp_ok($_ | $_, '==', unpack( 'l', pack 'l',$_->{val} ), "$_ | $_ == " . unpack 'l', pack 'l', $_->{val});
  cmp_ok($_ ^ $_, '==', 0, "$_ ^ $_ == 0");
}

my $js = Math::JS->new(123456789);

for(59 .. 64) {
  cmp_ok($js << -$_, '==', $js << 64 - $_, "<< -$_ == << 64-$_");
  cmp_ok($js >> -$_, '==', $js >> 64 - $_, ">> -$_ == >> 64-$_");
}

cmp_ok($js << 5  , '==', -344350048, "$js << 5   => -344350048");
cmp_ok($js << -59, '==', -344350048, "$js << -59 => -344350048");

cmp_ok($js >> 5  , '==', 3858024, "$js >> 5   => 3858024");
cmp_ok($js >> -59, '==', 3858024, "$js >> -59 => 3858024");

for(59 .. 64) {
  my $s = $_ + 0.9;
  cmp_ok($js << -$s, '==', $js << -int($s), "<< -$s == << -int($s)");
  cmp_ok($js >> -$s, '==', $js >> -int($s), ">> -$s == >> -int($s)");
  cmp_ok($js << $s,  '==', $js <<  int($s),  "<< $s == << int($s)");
  cmp_ok($js >> $s,  '==', $js >>  int($s),  ">> $s == >> int($s)");
}

cmp_ok(Math::JS->new(2 ** 31)    & Math::JS->new(Math::JS::MAX_ULONG), '==', Math::JS::MIN_SLONG, "(2 ** 31) & 4294967295 => -2147483648");
cmp_ok(Math::JS->new(-(2 ** 31)) & Math::JS->new(Math::JS::MAX_ULONG), '==', Math::JS::MIN_SLONG, "-(2 ** 31) & 4294967295 => -2147483648");
cmp_ok(Math::JS->new(9007199254740991) & Math::JS->new(9007199254740991), '==', -1, '9007199254740991 & 9007199254740991 => -1');
cmp_ok(Math::JS->new(9007199254740991) & Math::JS->new(4294967295), '==', -1, '9007199254740991 & 4294967295 => -1');
cmp_ok(Math::JS->new(9007199254740991) & Math::JS->new(429496729), '==', 429496729, '9007199254740991 & 429496729 => 429496729');
cmp_ok(Math::JS->new(8007199254740991) & Math::JS->new( 7007199254740991), '==', 305168383,  '8007199254740991 & 7007199254740991 =>   305168383');
cmp_ok(Math::JS->new(8007199254740991) & Math::JS->new(-7007199254740991), '==', 1225326593, '8007199254740991 & -7007199254740991 => 1225326593');

cmp_ok(Math::JS->new(2 ** 31)    | Math::JS->new(Math::JS::MAX_ULONG), '==', -1, "(2 ** 31) | 4294967295 => -1");
cmp_ok(Math::JS->new(-(2 ** 31)) | Math::JS->new(Math::JS::MAX_ULONG), '==', -1, "-(2 ** 31) | 4294967295 => -1");
cmp_ok(Math::JS->new(9007199254740991) | Math::JS->new(9007199254740991), '==', -1, '9007199254740991 | 9007199254740991 => -1');
cmp_ok(Math::JS->new(9007199254740991) | Math::JS->new(4294967295), '==', -1, '9007199254740991 | 4294967295 => -1');
cmp_ok(Math::JS->new(9007199254740991) | Math::JS->new(429496729), '==', -1, '9007199254740991 | 429496729 => -1');
cmp_ok(Math::JS->new(8007199254740991) | Math::JS->new( 7007199254740991), '==', -8650753,  '8007199254740991 | 7007199254740991 =>  -8650753');
cmp_ok(Math::JS->new(8007199254740991) | Math::JS->new(-7007199254740991), '==', 1539145727, '8007199254740991 | -7007199254740991 => 1539145727');

cmp_ok(Math::JS->new(2 ** 31)    ^ Math::JS->new(Math::JS::MAX_ULONG), '==', Math::JS::MAX_SLONG, "(2 ** 31) ^ 4294967295 => 2147483647");
cmp_ok(Math::JS->new(-(2 ** 31)) ^ Math::JS->new(Math::JS::MAX_ULONG), '==', Math::JS::MAX_SLONG, "-(2 ** 31) ^ 4294967295 => 2147483647");
cmp_ok(Math::JS->new(9007199254740991) ^ Math::JS->new(9007199254740991), '==', 0, '9007199254740991 ^ 9007199254740991 => 0');
cmp_ok(Math::JS->new(9007199254740991) ^ Math::JS->new(4294967295), '==', 0, '9007199254740991 ^ 4294967295 => 0');
cmp_ok(Math::JS->new(9007199254740991) ^ Math::JS->new(429496729), '==', -429496730, '9007199254740991 ^ 429496729 => -429496730');
cmp_ok(Math::JS->new(8007199254740991) ^ Math::JS->new( 7007199254740991), '==', -313819136,  '8007199254740991 ^ 7007199254740991 =>  -313819136');
cmp_ok(Math::JS->new(8007199254740991) ^ Math::JS->new(-7007199254740991), '==', 313819134, '8007199254740991 ^ -7007199254740991 => 313819134');

cmp_ok(~Math::JS->new(  2 ** 31),  '==', 2147483647,         '~(  2 ** 31)         => 2147483647');
cmp_ok(~Math::JS->new(-(2 ** 31)), '==', 2147483647,         '~(-(2 ** 31))        => 2147483647');
cmp_ok(~Math::JS->new( 429496729), '==', -429496730,         '~  429496729         => -429496730');
cmp_ok(~Math::JS->new(-429496729), '==',  429496728,         '~(-429496729)        => 429496728');
cmp_ok(~Math::JS->new( 4294967295), '==',  0,                '~  4294967295        => 0');
cmp_ok(~Math::JS->new(-4294967295), '==', -2,                '~(-4294967295)       => -2');
cmp_ok(~Math::JS->new( 7007199254740991), '==',  1233977344, '~  7007199254740991  => 1233977344');
cmp_ok(~Math::JS->new(-7007199254740991), '==', -1233977346, '~(-7007199254740991) => 1233977346');
cmp_ok(~Math::JS->new( 9007199254740991), '==',  0,          '~  9007199254740991  => 0');
cmp_ok(~Math::JS->new(-9007199254740991), '==', -2,          '~(-9007199254740991) => -2');


### NEW ###
for(0..33) {
  cmp_ok(Math::JS->new(9007199254740991) >> $_, '==', -1, "9007199254740991 >> $_ => -1");
}

for(1..31, 33) {
  cmp_ok(Math::JS->new(-9007199254740991) >> $_, '==', 0, "-9007199254740991 >> $_ => 0");
}

for(0, 32) {
  cmp_ok(Math::JS->new(-9007199254740991) >> $_, '==', 1, "-9007199254740991 >> $_ => 1");
}

cmp_ok(Math::JS->new(90071992500000) >> 1, '==', -1030815856, '9007199250000000 >> 1 => -1030815856');
cmp_ok(Math::JS->new(90071992500000) >> 4, '==', -128851982,  '9007199250000000 >> 4 => -128851982');
cmp_ok(Math::JS->new(-90071992500000) >> 1, '==', 1030815856, '-9007199250000000 >> 1 => 1030815856');
cmp_ok(Math::JS->new(-90071992500000) >> 4, '==', 128851982,  '-9007199250000000 >> 4 => 128851982');

cmp_ok(Math::JS->new(90071992500000) << 1, '==', 171703872, '9007199250000000 << 1 => 171703872');
cmp_ok(Math::JS->new(90071992500000) << 4, '==', 1373630976,  '9007199250000000 << 4 => 1373630976');
cmp_ok(Math::JS->new(-90071992500000) << 1, '==', -171703872, '-9007199250000000 << 1 => -171703872');
cmp_ok(Math::JS->new(-90071992500000) << 4, '==', -1373630976,  '-9007199250000000 << 4 => -1373630976');

cmp_ok(Math::JS->new(9007199250000000) >> 1, '==', -2370496, '9007199250000000 >> 1 => -2370496');
cmp_ok(Math::JS->new(9007199250000000) >> 4, '==', -296312,  '9007199250000000 >> 4 => -296312');

cmp_ok(Math::JS->new(-9007199254740000) >> 1, '==', 496, '-9007199254740000 >> 1 => 496');
cmp_ok(Math::JS->new(-9007199254740000) >> 4, '==', 62,  '-9007199254740000 >> 1 => 62');
cmp_ok(Math::JS->new(-4294967296) >> 1, '==',  0, '-4294967296 >> 1 => 0');
cmp_ok(Math::JS->new(-4294967299) >> 1, '==', -2, '-4294967299 >> -1 => -2');

my $arg = (2 ** 55) + 1172;
cmp_ok(Math::JS->new( $arg) >> 1, '==',  584, sprintf("%.17g",  $arg) . " >> 1 =>  584");
cmp_ok(Math::JS->new(-$arg) >> 1, '==', -584, sprintf("%.17g", -$arg) . " >> 1 => -584");

cmp_ok(Math::JS->new(1234.7) >> 1, '==', 617, '1234.7 >> 1 => 617');

my $pinf = 2 ** 1500; # +ve Inf
my $ninf = -$pinf;    # -ve Inf
my $nan = $pinf/$pinf;

cmp_ok(Math::JS->new(Math::JS::_get_pinf()), '==', Math::JS->new($pinf), "+Inf == +Inf");
cmp_ok(Math::JS->new(Math::JS::_get_ninf()), '==', Math::JS->new($ninf), "-Inf == -Inf");
my $N1 = Math::JS->new(Math::JS::_get_nan());
my $N2 = Math::JS->new($nan);
cmp_ok($N1,  '!=', $N2,   "NaN != NaN" );

my $nan_test = 1;
$nan_test = 0 if $N1 <= $N2;
cmp_ok($nan_test, '==', 1, "nan test 1 ok");

$nan_test = 1;
$nan_test = 0 if $N1 < $N2;
cmp_ok($nan_test, '==', 1, "nan test 2 ok");

$nan_test = 1;
$nan_test = 0 if $N1 >= $N2;
cmp_ok($nan_test, '==', 1, "nan test 3 ok");

$nan_test = 1;
$nan_test = 0 if $N1 > $N2;
cmp_ok($nan_test, '==', 1, "nan test 4 ok");

$nan_test = 1;
$nan_test = 0 if $N1 <= $nan;
cmp_ok($nan_test, '==', 1, "nan test 5 ok");

$nan_test = 1;
$nan_test = 0 if $N1 < $nan;
cmp_ok($nan_test, '==', 1, "nan test 6 ok");

$nan_test = 1;
$nan_test = 0 if $N1 >= $nan;
cmp_ok($nan_test, '==', 1, "nan test 7 ok");

$nan_test = 1;
$nan_test = 0 if $N1 > $nan;
cmp_ok($nan_test, '==', 1, "nan test 8 ok");

$nan_test = 1;
$nan_test = 0 if $nan <= $N2;
cmp_ok($nan_test, '==', 1, "nan test 9 ok");

$nan_test = 1;
$nan_test = 0 if $nan < $N2;
cmp_ok($nan_test, '==', 1, "nan test 10 ok");

$nan_test = 1;
$nan_test = 0 if $nan >= $N2;
cmp_ok($nan_test, '==', 1, "nan test 11 ok");

$nan_test = 1;
$nan_test = 0 if $nan > $N2;
cmp_ok($nan_test, '==', 1, "nan test 12 ok");

$nan_test = 1;
$nan_test = 0 if $nan == $N2;
cmp_ok($nan_test, '==', 1, "nan test 13 ok");

$nan_test = 1;
$nan_test = 0 unless $nan != $N2;
cmp_ok($nan_test, '==', 1, "nan test 14 ok");

my @infnan = ($pinf, $ninf, $nan);
for(@infnan) {
  cmp_ok(Math::JS::_infnan($_), '==', 1, "$_ is infnan");
  cmp_ok((Math::JS->new($_))->{type}, 'eq', 'number', "$_ is of type 'number'");
}

for my $x (@infnan, 0) {
  cmp_ok( ~ Math::JS->new($x), '==', -1, "~ Math::JS->new($x) == -1");
  for my $y (@infnan, 0) {
    cmp_ok(Math::JS->new($x) & Math::JS->new($y), '==', 0, "$x & $y == 0");
    cmp_ok(Math::JS->new($x) | Math::JS->new($y), '==', 0, "$x | $y == 0");
    cmp_ok(Math::JS->new($x) ^ Math::JS->new($y), '==', 0, "$x ^ $y == 0");
  }
}

for my $x (@infnan, 0) {
  for my $shift(1, 3) {
    cmp_ok(Math::JS->new($x) >> $shift, '==', 0, "$x >> $shift == 0");
    cmp_ok(Math::JS->new($x) << $shift, '==', 0, "$x << $shift == 0");
  }
}
###########

my $infval = 2 ** 1050;
cmp_ok(Math::JS::is_ok($infval / $infval), '==', 4, "is_ok(NaN) returns 4");

my $num = Math::JS->new(1000);
my $res = $num % 17;
cmp_ok($res, '==',  14,  "1000 % 17 =>  14");
cmp_ok($res->{type}, 'eq', 'sint32', " type ok for 1000 % 17");
$num %= 17;
cmp_ok($num->{type}, 'eq', 'sint32', " type ok for 1000 %= 17");
cmp_ok($num, '==', $res, "1: \$res == $num");

$num = Math::JS->new(1000);
$res = $num % -17;
cmp_ok($res, '==',  14,  "1000 % -17 => 14");
cmp_ok($res->{type}, 'eq', 'sint32', " type ok for 1000 % -17");
$num %= -17;
cmp_ok($num->{type}, 'eq', 'sint32', " type ok for 1000 %= -17");
cmp_ok($num, '==', $res, "2: \$res == $num");

$num = Math::JS->new(-1000);
$res = $num % 17;
cmp_ok($res, '==', -14, "-1000 % 17 => -14");
cmp_ok($res->{type}, 'eq', 'sint32', " type ok for -1000 % 17");
$num %= 17;
cmp_ok($num->{type}, 'eq', 'sint32', " type ok for -1000 %= 17");
cmp_ok($num, '==', $res, "3: \$res == $num");

$num = Math::JS->new(-1000);
$res = $num % -17;
cmp_ok($res, '==', -14, "-1000 % 17 => -14");
cmp_ok($res->{type}, 'eq', 'sint32', " type ok for -1000 % -17");
$num %= -17;
cmp_ok($num->{type}, 'eq', 'sint32', " type ok for -1000 %= -17");
cmp_ok($num, '==', $res, "4: \$res == $num");

$num = Math::JS->new(1000.9);
$res = $num % 17;
cmp_ok($res, '==',  14.899999999999977,  "1000.9 %  17 =>  14.899999999999977");
cmp_ok($res->{type}, 'eq', 'number', " type ok for 1000.9 % 17");
$num %= 17;
cmp_ok($num->{type}, 'eq', 'number', " type ok for 1000.9 %= 17");
cmp_ok($num, '==', $res, "5: \$res == $num");

$num = Math::JS->new(1000.9);
$res = $num % -17;
cmp_ok($res, '==',  14.899999999999977,  "1000.9 % -17 =>  14.899999999999977");
cmp_ok($res->{type}, 'eq', 'number', " type ok for 1000.9 % -17");
$num %= -17;
cmp_ok($num->{type}, 'eq', 'number', " type ok for 1000.9 %= -17");
cmp_ok($num, '==', $res, "6: \$res == $num");

$num = Math::JS->new(-1000.9);
$res = $num % 17;
cmp_ok($res, '==', -14.899999999999977, "-1000.9 %  17 => -14.899999999999977");
cmp_ok($res->{type}, 'eq', 'number', " type ok for -1000.9 % 17");
$num %= 17;
cmp_ok($num->{type}, 'eq', 'number', " type ok for -1000.9 %= 17");
cmp_ok($num, '==', $res, "7: \$res == $num");

$num = Math::JS->new(-1000.9);
$res = $num % -17;
cmp_ok($res, '==', -14.899999999999977, "-1000.9 % -17 => -14.899999999999977");
cmp_ok($res->{type}, 'eq', 'number', " type ok for -1000.9 % -17");
$num %= -17;
cmp_ok($num->{type}, 'eq', 'number', " type ok for -1000.9 %= -17");
cmp_ok($num, '==', $res, "8: \$res == $num");

$num = Math::JS->new(1000);
$res = $num % 17.5;
cmp_ok($res, '==',  2.5,  "1000 %  17.5 =>  2.5");
cmp_ok($res->{type}, 'eq', 'number', " type ok for 1000 % 17.5");
$num %= 17.5;
cmp_ok($num->{type}, 'eq', 'number', " type ok for 1000 %= 17.5");
cmp_ok($num, '==', $res, "9: \$res == $num");

$num = Math::JS->new(1000);
$res = $num % -17.5;
cmp_ok($res, '==',  2.5,  "1000 % -17.5 =>  2.5");
cmp_ok($res->{type}, 'eq', 'number', " type ok for 1000 % -17.5");
$num %= -17.5;
cmp_ok($num->{type}, 'eq', 'number', " type ok for 1000 %= -17.5");
cmp_ok($num, '==', $res, "10: \$res == $num");

$num = Math::JS->new(-1000);
$res = $num % 17.5;
cmp_ok($res, '==', -2.5, "-1000 %  17.5 => -2.5");
cmp_ok($res->{type}, 'eq', 'number', " type ok for -1000 % 17.5");
$num %= 17.5;
cmp_ok($num->{type}, 'eq', 'number', " type ok for -1000 %= 17.5");
cmp_ok($num, '==', $res, "11: \$res == $num");

$num = Math::JS->new(-1000);
$res = $num % -17.5;
cmp_ok($res, '==', -2.5, "-1000 % -17.5 => -2.5");
cmp_ok($res->{type}, 'eq', 'number', " type ok for -1000 % -17.5");
$num %= -17.5;
cmp_ok($num->{type}, 'eq', 'number', " type ok for -1000 %= 17.5");

cmp_ok($num, '==', $res, "12: \$res == $num");
$num = Math::JS->new(1000.9);
$res = $num % 17.5;
cmp_ok($res, '==',  3.3999999999999773,  "1000 %  17.5 =>  3.3999999999999773");
cmp_ok($res->{type}, 'eq', 'number', " type ok for 1000.9 % 17.5");
$num %= 17.5;
cmp_ok($num->{type}, 'eq', 'number', " type ok for 1000.9 %= 17.5");
cmp_ok($num, '==', $res, "13: \$res == $num");

$num = Math::JS->new(1000.9);
$res = $num % -17.5;
cmp_ok($res, '==',  3.3999999999999773,  "1000 % -17.5 =>  3.3999999999999773");
cmp_ok($res->{type}, 'eq', 'number', " type ok for 1000.9 % -17.5");
$num %= -17.5;
cmp_ok($num->{type}, 'eq', 'number', " type ok for 1000.9 %= -17.5");
cmp_ok($num, '==', $res, "14: \$res == $num");

$num = Math::JS->new(-1000.9);
$res = $num % 17.5;
cmp_ok($res, '==', -3.3999999999999773, "-1000 %  17.5 => -3.3999999999999773");
cmp_ok($res->{type}, 'eq', 'number', " type ok for -1000.9 % 17.5");
$num %= 17.5;
cmp_ok($num->{type}, 'eq', 'number', " type ok for -1000.9 %= 17.5");
cmp_ok($num, '==', $res, "15: \$res == $num");

$num = Math::JS->new(-1000.9);
$res = $num % -17.5;
cmp_ok($res, '==', -3.3999999999999773, "-1000.9 -17.5 => -3.3999999999999773");
cmp_ok($res->{type}, 'eq', 'number', " type ok for -1000.9 % -17.5");
$num %= -17.5;
cmp_ok($num->{type}, 'eq', 'number', " type ok for -1000.9 %= -17.5");
cmp_ok($num, '==', $res, "16: \$res == $num");

########################################################
cmp_ok(Math::JS->new( 1000) % Math::JS->new( 17), '==',  14,  "1000 % 17 =>  14");
cmp_ok(Math::JS->new( 1000) % Math::JS->new(-17), '==',  14,  "1000 % -17 => 14");
cmp_ok(Math::JS->new(-1000) % Math::JS->new( 17), '==', -14, "-1000 % 17 => -14");
cmp_ok(Math::JS->new(-1000) % Math::JS->new(-17), '==', -14, "-1000 % 17 => -14");

cmp_ok(Math::JS->new( 1000.9) % Math::JS->new( 17), '==',  14.899999999999977,  "1000.9 %  17 =>  14.899999999999977");
cmp_ok(Math::JS->new( 1000.9) % Math::JS->new(-17), '==',  14.899999999999977,  "1000.9 % -17 =>  14.899999999999977");
cmp_ok(Math::JS->new(-1000.9) % Math::JS->new( 17), '==', -14.899999999999977, "-1000.9 %  17 => -14.899999999999977");
cmp_ok(Math::JS->new(-1000.9) % Math::JS->new(-17), '==', -14.899999999999977, "-1000.9 % -17 => -14.899999999999977");

cmp_ok(Math::JS->new( 1000) % Math::JS->new( 17.5), '==',  2.5,  "1000 %  17.5 =>  2.5");
cmp_ok(Math::JS->new( 1000) % Math::JS->new(-17.5), '==',  2.5,  "1000 % -17.5 =>  2.5");
cmp_ok(Math::JS->new(-1000) % Math::JS->new( 17.5), '==', -2.5, "-1000 %  17.5 => -2.5");
cmp_ok(Math::JS->new(-1000) % Math::JS->new(-17.5), '==', -2.5, "-1000 % -17.5 => -2.5");

cmp_ok(Math::JS->new( 1000.9) % Math::JS->new( 17.5), '==',  3.3999999999999773,  "1000 %  17.5 =>  3.3999999999999773");
cmp_ok(Math::JS->new( 1000.9) % Math::JS->new(-17.5), '==',  3.3999999999999773,  "1000 % -17.5 =>  3.3999999999999773");
cmp_ok(Math::JS->new(-1000.9) % Math::JS->new( 17.5), '==', -3.3999999999999773, "-1000 %  17.5 => -3.3999999999999773");
cmp_ok(Math::JS->new(-1000.9) % Math::JS->new(-17.5), '==', -3.3999999999999773, "-1000 % -17.5 => -3.3999999999999773");
#######################################################

for my $n(19, 19.3, -19, -19.3) {
  for my $d(125, 125.7, -125,-125.7) {
    my $num = Math::JS->new($n);
    my $den = Math::JS->new($d);
    my $res = $num % $den;
    cmp_ok($res, '==', $n, "$n % $d => $n");
    cmp_ok($res->{type}, 'eq', $classify{Math::JS::is_ok($n)}, "resulting type ok for $n % $d");
    cmp_ok($num->{type}, 'eq', $classify{Math::JS::is_ok($n)}, "numerator type ok for $n % $d");
    cmp_ok($den->{type}, 'eq', $classify{Math::JS::is_ok($d)}, "denominator type ok for $n % $d");
  }
}

cmp_ok(9007199254740991 % Math::JS->new (2147483648),  '==',  2147483647, "9007199254740991 %  2147483648 =>  2147483647");
cmp_ok(9007199254740991 % Math::JS->new(-2147483648),  '==',  2147483647, "9007199254740991 % -2147483648 =>  2147483647");
cmp_ok(9007199254740991 % Math::JS->new (2147483647),  '==',  4194303,    "9007199254740991 %  2147483647 =>  4194303");
cmp_ok(9007199254740991 % Math::JS->new(-2147483647),  '==',  4194303,    "9007199254740991 % -2147483647 =>  4194303");
cmp_ok(-9007199254740991 % Math::JS->new (2147483647), '==', -4194303,    "9007199254740991 %  2147483647 =>  -4194303");
cmp_ok(-9007199254740991 % Math::JS->new(-2147483647), '==', -4194303,    "9007199254740991 % -2147483647 =>  -4194303");

cmp_ok(Math::JS->new(3)  / 0, '==', $pinf,  '3 / 0 =>  Infinity');
cmp_ok(Math::JS->new(-3) / 0, '==', $ninf, '-3 / 0 => -Infinity');

my $rop = Math::JS->new(3) % 0;
cmp_ok(Math::JS::_isnan($rop->{val}), '==', 1, "3 % 0 => NaN");
$rop = Math::JS->new(-3) % 0;
cmp_ok(Math::JS::_isnan($rop->{val}), '==', 1, "-3 % 0 => NaN");

$rop =  Math::JS->new($pinf) % 15;
cmp_ok(Math::JS::_isnan($rop->{val}), '==', 1, "+inf % 15 => NaN");
$rop =  $ninf %Math::JS->new(-15);
cmp_ok(Math::JS::_isnan($rop->{val}), '==', 1, "-inf % -15 => NaN");

$rop = -123 % Math::JS->new($pinf);
cmp_ok($rop, '==', -123, "-123 % +inf => -123");
$rop = 123 % Math::JS->new($ninf);
cmp_ok($rop, '==', 123, "123 % -inf => 123");

# 0 % anything-except-nan returns 0
cmp_ok(Math::JS->new(0) % 17,    '==', 0, '0 % 17 => 0');
cmp_ok(Math::JS->new(0) % $ninf, '==', 0, '0 % -inf => 0');
cmp_ok(Math::JS->new(0) % $nan,  '!=', 0, '0 % NaN != 0');   # returns NaN



# TODO: The following test fails. 859064762.875 is returned by the Math::JS implementation,
#cmp_ok(900719925474099.7 % Math::JS->new(2147483647.83), '==', 859064762.882, "900719925474099.7 % 2147483647.83 =>  859064762.882");

done_testing();

__END__











