/* -*- buffer-read-only: t -*-
   !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
   This file is built by regen/feature.pl.
   Any changes made here will be lost!
 */


#ifndef PERL_FEATURE_H_
#define PERL_FEATURE_H_

#if defined(PERL_CORE) || defined (PERL_EXT)

#define HINT_FEATURE_SHIFT	26

#define FEATURE_BITWISE_BIT         0x0001
#define FEATURE___SUB___BIT         0x0002
#define FEATURE_MYREF_BIT           0x0004
#define FEATURE_EVALBYTES_BIT       0x0008
#define FEATURE_FC_BIT              0x0010
#define FEATURE_POSTDEREF_QQ_BIT    0x0020
#define FEATURE_REFALIASING_BIT     0x0040
#define FEATURE_SAY_BIT             0x0080
#define FEATURE_SIGNATURES_BIT      0x0100
#define FEATURE_STATE_BIT           0x0200
#define FEATURE_SWITCH_BIT          0x0400
#define FEATURE_UNIEVAL_BIT         0x0800
#define FEATURE_UNICODE_BIT         0x1000

#define FEATURE_BUNDLE_DEFAULT	0
#define FEATURE_BUNDLE_510	1
#define FEATURE_BUNDLE_511	2
#define FEATURE_BUNDLE_515	3
#define FEATURE_BUNDLE_523	4
#define FEATURE_BUNDLE_527	5
#define FEATURE_BUNDLE_CUSTOM	(HINT_FEATURE_MASK >> HINT_FEATURE_SHIFT)

#define CURRENT_HINTS \
    (PL_curcop == &PL_compiling ? PL_hints : PL_curcop->cop_hints)
#define CURRENT_FEATURE_BUNDLE \
    ((CURRENT_HINTS & HINT_FEATURE_MASK) >> HINT_FEATURE_SHIFT)

/* Avoid using ... && Perl_feature_is_enabled(...) as that triggers a bug in
   the HP-UX cc on PA-RISC */
#define FEATURE_IS_ENABLED(name)				        \
	((CURRENT_HINTS							 \
	   & HINT_LOCALIZE_HH)						  \
	    ? Perl_feature_is_enabled(aTHX_ STR_WITH_LEN(name)) : FALSE)

#define FEATURE_IS_ENABLED_MASK(mask)                   \
  ((CURRENT_HINTS & HINT_LOCALIZE_HH)                \
    ? (PL_curcop->cop_features & (mask)) : FALSE)

/* The longest string we pass in.  */
#define MAX_FEATURE_LEN (sizeof("postderef_qq")-1)

#define FEATURE_FC_IS_ENABLED \
    ( \
	(CURRENT_FEATURE_BUNDLE >= FEATURE_BUNDLE_515 && \
	 CURRENT_FEATURE_BUNDLE <= FEATURE_BUNDLE_527) \
     || (CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_FC_BIT)) \
    )

#define FEATURE_SAY_IS_ENABLED \
    ( \
	(CURRENT_FEATURE_BUNDLE >= FEATURE_BUNDLE_510 && \
	 CURRENT_FEATURE_BUNDLE <= FEATURE_BUNDLE_527) \
     || (CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_SAY_BIT)) \
    )

#define FEATURE_STATE_IS_ENABLED \
    ( \
	(CURRENT_FEATURE_BUNDLE >= FEATURE_BUNDLE_510 && \
	 CURRENT_FEATURE_BUNDLE <= FEATURE_BUNDLE_527) \
     || (CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_STATE_BIT)) \
    )

#define FEATURE_SWITCH_IS_ENABLED \
    ( \
	(CURRENT_FEATURE_BUNDLE >= FEATURE_BUNDLE_510 && \
	 CURRENT_FEATURE_BUNDLE <= FEATURE_BUNDLE_527) \
     || (CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_SWITCH_BIT)) \
    )

#define FEATURE_BITWISE_IS_ENABLED \
    ( \
	CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_527 \
     || (CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_BITWISE_BIT)) \
    )

#define FEATURE_EVALBYTES_IS_ENABLED \
    ( \
	(CURRENT_FEATURE_BUNDLE >= FEATURE_BUNDLE_515 && \
	 CURRENT_FEATURE_BUNDLE <= FEATURE_BUNDLE_527) \
     || (CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_EVALBYTES_BIT)) \
    )

