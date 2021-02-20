# Test functions from libjpeg makefile, in Perl form

#########################

use strict;
use warnings;

use autodie;

use File::Temp qw( tempfile );

use Test;
BEGIN { plan tests => 5 };

use Image::JPEG::Libjpeg;

#########################

# The test section from libjpeg makefile is:
#test: cjpeg djpeg jpegtran
#        $(RM) testout*
#        ./djpeg -dct int -ppm -outfile testout.ppm testorig.jpg
#        ./djpeg -dct int -gif -outfile testout.gif testorig.jpg
#        ./djpeg -dct int -bmp -colors 256 -outfile testout.bmp testorig.jpg
#        ./cjpeg -dct int -outfile testout.jpg testimg.ppm
#        ./djpeg -dct int -ppm -outfile testoutp.ppm testprog.jpg
#        ./cjpeg -dct int -progressive -opt -outfile testoutp.jpg testimg.ppm
#        ./jpegtran -outfile testoutt.jpg testprog.jpg
#        cmp testimg.ppm testout.ppm
#        cmp testimg.gif testout.gif
#        cmp testimg.bmp testout.bmp
#        cmp testimg.jpg testout.jpg
#        cmp testimg.ppm testoutp.ppm
#        cmp testimgp.jpg testoutp.jpg
#        cmp testorig.jpg testoutt.jpg

# this script does some of these

#########################
# Helper functions
sub read_bytes {
  my ($fp, $count) = @_;
  my $buffer;

  if ($count == 0) {
    die "Request to read 0 bytes";
  }

  my $bytes_read = read $fp, $buffer, $count;
  if (!defined $bytes_read) {
    die "Read ($count) failed on $fp: $!";
  } elsif ($bytes_read == 0) {
    die "Read ($count) failed on $fp: at end of file";
  } elsif ($bytes_read != $count) {
    die "Read ($count) failed on $fp: got $bytes_read";
  }

  return $buffer;
}

