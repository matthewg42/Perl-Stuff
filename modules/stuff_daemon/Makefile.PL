use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Stuff::Daemon',
    VERSION_FROM      => 'lib/Stuff/Daemon.pm', # finds $VERSION
    AUTHOR            => 'Matthew Gates <matthew@porpoisehead.net>',
);

