# Streaming XML Reader
# ====================

struct _TextReader
    # type tag
end

"""
A streaming XML reader type.
"""
mutable struct StreamReader
    ptr::Ptr{_TextReader}
    input::Union{IO,Cvoid}

    function StreamReader(ptr::Ptr{_TextReader}, input=nothing)
        @assert ptr != C_NULL
        return new(ptr, input)
    end
end

function Base.show(io::IO, reader::StreamReader)
    @printf(io, "EzXML.StreamReader(<%s@%p>)", repr(nodetype(reader)), reader.ptr)
end

# Reader type (enum xmlReaderTypes).
if sizeof(Cint) == 2
    primitive type ReaderType <: Integer 16 end
elseif sizeof(Cint) == 4
    primitive type ReaderType <: Integer 32 end
elseif sizeof(Cint) == 8
    primitive type ReaderType <: Integer 64 end
else
    @assert false "invalid Cint size"
end

function ReaderType(x::Integer)
    return convert(ReaderType, x)
end

function Base.convert(::Type{ReaderType}, x::Integer)
    return reinterpret(ReaderType, convert(Cint, x))
end

function Base.convert(::Type{T}, x::ReaderType) where {T<:Integer}
    return convert(T, reinterpret(Cint, x))
end

function Base.convert(::Type{ReaderType}, x::ReaderType)
    return x
end

function Base.promote_rule(::Type{ReaderType}, ::Type{T}) where {T<:Union{Cint,Int}}
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

function StreamReader(input::IO)
    readcb = make_read_callback()
    closecb = C_NULL
    context = pointer_from_objref(input)
    uri = C_NULL
    encoding = C_NULL
    options = 0
    reader_ptr = @check ccall(
        (:xmlReaderForIO, libxml2),
        Ptr{_TextReader},
        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cstring, Cstring, Cint),
        readcb, closecb, context, uri, encoding, options) != C_NULL
    return StreamReader(reader_ptr, input)
end

function Base.open(::Type{StreamReader}, filename::AbstractString)
    encoding = C_NULL
    options = 0
    reader_ptr = @check ccall(
        (:xmlReaderForFile, libxml2),
        Ptr{_TextReader},
        (Cstring, Cstring, Cint),
        filename, encoding, options) != C_NULL
    return StreamReader(reader_ptr)
end

function Base.close(reader::StreamReader)
    ccall(
        (:xmlFreeTextReader, libxml2),
        Cvoid,
        (Ptr{Cvoid},),
        reader.ptr)
    reader.ptr = C_NULL
    if reader.input isa IO
        close(reader.input)
    end
    return nothing
end

function Base.eltype(::Type{StreamReader})
    return ReaderType
end

if isdefined(Base, :IteratorSize)
    function Base.IteratorSize(::Type{StreamReader})
        return Base.SizeUnknown()
    end
else
    function Base.iteratorsize(::Type{StreamReader})
        return Base.SizeUnknown()
    end
end

function Base.start(::StreamReader)
    return nothing
end

function Base.done(reader::StreamReader, _=nothing)
    return read_node(reader)
end

function Base.next(reader::StreamReader, _)
    return nodetype(reader), nothing
end

function Base.next(reader::StreamReader)
    return nodetype(reader)
end

# Read a next node and return `true` iff finished.
function read_node(reader)
    ret = @check ccall(
        (:xmlTextReaderRead, libxml2),
        Cint,
        (Ptr{Cvoid},),
        reader.ptr) ≥ 0
    return ret == 0
end

"""
    nodedepth(reader::StreamReader)

Return the depth of the current node of `reader`.
"""
function nodedepth(reader::StreamReader)
    ret = ccall(
        (:xmlTextReaderDepth, libxml2),
        Cint,
        (Ptr{Cvoid},),
        reader.ptr)
    return Int(ret)
end

"""
    nodetype(reader::StreamReader)

Return the type of the current node of `reader`.
"""
function nodetype(reader::StreamReader)
    typ = ccall(
        (:xmlTextReaderNodeType, libxml2),
        Cint,
        (Ptr{Cvoid},),
        reader.ptr)
    return convert(ReaderType, typ)
end

"""
    nodename(reader::StreamReader)

Return the name of the current node of `reader`.
"""
function nodename(reader::StreamReader)
    name_ptr = ccall(
        (:xmlTextReaderConstName, libxml2),
        Cstring,
        (Ptr{Cvoid},),
        reader.ptr)
    if name_ptr == C_NULL
        throw(ArgumentError("no node name"))
    end
    return unsafe_string(name_ptr)
end

"""
    nodecontent(reader::StreamReader)

Return the content of the current node of `reader`.
"""
function nodecontent(reader::StreamReader)
    content_ptr = ccall(
        (:xmlTextReaderReadString, libxml2),
        Cstring,
        (Ptr{Cvoid},),
        reader.ptr)
    if content_ptr == C_NULL
        throw(ArgumentError("no content"))
    end
    content = unsafe_string(content_ptr)
    Libc.free(content_ptr)
    return content
end

function Base.haskey(reader::StreamReader, name::AbstractString)
    value_ptr = ccall(
        (:xmlTextReaderGetAttribute, libxml2),
        Cstring,
        (Ptr{Cvoid}, Cstring),
        reader.ptr, name)
    return value_ptr != C_NULL
end

function Base.getindex(reader::StreamReader, name::AbstractString)
    value_ptr = ccall(
        (:xmlTextReaderGetAttribute, libxml2),
        Cstring,
        (Ptr{Cvoid}, Cstring),
        reader.ptr, name)
    value = unsafe_string(value_ptr)
    Libc.free(value_ptr)
    return value
end

"""
    namespace(reader::StreamReader)

Return the namespace of the current node of `reader`.
"""
function namespace(reader::StreamReader)
    ns_ptr = ccall(
        (:xmlTextReaderConstNamespaceUri, libxml2),
        Cstring,
        (Ptr{Cvoid},),
        reader.ptr)
    if ns_ptr == C_NULL
        throw(ArgumentError("no namespace"))
    end
    return unsafe_string(ns_ptr)
end

"""
    expandtree(reader::StreamReader)

Expand the current node of `reader` into a full subtree that will be available
until the next read of node.

Note that the expanded subtree is a read-only and temporary object. You cannot
modify it or keep references to any nodes of it after reading the next node.

Currently, namespace functions and XPath query will not work on the expanded
subtree.
"""
function expandtree(reader::StreamReader)
    node_ptr = @check ccall(
        (:xmlTextReaderExpand, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid},),
        reader.ptr) != C_NULL
    # do not automatically free memories
    return Node(node_ptr, false)
end
