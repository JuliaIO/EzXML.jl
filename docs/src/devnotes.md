Developer Notes
===============

This package is built on top of libxml2 and the design is significantly
influenced by it. The `Node` type is a proxy object that points to a C struct
allocated by libxml2. There are several node-like types in libxml2 that have
common fields to constitute an XML tree. These fields are always located at the
first fields of struct definitions, so we can safely use them by casting a
pointer to `_Node`. Especially, the first field, `_private`, is reserved for
applications and EzXML.jl uses it to store a pointer to a `Node` object. That
is, a `Node` object points to a node struct and the node struct keeps an
opposite pointer to the `Node` object. These bidirectional references are
especially important in this package.

When creating a `Node` object from a pointer, the constructor first checks
whether there is already a proxy object pointing to the same node. If it exists,
the constructor extracts the proxy object from the `_private` field and then
return it. Otherwise, it creates a new proxy object and stores a reference to
it in `_private`. As a result, proxy objects pointing to the same node in an
XML document are always unique and no duplication happens. This property is
fundamental to resource management.

A `Node` object has another field called `owner` that references another `Node`
object or the object itself. The owner node is responsible for freeing memory
resources of the node object allocated by libxml2. Freeing memories is done in
the `finalize_node` function, which is registered using `finalizer` when
creating a proxy node. If a node object does not own itself, there is almost
nothing to do in `finalize_node` except canceling (i.e. assigning the null
pointer) the `_private` field.  If a node object owns itself, it finalized all
descendant nodes in `finalize_node`.  In this process, the owner node cancels
all `_private` fields of its descendants because their finalizer may be called
after finished freeing nodes, which may result in a segmentation fault. Another
important role of keeping owner reference is that it prohibits owner objects
from being deallocated by Julia's garbage collecter.

Since the `owner` field is not managed by libxml2, EzXML.jl needs to update the
field when changing the structure of an XML tree. For example, linking a tree
with another tree will lead to an inconsistent situation where descendants nodes
reference different owner nodes. `update_owners!` updates the owner node of a
whole tree so that this situation won't happen. Therefore, functions like
`link!` and `unlink!` update owner objects by calling this function.
