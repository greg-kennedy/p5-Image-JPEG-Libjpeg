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
use constant {
  JCS_UNKNOWN => 0,
  JCS_GRAYSCALE => 1,
  JCS_RGB => 2,
  JCS_YCbCr => 3,
  JCS_CMYK => 4,
  JCS_YCCK => 5,
};

use constant {
  JDCT_ISLOW => 0,
  JDCT_IFAST => 1,
  JDCT_FLOAT => 2,
};

use constant {
  JDITHER_NONE => 0,
  JDITHER_ORDERED => 1,
  JDITHER_FS => 2,
};

# JPEG decompress defines
use constant {
  JPEG_SUSPENDED => 0,
  JPEG_HEADER_OK => 1,
  JPEG_HEADER_TABLES_ONLY => 2,
};
use constant {
  JPEG_REACHED_SOS => 1,
  JPEG_REACHED_EOI => 2,
  JPEG_ROW_COMPLETED => 3,
  JPEG_SCAN_COMPLETED => 4,
};

require XSLoader;
XSLoader::load('Image::JPEG::Libjpeg', $VERSION);

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Image::JPEG::Libjpeg - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Image::JPEG::Libjpeg;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Image::JPEG::Libjpeg, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Greg Kennedy, E<lt>grkenn@nyi.freebsd.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Greg Kennedy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.30.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
