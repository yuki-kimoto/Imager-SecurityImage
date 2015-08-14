use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Imager::SecurityImage',
    AUTHOR           => q{Yuki Kimoto <kimoto.yuki@gmail.com>},
    VERSION_FROM     => 'lib/Imager/SecurityImage.pm',
    ABSTRACT_FROM    => 'lib/Imager/SecurityImage.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Image::PNG::Simple' => '0.07'
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Imager-SecurityImage-*' },
);
