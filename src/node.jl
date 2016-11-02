# XML Node
# --------

# Shared fields of node-like structs.
immutable _Node
    _private::Ptr{Void}  # pointer to a Node object (NULL if not)
    typ::Cint
    name::Cstring
    children::Ptr{_Node}
    last::Ptr{_Node}
    parent::Ptr{_Node}
    next::Ptr{_Node}
    prev::Ptr{_Node}
    doc::Ptr{_Node}
end

# Node types (enum xmlElementType).
if sizeof(Cint) == 2
    bitstype 16 NodeType <: Integer
elseif sizeof(Cint) == 4
    bitstype 32 NodeType <: Integer
elseif sizeof(Cint) == 8
    bitstype 64 NodeType <: Integer
else
    @assert false "invalid Cint size"
end

function Base.convert(::Type{NodeType}, x::Integer)
    return reinterpret(NodeType, convert(Cint, x))
end

function Base.convert{T<:Integer}(::Type{T}, x::NodeType)
    return convert(T, reinterpret(Cint, x))
end

function Base.promote_rule{T<:Union{Cint,Int}}(::Type{NodeType}, ::Type{T})
    return T
end

const XML_ELEMENT_NODE       = NodeType( 1)
const XML_ATTRIBUTE_NODE     = NodeType( 2)
const XML_TEXT_NODE          = NodeType( 3)
const XML_CDATA_SECTION_NODE = NodeType( 4)
const XML_ENTITY_REF_NODE    = NodeType( 5)
const XML_ENTITY_NODE        = NodeType( 6)
const XML_PI_NODE            = NodeType( 7)
const XML_COMMENT_NODE       = NodeType( 8)
const XML_DOCUMENT_NODE      = NodeType( 9)
const XML_DOCUMENT_TYPE_NODE = NodeType(10)
const XML_DOCUMENT_FRAG_NODE = NodeType(11)
const XML_NOTATION_NODE      = NodeType(12)
const XML_HTML_DOCUMENT_NODE = NodeType(13)
const XML_DTD_NODE           = NodeType(14)
const XML_ELEMENT_DECL       = NodeType(15)
const XML_ATTRIBUTE_DECL     = NodeType(16)
const XML_ENTITY_DECL        = NodeType(17)
const XML_NAMESPACE_DECL     = NodeType(18)
const XML_XINCLUDE_START     = NodeType(19)
const XML_XINCLUDE_END       = NodeType(20)
const XML_DOCB_DOCUMENT_NODE = NodeType(21)

function Base.show(io::IO, x::NodeType)
    if x == XML_ELEMENT_NODE
        print(io, "XML_ELEMENT_NODE")
    elseif x == XML_ATTRIBUTE_NODE
        print(io, "XML_ATTRIBUTE_NODE")
    elseif x == XML_TEXT_NODE
        print(io, "XML_TEXT_NODE")
    elseif x == XML_CDATA_SECTION_NODE
        print(io, "XML_CDATA_SECTION_NODE")
    elseif x == XML_ENTITY_REF_NODE
        print(io, "XML_ENTITY_REF_NODE")
    elseif x == XML_ENTITY_NODE
        print(io, "XML_ENTITY_NODE")
    elseif x == XML_PI_NODE
        print(io, "XML_PI_NODE")
    elseif x == XML_COMMENT_NODE
        print(io, "XML_COMMENT_NODE")
    elseif x == XML_DOCUMENT_NODE
        print(io, "XML_DOCUMENT_NODE")
    elseif x == XML_DOCUMENT_TYPE_NODE
        print(io, "XML_DOCUMENT_TYPE_NODE")
    elseif x == XML_DOCUMENT_FRAG_NODE
        print(io, "XML_DOCUMENT_FRAG_NODE")
    elseif x == XML_NOTATION_NODE
        print(io, "XML_NOTATION_NODE")
    elseif x == XML_HTML_DOCUMENT_NODE
        print(io, "XML_HTML_DOCUMENT_NODE")
    elseif x == XML_DTD_NODE
        print(io, "XML_DTD_NODE")
    elseif x == XML_ELEMENT_DECL
        print(io, "XML_ELEMENT_DECL")
    elseif x == XML_ATTRIBUTE_DECL
        print(io, "XML_ATTRIBUTE_DECL")
    elseif x == XML_ENTITY_DECL
        print(io, "XML_ENTITY_DECL")
    elseif x == XML_NAMESPACE_DECL
        print(io, "XML_NAMESPACE_DECL")
    elseif x == XML_XINCLUDE_START
        print(io, "XML_XINCLUDE_START")
    elseif x == XML_XINCLUDE_END
        print(io, "XML_XINCLUDE_END")
    elseif x == XML_DOCB_DOCUMENT_NODE
        print(io, "XML_DOCB_DOCUMENT_NODE")
    else
        @assert false "unknown node type"
    end
