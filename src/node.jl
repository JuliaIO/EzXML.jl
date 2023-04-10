# XML Node
# ========

# Shared fields of node-like structs.
struct _Node
    _private::Ptr{Cvoid}  # pointer to a Node object (NULL if not)
    typ::Cint
    name::Cstring
    children::Ptr{_Node}
    last::Ptr{_Node}
    parent::Ptr{_Node}
    next::Ptr{_Node}
    prev::Ptr{_Node}
    doc::Ptr{_Node}
end

# Node type (enum xmlElementType).
if sizeof(Cint) == 2
    primitive type NodeType <: Integer 16 end
elseif sizeof(Cint) == 4
    primitive type NodeType <: Integer 32 end
elseif sizeof(Cint) == 8
    primitive type NodeType <: Integer 64 end
else
    @assert false "invalid Cint size"
end

function NodeType(x::Integer)
    return convert(NodeType, x)
end

function Base.convert(::Type{NodeType}, x::Integer)
    return reinterpret(NodeType, convert(Cint, x))
end

function Base.convert(::Type{T}, x::NodeType) where {T<:Integer}
    return convert(T, reinterpret(Cint, x))
end

function Base.convert(::Type{NodeType}, x::NodeType)
    return x
end

function Base.promote_rule(::Type{NodeType}, ::Type{T}) where {T<:Union{Cint,Int}}
    return T
end

const ELEMENT_NODE       = NodeType( 1)
const ATTRIBUTE_NODE     = NodeType( 2)
const TEXT_NODE          = NodeType( 3)
const CDATA_SECTION_NODE = NodeType( 4)
const ENTITY_REF_NODE    = NodeType( 5)
const ENTITY_NODE        = NodeType( 6)
const PI_NODE            = NodeType( 7)
const COMMENT_NODE       = NodeType( 8)
const DOCUMENT_NODE      = NodeType( 9)
const DOCUMENT_TYPE_NODE = NodeType(10)
const DOCUMENT_FRAG_NODE = NodeType(11)
const NOTATION_NODE      = NodeType(12)
const HTML_DOCUMENT_NODE = NodeType(13)
const DTD_NODE           = NodeType(14)
const ELEMENT_DECL       = NodeType(15)
const ATTRIBUTE_DECL     = NodeType(16)
const ENTITY_DECL        = NodeType(17)
const NAMESPACE_DECL     = NodeType(18)
const XINCLUDE_START     = NodeType(19)
const XINCLUDE_END       = NodeType(20)
const DOCB_DOCUMENT_NODE = NodeType(21)

function Base.show(io::IO, x::NodeType)
    if x == ELEMENT_NODE
        print(io, "ELEMENT_NODE")
    elseif x == ATTRIBUTE_NODE
        print(io, "ATTRIBUTE_NODE")
    elseif x == TEXT_NODE
        print(io, "TEXT_NODE")
    elseif x == CDATA_SECTION_NODE
        print(io, "CDATA_SECTION_NODE")
    elseif x == ENTITY_REF_NODE
        print(io, "ENTITY_REF_NODE")
    elseif x == ENTITY_NODE
        print(io, "ENTITY_NODE")
    elseif x == PI_NODE
        print(io, "PI_NODE")
    elseif x == COMMENT_NODE
        print(io, "COMMENT_NODE")
    elseif x == DOCUMENT_NODE
        print(io, "DOCUMENT_NODE")
    elseif x == DOCUMENT_TYPE_NODE
        print(io, "DOCUMENT_TYPE_NODE")
    elseif x == DOCUMENT_FRAG_NODE
        print(io, "DOCUMENT_FRAG_NODE")
    elseif x == NOTATION_NODE
        print(io, "NOTATION_NODE")
    elseif x == HTML_DOCUMENT_NODE
        print(io, "HTML_DOCUMENT_NODE")
    elseif x == DTD_NODE
        print(io, "DTD_NODE")
    elseif x == ELEMENT_DECL
        print(io, "ELEMENT_DECL")
    elseif x == ATTRIBUTE_DECL
        print(io, "ATTRIBUTE_DECL")
    elseif x == ENTITY_DECL
        print(io, "ENTITY_DECL")
    elseif x == NAMESPACE_DECL
        print(io, "NAMESPACE_DECL")
    elseif x == XINCLUDE_START
        print(io, "XINCLUDE_START")
    elseif x == XINCLUDE_END
        print(io, "XINCLUDE_END")
    elseif x == DOCB_DOCUMENT_NODE
        print(io, "DOCB_DOCUMENT_NODE")
    else
        @assert false "unknown node type"
    end
end

function Base.print(io::IO, x::NodeType)
    print(io, convert(Cint, x))
end

function Base.string(x::NodeType)
    return sprint(print, x)
end

# Fields of namespace (_xmlNs).
struct _Ns
    next::Ptr{_Ns}
    typ::Cint
    href::Cstring
    prefix::Cstring
    _private::Ptr{Cvoid}
    context::Ptr{Cvoid}
end

