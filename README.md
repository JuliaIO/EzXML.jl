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


## Quick reference

Types:
* `Document`: an XML document
* `Node`: an XML node including elements, attributes, texts, etc.

IO:
* `read(EzXML.Document, filename)`: read an XML document from a file.
* `write(filename, doc)`: write an XML document to a file.
* `parse(EzXML.Document, xml_string)`: parse an XML string.
* `print(io, doc)`: print an XML document.

Accessors:
* Node information:
    * `nodetype(node)`: return the type of a node.
    * `name(node)`: return the name of a node.
    * `content(node)`: return the content of a node.
    * `document(node)`: return the document of a node.
* Attributes:
    * `node[name]`: return an attribute value of a node by name.
    * `node[name] = value`: set a value to an attribute of a node.
    * `delete!(node, name)`: delete an attribute of a node.
* Tree traversal (prefixing `has_` check existence):
    * `root(doc)`: return the root node of a document.
    * `first_child_node(node)`: return the first child node of a node.
    * `last_child_node(node)`: return the last child node of a node.
    * `first_child_element(node)`: return the first child element of a node.
    * `last_child_element(node)`: return the last child element of a node.
    * `parent_node(node)`: return the parent node of a node.
    * `parent_element(node)`: return the parent element of a node.
* Iterators:
    * `each_node(node)`: create an iterator over child nodes.
    * `each_element(node)`: create an iterator over child elements.
    * `each_attribute(node)`: create an iterator over attributes (key-value pairs).
    * `child_nodes(node)`: create a vector of child nodes.
    * `child_elements(node)`: create a vector of child elements.
    * `attributes(node)`: create a vector of attributes.
* Counters:
    * `count_nodes(node)`: count the number of child nodes.
    * `count_elements(node)`: count the number of child elements.
    * `count_attributes(node)`: count the number of attributes.
* Namespaces:
    * `namespace(node)`: return the namespace of a node.
    * `namespaces(node)`: create a vector of namespaces applying to a node.

Constructors:
* `Document(version="1.0")`: create a document.
* `ElementNode(name)`: create an element node.
* `TextNode(content)`: create a text node.
* `CommentNode(content)`: create a comment node.
* `CDataNode(content)`: create a CDATA node.
* `DocumentNode(version="1.0")`: create a document node.

Queries:
* `find(doc|node, xpath)`: find all nodes that match an XPath query.
* `findfirst(doc|node, xpath)`: find the first matching node.
* `findlast(doc|node, xpath)`: find the last matching node.


## Examples

* [primates.jl](/example/primates.jl): "primates" example shown above.
* [julia2xml.jl](/example/julia2xml.jl): convert a Julia expression to XML.
* [issues.jl](/example/issues.jl): list latest issues of the Julia repository.
