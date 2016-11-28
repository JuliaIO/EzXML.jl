# XPath
# =====

immutable _XPathContext
    # type tag
end

immutable _NodeSet
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

immutable _XPathObject
    typ::Cint
    nodesetval::Ptr{_NodeSet}
    boolval::Cint
    floatval::Cdouble
    stringval::Ptr{UInt8}
    user::Ptr{Void}
    index::Cint
    user2::Ptr{Void}
    index2::Cint
end

"""
    find(doc::Document, xpath::AbstractString)

Find nodes matching `xpath` XPath query from `doc`.
"""
function Base.find(doc::Document, xpath::AbstractString)
    return find(doc.node, xpath)
end

"""
    findfirst(doc::Document, xpath::AbstractString)

Find the first node matching `xpath` XPath query from `doc`.
"""
function Base.findfirst(doc::Document, xpath::AbstractString)
    return findfirst(doc.node, xpath)
end

"""
    findlast(doc::Document, xpath::AbstractString)

Find the last node matching `xpath` XPath query from `doc`.
"""
function Base.findlast(doc::Document, xpath::AbstractString)
    return findlast(doc.node, xpath)
end

"""
    find(node::Node, xpath::AbstractString, [ns=namespaces(node)])

Find nodes matching `xpath` XPath query starting from `node`.

The `ns` argument is an iterator of namespace prefix and URI pairs.
"""
function Base.find(node::Node, xpath::AbstractString, ns=namespaces(node))::Vector{Node}
    if is_asterisk(xpath)
        return elements(node)
    elseif is_ncname(xpath)
        node_ptr = first_element_ptr(node.ptr)
        nodes = Node[]
        while node_ptr != C_NULL
            if is_named_as(node_ptr, xpath)
                push!(nodes, Node(node_ptr))
            end
            node_ptr = next_element_ptr(node_ptr)
        end
        return nodes
    end
    context_ptr = new_xpath_context(document(node))
    if context_ptr == C_NULL
        throw_xml_error()
    end
    for (prefix, uri) in ns
        ret = register_namespace!(context_ptr, prefix, uri)
        @assert ret == 0
    end
    result_ptr = eval_xpath(node, context_ptr, xpath)
    if result_ptr == C_NULL
        free(context_ptr)
        throw_xml_error()
    end
    try
        result = unsafe_load(result_ptr)
        @assert result.typ == XPATH_NODESET
        @assert result.nodesetval != C_NULL
        nodeset = unsafe_load(result.nodesetval)
        return [Node(unsafe_load(nodeset.nodeTab, i)) for i in 1:nodeset.nodeNr]
    catch
        rethrow()
    finally
        free(context_ptr)
        free(result_ptr)
    end
end

"""
    findfirst(node::Node, xpath::AbstractString, [ns=namespaces(node)])

Find the first node matching `xpath` XPath query starting from `node`.
"""
function Base.findfirst(node::Node, xpath::AbstractString, ns=namespaces(node))
    if is_asterisk(xpath)  # any element
        node_ptr = first_element_ptr(node.ptr)
        if node_ptr == C_NULL
            throw_no_matching_error()
        end
        return Node(node_ptr)
    elseif is_ncname(xpath)  # without namespace prefix
        node_ptr = first_element_ptr(node.ptr)
        while node_ptr != C_NULL
            if is_named_as(node_ptr, xpath)
                return Node(node_ptr)
            end
            node_ptr = next_element_ptr(node_ptr)
        end
        throw_no_matching_error()
    #elseif is_qname(xpath)  # with namespace prefix
    # TODO
    else
        ret = find(node, xpath, ns)
        if isempty(ret)
            throw_no_matching_error()
        end
        return first(ret)
    end
end

"""
    findlast(node::Node, xpath::AbstractString, [ns=namespaces(node)])

Find the last node matching `xpath` XPath query starting from `node`.
"""
function Base.findlast(node::Node, xpath::AbstractString, ns=namespaces(node))
    if is_asterisk(xpath)  # any element
        node_ptr = last_element_ptr(node.ptr)
        if node_ptr == C_NULL
            throw_no_matching_error()
        end
        return Node(node_ptr)
    elseif is_ncname(xpath)  # without namespace prefix
        node_ptr = last_element_ptr(node.ptr)
        while node_ptr != C_NULL
            if is_named_as(node_ptr, xpath)
                return Node(node_ptr)
            end
            node_ptr = prev_element_ptr(node_ptr)
        end
        throw_no_matching_error()
    # elseif is_qname(xpath)  # with namespace prefix
    # TODO
    else
        ret = find(node, xpath, ns)
        if isempty(ret)
            throw_no_matching_error()
        end
        return last(ret)
    end
end

function throw_no_matching_error()
    throw(ArgumentError("no matching nodes"))
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
        (Ptr{Void}, Cstring, Cstring),
        context_ptr, prefix, uri)
    return ret
end

function eval_xpath(node, context_ptr, xpath)
    # set the pointer to `node` in the cotnext
    unsafe_store!(Ptr{UInt}(context_ptr), convert(UInt, node.ptr), 2)
    result_ptr = ccall(
        (:xmlXPathEval, libxml2),
        Ptr{_XPathObject},
        (Cstring, Ptr{Void}),
        xpath, context_ptr)
    return result_ptr
end

function free(ptr::Ptr{_XPathContext})
    ccall(
        (:xmlXPathFreeContext, libxml2),
        Void,
        (Ptr{Void},),
        ptr)
end

function free(ptr::Ptr{_XPathObject})
    ccall(
        (:xmlXPathFreeObject, libxml2),
        Void,
        (Ptr{Void},),
        ptr)
end

# Check if `node` is named as `name` (same as `name(node) == name` but faster).
function is_named_as(node_ptr, name)
    node_str = unsafe_load(node_ptr)
    if node_str.name == C_NULL
        return false
    end
    ret = ccall(
        (:xmlStrEqual, libxml2),
        Cint,
        (Cstring, Cstring),
        node_str.name, name)
    return ret == 1
end

function is_asterisk(name)
    return name == "*"
end

function is_ncname(name)
    return ccall(
        (:xmlValidateNCName, libxml2),
        Cint,
        (Cstring, Cint),
        name, 0) == 0
end

function is_qname(name)
    return ccall(
        (:xmlValidateQName, libxml2),
        Cint,
        (Cstring, Cint),
        name, 0) == 0
end
