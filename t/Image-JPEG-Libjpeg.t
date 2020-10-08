# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Image-JPEG-Libjpeg.t'

#########################

use strict;
use warnings;

use File::Temp qw( tempfile );

use Test;
BEGIN { plan tests => 2 };

use Image::JPEG::Libjpeg;

#########################
# enable additional debug options
#  prints a lot of info to STDERR,
#  also retains the temp .ppm and .jpg files after execution
use constant DEBUG => 0;
#########################

# Perl-ified version of the example.c compress routine
sub write_JPEG_file
{
  my ($image, $filename, $quality) = @_;

  # In this example we want to open the output file before doing anything else
  my $outfile;
  if (! open($outfile, '>:raw', $filename))
  {
    warn "Failure in write_JPEG_file: can't open $filename";
    return undef;
  }
  if (DEBUG) { print STDERR "Opened file\n" }

  # Step 1: allocate and initialize JPEG compression object
  # Now we can initialize the JPEG compression object.
  my $cinfo = Image::JPEG::Libjpeg::Compress->new();
  if (DEBUG) { print STDERR "Created struct\n" }

  # Step 2: specify data destination (eg, a file)
  # Note: steps 2 and 3 can be done in either order.
  $cinfo->stdio_dest($outfile);
  if (DEBUG) { print STDERR "Set dest to outfile\n" }

  # Step 3: set parameters for compression
  # First we supply a description of the input image.
  # Four fields of the cinfo struct must be filled in:
  $cinfo->set_image_height( scalar @{$image} );
  $cinfo->set_image_width( length($image->[0]) / 3 );
  $cinfo->set_input_components( 3 );
  $cinfo->set_in_color_space( Image::JPEG::Libjpeg::JCS_RGB );

  # Now use the library's routine to set default compression parameters.
  # (You must set at least cinfo.in_color_space before calling this,
  # since the defaults depend on the source color space.)
  $cinfo->set_defaults();

  # Now you can set any non-default parameters you wish to.
  # Here we just illustrate the use of quality (quantization table) scaling:
  $cinfo->set_quality( $quality );
  if (DEBUG) { print STDERR "Set parameters\n" }

  # Step 4: Start compressor
  $cinfo->start_compress();
  if (DEBUG) { print STDERR "Started compress\n" }

  # Step 5: while (scan lines remain to be written)
  #           jpeg_write_scanlines(...);

  # Here we use the library's state variable cinfo.next_scanline as the
  # loop counter, so that we don't have to keep track ourselves.
  # To keep things simple, we pass one scanline per call; you can pass
  # more if you wish, though.
  while ( (my $i = $cinfo->get_next_scanline()) < $cinfo->get_image_height()) {
    $cinfo->write_scanlines( $image->[ $i ] );
    if (DEBUG) { print STDERR " . Read scanline (" . $i . "/" . $cinfo->get_image_height() . ")\n" }
  }

  # Step 6: Finish compression
  $cinfo->finish_compress();
  if (DEBUG) { print STDERR "Finished compress\n" }
  # After finish_compress, we can close the output file.
  close($outfile);
  if (DEBUG) { print STDERR "Closed file\n" }

  # Step 7: release JPEG compression object
  # This is an important step since it will release a good deal of memory.
  undef $cinfo;

  # And we're done!
  return $filename;
}

# Perl-ified version of the example.c decompress routine
sub read_JPEG_file
{
  my $filename = shift;

  # In this example we want to open the input file before doing anything else
  my $infile;
  if (! open($infile, '<:raw', $filename))
  {
    warn "Failure in read_JPEG_file: can't open $filename";
    return undef;
  }
  if (DEBUG) { print STDERR "Opened file\n" }

  # Step 1: allocate and initialize JPEG decompression object
  # Now we can initialize the JPEG decompression object.
  my $cinfo = Image::JPEG::Libjpeg::Decompress->new();
  if (DEBUG) { print STDERR "Created struct\n" }

  # Step 2: specify data source (eg, a file)
  $cinfo->stdio_src($infile);
  if (DEBUG) { print STDERR "Set src to infile\n" }

  # Step 3: read file parameters with jpeg_read_header()
  $cinfo->read_header(1);
  if (DEBUG) { print STDERR "Read header\n" }

  # Step 4: set parameters for decompression
  # In this example, we don't need to change any of the defaults set by
  # jpeg_read_header(), so we do nothing here.

  # Step 5: Start decompressor
  $cinfo->start_decompress();
  if (DEBUG) { print STDERR "Started decompress\n" }

  # Step 6: while (scan lines remain to be read) */
  #           jpeg_read_scanlines(...); */
  # Here we use the library's state variable cinfo.output_scanline as the
  # loop counter, so that we don't have to keep track ourselves.
  my @image;
  while ($cinfo->get_output_scanline() < $cinfo->get_output_height()) {
    # jpeg_read_scanlines expects an array of pointers to scanlines.
    # Here the array is only one element long, but you could ask for
    # more than one scanline at a time if that's more convenient.

    my @scanline = $cinfo->read_scanlines(1);
    if (DEBUG) { print STDERR " . Read scanline (" . $cinfo->get_output_scanline() . "/" . $cinfo->get_output_height() . ")\n" }

    # Assume put_scanline_someplace wants a pointer and sample count.
    push @image, @scanline;
  }

  # Step 7: Finish decompression
  $cinfo->finish_decompress();
  if (DEBUG) { print STDERR "Finished decompress\n" }
  # We can ignore the return value since suspension is not possible
  # with the stdio data source.

  # Step 8: Release JPEG decompression object

  # This is an important step since it will release a good deal of memory.
  undef $cinfo;

  # After finish_decompress, we can close the input file.
  # Here we postpone it until after no more JPEG errors are possible,
  # so as to simplify the setjmp error logic above.  (Actually, I don't
  # think that jpeg_destroy can do an error exit, but why assume anything...)

  close($infile);
  if (DEBUG) { print STDERR "Closed file\n" }

  # At this point you may want to check to see whether any corrupt-data
  # warnings occurred (test whether jerr.pub.num_warnings is nonzero).
  # And we're done!
  return \@image;
}

#########################
# Tests

my $image = read_JPEG_file("t/testimg.jpg");
ok( defined $image );

if (DEBUG) {
  # write PPM file to disk
  my ($fp, $filename) = tempfile('testXXXX', SUFFIX => '.ppm', TMPDIR => 1, UNLINK => 0);
  binmode $fp;
  print $fp "P6\n";
  print $fp (length($image->[0]) / 3) . " " . @{$image} . "\n";
  print $fp "255\n";
  foreach my $row (@{$image}) {
    print $fp $row;
  }
  close $fp;
  print STDERR "Wrote PPM to: $filename\n";
}

my (undef, $filename) = tempfile('testXXXX', SUFFIX => '.jpg', TMPDIR => 1, UNLINK => ! DEBUG);
ok(write_JPEG_file($image, $filename, 75));
if (DEBUG) { print STDERR "Wrote JPG to: $filename\n" }
