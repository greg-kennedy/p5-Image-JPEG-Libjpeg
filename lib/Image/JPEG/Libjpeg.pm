package Image::JPEG::Libjpeg;

use 5.006001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Image::JPEG::Libjpeg ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '1.00';

# Constants (replace T_ENUM from libjpeg)

# J_COLOR_SPACE
use constant {
  JCS_UNKNOWN => 0,
  JCS_GRAYSCALE => 1,
  JCS_RGB => 2,
  JCS_YCbCr => 3,
  JCS_CMYK => 4,
  JCS_YCCK => 5,
  # 9.0+
  JCS_BG_RGB => 6,
  JCS_BG_YCC => 7,
};

# J_COLOR_TRANSFORM
#  (libjpeg9)
use constant {
  JCT_NONE => 0,
  JCT_SUBTRACT_GREEN => 1,
};

# J_DCT_METHOD
use constant {
  JDCT_ISLOW => 0,
  JDCT_IFAST => 1,
  JDCT_FLOAT => 2,
};

# J_DITHER_MODE
use constant {
  JDITHER_NONE => 0,
  JDITHER_ORDERED => 1,
  JDITHER_FS => 2,
};

# return values of jpeg_read_header
use constant {
  JPEG_SUSPENDED => 0,
  JPEG_HEADER_OK => 1,
  JPEG_HEADER_TABLES_ONLY => 2,
};

# return values of jpeg_consume_input
use constant {
  JPEG_REACHED_SOS => 1,
  JPEG_REACHED_EOI => 2,
  JPEG_ROW_COMPLETED => 3,
  JPEG_SCAN_COMPLETED => 4,
};

# marker codes
use constant {
  JPEG_RST0 => 0xD0,
  JPEG_EOI => 0xD9,
  JPEG_APP0 => 0xE0,
  JPEG_COM => 0xFE,
};

# global_state field values
use constant {
  CSTATE_START => 100,
  CSTATE_SCANNING => 101,
  CSTATE_RAW_OK => 102,
  CSTATE_WRCOEFS => 103,
  DSTATE_START => 200,
  DSTATE_INHEADER => 201,
  DSTATE_READY => 202,
  DSTATE_PRELOAD => 203,
  DSTATE_PRESCAN => 204,
  DSTATE_SCANNING => 205,
  DSTATE_RAW_OK => 206,
  DSTATE_BUFIMAGE => 207,
  DSTATE_BUFPOST => 208,
  DSTATE_RDCOEFS => 209,
  DSTATE_STOPPING => 210,
};

require XSLoader;
XSLoader::load('Image::JPEG::Libjpeg', $VERSION);

# Preloaded methods go here.

1;
__END__

=head1 NAME

Image::JPEG::Libjpeg - Perl interface to the C library C<libjpeg>.

=head1 SYNOPSIS

  use Image::JPEG::Libjpeg;

  my $cinfo = Image::JPEG::Libjpeg::Decompress->new();

  open my $infile, '<:raw', 'testorig.jpg' or die $!;

  $cinfo->stdio_src($infile);
  $cinfo->read_header(1);
  $cinfo->start_decompress();

  my @image;
  while ($cinfo->get_output_scanline() < $cinfo->get_output_height()) {
    push @image, $cinfo->read_scanlines(1);
  }
  $cinfo->finish_decompress();

  close($infile);

=head1 DESCRIPTION

Image::JPEG::Libjpeg is a Perl library for working with JPEG images. It is a
thin wrapper around the common C C<libjpeg> (or compatible) library, exposing
the underlying C functions to Perl programs. Image::JPEG::Libjpeg does not
contain C<libjpeg>; it is a dependency and must be installed beforehand.

The library should work with any C<libjpeg> version from 6a to 9d. However,
attempting to use features from a newer version than installed on the system
will cause a fatal error.

=head1 FUNCTIONS

=head1 EXPORT

None by default.



=head1 SEE ALSO

Independent JPEG Group (libjpeg home): L<https://www.ijg.org/>

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Greg Kennedy, E<lt>kennedy.greg@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Greg Kennedy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.30.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
