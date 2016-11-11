References
==========

Constructors
------------

```@docs
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

DOM accessors
-------------

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

Linking and unlinking functions
-------------------------------

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
