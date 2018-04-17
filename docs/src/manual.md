Manual
======

This page is dedicated to those who are new to EzXML.jl. It is recommended to
read this page before reading other pages to grasp the concepts of the package
first. Once you have read it, [the reference page](reference.md) would be a
better place to find necessary functions. [The developer notes
page](devnotes.md) is for developers and most users do not need to read it.

In this manual, we use `using EzXML` for the sake of brevity.  However, it is
recommended to use `import EzXML` or something similar for long scripts or
packages because EzXML.jl exports a number of names to your environment. These
are useful in interactive sessions but easily conflict with other names. If you
want to see the list of exported names, please go to the top of src/EzXML.jl.

```@meta
# Ignore pointers.
DocTestFilters = r"@0x[0-9a-f]{16}"
# Load EzXML.jl
DocTestSetup = :(using EzXML)
```

Data types
----------

There are two types that constitute an XML document and its components:
`Document` and `Node`, respectively. The `Document` type represents a whole XML
document. A `Document` object points to the topmost node of the XML document,
but note that it is different from the root node you see in an XML file.  The
`Node` type represents almost everything in an XML document, that is, elements,
attributes, texts, CDATAs, comments, documents, etc. are all `Node` type
objects. These two type names are not exported from EzXML.jl because their names
are very general and easily conflict with names exported from other packages.
However, the user can expect them as public APIs and use them with the `EzXML.`
prefix.

A `Node` object can be separated into multiple types. As an example, let's see
the next XML document:

    <element attribute="attribute value">  Text  </element>
    ^        ^                             ^
    |        attribute node                text node
    element node

As you see, `<element>...</element>` is an element node, which may hold
attribute nodes and/or text nodes as children. These nodes are components of an
XML document.

Several constructors are provided to create documents and various kinds of
nodes.  For example, the `XMLDocument` constructor creates an XML document, the
`ElementNode` constructor does an element node, and the `TextNode` constructor
does a text node.  Calling the `show` method of `Node` shows a node type and a
pointer address to a node struct of libxml2 within the angle brackets, so that
you can quickly check the type of a node and its identity. The `print` method of
`Node` shows an XML tree rooted at the node. `prettyprint` is also provided to
print a formatted XML.  The `link!` function links two nodes:

```jldoctest
julia> using EzXML

julia> doc = XMLDocument()
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fa2ec190b70>))

julia> typeof(doc)
EzXML.Document

julia> typeof(doc.node)  # The document object has a document node.
EzXML.Node

julia> elm = ElementNode("element")
EzXML.Node(<ELEMENT_NODE@0x00007fcd5bd42920>)

julia> println(elm)  # The element node is still empty.
<element/>

julia> attr = AttributeNode("attribute", "attribute value")
EzXML.Node(<ATTRIBUTE_NODE@0x00007f91ca324570>)

julia> txt = TextNode("  Text  ")
EzXML.Node(<TEXT_NODE@0x00007fcd5be9aaf0>)

julia> typeof(elm), typeof(attr), typeof(txt)  # All nodes are the Node type.
(EzXML.Node, EzXML.Node, EzXML.Node)

julia> elm.type, attr.type, txt.type  # But their XML node types are different.
(ELEMENT_NODE, ATTRIBUTE_NODE, TEXT_NODE)

julia> link!(elm, attr)  # Link the element node with the attribute node.
EzXML.Node(<ATTRIBUTE_NODE@0x00007f91ca324570>)

julia> println(elm)  # The element node now has the attribute node.
<element attribute="attribute value"/>

julia> link!(elm, txt)  # Link the element node with the text node.
EzXML.Node(<TEXT_NODE@0x00007f91c7ebd430>)

julia> println(elm)  # The element node now has the text node.
<element attribute="attribute value">  Text  </element>

julia> link!(doc.node, elm)  # Link the document node with the element node.
EzXML.Node(<ELEMENT_NODE@0x00007fcd5bd42920>)

julia> print(doc)  # This is a complete XML document.
<?xml version="1.0" encoding="UTF-8"?>
<element attribute="attribute value">  Text  </element>

```

A `Node` object has some properties. The most important one would be the `type`
property, which we already saw in the example above. Other properties (`name`,
`path`, `content` and `namespace`) are demonstrated in the following example.
The value of a property will be `nothing` when there is no corresponding value.

```jldoctest
julia> elm = ElementNode("element")
EzXML.Node(<ELEMENT_NODE@0x00007f8cf18923b0>)

julia> elm.type
ELEMENT_NODE

julia> elm.name
"element"

julia> elm.path
"/element"

julia> elm.content
""

julia> elm.namespace === nothing
true

julia> txt = TextNode("  Text  ")
EzXML.Node(<TEXT_NODE@0x00007f8cf18c0940>)

julia> txt.type
TEXT_NODE

julia> txt.name
"text"

julia> txt.path
"/text()"

julia> txt.content
"  Text  "

```


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