# Fields of document node (_xmlDoc)
struct _Document
    _private::Ptr{Cvoid}
    typ::Cint
    name::Cstring
    children::Ptr{_Node}
    last::Ptr{_Node}
    parent::Ptr{_Node}
    next::Ptr{_Node}
    prev::Ptr{_Node}
    doc::Ptr{_Node}

    compression::Cint
    standalone::Cint
    intsubset::Ptr{_Node}
    extsubset::Ptr{_Node}
    oldns::Ptr{_Node}
    version::Cstring
    encoding::Cstring
    ids::Ptr{Cvoid}
    refs::Ptr{Cvoid}
    url::Cstring
    charset::Cint
    dict::Ptr{Cvoid}
    psvi::Ptr{Cvoid}
    parseflags::Cint
    properties::Cint
end

# Fields of element node (_xmlNode).
struct _Element
    _private::Ptr{Cvoid}
    typ::Cint
    name::Cstring
    children::Ptr{_Node}
    last::Ptr{_Node}
    parent::Ptr{_Node}
    next::Ptr{_Node}
    prev::Ptr{_Node}
    doc::Ptr{_Node}

    ns::Ptr{_Ns}
    content::Ptr{Cvoid}
    properties::Ptr{_Node}
    nsDef::Ptr{Cvoid}
    psvi::Ptr{Cvoid}
    line::Cshort
    extra::Cshort
end

# Fields of attribute node (_xmlAttr).
struct _Attribute
    _private::Ptr{Cvoid}
    typ::Cint
    name::Cstring
    children::Ptr{_Node}
    last::Ptr{_Node}
    parent::Ptr{_Node}
    next::Ptr{_Node}
    prev::Ptr{_Node}
    doc::Ptr{_Node}

    ns::Ptr{_Ns}
    atype::Cint
    psvi::Ptr{Cvoid}
end

# Fields of DTD node (_xmlDtd).
struct _Dtd
    _private::Ptr{Cvoid}
    typ::Cint
    name::Cstring
    children::Ptr{_Node}
    last::Ptr{_Node}
    parent::Ptr{_Node}
    next::Ptr{_Node}
    prev::Ptr{_Node}
    doc::Ptr{_Node}

    notations::Ptr{Cvoid}
    elements::Ptr{Cvoid}
    attributes::Ptr{Cvoid}
    entities::Ptr{Cvoid}
    externalID::Cstring
    systemID::Cstring
    pentities::Ptr{Cvoid}
end

# Node type
# ---------
#
# The following type is a proxy type to libxml2's node-like structs.  `ptr`
# points to a node-like C struct allocated in libxml2 that has common fields
# from `_private` to `doc` defined in `_Node`.  `owner` is a reference to a
# heap-allocated Julia object and is responsible for releasing memories. It must
# be either a document or the root element of a DOM tree. Note that moving a
# tree needs to update owners of its descendants. Every `Node` object must go
# through the internal constructor to make sure allocated memories will be
# released eventually. Users of the package are not supposed to directly call
# the constructor.

"""
A proxy type to libxml2's node struct.

Properties
----------

| Name | Type | Description |
|:---- |:---- |:------------|
| `type` | `EzXML.NodeType` | the type of a node |
| `name` | `String?`| the name of a node|
| `path` | `String`| the absolute path to a node |
| `content` | `String`| the content of a node |
| `namespace` | `String?`| the namespace associated with a node |

"""
mutable struct Node
    ptr::Ptr{_Node}
    owner::Node

    function Node(ptr::Ptr{_Node}, autofinalize::Bool=true)
        @assert ptr != C_NULL

        # return a preallocated proxy object if any
        str = unsafe_load(ptr)
        if has_proxy(str)
            # found a valid proxy
            return unsafe_extract_proxy(str)
        end

        if autofinalize
            # determine the owner of this node
            owner_ptr = ptr
            while (p = unsafe_load(owner_ptr).parent) != C_NULL
                owner_ptr = p
            end

            if ptr == owner_ptr
                # manage itself
                node = new(ptr)
                node.owner = node
            else
                # delegate management to its owner
                owner = Node(owner_ptr)
                node = new(ptr, owner)
            end

            finalizer(finalize_node, node)
        else
            node = new(ptr)
        end

        store_proxy_pointer!(node, pointer_from_objref(node))

        return node
    end
end

function ismanaged(node::Node)
    return isdefined(node, :owner)
end

function Base.show(io::IO, node::Node)
    prefix = isdefined(Main, :Node) ? "Node" : "EzXML.Node"
    ntype = nodetype(node)
    if ntype ∈ (ELEMENT_NODE, ATTRIBUTE_NODE) && hasnodename(node)
        desc = string(repr(ntype), '[', nodename(node), ']')
    else
        desc = repr(ntype)
    end
    @printf(io, "%s(<%s@%p>)", prefix, desc, node.ptr)
end

function Base.print(io::IO, node::Node)
    dump_node(io, node, false)
end

"""
    prettyprint([io], node::Node)

Print `node` with formatting.
"""
function prettyprint(node::Node)
    prettyprint(stdout, node)
end

function prettyprint(io::IO, node::Node)
    dump_node(io, node, true)
end

