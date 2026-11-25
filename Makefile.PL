use 5.010;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use ExtUtils::CppGuess;
use PDL::Core::Dev;

my $brew_prefix = '';
if ($^O eq 'darwin') {
    chomp($brew_prefix = `brew --prefix 2>/dev/null` || '');
}
my @inc_dirs = ('/usr/include', '/usr/local/include');
push @inc_dirs, "$brew_prefix/include" if $brew_prefix;
my $mlpack_inc;
for my $dir (@inc_dirs) {
    if (-f "$dir/mlpack.hpp") {
        $mlpack_inc = $dir;
        last;
    }
}
if (!$mlpack_inc) {
    die "libmlpack-dev (mlpack.hpp) is required to build PDL::ML::Engine::MLPack.\n";
}
my $lib_flag = ($brew_prefix && $mlpack_inc && $mlpack_inc =~ m{^\$brew_prefix}) ? "-L$brew_prefix/lib " : '';

my $pdl_inc      = PDL::Core::Dev::PDL_INCLUDE();
my $guess        = ExtUtils::CppGuess->new();
my %cpp_opts     = $guess->makemaker_options();
my $cpp_compiler = $guess->compiler_command() || 'g++';
my $cpp_libs     = $guess->linker_flags()     || '-lstdc++';
my $cpp_flags    = ($cpp_opts{CCFLAGS} || '') . ' -std=c++17';

WriteMakefile(
    NAME               => 'PDL::ML::Engine::MLPack',
    AUTHOR             => q{C.J. Collier <cjac@google.com>},
    VERSION_FROM       => 'lib/PDL/ML/Engine/MLPack.pm',
    ABSTRACT_FROM      => 'lib/PDL/ML/Engine/MLPack.pm',
    LICENSE            => 'perl_5',
    MIN_PERL_VERSION   => '5.010',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
        'ExtUtils::CppGuess'  => '0.26',
        'PDL'                 => '2.080',
    },
    TEST_REQUIRES => {
        'Test::More' => '0.88',
    },
    PREREQ_PM => {
        'PDL' => '2.080',
    },
    INC    => '-I. ' . $pdl_inc . ' -I' . $mlpack_inc,
    LIBS   => [ $lib_flag . '-larmadillo -lblas -llapack ' . $cpp_libs ],
    ($brew_prefix ? (dynamic_lib => { OTHERLDFLAGS => "-L$brew_prefix/lib -Wl,-rpath,$brew_prefix/lib -larmadillo -framework Accelerate" }) : ()),
    OBJECT => 'MLPack$(OBJ_EXT) mlpack_bridge$(OBJ_EXT)',
    XS     => { 'MLPack.xs' => 'MLPack.c' },
    clean  => { FILES => 'PDL-ML-Engine-MLPack-* *.o MLPack.bs MLPack.c' },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/PDLPorters/PDL-ML-Engine-MLPack.git',
                web  => 'https://github.com/PDLPorters/PDL-ML-Engine-MLPack',
            },
            bugtracker => {
                web => 'https://github.com/PDLPorters/PDL-ML-Engine-MLPack/issues',
            },
        },
    },
);

package MY;

sub postamble {
    return <<"END_MAKE";
CXX = $cpp_compiler
CXXFLAGS = $cpp_flags -O2 -fPIC

mlpack_bridge\$(OBJ_EXT): mlpack_bridge.cc mlpack_bridge.h
\t\$(CXX) \$(CXXFLAGS) -I. -I$mlpack_inc -c mlpack_bridge.cc -o mlpack_bridge\$(OBJ_EXT)
END_MAKE
}
