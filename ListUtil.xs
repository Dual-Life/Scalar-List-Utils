/* Copyright (c) 1997-2000 Graham Barr <gbarr@pobox.com>. All rights reserved.
 * This program is free software; you can redistribute it and/or
 * modify it under the same terms as Perl itself.
 */
#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "ppport.h"

#if PERL_BCDVERSION >= 0x5006000
#  include "multicall.h"
#endif

/* Some platforms have strict exports. And before 5.7.3 cxinc (or Perl_cxinc)
   was not exported. Therefore platforms like win32, VMS etc have problems
   so we redefine it here -- GMB
*/
#if PERL_BCDVERSION < 0x5007000
/* Not in 5.6.1. */
#  ifdef cxinc
#    undef cxinc
#  endif
#  define cxinc() my_cxinc(aTHX)
static I32
my_cxinc(pTHX)
{
    cxstack_max = cxstack_max * 3 / 2;
    Renew(cxstack, cxstack_max + 1, struct context);      /* XXX should fix CXINC macro */
    return cxstack_ix + 1;
}
#endif

#ifdef SVf_IVisUV
#  define slu_sv_value(sv) (SvIOK(sv)) ? (SvIOK_UV(sv)) ? (NV)(SvUVX(sv)) : (NV)(SvIVX(sv)) : (SvNV(sv))
#else
#  define slu_sv_value(sv) (SvIOK(sv)) ? (NV)(SvIVX(sv)) : (SvNV(sv))
#endif

MODULE=List::Util	PACKAGE=List::Util

void
min(...)
PROTOTYPE: @
ALIAS:
    min = 0
    max = 1
CODE:
{
    int index;
    NV retval;
    SV *retsv;
    int magic;
    if(!items) {
	XSRETURN_UNDEF;
    }
    retsv = ST(0);
    magic = SvAMAGIC(retsv);
    if (!magic) {
      retval = slu_sv_value(retsv);
    }
    for(index = 1 ; index < items ; index++) {
	SV *stacksv = ST(index);
        SV *tmpsv;
        if ((magic || SvAMAGIC(stacksv)) && (tmpsv = amagic_call(retsv, stacksv, gt_amg, 0))) {
             if (SvTRUE(tmpsv) ? !ix : ix) {
                  retsv = stacksv;
                  magic = SvAMAGIC(retsv);
                  if (!magic) {
                      retval = slu_sv_value(retsv);
                  }
             }
        }
        else {
            NV val = slu_sv_value(stacksv);
            if (magic) {
                retval = slu_sv_value(retsv);
                magic = 0;
            }
            if(val < retval ? !ix : ix) {
                retsv = stacksv;
                retval = val;
            }
        }
    }
    ST(0) = retsv;
    XSRETURN(1);
}



void
sum(...)
PROTOTYPE: @
CODE:
{
    dXSTARG;
    SV *sv;
    SV *retsv = NULL;
    int index;
    NV retval = 0;
    int magic;
    if(!items) {
	XSRETURN_UNDEF;
    }
    sv    = ST(0);
    magic = SvAMAGIC(sv);
    if (magic) {
        retsv = TARG;
        sv_setsv(retsv, sv);
    }
    else {
        retval = slu_sv_value(sv);
    }
    for(index = 1 ; index < items ; index++) {
        sv = ST(index);
        if(!magic && SvAMAGIC(sv)){
            magic = TRUE;
            if (!retsv) {
                retsv = TARG;
                sv_setnv(retsv,retval);
            }
        }
        if (magic) {
            SV* const tmpsv = amagic_call(retsv, sv, add_amg, SvAMAGIC(retsv) ? AMGf_assign : 0);
            if(tmpsv){
                retsv = tmpsv;
            }
            else {
                /* fall back to default */
                sv_setnv(retsv, SvNV(retsv) + SvNV(sv));
            }
        }
        else {
          retval += slu_sv_value(sv);
        }
    }
    if (!retsv) {
        retsv = TARG;
        sv_setnv(retsv,retval);
    }
    ST(0) = retsv;
    XSRETURN(1);
}

#define SLU_CMP_LARGER   1
#define SLU_CMP_SMALLER -1

void
minstr(...)
PROTOTYPE: @
ALIAS:
    minstr = SLU_CMP_LARGER
    maxstr = SLU_CMP_SMALLER
CODE:
{
    SV *left;
    int index;
    if(!items) {
	XSRETURN_UNDEF;
    }
    left = ST(0);
#ifdef OPpLOCALE
    if(MAXARG & OPpLOCALE) {
	for(index = 1 ; index < items ; index++) {
	    SV *right = ST(index);
	    if(sv_cmp_locale(left, right) == ix)
		left = right;
	}
    }
    else {
#endif
	for(index = 1 ; index < items ; index++) {
	    SV *right = ST(index);
	    if(sv_cmp(left, right) == ix)
		left = right;
	}
#ifdef OPpLOCALE
    }
#endif
    ST(0) = left;
    XSRETURN(1);
}



#ifdef dMULTICALL

void
reduce(block,...)
    SV * block