# Dump `node` to `io`.
function dump_node(io, node, format)
    if hasdocument(node)
        doc_ptr = document(node).node.ptr
    else
        doc_ptr = C_NULL
    end
    buf = Buffer()
    level = 0
    len = @check ccall(
        (:xmlNodeDump, libxml2),
        Cint,
        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cint, Cint),
        buf.ptr, doc_ptr, node.ptr, level, format) != -1
    print(io, unsafe_string(unsafe_load(buf.ptr).content))
end

function Base.:(==)(n1::Node, n2::Node)
    return n1.ptr == n2.ptr
end

function Base.hash(node::Node, h::UInt)
    return hash(node.ptr, h)
end

# Check if `str` has a reference to `Node`.
function has_proxy(str::_Node)
    return str._private != C_NULL
end

# Extract a `Node` object from `str`.
function unsafe_extract_proxy(str::_Node)
    return unsafe_pointer_to_objref(str._private)::Node
end

# Store a pointer value to the `_private` field.
function store_proxy_pointer!(node, ptr)
    unsafe_store!(convert(Ptr{UInt}, node.ptr), convert(UInt, ptr))
    return node
end

# Finalize a Node object.
function finalize_node(node::Node)
    node_ptr = node.ptr
    GC.@preserve node if node === node.owner
        # detach pointers to C structs of descendant nodes
        traverse_tree(node_ptr) do ptr
            str = unsafe_load(ptr)
            if has_proxy(str)
                # detach!
                unsafe_extract_proxy(str).ptr = C_NULL
            end
        end
        # free the descendants
        if unsafe_load(node_ptr).typ ∈ (DOCUMENT_NODE, HTML_DOCUMENT_NODE)
            ccall((:xmlFreeDoc, libxml2), Cvoid, (Ptr{Cvoid},), node_ptr)
        else
            ccall((:xmlFreeNode, libxml2), Cvoid, (Ptr{Cvoid},), node_ptr)
        end
    elseif node_ptr != C_NULL
        # indicate the proxy does not exit anymore
        store_proxy_pointer!(node, C_NULL)
    end
    return nothing
end


# Node properties
# ---------------

Base.propertynames(x::Node) = (
    :type, :name, :path, :content, :namespace, :document, :parentnode, :parentelement, :firstnode, :lastnode, :firstelement, :lastelement, :nextnode, :prevnode, :nextelement, :prevelement,
    fieldnames(typeof(x))...
)

@inline function Base.getproperty(node::Node, name::Symbol)
    # node properties
    name == :type      ? nodetype(node)                                   :
    name == :name      ? (hasnodename(node)  ? nodename(node)  : nothing) :
    name == :path      ? nodepath(node)                                   :
    name == :content   ? nodecontent(node)                                :
    name == :namespace ? (hasnamespace(node) ? namespace(node) : nothing) :
    # tree traversal
    name == :document      ? (hasdocument(node)      ? document(node)      : nothing) :
    name == :parentnode    ? (hasparentnode(node)    ? parentnode(node)    : nothing) :
    name == :parentelement ? (hasparentelement(node) ? parentelement(node) : nothing) :
    name == :firstnode     ? (hasnode(node)          ? firstnode(node)     : nothing) :
    name == :lastnode      ? (hasnode(node)          ? lastnode(node)      : nothing) :
    name == :firstelement  ? (haselement(node)       ? firstelement(node)  : nothing) :
    name == :lastelement   ? (haselement(node)       ? lastelement(node)   : nothing) :
    name == :nextnode      ? (hasnextnode(node)      ? nextnode(node)      : nothing) :
    name == :prevnode      ? (hasprevnode(node)      ? prevnode(node)      : nothing) :
    name == :nextelement   ? (hasnextelement(node)   ? nextelement(node)   : nothing) :
    name == :prevelement   ? (hasprevelement(node)   ? prevelement(node)   : nothing) :
    # data fields
    Core.getfield(node, name)
end

@inline function Base.setproperty!(node::Node, name::Symbol, x)
    # node properties
    if name == :name
        setnodename!(node, string(x))
    elseif name == :content
        setnodecontent!(node, string(x))
    else
        Core.setfield!(node, name, convert(fieldtype(Node, name), x))
    end
    return node
end


# Node constructors
# -----------------

"""
    XMLDocumentNode(version)

Create an XML document node with `version`.
"""
function XMLDocumentNode(version::AbstractString)
    node_ptr = @check ccall(
        (:xmlNewDoc, libxml2),
        Ptr{_Node},
        (Cstring,),
        version) != C_NULL
    return Node(node_ptr)
end

"""
    HTMLDocumentNode(uri, externalID)

Create an HTML document node.

`uri` and `externalID` are either a string or `nothing`.
"""
function HTMLDocumentNode(uri::Union{AbstractString,Cvoid},
                          externalID::Union{AbstractString,Cvoid})
    if uri === nothing
        uri = C_NULL
    end
    if externalID === nothing
        externalID = C_NULL
    end
    node_ptr = @check ccall(
        (:htmlNewDoc, libxml2),
        Ptr{_Node},
        (Cstring, Cstring),
        uri, externalID) != C_NULL
    return Node(node_ptr)
end

