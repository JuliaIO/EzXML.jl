Manual
======

EzXML.jl is a package for handling XML and HTML documents. The APIs are simple
and support various functionalities including:
* Traversing XML/HTML documents with
  [DOM](https://en.wikipedia.org/wiki/Document_Object_Model)-like interfaces.
* Searching elements using [XPath](https://en.wikipedia.org/wiki/XPath).
* Handling [XML namespaces](https://en.wikipedia.org/wiki/XML_namespace).
* Parsing with [streaming APIs](http://xmlsoft.org/xmlreader.html).
* Automatic memory management.

Here is an example of parsing and traversing an XML document:
```julia
using EzXML

# Parse an XML string
# (use `read(Document, <filename>)` to read a document from a file).
doc = parse(Document, """
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

Data types
----------

There are two types that constitute an XML document and components: `Document`
and `Node`, respectively. The `Document` type represents a whole XML document
and points to a document node of `Node` type. The `Node` type represents almost
everything in an XML document, that is, elements, attributes, texts, CDATAs,
comments, documents, etc. are all `Node` type objects.

Several kinds of constructors are provided to create documents and various node
types. For example, `XMLDocument` creates an XML document, `ElementNode` does an
element node, and `TextNode` does a text node:
```jlcon
julia> using EzXML

julia> doc = XMLDocument()
EzXML.Document(EzXML.Node(<XML_DOCUMENT_NODE@0x00007fa2ec190b70>))

julia> typeof(doc)
EzXML.Document

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>

julia> elm = ElementNode("elm")
EzXML.Node(<XML_ELEMENT_NODE@0x00007fcd5bd42920>)

julia> typeof(elm)
EzXML.Node

julia> println(elm)
<elm/>

julia> txt = TextNode("some text")
EzXML.Node(<XML_TEXT_NODE@0x00007fcd5be9aaf0>)

julia> typeof(txt)
EzXML.Node

julia> println(txt)
some text

```

Calling the `show` method of `Node` shows a node type and a pointer address to a
node struct of libxml2 within the angle brackets so that you can quickly check
the type of a node and its identity. The `print` method of `Node` shows an XML
tree rooted at the node. `prettyprint` is also provided to print formatted XML.

DOM interfaces
--------------

DOM interfaces regard an XML document as a tree of nodes. There is a root node
at the top of a document tree and each node has zero or more child nodes. Some
nodes (e.g. texts, attributes, etc.) cannot have child nodes.

For the demonstration purpose, save the next XML in "primates.xml" file.

    <?xml version="1.0" encoding="UTF-8"?>
    <primates>
        <genus name="Homo">
            <species name="sapiens">Human</species>
        </genus>
        <genus name="Pan">
            <species name="paniscus">Bonobo</species>
            <species name="troglodytes">Chimpanzee</species>
        </genus>
    </primates>

`read(Document, <filename>)` reads an XML file and builds a document object in
memory.  On the other hand `parse(Document, <string or byte array>)` parses an
XML string or a byte array and builds a document object like the `read` method:
```jlcon
julia> doc = read(Document, "primates.xml")
EzXML.Document(EzXML.Node(<XML_DOCUMENT_NODE@0x00007fff3cfe8a50>))

julia> data = readstring("primates.xml");

julia> doc = parse(Document, data)
EzXML.Document(EzXML.Node(<XML_DOCUMENT_NODE@0x00007fff3d161380>))

```

Before traversing the document we need to retrieve the root of the document tree. 
`root(<document>)` returns the root element of a document and we can start
traversal there:
```jlcon
julia> primates = root(doc)  # Get the root element.
EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3d109ef0>)

julia> nodetype(primates)    # The node is an element node.
XML_ELEMENT_NODE

julia> name(primates)        # `name` returns the tag name of an element.
"primates"

julia> haselement(primates)  # Check if a node has one or more elements.
true

julia> genus = elements(primates)  # `elements` returns all child elements.
2-element Array{EzXML.Node,1}:
 EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cff0000>)
 EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cfbdf00>)

julia> name.(genus)          # Broadcasting syntax (dot function) works.
2-element Array{String,1}:
 "genus"
 "genus"

```

Attribute values can be accessed by its name like a dictionary; `haskey`,
`getindex`, `setindex!` and `delete!` are overloaded for element nodes.
Qualified name, which may or may not have the prefix of a namespace, can be used
as a key name:
```jlcon
julia> haskey(genus[1], "name")  # Check whether an attribute exists.
true

julia> genus[1]["name"]          # Get a value as a string.
"Homo"

julia> genus[2]["name"]          # Same above.
"Pan"

julia> println(genus[1])             # Print a "genus" element before updating.
<genus name="Homo">
        <species name="sapiens">Human</species>
    </genus>

julia> genus[1]["taxonID"] = "9206"  # Insert a new attribute.
"9206"

julia> println(genus[1])             # The "genus" element has been updated.
<genus name="Homo" taxonID="9206">
        <species name="sapiens">Human</species>
    </genus>

```

Distinction between nodes and elements is what every user should know about
before using DOM APIs.  There are good explanations on this topic:
<http://www.w3schools.com/xml/dom_nodes.asp>,
<http://stackoverflow.com/questions/132564/whats-the-difference-between-an-element-and-a-node-in-xml>.
Once you get it, tree traversal functions of EzXML.jl must be quite natural to
you. For example, `hasnode(<parent node>)` checks if a (parent) node has one or
more child *nodes* while `haselement(<parent node>)` checks if a (parent) node
has one or more child *elements*. All functions are also named in this way:
```jlcon
julia> hasnode(primates)       # `primates` contains child nodes?
true

julia> haselement(primates)    # `primates` contains child elements?
true

julia> firstnode(primates)     # Get the first child node, which is a text node.
EzXML.Node(<XML_TEXT_NODE@0x00007fff3cfe92f0>)

julia> lastnode(primates)      # Get the last child node, which is a text node, too.
EzXML.Node(<XML_TEXT_NODE@0x00007fff3cfe4b60>)

julia> firstelement(primates)  # Get the first child element, which is apparently an element node.
EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cff0000>)