PROTOTYPE: &@
CODE:
{
    dMULTICALL;
    SV *ret = sv_newmortal();
    int index;
    GV *agv,*bgv,*gv;
    HV *stash;
    I32 gimme = G_SCALAR;
    SV **args = &PL_stack_base[ax];
    CV *cv;

    if(items <= 1) {
	XSRETURN_UNDEF;
    }
    cv = sv_2cv(block, &stash, &gv, 0);
    if (cv == Nullcv) {
       croak("Not a subroutine reference");
    }
    PUSH_MULTICALL(cv);
    agv = gv_fetchpv("a", TRUE, SVt_PV);
    bgv = gv_fetchpv("b", TRUE, SVt_PV);
    SAVESPTR(GvSV(agv));
    SAVESPTR(GvSV(bgv));
    GvSV(agv) = ret;
    SvSetSV(ret, args[1]);
    for(index = 2 ; index < items ; index++) {
	GvSV(bgv) = args[index];
	MULTICALL;
	SvSetSV(ret, *PL_stack_sp);
    }
    POP_MULTICALL;
    ST(0) = ret;
    XSRETURN(1);
}

void
first(block,...)
    SV * block
PROTOTYPE: &@
CODE:
{
    dMULTICALL;
    int index;
    GV *gv;
    HV *stash;
    I32 gimme = G_SCALAR;
    SV **args = &PL_stack_base[ax];
    CV *cv;

    if(items <= 1) {
	XSRETURN_UNDEF;
    }
    cv = sv_2cv(block, &stash, &gv, 0);
    if (cv == Nullcv) {
       croak("Not a subroutine reference");
    }
    PUSH_MULTICALL(cv);
    SAVESPTR(GvSV(PL_defgv));

    for(index = 1 ; index < items ; index++) {
	GvSV(PL_defgv) = args[index];
	MULTICALL;
	if (SvTRUE(*PL_stack_sp)) {
	  POP_MULTICALL;
	  ST(0) = ST(index);
	  XSRETURN(1);
	}
    }
    POP_MULTICALL;
    XSRETURN_UNDEF;
}

#endif

void
shuffle(...)
PROTOTYPE: @
CODE:
{
    int index;
#if (PERL_VERSION < 9)
    struct op dmy_op;
    struct op *old_op = PL_op;

    /* We call pp_rand here so that Drand01 get initialized if rand()
       or srand() has not already been called
    */
    memzero((char*)(&dmy_op), sizeof(struct op));
    /* we let pp_rand() borrow the TARG allocated for this XS sub */
    dmy_op.op_targ = PL_op->op_targ;
    PL_op = &dmy_op;
    (void)*(PL_ppaddr[OP_RAND])(aTHX);
    PL_op = old_op;
#else
    /* Initialize Drand01 if rand() or srand() has
       not already been called
    */
    if (!PL_srand_called) {
        (void)seedDrand01((Rand_seed_t)Perl_seed(aTHX));
        PL_srand_called = TRUE;
    }
#endif

    for (index = items ; index > 1 ; ) {
	int swap = (int)(Drand01() * (double)(index--));
	SV *tmp = ST(swap);
	ST(swap) = ST(index);
	ST(index) = tmp;
    }
    XSRETURN(items);
}


MODULE=List::Util	PACKAGE=Scalar::Util

void
dualvar(num,str)
    SV *	num
    SV *	str
PROTOTYPE: $$
CODE:
{
    STRLEN len;
    const char *ptr = SvPV_const(str,len);
    ST(0) = sv_newmortal();
    (void)SvUPGRADE(ST(0),SVt_PVNV);
    sv_setpvn(ST(0),ptr,len);
    if (SvUTF8(str))
        SvUTF8_on(ST(0));
    if(SvNOK(num) || SvPOK(num) || SvMAGICAL(num)) {
	SvNV_set(ST(0), SvNV(num));
	SvNOK_on(ST(0));
    }
#ifdef SVf_IVisUV
    else if (SvUOK(num)) {
	SvUV_set(ST(0), SvUV(num));
	SvIOK_on(ST(0));
	SvIsUV_on(ST(0));
    }
#endif
    else {
	SvIV_set(ST(0), SvIV(num));
	SvIOK_on(ST(0));
    }
    if(PL_tainting && (SvTAINTED(num) || SvTAINTED(str)))
	SvTAINTED_on(ST(0));
    XSRETURN(1);
}

char *
blessed(sv)
    SV * sv
PROTOTYPE: $
CODE:
{
    SvGETMAGIC(sv);
    if(!(SvROK(sv) && SvOBJECT(SvRV(sv)))) {
	XSRETURN_UNDEF;
    }
    RETVAL = (char*)sv_reftype(SvRV(sv),TRUE);
}
OUTPUT:
    RETVAL

char *
reftype(sv)
    SV * sv
PROTOTYPE: $
CODE:
{
    SvGETMAGIC(sv);
    if(!SvROK(sv)) {
	XSRETURN_UNDEF;
    }
    RETVAL = (char*)sv_reftype(SvRV(sv),FALSE);
}
OUTPUT:
    RETVAL