"""
    ElementNode(name)

Create an element node with `name`.
"""
function ElementNode(name::AbstractString)
    ns = C_NULL
    node_ptr = @check ccall(
        (:xmlNewNode, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Cstring),
        ns, name) != C_NULL
    return Node(node_ptr)
end

"""
    TextNode(content)

Create a text node with `content`.
"""
function TextNode(content::AbstractString)
    node_ptr = @check ccall(
        (:xmlNewText, libxml2),
        Ptr{_Node},
        (Cstring,),
        content) != C_NULL
    return Node(node_ptr)
end

"""
    CommentNode(content)

Create a comment node with `content`.
"""
function CommentNode(content::AbstractString)
    node_ptr = @check ccall(
        (:xmlNewComment, libxml2),
        Ptr{_Node},
        (Cstring,),
        content) != C_NULL
    return Node(node_ptr)
end

"""
    CDataNode(content)

Create a CDATA node with `content`.
"""
function CDataNode(content::AbstractString)
    doc_ptr = C_NULL
    node_ptr = @check ccall(
        (:xmlNewCDataBlock, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Cstring, Cint),
        doc_ptr, content, sizeof(content)) != C_NULL
    return Node(node_ptr)
end

"""
    AttributeNode(name, value)

Create an attribute node with `name` and `value`.
"""
function AttributeNode(name::AbstractString, value::AbstractString)
    doc_ptr = C_NULL
    node_ptr = @check ccall(
        (:xmlNewDocProp, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Cstring, Cstring),
        doc_ptr, name, value) != C_NULL
    return Node(node_ptr)
end

"""
    DTDNode(name, [systemID, [externalID]])

Create a DTD node with `name`, `systemID`, and `externalID`.
"""
function DTDNode(name::AbstractString, systemID::AbstractString, externalID::AbstractString)
    return make_dtd_node(name, systemID, externalID)
end

function DTDNode(name::AbstractString, systemID::AbstractString)
    return make_dtd_node(name, systemID, C_NULL)
end

function DTDNode(name::AbstractString)
    return make_dtd_node(name, C_NULL, C_NULL)
end

function make_dtd_node(name, systemID, externalID)
    doc_ptr = C_NULL
    node_ptr = @check ccall(
        (:xmlCreateIntSubset, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Cstring, Cstring, Cstring),
        doc_ptr, name, externalID, systemID) != C_NULL
    return Node(node_ptr)
end


# Tree traversal
# --------------

# Apply `f` to all nodes rooted at `root_ptr`.
function traverse_tree(f, root_ptr)
    n_nodes = 0
    cur_ptr = root_ptr
    while cur_ptr != C_NULL
        f(cur_ptr)
        n_nodes += 1
        cur_str = unsafe_load(cur_ptr)
        if cur_str.typ == ELEMENT_NODE
            # Attributes of element nodes aren't attached as `children` nodes.
            prop_ptr = property_ptr(cur_ptr)
            while prop_ptr != C_NULL
                f(prop_ptr)
                n_nodes += traverse_tree(f, prop_ptr)
                prop_ptr = unsafe_load(prop_ptr).next
            end
        end
        if cur_str.children != C_NULL
            cur_ptr = cur_str.children
        else
            while cur_ptr != root_ptr && cur_str.next == C_NULL
                cur_ptr = cur_str.parent
                cur_str = unsafe_load(cur_ptr)
            end
            if cur_ptr == root_ptr
                cur_ptr = convert(Ptr{_Node}, C_NULL)
            else
                cur_ptr = cur_str.next
            end
        end
    end
    return n_nodes
end

"""
    hasparentnode(node::Node)

Return if `node` has a parent node.
"""
function hasparentnode(node::Node)
    return parent_ptr(node.ptr) != C_NULL
end

"""
    parentnode(node::Node)

Return the parent of `node`.
"""
function parentnode(node::Node)
    if !hasparentnode(node)
        throw(ArgumentError("no parent node"))
    end
    return Node(parent_ptr(node.ptr))
end

"""
    hasparentelement(node::Node)

Return if `node` has a parent node.
"""
function hasparentelement(node::Node)
    par_ptr = parent_ptr(node.ptr)
    if par_ptr == C_NULL
        return false
    end
    return unsafe_load(par_ptr).typ == ELEMENT_NODE
end

"""
    parentelement(node::Node)

Return the parent element of `node`.
"""
function parentelement(node::Node)
    if !hasparentelement(node)
        throw(ArgumentError("no parent element"))
    end
    return Node(parent_ptr(node.ptr))
end

"""
    hasnode(node::Node)

Return if `node` has a child node.
"""
function hasnode(node::Node)
    return first_node_ptr(node.ptr) != C_NULL
end

"""
    firstnode(node::Node)

Return the first child node of `node`.
"""
function firstnode(node::Node)
    if !hasnode(node)
        throw(ArgumentError("no child nodes"))
    end
    return Node(first_node_ptr(node.ptr), ismanaged(node))
end

"""
    lastnode(node::Node)

Return the last child node of `node`.
"""
function lastnode(node::Node)
    if !hasnode(node)
        throw(ArgumentError("no child nodes"))
    end
    return Node(last_node_ptr(node.ptr), ismanaged(node))
end

