#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

/* enable retrieval of libjpeg build options */
#define JPEG_INTERNAL_OPTIONS

#include <jpeglib.h>
#include <jerror.h>

/* Default error-management setup */
/*
struct jpeg_error_mgr * jpeg_std_error
	(struct jpeg_error_mgr * err);
*/

typedef struct jpeg_compress_struct * Image__JPEG__Libjpeg__Compress;
typedef struct jpeg_decompress_struct * Image__JPEG__Libjpeg__Decompress;

#ifndef OutputStream
#define OutputStream PerlIO *
#endif

#ifndef InputStream
#define InputStream PerlIO *
#endif

/* HELPER FUNCTIONS */
/* Several of the methods for Compress and Decompress struct share common
    getter / setter code.  These methods help reduce copy-paste where possible. */

/* Convert a JQUANT_TBL struct to a Perl hash */
static HV * get_JQUANT_TBL(pTHX_ JQUANT_TBL * jquant_tbl)
{
	HV * hv;
	AV * av;
	int i;

	hv = newHV();
	hv_store(hv, "sent_table", 10, jquant_tbl->sent_table ? &PL_sv_yes : &PL_sv_no, 0 );

	av = newAV();
	av_extend(av, DCTSIZE2 - 1);
	for (i = 0; i < DCTSIZE2; i++)
		av_push(av, newSVuv(jquant_tbl->quantval[i]));
	hv_store(hv, "quantval", 8, newRV_noinc((SV*)av), 0);

	return hv;
}

static HV * get_JHUFF_TBL(pTHX_ JHUFF_TBL * jhuff_tbl)
{
	HV * hv;
	AV * av;
	int i;

	hv = newHV();
	hv_store(hv, "sent_table", 10, jhuff_tbl->sent_table ? &PL_sv_yes : &PL_sv_no, 0);

	av = newAV();
	av_extend(av, 15);
	for (i = 1; i < 17; i++)
		av_push(av, newSVuv(jhuff_tbl->bits[i]));
	hv_store(hv, "bits", 4, newRV_noinc( (SV*) av ), 0);

	av = newAV();
	av_extend(av, 255);
	for (i = 0; i < 256; i++)
		av_push(av, newSVuv(jhuff_tbl->huffval[i]));
	hv_store(hv, "huffval", 7, newRV_noinc( (SV*) av ), 0);

	return hv;
}

/* Convert a jpeg_component_info struct to a Perl hash */
static HV * get_jpeg_component_info(pTHX_ jpeg_component_info * comp_info)
{
	HV * hv;
	int i;

	hv = newHV();
	hv_store(hv, "component_id", 12, newSViv(comp_info->component_id), 0);
	hv_store(hv, "component_index", 15, newSViv(comp_info->component_index), 0);
	hv_store(hv, "h_samp_factor", 13, newSViv(comp_info->h_samp_factor), 0);
	hv_store(hv, "v_samp_factor", 13, newSViv(comp_info->v_samp_factor), 0);
	hv_store(hv, "quant_tbl_no", 12, newSViv(comp_info->quant_tbl_no), 0);
	hv_store(hv, "dc_tbl_no", 9, newSViv(comp_info->dc_tbl_no), 0);
	hv_store(hv, "ac_tbl_no", 9, newSViv(comp_info->ac_tbl_no), 0);
	hv_store(hv, "width_in_blocks", 15, newSVuv(comp_info->ac_tbl_no), 0);
	hv_store(hv, "height_in_blocks", 16, newSVuv(comp_info->ac_tbl_no), 0);

	hv_store(hv, "DCT_h_scaled_size", 17, newSViv(comp_info->DCT_h_scaled_size), 0);
	hv_store(hv, "DCT_v_scaled_size", 17, newSViv(comp_info->DCT_v_scaled_size), 0);

	hv_store(hv, "downsampled_width", 17, newSVuv(comp_info->ac_tbl_no), 0);
	hv_store(hv, "downsampled_height", 18, newSVuv(comp_info->ac_tbl_no), 0);

	hv_store(hv, "component_needed", 16, comp_info->component_needed ? &PL_sv_yes : &PL_sv_no, 0);

	hv_store(hv, "MCU_width", 9, newSViv(comp_info->MCU_width), 0);
	hv_store(hv, "MCU_height", 10, newSViv(comp_info->MCU_height), 0);
	hv_store(hv, "MCU_blocks", 10, newSViv(comp_info->MCU_blocks), 0);
	hv_store(hv, "MCU_sample_width", 16, newSViv(comp_info->MCU_sample_width), 0);
	hv_store(hv, "last_col_width", 14, newSViv(comp_info->last_col_width), 0);
	hv_store(hv, "last_row_height", 15, newSViv(comp_info->last_row_height), 0);

	if ( comp_info->quant_table != NULL)
		hv_store(hv, "quant_table", 11, newRV_noinc( (SV*) get_JQUANT_TBL(aTHX_ comp_info->quant_table ) ), 0);

	/* void * dct_table; */

	return hv;
}

/* BEGIN XS CODE */
MODULE = Image::JPEG::Libjpeg  PACKAGE = Image::JPEG::Libjpeg  PREFIX = jpeg_
PROTOTYPES: DISABLE

 # make some underlying constants available
void
get_config(...)
PPCODE:
	EXTEND( SP, 38 );
#define pushdef(x) PUSHs( sv_2mortal( newSVpv( #x, strlen( #x )) )); PUSHs( sv_2mortal( newSViv( x ) ));
	pushdef( JPEG_LIB_VERSION );
	pushdef( DCTSIZE );
	pushdef( DCTSIZE2 );
	pushdef( NUM_QUANT_TBLS );
	pushdef( NUM_HUFF_TBLS );
	pushdef( NUM_ARITH_TBLS );
	pushdef( MAX_COMPS_IN_SCAN );
	pushdef( MAX_SAMP_FACTOR );
	pushdef( C_MAX_BLOCKS_IN_MCU );
	pushdef( D_MAX_BLOCKS_IN_MCU );
	pushdef( JDCT_DEFAULT );
	pushdef( JDCT_FASTEST );
	pushdef( JMSG_LENGTH_MAX );
	pushdef( JMSG_STR_PARM_MAX );
	pushdef( BITS_IN_JSAMPLE );
	pushdef( MAX_COMPONENTS );
	pushdef( MAXJSAMPLE );
	pushdef( CENTERJSAMPLE );
	pushdef( JPEG_MAX_DIMENSION );
#define xpushdef(x) XPUSHs( sv_2mortal( newSVpv( #x, strlen( #x )) )); XPUSHs( sv_2mortal( newSViv( x ) ));
#ifdef JPEG_LIB_VERSION_MAJOR
	/* added libjpeg8c */
	xpushdef( JPEG_LIB_VERSION_MAJOR );
#endif
#ifdef JPEG_LIB_VERSION_MINOR
	/* added libjpeg8c */
	xpushdef( JPEG_LIB_VERSION_MINOR );
#endif
#define xpushflag(x) XPUSHs( sv_2mortal( newSVpv( #x, strlen( #x )) )); XPUSHs( &PL_sv_yes );
#ifdef DCT_ISLOW_SUPPORTED
        xpushflag( DCT_ISLOW_SUPPORTED );
#endif
#ifdef DCT_IFAST_SUPPORTED
        xpushflag( DCT_IFAST_SUPPORTED );
#endif
#ifdef DCT_FLOAT_SUPPORTED
        xpushflag( DCT_FLOAT_SUPPORTED );
#endif
#ifdef C_ARITH_CODING_SUPPORTED
	/* enabled libjpeg7 */
        xpushflag( C_ARITH_CODING_SUPPORTED );
