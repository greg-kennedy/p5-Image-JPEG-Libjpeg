#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

// enable retrieval of libjpeg build options
#define JPEG_INTERNAL_OPTIONS

#include <jpeglib.h>
#include <jerror.h>

typedef struct jpeg_decompress_struct * Image__JPEG__Libjpeg__Decompress;

#ifndef InputStream
#define InputStream PerlIO *
#endif

MODULE = Image::JPEG::Libjpeg  PACKAGE = Image::JPEG::Libjpeg  PREFIX = jpeg_
PROTOTYPES: DISABLE

 # make some underlying constants available
void
get_config(...)
PPCODE:
	EXTEND( SP, 38 );
	PUSHs( sv_2mortal( newSVpv("JPEG_LIB_VERSION", 16) ));
	PUSHs( sv_2mortal( newSVuv( JPEG_LIB_VERSION ) ));
	PUSHs( sv_2mortal( newSVpv("DCTSIZE", 7) ));
	PUSHs( sv_2mortal( newSVuv( DCTSIZE ) ));
	PUSHs( sv_2mortal( newSVpv("DCTSIZE2", 8) ));
	PUSHs( sv_2mortal( newSVuv( DCTSIZE2 ) ));
	PUSHs( sv_2mortal( newSVpv("NUM_QUANT_TBLS", 14) ));
	PUSHs( sv_2mortal( newSVuv( NUM_QUANT_TBLS ) ));
	PUSHs( sv_2mortal( newSVpv("NUM_HUFF_TBLS", 13) ));
	PUSHs( sv_2mortal( newSVuv( NUM_HUFF_TBLS ) ));
	PUSHs( sv_2mortal( newSVpv("NUM_ARITH_TBLS", 14) ));
	PUSHs( sv_2mortal( newSVuv( NUM_ARITH_TBLS ) ));
	PUSHs( sv_2mortal( newSVpv("MAX_COMPS_IN_SCAN", 17) ));
	PUSHs( sv_2mortal( newSVuv( MAX_COMPS_IN_SCAN ) ));
	PUSHs( sv_2mortal( newSVpv("MAX_SAMP_FACTOR", 15) ));
	PUSHs( sv_2mortal( newSVuv( MAX_SAMP_FACTOR ) ));
	PUSHs( sv_2mortal( newSVpv("C_MAX_BLOCKS_IN_MCU", 19) ));
	PUSHs( sv_2mortal( newSVuv( C_MAX_BLOCKS_IN_MCU ) ));
	PUSHs( sv_2mortal( newSVpv("D_MAX_BLOCKS_IN_MCU", 19) ));
	PUSHs( sv_2mortal( newSVuv( D_MAX_BLOCKS_IN_MCU ) ));
	PUSHs( sv_2mortal( newSVpv("JDCT_DEFAULT", 12) ));
	PUSHs( sv_2mortal( newSVuv( JDCT_DEFAULT ) ));
	PUSHs( sv_2mortal( newSVpv("JDCT_FASTEST", 12) ));
	PUSHs( sv_2mortal( newSVuv( JDCT_FASTEST ) ));
	PUSHs( sv_2mortal( newSVpv("JMSG_LENGTH_MAX", 15) ));
	PUSHs( sv_2mortal( newSVuv( JMSG_LENGTH_MAX ) ));
	PUSHs( sv_2mortal( newSVpv("JMSG_STR_PARM_MAX", 17) ));
	PUSHs( sv_2mortal( newSVuv( JMSG_STR_PARM_MAX ) ));
	PUSHs( sv_2mortal( newSVpv("BITS_IN_JSAMPLE", 15) ));
	PUSHs( sv_2mortal( newSVuv( BITS_IN_JSAMPLE ) ));
	PUSHs( sv_2mortal( newSVpv("MAX_COMPONENTS", 14) ));
	PUSHs( sv_2mortal( newSVuv( MAX_COMPONENTS ) ));
	PUSHs( sv_2mortal( newSVpv("MAXJSAMPLE", 10) ));
	PUSHs( sv_2mortal( newSVuv( MAXJSAMPLE ) ));
	PUSHs( sv_2mortal( newSVpv("CENTERJSAMPLE", 13) ));
	PUSHs( sv_2mortal( newSVuv( CENTERJSAMPLE ) ));
	PUSHs( sv_2mortal( newSVpv("JPEG_MAX_DIMENSION", 18) ));
	PUSHs( sv_2mortal( newSVuv( JPEG_MAX_DIMENSION ) ));