end

function Base.print(io::IO, x::NodeType)
    print(io, convert(Cint, x))
end

# Fields of element node (_xmlNode).
immutable _Element
    _private::Ptr{Void}
    typ::Cint
    name::Cstring
    children::Ptr{_Node}
    last::Ptr{_Node}
    parent::Ptr{_Node}
    next::Ptr{_Node}
    prev::Ptr{_Node}
    doc::Ptr{_Node}

    ns::Ptr{Void}
    content::Ptr{Void}
    properties::Ptr{_Node}
    nsDef::Ptr{Void}
    psvi::Ptr{Void}
    line::Cshort
    extra::Cshort
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
"""
type Node
    ptr::Ptr{_Node}
    owner::Node

    function Node(ptr::Ptr{_Node})
        @assert ptr != C_NULL

        # return a preallocated proxy object if any
        str = unsafe_load(ptr)
        proxy = try_extract_proxy(str)
        if !isnull(proxy)
            # found a valid proxy
            return get(proxy)
        end

        # determine the owner of this node
        owner_ptr = ptr
        while unsafe_load(owner_ptr).parent != C_NULL
            owner_ptr = unsafe_load(owner_ptr).parent
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

        # do memory management stuffs
        store_proxy_pointer!(node, pointer_from_objref(node))
        finalizer(node, finalize_node)

        return node
    end
end

function Base.show(io::IO, node::Node)
    node_str = unsafe_load(node.ptr)
    print(io, @sprintf("Node(<type:%d>@%p", node_str.typ, node.ptr), ")")
end

function Base.print(io::IO, node::Node)
    doc = document(node)
    buf = Buffer()
    level = format = 0
    len = ccall(
        (:xmlNodeDump, libxml2),
        Cint,
        (Ptr{Void}, Ptr{Void}, Ptr{Void}, Cint, Cint),
        buf.ptr, doc.node.ptr, node.ptr, level, format)
    if len == -1
        throw_xml_error()
    end
    print(io, unsafe_wrap(String, unsafe_load(buf.ptr).content, len))
end

# Try to extract the proxy object from the `_private` field if any.
function try_extract_proxy(str)
    proxy_ptr = str._private
    if proxy_ptr == C_NULL
        return Nullable{Node}()
    else
        return Nullable{Node}(unsafe_pointer_to_objref(proxy_ptr))
    end
end

# Store a pointer value to the `_private` field.
function store_proxy_pointer!(node, ptr)
    unsafe_store!(convert(Ptr{UInt}, node.ptr), convert(UInt, ptr))
    return node
end

# Finalize a Node object.
function finalize_node(node)
    node_ptr = node.ptr
    if node === node.owner
        # detach pointers to C structs of descendant nodes
        traverse_tree(node_ptr) do ptr
            proxy = try_extract_proxy(unsafe_load(ptr))
            if !isnull(proxy)
                # detach!
                get(proxy).ptr = C_NULL
            end
        end
        # free the descendants
        if unsafe_load(node_ptr).typ == XML_DOCUMENT_NODE
            ccall((:xmlFreeDoc, libxml2), Void, (Ptr{Void},), node_ptr)
        else
            ccall((:xmlFreeNode, libxml2), Void, (Ptr{Void},), node_ptr)
        end
    elseif node_ptr != C_NULL
        # indicate the proxy does not exit anymore
        store_proxy_pointer!(node, C_NULL)
    end
    return nothing
end


# Node constructors
# -----------------

function ElementNode(name::AbstractString)
    ns = C_NULL
    node_ptr = ccall(
        (:xmlNewNode, libxml2),
        Ptr{_Node},
        (Ptr{Void}, Cstring),
        ns, name)
    if node_ptr == C_NULL
        throw_xml_error()
    end
    return Node(node_ptr)
end

function TextNode(content::AbstractString)
    node_ptr = ccall(
        (:xmlNewText, libxml2),
        Ptr{_Node},
        (Cstring,),
        content)
    if node_ptr == C_NULL
        throw_xml_error()
    end
    return Node(node_ptr)
end

function CommentNode(content::AbstractString)
    node_ptr = ccall(
        (:xmlNewComment, libxml2),
        Ptr{_Node},
        (Cstring,),
        content)
    if node_ptr == C_NULL
        throw_xml_error()
    end
    return Node(node_ptr)
end

function CDataNode(content::AbstractString)
    doc_ptr = C_NULL
    node_ptr = ccall(
        (:xmlNewCDataBlock, libxml2),
        Ptr{_Node},
        (Ptr{Void}, Cstring, Cint),
        doc_ptr, content, length(content))
    if node_ptr == C_NULL
        throw_xml_error()
    end
    return Node(node_ptr)
end


# DOM
# ---

# Apply `f` to all nodes rooted at `root_ptr`.
function traverse_tree(f, root_ptr)
    n_nodes = 0
    cur_ptr = root_ptr
    while cur_ptr != C_NULL
        n_nodes += 1
        f(cur_ptr)
        cur_str = unsafe_load(cur_ptr)
        if cur_str.typ == XML_ELEMENT_NODE
            # Attributes of element nodes aren't attached as `children` nodes.
            elm_str = unsafe_load(convert(Ptr{_Element}, cur_ptr))
            prop_ptr = elm_str.properties
            while prop_ptr != C_NULL
                n_nodes += traverse_tree(f, prop_ptr)
                f(prop_ptr)
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
    has_parent_node(node::Node)

Return if `node` has a parent node.
"""
function has_parent_node(node::Node)
    @assert node.ptr != C_NULL
    return unsafe_load(node.ptr).parent != C_NULL