`readxml(<filename>)` reads an XML file and builds a document object in memory.
On the other hand, `parsexml(<string or byte array>)` parses an XML string or a
byte array in memory and builds a document object like the `readxml` method:
```jldoctest dom
julia> doc = readxml("primates.xml")  # Read from a file.
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fff3cfe8a50>))

julia> data = String(read("primates.xml"));

julia> doc = parsexml(data)           # Parse a string.
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fff3d161380>))

```

Before traversing a document we need to retrieve the root of the document tree.
`root(<document>)` returns the root element of a document and we can start
traversal there:
```jldoctest dom
julia> primates = root(doc)  # Get the root element.
EzXML.Node(<ELEMENT_NODE@0x00007fff3d109ef0>)

julia> primates = doc.root   # The `root` property is also available.
EzXML.Node(<ELEMENT_NODE@0x00007fff3d109ef0>)

julia> nodetype(primates)    # The node is an element node.
ELEMENT_NODE

julia> nodename(primates)    # `nodename` returns the tag name of an element.
"primates"

julia> haselement(primates)  # Check if a node has one or more elements.
true

julia> genus = elements(primates)  # `elements` returns all child elements.
2-element Array{EzXML.Node,1}:
 EzXML.Node(<ELEMENT_NODE@0x00007fff3cff0000>)
 EzXML.Node(<ELEMENT_NODE@0x00007fff3cfbdf00>)

julia> nodename.(genus)      # Broadcasting syntax (dot function) works.
2-element Array{String,1}:
 "genus"
 "genus"

```

Attribute values can be accessed by its name like a dictionary; `haskey`,
`getindex`, `setindex!` and `delete!` are overloaded for element nodes.
Qualified name, which may or may not have the prefix of a namespace, can be used
as a key name:
```jldoctest dom
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

In this package, a `Node` object is regarded as a container of its child nodes.
This idea is reflected on function names; for example, a function returning the
first child node is named as `firstnode` instead of `firstchildnode`. All
functions provided by the `EzXML` module are named in this way and tree
traversal functions works on its child nodes by default. Functions with a
direction prefix works on that direction; for example, `nextnode` returns the
next sibling node and `parentnode` returns the parent node.

Distinction between nodes and elements is what every user should know about
before using DOM APIs.  There are good explanations on this topic:
<http://www.w3schools.com/xml/dom_nodes.asp>,
<http://stackoverflow.com/questions/132564/whats-the-difference-between-an-element-and-a-node-in-xml>.
Some functions have a suffix like `node` or `element` that indicates the node
type the function is interested in. For example, `hasnode(<parent node>)` checks
if a (parent) node has one or more child *nodes* while `haselement(<parent
node>)` checks if a (parent) node has one or more child *elements*. All
functions are also named in this way:
```jldoctest dom
julia> hasnode(primates)       # `primates` contains child nodes?
true

julia> haselement(primates)    # `primates` contains child elements?
true

julia> firstnode(primates)     # Get the first child node, which is a text node.
EzXML.Node(<TEXT_NODE@0x00007fff3cfe92f0>)

julia> lastnode(primates)      # Get the last child node, which is a text node, too.
EzXML.Node(<TEXT_NODE@0x00007fff3cfe4b60>)

julia> firstelement(primates)  # Get the first child element, which is apparently an element node.
EzXML.Node(<ELEMENT_NODE@0x00007fff3cff0000>)

julia> lastelement(primates)   # Get the last child element, which is apparently an element node, too.
EzXML.Node(<ELEMENT_NODE@0x00007fff3cfbdf00>)

```

There are tree traversal properties, which return `nothing` when there is no
correspoding node:

```jldoctest dom
julia> primates = doc.root
EzXML.Node(<ELEMENT_NODE@0x00007f8cf18bdb20>)

julia> primates.firstelement
EzXML.Node(<ELEMENT_NODE@0x00007f8cf18bff70>)

julia> primates.firstelement.nextelement === primates.lastelement
true

julia> primates.firstelement.prevelement === nothing
true

```

If you'd like to iterate over child nodes or elements, you can use the
`eachnode(<parent node>)` or `eachelement(<parent node>)` function.  The
`eachnode` function generates all nodes including texts, elements, comments, and
so on, while `eachelement` selects element nodes only. `nodes(<parent node>)`
and `elements(<parent node>)` are handy functions that return a vector of nodes
and elements, respectively:
```jldoctest dom
julia> for node in eachnode(primates)
           @show node
       end
