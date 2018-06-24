using BinaryProvider

# Configure the binary dependency.
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

products = [
    LibraryProduct(prefix, String["libxml2"], :libxml2),
]

bin_prefix = "https://github.com/bicycle1885/XML2Builder/releases/download/v1.0.1"
download_info = Dict(
    BinaryProvider.Linux(:aarch64, :glibc)     => ("$bin_prefix/XML2Builder.v2.9.7.aarch64-linux-gnu.tar.gz", "09c42524aacc117f0ff2237b5b7c72c3ff68087e0873a72163a89866124938a2"),
    BinaryProvider.Linux(:armv7l, :glibc)      => ("$bin_prefix/XML2Builder.v2.9.7.arm-linux-gnueabihf.tar.gz", "84ae8769890ea32dfd56fc0d37b2e36621d6b39f4581cd06e99debe8c895e99f"),
    BinaryProvider.Linux(:i686, :glibc)        => ("$bin_prefix/XML2Builder.v2.9.7.i686-linux-gnu.tar.gz", "f2f2995bc0504a5d843f779dc027aa130e10dd018b542b6c963795938db6b3ef"),
    BinaryProvider.Linux(:powerpc64le, :glibc) => ("$bin_prefix/XML2Builder.v2.9.7.powerpc64le-linux-gnu.tar.gz", "bcd6a80cf0eb8aba5193a1e2830bbe79011e684bb22600a19be3e7415862d829"),
    BinaryProvider.Linux(:x86_64, :glibc)      => ("$bin_prefix/XML2Builder.v2.9.7.x86_64-linux-gnu.tar.gz", "4a42f19c355dbc3654d55c3736cebf31d325f6170c22bc0e1767bbe5f1938a93"),
    BinaryProvider.MacOS()                     => ("$bin_prefix/XML2Builder.v2.9.7.x86_64-apple-darwin14.tar.gz", "5129197d1ff27efa9a2981681e4ad55d880893d6782d8e290ec1413830e2c51f"),
    BinaryProvider.Windows(:i686)              => ("$bin_prefix/XML2Builder.v2.9.7.i686-w64-mingw32.tar.gz", "99d2214bbe98ad44b5496b681578b7a6d8ec85125f37b58be243b81243ac7111"),
    BinaryProvider.Windows(:x86_64)            => ("$bin_prefix/XML2Builder.v2.9.7.x86_64-w64-mingw32.tar.gz", "78226b738d71a371c9b017ff889a7394e092f3090f38c4afabc8065c5403d438"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
