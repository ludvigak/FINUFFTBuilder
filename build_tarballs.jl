# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "FINUFFTBuilder"
version = v"0.1.0"

# Collection of sources required to build FINUFFTBuilder
sources = [
    "https://github.com/flatironinstitute/finufft/archive/1.1.1.zip" =>
    "a51e8d56544378ace1e5c4177717dfe0943ea3aab08018094f2a9c4375576ed6",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir	
cd finufft-1.1.1/
sed -i s/_\$\(FFTWOMPSUFFIX\)// makefile
if [[ $target == aarch64-* ]] || [[ $target == arm-* ]] || [[ $target == powerpc* ]]; then
   sed -i s/-march=native// makefile
fi
make lib/libfinufft.so LIBRARY_PATH=$prefix/lib/ CPATH=$prefix/include/ LIBS="-lm -L$prefix/lib $LDFLAGS"
if [[ ${target} == x86_64-apple* ]]; then
   cp lib/libfinufft.so $prefix/lib/libfinufft.dylib
else
   cp lib/libfinufft.so $prefix/lib/
fi
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    FreeBSD(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libfinufft", :libfinufft)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://raw.githubusercontent.com/JuliaMath/FFTW.jl/v0.2.4/deps/build_fftw.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

