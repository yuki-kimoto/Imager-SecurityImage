use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    use_ok( 'Imager::SecurityImage' ) || print "Bail out!\n";
}

my $sec_image = Imager::SecurityImage->new;

$DB::single = 1;

$sec_image->write_security_image_to_file('t/cap.png');
