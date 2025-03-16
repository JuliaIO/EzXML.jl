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
    function StreamReader(input::IO)
        readcb = make_read_callback(StreamReader)
        closecb = C_NULL
        uri = C_NULL
        encoding = C_NULL
        options = 0
        reader = new(C_NULL, input)
        reader.ptr = @check ccall(
            (:xmlReaderForIO, libxml2),
            Ptr{_TextReader},
            (Ptr{Cvoid}, Ptr{Cvoid}, Ref{StreamReader}, Cstring, Cstring, Cint),
            readcb, closecb, reader, uri, encoding, options) != C_NULL
        return reader
    end
end
Base.unsafe_convert(::Type{Ptr{Cvoid}}, reader::StreamReader) = reader.ptr

Base.propertynames(x::StreamReader) = (
    :type, :depth, :name, :content, :namespace,
    fieldnames(typeof(x))...
)

@inline function Base.getproperty(reader::StreamReader, name::Symbol)
    name == :type      ? nodetype(reader)                                         :
    name == :depth     ? nodedepth(reader)                                        :
    name == :name      ? (hasnodename(reader)    ? nodename(reader)    : nothing) :
    name == :content   ? (hasnodecontent(reader) ? nodecontent(reader) : nothing) :
    name == :namespace ? namespace(reader)                                        :
    Core.getfield(reader, name)
end

function Base.show(io::IO, reader::StreamReader)
    prefix = isdefined(Main, :StreamReader) ? "StreamReader" : "EzXML.StreamReader"
    @printf(io, "%s(<%s@%p>)", prefix, repr(nodetype(reader)), reader.ptr)
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

Base.hash(x::ReaderType, h::UInt) = hash(convert(Cint,x), h)

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

function Base.string(x::ReaderType)
    return sprint(print, x)
end

read_callback_get_input(reader::StreamReader) = reader.input

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
        reader)
    reader.ptr = C_NULL
    if reader.input isa IO
        close(reader.input)
    end
    return nothing
end

function Base.eltype(::Type{StreamReader})
    return ReaderType
end

function Base.IteratorSize(::Type{StreamReader})
    return Base.SizeUnknown()
end

function Base.iterate(reader::StreamReader, state=nothing)
    if read_node(reader)
        nothing
    else
        nodetype(reader), nothing
    end
end

# Read a next node and return `true` iff finished.
function read_node(reader)
    ret = @check ccall(
        (:xmlTextReaderRead, libxml2),
        Cint,
        (Ptr{Cvoid},),
        reader) ≥ 0
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
        reader)
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
        reader)
    return convert(ReaderType, typ)
end

"""
    hasnodename(reader::StreamReader)

Return if the current node of `reader` has a node name.
"""
function hasnodename(reader::StreamReader)
    return ccall(
        (:xmlTextReaderConstName, libxml2),
        Cstring,
        (Ptr{Cvoid},),
        reader) != C_NULL
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
        reader)
    if name_ptr == C_NULL
        throw(ArgumentError("no node name"))
    end
    return unsafe_string(name_ptr)
end

"""
    hasnodecontent(reader::StreamReader)

Return if the current node of `reader` has content.
"""
function hasnodecontent(reader::StreamReader)
    if nodetype(reader) == READER_ATTRIBUTE
        return false
    end
    # TODO: this allocates memory; any way to avoid it?
    ptr = ccall(
        (:xmlTextReaderReadString, libxml2),
        Cstring,
        (Ptr{Cvoid},),
        reader)
    if ptr == C_NULL
        return false
    else
        Libc.free(ptr)
        return true
    end
end

"""
    nodecontent(reader::StreamReader)

Return the content of the current node of `reader`.
"""
function nodecontent(reader::StreamReader)
    if nodetype(reader) == READER_ATTRIBUTE
        throw(ArgumentError("no content"))
    end
    content_ptr = ccall(
        (:xmlTextReaderReadString, libxml2),
        Cstring,
        (Ptr{Cvoid},),
        reader)
    if content_ptr == C_NULL
        throw(ArgumentError("no content"))
    end
    content = unsafe_string(content_ptr)
    Libc.free(content_ptr)
    return content
end