julia> lastelement(primates)   # Get the last child element, which is apparently an element node, too.
EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cfbdf00>)

```

If you'd like to iterate over child nodes or elements, you can use the
`eachnode(<parent node>)` or `eachelement(<parent node>)` function.  The
`eachnode` function generates all nodes including texts, elements, comments, and
so on while `eachelement` selects element nodes only. `nodes(<parent node>)` and
`elements(<parent node>)` are handy functions that return a vector of nodes and
elements, respectively:
```jlcon
julia> for genus in eachnode(primates)
           @show genus
       end
genus = EzXML.Node(<XML_TEXT_NODE@0x00007fff3cfe92f0>)
genus = EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cff0000>)
genus = EzXML.Node(<XML_TEXT_NODE@0x00007fff3d10a090>)
genus = EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cfbdf00>)
genus = EzXML.Node(<XML_TEXT_NODE@0x00007fff3cfe4b60>)

julia> for genus in eachelement(primates)
           @show genus
       end
genus = EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cff0000>)
genus = EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cfbdf00>)

julia> nodes(primates)
5-element Array{EzXML.Node,1}:
 EzXML.Node(<XML_TEXT_NODE@0x00007fff3cfe92f0>)
 EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cff0000>)
 EzXML.Node(<XML_TEXT_NODE@0x00007fff3d10a090>)
 EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cfbdf00>)
 EzXML.Node(<XML_TEXT_NODE@0x00007fff3cfe4b60>)

julia> elements(primates)
2-element Array{EzXML.Node,1}:
 EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cff0000>)
 EzXML.Node(<XML_ELEMENT_NODE@0x00007fff3cfbdf00>)

```

There are so many functions to traverse XML document trees. The complete list of
these functions is available at the reference page.

Constructing documents
----------------------

ExXML.jl also supports constructing XML/HTML documents.

The components of an XML document can be created using document/node
constructors introduced above:
```jlcon
julia> doc = XMLDocument()
EzXML.Document(EzXML.Node(<XML_DOCUMENT_NODE@0x00007fe4b57bfbc0>))

julia> r = ElementNode("root")
EzXML.Node(<XML_ELEMENT_NODE@0x00007fe4b581c5a0>)
```

Setting a root element to a document can be done by the `setroot!(<document>,
<root>)` function:
```jlcon
julia> setroot!(doc, r)
EzXML.Document(EzXML.Node(<XML_DOCUMENT_NODE@0x00007fe4b57bfbc0>))

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root/>

