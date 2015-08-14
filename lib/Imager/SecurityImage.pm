use 5.008007;

package Imager::SecurityImage;

use Object::Simple -base;

use POSIX qw(floor);
use Imager;
use Imager::Font;
use Imager::Matrix2d;
use List::Util qw(shuffle);
use File::Temp ();
use Carp 'croak';

sub get_security_image_data {
  my $self = shift;
  
  my $tmp_dir = File::Temp->newdir;
  my $tmp_file = "$tmp_dir/tmp.png";
  
  # Write security image data to temp file
  open my $out_fh, '>', $tmp_file
    or croak "Can't open file $tmp_file for write: $!";
  $self->write_security_image_to_file($tmp_file);
  close $out_fh;
  
  # Read security image data from temp file
  open my $in_fh, '<', $tmp_file
    or croak "Can't open file $tmp_file for read: $!";
  binmode($in_fh);
  my $security_image_data = do { local $/; <$in_fh> };
  close $in_fh;
  
  return $security_image_data;
}

sub write_security_image_to_file {
  my ($self, $file) = @_;

  my $width  = 250; # CAPTCHA height
  my $height = 50;  # CAPTCHA width

  # CAPTCHA
  my $imager = Imager->new(xsize => $width, ysize => $height);
  $imager->box(filled => 1, color => $self->_random_color('#cccccc', '#ffffff'));

  for (1 .. $self->_random(200, 300)) {
    $imager->setpixel(
      x => $self->_random(0, $width - 1),
      y => $self->_random(0, $height - 1),
      color => $self->_random_color('#000000', '#666666'),
    );
  }

  $imager->filter(type => 'gaussian', stddev => 0.5);

  for (1 .. $self->_random(3, 5)) {
    $imager->line(
      color => $self->_random_color('#000000', '#666666'),
      x1 => $self->_random(0, $width - 1),
      y1 => $self->_random(0, $height - 1),
      x2 => $self->_random(0, $width - 1),
      y2 => $self->_random(0, $height - 1),
      aa => 1,
    );
  }
  
  my $font_file = $self->_get_font_file;
  my $font = Imager::Font->new(
    file => $font_file,
    size => 35,
    aa   => 1,
    type => 'ft2',
  );

  my $word;
  my $bbox;
  while (1) {
    $word = $self->_random_char(5, 10);
    $bbox = $font->bounding_box(string => $word);
    next if $bbox->total_width >= $width;
    last;
  }

  my $x = floor(($width - $bbox->total_width) / 2);
  for my $char (split //, $word) {
    my $bbox = $font->bounding_box(string => $char);
    
    # Hineri
    my $matrix = Imager::Matrix2d->shear(
      x => ($self->_random(-3, 3) / 10),
      y => ($self->_random(-3, 3) / 10),
    );
    $font->transform(matrix => $matrix);
    
    # Height is random
    my $y = $self->_random(10, floor($height - $bbox->font_height) * 2 - 10);
    $imager->string(
      align  => 0,
      x      => $x,
      y      => $y,
      halign => 'center',
      string => $char,
      font   => $font,
      color  => $self->_random_color('#000000', '#666666'),
    );
    $x += $bbox->total_width;
  }

  for (1 .. $self->_random(10, 15)) {
    my $angle = $self->_random(0, 360);
    my $x = $self->_random(0, $width);
    my $y = $self->_random(0, $height);
    my $radius = $self->_random(0, $width - $x);
    $imager->arc(
      color => $self->_random_color('#000000', '#666666'),
      x     => $x,
      y     => $y,
      r     => $radius,
      d1    => $angle,
      d2    => $angle + 1,
      aa    => 1,
    );
  }

  $imager->write(file => $file, type => 'png');
}

sub _get_font_file {
  my $self = shift;
  
  my $module_file = $INC{'Imager/SecurityImage.pm'};
  $module_file =~ s/\.pm$//;
  my $font_file = $module_file . '/Vera.ttf';
  
  return $font_file;
}

sub _random {
  my $self = shift;
  
  my($min, $max) = sort { $a <=> $b } @_;
  return floor($min + rand($max - $min + 1));
}

sub _random_color {
  my $self = shift;
  
  my($color_a, $color_b) = @_;
  my @rgb_a = map { hex $_ }
    $color_a =~ /^\#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})/i;
  my @rgb_b = map { hex $_ }
    $color_b =~ /^\#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})/i;
  my $r = $self->_random($rgb_a[0], $rgb_b[0]);
  my $g = $self->_random($rgb_a[1], $rgb_b[1]);
  my $b = $self->_random($rgb_a[2], $rgb_b[2]);
  return sprintf '#%02x%02x%02x', $r, $g, $b;
}

sub _random_char {
  my $self = shift;
  
  my($min, $max) = @_;
  my $length = $self->_random($min, $max);
  my @chr = ();
  push @chr, map { chr($_) } (ord('a') .. ord('z'));
  push @chr, map { chr($_) } (ord('A') .. ord('Z'));
  push @chr, map { chr($_) } (ord('0') .. ord('9'));
  return join '', (shuffle(@chr))[0 .. $length - 1];
}

=head1 NAME

Imager::SecurityImage - The great new Imager::SecurityImage!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Imager::SecurityImage;

    my $sec_image = Imager::SecurityImage->new();
    
    # Image data
    my $image_data = $sec_image->get_security_image;
    

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 METHODS

=head1 AUTHOR

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-imager-securityimage at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Imager-SecurityImage>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Imager::SecurityImage


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Imager-SecurityImage>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Imager-SecurityImage>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Imager-SecurityImage>

=item * Search CPAN

L<http://search.cpan.org/dist/Imager-SecurityImage/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Yuki Kimoto.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Imager::SecurityImage
