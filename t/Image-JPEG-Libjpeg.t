# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Image-JPEG-Libjpeg.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use constant DEBUG => 1;

use Test;
BEGIN { plan tests => 2 };
use Image::JPEG::Libjpeg;
ok(1); # If we made it this far, we're ok.

#########################

# Helper functions
sub write_ppm
{
  my ($filename, $image) = @_;
  open my $fp, '>:raw', $filename or die "Failed to open output file: $!";
  print $fp "P6\n";
  print $fp (@{$image->[0]} / 3) . " " . @{$image} . "\n";
  print $fp "255\n";
  foreach my $row (@{$image}) {
    print join(' ', @{$row}) . "\n";
    print $fp pack('C*', @{$row});
  }
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# Perl-ified version of the example.c decompress routine
sub read_JPEG_file
{
  my $filename = shift;

  # In this example we want to open the input file before doing anything else
  my $infile;
  if (! open($infile, '<:raw', $filename))
  {
    warn "Failure in read_JPEG_file: can't open $filename";
    return 0;
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
  # We can ignore the return value from jpeg_read_header since
  #   (a) suspension is not possible with the stdio data source, and
  #   (b) we passed TRUE to reject a tables-only JPEG file as an error.
  # See libjpeg.doc for more info.

  # Step 4: set parameters for decompression

  # In this example, we don't need to change any of the defaults set by
  # jpeg_read_header(), so we do nothing here.

  # Step 5: Start decompressor
  $cinfo->start_decompress();

  if (DEBUG) { print STDERR "Started decompress\n" }

  # We can ignore the return value since suspension is not possible
  # with the stdio data source.

  # We may need to do some setup of our own at this point before reading
  # the data.  After jpeg_start_decompress() we have the correct scaled
  # output image dimensions available, as well as the output colormap
  # if we asked for color quantization.

  # Step 6: while (scan lines remain to be read) */
  #           jpeg_read_scanlines(...); */

  # Here we use the library's state variable cinfo.output_scanline as the
  # loop counter, so that we don't have to keep track ourselves.
  my @image;
  while ($cinfo->get_output_scanline() < $cinfo->get_output_height()) {
    # jpeg_read_scanlines expects an array of pointers to scanlines.
    # Here the array is only one element long, but you could ask for
    # more than one scanline at a time if that's more convenient.

    my @scanline = $cinfo->read_scanlines();
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
  write_ppm("t/test_decode.ppm", \@image);
  if (DEBUG) { print STDERR "Wrote PPM\n" }

  # And we're done!
  return 1;
}

ok(read_JPEG_file("t/testimg.jpg"));
