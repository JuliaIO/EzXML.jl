using Pkg
Pkg.instantiate()
Pkg.develop(PackageSpec(path=pwd()))
Pkg.build("EzXML")