node = EzXML.Node(<TEXT_NODE@0x00007fff3cfe92f0>)
node = EzXML.Node(<ELEMENT_NODE@0x00007fff3cff0000>)
node = EzXML.Node(<TEXT_NODE@0x00007fff3d10a090>)
node = EzXML.Node(<ELEMENT_NODE@0x00007fff3cfbdf00>)
node = EzXML.Node(<TEXT_NODE@0x00007fff3cfe4b60>)

julia> for elem in eachelement(primates)
           @show elem
       end
elem = EzXML.Node(<ELEMENT_NODE@0x00007fff3cff0000>)
elem = EzXML.Node(<ELEMENT_NODE@0x00007fff3cfbdf00>)

julia> nodes(primates)
5-element Array{EzXML.Node,1}:
 EzXML.Node(<TEXT_NODE@0x00007fff3cfe92f0>)
 EzXML.Node(<ELEMENT_NODE@0x00007fff3cff0000>)
 EzXML.Node(<TEXT_NODE@0x00007fff3d10a090>)
 EzXML.Node(<ELEMENT_NODE@0x00007fff3cfbdf00>)
 EzXML.Node(<TEXT_NODE@0x00007fff3cfe4b60>)

julia> elements(primates)
2-element Array{EzXML.Node,1}:
 EzXML.Node(<ELEMENT_NODE@0x00007fff3cff0000>)
 EzXML.Node(<ELEMENT_NODE@0x00007fff3cfbdf00>)

```

There are many functions to traverse XML document trees. The complete list of
these functions is available at [the reference page](reference.md).

Constructing documents
----------------------

ExXML.jl also supports constructing XML/HTML documents.

The components of an XML document can be created using document/node
constructors introduced above:
```jldoctest constr
julia> doc = XMLDocument()
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fe4b57bfbc0>))

julia> r = ElementNode("root")
EzXML.Node(<ELEMENT_NODE@0x00007fe4b581c5a0>)
```

Setting a root element to a document can be done by the `setroot!(<document>,
<root>)` function:
```jldoctest constr
julia> setroot!(doc, r)
EzXML.Node(<ELEMENT_NODE@0x00007fe4b581c5a0>)

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root/>

```

Other child elements or subtrees can be linked to an existing element using
`link!(<parent node>, <child node>)`:
```jldoctest constr
julia> c = ElementNode("child")
EzXML.Node(<ELEMENT_NODE@0x00007fe4b57de820>)

julia> link!(r, c)
EzXML.Node(<ELEMENT_NODE@0x00007fe4b57de820>)

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root><child/></root>

julia> setnodecontent!(c, "some content")
EzXML.Node(<ELEMENT_NODE@0x00007fe4b57de820>)

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root><child>some content</child></root>

julia> c = ElementNode("child")
EzXML.Node(<ELEMENT_NODE@0x00007fe4b5841f00>)

julia> link!(r, c)
EzXML.Node(<ELEMENT_NODE@0x00007fe4b5841f00>)

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root><child>some content</child><child/></root>

```

After finished building an XML document, the user can serialize it into a file
as follows:
```jldoctest constr
julia> write("out.xml", doc);  # Write a document into a file.

julia> print(String(read("out.xml")))
<?xml version="1.0" encoding="UTF-8"?>
<root><child>some content</child><child/></root>

```

An alternative way is using the `addelement!(<parent>, <child>, [<content>])`
function, which is a shorthand of a sequence of operations: `ElementNode(<child
name>)`, `link!(<parent>, <child>)`, and optional `setnodecontent!(<child>,
<content>)`. This is often handier in typical use:
```jldoctest
julia> doc = XMLDocument()
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fd0c682f460>))

julia> setroot!(doc, ElementNode("root"))
EzXML.Node(<ELEMENT_NODE@0x00007f9fe71c5d60>)

julia> for i in 1:3
           c = addelement!(root(doc), "child")
           c["id"] = string(i)
       end

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root><child id="1"/><child id="2"/><child id="3"/></root>

julia> addelement!(root(doc), "lastchild", "some content")
EzXML.Node(<ELEMENT_NODE@0x00007fd0c6ad7500>)

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root><child id="1"/><child id="2"/><child id="3"/><lastchild>some content</lastchild></root>

```

XPath queries
-------------

[XPath](https://en.wikipedia.org/wiki/XPath) is a query language for XML. The
user can retrieve target elements using a short string query. For example,
`"//genus/species"` selects all "species" elements just under a "genus" element.

The `findall`, `findfirst` and `findlast` functions are overloaded for XPath
query and return a vector of selected nodes:
```jldoctest xpath
julia> primates = readxml("primates.xml")
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fbeddc2a1d0>))

julia> findall("/primates", primates)  # Find the "primates" element just under the document
1-element Array{EzXML.Node,1}:
 EzXML.Node(<ELEMENT_NODE@0x00007fbeddc1e190>)

