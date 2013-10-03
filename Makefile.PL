use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Text::Aligner',
    VERSION_FROM => 'lib/Text/Aligner.pm', # finds $VERSION
    AUTHOR       => 'Anno Siegel (siegel@zrz.tu-berlin.de)',
    ABSTRACT     => 'Align text in columns',
    PREREQ_PM => {
        'Test::More' => 0,
        'Term::ANSIColor' => '2.01',
    },
);