"""
    haselement(node::Node)

Return if `node` has a child element.
"""
function haselement(node::Node)
    return first_element_ptr(node.ptr) != C_NULL
end

"""
    firstelement(node::Node)

Return the first child element of `node`.
"""
function firstelement(node::Node)
    if !haselement(node)
        throw(ArgumentError("no child elements"))
    end
    return Node(first_element_ptr(node.ptr), ismanaged(node))
end

"""
    lastelement(node::Node)

Return the last child element of `node`.
"""
function lastelement(node::Node)
    if !haselement(node)
        throw(ArgumentError("no child elements"))
    end
    return Node(last_element_ptr(node.ptr), ismanaged(node))
end

"""
    hasnextnode(node::Node)

Return if `node` has a next node.
"""
function hasnextnode(node::Node)
    return next_node_ptr(node.ptr) != C_NULL
end

"""
    nextnode(node::Node)

Return the next node of `node`.
"""
function nextnode(node::Node)
    if !hasnextnode(node)
        throw(ArgumentError("no next node"))
    end
    return Node(next_node_ptr(node.ptr))
end

"""
    hasprevnode(node::Node)

Return if `node` has a previous node.
"""
function hasprevnode(node::Node)
    return prev_node_ptr(node.ptr) != C_NULL
end

"""
    prevnode(node::Node)

Return the previous node of `node`.
"""
function prevnode(node::Node)
    if !hasprevnode(node)
        throw(ArgumentError("no previous node"))
    end
    return Node(prev_node_ptr(node.ptr))
end

"""
    hasnextelement(node::Node)

Return if `node` has a next node.
"""
function hasnextelement(node::Node)
    return next_element_ptr(node.ptr) != C_NULL
end

"""
    nextelement(node::Node)

Return the next element of `node`.
"""
function nextelement(node::Node)
    if !hasnextelement(node)
        throw(ArgumentError("no next elements"))
    end
    return Node(next_element_ptr(node.ptr))
end

"""
    hasprevelement(node::Node)

Return if `node` has a previous node.
"""
function hasprevelement(node::Node)
    return prev_element_ptr(node.ptr) != C_NULL
end

"""
    prevelement(node::Node)

Return the previous element of `node`.
"""
function prevelement(node::Node)
    if !hasprevelement(node)
        throw(ArgumentError("no previous elements"))
    end
    return Node(prev_element_ptr(node.ptr))
end


# Counters
# --------

"""
    countnodes(parent::Node)

Count the number of child nodes of `parent`.
"""
function countnodes(parent::Node)
    n = 0
    cur_ptr = first_node_ptr(parent.ptr)
    while cur_ptr != C_NULL
        n += 1
        cur_ptr = next_node_ptr(cur_ptr)
    end
    return n
end

"""
    countelements(parent::Node)

Count the number of child elements of `parent`.
"""
function countelements(parent::Node)
    n = ccall(
        (:xmlChildElementCount, libxml2),
        Culong,
        (Ptr{Cvoid},),
        parent.ptr)
    return Int(n)
end

"""
    countattributes(elem::Node)

Count the number of attributes of `elem`.
"""
function countattributes(elem::Node)
    if !iselement(elem)
        throw(ArgumentError("not an element node"))
    end
    n = 0
    cur_ptr = property_ptr(elem.ptr)
    while cur_ptr != C_NULL
        n += 1
        cur_ptr = next_node_ptr(cur_ptr)
    end
    return n
end


# Tree modifiers
# --------------

"""
    link!(parent::Node, child::Node)

Link `child` at the end of children of `parent`.
"""
function link!(parent::Node, child::Node)
    check_topmost(child)
    node_ptr = @check ccall(
        (:xmlAddChild, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Ptr{Cvoid}),
        parent.ptr, child.ptr) != C_NULL
    update_owners!(child, parent.owner)
    return child
end

"""
    linknext!(target::Node, node::Node)

Link `node` as the next sibling of `target`.
"""
function linknext!(target::Node, node::Node)
    check_topmost(node)
    node_ptr = @check ccall(
        (:xmlAddNextSibling, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Ptr{Cvoid}),
        target.ptr, node.ptr) != C_NULL
    update_owners!(node, target.owner)
    return node
end

"""
    linkprev!(target::Node, node::Node)

Link `node` as the prev sibling of `target`.
"""
function linkprev!(target::Node, node::Node)
    check_topmost(node)
    node_ptr = @check ccall(
        (:xmlAddPrevSibling, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Ptr{Cvoid}),
        target.ptr, node.ptr) != C_NULL
    update_owners!(node, target.owner)
    return node
end

function check_topmost(node::Node)
    if node !== node.owner
        throw(ArgumentError("the node is not a topmost one; must be unlinked first"))
    end
    return nothing
end

"""
    unlink!(node::Node)

Unlink `node` from its context.
"""
function unlink!(node::Node)
    ccall(
        (:xmlUnlinkNode, libxml2),
        Cvoid,
        (Ptr{Cvoid},),
        node.ptr)
    ccall(
        (:xmlSetTreeDoc, libxml2),
        Cvoid,
        (Ptr{Cvoid}, Ptr{Cvoid}),
        node.ptr, C_NULL)
    update_owners!(node, node)
    return node
