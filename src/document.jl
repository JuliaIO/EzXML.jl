# XML Document
# ------------

"""
An XML document type.
"""
immutable Document
    node::Node

    function Document(ptr::Ptr{_Node})
        @assert ptr != C_NULL
        @assert unsafe_load(ptr).typ == 9
        return new(Node(ptr))
    end
end

function Document(version::AbstractString="1.0")
    node = DocumentNode(version)
    return Document(node.ptr)
end

function Base.print(io::IO, doc::Document)
    print(io, doc.node)
end

function Base.parse(::Type{Document}, xmlstring::AbstractString)
    if isempty(xmlstring)
        throw(ArgumentError("empty XML string"))
    end
    ptr = ccall(
        (:xmlParseMemory, libxml2),
        Ptr{_Node},
        (Cstring, Cint),
        xmlstring, length(xmlstring))
    if ptr == C_NULL
        throw_xml_error()
    end
    return Document(ptr)
end

function Base.read(::Type{Document}, filename::AbstractString)
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
    has_root(doc::Document)

Return if `doc` has a root element.
"""
function has_root(doc::Document)
    ptr = ccall(
        (:xmlDocGetRootElement, libxml2),
        Ptr{Void},
        (Ptr{Void},),
        doc.node.ptr)
    return ptr != C_NULL
end

"""
    root(doc::Document)

Return the root node of `doc`.
"""
function root(doc::Document)
    if !has_root(doc)
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
