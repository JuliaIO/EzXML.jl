<p align="center"><img src="/docs/EzXML.jl.png" alt="EzXML.jl Logo" width="250" /></p>

EzXML.jl - XML/HTML tools for primates
======================================

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

```julia
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
        species_name = content(species)
        println("  └ ", species["name"], " (", species_name, ")")
    end
end
println()

# Find texts using XPath query.
for species_name in content.(find(primates, "//species/text()"))
    println("- ", species_name)
end
```

Quick reference
---------------

See the [reference page](https://bicycle1885.github.io/EzXML.jl/latest/references.html) or docstrings for more details.

Types:
* `EzXML.Document`: an XML/HTML document
* `EzXML.Node`: an XML/HTML node including elements, attributes, texts, etc.
* `EzXML.XMLError`: an error happened in libxml2
* `EzXML.StreamReader`: a streaming XML reader

IO:
* From file: `read(EzXML.Document, filename)`, `readxml(filename|stream)`, `readhtml(filename|stream)`
* From string or byte array: `parse(EzXML.Document, string)`, `parsexml(string)`, `parsehtml(string)`
* To file: `write(filename, doc)`
* To stream: `print(io, doc)`

Accessors:
* Node information: `nodetype(node)`, `nodepath(node)`, `nodename(node)`, `content(node)`, `setnodename!(node, name)`
* Document: `root(doc)`, `dtd(doc)`, `hasroot(doc)`, `hasdtd(doc)`, `setroot!(doc, element_node)`, `setdtd!(doc, dtd_node)`
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
* XPath: `find(doc|node, xpath)`, `findfirst(doc|node, xpath)`, `findlast(doc|node, xpath)`

Examples
--------

* [primates.jl](/example/primates.jl): Run "primates" example shown above.
* [julia2xml.jl](/example/julia2xml.jl): Convert a Julia expression to XML.
* [listlinks.jl](/example/listlinks.jl): List all links in an HTML document.
* [graphml.jl](/example/graphml.jl): Read a GraphML file with streaming reader.

Other XML/HTML packages in Julia
--------------------------------

* [LightXML.jl](https://github.com/JuliaIO/LightXML.jl)
* [LibExpat.jl](https://github.com/amitmurthy/LibExpat.jl)

[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://bicycle1885.github.io/EzXML.jl/latest
[travisci-img]: https://travis-ci.org/bicycle1885/EzXML.jl.svg?branch=master
[travisci-url]: https://travis-ci.org/bicycle1885/EzXML.jl
[appveyor-img]: https://ci.appveyor.com/api/projects/status/n5d7o2mmy8ckdjc8?svg=true
[appveyor-url]: https://ci.appveyor.com/project/bicycle1885/ezxml-jl
[codecov-img]: http://codecov.io/github/bicycle1885/EzXML.jl/coverage.svg?branch=master
[codecov-url]: http://codecov.io/github/bicycle1885/EzXML.jl?branch=master