UV
refaddr(sv)
    SV * sv
PROTOTYPE: $
CODE:
{
    SvGETMAGIC(sv);
    if(!SvROK(sv)) {
	XSRETURN_UNDEF;
    }
    RETVAL = PTR2UV(SvRV(sv));
}
OUTPUT:
    RETVAL

void
weaken(sv)
	SV *sv
PROTOTYPE: $
CODE:
#ifdef SvWEAKREF
	sv_rvweaken(sv);
#else
	croak("weak references are not implemented in this release of perl");
#endif

void
isweak(sv)
	SV *sv
PROTOTYPE: $
CODE:
#ifdef SvWEAKREF
	ST(0) = boolSV(SvROK(sv) && SvWEAKREF(sv));
	XSRETURN(1);
#else
	croak("weak references are not implemented in this release of perl");
#endif

int
readonly(sv)
	SV *sv
PROTOTYPE: $
CODE:
  RETVAL = SvREADONLY(sv);
OUTPUT:
  RETVAL

int
tainted(sv)
	SV *sv
PROTOTYPE: $
CODE:
  RETVAL = SvTAINTED(sv);
OUTPUT:
  RETVAL

void
isvstring(sv)
       SV *sv
PROTOTYPE: $
CODE:
#ifdef SvVOK
  ST(0) = boolSV(SvVOK(sv));
  XSRETURN(1);
#else
	croak("vstrings are not implemented in this release of perl");
#endif

int
looks_like_number(sv)
	SV *sv
PROTOTYPE: $
CODE:
  SV *tempsv;
  if (SvAMAGIC(sv) && (tempsv = AMG_CALLun(sv, numer))) {
    sv = tempsv;
  }
  SvGETMAGIC(sv);
#if PERL_BCDVERSION < 0x5008005
  if (SvPOK(sv) || SvPOKp(sv)) {
    RETVAL = looks_like_number(sv);
  }
  else {
    RETVAL = SvFLAGS(sv) & (SVf_NOK|SVp_NOK|SVf_IOK|SVp_IOK);
  }
#else
  RETVAL = looks_like_number(sv);
#endif
OUTPUT:
  RETVAL

void
set_prototype(subref, proto)
    SV *subref
    SV *proto
PROTOTYPE: &$
CODE:
{
    if (SvROK(subref)) {
	SV *sv = SvRV(subref);
	if (SvTYPE(sv) != SVt_PVCV) {
	    /* not a subroutine reference */
	    croak("set_prototype: not a subroutine reference");
	}
	if (SvPOK(proto)) {
	    /* set the prototype */
	    STRLEN len;
	    const char *ptr = SvPV_const(proto, len);
	    sv_setpvn(sv, ptr, len);
	}
	else {
	    /* delete the prototype */
	    SvPOK_off(sv);
	}
    }
    else {
	croak("set_prototype: not a reference");
    }
    XSRETURN(1);
}

void
openhandle(SV* sv)
PROTOTYPE: $
CODE:
{
    IO* io = NULL;
    SvGETMAGIC(sv);
    if(SvROK(sv)){
        /* deref first */
        sv = SvRV(sv);
    }

    /* must be GLOB or IO */
    if(isGV(sv)){
        io = GvIO((GV*)sv);
    }
    else if(SvTYPE(sv) == SVt_PVIO){
        io = (IO*)sv;
    }

    if(io){
        /* real or tied filehandle? */
        if(IoIFP(io) || SvTIED_mg((SV*)io, PERL_MAGIC_tiedscalar)){
            XSRETURN(1);
        }
    }
    XSRETURN_UNDEF;
}

BOOT:
{
    HV *lu_stash = gv_stashpvn("List::Util", 10, TRUE);
    GV *rmcgv = *(GV**)hv_fetch(lu_stash, "REAL_MULTICALL", 14, TRUE);
    SV *rmcsv;
#if !defined(SvWEAKREF) || !defined(SvVOK)
    HV *su_stash = gv_stashpvn("Scalar::Util", 12, TRUE);
    GV *vargv = *(GV**)hv_fetch(su_stash, "EXPORT_FAIL", 11, TRUE);
    AV *varav;
    if (SvTYPE(vargv) != SVt_PVGV)
	gv_init(vargv, su_stash, "Scalar::Util", 12, TRUE);
    varav = GvAVn(vargv);
#endif
    if (SvTYPE(rmcgv) != SVt_PVGV)
	gv_init(rmcgv, lu_stash, "List::Util", 12, TRUE);
    rmcsv = GvSVn(rmcgv);
#ifndef SvWEAKREF
    av_push(varav, newSVpv("weaken",6));
    av_push(varav, newSVpv("isweak",6));
#endif
#ifndef SvVOK
    av_push(varav, newSVpv("isvstring",9));
#endif
#ifdef REAL_MULTICALL
    sv_setsv(rmcsv, &PL_sv_yes);
#else
    sv_setsv(rmcsv, &PL_sv_no);
#endif
}
