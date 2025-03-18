using Documenter
using EzXML

makedocs(
    sitename="EzXML.jl",
    modules=[EzXML],
    pages=["index.md", "manual.md", "reference.md", "devnotes.md"],
    warnonly=:doctest,
    checkdocs=:none,
)

deploydocs(
    repo="github.com/JuliaIO/EzXML.jl.git",
    target="build")