julia> findall("//genus", primates)
2-element Array{EzXML.Node,1}:
 EzXML.Node(<ELEMENT_NODE@0x00007fbeddc12c50>)
 EzXML.Node(<ELEMENT_NODE@0x00007fbeddc16ea0>)

julia> findfirst("//genus", primates)
EzXML.Node(<ELEMENT_NODE@0x00007fbeddc12c50>)

julia> findlast("//genus", primates)
EzXML.Node(<ELEMENT_NODE@0x00007fbeddc16ea0>)

julia> println(findfirst("//genus", primates))
<genus name="Homo">
        <species name="sapiens">Human</species>
    </genus>

```

If you would like to change the starting node of a query, you can pass the node
as the second argument of `find*`:
```jldoctest xpath
julia> genus = findfirst("//genus", primates)
EzXML.Node(<ELEMENT_NODE@0x00007fbeddc12c50>)

julia> println(genus)
<genus name="Homo">
        <species name="sapiens">Human</species>
    </genus>

julia> println(findfirst("species", genus))
<species name="sapiens">Human</species>

```

`find*(<xpath>, <node>)` automatically registers namespaces applied to `<node>`,
which means prefixes are available in the XPath query. This is especially useful
when an XML document is composed of elements originated from different
namespaces.

There is a caveat on the combination of XPath and namespaces: if a document
contains elements with a default namespace, you need to specify its prefix to
the `find*` function. For example, in the following example, the root element and
its descendants have a default namespace "http://www.foobar.org" but it does not
have its own prefix.  In this case, you need to pass its prefix to find elements
in the namespace:
```jldoctest
julia> doc = parsexml("""
       <parent xmlns="http://www.foobar.org">
           <child/>
       </parent>
       """)
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fdc67710030>))

julia> findall("/parent/child", root(doc))
0-element Array{EzXML.Node,1}

julia> namespaces(root(doc))  # The default namespace has an empty prefix.
1-element Array{Pair{String,String},1}:
 "" => "http://www.foobar.org"

julia> ns = namespace(root(doc))  # Get the namespace.
"http://www.foobar.org"

julia> findall("/x:parent/x:child", root(doc), ["x"=>ns])  # Specify its prefix as "x".
1-element Array{EzXML.Node,1}:
 EzXML.Node(<ELEMENT_NODE@0x00007fdc6774c990>)

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
`EzXML.StreamReader` object using the `open` function:
```jldoctest stream
julia> reader = open(EzXML.StreamReader, "undirected.graphml")
EzXML.StreamReader(<READER_NONE@0x00007f9fe8d67340>)

```

Iteration is advanced by the `done(<reader>)` method, which updates the current
reading position of the reader and returns `false` when there is at least one
node to read from the stream:
```jldoctest stream
julia> done(reader)  # Read the 1st node.
false

julia> nodetype(reader)
READER_ELEMENT

julia> nodename(reader)
"graphml"

julia> done(reader)  # Read the 2nd node.
false

julia> nodetype(reader)
READER_SIGNIFICANT_WHITESPACE

julia> nodename(reader)
"#text"

julia> done(reader)  # Read the 3rd node.
false

julia> nodetype(reader)
READER_ELEMENT

julia> nodename(reader)
"graph"

julia> reader["edgedefault"]
"undirected"

```

Unlike DOM interfaces, methods are applied to a reader object. This is because
the streaming reader does not construct a DOM tree while reading and hence we
have no access to actual nodes of an XML document. Methods like `nodetype`,
`nodename`, `nodecontent`, `namespace` and `getindex` are overloaded for the
reader type.

An important thing to be noted is that while the value of `nodetype` for the XML
reader returns the current node type, the domain is slightly different from that
of `nodetype` for `Node`, but slightly different meanings. For example, there
are two kinds of values that will be returned when reading an element node:
`READER_ELEMENT` and `READER_END_ELEMENT`. The former
indicates the reader just read an opening tag of an element node while the
latter does the reader just read an ending tag of an element node.

In addition to these functions, there are several functions that are specific to
the streaming reader. The `nodedepth(<reader>)` function returns the depth of
the current node. The `expandtree(<reader>)` function expands the current node
into a complete subtree rooted at the node. This function is useful when you
want to use the DOM interfaces for the node. However, the expanded subtree is
alive until the next read of a new node. That means you cannot keep references
to (parts of) the expanded subtree.

An idiomatic way of stream reading would look like this:
```julia
reader = open(EzXML.StreamReader, "undirected.graphml")
while !done(reader)
    typ = nodetype(reader)
    # body
end
close(reader)
```

Alternatively, EzXML.jl supports `for` loop, too:
```julia
reader = open(EzXML.StreamReader, "undirected.graphml")
for typ in reader
    # body
end
close(reader)
```
