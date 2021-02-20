# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Image-JPEG-Libjpeg.t'

#########################

use strict;
use warnings;

use File::Temp qw( tempfile );

use Test;
BEGIN { plan tests => 21 };

my @required = (
  'JPEG_LIB_VERSION',
  'DCTSIZE',
  'DCTSIZE2',
  'NUM_QUANT_TBLS',
  'NUM_HUFF_TBLS',
  'NUM_ARITH_TBLS',
  'MAX_COMPS_IN_SCAN',
  'MAX_SAMP_FACTOR',
  'C_MAX_BLOCKS_IN_MCU',
  'D_MAX_BLOCKS_IN_MCU',
  'JDCT_DEFAULT',
  'JDCT_FASTEST',
  'JMSG_LENGTH_MAX',
  'JMSG_STR_PARM_MAX',
  'BITS_IN_JSAMPLE',
  'MAX_COMPONENTS',
  'MAXJSAMPLE',
  'CENTERJSAMPLE',
  'JPEG_MAX_DIMENSION',
);

my @optional = (
  'JPEG_LIB_VERSION_MAJOR',
  'JPEG_LIB_VERSION_MINOR',

  'DCT_ISLOW_SUPPORTED',
  'DCT_IFAST_SUPPORTED',
  'DCT_FLOAT_SUPPORTED',
  'C_ARITH_CODING_SUPPORTED',
  'C_MULTISCAN_FILES_SUPPORTED',
  'C_PROGRESSIVE_SUPPORTED',
  'DCT_SCALING_SUPPORTED',
  'ENTROPY_OPT_SUPPORTED',
  'INPUT_SMOOTHING_SUPPORTED',
  'D_ARITH_CODING_SUPPORTED',
  'D_MULTISCAN_FILES_SUPPORTED',
  'D_PROGRESSIVE_SUPPORTED',
  'IDCT_SCALING_SUPPORTED',
  'SAVE_MARKERS_SUPPORTED',
  'BLOCK_SMOOTHING_SUPPORTED',
  'UPSAMPLE_MERGING_SUPPORTED',
  'QUANT_1PASS_SUPPORTED',
  'QUANT_2PASS_SUPPORTED',
);

use Image::JPEG::Libjpeg;

# retrieve config info
my %config = Image::JPEG::Libjpeg::get_config();
ok( %config );

# verify existence of each required key
foreach my $key (@required) {
  my $value = delete $config{$key};
  ok( defined $value );
}

# delete all optional keys
foreach my $key (@optional) {
  delete $config{$key};
}

# ensure config is now empty
ok( scalar %config, 0, "config should be empty" );
