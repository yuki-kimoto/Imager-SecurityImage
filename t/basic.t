use strict;
use warnings;
use Test::More 'no_plan';
use File::Temp ();
use FindBin;

BEGIN {
  use_ok( 'Imager::SecurityImage' ) || print "Bail out!\n";
}

sub slurp {
  my $file = shift;
  
  open my $fh, '<', $file
    or die "Can't open file $file: $!";
  
  binmode $fh;
  my $content = do { local $/; <$fh> };
  
  return $content;
}

# Set srand value for test
$ENV{IMAGER_SECURITY_IMAGE_TEST_SRAND} = 100;


# write_security_image_to_file
{
  my $tmp_dir = File::Temp->newdir;
  my $sec_image = Imager::SecurityImage->new;
  my $output_file = "$tmp_dir/sec.png";
  $sec_image->write_security_image_to_file($output_file);

  my $expected_file = "$FindBin::Bin/images/sec.png";
  
  if (slurp($output_file) eq slurp($expected_file)) {
    pass;
  }
  else {
    fail;
  }
}

# get_security_image_data
{
  my $tmp_dir = File::Temp->newdir;
  my $sec_image = Imager::SecurityImage->new;
  my $security_image_data = $sec_image->get_security_image_data;

  my $expected_file = "$FindBin::Bin/images/sec.png";
  if ($security_image_data eq slurp($expected_file)) {
    pass;
  }
  else {
    fail;
  }
}

1;