#define FEATURE_SIGNATURES_IS_ENABLED \
    ( \
	CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_SIGNATURES_BIT) \
    )

#define FEATURE___SUB___IS_ENABLED \
    ( \
	(CURRENT_FEATURE_BUNDLE >= FEATURE_BUNDLE_515 && \
	 CURRENT_FEATURE_BUNDLE <= FEATURE_BUNDLE_527) \
     || (CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE___SUB___BIT)) \
    )

#define FEATURE_REFALIASING_IS_ENABLED \
    ( \
	CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_REFALIASING_BIT) \
    )

#define FEATURE_POSTDEREF_QQ_IS_ENABLED \
    ( \
	(CURRENT_FEATURE_BUNDLE >= FEATURE_BUNDLE_523 && \
	 CURRENT_FEATURE_BUNDLE <= FEATURE_BUNDLE_527) \
     || (CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_POSTDEREF_QQ_BIT)) \
    )

#define FEATURE_UNIEVAL_IS_ENABLED \
    ( \
	(CURRENT_FEATURE_BUNDLE >= FEATURE_BUNDLE_515 && \
	 CURRENT_FEATURE_BUNDLE <= FEATURE_BUNDLE_527) \
     || (CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_UNIEVAL_BIT)) \
    )

#define FEATURE_MYREF_IS_ENABLED \
    ( \
	CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_MYREF_BIT) \
    )

#define FEATURE_UNICODE_IS_ENABLED \
    ( \
	(CURRENT_FEATURE_BUNDLE >= FEATURE_BUNDLE_511 && \
	 CURRENT_FEATURE_BUNDLE <= FEATURE_BUNDLE_527) \
     || (CURRENT_FEATURE_BUNDLE == FEATURE_BUNDLE_CUSTOM && \
	 FEATURE_IS_ENABLED_MASK(FEATURE_UNICODE_BIT)) \
    )


#define SAVEFEATUREBITS() SAVEI32(PL_compiling.cop_features)

#define CLEARFEATUREBITS() (PL_compiling.cop_features = 0)

#define STOREFEATUREBITSHH(hh) \
  (hv_stores((hh), "feature/bits", newSVuv(PL_compiling.cop_features)))

#define FETCHFEATUREBITSHH(hh)                              \
  STMT_START {                                              \
      SV **fbsv = hv_fetchs((hh), "feature/bits", FALSE);   \
      PL_compiling.cop_features = fbsv ? SvUV(*fbsv) : 0;   \
  } STMT_END

#endif /* PERL_CORE or PERL_EXT */

#ifdef PERL_IN_OP_C
PERL_STATIC_INLINE void
S_enable_feature_bundle(pTHX_ SV *ver)
{
    SV *comp_ver = sv_newmortal();
    PL_hints = (PL_hints &~ HINT_FEATURE_MASK)
	     | (
		  (sv_setnv(comp_ver, 5.027),
		   vcmp(ver, upg_version(comp_ver, FALSE)) >= 0)
			? FEATURE_BUNDLE_527 :
		  (sv_setnv(comp_ver, 5.023),
		   vcmp(ver, upg_version(comp_ver, FALSE)) >= 0)
			? FEATURE_BUNDLE_523 :
		  (sv_setnv(comp_ver, 5.015),
		   vcmp(ver, upg_version(comp_ver, FALSE)) >= 0)
			? FEATURE_BUNDLE_515 :
		  (sv_setnv(comp_ver, 5.011),
		   vcmp(ver, upg_version(comp_ver, FALSE)) >= 0)
			? FEATURE_BUNDLE_511 :
		  (sv_setnv(comp_ver, 5.009005),
		   vcmp(ver, upg_version(comp_ver, FALSE)) >= 0)
			? FEATURE_BUNDLE_510 :
			  FEATURE_BUNDLE_DEFAULT
	       ) << HINT_FEATURE_SHIFT;
    /* special case */
    assert(PL_curcop == &PL_compiling);
    if (FEATURE_UNICODE_IS_ENABLED) PL_hints |=  HINT_UNI_8_BIT;
    else			    PL_hints &= ~HINT_UNI_8_BIT;
}
#endif /* PERL_IN_OP_C */

#endif /* PERL_FEATURE_H_ */

/* ex: set ro: */
