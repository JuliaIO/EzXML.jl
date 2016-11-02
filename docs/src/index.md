# EzXML.jl

EzXML.jl is a package to handle XML/HTML documents with no hassle. Only two
types (plus an exception type) are exported from the module: `Document` and
`Node`. `Document` is a whole document that contains an XML tree, and `Node` is
a node of the tree. Elements, texts, comments, attributes and even documents can
be regarded as `Node` objects. This design is based on that of libxml2; in fact
a `Node` object is a proxy object to a node structure of libxml2.

XML trees will be automatically freed by Julia's garbage collector if all of the
nodes are unreachable. This is achieved by `finalizer` mechanism and object
references from node objects to its owner object that is responsible for
releasing their memories.


```@autodocs
Modules = [EzXML]
```