#ifdef JPEG_LIB_VERSION_MAJOR
	// added libjpeg8c
	XPUSHs( sv_2mortal( newSVpv("JPEG_LIB_VERSION_MAJOR", 22) ));
	XPUSHs( sv_2mortal( newSVuv( JPEG_LIB_VERSION_MAJOR ) ));
#endif
#ifdef JPEG_LIB_VERSION_MINOR
	// added libjpeg8c
	XPUSHs( sv_2mortal( newSVpv("JPEG_LIB_VERSION_MINOR", 22) ));
	XPUSHs( sv_2mortal( newSVuv( JPEG_LIB_VERSION_MINOR ) ));
#endif
#ifdef DCT_ISLOW_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("DCT_ISLOW_SUPPORTED", 19) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef DCT_IFAST_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("DCT_IFAST_SUPPORTED", 19) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef DCT_FLOAT_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("DCT_FLOAT_SUPPORTED", 19) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef C_ARITH_CODING_SUPPORTED
	// enabled libjpeg7
        XPUSHs( sv_2mortal( newSVpv("C_ARITH_CODING_SUPPORTED", 24) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef C_MULTISCAN_FILES_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("C_MULTISCAN_FILES_SUPPORTED", 27) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef C_PROGRESSIVE_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("C_PROGRESSIVE_SUPPORTED", 23) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef DCT_SCALING_SUPPORTED
	// added libjpeg7
        XPUSHs( sv_2mortal( newSVpv("DCT_SCALING_SUPPORTED", 21) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef ENTROPY_OPT_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("ENTROPY_OPT_SUPPORTED", 21) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef INPUT_SMOOTHING_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("INPUT_SMOOTHING_SUPPORTED", 25) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef D_ARITH_CODING_SUPPORTED
	// enabled libjpeg7
        XPUSHs( sv_2mortal( newSVpv("D_ARITH_CODING_SUPPORTED", 24) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef D_MULTISCAN_FILES_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("D_MULTISCAN_FILES_SUPPORTED", 27) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef D_PROGRESSIVE_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("D_PROGRESSIVE_SUPPORTED", 23) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef IDCT_SCALING_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("IDCT_SCALING_SUPPORTED", 22) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef SAVE_MARKERS_SUPPORTED
	// added libjpeg6b
        XPUSHs( sv_2mortal( newSVpv("SAVE_MARKERS_SUPPORTED", 22) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef BLOCK_SMOOTHING_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("BLOCK_SMOOTHING_SUPPORTED", 25) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef UPSAMPLE_MERGING_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("UPSAMPLE_MERGING_SUPPORTED", 26) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef QUANT_1PASS_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("QUANT_1PASS_SUPPORTED", 21) ));
        XPUSHs( &PL_sv_yes );
#endif
#ifdef QUANT_2PASS_SUPPORTED
        XPUSHs( sv_2mortal( newSVpv("QUANT_2PASS_SUPPORTED", 21) ));
        XPUSHs( &PL_sv_yes );
#endif

 # Error handling setup should go here

 # Other "common-to-both" functions can go here too

int
jpeg_quality_scaling(int quality)

# client_data field in common ptrs not added until 6.2

MODULE = Image::JPEG::Libjpeg  PACKAGE = Image::JPEG::Libjpeg::Decompress  PREFIX = jpeg_
PROTOTYPES: DISABLE

 # ###########################################################################
 # DECOMPRESSION FUNCTIONS AND OBJECT
 # Decompress struct accessors

 # ###########################################################################
 # Common fields
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
	AV * jsamprow;
	int actual_number_of_colors, out_color_components;
	int i, j;
PPCODE:
	if(cinfo->colormap == NULL)
		XSRETURN_UNDEF;
	out_color_components = cinfo->out_color_components;
	actual_number_of_colors = cinfo->actual_number_of_colors;
	EXTEND(SP, out_color_components);
	for (i = 0; i < out_color_components; i++) {
		jsamprow = newAV();
		av_extend(jsamprow, actual_number_of_colors - 1);
		for (j = 0; j < actual_number_of_colors; j++)
			av_push(jsamprow, newSViv(cinfo->colormap[i][j]));
		PUSHs( newRV_noinc(sv_2mortal((SV*)jsamprow) ) );
	}

void
set_colormap(Image::JPEG::Libjpeg::Decompress cinfo, AV * colormap)
PREINIT:
	AV * jsamprow;
	SV ** elem;
	int actual_number_of_colors, num_components;
	int i, j;
CODE:
	num_components = av_len(colormap) + 1;
	//cinfo->num_components = num_components;
	New(0, cinfo->colormap, num_components, JSAMPROW);
	for (i = 0; i<num_components; i++) {
		elem = av_fetch(colormap, i, 0);
		if (elem == NULL)
			croak("param is not set (is null)");
		if (! SvROK(*elem))
			croak("param is not a reference");
		if (SvTYPE( SvRV( *elem ) ) != SVt_PVAV )
			croak("param is not an array reference");
		jsamprow = (AV *)SvRV(*elem);
		actual_number_of_colors = av_len(jsamprow) + 1;
		cinfo->actual_number_of_colors = actual_number_of_colors;
		New(0, cinfo->colormap[i], actual_number_of_colors, JSAMPLE);
		for (j = 0; j < actual_number_of_colors; j ++) {
			elem = av_fetch(jsamprow, j, 0);
			if (elem == NULL) {
				cinfo->colormap[i][j] = 0;
			} else {
				cinfo->colormap[i][j] = SvIV(*elem);
			}
		}
	}

 # ###########################################################################
 # In use during jpeg_read_scanlines
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

void
get_coef_bits(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	AV * coef_bits;
	int i, j;
CODE:
	if(cinfo->coef_bits == NULL)
		XSRETURN_UNDEF;
	EXTEND(SP, cinfo->out_color_components);
	for (i = 0; i < cinfo->out_color_components; i++) {
		coef_bits = newAV();
		av_extend(coef_bits, DCTSIZE2 - 1);
		for (j = 0; j < DCTSIZE2; j++)
			av_push(coef_bits, newSViv(cinfo->coef_bits[i][j]));
		PUSHs( newRV_noinc(sv_2mortal((SV*)coef_bits) ) );
	}

int
get_data_precision(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->data_precision;
OUTPUT:	RETVAL

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
		PUSHs( newSVuv(cinfo->arith_dc_L[i] ) );

void
get_arith_dc_U(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_ARITH_TBLS);
	for (i = 0; i < NUM_ARITH_TBLS; i++)
		PUSHs( newSVuv(cinfo->arith_dc_U[i] ) );

void
get_arith_ac_K(Image::JPEG::Libjpeg::Decompress cinfo)
PREINIT:
	int i;
PPCODE:
	EXTEND(SP, NUM_ARITH_TBLS);
	for (i = 0; i < NUM_ARITH_TBLS; i++)
		PUSHs( newSVuv(cinfo->arith_ac_K[i] ) );

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

 # ###########################################################################
 # DECOMPRESSOR-SPECIFIC FIELDS
 # ###########################################################################

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

int
get_comps_in_scan(Image::JPEG::Libjpeg::Decompress cinfo)
CODE:
	RETVAL = cinfo->comps_in_scan;
OUTPUT:	RETVAL

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

 # DECOMPRESSION FUNCTIONS AND OBJECT
Image::JPEG::Libjpeg::Decompress
new (char* class)
PREINIT:
	struct jpeg_error_mgr * jerr;
CODE:
	New(0, jerr, 1, struct jpeg_error_mgr);
	New(0, RETVAL, 1, struct jpeg_decompress_struct);
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
	jpeg_stdio_src (cinfo, PerlIO_findFILE(infile));

int
jpeg_read_header (Image::JPEG::Libjpeg::Decompress cinfo, bool require_image = false)

bool
jpeg_start_decompress (Image::JPEG::Libjpeg::Decompress cinfo)

void
jpeg_read_scanlines (Image::JPEG::Libjpeg::Decompress cinfo, JDIMENSION max_lines)
PREINIT:
	int row_stride;
	JSAMPARRAY scanlines;
	JDIMENSION i, j, read_lines;
	AV * row;
PPCODE:
	New(0, scanlines, max_lines, JSAMPROW);
	row_stride = cinfo->output_width * cinfo->output_components;
	for (i=0; i<max_lines; i++)
		New(0, scanlines[i], row_stride, JSAMPLE);
	//
	read_lines = jpeg_read_scanlines(cinfo, scanlines, max_lines);
	//
	EXTEND(SP, read_lines);
	for (i=0; i<read_lines; i++)
	{
		//row = (AV*)sv_2mortal((SV*)newAV());
		row = newAV();
		av_extend(row, row_stride - 1);
		for (j=0; j<row_stride; j++)
		{
			av_push(row, newSViv(scanlines[i][j]));
		}
		PUSHs( newRV_noinc(sv_2mortal((SV*)row) ) );
		Safefree(scanlines[i]);
	}
	for (i=read_lines; i<max_lines; i++)
	{
		Safefree(scanlines[i]);
	}
	Safefree(scanlines);

bool
jpeg_finish_decompress (Image::JPEG::Libjpeg::Decompress cinfo)

void
jpeg_read_raw_data (Image::JPEG::Libjpeg::Decompress cinfo, JDIMENSION max_lines)
PREINIT:
	JSAMPIMAGE data;
	JDIMENSION i, j, k, read_lines;
	unsigned int w, h;
	AV * image;
	AV * row;
PPCODE:
	New(0, data, cinfo->output_components, JSAMPARRAY);
	for (i=0; i<cinfo->output_components; i++)
	{
		fprintf(stderr, "component %d\n", i);
		h = cinfo->comp_info[i].v_samp_factor * DCTSIZE;
		New(0, data[i], h, JSAMPROW);
		for (j=0; j<h; j++)
		{
			fprintf(stderr, " . row %d\n", j);
			w = cinfo->output_width / (cinfo->comp_info[i].h_samp_factor * DCTSIZE) + 1;
			New(0, data[i][j], w, JSAMPLE);
			fprintf(stderr, " . . width %d\n", j);
		}
	}
	//
	read_lines = jpeg_read_raw_data(cinfo, data, max_lines);
	//
	EXTEND(SP, cinfo->output_components);
	for (i=0; i<cinfo->output_components; i++)
	{
		image = newAV();
		av_extend(image, cinfo->comp_info[i].v_samp_factor * DCTSIZE - 1);
		for (j=0; j< cinfo->comp_info[i].v_samp_factor * DCTSIZE; j++)
		{
			row = newAV();
			av_extend(row,  cinfo->comp_info[i].h_samp_factor * DCTSIZE - 1);
			for (k=0; k< cinfo->comp_info[i].h_samp_factor * DCTSIZE; k ++)
			{
				av_push(row, newSViv(data[i][j][k]));
			}
			av_push(image, newRV_inc(sv_2mortal((SV*)row)));
			Safefree(data[i][j]);
		}
		PUSHs( newRV_noinc(sv_2mortal((SV*)image) ) );
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
jpeg_save_markers (Image::JPEG::Libjpeg::Decompress cinfo, int marker_code, unsigned int length_limit)

#endif

bool
jpeg_resync_to_restart (Image::JPEG::Libjpeg::Decompress cinfo, int desired)

void
jpeg_abort_decompress (Image::JPEG::Libjpeg::Decompress cinfo)
