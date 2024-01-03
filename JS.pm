# Checked against calculator at https://playcode.io/new
package Math::JS;
use strict;
use warnings;
use Config;

BEGIN {

  # By default, the '""' overloading (sub oload_stringify) will use
  # Math::MPFR::nvtoa() or Math::MPFR::mpfrtoa() if available. This
  # can be prevented by setting $ENV{NO_MPFR} to a true value - thus
  # ensuring that oload_stringify() uses sprintf("%.17g",val).
  # (This capability is useful for author testing.)

  unless(defined $ENV{NO_MPFR}) {
    eval{require Math::MPFR;};
    unless($@) {
      if($Config{nvsize} != 8) {
        $Math::JS::USE_NVTOA = 0;
        if($Math::MPFR::VERSION >= 4.17) {
          $Math::JS::USE_MPFRTOA = 1;
        }
        else {
          $Math::JS::USE_MPFRTOA = 0;
        }
      }
      else { # $config{nvsize} == 8 (double)
        if($Math::MPFR::VERSION >= 4.05) {
          $Math::JS::USE_NVTOA = 1;
          $Math::JS::USE_MPFRTOA = 0;
        }
        else {
          $Math::JS::USE_NVTOA = 0;
          $Math::JS::USE_MPFRTOA = 0;
        }
      }
    }
    else { # Math::MPFR not available
      $Math::JS::USE_NVTOA = 0;
      $Math::JS::USE_MPFRTOA = 0;
    }
  }  # close unless{} block
  else {
    $Math::JS::USE_NVTOA = 0;
    $Math::JS::USE_MPFRTOA = 0;
  }
};   # close BEGIN{}  block

use overload
'+'    => \&oload_add,
'-'    => \&oload_sub,
'*'    => \&oload_mul,
'/'    => \&oload_div,
'**'   => \&oload_pow,
'++'   => \&oload_inc,
'--'   => \&oload_dec,
'>='   => \&oload_gte,
'<='   => \&oload_lte,
'=='   => \&oload_equiv,
'>'    => \&oload_gt,
'<'    => \&oload_lt,
'<=>'  => \&oload_spaceship,
'""'   => \&oload_stringify,
'&'    => \&oload_and,
'|'    => \&oload_ior,
'^'    => \&oload_xor,
'~'    => \&oload_not,
'<<'   => \&oload_lshift,
'>>'   => \&oload_rshift,
;

use constant MAX_ULONG =>  4294967295;
use constant MAX_SLONG =>  2147483647;
use constant MIN_ULONG =>  2147483648;  # 1<<31 (Lowest positive value that sets 32nd bit)
use constant MIN_SLONG => -2147483648;
use constant LOW_31BIT =>  1073741824;  # 1<<30 (Lowest 31 bit positive number)
use constant MAX_NUM   =>  9007199254740991;
use constant IVSIZE    => $Config{ivsize};
use constant NVSIZE    => $Config{nvsize};
use constant USE_NVTOA => $Math::JS::USE_NVTOA;
use constant USE_MPFRTOA => $Math::JS::USE_MPFRTOA;

our $VERSION = '0.01';

require DynaLoader;
Math::JS->DynaLoader::bootstrap($VERSION);
sub dl_load_flags {0}

sub new {
  shift if(!ref($_[0]) && $_[0] eq "Math::JS"); # 'new' has been called as a method
  my $val = shift;
  my $ok = is_ok($val); # returns 1 for Math::JS object, 2 for a 32-bit UV,
                        # 3 for a 32-bit IV, 4 for an NV, and 0 (not ok) for anything else.
  die "Bad argument (or no argument) given to new" unless $ok;

  if($ok == 1) {
    # return a copy of the given Math::JS object
    my $ret = shift;
    return $ret;
  }

  if(NVSIZE != 8) {
    $val = unpack('d', pack 'd', $val) if $ok == 4;
  }

  my %h = ('val' => $val, 'type' => _classify($val, $ok));
  return bless(\%h, 'Math::JS');
}

########### + ##########
sub oload_add {
  die "Wrong number of arguments given to oload_add()"
    if @_ > 3;

  my $ok = is_ok($_[1]); # check that 2nd arg is suitable.
  die "Bad argument given to oload_add" unless $ok;

  my $retval;

  if($ok == 1) {
    my $retval1 = _evaluate($_[0]->{val}, $_[0]->{type});
    my $retval2 = _evaluate($_[1]->{val}, $_[1]->{type});

    if($_[0]->{type} eq 'sint32' && $_[1]->{type} eq 'sint32') {
      $retval = $retval1 + $retval2;

      return Math::JS->new(unpack 'L', pack 'L', $retval)
        if(is_ok($retval) == 2);

      return Math::JS->new(unpack 'l', pack 'L', $retval);
    }
    return Math::JS->new($retval1 + $retval2);
  }

  $retval = _evaluate($_[0]->{val}, $_[0]->{type}) + $_[1];
  return Math::JS->new($retval);
}

