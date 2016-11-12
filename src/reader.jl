# Streaming XML Reader
# --------------------

immutable _TextReader
    # type tag
end

"""
A streaming XML reader type.
"""
type XMLReader
    ptr::Ptr{_TextReader}

    function XMLReader(ptr::Ptr{_TextReader})
        @assert ptr != C_NULL
        return new(ptr)
    end
end

# Reader type (enum xmlReaderTypes).
if sizeof(Cint) == 2
    bitstype 16 ReaderType <: Integer
elseif sizeof(Cint) == 4
    bitstype 32 ReaderType <: Integer
elseif sizeof(Cint) == 8
    bitstype 64 ReaderType <: Integer
else
    @assert false "invalid Cint size"
end

function Base.convert(::Type{ReaderType}, x::Integer)
    return reinterpret(ReaderType, convert(Cint, x))
end

function Base.convert{T<:Integer}(::Type{T}, x::ReaderType)
    return convert(T, reinterpret(Cint, x))
end

function Base.convert(::Type{ReaderType}, x::ReaderType)
    return x
end

function Base.promote_rule{T<:Union{Cint,Int}}(::Type{ReaderType}, ::Type{T})
    return T
end

const READER_NONE                   = ReaderType( 0)
const READER_ELEMENT                = ReaderType( 1)
const READER_ATTRIBUTE              = ReaderType( 2)
const READER_TEXT                   = ReaderType( 3)
const READER_CDATA                  = ReaderType( 4)
const READER_ENTITY_REFERENCE       = ReaderType( 5)
const READER_ENTITY                 = ReaderType( 6)
const READER_PROCESSING_INSTRUCTION = ReaderType( 7)
const READER_COMMENT                = ReaderType( 8)
const READER_DOCUMENT               = ReaderType( 9)
const READER_DOCUMENT_TYPE          = ReaderType(10)
const READER_DOCUMENT_FRAGMENT      = ReaderType(11)
const READER_NOTATION               = ReaderType(12)
const READER_WHITESPACE             = ReaderType(13)
const READER_SIGNIFICANT_WHITESPACE = ReaderType(14)
const READER_END_ELEMENT            = ReaderType(15)
const READER_END_ENTITY             = ReaderType(16)
const READER_XML_DECLARATION        = ReaderType(17)

function Base.show(io::IO, x::ReaderType)
    if x == READER_NONE
        print(io, "READER_NONE")
    elseif x == READER_ELEMENT
        print(io, "READER_ELEMENT")
    elseif x == READER_ATTRIBUTE
        print(io, "READER_ATTRIBUTE")
    elseif x == READER_TEXT
        print(io, "READER_TEXT")
    elseif x == READER_CDATA
        print(io, "READER_CDATA")
    elseif x == READER_ENTITY_REFERENCE
        print(io, "READER_ENTITY_REFERENCE")
    elseif x == READER_ENTITY
        print(io, "READER_ENTITY")
    elseif x == READER_PROCESSING_INSTRUCTION
        print(io, "READER_PROCESSING_INSTRUCTION")
    elseif x == READER_COMMENT
        print(io, "READER_COMMENT")
    elseif x == READER_DOCUMENT
        print(io, "READER_DOCUMENT")
    elseif x == READER_DOCUMENT_TYPE
        print(io, "READER_DOCUMENT_TYPE")
    elseif x == READER_DOCUMENT_FRAGMENT
        print(io, "READER_DOCUMENT_FRAGMENT")
    elseif x == READER_NOTATION
        print(io, "READER_NOTATION")
    elseif x == READER_WHITESPACE
        print(io, "READER_WHITESPACE")
    elseif x == READER_SIGNIFICANT_WHITESPACE
        print(io, "READER_SIGNIFICANT_WHITESPACE")
    elseif x == READER_END_ELEMENT
        print(io, "READER_END_ELEMENT")
    elseif x == READER_END_ENTITY
        print(io, "READER_END_ENTITY")
    elseif x == READER_XML_DECLARATION
        print(io, "READER_XML_DECLARATION")
    else
        @assert false "unknown reader type"
    end
end

