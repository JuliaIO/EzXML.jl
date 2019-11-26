# XPath
# =====

struct _XPathContext
    # type tag
end

struct _NodeSet
    nodeNr::Cint
    nodeMax::Cint
    nodeTab::Ptr{Ptr{_Node}}
end

const XPATH_UNDEFINED   = Cint(0)
const XPATH_NODESET     = Cint(1)
const XPATH_BOOLEAN     = Cint(2)
const XPATH_NUMBER      = Cint(3)
const XPATH_STRING      = Cint(4)
const XPATH_POINT       = Cint(5)
const XPATH_RANGE       = Cint(6)
const XPATH_LOCATIONSET = Cint(7)
const XPATH_USERS       = Cint(8)
const XPATH_XSLT_TREE   = Cint(9)

struct _XPathObject
    typ::Cint
    nodesetval::Ptr{_NodeSet}
    boolval::Cint
    floatval::Cdouble
    stringval::Ptr{UInt8}
    user::Ptr{Cvoid}
    index::Cint
    user2::Ptr{Cvoid}
    index2::Cint
end

"""
    findall(xpath::AbstractString, doc::Document)

Find nodes matching `xpath` XPath query from `doc`.
"""
function Base.findall(xpath::AbstractString, doc::Document)
    return findall(xpath, doc.node)
end

"""
    findfirst(xpath::AbstractString, doc::Document)

Find the first node matching `xpath` XPath query from `doc`.
"""
function Base.findfirst(xpath::AbstractString, doc::Document)
    # string("(", xpath, ")[position()=1]") may be faster
    nodes = findall(xpath, doc)
    return isempty(nodes) ? nothing : first(nodes)
end

"""
    findlast(doc::Document, xpath::AbstractString)

Find the last node matching `xpath` XPath query from `doc`.
"""
function Base.findlast(xpath::AbstractString, doc::Document)
    # string("(", xpath, ")[position()=last()]") may be faster
    nodes = findall(xpath, doc)
    return isempty(nodes) ? nothing : last(nodes)
end

"""
    findall(xpath::AbstractString, node::Node, [ns=namespaces(node)])

Find nodes matching `xpath` XPath query starting from `node`.

The `ns` argument is an iterator of namespace prefix and URI pairs.
"""
function Base.findall(xpath::AbstractString, node::Node, ns=namespaces(node))
    if !ismanaged(node)
        throw(ArgumentError("XPath query on the unmanaged node"))
    end
    context_ptr = new_xpath_context(document(node))
    if context_ptr == C_NULL
        throw_xml_error()
    end
    for (prefix, uri) in ns
        if isempty(prefix)
            @warn "ignored the empty prefix for '$(uri)'; expected to be non-empty"
        else
            ret = register_namespace!(context_ptr, prefix, uri)
            @assert ret == 0
        end
    end
    result_ptr = eval_xpath(node, context_ptr, xpath)
    if result_ptr == C_NULL
        free(context_ptr)
        throw_xml_error()
    end
    try
        result = unsafe_load(result_ptr)
        @assert result.typ == XPATH_NODESET
        if result.nodesetval == C_NULL
            return Vector{Node}()
        end
        nodeset = unsafe_load(result.nodesetval)
        # I don't know why, but this fails to infer the type of elements.
        return Node[Node(unsafe_load(nodeset.nodeTab, i)) for i in 1:nodeset.nodeNr]
    catch
        rethrow()
    finally
        free(context_ptr)
        free(result_ptr)
    end
end

"""
    findfirst(xpath::AbstractString, node::Node, [ns=namespaces(node)])

Find the first node matching `xpath` XPath query starting from `node`.
"""
function Base.findfirst(xpath::AbstractString, node::Node, ns=namespaces(node))
    # string("(", xpath, ")[position()=1]") may be faster
    nodes = findall(xpath, node, ns)
    return isempty(nodes) ? nothing : first(nodes)
end

"""
    findlast(node::Node, xpath::AbstractString, [ns=namespaces(node)])

Find the last node matching `xpath` XPath query starting from `node`.
"""
function Base.findlast(xpath::AbstractString, node::Node, ns=namespaces(node))
    # string("(", xpath, ")[position()=last()]") may be faster
    nodes = findall(xpath, node, ns)
    return isempty(nodes) ? nothing : last(nodes)
end

function new_xpath_context(doc)
    context_ptr = ccall(
        (:xmlXPathNewContext, libxml2),
        Ptr{_XPathContext},
        (Ptr{_XPathObject},),
        doc.node.ptr)
    return context_ptr
end

function register_namespace!(context_ptr, prefix, uri)
    ret = ccall(
        (:xmlXPathRegisterNs, libxml2),
        Cint,
        (Ptr{Cvoid}, Cstring, Cstring),
        context_ptr, prefix, uri)
    return ret
end

function eval_xpath(node, context_ptr, xpath)
    # set the pointer to `node` in the cotnext
    unsafe_store!(Ptr{UInt}(context_ptr), convert(UInt, node.ptr), 2)
    result_ptr = ccall(
        (:xmlXPathEval, libxml2),
        Ptr{_XPathObject},
        (Cstring, Ptr{Cvoid}),
        xpath, context_ptr)
    return result_ptr
end

function free(ptr::Ptr{_XPathContext})
    ccall(
        (:xmlXPathFreeContext, libxml2),
        Cvoid,
        (Ptr{Cvoid},),
        ptr)
end

function free(ptr::Ptr{_XPathObject})
    ccall(
        (:xmlXPathFreeObject, libxml2),
        Cvoid,
        (Ptr{Cvoid},),
        ptr)
end