########### * ##########
sub oload_mul {
  die "Wrong number of arguments given to oload_mul()"
    if @_ > 3;

  my $ok = is_ok($_[1]); # check that 2nd arg is suitable.
  die "Bad argument given to oload_mul" unless $ok;

  my $retval;

  if($ok == 1) {
    my $retval1 = _evaluate($_[0]->{val}, $_[0]->{type});
    my $retval2 = _evaluate($_[1]->{val}, $_[1]->{type});

    if($_[0]->{type} eq 'sint32' && $_[1]->{type} eq 'sint32') {
      $retval = $retval1 * $retval2;

      return Math::JS->new(unpack 'L', pack 'L', $retval)
        if(is_ok($retval) == 2);

      return Math::JS->new(unpack 'l', pack 'L', $retval);
    }
    return Math::JS->new($retval1 * $retval2);
  }

  $retval = _evaluate($_[0]->{val}, $_[0]->{type}) * $_[1];
  return Math::JS->new($retval);
}

########### - ##########
sub oload_sub {
  die "Wrong number of arguments given to oload_sub()"
    if @_ > 3;

  my $ok = is_ok($_[1]); # check that 2nd arg is suitable.
  die "Bad argument given to oload_sub" unless $ok;

  my $third_arg = $_[2];
  my $retval;

  if($ok == 1) {
    if($third_arg) {

      $retval = _evaluate($_[1]->{val}, $_[1]->{type}) - _evaluate($_[0]->{val}, $_[0]->{type});
      return Math::JS->new($retval);
    }
    $retval = _evaluate($_[0]->{val}, $_[0]->{type}) - _evaluate($_[1]->{val}, $_[1]->{type});
    return Math::JS->new($retval);
  }

  if($third_arg) {
    $retval = $_[1] - _evaluate($_[0]->{val}, $_[0]->{type});
    return Math::JS->new($retval);
  }
  $retval = _evaluate($_[0]->{val}, $_[0]->{type}) - $_[1];
  return Math::JS->new($retval);
}

########### / ##########
sub oload_div {
  die "Wrong number of arguments given to oload_div()"
    if @_ > 3;

  my $ok = is_ok($_[1]); # check that 2nd arg is suitable.
  die "Bad argument given to oload_div" unless $ok;

  my $third_arg = $_[2];
  my $retval;

  if($ok == 1) {
    if($third_arg) {

      $retval = unpack "d", pack("d", _evaluate($_[1]->{val}, $_[1]->{type}) / _evaluate($_[0]->{val}, $_[0]->{type}));
      return Math::JS->new($retval);
    }
    $retval = unpack "d", pack("d", _evaluate($_[0]->{val}, $_[0]->{type}) / _evaluate($_[1]->{val}, $_[1]->{type}));
    return Math::JS->new($retval);
  }

  if($third_arg) {
    $retval = unpack "d", pack("d", $_[1] / _evaluate($_[0]->{val}, $_[0]->{type}));
    return Math::JS->new($retval);
  }
  $retval = unpack "d", pack("d", _evaluate($_[0]->{val}, $_[0]->{type}) / $_[1]);
  return Math::JS->new($retval);
}

########### ** ##########
sub oload_pow {
  die "Wrong number of arguments given to oload_pow()"
    if @_ > 3;

  my $ok = is_ok($_[1]); # check that 2nd arg is suitable.
  die "Bad argument given to oload_div" unless $ok;

  my $third_arg = $_[2];
  my $retval;

  if($ok == 1) {
    if($third_arg) {

      $retval = _evaluate($_[1]->{val}, $_[1]->{type}) ** _evaluate($_[0]->{val}, $_[0]->{type});
      return Math::JS->new($retval);
    }
    $retval = _evaluate($_[0]->{val}, $_[0]->{type}) ** _evaluate($_[1]->{val}, $_[1]->{type});
    return Math::JS->new($retval);
  }

  if($third_arg) {
    $retval = $_[1] ** _evaluate($_[0]->{val}, $_[0]->{type});
    return Math::JS->new($retval);
  }
  $retval = _evaluate($_[0]->{val}, $_[0]->{type}) ** $_[1];
  return Math::JS->new($retval);
}