function Base.print(io::IO, x::ReaderType)
    print(io, convert(Cint, x))
end

function Base.open(::Type{XMLReader}, filename::AbstractString)
    encoding = C_NULL
    options = 0
    reader_ptr = ccall(
        (:xmlReaderForFile, libxml2),
        Ptr{_TextReader},
        (Cstring, Cstring, Cint),
        filename, encoding, options)
    if reader_ptr == C_NULL
        throw_xml_error()
    end
    return XMLReader(reader_ptr)
end

function Base.close(reader::XMLReader)
    ccall(
        (:xmlFreeTextReader, libxml2),
        Void,
        (Ptr{Void},),
        reader.ptr)
    reader.ptr = C_NULL
    return nothing
end

function Base.eltype(::Type{XMLReader})
    return ReaderType
end

function Base.iteratorsize(::Type{XMLReader})
    return Base.SizeUnknown()
end

function Base.start(::XMLReader)
    return nothing
end

function Base.done(reader::XMLReader, _=nothing)
    ret = read_node(reader)
    if ret == 0
        return true
    elseif ret == 1
        return false
    else
        error("reader error")
    end
end

function Base.next(reader::XMLReader, _)
    return nodetype(reader), nothing
end

function Base.next(reader::XMLReader)
    return nodetype(reader)
end

# Read a next node.
function read_node(reader)
    ccall(
        (:xmlTextReaderRead, libxml2),
        Cint,
        (Ptr{Void},),
        reader.ptr)
end

"""
    depth(reader::XMLReader)

Return the depth of the current node of `reader`.
"""
function depth(reader::XMLReader)
    ret = ccall(
        (:xmlTextReaderDepth, libxml2),
        Cint,
        (Ptr{Void},),
        reader.ptr)
    return Int(ret)
end

"""
    nodetype(reader::XMLReader)

Return the type of the current node of `reader`.
"""
function nodetype(reader::XMLReader)
    typ = ccall(
        (:xmlTextReaderNodeType, libxml2),
        Cint,
        (Ptr{Void},),
        reader.ptr)
    return convert(ReaderType, typ)
end

"""
    name(reader::XMLReader)

Return the name of the current node of `reader`.
"""
function name(reader::XMLReader)
    name_ptr = ccall(
        (:xmlTextReaderConstName, libxml2),
        Cstring,
        (Ptr{Void},),
        reader.ptr)
    if name_ptr == C_NULL
        throw(ArgumentError("no node name"))
    end
    return unsafe_string(name_ptr)
end

"""
    content(reader::XMLReader)

Return the content of the current node of `reader`.
"""
function content(reader::XMLReader)
    content_ptr = ccall(
        (:xmlTextReaderReadString, libxml2),
        Cstring,
        (Ptr{Void},),
        reader.ptr)
    if content_ptr == C_NULL
        throw(ArgumentError("no content"))
    end
    return unsafe_wrap(String, content_ptr, true)
end

function Base.getindex(reader::XMLReader, name::AbstractString)
    value_ptr = ccall(
        (:xmlTextReaderGetAttribute, libxml2),
        Cstring,
        (Ptr{Void}, Cstring),
        reader.ptr, name)
    return unsafe_wrap(String, value_ptr, true)
end

"""
    namespace(reader::XMLReader)

Return the namespace of the current node of `reader`.
"""
function namespace(reader::XMLReader)
    ns_ptr = ccall(
        (:xmlTextReaderConstNamespaceUri, libxml2),
        Cstring,
        (Ptr{Void},),
        reader.ptr)
    if ns_ptr == C_NULL
        throw(ArgumentError("no namespace"))
    end
    return unsafe_string(ns_ptr)
end

"""
    expandtree(reader::XMLReader)

Expand the current node of `reader` into a full subtree that will be available
until the next read of node.
"""
function expandtree(reader::XMLReader)
    node_ptr = ccall(
        (:xmlTextReaderExpand, libxml2),
        Ptr{_Node},
        (Ptr{Void},),
        reader.ptr)
    if node_ptr == C_NULL
        throw_xml_error()
    end
    # do not automatically free memories
    return Node(node_ptr, false)
end
