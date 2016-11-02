# XPath
# -----

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

function Base.find(doc::Document, xpath::AbstractString)
    context_ptr = make_xpath_context(doc)
    if context_ptr == C_NULL
        throw_xml_error()
    end
    result_ptr = eval_xpath(context_ptr, xpath)
    if result_ptr == C_NULL
        free(context_ptr)
        throw_xml_error()
    end
    result = unsafe_load(result_ptr)
    if result.typ != XPATH_NODESET || result.nodesetval == C_NULL
        free(context_ptr)
        free(result_ptr)
        throw_xml_error()
    end
    try
        nodeset = unsafe_load(result.nodesetval)
        return [Node(unsafe_load(nodeset.nodeTab, i)) for i in 1:nodeset.nodeNr]
    catch
        rethrow()
    finally
        free(context_ptr)
        # Does this release nodesetval?
        free(result_ptr)
    end
end

function Base.findfirst(doc::Document, xpath::AbstractString)
    # string("(", xpath, ")[position()=1]") may be faster
    return first(find(doc, xpath))
end

function Base.findlast(doc::Document, xpath::AbstractString)
    # string("(", xpath, ")[position()=last()]") may be faster
    return last(find(doc, xpath))
end

function Base.find(node::Node, xpath::AbstractString)
    context_ptr = make_xpath_context(document(node))
    if context_ptr == C_NULL
        throw_xml_error()
    end
    result_ptr = eval_xpath(node, context_ptr, xpath)
    if result_ptr == C_NULL
        free(context_ptr)
        throw_xml_error()
    end
    result = unsafe_load(result_ptr)
    if result.typ != XPATH_NODESET || result.nodesetval == C_NULL
        free(context_ptr)
        free(result_ptr)
        throw_xml_error()
    end
    try
        nodeset = unsafe_load(result.nodesetval)
        return [Node(unsafe_load(nodeset.nodeTab, i)) for i in 1:nodeset.nodeNr]
    catch
        rethrow()
    finally
        free(context_ptr)
        # Does this release nodesetval?
        free(result_ptr)
    end
end

function Base.findfirst(node::Node, xpath::AbstractString)
    # string("(", xpath, ")[position()=1]") may be faster
    return first(find(node, xpath))
end

function Base.findlast(node::Node, xpath::AbstractString)
    # string("(", xpath, ")[position()=last()]") may be faster
    return last(find(node, xpath))
end

function make_xpath_context(doc)
    context_ptr = ccall(
        (:xmlXPathNewContext, libxml2),
        Ptr{_XPathContext},
        (Ptr{_XPathObject},),
        doc.node.ptr)
    return context_ptr
end

function eval_xpath(context_ptr, xpath)
    result_ptr = ccall(
        (:xmlXPathEval, libxml2),
        Ptr{_XPathObject},
        (Cstring, Ptr{Void}),
        xpath, context_ptr)
    return result_ptr
end

function eval_xpath(node, context_ptr, xpath)
    result_ptr = ccall(
        (:xmlXPathNodeEval, libxml2),
        Ptr{_XPathObject},
        (Ptr{Void}, Cstring, Ptr{Void}),
        node.ptr, xpath, context_ptr)
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

function free(ptr::Ptr{_NodeSet})
    ccall(
        (:xmlXPathFreeNodeSet, libxml2),
        Void,
        (Ptr{Void},),
        ptr)
end