sub compare
{
  my ($a, $b) = @_;

  my $a_type = ref $a;
  my $b_type = ref $b;

  if ($a_type ne $b_type) {
    die "Reference mismatch between $a_type and $b_type";
  }

  if ($a_type eq 'ARRAY') {
    return -1 if (@$a < @$b);
    return 1 if (@$a > @$b);

    for my $i (0 .. $#$a)
    {
      my $val = compare($a->[$i], $b->[$i]);
      return $val if $val;
    }

    return 0;
  } else {
    return $a cmp $b;
  }
}

# READ A RAW BIN FILE
sub read_bin
{
  my $filename = shift;
  open my $fp, '<:raw', $filename or die "Failed to open input file: $!";
  my $file_content = read_bytes($fp, -s $filename);
  close $fp;

  return $file_content;
}

# READ A PPM FILE
sub read_ppm
{
  my $filename = shift;
  my $file_content = read_bin($filename);

  # parse PPM file
  if ($file_content =~ m/^(\S+)\s(\S+)\s(\S+)\s(\S+)\s(.+)$/s) {
    my ($type, $width, $height, $colors, $data) = ($1, $2, $3, $4, $5);
    die "Unknown file type $type" unless $type eq 'P6';
    die "Unexpected color count $colors" unless $colors == 255;

    my $bpr = $width * 3;
    my @image = unpack "(A[$bpr])*", $data;
    return \@image;
  } else {
    die "File does not seem to be in PPM format";
  }
}

# READ A PALETTED BMP FILE
sub read_bmp
{
  my $filename = shift;

  open my $fp, '<:raw', $filename or die "Failed to open input file: $!";
  # BMP header
  my ($signature, $fileSize, $dataOffset) = unpack 'nVx4V', read_bytes($fp, 14);
  die "Does not look like a BMP file (signature=$signature)" unless $signature == 0x424d;
  die "Filesize $fileSize seems incorrect" unless $fileSize = -s $filename;

  # INFOHEADER
  my ($headerSize, $width, $height, $planes, $bpp, $compression, $imageSize, $colors) =
    unpack "VVVvvVVx4x4Vx4", read_bytes($fp, 40);
  die "headerSize $headerSize seems wrong" unless $headerSize == 0x28;
  die "Too many planes ($planes)" unless $planes == 1;
  die "Expected 8bpp palette image" unless $bpp == 8;
  die "Compression unsupported" if $compression;
  die "Should be 256 colors" unless $colors == 256;

  # PALETTE
  my @palette;
  my @vals;
  for my $i (0 .. $colors - 1)
  {
    ($vals[0][$i], $vals[1][$i], $vals[2][$i]) = unpack 'C3x', read_bytes($fp, 4);
  }
  $palette[2] = pack 'C*', @{$vals[0]};
  $palette[1] = pack 'C*', @{$vals[1]};
  $palette[0] = pack 'C*', @{$vals[2]};

  # IMAGEDATA
  die "Data offset $dataOffset seems wrong" unless $dataOffset == tell($fp);
  if ($imageSize == 0) { $imageSize = $fileSize - $dataOffset }
  my $rowlen = $width;
  if ($rowlen % 4) {
    $rowlen += (4 - ($rowlen % 4));
  }
  # bmp stored upside-down...
  my @image;
  for (my $i = $height - 1; $i >= 0; $i --) {
    $image[$i] = substr(read_bytes($fp, $rowlen), 0, $width);
  }

  return (\@image, \@palette);
}

#########################

sub cjpeg
{
  my $image = shift;

  my ($fh, $filename) = tempfile('testXXXX', SUFFIX => '.jpg', TMPDIR => 1, UNLINK => 1);

  my $cinfo = Image::JPEG::Libjpeg::Compress->new();

  $cinfo->stdio_dest($fh);

  $cinfo->set_image_height(scalar @{$image});
  $cinfo->set_image_width(length($image->[0]) / 3);
  $cinfo->set_input_components(3);
  $cinfo->set_in_color_space(Image::JPEG::Libjpeg::JCS_RGB);

  $cinfo->set_defaults();

  $cinfo->start_compress();
  while ( (my $i = $cinfo->get_next_scanline()) < $cinfo->get_image_height()) {
    $cinfo->write_scanlines( $image->[ $i ] );
  }
  $cinfo->finish_compress();
  close($fh);

  return $filename;
}

#########################

sub djpeg
{
  my ($filename, $params) = @_;

  my $infile;
  if (! open($infile, '<:raw', $filename))
  {
    warn "Failure in read_JPEG_file: can't open $filename";
    return 0;
  }

  my $cinfo = Image::JPEG::Libjpeg::Decompress->new();

  $cinfo->stdio_src($infile);
  $cinfo->read_header(1);

  if ($params && $params eq 'quantize') {
    $cinfo->set_quantize_colors(1);
  }
  $cinfo->set_dct_method(Image::JPEG::Libjpeg::JDCT_ISLOW);

  $cinfo->start_decompress();
  my @image;
  while ($cinfo->get_output_scanline() < $cinfo->get_output_height()) {
    my @scanline = $cinfo->read_scanlines(1);
    push @image, @scanline;
  }
  $cinfo->finish_decompress();

  close($infile);

  if ($params && $params eq 'quantize') {
    my @colormap = $cinfo->get_colormap();
    return (\@image, \@colormap);
  }
  return \@image;
}

#########################

my $ppm = read_ppm('t/testimg.ppm');
# TEST 1
{
  #        ./djpeg -dct int -ppm -outfile testout.ppm testorig.jpg
  # read JPG, compare PPM
  my $image = djpeg('t/testorig.jpg');
  #        cmp testimg.ppm testout.ppm
  ok(compare($image, $ppm) == 0);
}

# TEST 2
#        ./djpeg -dct int -gif -outfile testout.gif testorig.jpg
#        cmp testimg.gif testout.gif
# SKIPPED, we do not care about gif support

# TEST 3
{
  #        ./djpeg -dct int -bmp -colors 256 -outfile testout.bmp testorig.jpg
  # this tests using the color remapping of djpeg
  my ($image, $jpalette) = djpeg('t/testorig.jpg', 'quantize');
  my ($bmp, $bpalette) = read_bmp('t/testimg.bmp');
  #        cmp testimg.bmp testout.bmp
  ok(compare($image, $bmp) == 0);
  ok(compare($jpalette, $bpalette) == 0);
}

# TEST 4
{
  #        ./cjpeg -dct int -outfile testout.jpg testimg.ppm
  # attempt to compress ppm with cjpeg
  my $filename = cjpeg($ppm);
  my $image = read_bin($filename);
  my $jpg = read_bin('t/testimg.jpg');
  #        cmp testimg.jpg testout.jpg
  ok($image eq $jpg);
}

# TEST 5
{
  #        ./djpeg -dct int -ppm -outfile testoutp.ppm testprog.jpg
  # decompress progressive jpg to ppm and compare
  my $image = djpeg('t/testprog.jpg');
  my $ppm = read_ppm('t/testimg.ppm');
  #        cmp testimg.ppm testoutp.ppm
  ok(compare($image, $ppm) == 0);
}

# TEST 6
#{
  #        ./cjpeg -dct int -progressive -opt -outfile testoutp.jpg testimg.ppm
#  print "hello";
  # turn testimg.ppm into a progressive jpg
#        cmp testimgp.jpg testoutp.jpg
#}

# TEST 7
#{
#        ./jpegtran -outfile testoutt.jpg testprog.jpg
#  print "hello";
#        cmp testorig.jpg testoutt.jpg
#}
