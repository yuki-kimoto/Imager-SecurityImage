use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    use_ok( 'Imager::SecurityImage' ) || print "Bail out!\n";
}

my $sec_image = Imager::SecurityImage->new;

$sec_image->write_security_image_to_file('t/cap.png');
my $security_image_data = $sec_image->get_security_image_data;

open my $fh, '>', 'a.png'
  or die;

binmode $fh;

print $fh $security_image_data;

1;
