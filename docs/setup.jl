using Pkg
pkgspec = PackageSpec(path=pwd())
@show pwd()
@show pkgspec
Pkg.instantiate()
Pkg.develop(pkgspec)
Pkg.build(pkgspec)