#endif
#ifdef C_MULTISCAN_FILES_SUPPORTED
        xpushflag( C_MULTISCAN_FILES_SUPPORTED );
#endif
#ifdef C_PROGRESSIVE_SUPPORTED
        xpushflag( C_PROGRESSIVE_SUPPORTED );
#endif
#ifdef DCT_SCALING_SUPPORTED
	/* added libjpeg7 */
        xpushflag( DCT_SCALING_SUPPORTED );
#endif
#ifdef ENTROPY_OPT_SUPPORTED
        xpushflag( ENTROPY_OPT_SUPPORTED );
#endif
#ifdef INPUT_SMOOTHING_SUPPORTED
        xpushflag( INPUT_SMOOTHING_SUPPORTED );
#endif
#ifdef D_ARITH_CODING_SUPPORTED
	/* enabled libjpeg7 */
        xpushflag( D_ARITH_CODING_SUPPORTED );
#endif
#ifdef D_MULTISCAN_FILES_SUPPORTED
        xpushflag( D_MULTISCAN_FILES_SUPPORTED );
#endif
#ifdef D_PROGRESSIVE_SUPPORTED
        xpushflag( D_PROGRESSIVE_SUPPORTED );
#endif
#ifdef IDCT_SCALING_SUPPORTED
        xpushflag( IDCT_SCALING_SUPPORTED );
#endif
#ifdef SAVE_MARKERS_SUPPORTED
	/* added libjpeg6b */
        xpushflag( SAVE_MARKERS_SUPPORTED );
#endif
#ifdef BLOCK_SMOOTHING_SUPPORTED
        xpushflag( BLOCK_SMOOTHING_SUPPORTED );
#endif
#ifdef UPSAMPLE_MERGING_SUPPORTED
        xpushflag( UPSAMPLE_MERGING_SUPPORTED );
#endif
#ifdef QUANT_1PASS_SUPPORTED
        xpushflag( QUANT_1PASS_SUPPORTED );
#endif
#ifdef QUANT_2PASS_SUPPORTED
        xpushflag( QUANT_2PASS_SUPPORTED );
#endif

 # Error handling setup should go here

 # Other "common-to-both" functions can go here too

int
jpeg_quality_scaling(int quality)

 # these aren't really useful: there are compress / decompress-specific routines
 # void jpeg_abort (j_common_ptr cinfo);
 # void jpeg_destroy (j_common_ptr cinfo);

 # client_data field in common ptrs not added until 6.2

 # ###########################################################################
 # COMPRESSION STRUCTURE AND FUNCTIONS
 # ###########################################################################

MODULE = Image::JPEG::Libjpeg  PACKAGE = Image::JPEG::Libjpeg::Compress  PREFIX = jpeg_
PROTOTYPES: DISABLE

 # ###########################################################################
 # Compress struct accessors

 # ###########################################################################
 # Common fields

 # struct jpeg_error_mgr * err;
 # struct jpeg_memory_mgr * mem;
 # struct jpeg_progress_mgr * progress;
 # void * client_data; /* not added until 6b */

