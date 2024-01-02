#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

int is_ok(SV * in) {

  if(!SvOK(in)) return 0;

  if( sv_isobject(in) ) {
    const char* h = HvNAME( SvSTASH(SvRV(in)) );
    if(strEQ(h, "Math::JS")) return 1;
  }

#if IVSIZE == 4

  if( !SvPOK(in) ) {
    if( SvIOK(in) ) {
      if( SvUOK(in) ) return 2;
      return 3;
    }
    if( SvNOK(in) ) return 4;
  }

#else

  if( !SvPOK(in) ) {
    IV iv = SvIVX(in);
    if( SvIOK(in) ) {
      if( SvUOK(in) ) return 4;
      if( iv >= 0) {
        if(iv > 4294967295) return 4;
        if(iv > 2147483647) return 2;
        return 3;
      }

      if(iv < -2147483648LL) return 4;
      return 3;
    }
    if( SvNOK(in) ) return 4;
  }

#endif

  return 0;
}


MODULE = Math::JS PACKAGE = Math::JS

PROTOTYPES: DISABLE

int
is_ok (in)
	SV *	in
