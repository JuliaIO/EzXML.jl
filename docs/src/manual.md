Manual
======

This page is dedicated to those who are new to EzXML.jl. It is recommended to
read this page before reading other pages to grasp the concepts of the package
first. Once you have read it, [the reference page](reference.md) would be a
better place to find necessary functions. [The developer notes
page](devnotes.md) is for developers and most users do not need to read it.

In this manual, we use `using EzXML` to load the package for brevity.  However,
it is recommended to use `import EzXML` or something similar for non-trivial
scripts or packages because EzXML.jl exports a number of names to your
environment. These are useful in an interactive session but easily conflict
with other names. If you would like to know the list of exported names, please
go to the top of src/EzXML.jl, where you will see a long list of type and
function names.

EzXML.jl is built on top of [libxml2](http://xmlsoft.org/), a portable C library
compliant to the XML standard. If you are no familiar with XML itself, the
following links offer good resources to learn the basic concents of XML:
- [XML Tutorial](https://www.w3schools.com/xml/default.asp)
- [XML Tree](https://www.w3schools.com/xml/xml_tree.asp)
- [XML XPath](https://www.w3schools.com/xml/xml_xpath.asp)

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
`Node` type represents almost everything in an XML document; elements,
attributes, texts, CDATAs, comments, documents, etc. are all `Node` type
objects. These two type names are not exported from EzXML.jl because their names
are very general and easily conflict with other names exported from other
packages.  However, the user can expect them as public APIs and use them with
the `EzXML.` prefix.

Here is an example to create an empty XML document using the `XMLDocument`
constructor:
```jldoctest doc
julia> using EzXML

julia> doc = XMLDocument()
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fd9f1f14370>))

julia> typeof(doc)
EzXML.Document

julia> doc.node
EzXML.Node(<DOCUMENT_NODE@0x00007fd9f1f14370>)

julia> typeof(doc.node)
EzXML.Node

julia> print(doc)  # print an XML-formatted text
<?xml version="1.0" encoding="UTF-8"?>

```

The text just before the `@` sign shows the node type (in this example,
`DOCUMENT_NODE`), and the text just after `@` shows the pointer address
(`0x00007fd9f1f14370`) to a node struct of libxml2.

Let's add a root node to the document and a text node to the root node:
```jldoctest doc
julia> elm = ElementNode("root")  # create an element node
EzXML.Node(<ELEMENT_NODE@0x00007fd9f2a1b5f0>)

julia> setroot!(doc, elm)
EzXML.Node(<ELEMENT_NODE@0x00007fd9f2a1b5f0>)

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root/>

julia> txt = TextNode("some text")  # create a text node
EzXML.Node(<TEXT_NODE@0x00007fd9f2a81ee0>)

julia> link!(elm, txt)
EzXML.Node(<TEXT_NODE@0x00007fd9f2a81ee0>)

julia> print(doc)
<?xml version="1.0" encoding="UTF-8"?>
<root>some text</root>

```

Finally you can write the document object to a file using the `write` function:
```jldoctest doc
julia> write("out.xml", doc)
62

julia> print(String(read("out.xml")))
<?xml version="1.0" encoding="UTF-8"?>
<root>some text</root>

```

A `Node` object has some properties. The most important one would be the `type`
property, which we already saw in the example above. Other properties (`name`,
`path`, `content` and `namespace`) are demonstrated in the following example.
The value of a property will be `nothing` when there is no corresponding value.

```jldoctest
julia> elm = ElementNode("element")
EzXML.Node(<ELEMENT_NODE@0x00007fd9f44122f0>)

julia> println(elm)
<element/>

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

julia> txt = TextNode("  text  ")
EzXML.Node(<TEXT_NODE@0x00007fd9f441f3f0>)

julia> println(txt)
  text

julia> txt.type
TEXT_NODE

julia> txt.name
"text"

julia> txt.path
"/text()"

julia> txt.content
"  text  "

```

`addelement!(<parent>, <child>, [<content>])` is handy when you want to add a
child element to an existing node:
```jldoctest
julia> user = ElementNode("User")
EzXML.Node(<ELEMENT_NODE@0x00007fd9f427c510>)

julia> println(user)
<User/>

julia> addelement!(user, "id", "167492")
EzXML.Node(<ELEMENT_NODE@0x00007fd9f41ad580>)

julia> println(user)
<User><id>167492</id></User>

julia> addelement!(user, "name", "Kumiko Oumae")
EzXML.Node(<ELEMENT_NODE@0x00007fd9f42942d0>)

julia> println(user)
<User><id>167492</id><name>Kumiko Oumae</name></User>

julia> prettyprint(user)
<User>
  <id>167492</id>
  <name>Kumiko Oumae</name>
</User>
```

On Julia 0.6, these properties can be accessed via accessor functions:
```jldoctest
julia> elm = ElementNode("element")
EzXML.Node(<ELEMENT_NODE@0x00007fd9f41acbc0>)

julia> nodetype(elm)
ELEMENT_NODE

julia> nodename(elm)
"element"

julia> nodepath(elm)
"/element"

julia> nodecontent(elm)
""

julia> println(elm)
<element/>

julia> setnodecontent!(elm, "content")
EzXML.Node(<ELEMENT_NODE@0x00007fd9f41acbc0>)

julia> println(elm)
<element>content</element>

```


DOM interfaces
--------------

DOM (Document Object Model) interfaces regard an XML document as a tree of
nodes. There is a root node at the top of a document tree and each node has zero
or more child nodes. Some nodes (e.g. texts, attributes, etc.) cannot have child
nodes.

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
Likewise, `parsexml(<string or byte array>)` parses an XML string or a byte
array in memory and builds a document object:
```jldoctest dom
julia> doc = readxml("primates.xml")
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fd9f410a5f0>))

julia> data = String(read("primates.xml"));

julia> doc = parsexml(data)
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fd9f4051f80>))

```

Before traversing a document we need to get the root of the document tree.
The `.root` property returns the root element (if any) of a document:
```jldoctest dom
julia> primates = doc.root  # get the root element
EzXML.Node(<ELEMENT_NODE@0x00007fd9f4086880>)

julia> root(doc)  # on Julia 0.6
EzXML.Node(<ELEMENT_NODE@0x00007fd9f4086880>)

julia> genus = elements(primates)  # `elements` returns all child elements.
2-element Array{EzXML.Node,1}:
 EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)
 EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)

julia> genus[1].type, genus[1].name
(ELEMENT_NODE, "genus")

julia> genus[2].type, genus[2].name
(ELEMENT_NODE, "genus")

```

Attribute values can be accessed by its name like a dictionary; `haskey`,
`getindex`, `setindex!` and `delete!` are overloaded for element nodes.
Qualified name, which may or may not have the prefix of a namespace, can be used
as a key name:
```jldoctest dom
julia> haskey(genus[1], "name")  # check whether an attribute exists
true

julia> genus[1]["name"]  # get a value as a string
"Homo"

julia> genus[2]["name"]  # same above
"Pan"

julia> println(genus[1])  # print a "genus" element before updating
<genus name="Homo">
        <species name="sapiens">Human</species>
    </genus>

julia> genus[1]["taxonID"] = "9206"  # insert a new attribute
"9206"

julia> println(genus[1])  # the "genus" element has been updated
<genus name="Homo" taxonID="9206">
        <species name="sapiens">Human</species>
    </genus>

```

In this package, a `Node` object is regarded as a container of its child nodes.
This idea is reflected on its property and function names; for example, a
property returning the first child node is named as `.firstnode` instead of
`.firstchildnode`. All properties and functions provided by the `EzXML` module
are named in this way, and the tree traversal API of a node works on its child
nodes by default. Properties (functions) with a direction prefix work on that
direction; for example, `.nextnode` returns the next sibling node and
`.parentnode` returns the parent node.

Distinction between nodes and elements is what every user should know about
before using the DOM API.  There are good explanations on this topic:
<http://www.w3schools.com/xml/dom_nodes.asp>,
<http://stackoverflow.com/questions/132564/whats-the-difference-between-an-element-and-a-node-in-xml>.
Some properties (functions) have a suffix like `node` or `element` that
indicate a node type the property (function) is interested in. For example,
`.firstnode` returns the first child node (if any), which may be a text node,
but `.firstelement` always returns the first element node (if any):
```jldoctest dom
julia> primates.firstnode
EzXML.Node(<TEXT_NODE@0x00007fd9f409f200>)

julia> primates.firstelement
EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)

julia> primates.firstelement == genus[1]
true

julia> primates.lastnode
EzXML.Node(<TEXT_NODE@0x00007fd9f404bec0>)

julia> primates.lastelement
EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)

julia> primates.lastelement === genus[2]
true

```

Tree traversal properties return `nothing` when there is no corresponding node:
```jldoctest dom
julia> primates.firstelement.nextelement === primates.lastelement
true

julia> primates.firstelement.prevelement === nothing
true

```

Here is the list of tree traversal properties:
- The `Document` type:
    - `.root`
    - `.dtd`
- The `Node` type:
    - `.document`
    - `.parentnode`
    - `.parentelement`
    - `.firstnode`
    - `.firstelement`
    - `.lastelement`
    - `.lastnode`
    - `.nextnode`
    - `.nextelement`
    - `.nextnode`
    - `.prevnode`

If you would like to iterate over child nodes or elements, you can use the
`eachnode(<parent node>)` or the `eachelement(<parent node>)` function.  The
`eachnode` function generates all nodes including texts, elements, comments, and
so on, while `eachelement` selects only element nodes. `nodes(<parent node>)`
and `elements(<parent node>)` are handy functions that return a vector of nodes
and elements, respectively:
```jldoctest dom
julia> for node in eachnode(primates)
           @show node
       end
node = EzXML.Node(<TEXT_NODE@0x00007fd9f409f200>)
node = EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)
node = EzXML.Node(<TEXT_NODE@0x00007fd9f4060f70>)
node = EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)
node = EzXML.Node(<TEXT_NODE@0x00007fd9f404bec0>)

julia> for node in eachelement(primates)
           @show node
       end
node = EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)
node = EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)

julia> nodes(primates)
5-element Array{EzXML.Node,1}:
 EzXML.Node(<TEXT_NODE@0x00007fd9f409f200>)
 EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)
 EzXML.Node(<TEXT_NODE@0x00007fd9f4060f70>)
 EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)
 EzXML.Node(<TEXT_NODE@0x00007fd9f404bec0>)

julia> elements(primates)
2-element Array{EzXML.Node,1}:
 EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)
 EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)

```

XPath queries
-------------

[XPath](https://en.wikipedia.org/wiki/XPath) is a query language for XML. You
can retrieve target elements using a short string query. For example,
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
