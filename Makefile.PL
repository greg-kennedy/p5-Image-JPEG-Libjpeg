use 5.006001;
use ExtUtils::MakeMaker;

WriteMakefile(
    # meta info
    NAME             => 'Image::JPEG::Libjpeg',
    AUTHOR           => 'Greg Kennedy <kennedy.greg@gmail.com>',
    VERSION_FROM     => 'lib/Image/JPEG/Libjpeg.pm',
    ABSTRACT_FROM    => 'lib/Image/JPEG/Libjpeg.pm',
    LICENSE          => 'artistic_2',
    META_MERGE => {
        resources => {
            homepage =>
                'https://github.com/greg-kennedy/p5-Image-JPEG-Libjpeg',
            repository =>
                'https://github.com/greg-kennedy/p5-Image-JPEG-Libjpeg',
            bugtracker =>
                'https://github.com/greg-kennedy/p5-Image-JPEG-Libjpeg/issues',
        },
    },

    # prerequisites
    MIN_PERL_VERSION => 5.006001,
    PREREQ_PM        => {'Test'        =>  0, },

    # C build information
    LIBS             => ['-ljpeg'],
);