end

"""
    parent_node(node::Node)

Return the parent of `node`.
"""
function parent_node(node::Node)
    if !has_parent_node(node)
        throw(ArgumentError("no parent"))
    end
    return Node(unsafe_load(node.ptr).parent)
end

"""
    has_child_node(node::Node)

Return if `node` has a child node.
"""
function has_child_node(node::Node)
    @assert node.ptr != C_NULL
    return unsafe_load(node.ptr).children != C_NULL
end

"""
    first_child_node(node::Node)

Return the first child node of `node`.
"""
function first_child_node(node::Node)
    if !has_child_node(node)
        throw(ArgumentError("no children"))
    end
    return Node(unsafe_load(node.ptr).children)
end

"""
    last_child_node(node::Node)

Return the last child node of `node`.
"""
function last_child_node(node::Node)
    if !has_child_node(node)
        throw(ArgumentError("no children"))
    end
    return Node(unsafe_load(node.ptr).last)
end

"""
    has_next_node(node::Node)

Return if `node` has a next node.
"""
function has_next_node(node::Node)
    @assert node.ptr != C_NULL
    return unsafe_load(node.ptr).next != C_NULL
end

"""
    next_node(node::Node)

Return the next node of `node`.
"""
function next_node(node::Node)
    if !has_next_node(node)
        throw(ArgumentError("no next node"))
    end
    return Node(unsafe_load(node.ptr).next)
end

"""
    has_prev_node(node::Node)

Return if `node` has a previous node.
"""
function has_prev_node(node::Node)
    @assert node.ptr != C_NULL
    return unsafe_load(node.ptr).prev != C_NULL
end

"""
    prev_node(node::Node)

Return the previous node of `node`.
"""
function prev_node(node::Node)
    if !has_prev_node(node)
        throw(ArgumentError("no previous node"))
    end
    return Node(unsafe_load(node.ptr).prev)
end

"""
    add_child_node!(parent::Node, child::Node)

Add `child` at the end of children of `parent`.
"""
function add_child_node!(parent::Node, child::Node)
    child_ptr = ccall(
        (:xmlAddChild, libxml2),
        Ptr{_Node},
        (Ptr{Void}, Ptr{Void}),
        parent.ptr, child.ptr)
    if child_ptr == C_NULL
        throw_xml_error()
    end
    update_owners!(child, parent.owner)
    return child