bool
get_is_decompressor (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->is_decompressor;
OUTPUT:	RETVAL

int
get_global_state (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->global_state;
OUTPUT:	RETVAL

 # ###########################################################################
 # Compression parameters - set before starting compression
JDIMENSION
get_image_width (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->image_width;
OUTPUT:	RETVAL

void
set_image_width (Image::JPEG::Libjpeg::Compress cinfo, JDIMENSION image_width)
CODE:
	cinfo->image_width = image_width;

JDIMENSION
get_image_height (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->image_height;
OUTPUT:	RETVAL

void
set_image_height (Image::JPEG::Libjpeg::Compress cinfo, JDIMENSION image_height)
CODE:
	cinfo->image_height = image_height;

int
get_input_components (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->input_components;
OUTPUT:	RETVAL

void
set_input_components (Image::JPEG::Libjpeg::Compress cinfo, int input_components)
CODE:
	cinfo->input_components = input_components;

J_COLOR_SPACE
get_in_color_space (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->in_color_space;
OUTPUT:	RETVAL

void
set_in_color_space (Image::JPEG::Libjpeg::Compress cinfo, J_COLOR_SPACE in_color_space)
CODE:
	cinfo->in_color_space = in_color_space;

double
get_input_gamma (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->input_gamma;
OUTPUT:	RETVAL

void
set_input_gamma (Image::JPEG::Libjpeg::Compress cinfo, double input_gamma)
CODE:
	cinfo->input_gamma = input_gamma;

#if JPEG_LIB_VERSION >= 70
unsigned int
get_scale_num (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->scale_num;
OUTPUT:	RETVAL

void
set_scale_num (Image::JPEG::Libjpeg::Compress cinfo, unsigned int scale_num)
CODE:
	cinfo->scale_num = scale_num;

unsigned int
get_scale_denom (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->scale_denom;
OUTPUT:	RETVAL

void
set_scale_denom (Image::JPEG::Libjpeg::Compress cinfo, unsigned int scale_denom)
CODE:
	cinfo->scale_denom = scale_denom;

 # computed by jpeg_calc_jpeg_dimensions or jpeg_start_compress
JDIMENSION
get_jpeg_width (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->jpeg_width;
OUTPUT:	RETVAL

JDIMENSION
get_jpeg_height (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->jpeg_height;
OUTPUT:	RETVAL

#endif

int
get_data_precision (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->data_precision;
OUTPUT:	RETVAL

void
set_data_precision (Image::JPEG::Libjpeg::Compress cinfo, int data_precision)
CODE:
	cinfo->data_precision = data_precision;

int
get_num_components (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->num_components;
OUTPUT:	RETVAL

void
set_num_components (Image::JPEG::Libjpeg::Compress cinfo, int num_components)
CODE:
	cinfo->num_components = num_components;

J_COLOR_SPACE
get_jpeg_color_space (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->jpeg_color_space;
OUTPUT:	RETVAL

void
set_jpeg_color_space (Image::JPEG::Libjpeg::Compress cinfo, J_COLOR_SPACE jpeg_color_space)
CODE:
	cinfo->jpeg_color_space = jpeg_color_space;

# TODO: TEST THIS
void
get_comp_info (Image::JPEG::Libjpeg::Compress cinfo)
PREINIT:
	int i;
PPCODE:
	if(cinfo->comp_info == NULL)
		XSRETURN_UNDEF;
	EXTEND(SP, cinfo->num_components);
	for (i = 0; i < cinfo->num_components; i++)
		PUSHs( sv_2mortal( (SV *) get_jpeg_component_info( aTHX_ &cinfo->comp_info[i] ) ));

=pod
# THIS IS BROKEN
void
set_comp_info (Image::JPEG::Libjpeg::Compress cinfo, AV * comp_info)
PREINIT:
	SV ** elem;
	int num_components;
	int i, j;
PPCODE:
	num_components = av_len(comp_info) + 1;
	/* cinfo->num_components = num_components; */
	Newx(cinfo->comp_info, num_components, JSAMPROW);
	for (i = 0; i<num_components; i++) {
		elem = av_fetch(colormap, i, 0);
		if (elem == NULL || ! SvOK(*elem) || ! SvPOK(*elem))
			croak("param is not set (is null)");
		cinfo->colormap[i] = (JSAMPROW)SvPV_nolen(*elem);
	}

=cut

void
get_quant_tbls(Image::JPEG::Libjpeg::Compress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_QUANT_TBLS);
	for (i = 0; i < NUM_QUANT_TBLS; i++)
		if ( cinfo->quant_tbl_ptrs[i] == NULL)
			PUSHs(&PL_sv_undef);
		else
			PUSHs( sv_2mortal( newRV_noinc( (SV *) get_JQUANT_TBL(aTHX_ cinfo->quant_tbl_ptrs[i]) ) ) );

=pod
void
set_quant_tbl_ptrs[NUM_QUANT_TBLS] (Image::JPEG::Libjpeg::Compress cinfo, JQUANT_TBL * quant_tbl_ptrs[NUM_QUANT_TBLS])
CODE:
	cinfo->quant_tbl_ptrs[NUM_QUANT_TBLS] = quant_tbl_ptrs[NUM_QUANT_TBLS];

=cut

#if JPEG_LIB_VERSION >= 70
void
get_q_scale_factor (Image::JPEG::Libjpeg::Compress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_QUANT_TBLS);
	for (i = 0; i < NUM_QUANT_TBLS; i++)
		PUSHs( sv_2mortal( newSViv( cinfo->q_scale_factor[i] ) ) );

void
set_q_scale_factor (Image::JPEG::Libjpeg::Compress cinfo, AV * q_scale_factor)
PREINIT:
	SV ** elem;
	int i;
PPCODE:
	for (i = 0; i<NUM_QUANT_TBLS; i++) {
		elem = av_fetch(q_scale_factor, i, 0);
		if (elem == NULL || ! SvOK(*elem) || ! SvIOK(*elem))
			croak("param is not set (is null)");
		cinfo->q_scale_factor[i] = SvIV(*elem);
	}

#endif

# TODO: TEST THIS
void
get_dc_huff_tbls(Image::JPEG::Libjpeg::Compress cinfo)
PREINIT:
	AV * av;
	HV * jhuff_tbl;
	int i, j;
PPCODE:
	EXTEND(SP, NUM_HUFF_TBLS);
	for (i = 0; i < NUM_HUFF_TBLS; i++)
		if ( cinfo->dc_huff_tbl_ptrs[i] == NULL)
			PUSHs(&PL_sv_undef);
		else
			PUSHs( sv_2mortal( newRV_noinc( (SV *) get_JHUFF_TBL(aTHX_ cinfo->dc_huff_tbl_ptrs[i]) ) ) );

=pod
void
set_dc_huff_tbl_ptrs[NUM_HUFF_TBLS] (Image::JPEG::Libjpeg::Compress cinfo, JHUFF_TBL * dc_huff_tbl_ptrs[NUM_HUFF_TBLS])
CODE:
	cinfo->dc_huff_tbl_ptrs[NUM_HUFF_TBLS] = dc_huff_tbl_ptrs[NUM_HUFF_TBLS];

=cut

# TODO: TEST THIS
void
get_ac_huff_tbls(Image::JPEG::Libjpeg::Compress cinfo)
PREINIT:
	AV * av;
	HV * jhuff_tbl;
	int i, j;
PPCODE:
	EXTEND(SP, NUM_HUFF_TBLS);
	for (i = 0; i < NUM_HUFF_TBLS; i++)
		if ( cinfo->ac_huff_tbl_ptrs[i] == NULL)
			PUSHs(&PL_sv_undef);
		else
			PUSHs( sv_2mortal( newRV_noinc( (SV *) get_JHUFF_TBL(aTHX_ cinfo->ac_huff_tbl_ptrs[i]) ) ) );

=pod
void
set_ac_huff_tbls (Image::JPEG::Libjpeg::Compress cinfo, AV * ac_huff_tbls)
PREINIT:
	int i, j;
	SV ** elem;
	AV * av;
	HV * jhuff_tbl;
PPCODE:
	for (i = 0; i < NUM_HUFF_TBLS; i ++) {
		elem = av_fetch(ac_huff_tbls, i, 0);
		if (elem == NULL || ! SvOK(*elem) || ! SvROK(*elem))
			croak("param is not set (is null)");
		jhuff_tbl = SvRV(*elem);
		/* */
		elem = hv_fetch(jhuff_tbl, "sent_table", 10, 0);
		if (elem == NULL || ! SvOK(*elem) || ! SvIOK(*elem))
			croak("sent_table is not set (is null)");
		cinfo->ac_huff_tbl_ptrs[i]->sent_table = SvRV(*elem);
		/* */
		elem = hv_fetch(jhuff_tbl, "bits", 4, 0);
		if (elem == NULL || ! SvOK(*elem) || ! SvROK(*elem))
			croak("bits is not set (is null)");
		av = SvRV(*elem);
		for (j = 0; j < 16; j ++) {
			elem = av_fetch(av, i, 0);
			if (elem == NULL || ! SvOK(*elem) || ! SvIOK(*elem))
				croak("bits[j] is not set (is null)");
			cinfo->ac_huff_tbl_ptrs[i]->bits[j+1] = SvRV(*elem);
		}
		/* */
		elem = hv_fetch(jhuff_tbl, "huffval", 7, 0);
		if (elem == NULL || ! SvOK(*elem) || ! SvROK(*elem))
			croak("huffval is not set (is null)");
		av = SvRV(*elem);
		for (j = 0; j < 256; j ++) {
			elem = av_fetch(av, i, 0);
			if (elem == NULL || ! SvOK(*elem) || ! SvIOK(*elem))
				croak("huffval[j] is not set (is null)");
			cinfo->ac_huff_tbl_ptrs[i]->huffval[j] = SvRV(*elem);
		}
	}
=cut

void
get_arith_dc_L(Image::JPEG::Libjpeg::Compress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_ARITH_TBLS);
	for (i = 0; i < NUM_ARITH_TBLS; i++)
		PUSHs( sv_2mortal( newSVuv(cinfo->arith_dc_L[i]) ) );

=pod
void
set_arith_dc_L[NUM_ARITH_TBLS] (Image::JPEG::Libjpeg::Compress cinfo, UINT8 arith_dc_L[NUM_ARITH_TBLS])
CODE:
	cinfo->arith_dc_L[NUM_ARITH_TBLS] = arith_dc_L[NUM_ARITH_TBLS];

=cut

void
get_arith_dc_U(Image::JPEG::Libjpeg::Compress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_ARITH_TBLS);
	for (i = 0; i < NUM_ARITH_TBLS; i++)
		PUSHs( sv_2mortal( newSVuv(cinfo->arith_dc_U[i]) ) );

=pod
void
set_arith_dc_U[NUM_ARITH_TBLS] (Image::JPEG::Libjpeg::Compress cinfo, UINT8 arith_dc_U[NUM_ARITH_TBLS])
CODE:
	cinfo->arith_dc_U[NUM_ARITH_TBLS] = arith_dc_U[NUM_ARITH_TBLS];

=cut

void
get_arith_ac_K(Image::JPEG::Libjpeg::Compress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_ARITH_TBLS);
	for (i = 0; i < NUM_ARITH_TBLS; i++)
		PUSHs( sv_2mortal( newSVuv(cinfo->arith_ac_K[i]) ) );

=pod
void
set_arith_ac_K[NUM_ARITH_TBLS] (Image::JPEG::Libjpeg::Compress cinfo, UINT8 arith_ac_K[NUM_ARITH_TBLS])
CODE:
	cinfo->arith_ac_K[NUM_ARITH_TBLS] = arith_ac_K[NUM_ARITH_TBLS];

=cut

int
get_num_scans (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->num_scans;
OUTPUT:	RETVAL

void
set_num_scans (Image::JPEG::Libjpeg::Compress cinfo, int num_scans)
CODE:
	cinfo->num_scans = num_scans;

=pod
const jpeg_scan_info *
get_scan_info (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->scan_info;
OUTPUT:	RETVAL

void
set_scan_info (Image::JPEG::Libjpeg::Compress cinfo, const jpeg_scan_info * scan_info)
CODE:
	cinfo->scan_info = scan_info;
=cut

bool
get_raw_data_in (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->raw_data_in;
OUTPUT:	RETVAL

void
set_raw_data_in (Image::JPEG::Libjpeg::Compress cinfo, bool raw_data_in)
CODE:
	cinfo->raw_data_in = raw_data_in;

bool
get_arith_code (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->arith_code;
OUTPUT:	RETVAL

void
set_arith_code (Image::JPEG::Libjpeg::Compress cinfo, bool arith_code)
CODE:
	cinfo->arith_code = arith_code;

bool
get_optimize_coding (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->optimize_coding;
OUTPUT:	RETVAL

void
set_optimize_coding (Image::JPEG::Libjpeg::Compress cinfo, bool optimize_coding)
CODE:
	cinfo->optimize_coding = optimize_coding;

bool
get_CCIR601_sampling (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->CCIR601_sampling;
OUTPUT:	RETVAL

void
set_CCIR601_sampling (Image::JPEG::Libjpeg::Compress cinfo, bool CCIR601_sampling)
CODE:
	cinfo->CCIR601_sampling = CCIR601_sampling;

#if JPEG_LIB_VERSION >= 70
bool
get_do_fancy_downsampling (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->do_fancy_downsampling;
OUTPUT:	RETVAL

void
set_do_fancy_downsampling (Image::JPEG::Libjpeg::Compress cinfo, bool do_fancy_downsampling)
CODE:
	cinfo->do_fancy_downsampling = do_fancy_downsampling;

#endif

int
get_smoothing_factor (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->smoothing_factor;
OUTPUT:	RETVAL

void
set_smoothing_factor (Image::JPEG::Libjpeg::Compress cinfo, int smoothing_factor)
CODE:
	cinfo->smoothing_factor = smoothing_factor;

J_DCT_METHOD
get_dct_method (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->dct_method;
OUTPUT:	RETVAL

void
set_dct_method (Image::JPEG::Libjpeg::Compress cinfo, J_DCT_METHOD dct_method)
CODE:
	cinfo->dct_method = dct_method;

unsigned int
get_restart_interval (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->restart_interval;
OUTPUT:	RETVAL

void
set_restart_interval (Image::JPEG::Libjpeg::Compress cinfo, unsigned int restart_interval)
CODE:
	cinfo->restart_interval = restart_interval;

int
get_restart_in_rows (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->restart_in_rows;
OUTPUT:	RETVAL

void
set_restart_in_rows (Image::JPEG::Libjpeg::Compress cinfo, int restart_in_rows)
CODE:
	cinfo->restart_in_rows = restart_in_rows;

 # Parameters controlling emission of special markers.

bool
get_write_JFIF_header (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->write_JFIF_header;
OUTPUT:	RETVAL

void
set_write_JFIF_header (Image::JPEG::Libjpeg::Compress cinfo, bool write_JFIF_header)
CODE:
	cinfo->write_JFIF_header = write_JFIF_header;

#if JPEG_LIB_VERSION >= 62
UINT8
get_JFIF_major_version (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->JFIF_major_version;
OUTPUT:	RETVAL

void
set_JFIF_major_version (Image::JPEG::Libjpeg::Compress cinfo, UINT8 JFIF_major_version)
CODE:
	cinfo->JFIF_major_version = JFIF_major_version;

UINT8
get_JFIF_minor_version (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->JFIF_minor_version;
OUTPUT:	RETVAL

void
set_JFIF_minor_version (Image::JPEG::Libjpeg::Compress cinfo, UINT8 JFIF_minor_version)
CODE:
	cinfo->JFIF_minor_version = JFIF_minor_version;

#endif

UINT8
get_density_unit (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->density_unit;
OUTPUT:	RETVAL

void
set_density_unit (Image::JPEG::Libjpeg::Compress cinfo, UINT8 density_unit)
CODE:
	cinfo->density_unit = density_unit;

UINT16
get_X_density (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->X_density;
OUTPUT:	RETVAL

void
set_X_density (Image::JPEG::Libjpeg::Compress cinfo, UINT16 X_density)
CODE:
	cinfo->X_density = X_density;

UINT16
get_Y_density (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->Y_density;
OUTPUT:	RETVAL

void
set_Y_density (Image::JPEG::Libjpeg::Compress cinfo, UINT16 Y_density)
CODE:
	cinfo->Y_density = Y_density;

bool
get_write_Adobe_marker (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->write_Adobe_marker;
OUTPUT:	RETVAL

void
set_write_Adobe_marker (Image::JPEG::Libjpeg::Compress cinfo, bool write_Adobe_marker)
CODE:
	cinfo->write_Adobe_marker = write_Adobe_marker;

#if JPEG_LIB_VERSION >= 90
J_COLOR_TRANSFORM
get_color_transform (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->color_transform;
OUTPUT:	RETVAL

void
set_color_transform (Image::JPEG::Libjpeg::Compress cinfo, J_COLOR_TRANSFORM color_transform)
CODE:
	cinfo->color_transform = color_transform;

#endif

JDIMENSION
get_next_scanline (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->next_scanline;
OUTPUT:	RETVAL

void
set_next_scanline (Image::JPEG::Libjpeg::Compress cinfo, JDIMENSION next_scanline)
CODE:
	cinfo->next_scanline = next_scanline;

 # do not touch

bool
get_progressive_mode (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->progressive_mode;
OUTPUT:	RETVAL

int
get_max_h_samp_factor (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->max_h_samp_factor;
OUTPUT:	RETVAL

int
get_max_v_samp_factor (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->max_v_samp_factor;
OUTPUT:	RETVAL

JDIMENSION
get_total_iMCU_rows (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->total_iMCU_rows;
OUTPUT:	RETVAL

 # Scan-specific params

int
get_comps_in_scan (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->comps_in_scan;
OUTPUT:	RETVAL

void
set_comps_in_scan (Image::JPEG::Libjpeg::Compress cinfo, int comps_in_scan)
CODE:
	cinfo->comps_in_scan = comps_in_scan;

=pod
jpeg_component_info *
get_cur_comp_info[MAX_COMPS_IN_SCAN] (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->cur_comp_info[MAX_COMPS_IN_SCAN];
OUTPUT:	RETVAL

void
set_cur_comp_info[MAX_COMPS_IN_SCAN] (Image::JPEG::Libjpeg::Compress cinfo, jpeg_component_info * cur_comp_info[MAX_COMPS_IN_SCAN])
CODE:
	cinfo->cur_comp_info[MAX_COMPS_IN_SCAN] = cur_comp_info[MAX_COMPS_IN_SCAN];
=cut

JDIMENSION
get_MCUs_per_row (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->MCUs_per_row;
OUTPUT:	RETVAL

void
set_MCUs_per_row (Image::JPEG::Libjpeg::Compress cinfo, JDIMENSION MCUs_per_row)
CODE:
	cinfo->MCUs_per_row = MCUs_per_row;

JDIMENSION
get_MCU_rows_in_scan (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->MCU_rows_in_scan;
OUTPUT:	RETVAL

void
set_MCU_rows_in_scan (Image::JPEG::Libjpeg::Compress cinfo, JDIMENSION MCU_rows_in_scan)
CODE:
	cinfo->MCU_rows_in_scan = MCU_rows_in_scan;

int
get_blocks_in_MCU (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->blocks_in_MCU;
OUTPUT:	RETVAL

void
set_blocks_in_MCU (Image::JPEG::Libjpeg::Compress cinfo, int blocks_in_MCU)
CODE:
	cinfo->blocks_in_MCU = blocks_in_MCU;

=pod
int
get_MCU_membership[C_MAX_BLOCKS_IN_MCU] (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->MCU_membership[C_MAX_BLOCKS_IN_MCU];
OUTPUT:	RETVAL

void
set_MCU_membership[C_MAX_BLOCKS_IN_MCU] (Image::JPEG::Libjpeg::Compress cinfo, int MCU_membership[C_MAX_BLOCKS_IN_MCU])
CODE:
	cinfo->MCU_membership[C_MAX_BLOCKS_IN_MCU] = MCU_membership[C_MAX_BLOCKS_IN_MCU];
=cut

int
get_Ss (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->Ss;
OUTPUT:	RETVAL

void
set_Ss (Image::JPEG::Libjpeg::Compress cinfo, int Ss)
CODE:
	cinfo->Ss = Ss;

int
get_Se (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->Se;
OUTPUT:	RETVAL

void
set_Se (Image::JPEG::Libjpeg::Compress cinfo, int Se)
CODE:
	cinfo->Se = Se;

int
get_Ah (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->Ah;
OUTPUT:	RETVAL

void
set_Ah (Image::JPEG::Libjpeg::Compress cinfo, int Ah)
CODE:
	cinfo->Ah = Ah;

int
get_Al (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->Al;
OUTPUT:	RETVAL

void
set_Al (Image::JPEG::Libjpeg::Compress cinfo, int Al)
CODE:
	cinfo->Al = Al;

#if JPEG_LIB_VERSION >= 80
int
get_block_size (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->block_size;
OUTPUT:	RETVAL

void
set_block_size (Image::JPEG::Libjpeg::Compress cinfo, int block_size)
CODE:
	cinfo->block_size = block_size;

void
get_natural_order(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, cinfo->lim_Se);
	for (i = 0; i < cinfo->lim_Se; i ++)
		PUSHs( sv_2mortal( newSViv(cinfo->natural_order[i]) ));

=pod
void
set_natural_order (Image::JPEG::Libjpeg::Compress cinfo, const int * natural_order)
CODE:
	cinfo->natural_order = natural_order;
=cut

int
get_lim_Se (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	RETVAL = cinfo->lim_Se;
OUTPUT:	RETVAL

void
set_lim_Se (Image::JPEG::Libjpeg::Compress cinfo, int lim_Se)
CODE:
	cinfo->lim_Se = lim_Se;

#endif

 # ###########################################################################
 # Compress functions

Image::JPEG::Libjpeg::Compress
new (char * class)
PREINIT:
	struct jpeg_error_mgr * jerr;
CODE:
	Newx(jerr, 1, struct jpeg_error_mgr);
	Newx(RETVAL, 1, struct jpeg_compress_struct);
	RETVAL->err = jpeg_std_error(jerr);
	jpeg_create_compress(RETVAL);
OUTPUT: RETVAL

void
DESTROY (Image::JPEG::Libjpeg::Compress cinfo)
CODE:
	Safefree(cinfo->err);
	jpeg_destroy_compress(cinfo);
	Safefree(cinfo);

void
jpeg_stdio_dest (Image::JPEG::Libjpeg::Compress cinfo, OutputStream outfile)
INIT:
	if (! outfile) croak("Error: outfile is NULL");
CODE:
	jpeg_stdio_dest (cinfo, PerlIO_findFILE(outfile));

=pod
#if JPEG_LIB_VERSION >= 80
void
jpeg_mem_dest(Image::JPEG::Libjpeg::Compress cinfo, unsigned char ** outbuffer, unsigned long * outsize)
PREINIT:
	unsigned long size;
	unsigned char * buffer;

#endif
=cut

void
jpeg_set_defaults (Image::JPEG::Libjpeg::Compress cinfo)

void
jpeg_set_colorspace (Image::JPEG::Libjpeg::Compress cinfo, J_COLOR_SPACE colorspace)

void
jpeg_default_colorspace (Image::JPEG::Libjpeg::Compress cinfo)

void
jpeg_set_quality (Image::JPEG::Libjpeg::Compress cinfo, int quality = 75, bool force_baseline = 1)

void
jpeg_set_linear_quality (Image::JPEG::Libjpeg::Compress cinfo, int scale_factor = 50, bool force_baseline = 1)

#if JPEG_LIB_VERSION >= 70
void
jpeg_default_qtables (Image::JPEG::Libjpeg::Compress cinfo, bool force_baseline = 1)

#endif

=pod
void
jpeg_add_quant_table (cinfo, which_tbl, basic_table, scale_factor, force_baseline)
	Image::JPEG::Libjpeg::Compress cinfo
	int which_tbl
	unsigned long * basic_table
	int scale_factor
	bool force_baseline
=cut

void
jpeg_simple_progression (Image::JPEG::Libjpeg::Compress cinfo)

void
jpeg_suppress_tables (Image::JPEG::Libjpeg::Compress cinfo, bool suppress = 1)

#JQUANT_TBL * jpeg_alloc_quant_table (j_common_ptr cinfo);
#JHUFF_TBL * jpeg_alloc_huff_table (j_common_ptr cinfo);
# 9.4+
#EXTERN(JHUFF_TBL *) jpeg_std_huff_table JPP((j_common_ptr cinfo,
#						boolean isDC, int tblno));
#

void
jpeg_start_compress (Image::JPEG::Libjpeg::Compress cinfo, bool write_all_tables = 1)

JDIMENSION
jpeg_write_scanlines (Image::JPEG::Libjpeg::Compress cinfo, ...)
PREINIT:
	int i;
	JSAMPARRAY scanlines;
CODE:
	Newx(scanlines, items - 1, JSAMPROW);
	for (i=1; i<items; i++)
	{
		scanlines[i-1] = (JSAMPROW)SvPV_nolen(ST(i));
	}
	//
	RETVAL = jpeg_write_scanlines(cinfo, scanlines, items - 1);
	Safefree(scanlines);
OUTPUT:	RETVAL

void
jpeg_finish_compress (Image::JPEG::Libjpeg::Compress cinfo)

#if JPEG_LIB_VERSION >= 70
void
jpeg_calc_jpeg_dimensions(Image::JPEG::Libjpeg::Compress cinfo)

#endif

=pod
JDIMENSION
jpeg_write_raw_data (Image::JPEG::Libjpeg::Compress cinfo, ...)
PREINIT:
	int i;
	AV * comp;
	JSAMPIMAGE data;
CODE:
	Newx(data, items - 1, JSAMPROW);
	for (i=1; i<items; i++)
	{
		if (SvOK(ST(i)) && SvROK(ST(i)) && SvTYPE(SvRV(ST(i))))
		{
			comp = (AV *)SvRV(ST(i));
			Newx(data[i], av_top_index(comp));
			scanlines[i-1] = (JSAMPROW)SvPV_nolen(ST(i));
		}
	}
	//
	RETVAL = jpeg_write_scanlines(cinfo, data, num_lines);
	Safefree(scanlines);
OUTPUT:	RETVAL
=cut

void
jpeg_write_marker (Image::JPEG::Libjpeg::Compress cinfo, int marker, unsigned char * dataptr, unsigned int length(dataptr))

#if JPEG_LIB_VERSION >= 62
void
jpeg_write_m_header (Image::JPEG::Libjpeg::Compress cinfo, int marker, unsigned int datalen)

void
jpeg_write_m_byte (Image::JPEG::Libjpeg::Compress cinfo, int val)

#endif

void
jpeg_write_tables (Image::JPEG::Libjpeg::Compress cinfo)

=pod
void
jpeg_write_coefficients (cinfo, coef_arrays)
	Image::JPEG::Libjpeg::Compress cinfo
	jvirt_barray_ptr * coef_arrays
=cut

void
jpeg_abort_compress (Image::JPEG::Libjpeg::Compress cinfo)

 # ###########################################################################
 # DECOMPRESSION STRUCTURE AND FUNCTIONS
 # ###########################################################################

MODULE = Image::JPEG::Libjpeg  PACKAGE = Image::JPEG::Libjpeg::Decompress  PREFIX = jpeg_
PROTOTYPES: DISABLE

 # ###########################################################################
 # Decompress struct accessors

 # ###########################################################################
 # Common fields

 # struct jpeg_error_mgr * err;
 # struct jpeg_memory_mgr * mem;
 # struct jpeg_progress_mgr * progress;
 # void * client_data; /* not added until 6b */

bool
get_is_decompressor(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->is_decompressor;
OUTPUT:	RETVAL

int
get_global_state(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->global_state;
OUTPUT:	RETVAL

 # struct jpeg_source_mgr * src;

 # ###########################################################################
 # Produced by jpeg_read_header()
JDIMENSION
get_image_width(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->image_width;
OUTPUT:	RETVAL

JDIMENSION
get_image_height(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->image_height;
OUTPUT:	RETVAL

int
get_num_components(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->num_components;
OUTPUT:	RETVAL

J_COLOR_SPACE
get_jpeg_color_space(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->jpeg_color_space;
OUTPUT:	RETVAL

 # ###########################################################################
 # Read/write decompression params
J_COLOR_SPACE
get_out_color_space(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->out_color_space;
OUTPUT:	RETVAL

void
set_out_color_space(Image::JPEG::Libjpeg::Decompress cinfo, J_COLOR_SPACE out_color_space)
CODE:
	cinfo->out_color_space = out_color_space;

unsigned int
get_scale_num(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->scale_num;
OUTPUT:	RETVAL

void
set_scale_num(Image::JPEG::Libjpeg::Decompress cinfo, unsigned int scale_num)
CODE:
	cinfo->scale_num = scale_num;

unsigned int
get_scale_denom(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->scale_denom;
OUTPUT:	RETVAL

void
set_scale_denom(Image::JPEG::Libjpeg::Decompress cinfo, unsigned int scale_denom)
CODE:
	cinfo->scale_denom = scale_denom;

double
get_output_gamma(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->output_gamma;
OUTPUT:	RETVAL

void
set_output_gamma(Image::JPEG::Libjpeg::Decompress cinfo, double output_gamma)
CODE:
	cinfo->output_gamma = output_gamma;

bool
get_buffered_image(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->buffered_image;
OUTPUT:	RETVAL

void
set_buffered_image(Image::JPEG::Libjpeg::Decompress cinfo, bool buffered_image)
CODE:
	cinfo->buffered_image = buffered_image;

bool
get_raw_data_out(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->raw_data_out;
OUTPUT:	RETVAL

void
set_raw_data_out(Image::JPEG::Libjpeg::Decompress cinfo, bool raw_data_out)
CODE:
	cinfo->raw_data_out = raw_data_out;

J_DCT_METHOD
get_dct_method(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->dct_method;
OUTPUT:	RETVAL

void
set_dct_method(Image::JPEG::Libjpeg::Decompress cinfo, J_DCT_METHOD dct_method)
CODE:
	cinfo->dct_method = dct_method;

bool
get_do_fancy_upsampling(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->do_fancy_upsampling;
OUTPUT:	RETVAL

void
set_do_fancy_upsampling(Image::JPEG::Libjpeg::Decompress cinfo, bool do_fancy_upsampling)
CODE:
	cinfo->do_fancy_upsampling = do_fancy_upsampling;

bool
get_do_block_smoothing(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->do_block_smoothing;
OUTPUT:	RETVAL

void
set_do_block_smoothing(Image::JPEG::Libjpeg::Decompress cinfo, bool do_block_smoothing)
CODE:
	cinfo->do_block_smoothing = do_block_smoothing;

bool
get_quantize_colors(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->quantize_colors;
OUTPUT:	RETVAL

void
set_quantize_colors(Image::JPEG::Libjpeg::Decompress cinfo, bool quantize_colors)
CODE:
	cinfo->quantize_colors = quantize_colors;

 # the following are ignored if not quantize_colors:
J_DITHER_MODE
get_dither_mode(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->dither_mode;
OUTPUT:	RETVAL

void
set_dither_mode(Image::JPEG::Libjpeg::Decompress cinfo, J_DITHER_MODE dither_mode)
CODE:
	cinfo->dither_mode = dither_mode;

bool
get_two_pass_quantize(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->two_pass_quantize;
OUTPUT:	RETVAL

void
set_two_pass_quantize(Image::JPEG::Libjpeg::Decompress cinfo, bool two_pass_quantize)
CODE:
	cinfo->two_pass_quantize = two_pass_quantize;

int
get_desired_number_of_colors(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->desired_number_of_colors;
OUTPUT:	RETVAL

void
set_desired_number_of_colors(Image::JPEG::Libjpeg::Decompress cinfo, int desired_number_of_colors)
CODE:
	cinfo->desired_number_of_colors = desired_number_of_colors;

 # these are significant only in buffered-image mode:
bool
get_enable_1pass_quant(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->enable_1pass_quant;
OUTPUT:	RETVAL

void
set_enable_1pass_quant(Image::JPEG::Libjpeg::Decompress cinfo, bool enable_1pass_quant)
CODE:
	cinfo->enable_1pass_quant = enable_1pass_quant;

bool
get_enable_external_quant(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->enable_external_quant;
OUTPUT:	RETVAL

void
set_enable_external_quant(Image::JPEG::Libjpeg::Decompress cinfo, bool enable_external_quant)
CODE:
	cinfo->enable_external_quant = enable_external_quant;

bool
get_enable_2pass_quant(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->enable_2pass_quant;
OUTPUT:	RETVAL

void
set_enable_2pass_quant(Image::JPEG::Libjpeg::Decompress cinfo, bool enable_2pass_quant)
CODE:
	cinfo->enable_2pass_quant = enable_2pass_quant;

 # ###########################################################################
 # Produced by jpeg_calc_output_dimensions()
JDIMENSION
get_output_width(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->output_width;
OUTPUT:	RETVAL

JDIMENSION
get_output_height(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->output_height;
OUTPUT:	RETVAL

int
get_out_color_components(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->out_color_components;
OUTPUT:	RETVAL

int
get_output_components(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->output_components;
OUTPUT:	RETVAL

int
get_rec_outbuf_height(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->rec_outbuf_height;
OUTPUT:	RETVAL

 # ###########################################################################
 # Read/write decompression params (cont)
int
get_actual_number_of_colors(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->actual_number_of_colors;
OUTPUT:	RETVAL

void
set_actual_number_of_colors(Image::JPEG::Libjpeg::Decompress cinfo, int actual_number_of_colors)
CODE:
	cinfo->actual_number_of_colors = actual_number_of_colors;

void
get_colormap(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
PPCODE:
	if(cinfo->colormap == NULL)
		XSRETURN_UNDEF;
	EXTEND(SP, cinfo->out_color_components);
	for (i = 0; i < cinfo->out_color_components; i++)
		PUSHs( sv_2mortal(newSVpv((char *)cinfo->colormap[i], cinfo->actual_number_of_colors * sizeof(JSAMPLE))) );

void
set_colormap(Image::JPEG::Libjpeg::Decompress cinfo, AV * colormap)
PREINIT:
	SV ** elem;
	int num_components;
	int i, j;
CODE:
	num_components = av_len(colormap) + 1;
	if (num_components != 3)
		croak("libjpeg requires exactly 3 colormap components");
	/* cinfo->num_components = num_components; */
	Newx(cinfo->colormap, num_components, JSAMPROW);
	for (i = 0; i<num_components; i++) {
		elem = av_fetch(colormap, i, 0);
		if (elem == NULL || ! SvOK(*elem) || ! SvPOK(*elem))
			croak("param is not set (is null)");
		cinfo->colormap[i] = (JSAMPROW)SvPV_nolen(*elem);
	}

 # ###########################################################################
 # State Variables - In use during jpeg_read_scanlines
JDIMENSION
get_output_scanline(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->output_scanline;
OUTPUT:	RETVAL

int
get_input_scan_number(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->input_scan_number;
OUTPUT:	RETVAL

JDIMENSION
get_input_iMCU_row(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->input_iMCU_row;
OUTPUT:	RETVAL

int
get_output_scan_number(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->output_scan_number;
OUTPUT:	RETVAL

JDIMENSION
get_output_iMCU_row(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->output_iMCU_row;
OUTPUT:	RETVAL

# TODO: TEST THIS
void
get_coef_bits(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	AV * coef_bits;
	int i, j;
PPCODE:
	if(cinfo->coef_bits == NULL)
		XSRETURN_UNDEF;
	EXTEND(SP, cinfo->out_color_components);
	for (i = 0; i < cinfo->out_color_components; i++) {
		coef_bits = newAV();
		av_extend(coef_bits, DCTSIZE2 - 1);
		for (j = 0; j < DCTSIZE2; j++)
			av_push(coef_bits, newSViv(cinfo->coef_bits[i][j]));
		PUSHs( sv_2mortal( newRV_noinc((SV*)coef_bits) ) );
	}

 # Internal JPEG parameters
void
get_quant_tbls(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_QUANT_TBLS);
	for (i = 0; i < NUM_QUANT_TBLS; i++)
		if ( cinfo->quant_tbl_ptrs[i] == NULL)
			PUSHs(&PL_sv_undef);
		else
			PUSHs( sv_2mortal( newRV_noinc( (SV *) get_JQUANT_TBL(aTHX_ cinfo->quant_tbl_ptrs[i]) ) ) );

# TODO: TEST THIS
void
get_dc_huff_tbls(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	AV * av;
	HV * jhuff_tbl;
	int i, j;
PPCODE:
	EXTEND(SP, NUM_HUFF_TBLS);
	for (i = 0; i < NUM_HUFF_TBLS; i++)
		if ( cinfo->dc_huff_tbl_ptrs[i] == NULL)
			PUSHs(&PL_sv_undef);
		else
			PUSHs( sv_2mortal( newRV_noinc( (SV *) get_JHUFF_TBL(aTHX_ cinfo->dc_huff_tbl_ptrs[i]) ) ) );

# TODO: TEST THIS
void
get_ac_huff_tbls(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	AV * av;
	HV * jhuff_tbl;
	int i, j;
PPCODE:
	EXTEND(SP, NUM_HUFF_TBLS);
	for (i = 0; i < NUM_HUFF_TBLS; i++)
		if ( cinfo->ac_huff_tbl_ptrs[i] == NULL)
			PUSHs(&PL_sv_undef);
		else
			PUSHs( sv_2mortal( newRV_noinc( (SV *) get_JHUFF_TBL(aTHX_ cinfo->ac_huff_tbl_ptrs[i]) ) ) );

int
get_data_precision(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->data_precision;
OUTPUT:	RETVAL

# TODO: TEST THIS
void
get_comp_info(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	AV * quantval;
	HV * comp_info, * quant_table;
	int i, j;
PPCODE:
	if(cinfo->comp_info == NULL)
		XSRETURN_UNDEF;
	EXTEND(SP, cinfo->num_components);
	for (i = 0; i < cinfo->num_components; i++)
		PUSHs( sv_2mortal( (SV*) get_jpeg_component_info( aTHX_ &cinfo->comp_info[i] ) ));

#if JPEG_LIB_VERSION >= 80
bool
get_is_baseline(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->is_baseline;
OUTPUT:	RETVAL

#endif

bool
get_progressive_mode(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->progressive_mode;
OUTPUT:	RETVAL

bool
get_arith_code(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->arith_code;
OUTPUT:	RETVAL

void
get_arith_dc_L(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_ARITH_TBLS);
	for (i = 0; i < NUM_ARITH_TBLS; i++)
		PUSHs( sv_2mortal( newSVuv(cinfo->arith_dc_L[i]) ) );

void
get_arith_dc_U(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_ARITH_TBLS);
	for (i = 0; i < NUM_ARITH_TBLS; i++)
		PUSHs( sv_2mortal( newSVuv(cinfo->arith_dc_U[i]) ) );

void
get_arith_ac_K(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_ARITH_TBLS);
	for (i = 0; i < NUM_ARITH_TBLS; i++)
		PUSHs( sv_2mortal( newSVuv(cinfo->arith_ac_K[i]) ) );

unsigned int
get_restart_interval(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->restart_interval;
OUTPUT:	RETVAL

 # ###########################################################################
 # Produced by jpeg_read_header()
bool
get_saw_JFIF_marker(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->saw_JFIF_marker;
OUTPUT:	RETVAL

#if JPEG_LIB_VERSION >= 62
UINT8
get_JFIF_major_version(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->JFIF_major_version;
OUTPUT:	RETVAL

#endif

#if JPEG_LIB_VERSION >= 62
UINT8
get_JFIF_minor_version(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->JFIF_minor_version;
OUTPUT:	RETVAL

#endif

UINT8
get_density_unit(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->density_unit;
OUTPUT:	RETVAL

UINT16
get_X_density(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->X_density;
OUTPUT:	RETVAL

UINT16
get_Y_density(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->Y_density;
OUTPUT:	RETVAL

bool
get_saw_Adobe_marker(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->saw_Adobe_marker;
OUTPUT:	RETVAL

UINT8
get_Adobe_transform(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->Adobe_transform;
OUTPUT:	RETVAL

 # ###########################################################################
 # Read/write decompression params (cont)

#if JPEG_LIB_VERSION >= 90
J_COLOR_TRANSFORM
get_color_transform(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->color_transform;
OUTPUT:	RETVAL

#endif

bool
get_CCIR601_sampling(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->CCIR601_sampling;
OUTPUT:	RETVAL

=pod
#if JPEG_LIB_VERSION >= 62
jpeg_saved_marker_ptr
get_marker_list(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->marker_list;
OUTPUT:	RETVAL

#endif
=cut

 # ###########################################################################
 # Computed during decompression startup
int
get_max_h_samp_factor(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->max_h_samp_factor;
OUTPUT:	RETVAL

int
get_max_v_samp_factor(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->max_v_samp_factor;
OUTPUT:	RETVAL

#if JPEG_LIB_VERSION <= 62
int
get_min_DCT_scaled_size(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->min_DCT_scaled_size;
OUTPUT:	RETVAL

#endif

#if JPEG_LIB_VERSION >= 70
int
get_min_DCT_h_scaled_size(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->min_DCT_h_scaled_size;
OUTPUT:	RETVAL

#endif

#if JPEG_LIB_VERSION >= 70
int
get_min_DCT_v_scaled_size(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->min_DCT_v_scaled_size;
OUTPUT:	RETVAL

#endif

JDIMENSION
get_total_iMCU_rows(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->total_iMCU_rows;
OUTPUT:	RETVAL

=pod
JSAMPLE *
get_sample_range_limit(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->sample_range_limit;
OUTPUT:	RETVAL
=cut

int
get_comps_in_scan(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->comps_in_scan;
OUTPUT:	RETVAL

=pod
jpeg_component_info *
get_cur_comp_info[MAX_COMPS_IN_SCAN](Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->cur_comp_info[MAX_COMPS_IN_SCAN];
OUTPUT:	RETVAL
=cut

JDIMENSION
get_MCUs_per_row(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->MCUs_per_row;
OUTPUT:	RETVAL

JDIMENSION
get_MCU_rows_in_scan(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->MCU_rows_in_scan;
OUTPUT:	RETVAL

int
get_blocks_in_MCU(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->blocks_in_MCU;
OUTPUT:	RETVAL

void
get_MCU_membership(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, D_MAX_BLOCKS_IN_MCU);
	for (i = 0; i < D_MAX_BLOCKS_IN_MCU; i ++)
		PUSHs( sv_2mortal( newSViv(cinfo->MCU_membership[i]) ));

int
get_Ss(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->Ss;
OUTPUT:	RETVAL

int
get_Se(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->Se;
OUTPUT:	RETVAL

int
get_Ah(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->Ah;
OUTPUT:	RETVAL

int
get_Al(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->Al;
OUTPUT:	RETVAL

#if JPEG_LIB_VERSION >= 80
int
get_block_size(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->block_size;
OUTPUT:	RETVAL

#endif

#if JPEG_LIB_VERSION >= 80
void
get_natural_order(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, cinfo->lim_Se);
	for (i = 0; i < cinfo->lim_Se; i ++)
		PUSHs( sv_2mortal( newSViv(cinfo->natural_order[i]) ));

#endif

#if JPEG_LIB_VERSION >= 80
int
get_lim_Se(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->lim_Se;
OUTPUT:	RETVAL

#endif

int
get_unread_marker(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->unread_marker;
OUTPUT:	RETVAL

 # ###########################################################################
 # Decompress functions

Image::JPEG::Libjpeg::Decompress
new (char * class)
PREINIT:
	struct jpeg_error_mgr * jerr;
CODE:
	Newx(jerr, 1, struct jpeg_error_mgr);
	Newx(RETVAL, 1, struct jpeg_decompress_struct);
	RETVAL->err = jpeg_std_error(jerr);
	jpeg_create_decompress(RETVAL);
OUTPUT:	RETVAL

void
DESTROY (Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	Safefree(cinfo->err);
	jpeg_destroy_decompress(cinfo);
	Safefree(cinfo);

void
jpeg_stdio_src (Image::JPEG::Libjpeg::Decompress cinfo, InputStream infile)
INIT:
	if (! infile) croak("Error: infile is NULL");
CODE:
	jpeg_stdio_src(cinfo, PerlIO_findFILE(infile));

#if JPEG_LIB_VERSION >= 80
void
jpeg_mem_src (Image::JPEG::Libjpeg::Decompress cinfo, unsigned char * in, int length(in))

#endif

int
jpeg_read_header (Image::JPEG::Libjpeg::Decompress cinfo, bool require_image = 1)

bool
jpeg_start_decompress (Image::JPEG::Libjpeg::Decompress cinfo)

void
jpeg_read_scanlines (Image::JPEG::Libjpeg::Decompress cinfo, JDIMENSION max_lines = 1)
PREINIT:
	int row_stride;
	JSAMPARRAY scanlines;
	JDIMENSION i, read_lines;
PPCODE:
	Newx(scanlines, max_lines, JSAMPROW);
	row_stride = cinfo->output_width * cinfo->output_components;
	for (i=0; i<max_lines; i++)
		Newx(scanlines[i], row_stride, JSAMPLE);
	/* */
	read_lines = jpeg_read_scanlines(cinfo, scanlines, max_lines);
	/* */
	EXTEND(SP, read_lines);
	for (i=0; i<max_lines; i++)
	{
		if (i < read_lines)
			PUSHs( sv_2mortal(newSVpv((char *)scanlines[i], row_stride * sizeof(JSAMPLE))) );
		Safefree(scanlines[i]);
	}
	Safefree(scanlines);

bool
jpeg_finish_decompress (Image::JPEG::Libjpeg::Decompress cinfo)

void
jpeg_read_raw_data (Image::JPEG::Libjpeg::Decompress cinfo, JDIMENSION max_lines = 1)
PREINIT:
	JSAMPIMAGE data;
	JDIMENSION i, j, k, read_lines;
	unsigned int w, h;
	AV * image;
	AV * row;
PPCODE:
	Newx(data, cinfo->output_components, JSAMPARRAY);
	for (i=0; i<cinfo->output_components; i++)
	{
		fprintf(stderr, "component %d\n", i);
		h = cinfo->comp_info[i].v_samp_factor * DCTSIZE;
		Newx(data[i], h, JSAMPROW);
		for (j=0; j<h; j++)
		{
			fprintf(stderr, " . row %d\n", j);
			w = cinfo->output_width / (cinfo->comp_info[i].h_samp_factor * DCTSIZE) + 1;
			Newx(data[i][j], w, JSAMPLE);
			fprintf(stderr, " . . width %d\n", j);
		}
	}
	/* */
	read_lines = jpeg_read_raw_data(cinfo, data, max_lines);
	/* */
	EXTEND(SP, cinfo->output_components);
	for (i=0; i<cinfo->output_components; i++)
	{
		image = newAV();
		av_extend(image, cinfo->comp_info[i].v_samp_factor * DCTSIZE - 1);
		for (j=0; j< cinfo->comp_info[i].v_samp_factor * DCTSIZE; j++)
		{
			av_push(image, sv_2mortal(newSVpv((char *)data[i][j], cinfo->comp_info[i].h_samp_factor * DCTSIZE * sizeof(JSAMPLE))) );
			Safefree(data[i][j]);
		}
		Safefree(data[i]);
	}
	Safefree(data);

bool
jpeg_has_multiple_scans (Image::JPEG::Libjpeg::Decompress cinfo)

bool
jpeg_start_output (Image::JPEG::Libjpeg::Decompress cinfo, int scan_number)

bool
jpeg_finish_output (Image::JPEG::Libjpeg::Decompress cinfo)

bool
jpeg_input_complete (Image::JPEG::Libjpeg::Decompress cinfo)

void
jpeg_new_colormap (Image::JPEG::Libjpeg::Decompress cinfo)

int
jpeg_consume_input (Image::JPEG::Libjpeg::Decompress cinfo)

#if JPEG_LIB_VERSION >= 80
void
jpeg_core_output_dimensions (Image::JPEG::Libjpeg::Decompress cinfo)

#endif

void
jpeg_calc_output_dimensions (Image::JPEG::Libjpeg::Decompress cinfo)

#if JPEG_LIB_VERSION >= 62
void
jpeg_save_markers (Image::JPEG::Libjpeg::Decompress cinfo, int marker_code, unsigned int length_limit = 0xFFFF)

#endif

=pod
void
jpeg_set_marker_processor (j_decompress_ptr cinfo, int marker_code, jpeg_marker_parser_method routine);

void
jpeg_read_coefficients (Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
	jvirt_barray_ptr * coefficients;
	AV * image;
	AV * row;
PPCODE:
	coefficients = jpeg_read_coefficients(cinfo);
	for (i=0; i < cinfo->num_components; i++) {
		av_extend(image, cinfo->comp_info[i].v_samp_factor * DCTSIZE - 1);
	}
=cut

void
jpeg_copy_critical_parameters (Image::JPEG::Libjpeg::Decompress srcinfo, Image::JPEG::Libjpeg::Compress dstinfo)

bool
jpeg_resync_to_restart (Image::JPEG::Libjpeg::Decompress cinfo, int desired)

void
jpeg_abort_decompress (Image::JPEG::Libjpeg::Decompress cinfo)