"""
    hasnodevalue(reader::StreamReader)

Return if the current node of `reader` has a value.
"""
function hasnodevalue(reader::StreamReader)
    r = ccall(
       (:xmlTextReaderHasValue, libxml2),
       Cint,
       (Ptr{Cvoid},),
       reader)
    return r == 1
end

"""
    nodevalue(reader::StreamReader)

Return the value of the current node of `reader`.

This can be different from `nodecontent`.
"""
function nodevalue(reader::StreamReader)
    value_ptr = ccall(
        (:xmlTextReaderConstValue, libxml2),
        Cstring,
        (Ptr{Cvoid},),
        reader)
    if value_ptr == C_NULL
        throw(ArgumentError("no node value"))
    end
    return unsafe_string(value_ptr)
end

"""
    hasnodeattributes(reader::StreamReader)

Return if the current node of 'reader' has attributes
"""
function hasnodeattributes(reader::StreamReader)
    r = ccall(
       (:xmlTextReaderHasAttributes, libxml2),
       Cint,
       (Ptr{Cvoid},),
       reader)
    @assert r ≥ 0 "XML Error Detected"
    return r == 1
end

struct AttributeReader
    reader::StreamReader

    function AttributeReader(reader::StreamReader)
        if nodetype(reader) != READER_ELEMENT
            throw(ArgumentError("Reader not an Element Node"))
        end
        return new(reader)
    end
end

function Base.eltype(::Type{AttributeReader})
    return StreamReader
end

function Base.IteratorSize(::Type{AttributeReader})
    return Base.SizeUnknown()
end

function Base.iterate(attrs::AttributeReader, state=nothing)
    r = ccall(
        (:xmlTextReaderMoveToNextAttribute, libxml2),
        Cint,
        (Ptr{Cvoid},),
        attrs.reader)
    if r == 1
        return attrs.reader, nothing
    end
    if nodetype(attrs.reader) == READER_ATTRIBUTE
        r = ccall(
            (:xmlTextReaderMoveToElement, libxml2),
            Cint,
            (Ptr{Cvoid},),
            attrs.reader)
        @assert r == 1
    end
    return nothing
end

"""
    eachattribute(reader::StreamReader)

Return an `AttributeReader` object for the current node of `reader`
"""
eachattribute(reader::StreamReader) = AttributeReader(reader)

"""
    countattributes(reader::StreamReader)

Count the number of attributes in the current node of `reader`.
"""
function countattributes(reader::StreamReader)
    r = ccall(
        (:xmlTextReaderAttributeCount, libxml2),
        Cint,
        (Ptr{Cvoid},),
        reader)
    return Int(r)
end

"""
    nodeattributes(reader::StreamReader)

Return a dictionary of the attributes in the current node of `reader`.
"""
function nodeattributes(reader::StreamReader)
    attrs = Dict{String,String}()
    for attr in eachattribute(reader)
        attrs[nodename(attr)] = nodevalue(attr)
    end
    return attrs
end

function attribute_ptr(reader::StreamReader, name::AbstractString)
    value_ptr = ccall(
        (:xmlTextReaderGetAttribute, libxml2),
        Cstring,
        (Ptr{Cvoid}, Cstring),
        reader, name)
end

function attribute_ptr(reader::StreamReader, no::Integer)
    value_ptr = ccall(
        (:xmlTextReaderGetAttributeNo, libxml2),
        Cstring,
        (Ptr{Cvoid}, Cint),
        reader, Cint(no - 1))
end

"""
    haskey(reader::StreamReader, key::Union{Integer,AbstractString})

Check if current node of `reader` has attribute `key`.
"""
function Base.haskey(reader::StreamReader, key::Union{Integer,AbstractString})
    value_ptr = attribute_ptr(reader, key)
    ret = value_ptr != C_NULL
    Libc.free(value_ptr)
    return ret
end

"""
    getindex(reader::StreamReader, key::Union{Integer,AbstractString})

Get attribute `key` at current node of `reader`.
"""
function Base.getindex(reader::StreamReader, key::Union{Integer,AbstractString})
    value_ptr = attribute_ptr(reader, key)
    if value_ptr == C_NULL
        throw(KeyError(key))
    end
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
        reader)
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
        reader) != C_NULL
    # do not automatically free memories
    return Node(node_ptr, false)
end