########### & ##########
sub oload_and {
  die "Wrong number of arguments given to oload_and()"
    if @_ > 3;

  die "'&' operator overloading not yet implemented for Math::JS objects whose values are not 32-bit integers"
    unless ($_[0]->{type} =~ /int32/);

  my $ok = is_ok($_[1]); # check that 2nd arg is suitable.
  die "Bad argument given to oload_and" unless ($ok && $ok < 4);


  my $retval;

  if($ok == 1) {
    die "'&' operator overloading not yet implemented for Math::JS objects whose values are not 32-bit integers"
      unless ($_[0]->{type} =~ /int32/);
    $retval = ($_[0]->{val} & 0xffffffff) & ($_[1]->{val} & 0xffffffff);
    return Math::JS->new(unpack 'l', pack 'L', $retval);
  }

  $retval = ($_[0]->{val} & 0xffffffff) & ($_[1] & 0xffffffff);
  return Math::JS->new(unpack 'l', pack 'L', $retval);
}

########### | ##########
sub oload_ior {
  die "Wrong number of arguments given to oload_ior()"
    if @_ > 3;

  die "'|' operator overloading not yet implemented for Math::JS objects whose values are not 32-bit integers"
    unless ($_[0]->{type} =~ /int32/);

  my $ok = is_ok($_[1]); # check that 2nd arg is suitable.
  die "Bad argument given to oload_ior" unless ($ok && $ok < 4);

  my $retval;

  if($ok == 1) {
    die "'|' operator overloading not yet implemented for Math::JS objects whose values are not 32-bit integers"
      unless ($_[0]->{type} =~ /int32/);
    $retval = ($_[0]->{val} & 0xffffffff) | ($_[1]->{val} & 0xffffffff);
    return Math::JS->new(unpack 'l', pack 'L', $retval);
  }

  $retval = ($_[0]->{val} & 0xffffffff) | ($_[1] & 0xffffffff);
  return Math::JS->new(unpack 'l', pack 'L', $retval);
}

########### ^ ##########
sub oload_xor {
  die "Wrong number of arguments given to oload_xor()"
    if @_ > 3;

  die "'^' operator overloading not yet implemented for Math::JS objects whose values are not 32-bit integers"
    unless ($_[0]->{type} =~ /int32/);

  my $ok = is_ok($_[1]); # check that 2nd arg is suitable.
  die "Bad argument given to oload_xor" unless ($ok && $ok < 4);

  my $retval;

  if($ok == 1) {
    die "'^' operator overloading not yet implemented for Math::JS objects whose values are not 32-bit integers"
      unless ($_[0]->{type} =~ /int32/);
    $retval = ($_[0]->{val} & 0xffffffff) ^ ($_[1]->{val} & 0xffffffff);
    return Math::JS->new(unpack 'l', pack 'L', $retval);
  }

  $retval = ($_[0]->{val} & 0xffffffff) ^ ($_[1] & 0xffffffff);
  return Math::JS->new(unpack 'l', pack 'L', $retval);
}

########### ~ ##########
sub oload_not {
  die "Wrong number of arguments given to oload_ior()"
    if @_ > 3;

  die "'~' operator overloading not yet implemented for Math::JS objects whose values are not 32-bit integers"
    unless ($_[0]->{type} =~ /int32/);

  my $val = $_[0]->{val};

  return Math::JS->new( MAX_ULONG - $val )
    if($val > MAX_SLONG);

  return Math::JS->new( -$val - 1);
}

########### ++ ##########
sub oload_inc {
  $_[0]->{type} = 'uint32' if $_[0]->{val} == MAX_SLONG;
  ($_[0]->{val}) += 1;;
}

########### -- ##########
sub oload_dec {
  $_[0]->{type} = 'sint32' if $_[0]->{val} == MIN_ULONG;
  ($_[0]->{val}) -= 1;
}

########### "" ##########
sub oload_stringify {
  my $self = shift;
  # "l" is signed 32-bit integer; "L" is unsigned 32-bit integer.
  my $ret;
  if    ($self->{type} eq 'sint32') { $ret = unpack("l", pack("L", $self->{val})) }
  elsif ($self->{type} eq 'uint32') { $ret = unpack("L", pack("L", $self->{val})) }
  else {
    if(USE_NVTOA)      { $ret = Math::MPFR::nvtoa  (Math::MPFR->new($self->{val})) }
    elsif(USE_MPFRTOA) {
      #printf "VAL: %.17g\n", $self->{val};
      #printf "TYPE: %s\n", $self->{type};
      #print "1: ", Math::MPFR::mpfrtoa(Math::MPFR->new(sprintf "%.17g", $self->{val})), "\n";
      #print "2: ", Math::MPFR::mpfrtoa(Math::MPFR->new($self->{val})), "\n";
      $ret = Math::MPFR::mpfrtoa(Math::MPFR->new(sprintf "%.17g", $self->{val}));
    }
    else               { $ret = sprintf "%.17g", $self->{val} }
 }
  return "$ret";
}

