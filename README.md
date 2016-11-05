<p align="center"><img src="/docs/EzXML.jl.png" alt="EzXML.jl Logo" width="250" /></p>

# EzXML.jl - XML/HTML tools for primates

[![Build Status](https://travis-ci.org/bicycle1885/EzXML.jl.svg?branch=master)](https://travis-ci.org/bicycle1885/EzXML.jl)
[![codecov.io](http://codecov.io/github/bicycle1885/EzXML.jl/coverage.svg?branch=master)](http://codecov.io/github/bicycle1885/EzXML.jl?branch=master)
<!-- [![Coverage Status](https://coveralls.io/repos/bicycle1885/EzXML.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/bicycle1885/EzXML.jl?branch=master) -->


**Still alpha-quality package.**

EzXML.jl is a package to handle XML/HTML documents for primates.

The main features are:
* Reading and writing XML/HTML documents.
* Traversing XML/HTML trees with DOM interfaces.
* Searching elements using XPath.
* Proper namespace handling.
* Capturing error messages.
* Automatic memory management.

In addition, reading extremely large files will be supported.

```julia
using EzXML

# Parse an XML string
# (use `read(Document, <filename>)` to read a document from a file).
doc = parse(EzXML.Document, """
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
for genus in each_element(primates)
    # Get an attribute value by name.
    genus_name = genus["name"]
    println("- ", genus_name)
    for species in each_element(genus)
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


## Core concepts

The main types exported from this package are `Document` and `Node`.  `Document`
represents an entire XML/HTML document and `Node` are components of it.  Everything
in an XML/HTML tree is a `Node` object: document, element, text, attribute, comments,
and so on. A document object of `Document` type is a thin wrapper to a document
node of `Node` type. This design leads to simplicity of interfaces because
tree-traversal functions always return `Node` objects. In addition, the type
stability of this design may enable the Julia compiler to generate faster code.

In this package, a `Node` object is regarded as a container of its child nodes.
This idea is reflected on function names; for example, a function returning the
first child node is named as `first_node` instead of `first_child_node` because
it is apparent that we are interested in **child** nodes. If the user is
interested in a special type of nodes like element nodes, functions like
`first_element` are provided.

Internally, a `Node` object is a proxy object to a node-like struct allocated by
the libxml2 library. Additionally, a node-like struct also has a pointer to
Julia's `Node` object, which enables to extract a unique proxy object from C's
struct. Therefore, two `Node` objects pointing to the same node in an XML/HTML
document are identical even if they are generated from different ways. A `Node`
object also keeps an owner node that is responsible for releasing memories of
nodes.


## Quick reference

Types:
* `Document`: an XML/HTML document
* `Node`: an XML/HTML node including elements, attributes, texts, etc.
* `XMLError`: an error happened in libxml2

IO:
* `read(Document, filename)`: read an XML/HTML document from a file.
* `readxml(filename)`: read an XML document from file.
* `readhtml(filename)`: read an HTML document from file.
* `write(filename, doc)`: write a document to a file.
* `parse(Document, string)`: parse an XML/HTML string.
* `parsexml(string)`: parse an XML string.
* `parsehtml(string)`: parse an HTML string.
* `print(io, doc)`: print a document.

Accessors:
* Node information:
    * `nodetype(node)`: return the type of a node.
    * `name(node)`: return the name of a node.
    * `content(node)`: return the content of a node.
    * `document(node)`: return the document of a node.
* Attributes:
    * `node[name]`: return an attribute value of a node by name.
    * `node[name] = value`: set a value to an attribute of a node.
    * `haskey(node, name)`: return if a node has an attribute name.
    * `delete!(node, name)`: delete an attribute of a node.
* Tree traversal:
    * `root(doc)`: return the root element of a document.
    * `first_node(node)`: return the first child node of a node.
    * `last_node(node)`: return the last child node of a node.
    * `first_element(node)`: return the first child element of a node.
    * `last_element(node)`: return the last child element of a node.
    * `next_node(node)`: return the next node of a node.
    * `prev_node(node)`: return the previous node of a node.
    * `next_element(node)`: return the next element of a node.
    * `prev_element(node)`: return the previous element of a node.
    * `parent_node(node)`: return the parent node of a node.
    * `parent_element(node)`: return the parent element of a node.
* Node predicate:
    * `has_root(doc)`: return if a document has a root element.
    * `has_node(node)`: return if a node has a child node.
    * `has_element(node)`: return if a node has a child element.
    * `has_next_node(node)`: return if a node has a next node.
    * `has_prev_node(node)`: return if a node has a previous node.
    * `has_next_element(node)`: return if a node has a next element.
    * `has_prev_element(node)`: return if a node has a previous element.
    * `has_parent_node(node)`: return if a node has a parent node.
    * `has_parent_element(node)`: return if a node has a parent element.
* Iterators:
    * `each_node(node)`: create an iterator over child nodes.
    * `each_element(node)`: create an iterator over child elements.
    * `each_attribute(node)`: create an iterator over attribute nodes.
    * `nodes(node)`: create a vector of child nodes.
    * `elements(node)`: create a vector of child elements.
    * `attributes(node)`: create a vector of attribute nodes.
* Counters:
    * `count_nodes(node)`: count the number of child nodes.
    * `count_elements(node)`: count the number of child elements.
    * `count_attributes(node)`: count the number of attributes.
* Namespaces:
    * `namespace(node)`: return the namespace of a node.
    * `namespaces(node)`: create a vector of namespaces applying to a node.

Constructors:
* `XMLDocument(version="1.0")`: create an XML document.
* `HTMLDocument()`: create an HTML document.
* `ElementNode(name)`: create an element node.
* `TextNode(content)`: create a text node.
* `CommentNode(content)`: create a comment node.
* `CDataNode(content)`: create a CDATA node.
* `XMLDocumentNode(version="1.0")`: create an XML document node.
* `HTMLDocumentNode()`: create an HTML document node.

Modifiers:
* `add_node!(parent_node, child_node)`: add a child node to a parent node.
* `add_element!(parent_node, name, content="")`: add a child element with content to a parent node.
* `add_next_sibling!(target_node, node)`: add a node next to a target node.
* `add_prev_sibling!(target_node, node)`: add a node previous to a target node.
* `unlink_node!(node)`: Unlink a node from its context (parent and siblings).

Queries:
* `find(doc|node, xpath)`: find all nodes that match an XPath query.
* `findfirst(doc|node, xpath)`: find the first matching node.
* `findlast(doc|node, xpath)`: find the last matching node.


## Examples

* [primates.jl](/example/primates.jl): "primates" example shown above.
* [julia2xml.jl](/example/julia2xml.jl): convert a Julia expression to XML.
* [issues.jl](/example/issues.jl): list latest issues of the Julia repository.


## Other XML/HTML packages in Julia.

* [LightXML.jl](https://github.com/JuliaIO/LightXML.jl)
* [LibExpat.jl](https://github.com/amitmurthy/LibExpat.jl)
