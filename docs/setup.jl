using Pkg
pkgspec = PackageSpec(path=pwd())
Pkg.instantiate()
Pkg.develop(pkgspec)
#Pkg.build(pkgspec)