########### >= ##########
sub oload_gte {
  die "Wrong number of arguments given to oload_gte()"
    if @_ > 3;

  my $cmp = oload_spaceship($_[0], $_[1], $_[2]);

  return 1 if $cmp >= 0;
  return 0;
}

########### <= ##########
sub oload_lte {
  die "Wrong number of arguments given to oload_lte()"
    if @_ > 3;

  my $cmp = oload_spaceship($_[0], $_[1], $_[2]);

  #if($_[2]) {
  #  return 1 if $cmp >= 0;
  #  return 0;
  #}

  return 1 if $cmp <= 0;
  return 0;
}

########### == ##########
sub oload_equiv {
  die "Wrong number of arguments given to oload_equiv()"
    if @_ > 3;

  return 1 if(oload_spaceship($_[0], $_[1], $_[2]) == 0);
  return 0;
}

########### > ##########
sub oload_gt {
  die "Wrong number of arguments given to oload_gt()"
    if @_ > 3;

  my $cmp = oload_spaceship($_[0], $_[1], $_[2]);

  return 1 if $cmp > 0;
  return 0;
}

########### < ##########
sub oload_lt {
  die "Wrong number of arguments given to oload_lt()"
    if @_ > 3;

  my $cmp = oload_spaceship($_[0], $_[1], $_[2]);

  return 1 if $cmp < 0;
  return 0;
}

########### <=> ##########
sub oload_spaceship {
  die "Wrong number of arguments given to oload_spaceship()"
    if @_ > 3;

  my $ok = is_ok($_[1]); # check that 2nd arg is suitable.
  die "Bad argument given to oload_spaceship" unless $ok;

  my $third_arg = $_[2];

  if($ok == 1) {
    if($third_arg) {
      return ($_[1]->{val} <=> $_[0]->{val});
    }
    return ($_[0]->{val} <=> $_[1]->{val});
  }

  my $second = $_[1];

  $second = unpack "d", pack "d", $second
    if NVSIZE != 8;

  if($third_arg) {
     return ($second <=> $_[0]->{val});
  }
  return ($_[0]->{val} <=> $second);
}

########### << ##########
sub oload_lshift {
  die "Wrong number of arguments given to oload_lshift()"
    if @_ > 3;

  my $shift = $_[1] % 32;
  my $type  = $_[0]->{type};

  die "left-shift operation not yet implemented for Math::JS objects whose values are not 32-bit integers"
    unless ($type =~ /int32/);

  my $val   = $_[0]->{val};

  if($type eq 'sint32' && $val < 0) {
    $val *= -1;
    $val <<= $shift;
    return Math::JS->new(-$val);
  }

  my $ret = Math::JS->new(unpack 'l', pack 'l', (($_[0]->{val} & 0xffffffff) << $_[1]) );
  $ret->{type} = 'sint32';
  return $ret;
}

########### >> ##########
sub oload_rshift {
  die "Wrong number of arguments given to oload_rshift()"
    if @_ > 3;

  my $shift = $_[1] % 32;
  my $type  = $_[0]->{type};

  die "right-shift operation not yet implemented for Math::JS objects whose values are not 32-bit integers"
    unless ($type =~ /int32/);

  my $val   = $_[0]->{val};

  if($type eq 'uint32' || ($type eq 'sint32' && $val < 0)) {
    my $ior = 0xffffffff ^ ((1 << (32 - $shift)) - 1);
    my $val = unpack('l', pack 'L', $val) >> $shift;
    $val |= $ior;
    return Math::JS->new(unpack 'l', pack 'L', $val);
  }

  my $ret = Math::JS->new( ($_[0]->{val} & 0xffffffff) >> ($_[1] % 32) );
  $ret->{type} = 'sint32';
  return $ret;
}

###########################
###########################

sub _classify {
  my $arg = shift;
  return $arg->{type} if(ref($arg) && ref($arg) eq "Math::JS");
  my $ok = shift;
  return "uint32" if $ok == 2;
  return "sint32" if $ok == 3;
  return "number" if $ok == 4;
  die "Bad 2nd arg given to Math::JS::_classify()";
}

sub _evaluate {
  my($val, $type) = (shift, shift);
  # "l" is signed 32-bit integer; "L" is unsigned 32-bit integer.
  return unpack("l", pack("L", $val)) if $type eq 'sint32';
  return unpack("L", pack("L", $val)) if $type eq 'uint32';
  return "%.17g", (unpack("d", pack("d", $val))) if $type eq 'number';
  return $val;
}


1;

__END__

