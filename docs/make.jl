using Documenter
using EzXML

makedocs(
    format=:html,
    sitename="EzXML.jl",
    modules=[EzXML],
    pages=["index.md", "manual.md", "reference.md", "devnotes.md"])

deploydocs(
    repo="github.com/bicycle1885/EzXML.jl.git",
    julia="0.6",
    target="build",
    deps=nothing,
    make=nothing)
