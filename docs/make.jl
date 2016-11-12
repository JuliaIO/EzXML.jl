using Documenter
using EzXML

makedocs(
    format=:html,
    sitename="EzXML.jl",
    pages=["manual.md", "references.md", "devnotes.md"])

deploydocs(
    repo="github.com/bicycle1885/EzXML.jl.git",
    julia="0.5")
