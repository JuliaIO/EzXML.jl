using Documenter
using EzXML

makedocs(
    sitename="EzXML.jl",
    modules=[EzXML],
    pages=["index.md", "manual.md", "reference.md", "devnotes.md"])

deploydocs(
    repo="github.com/bicycle1885/EzXML.jl.git",
    target="build")
