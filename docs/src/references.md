References
==========

```@meta
CurrentModule = EzXML
```

Types
-----

```@docs
EzXML.Document
EzXML.Node
EzXML.StreamReader
EzXML.XMLError
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
DTDNode
```

Node types
----------

| Node type                  | Integer |
| -------------------------- | ------- |
| `EzXML.ELEMENT_NODE`       | 1       |
| `EzXML.ATTRIBUTE_NODE`     | 2       |
| `EzXML.TEXT_NODE`          | 3       |
| `EzXML.CDATA_SECTION_NODE` | 4       |
| `EzXML.ENTITY_REF_NODE`    | 5       |
| `EzXML.ENTITY_NODE`        | 6       |
| `EzXML.PI_NODE`            | 7       |
| `EzXML.COMMENT_NODE`       | 8       |
| `EzXML.DOCUMENT_NODE`      | 9       |
| `EzXML.DOCUMENT_TYPE_NODE` | 10      |
| `EzXML.DOCUMENT_FRAG_NODE` | 11      |
| `EzXML.NOTATION_NODE`      | 12      |
| `EzXML.HTML_DOCUMENT_NODE` | 13      |
| `EzXML.DTD_NODE`           | 14      |
| `EzXML.ELEMENT_DECL`       | 15      |
| `EzXML.ATTRIBUTE_DECL`     | 16      |
| `EzXML.ENTITY_DECL`        | 17      |
| `EzXML.NAMESPACE_DECL`     | 18      |
| `EzXML.XINCLUDE_START`     | 19      |
| `EzXML.XINCLUDE_END`       | 20      |
| `EzXML.DOCB_DOCUMENT_NODE` | 21      |

Node accessors
--------------

```@docs
nodetype(::Node)
nodepath(::Node)
nodename(::Node)
nodecontent(::Node)
namespace(::Node)
namespaces(::Node)
iselement(::Node)
isattribute(::Node)
istext(::Node)
iscdata(::Node)
iscomment(::Node)
isdtd(::Node)
countnodes(::Node)
countelements(::Node)
countattributes(::Node)
systemID(::Node)
externalID(::Node)
```

Node modifiers
--------------

```@docs
setnodename!(::Node, ::AbstractString)
setnodecontent!(::Node, ::AbstractString)
```

DOM tree accessors
------------------

```@docs
document
root
dtd
parentnode
parentelement
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
hasroot
hasdtd
hasnode
hasnextnode
hasprevnode
haselement
hasnextelement
hasprevelement
hasdocument
hasparentnode
hasparentelement
```

DOM tree modifiers
------------------

```@docs
setroot!
setdtd!
link!
linknext!
linkprev!
unlink!
addelement!
```

XPath query
-----------

```@docs
findall(xpath::AbstractString, doc::Document)
findfirst(xpath::AbstractString, doc::Document)
findlast(xpath::AbstractString, doc::Document)
findall(xpath::AbstractString, node::Node)
findfirst(xpath::AbstractString, node::Node)
findlast(xpath::AbstractString, node::Node)
```

Validation
----------

```@docs
validate
readdtd
```

Reader node types
-----------------

| Node type                             | Integer |
| ------------------------------------- | ------- |
| `EzXML.READER_NONE`                   | 0       |
| `EzXML.READER_ELEMENT`                | 1       |
| `EzXML.READER_ATTRIBUTE`              | 2       |
| `EzXML.READER_TEXT`                   | 3       |
| `EzXML.READER_CDATA`                  | 4       |
| `EzXML.READER_ENTITY_REFERENCE`       | 5       |
| `EzXML.READER_ENTITY`                 | 6       |
| `EzXML.READER_PROCESSING_INSTRUCTION` | 7       |
| `EzXML.READER_COMMENT`                | 8       |
| `EzXML.READER_DOCUMENT`               | 9       |
| `EzXML.READER_DOCUMENT_TYPE`          | 10      |
| `EzXML.READER_DOCUMENT_FRAGMENT`      | 11      |
| `EzXML.READER_NOTATION`               | 12      |
| `EzXML.READER_WHITESPACE`             | 13      |
| `EzXML.READER_SIGNIFICANT_WHITESPACE` | 14      |
| `EzXML.READER_END_ELEMENT`            | 15      |
| `EzXML.READER_END_ENTITY`             | 16      |
| `EzXML.READER_XML_DECLARATION`        | 17      |

Streaming reader
----------------

```@docs
expandtree(::StreamReader)
nodetype(::StreamReader)
nodename(::StreamReader)
nodecontent(::StreamReader)
nodedepth(::StreamReader)
namespace(::StreamReader)
```
