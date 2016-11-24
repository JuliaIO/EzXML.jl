# XML Document
# ------------

"""
An XML/HTML document type.
"""
immutable Document
    node::Node

    function Document(ptr::Ptr{_Node})
        @assert ptr != C_NULL
        ntype = unsafe_load(ptr).typ
        @assert ntype ∈ (DOCUMENT_NODE, HTML_DOCUMENT_NODE)
        return new(Node(ptr))
    end
end

"""
    XMLDocument(version="1.0")

Create an XML document.
"""
function XMLDocument(version::AbstractString="1.0")
    node = XMLDocumentNode(version)
    return Document(node.ptr)
end

"""
    HTMLDocument(uri=nothing, externalID=nothing)

Create an HTML document.
"""
function HTMLDocument(uri=nothing, externalID=nothing)
    node = HTMLDocumentNode(uri, externalID)
    return Document(node.ptr)
end

function Base.print(io::IO, doc::Document)
    print(io, doc.node)
end

"""
    prettyprint([io], doc::Document)

Print `doc` with formatting.
"""
function prettyprint(doc::Document)
    prettyprint(STDOUT, doc)
end

function prettyprint(io::IO, doc::Document)
    prettyprint(io, doc.node)
end

function Base.parse(::Type{Document}, inputstring::AbstractString)
    if is_html_like(inputstring)
        return parsehtml(inputstring)
    else
        return parsexml(inputstring)
    end
end

function Base.parse(::Type{Document}, inputdata::Vector{UInt8})
    return parse(Document, String(inputdata))
end

# Try to infer whether an input is formatted in HTML.
function is_html_like(inputstring)
    if ismatch(r"^\s*<!DOCTYPE html", inputstring)
        return true
    elseif ismatch(r"^\s*<\?xml", inputstring)
        return false
    end
    i = searchindex(inputstring, "<html")
    if 0 < i < 100
        return true
    else
        return false
    end
end

"""
    parsexml(xmlstring)

Parse `xmlstring` and create an XML document.
"""
function parsexml(xmlstring::AbstractString)
    if isempty(xmlstring)
        throw(ArgumentError("empty XML string"))
    end
    ptr = ccall(
        (:xmlParseMemory, libxml2),
        Ptr{_Node},
        (Cstring, Cint),
        xmlstring, sizeof(xmlstring))
    if ptr == C_NULL
        throw_xml_error()
    end
    return Document(ptr)
end

function parsexml(xmldata::Vector{UInt8})
    return parsexml(String(xmldata))
end

"""
    parsehtml(htmlstring)

Parse `htmlstring` and create an HTML document.
"""
function parsehtml(htmlstring::AbstractString)
    if isempty(htmlstring)
        throw(ArgumentError("empty HTML string"))
    end
    url = C_NULL
    encoding = C_NULL
    options = 1
    ptr = ccall(
        (:htmlReadMemory, libxml2),
        Ptr{_Node},
        (Cstring, Cint, Cstring, Cstring, Cint),
        htmlstring, sizeof(htmlstring), url, encoding, options)
    if ptr == C_NULL
        throw_xml_error()
    end
    return Document(ptr)
end

function parsehtml(htmldata::Vector{UInt8})
    return parsehtml(String(htmldata))
end

function Base.read(::Type{Document}, filename::AbstractString)
    if endswith(filename, ".html") || endswith(filename, ".htm")
        return readhtml(filename)
    else
        return readxml(filename)
    end
end

"""
    readxml(filename)

Read `filename` and create an XML document.
"""
function readxml(filename::AbstractString)
    encoding = C_NULL
    options = 0
    ptr = ccall(
        (:xmlReadFile, libxml2),
        Ptr{_Node},
        (Cstring, Ptr{UInt8}, Cint),
        filename, encoding, options)
    if ptr == C_NULL
        throw_xml_error()
    end
    return Document(ptr)
end

"""
    readhtml(filename)

Read `filename` and create an HTML document.
"""
function readhtml(filename::AbstractString)
    encoding = C_NULL
    options = 0
    ptr = ccall(
        (:htmlReadFile, libxml2),
        Ptr{_Node},
        (Cstring, Cstring, Cint),
        filename, encoding, options)
    if ptr == C_NULL
        throw_xml_error()
    end
    return Document(ptr)
end

function Base.write(filename::AbstractString, doc::Document)
    format = 0
    encoding = "UTF-8"
    ret = ccall(
        (:xmlSaveFormatFileEnc, libxml2),
        Cint,
        (Cstring, Ptr{Void}, Cstring, Cint),
        filename, doc.node.ptr, encoding, format)
    if ret == -1
        throw_xml_error()
    end
    return Int(ret)
end

"""
    hasroot(doc::Document)

Return if `doc` has a root element.
"""
function hasroot(doc::Document)
    ptr = ccall(
        (:xmlDocGetRootElement, libxml2),
        Ptr{Void},
        (Ptr{Void},),
        doc.node.ptr)
    return ptr != C_NULL
end

"""
    root(doc::Document)

Return the root element of `doc`.
"""
function root(doc::Document)
    if !hasroot(doc)
        throw(ArgumentError("no root element"))
    end
    ptr = ccall(
        (:xmlDocGetRootElement, libxml2),
        Ptr{_Node},
        (Ptr{Void},),
        doc.node.ptr)
    if ptr == C_NULL
        throw_xml_error()
    end
    return Node(ptr)
end

"""
    setroot!(doc::Document, node::Node)

Set the root element of `doc` to `node` and return the root element.
"""
function setroot!(doc::Document, root::Node)
    if nodetype(root) != ELEMENT_NODE
        throw(ArgumentError("not an element node"))
    end
    old_root_ptr = ccall(
        (:xmlDocSetRootElement, libxml2),
        Ptr{_Node},
        (Ptr{Void}, Ptr{Void}),
        doc.node.ptr, root.ptr)
    update_owners!(root, doc.node)
    if old_root_ptr != C_NULL
        old_root = Node(old_root_ptr)
        update_owners!(old_root, old_root)
    end
    return root
end

"""
    hasdtd(doc::Document)

Return if `doc` has a DTD node.
"""
function hasdtd(doc::Document)
    dtd_ptr = ccall(
        (:xmlGetIntSubset, libxml2),
        Ptr{_Node},
        (Ptr{Void},),
        doc.node.ptr)
    return dtd_ptr != C_NULL
end

"""
    dtd(doc::Document)

Return the DTD node of `doc`.
"""
function dtd(doc::Document)
    if !hasdtd(doc)
        throw(ArgumentError("no DTD"))
    end
    dtd_ptr = ccall(
        (:xmlGetIntSubset, libxml2),
        Ptr{_Node},
        (Ptr{Void},),
        doc.node.ptr)
    return Node(dtd_ptr)
end

"""
    setdtd!(doc::Document, node::Node)

Set the DTD node of `doc` to `node` and return the DTD node.
"""
function setdtd!(doc::Document, node::Node)
    if !isdtd(node)
        throw(ArgumentError("not a DTD node"))
    elseif hasdtd(doc)
        unlink!(dtd(doc))
    end
    # Insert `node` as the first child of `doc.node`.
    if hasnode(doc.node)
        linkprev!(firstnode(doc.node), node)
    else
        link!(doc.node, node)
    end
    return node
end
