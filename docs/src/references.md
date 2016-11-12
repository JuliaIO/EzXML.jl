References
==========

Types
-----

```@docs
Document
Node
```

I/O
---

```@docs
parsexml
parsehtml
readxml
readhtml
prettyprint
```

Constructors
------------

```@docs
XMLDocument
HTMLDocument
XMLDocumentNode
HTMLDocumentNode
ElementNode
TextNode
CommentNode
CDataNode
AttributeNode
```

Node accessors
--------------

```@docs
nodetype(::Node)
name(::Node)
content(::Node)
namespace(::Node)
namespaces(::Node)
iselement(::Node)
isattribute(::Node)
EzXML.istext(::Node)
iscdata(::Node)
iscomment(::Node)
countnodes(::Node)
countelements(::Node)
countattributes(::Node)
```

Node modifiers
--------------

```@docs
setname!(::Node, ::AbstractString)
setcontent!(::Node, ::AbstractString)
```

DOM tree accessors
------------------

```@docs
document
root
parentnode
firstnode
lastnode
firstelement
lastelement
nextnode
prevnode
nextelement
prevelement
eachnode
nodes
eachelement
elements
eachattribute
attributes
```

DOM tree modifiers
------------------

```@docs
setroot!
link!
linknext!
linkprev!
unlink!
addelement!
```

XPath query
-----------

```@docs
find(doc::Document, xpath::AbstractString)
findfirst(doc::Document, xpath::AbstractString)
findlast(doc::Document, xpath::AbstractString)
find(node::Node, xpath::AbstractString)
findfirst(node::Node, xpath::AbstractString)
findlast(node::Node, xpath::AbstractString)
```

Streaming reader
----------------

```@docs
depth(::XMLReader)
expandtree(::XMLReader)
nodetype(::XMLReader)
name(::XMLReader)
content(::XMLReader)
namespace(::XMLReader)
```
