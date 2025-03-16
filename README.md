<p align="center"><img src="/docs/EzXML.jl.png" alt="EzXML.jl Logo" width="350" /></p>

EzXML.jl - XML/HTML tools for primates
======================================

[![Docs Stable][docs-stable-img]][docs-stable-url]
[![Docs Latest][docs-latest-img]][docs-latest-url]
[![CI Status][ci-status-img]][ci-status-url]
[![codecov.io][codecov-img]][codecov-url]

EzXML.jl is a package to handle XML/HTML documents for primates.

The main features are:
* Reading and writing XML/HTML documents.
* Traversing XML/HTML trees with DOM interfaces.
* Searching elements using XPath.
* Proper namespace handling.
* Capturing error messages.
* Automatic memory management.
* Document validation.
* Streaming parsing for large XML files.

Installation
------------

Install EzXML.jl as follows:
```
julia -e 'using Pkg; Pkg.add("EzXML")'
```

This package depends on [libxml2](http://xmlsoft.org/), which will be automatically installed as an artifact via [XML2_jll.jl](https://github.com/JuliaBinaryWrappers/XML2_jll.jl) if you use Julia 1.3 or later.
Currently, Windows, Linux, macOS, and FreeBSD are now supported.

Version compatibility
---------------------

| EzXML.jl | Julia        |
|:--------:|:------------:|
| 1.0      | 1.0 or later |
| 1.1      | 1.3 or later |
| 1.2      | 1.6 or later |

Usage
-----

```julia
# Load the package.
using EzXML

# Parse an XML string
# (use `readxml(<filename>)` to read a document from a file).
doc = parsexml("""
<primates>
    <genus name="Homo">
        <species name="sapiens">Human</species>
    </genus>
    <genus name="Pan">
        <species name="paniscus">Bonobo</species>
        <species name="troglodytes">Chimpanzee</species>
    </genus>
</primates>
""")

# Get the root element from `doc`.
primates = root(doc)  # or `doc.root`

# Iterate over child elements.
for genus in eachelement(primates)
    # Get an attribute value by name.
    genus_name = genus["name"]
    println("- ", genus_name)
    for species in eachelement(genus)
        # Get the content within an element.
        species_name = nodecontent(species)  # or `species.content`
        println("  └ ", species["name"], " (", species_name, ")")
    end
end
println()

# Find texts using XPath query.
for species_name in nodecontent.(findall("//species/text()", primates))
    println("- ", species_name)
end
```

Quick reference
---------------

See the [reference page](https://juliaio.github.io/EzXML.jl/stable/reference/) or docstrings for more details.

Types:
* `EzXML.Document`: an XML/HTML document
* `EzXML.Node`: an XML/HTML node including elements, attributes, texts, etc.
* `EzXML.XMLError`: an error happened in libxml2
* `EzXML.StreamReader`: a streaming XML reader

IO:
* From file: `readxml(filename|stream)`, `readhtml(filename|stream)`
* From string or byte array: `parsexml(string)`, `parsehtml(string)`
* To file: `write(filename, doc)`
* To stream: `print(io, doc)`

Accessors:
* Node information: `nodetype(node)`, `nodepath(node)`, `nodename(node)`, `nodecontent(node)`, `setnodename!(node, name)`, `setnodecontent!(node, content)`
* Node property: `node.type`, `node.name`, `node.path`, `node.content`, `node.namespace`
* Document:
    - Property: `version(doc)`, `encoding(doc)`, `hasversion(doc)`, `hasencoding(doc)`
    - Node: `root(doc)`, `dtd(doc)`, `hasroot(doc)`, `hasdtd(doc)`, `setroot!(doc, element_node)`, `setdtd!(doc, dtd_node)`
* Document property: `doc.version`, `doc.encoding`, `doc.node`, `doc.root`, `doc.dtd`
* Attributes: `node[name]`, `node[name] = value`, `haskey(node, name)`, `delete!(node, name)`
* Node predicate:
    * Document: `hasdocument(node)`
    * Parent: `hasparentnode(node)`, `hasparentelement(node)`
    * Child: `hasnode(node)`, `haselement(node)`
    * Sibling: `hasnextnode(node)`, `hasprevnode(node)`, `hasnextelement(node)`, `hasprevelement(node)`
    * Node type: `iselement(node)`, `isattribute(node)`, `istext(node)`, `iscdata(node)`, `iscomment(node)`, `isdtd(node)`
* Tree traversal:
    * Document: `document(node)`
    * Parent: `parentnode(node)`, `parentelement(node)`
    * Child: `firstnode(node)`, `lastnode(node)`, `firstelement(node)`, `lastelement(node)`
    * Sibling: `nextnode(node)`, `prevnode(node)`, `nextelement(node)`, `prevelement(node)`
* Tree modifiers:
    * Link: `link!(parent_node, child_node)`, `linknext!(target_node, node)`, `linkprev!(target_node, node)`
    * Unlink: `unlink!(node)`
    * Create: `addelement!(parent_node, name, [content])`
* Iterators:
    * Iterator: `eachnode(node)`, `eachelement(node)`, `eachattribute(node)`
    * Vector: `nodes(node)`, `elements(node)`, `attributes(node)`
* Counters: `countnodes(node)`, `countelements(node)`, `countattributes(node)`
* Namespaces: `namespace(node)`, `namespaces(node)`

Constructors:
* `EzXML.Document` type: `XMLDocument(version="1.0")`, `HTMLDocument(uri=nothing, externalID=nothing)`
* `EzXML.Node` type: `XMLDocumentNode(version="1.0")`, `HTMLDocumentNode(uri, externalID)`, `ElementNode(name)`, `TextNode(content)`, `CommentNode(content)`, `CDataNode(content)`, `AttributeNode(name, value)`, `DTDNode(name, [systemID, [externalID]])`

Queries:
* XPath: `findall(xpath, doc|node)`, `findfirst(xpath, doc|node)`, `findlast(xpath, doc|node)`\
  (Note the caveat on the combination of XPath and namespaces in the [manual](https://juliaio.github.io/EzXML.jl/stable/manual/#XPath-1))


Examples
--------

* [primates.jl](/example/primates.jl): Run "primates" example shown above.
* [julia2xml.jl](/example/julia2xml.jl): Convert a Julia expression to XML.
* [listlinks.jl](/example/listlinks.jl): List all links in an HTML document.

Other XML/HTML packages in Julia
--------------------------------

* [XML.jl](https://github.com/JuliaComputing/XML.jl)
* [LightXML.jl](https://github.com/JuliaIO/LightXML.jl)
* [LibExpat.jl](https://github.com/JuliaIO/LibExpat.jl)

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://juliaio.github.io/EzXML.jl/stable
[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://juliaio.github.io/EzXML.jl/latest
[codecov-img]: https://codecov.io/gh/JuliaIO/EzXML.jl/branch/master/graph/badge.svg?token=ghRtgNZUhC
[codecov-url]: https://codecov.io/gh/JuliaIO/EzXML.jl
[ci-status-img]: https://github.com/JuliaIO/EzXML.jl/actions/workflows/CI.yml/badge.svg?branch=master
[ci-status-url]: https://github.com/JuliaIO/EzXML.jl/actions/workflows/CI.yml
