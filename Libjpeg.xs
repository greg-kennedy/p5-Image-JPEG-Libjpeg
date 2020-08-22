#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <jpeglib.h>
#include <jerror.h>

typedef struct jpeg_decompress_struct * Image__JPEG__Libjpeg__Decompress;

#ifndef InputStream
#define InputStream PerlIO *
#endif

MODULE = Image::JPEG::Libjpeg  PACKAGE = Image::JPEG::Libjpeg  PREFIX = jpeg_
PROTOTYPES: DISABLE

 # Error handling setup should go here

 # Other "common-to-both" functions can go here too

int
jpeg_quality_scaling (quality)
	int quality

MODULE = Image::JPEG::Libjpeg  PACKAGE = Image::JPEG::Libjpeg::Decompress  PREFIX = jpeg_
PROTOTYPES: DISABLE

 # Decompress struct accessors

 # ###########################################################################
 # Common fields
bool
get_is_decompressor (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->is_decompressor;
OUTPUT:
	RETVAL

int
get_global_state (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->global_state;
OUTPUT:
	RETVAL

 # ###########################################################################
 # Produced by jpeg_read_header()
JDIMENSION
get_image_width (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->image_width;
OUTPUT:
	RETVAL

JDIMENSION
get_image_height (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->image_height;
OUTPUT:
	RETVAL

int
get_num_components (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->num_components;
OUTPUT:
	RETVAL

J_COLOR_SPACE
get_jpeg_color_space (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->jpeg_color_space;
OUTPUT:
	RETVAL

 # ###########################################################################
 # Read/write decompression params
J_COLOR_SPACE
get_out_color_space (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->out_color_space;
OUTPUT:
	RETVAL

void
set_out_color_space (cinfo, out_color_space)
	Image::JPEG::Libjpeg::Decompress cinfo
	J_COLOR_SPACE out_color_space
CODE:
	cinfo->out_color_space = out_color_space;

unsigned int
get_scale_num (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->scale_num;
OUTPUT:
	RETVAL

void
set_scale_num (cinfo, scale_num)
	Image::JPEG::Libjpeg::Decompress cinfo
	unsigned int scale_num
CODE:
	cinfo->scale_num = scale_num;

unsigned int
get_scale_denom (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->scale_denom;
OUTPUT:
	RETVAL

void
set_scale_denom (cinfo, scale_denom)
	Image::JPEG::Libjpeg::Decompress cinfo
	unsigned int scale_denom
CODE:
	cinfo->scale_denom = scale_denom;

double
get_output_gamma (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->output_gamma;
OUTPUT:
	RETVAL

void
set_output_gamma (cinfo, output_gamma)
	Image::JPEG::Libjpeg::Decompress cinfo
	double output_gamma
CODE:
	cinfo->output_gamma = output_gamma;

bool
get_buffered_image (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->buffered_image;
OUTPUT:
	RETVAL

void
set_buffered_image (cinfo, buffered_image)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool buffered_image
CODE:
	cinfo->buffered_image = buffered_image;

bool
get_raw_data_out (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->raw_data_out;
OUTPUT:
	RETVAL

void
set_raw_data_out (cinfo, raw_data_out)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool raw_data_out
CODE:
	cinfo->raw_data_out = raw_data_out;

J_DCT_METHOD
get_dct_method (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->dct_method;
OUTPUT:
	RETVAL

void
set_dct_method (cinfo, dct_method)
	Image::JPEG::Libjpeg::Decompress cinfo
	J_DCT_METHOD dct_method
CODE:
	cinfo->dct_method = dct_method;

bool
get_do_fancy_upsampling (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->do_fancy_upsampling;
OUTPUT:
	RETVAL

void
set_do_fancy_upsampling (cinfo, do_fancy_upsampling)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool do_fancy_upsampling
CODE:
	cinfo->do_fancy_upsampling = do_fancy_upsampling;

bool
get_do_block_smoothing (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->do_block_smoothing;
OUTPUT:
	RETVAL

void
set_do_block_smoothing (cinfo, do_block_smoothing)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool do_block_smoothing
CODE:
	cinfo->do_block_smoothing = do_block_smoothing;

bool
get_quantize_colors (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->quantize_colors;
OUTPUT:
	RETVAL

void
set_quantize_colors (cinfo, quantize_colors)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool quantize_colors
CODE:
	cinfo->quantize_colors = quantize_colors;

J_DITHER_MODE
get_dither_mode (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->dither_mode;
OUTPUT:
	RETVAL

void
set_dither_mode (cinfo, dither_mode)
	Image::JPEG::Libjpeg::Decompress cinfo
	J_DITHER_MODE dither_mode
CODE:
	cinfo->dither_mode = dither_mode;

bool
get_two_pass_quantize (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->two_pass_quantize;
OUTPUT:
	RETVAL

void
set_two_pass_quantize (cinfo, two_pass_quantize)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool two_pass_quantize
CODE:
	cinfo->two_pass_quantize = two_pass_quantize;

int
get_desired_number_of_colors (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->desired_number_of_colors;
OUTPUT:
	RETVAL

void
set_desired_number_of_colors (cinfo, desired_number_of_colors)
	Image::JPEG::Libjpeg::Decompress cinfo
	int desired_number_of_colors
CODE:
	cinfo->desired_number_of_colors = desired_number_of_colors;

bool
get_enable_1pass_quant (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->enable_1pass_quant;
OUTPUT:
	RETVAL

void
set_enable_1pass_quant (cinfo, enable_1pass_quant)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool enable_1pass_quant
CODE:
	cinfo->enable_1pass_quant = enable_1pass_quant;

bool
get_enable_external_quant (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->enable_external_quant;
OUTPUT:
	RETVAL

void
set_enable_external_quant (cinfo, enable_external_quant)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool enable_external_quant
CODE:
	cinfo->enable_external_quant = enable_external_quant;

bool
get_enable_2pass_quant (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->enable_2pass_quant;
OUTPUT:
	RETVAL

void
set_enable_2pass_quant (cinfo, enable_2pass_quant)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool enable_2pass_quant
CODE:
	cinfo->enable_2pass_quant = enable_2pass_quant;

 # ###########################################################################
 # Produced by jpeg_calc_output_dimensions()
JDIMENSION
get_output_width (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->output_width;
OUTPUT:
	RETVAL

JDIMENSION
get_output_height (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->output_height;
OUTPUT:
	RETVAL

int
get_out_color_components (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->out_color_components;
OUTPUT:
	RETVAL

int
get_output_components (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->output_components;
OUTPUT:
	RETVAL

int
get_rec_outbuf_height (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->rec_outbuf_height;
OUTPUT:
	RETVAL

 # ###########################################################################
 # Read/write decompression params (cont)
int
get_actual_number_of_colors (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->actual_number_of_colors;
OUTPUT:
	RETVAL

void
set_actual_number_of_colors (cinfo, actual_number_of_colors)
	Image::JPEG::Libjpeg::Decompress cinfo
	int actual_number_of_colors
CODE:
	cinfo->actual_number_of_colors = actual_number_of_colors;

 # ###########################################################################
 # In use during jpeg_read_scanlines
JDIMENSION
get_output_scanline (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->output_scanline;
OUTPUT:
	RETVAL

int
get_input_scan_number (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->input_scan_number;
OUTPUT:
	RETVAL

JDIMENSION
get_input_iMCU_row (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->input_iMCU_row;
OUTPUT:
	RETVAL

int
get_output_scan_number (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->output_scan_number;
OUTPUT:
	RETVAL

JDIMENSION
get_output_iMCU_row (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->output_iMCU_row;
OUTPUT:
	RETVAL

int
get_data_precision (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->data_precision;
OUTPUT:
	RETVAL

bool
get_progressive_mode (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->progressive_mode;
OUTPUT:
	RETVAL

bool
get_arith_code (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->arith_code;
OUTPUT:
	RETVAL

unsigned int
get_restart_interval (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->restart_interval;
OUTPUT:
	RETVAL

 # ###########################################################################
 # Produced by jpeg_read_header()
bool
get_saw_JFIF_marker (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->saw_JFIF_marker;
OUTPUT:
	RETVAL

UINT8
get_JFIF_major_version (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->JFIF_major_version;
OUTPUT:
	RETVAL

UINT8
get_JFIF_minor_version (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->JFIF_minor_version;
OUTPUT:
	RETVAL

UINT8
get_density_unit (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->density_unit;
OUTPUT:
	RETVAL

UINT16
get_X_density (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->X_density;
OUTPUT:
	RETVAL

UINT16
get_Y_density (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->Y_density;
OUTPUT:
	RETVAL

bool
get_saw_Adobe_marker (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->saw_Adobe_marker;
OUTPUT:
	RETVAL

UINT8
get_Adobe_transform (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->Adobe_transform;
OUTPUT:
	RETVAL

 # ###########################################################################
 # Read/write decompression params (cont)
bool
get_CCIR601_sampling (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	RETVAL = cinfo->CCIR601_sampling;
OUTPUT:
	RETVAL

void
set_CCIR601_sampling (cinfo, CCIR601_sampling)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool CCIR601_sampling
CODE:
	cinfo->CCIR601_sampling = CCIR601_sampling;

 # ###########################################################################
 # DECOMPRESSION FUNCTIONS AND OBJECT

Image::JPEG::Libjpeg::Decompress
new (class)
	char *class
PREINIT:
	struct jpeg_error_mgr * jerr;
CODE:
	New(0, jerr, 1, struct jpeg_error_mgr);
	New(0, RETVAL, 1, struct jpeg_decompress_struct);
	RETVAL->err = jpeg_std_error(jerr);
	jpeg_create_decompress(RETVAL);
OUTPUT:
	RETVAL

void
DESTROY (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
CODE:
	Safefree(cinfo->err);
	jpeg_destroy_decompress(cinfo);
	Safefree(cinfo);

void
jpeg_stdio_src (cinfo, infile)
	Image::JPEG::Libjpeg::Decompress cinfo
	InputStream infile
INIT:
	if (! infile)
		croak("Error: infile is NULL");
CODE:
	jpeg_stdio_src (cinfo, PerlIO_findFILE(infile));

int
jpeg_read_header (cinfo, require_image=false)
	Image::JPEG::Libjpeg::Decompress cinfo
	bool require_image

bool
jpeg_start_decompress (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo

void
jpeg_read_scanlines (cinfo, max_lines=JPEG_MAX_DIMENSION)
	Image::JPEG::Libjpeg::Decompress cinfo
	JDIMENSION max_lines
PREINIT:
	int row_stride;
	JSAMPARRAY scanlines;
	JDIMENSION i, j, read_lines;
	AV * row;
	AV * sample;
PPCODE:
	i = cinfo->output_height - cinfo->output_scanline;
	if (max_lines > i) max_lines = i;
	//
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
		//PUSHs( newRV_noinc((SV*)row) );
		PUSHs( newRV_noinc(sv_2mortal((SV*)row) ) );
		Safefree(scanlines[i]);
	}
	for (i=read_lines; i<max_lines; i++)
	{
		Safefree(scanlines[i]);
	}
	Safefree(scanlines);

bool
jpeg_finish_decompress (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo

bool
jpeg_has_multiple_scans (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo

bool
jpeg_start_output (cinfo, scan_number)
	Image::JPEG::Libjpeg::Decompress cinfo
	int scan_number

bool
jpeg_finish_output (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo

bool
jpeg_input_complete (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo

void
jpeg_new_colormap (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo

int
jpeg_consume_input (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo

void
jpeg_calc_output_dimensions (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo

void
jpeg_save_markers (cinfo, marker_code, length_limit)
	Image::JPEG::Libjpeg::Decompress cinfo
	int marker_code
	unsigned int length_limit

bool
jpeg_resync_to_restart (cinfo, desired)
	Image::JPEG::Libjpeg::Decompress cinfo
	int desired

void
jpeg_abort_decompress (cinfo)
	Image::JPEG::Libjpeg::Decompress cinfo