end

"""
    addelement!(parent::Node, name::AbstractString)

Add a new child element of `name` with no content to `parent` and return the new child element.
"""
function addelement!(parent::Node, name::AbstractString)
    ns_ptr = C_NULL
    content_ptr = C_NULL
    node_ptr = @check ccall(
        (:xmlNewTextChild, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Ptr{Cvoid}, Cstring, Cstring),
        parent.ptr, ns_ptr, name, content_ptr) != C_NULL
    return Node(node_ptr)
end

"""
    addelement!(parent::Node, name::AbstractString, content::AbstractString)

Add a new child element of `name` with `content` to `parent` and return the new child element.
"""
function addelement!(parent::Node, name::AbstractString, content::AbstractString)
    ns_ptr = C_NULL
    node_ptr = @check ccall(
        (:xmlNewTextChild, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Ptr{Cvoid}, Cstring, Cstring),
        parent.ptr, ns_ptr, name, content) != C_NULL
    return Node(node_ptr)
end

# Update owners of the `root` tree.  NOTE: This function must not throw an
# exception; otherwise it may lead to a devastating tree.
function update_owners!(root, new_owner)
    traverse_tree(root.ptr) do node_ptr
        str = unsafe_load(node_ptr)
        if has_proxy(str)
            unsafe_extract_proxy(str).owner = new_owner
        end
    end
end


# Utils
# -----

"""
    nodetype(node::Node)

Return the type of `node` as an integer.
"""
function nodetype(node::Node)
    node_str = unsafe_load(node.ptr)
    return convert(NodeType, node_str.typ)
end

"""
    nodepath(node::Node)

Return the path of `node`.
"""
function nodepath(node::Node)
    str_ptr = @check ccall(
        (:xmlGetNodePath, libxml2),
        Cstring,
        (Ptr{Cvoid},),
        node.ptr) != C_NULL
    str = unsafe_string(str_ptr)
    Libc.free(str_ptr)
    return str
end

"""
    iselement(node::Node)

Return if `node` is an element node.
"""
function iselement(node::Node)
    return nodetype(node) === ELEMENT_NODE
end

"""
    isattribute(node::Node)

Return if `node` is an attribute node.
"""
function isattribute(node::Node)
    return nodetype(node) === ATTRIBUTE_NODE
end

"""
    istext(node::Node)

Return if `node` is a text node.
"""
function istext(node::Node)
    return nodetype(node) === TEXT_NODE
end

"""
    iscdata(node::Node)

Return if `node` is a CDATA node.
"""
function iscdata(node::Node)
    return nodetype(node) === CDATA_SECTION_NODE
end

"""
    iscomment(node::Node)

Return if `node` is a comment node.
"""
function iscomment(node::Node)
    return nodetype(node) === COMMENT_NODE
end

"""
    isdtd(node::Node)

Return if `node` is a DTD node.
"""
function isdtd(node::Node)
    return nodetype(node) === DTD_NODE
end

"""
    hasdocument(node::Node)

Return if `node` belongs to a document.
"""
function hasdocument(node::Node)
    return unsafe_load(node.ptr).doc != C_NULL
end

"""
    document(node::Node)

Return the document of `node`.
"""
function document(node::Node)
    if !hasdocument(node)
        throw(ArgumentError("no document"))
    end
    doc_ptr = unsafe_load(node.ptr).doc
    return Document(doc_ptr)
end

"""
    hasnodename(node::Node)

Return if `node` has a node name.
"""
function hasnodename(node::Node)
    return unsafe_load(node.ptr).name != C_NULL
end

"""
    nodename(node::Node)

Return the node name of `node`.
"""
function nodename(node::Node)
    node_str = unsafe_load(node.ptr)
    if node_str.name == C_NULL
        throw(ArgumentError("no node name"))
    end
    return unsafe_string(node_str.name)
end

"""
    setnodename!(node::Node, name::AbstractString)

Set the name of `node`.
"""
function setnodename!(node::Node, name::AbstractString)
    ccall(
        (:xmlNodeSetName, libxml2),
        Cvoid,
        (Ptr{Cvoid}, Cstring),
        node.ptr, name)
    return node
end

"""
    nodecontent(node::Node)

Return the node content of `node`.
"""
function nodecontent(node::Node)
    str_ptr = @check ccall(
        (:xmlNodeGetContent, libxml2),
        Cstring,
        (Ptr{Cvoid},),
        node.ptr) != C_NULL
    str = unsafe_string(str_ptr)
    Libc.free(str_ptr)
    return str
end

"""
    setnodecontent!(node::Node, content::AbstractString)

Replace the content of `node`.
"""
function setnodecontent!(node::Node, content::AbstractString)
    ccall(
        (:xmlNodeSetContentLen, libxml2),
        Cvoid,
        (Ptr{Cvoid}, Cstring, Cint),
        node.ptr, content, sizeof(content))
    return node
end

"""
    systemID(node::Node)

Return the system ID of `node`.
"""
function systemID(node::Node)
    if !isdtd(node)
        throw(ArgumentError("not a DTD node"))
    end
    return unsafe_string(unsafe_load(convert(Ptr{_Dtd}, node.ptr)).systemID)
