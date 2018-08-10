<p align="center"><img src="/docs/EzXML.jl.png" alt="EzXML.jl Logo" width="350" /></p>

EzXML.jl - XML/HTML tools for primates
======================================

[![Docs Stable][docs-stable-img]][docs-stable-url]
[![Docs Latest][docs-latest-img]][docs-latest-url]
[![TravisCI Status][travisci-img]][travisci-url]
[![Appveyor Status][appveyor-img]][appveyor-url]
[![codecov.io][codecov-img]][codecov-url]

**Still in beta-quality package; the APIs may change in the future.**

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

This package depends on [libxml2](http://xmlsoft.org/), which will be installed
automatically from <https://github.com/bicycle1885/XML2Builder> via
[BinaryProvider.jl](https://github.com/JuliaPackaging/BinaryProvider.jl).
Windows, Linux, and macOS are now supported.

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
primates = root(doc)

# Iterate over child elements.
for genus in eachelement(primates)
    # Get an attribute value by name.
    genus_name = genus["name"]
    println("- ", genus_name)
    for species in eachelement(genus)
        # Get the content within an element.
        species_name = nodecontent(species)
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

See the [reference page](https://bicycle1885.github.io/EzXML.jl/stable/reference.html) or docstrings for more details.

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
* XPath: `findall(xpath, doc|node)`, `findfirst(xpath, doc|node)`, `findlast(xpath, doc|node)`

Examples
--------

* [primates.jl](/example/primates.jl): Run "primates" example shown above.
* [julia2xml.jl](/example/julia2xml.jl): Convert a Julia expression to XML.
* [listlinks.jl](/example/listlinks.jl): List all links in an HTML document.

Other XML/HTML packages in Julia
--------------------------------

* [LightXML.jl](https://github.com/JuliaIO/LightXML.jl)
* [LibExpat.jl](https://github.com/amitmurthy/LibExpat.jl)

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://bicycle1885.github.io/EzXML.jl/stable
[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://bicycle1885.github.io/EzXML.jl/latest
[travisci-img]: https://travis-ci.org/bicycle1885/EzXML.jl.svg?branch=master
[travisci-url]: https://travis-ci.org/bicycle1885/EzXML.jl
[appveyor-img]: https://ci.appveyor.com/api/projects/status/n5d7o2mmy8ckdjc8?svg=true
[appveyor-url]: https://ci.appveyor.com/project/bicycle1885/ezxml-jl
[codecov-img]: http://codecov.io/github/bicycle1885/EzXML.jl/coverage.svg?branch=master
[codecov-url]: http://codecov.io/github/bicycle1885/EzXML.jl?branch=master
