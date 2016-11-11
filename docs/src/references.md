References
==========

Types
-----

```@docs
Document
Node
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

I/O
---

```@docs
parsexml
parsehtml
readxml
readhtml
prettyprint
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
name
content
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
setname!
setcontent!
link!
linknext!
linkprev!
unlink!
addelement!
```