end

"""
    add_next_sibling!(target::Node, node::Node)

Add `node` as the next sibling of `target`.
"""
function add_next_sibling!(target::Node, node::Node)
    node_ptr = ccall(
        (:xmlAddNextSibling, libxml2),
        Ptr{_Node},
        (Ptr{Void}, Ptr{Void}),
        target.ptr, node.ptr)
    if node_ptr == C_NULL
        throw_xml_error()
    end
    update_owners!(node, target.owner)
    return node
end

"""
    add_prev_sibling!(target::Node, node::Node)

Add `node` as the prev sibling of `target`.
"""
function add_prev_sibling!(target::Node, node::Node)
    node_ptr = ccall(
        (:xmlAddPrevSibling, libxml2),
        Ptr{_Node},
        (Ptr{Void}, Ptr{Void}),
        target.ptr, node.ptr)
    if node_ptr == C_NULL
        throw_xml_error()
    end
    update_owners!(node, target.owner)
    return node
end

# Update owners of the `root` tree.
function update_owners!(root, new_owner)
    traverse_tree(root.ptr) do node_ptr
        proxy = try_extract_proxy(unsafe_load(node_ptr))
        if !isnull(proxy)
            get(proxy).owner = new_owner
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
    document(node::Node)

Return the document of `node`.
"""
function document(node::Node)
    doc_ptr = unsafe_load(node.ptr).doc
    if doc_ptr == C_NULL
        throw(ArgumentError("no document"))
    end
    return Document(doc_ptr)
end

"""
    name(node::Node)

Return the node name of `node`.
"""
function name(node::Node)
    node_str = unsafe_load(node.ptr)
    if node_str.name == C_NULL
        throw(ArgumentError("no node name"))
    end
    return unsafe_string(node_str.name)
end

"""
    content(node::Node)

Return the node content of `node`.
"""
function content(node::Node)
    ptr = ccall(
        (:xmlNodeGetContent, libxml2),
        Cstring,
        (Ptr{Void},),
        node.ptr)
    if ptr == C_NULL
        throw_xml_error()
    end
    return unsafe_wrap(String, ptr, true)
end

"""
    set_content!(node::Node, content::AbstractString)

Replace the conteot of `node`.
"""
function set_content!(node::Node, content::AbstractString)
    ccall(
        (:xmlNodeSetContentLen, libxml2),
        Void,
        (Ptr{Void}, Cstring, Cint),
        node.ptr, content, length(content))
    return content
end


# Attributes
# ----------

function Base.getindex(node::Node, attr::AbstractString)
    ptr = ccall(
        (:xmlGetProp, libxml2),
        Cstring,
        (Ptr{Void}, Cstring),
        node.ptr, attr)
    if ptr == C_NULL
        throw(KeyError(attr))
    end
    return unsafe_wrap(String, ptr, true)
end

function Base.haskey(node::Node, attr::AbstractString)
    ptr = ccall(
        (:xmlHasProp, libxml2),
        Ptr{Void},
        (Ptr{Void}, Cstring),
        node.ptr, attr)
    return ptr != C_NULL
end

function Base.setindex!(node::Node, val, attr::AbstractString)
    ptr = ccall(
        (:xmlSetProp, libxml2),
        Ptr{Void},
        (Ptr{Void}, Cstring, Cstring),
        node.ptr, attr, string(val))
    if ptr == C_NULL
        throw_xml_error()
    end
    return node
end

function Base.delete!(node::Node, attr::AbstractString)
    ccall(
        (:xmlUnsetProp, libxml2),
        Cint,
        (Ptr{Void}, Cstring),
        node.ptr, attr)
    # ignore the returned value
    return node
end


# Namespaces
# ----------

immutable _Ns
    next::Ptr{_Ns}
    typ::Cint
    href::Cstring
    prefix::Cstring
    _private::Ptr{Void}
    context::Ptr{Void}
end

function free(ptr::Ptr{_Ns})
    ccall(
        (:xmlFreeNsList, libxml2),
        Void,
        (Ptr{Void},),
        ptr)
end

"""
    namespace(node::Node)