```

Other child elements or subtrees can be linked to an existing element using
`link!(<parent node>, <child node>)`:
```jlcon
julia> c = ElementNode("child")
EzXML.Node(<XML_ELEMENT_NODE@0x00007fe4b57de820>)

julia> link!(r, c)
EzXML.Node(<XML_ELEMENT_NODE@0x00007fe4b57de820>)

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root><child/></root>

julia> setcontent!(c, "some content")
EzXML.Node(<XML_ELEMENT_NODE@0x00007fe4b57de820>)

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root><child>some content</child></root>

julia> c = ElementNode("child")
EzXML.Node(<XML_ELEMENT_NODE@0x00007fe4b5841f00>)

julia> link!(r, c)
EzXML.Node(<XML_ELEMENT_NODE@0x00007fe4b5841f00>)

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root><child>some content</child><child/></root>

```

After finished building an XML document, the user can serialize it into a file
as follows:
```jlcon
julia> write("out.xml", doc)  # Write a document into a file.
88

shell> cat out.xml
<?xml version="1.0" encoding="UTF-8"?>
<root><child>some content</child><child/></root>

```

Streaming interfaces
--------------------

In addition to DOM interfaces, EzXML.jl provides a streaming reader of XML
files. The streaming reader processes, as the name suggests, a stream of an XML
data read from a file instead of reading a whole XML tree into the memory. This
enables reading extremely large files that do not fit in RAM.

Let's use the following XML file (undirected.graphml) that represents an undirected graph formatted
in [GraphML](http://graphml.graphdrawing.org/) (slightly simplified for
brevity):

    <?xml version="1.0" encoding="UTF-8"?>
    <graphml>
        <graph edgedefault="undirected">
            <node id="n0"/>
            <node id="n1"/>
            <node id="n2"/>
            <node id="n3"/>
            <node id="n4"/>
            <edge source="n0" target="n2"/>
            <edge source="n1" target="n2"/>
            <edge source="n2" target="n3"/>
            <edge source="n3" target="n4"/>
        </graph>
    </graphml>

The interfaces of streaming reader are totally different from the DOM interfaces
introduced above. The first thing the user needs to do is creating an
`XMLReader` object using the `open` function:
```jlcon
julia> reader = open(XMLReader, "undirected.graphml")
EzXML.XMLReader(Ptr{EzXML._TextReader} @0x00007f95fb6c0b00)

```

Iteration is advanced by the `done(<reader>)` method, which updates the current
reading position of the reader and returns `false` when there is al least one
node to read from the stram:
```jlcon
julia> done(reader)  # Read the 1st node.
false

julia> nodetype(reader)
XML_READER_TYPE_ELEMENT

julia> name(reader)
"graphml"

julia> done(reader)  # Read the 2nd node.
false

julia> nodetype(reader)
XML_READER_TYPE_SIGNIFICANT_WHITESPACE

julia> name(reader)
"#text"

julia> done(reader)  # Read the 3rd node.
false

julia> nodetype(reader)
XML_READER_TYPE_ELEMENT

julia> name(reader)
"graph"

julia> reader["edgedefault"]
"undirected"

```

Unlike DOM interfaces, methods are applied to a reader object. This is because
the streaming reader does not construct a DOM tree while reading and hence we
have no access to actual nodes of an XML document. Methods like `nodetype`,
`name`, `content`, `namespace` and `getindex` are overloaded for the reader
type.

An important thing to be noted is that while the value of `nodetype` for the XML
reader returns the current node type, the domain is slightly different from that
of `nodetype` for `Node`, but slightly different meanings. For example, there
are two kinds of values that will be returned when reading an element node:
`XML_READER_TYPE_ELEMENT` and `XML_READER_TYPE_END_ELEMENT`. The former
indicates the reader just read an opening tag of an element node while the
latter does the reader just read an ending tag of an element node.

An idiomatic way of stream reading would look like this:
```julia
reader = open(Document, "undirected.graphml")
while !done(reader)
    typ = nodetype(reader)
    # body
end
close(reader)
```

Alternatively, EzXML.jl supports `for` loop, too:
```julia
reader = open(Document, "undirected.graphml")
for typ in reader
    # body
end
close(reader)
```