end

"""
    externalID(node::Node)

Return the external ID of `node`.
"""
function externalID(node::Node)
    if !isdtd(node)
        throw(ArgumentError("not a DTD node"))
    end
    return unsafe_string(unsafe_load(convert(Ptr{_Dtd}, node.ptr)).externalID)
end


# Attributes
# ----------

function Base.getindex(node::Node, attr::AbstractString)
    i = findfirstchar(':', attr)
    if i == 0
        str_ptr = ccall(
            (:xmlGetNoNsProp, libxml2),
            Cstring,
            (Ptr{Cvoid}, Cstring),
            node.ptr, attr)
    else
        prefix = attr[1:i-1]
        ns_ptr = search_ns_ptr(node, prefix)
        if ns_ptr == C_NULL
            throw(ArgumentError("unknown namespace prefix: '$(prefix)'"))
        end
        ncname = attr[i+1:end]
        str_ptr = ccall(
            (:xmlGetNsProp, libxml2),
            Cstring,
            (Ptr{Cvoid}, Cstring, Cstring),
            node.ptr, ncname, unsafe_load(ns_ptr).href)
    end
    if str_ptr == C_NULL
        throw(KeyError(attr))
    end
    str = unsafe_string(str_ptr)
    Libc.free(str_ptr)
    return str
end

function Base.haskey(node::Node, attr::AbstractString)
    i = findfirstchar(':', attr)
    if i == 0
        prop_ptr = ccall(
            (:xmlHasNsProp, libxml2),
            Ptr{_Node},
            (Ptr{Cvoid}, Cstring, Cstring),
            node.ptr, attr, C_NULL)
    else
        prefix = attr[1:i-1]
        ns_ptr = search_ns_ptr(node, prefix)
        if ns_ptr == C_NULL
            return false
        end
        ncname = attr[i+1:end]
        prop_ptr = ccall(
            (:xmlHasNsProp, libxml2),
            Ptr{_Node},
            (Ptr{Cvoid}, Cstring, Cstring),
            node.ptr, ncname, unsafe_load(ns_ptr).href)
    end
    return prop_ptr != C_NULL
end

function Base.setindex!(node::Node, val, attr::AbstractString)
    # This function handles QName properly.
    prop_ptr = @check ccall(
        (:xmlSetProp, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Cstring, Cstring),
        node.ptr, attr, string(val)) != C_NULL
    return node
end

function Base.delete!(node::Node, attr::AbstractString)
    i = findfirstchar(':', attr)
    if i == 0
        # This function handles attributes in no namespace.
        ccall(
            (:xmlUnsetProp, libxml2),
            Cint,
            (Ptr{Cvoid}, Cstring),
            node.ptr, attr)
    else
        prefix = attr[1:i-1]
        ncname = attr[i+1:end]
        ns_ptr = search_ns_ptr(node, prefix)
        ccall(
            (:xmlUnsetNsProp, libxml2),
            Cint,
            (Ptr{Cvoid}, Ptr{Cvoid}, Cstring),
            node.ptr, ns_ptr, ncname)
    end
    # ignore the returned value
    return node
end

function findfirstchar(char::Char, str::AbstractString)
    return something(findfirst(isequal(char), str), 0)
end


# Namespaces
# ----------

"""
    hasnamespace(node::Node)

Return if `node` is associated with a namespace.
"""
function hasnamespace(node::Node)
    t = nodetype(node)
    if t == ELEMENT_NODE
        return unsafe_load(convert(Ptr{_Element}, node.ptr)).ns != C_NULL
    elseif t == ATTRIBUTE_NODE
        return unsafe_load(convert(Ptr{_Attribute}, node.ptr)).ns != C_NULL
    else
        return false
    end
end

"""
    namespace(node::Node)

Return the namespace associated with `node`.
"""
function namespace(node::Node)
    t = nodetype(node)
    if t == ELEMENT_NODE
        ns_ptr = unsafe_load(convert(Ptr{_Element}, node.ptr)).ns
    elseif t == ATTRIBUTE_NODE
        ns_ptr = unsafe_load(convert(Ptr{_Attribute}, node.ptr)).ns
    else
        throw(ArgumentError("neither element nor attribute node"))
    end
    if ns_ptr == C_NULL
        throw(ArgumentError("no namespace"))
    end
    return unsafe_string(unsafe_load(ns_ptr).href)
end

"""
    namespaces(node::Node)

Create a vector of namespaces applying to `node`.
"""
function namespaces(node::Node)
    doc = document(node)
    nslist_ptr = ccall(
        (:xmlGetNsList, libxml2),
        Ptr{Ptr{_Ns}},
        (Ptr{Cvoid}, Ptr{Cvoid}),
        doc.node.ptr, node.ptr)
    if nslist_ptr == C_NULL
        # empty list
        return Pair{String,String}[]
    end
    nslist = Pair{String,String}[]
    i = 1
    while unsafe_load(nslist_ptr, i) != C_NULL
        ns_ptr = unsafe_load(nslist_ptr, i)
        ns = unsafe_load(ns_ptr)
        href = unsafe_string(ns.href)
        if ns.prefix == C_NULL
            prefix = ""
        else
            prefix = unsafe_string(ns.prefix)
        end
        push!(nslist, prefix => href)
        i += 1
    end
    # Calling xmlFreeNsList results in error.
    Libc.free(nslist_ptr)
    return nslist
