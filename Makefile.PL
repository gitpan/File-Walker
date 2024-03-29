use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME		=> 'File::Walker',
    VERSION_FROM	=> 'lib/File/Walker.pm', # finds $VERSION
    NO_META		=> 1,
    PREREQ_PM		=> {
	Test::Simple => 0.47,
	}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/File/Walker.pm', # retrieve abstract from module
       AUTHOR         => 'Tels') : ()),
);