Return the namespace associated with `node`.
"""
function namespace(node::Node)
    if unsafe_load(node.ptr).typ != XML_ELEMENT_NODE
        throw(ArgumentError("not an element node"))
    end
    elm_ptr = convert(Ptr{_Element}, node.ptr)
    ns_ptr = unsafe_load(elm_ptr).ns
    if ns_ptr == C_NULL
        throw(ArgumentError("no namespace"))
    end
    ptr = unsafe_load(convert(Ptr{_Ns}, ns_ptr)).href
    @assert ptr != C_NULL
    return unsafe_string(ptr)
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
        (Ptr{Void}, Ptr{Void}),
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


# Iterators
# ---------

"""
    each_node(node::Node)

Create an iterator of child nodes.
"""
function each_node(node::Node)
    return ChildNodeIterator(node.ptr)
end

"""
    child_nodes(node::Node)

Create a vector of child nodes.
"""
function child_nodes(node::Node)
    return collect(each_node(node))
end

immutable ChildNodeIterator
    node::Ptr{_Node}
end

function Base.iteratorsize(::Type{ChildNodeIterator})
    return Base.SizeUnknown()
end

function Base.eltype(::Type{ChildNodeIterator})
    return Node
end

function Base.start(iter::ChildNodeIterator)
    current = unsafe_load(iter.node).children
    return current
end

function Base.done(::ChildNodeIterator, current)
    return current == C_NULL
end

function Base.next(::ChildNodeIterator, current)
    return Node(current), unsafe_load(current).next
end

"""
    each_element(node::Node)

Create an iterator of child elements.
"""
function each_element(node::Node)
    return ChildElementIterator(node.ptr)
end

"""
    child_elements(node::Node)

Create a vector of child elements.
"""
function child_elements(node::Node)
    return collect(each_element(node))
end

immutable ChildElementIterator
    ptr::Ptr{_Node}
end

function Base.iteratorsize(::Type{ChildElementIterator})
    return Base.SizeUnknown()
end

function Base.eltype(::Type{ChildElementIterator})
    return Node
end

function Base.start(iter::ChildElementIterator)
    cur_ptr = ccall(
        (:xmlFirstElementChild, libxml2),
        Ptr{_Node},
        (Ptr{Void},),
        iter.ptr)
    return cur_ptr
end

function Base.done(::ChildElementIterator, cur_ptr)
    return cur_ptr == C_NULL
end

function Base.next(::ChildElementIterator, cur_ptr)
    next_ptr = ccall(
        (:xmlNextElementSibling, libxml2),
        Ptr{_Node},
        (Ptr{Void},),
        cur_ptr)
    return Node(cur_ptr), next_ptr
end

"""
    each_attributes(node::Node)

Create an iterator of attributes.
"""
function each_attributes(node::Node)
    if unsafe_load(node.ptr).typ != XML_ELEMENT_NODE
        throw(ArgumentError("not an element node"))
    end
    return AttributesIterator(node.ptr)
end

"""
    attributes(node::Node)

Create a vector of attributes.
"""
function attributes(node::Node)
    return collect(each_attributes(node))
end

immutable AttributesIterator
    ptr::Ptr{_Node}
end

function Base.iteratorsize(::Type{AttributesIterator})
    return Base.SizeUnknown()
end

function Base.eltype(::Type{AttributesIterator})
    return Pair{String,String}
end

function Base.start(iter::AttributesIterator)
    @assert iter.ptr != C_NULL
    @assert unsafe_load(iter.ptr).typ == XML_ELEMENT_NODE
    elm_str = unsafe_load(convert(Ptr{_Element}, iter.ptr))
    return elm_str.properties
end

function Base.done(::AttributesIterator, cur_ptr)
    return cur_ptr == C_NULL
end

function Base.next(::AttributesIterator, cur_ptr)
    cur_str = unsafe_load(cur_ptr)
    text_ptr = ccall(
        (:xmlNodeGetContent, libxml2),
        Cstring,
        (Ptr{Void},),
        cur_str.children)
    if text_ptr == C_NULL
        throw_xml_error()
    end
    name = unsafe_wrap(String, cur_str.name)
    text = unsafe_wrap(String, text_ptr, true)
    return (name => text), cur_str.next
end