end

# Search a namespace pointer of `prefix` applied to `node`.
function search_ns_ptr(node::Node, prefix::AbstractString)
    ns_ptr = ccall(
        (:xmlSearchNs, libxml2),
        Ptr{_Ns},
        (Ptr{Cvoid}, Ptr{Cvoid}, Cstring),
        unsafe_load(node.ptr).doc, node.ptr, prefix)
    return ns_ptr
end


# Iterators
# ---------

abstract type AbstractNodeIterator end

function Base.eltype(::Type{T}) where {T<:AbstractNodeIterator}
    return Node
end

function Base.IteratorSize(::Type{T}) where {T<:AbstractNodeIterator}
    return Base.SizeUnknown()
end

"""
    eachnode(node::Node, [backward=false])

Create an iterator of child nodes.
"""
function eachnode(node::Node, backward::Bool=false)
    return ChildNodeIterator(node, backward)
end

"""
    nodes(node::Node, [backward=false])

Create a vector of child nodes.
"""
function nodes(node::Node, backward::Bool=false)
    return collect(eachnode(node, backward))
end

struct ChildNodeIterator <: AbstractNodeIterator
    node::Node
    backward::Bool
end

function Base.iterate(iter::ChildNodeIterator)
    cur_ptr = iter.backward ? last_node_ptr(iter.node.ptr) : first_node_ptr(iter.node.ptr)
    cur_ptr == C_NULL && return nothing
    return Node(cur_ptr, ismanaged(iter.node)), cur_ptr
end

function Base.iterate(iter::ChildNodeIterator, cur_ptr)
    cur_ptr = iter.backward ? prev_node_ptr(cur_ptr) : next_node_ptr(cur_ptr)
    cur_ptr == C_NULL && return nothing
    return Node(cur_ptr, ismanaged(iter.node)), cur_ptr
end

"""
    eachelement(node::Node, [backward=false])

Create an iterator of child elements.
"""
function eachelement(node::Node, backward::Bool=false)
    return ChildElementIterator(node, backward)
end

"""
    elements(node::Node, [backward=false])

Create a vector of child elements.
"""
function elements(node::Node, backward::Bool=false)
    return collect(eachelement(node, backward))
end

struct ChildElementIterator <: AbstractNodeIterator
    node::Node
    backward::Bool
end

function Base.iterate(iter::ChildElementIterator)
    cur_ptr = iter.backward ? last_element_ptr(iter.node.ptr) : first_element_ptr(iter.node.ptr)
    cur_ptr == C_NULL && return nothing
    return Node(cur_ptr, ismanaged(iter.node)), cur_ptr
end

function Base.iterate(iter::ChildElementIterator, cur_ptr)
    cur_ptr = iter.backward ? prev_element_ptr(cur_ptr) : next_element_ptr(cur_ptr)
    cur_ptr == C_NULL && return nothing
    return Node(cur_ptr, ismanaged(iter.node)), cur_ptr
end

"""
    eachattribute(node::Node)

Create an iterator of attributes.
"""
function eachattribute(node::Node)
    if unsafe_load(node.ptr).typ != ELEMENT_NODE
        throw(ArgumentError("not an element node"))
    end
    return AttributeIterator(node)
end

"""
    attributes(node::Node)

Create a vector of attributes.
"""
function attributes(node::Node)
    return collect(eachattribute(node))
end

struct AttributeIterator <: AbstractNodeIterator
    node::Node
end

function Base.iterate(iter::AttributeIterator, cur_ptr::Ptr{_Node}=property_ptr(iter.node.ptr))
    cur_ptr == C_NULL && return nothing
    return Node(cur_ptr, ismanaged(iter.node)), next_node_ptr(cur_ptr)
end

function parent_ptr(node_ptr)
    return unsafe_load(node_ptr).parent
end

function property_ptr(node_ptr)
    @assert node_ptr != C_NULL
    @assert unsafe_load(node_ptr).typ == ELEMENT_NODE
    return unsafe_load(convert(Ptr{_Element}, node_ptr)).properties
end

function first_node_ptr(node_ptr)
    return unsafe_load(node_ptr).children
end

function last_node_ptr(node_ptr)
    return unsafe_load(node_ptr).last
end

function next_node_ptr(node_ptr)
    return unsafe_load(node_ptr).next
end

function prev_node_ptr(node_ptr)
    return unsafe_load(node_ptr).prev
end

function first_element_ptr(node_ptr)
    return ccall(
        (:xmlFirstElementChild, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid},),
        node_ptr)
end

function last_element_ptr(node_ptr)
    return ccall(
        (:xmlLastElementChild, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid},),
        node_ptr)
end

function next_element_ptr(node_ptr)
    return ccall(
        (:xmlNextElementSibling, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid},),
        node_ptr)
end

function prev_element_ptr(node_ptr)
    return ccall(
        (:xmlPreviousElementSibling, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid},),
        node_ptr)
end
