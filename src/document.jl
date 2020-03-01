# XML Document
# ============

"""
An XML/HTML document type.
"""
struct Document
    node::Node

    function Document(ptr::Ptr{_Node})
        @assert ptr != C_NULL
        ntype = unsafe_load(ptr).typ
        @assert ntype ∈ (DOCUMENT_NODE, HTML_DOCUMENT_NODE)
        return new(Node(ptr))
    end
end


# Document properties
# -------------------

@inline function Base.getproperty(doc::Document, name::Symbol)
    name == :version  ? (hasversion(doc)  ? version(doc)  : nothing) :
    name == :encoding ? (hasencoding(doc) ? encoding(doc) : nothing) :
    name == :root     ? (hasroot(doc)     ? root(doc)     : nothing) :
    name == :dtd      ? (hasdtd(doc)      ? dtd(doc)      : nothing) :
    Core.getfield(doc, name)
end


# Document constructors
# ---------------------

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

function Base.show(io::IO, doc::Document)
    prefix = "EzXML.Document"
    node = repr(doc.node)
    print(io, "$(prefix)($node)")
end

function Base.print(io::IO, doc::Document)
    print(io, doc.node)
end

"""
    prettyprint([io], doc::Document)

Print `doc` with formatting.
"""
function prettyprint(doc::Document)
    prettyprint(stdout, doc)
end

function prettyprint(io::IO, doc::Document)
    prettyprint(io, doc.node)
end

"""
    parsexml(xmlstring)

Parse `xmlstring` and create an XML document.
"""
function parsexml(xmlstring::AbstractString)
    if isempty(xmlstring)
        throw(ArgumentError("empty XML string"))
    end
    doc_ptr = @check ccall(
        (:xmlParseMemory, libxml2),
        Ptr{_Node},
        (Cstring, Cint),
        xmlstring, sizeof(xmlstring)) != C_NULL
    return Document(doc_ptr)
end

function parsexml(xmldata::Vector{UInt8})
    return parsexml(String(xmldata))
end

function parsexml(xmldata::Base.CodeUnits{UInt8,String})
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
    doc_ptr = @check ccall(
        (:htmlReadMemory, libxml2),
        Ptr{_Node},
        (Cstring, Cint, Cstring, Cstring, Cint),
        htmlstring, sizeof(htmlstring), url, encoding, options) != C_NULL
    show_warnings()
    return Document(doc_ptr)
end

function parsehtml(htmldata::Vector{UInt8})
    return parsehtml(String(htmldata))
end

function parsehtml(htmldata::Base.CodeUnits{UInt8,String})
    return parsehtml(String(htmldata))
end

"""
    readxml(filename)

Read `filename` and create an XML document.
"""
function readxml(filename::AbstractString)
    encoding = C_NULL
    # Do not reuse the context dictionary.
    options = 1 << 12
    doc_ptr = @check ccall(
        (:xmlReadFile, libxml2),
        Ptr{_Node},
        (Cstring, Ptr{UInt8}, Cint),
        filename, encoding, options) != C_NULL
    return Document(doc_ptr)
end

"""
    readxml(input::IO)

Read `input` and create an XML document.
"""
function readxml(input::IO)
    readcb = make_read_callback()
    closecb = C_NULL
    context = pointer_from_objref(input)
    uri = C_NULL
    encoding = C_NULL
    options = 0
    doc_ptr = @check ccall(
        (:xmlReadIO, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cstring, Cstring, Cint),
        readcb, closecb, context, uri, encoding, options) != C_NULL
    return Document(doc_ptr)
end

"""
    readhtml(filename)

Read `filename` and create an HTML document.
"""
function readhtml(filename::AbstractString)
    encoding = C_NULL
    options = 0
    doc_ptr = @check ccall(
        (:htmlReadFile, libxml2),
        Ptr{_Node},
        (Cstring, Cstring, Cint),
        filename, encoding, options) != C_NULL
    show_warnings()
    return Document(doc_ptr)
end

"""
    readhtml(input::IO)

Read `input` and create an HTML document.
"""
function readhtml(input::IO)
    readcb = make_read_callback()
    closecb = C_NULL
    context = pointer_from_objref(input)
    uri = C_NULL
    encoding = C_NULL
    options = 0
    doc_ptr = @check ccall(
        (:htmlReadIO, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cstring, Cstring, Cint),
        readcb, closecb, context, uri, encoding, options) != C_NULL
    show_warnings()
    return Document(doc_ptr)
end

function Base.write(filename::AbstractString, doc::Document)
    format = 0
    encoding = "UTF-8"
    ret = @check ccall(
        (:xmlSaveFormatFileEnc, libxml2),
        Cint,
        (Cstring, Ptr{Cvoid}, Cstring, Cint),
        filename, doc.node.ptr, encoding, format) != -1
    return Int(ret)
end

function make_read_callback()
    # Passing an input stream as an argument is impossible to create a callback
    # because Julia does not support C-callable closures yet.
    return @cfunction(Cint, (Ref{IO}, Ptr{UInt8}, Cint)) do context, buffer, len
        input = context
        avail = min(bytesavailable(input), len)
        if avail > 0
            unsafe_read(input, buffer, avail)
            read = avail
        elseif len > 0 && !eof(input)
            # An input stream may return bytesavailable = 0 before reading data.
            # So, read a byte to kick it ready.
            unsafe_store!(buffer, Base.read(input, UInt8))
            read = 1
        else
            read = 0
        end
        # debug
        # @show unsafe_string(buffer, read)
        return Cint(read)
    end
end


# Properties
# ----------

"""
    hasversion(doc::Document)

Return if `doc` has a version string.
"""
function hasversion(doc::Document)
    doc_ptr = Ptr{_Document}(doc.node.ptr)
    @assert doc_ptr != C_NULL
    return unsafe_load(doc_ptr).version != C_NULL
end

"""
    version(doc::Document)

Return the version string of `doc`.
"""
function version(doc::Document)
    if !hasversion(doc)
        throw(ArgumentError("no version string"))
    end
    doc_ptr = Ptr{_Document}(doc.node.ptr)
    @assert doc_ptr != C_NULL
    return unsafe_string(unsafe_load(doc_ptr).version)
end

"""
    hasencoding(doc::Document)

Return if `doc` has an encoding string.
"""
function hasencoding(doc::Document)
    doc_ptr = Ptr{_Document}(doc.node.ptr)
    @assert doc_ptr != C_NULL
    return unsafe_load(doc_ptr).encoding != C_NULL
end

"""
    encoding(doc::Document)

Return the encoding string of `doc`.
"""
function encoding(doc::Document)
    if !hasencoding(doc)
        throw(ArgumentError("no encoding string"))
    end
    doc_ptr = Ptr{_Document}(doc.node.ptr)
    @assert doc_ptr != C_NULL
    return unsafe_string(unsafe_load(doc_ptr).encoding)
end


# Root
# ----

"""
    hasroot(doc::Document)

Return if `doc` has a root element.
"""
function hasroot(doc::Document)
    ptr = ccall(
        (:xmlDocGetRootElement, libxml2),
        Ptr{Cvoid},
        (Ptr{Cvoid},),
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
    root_ptr = @check ccall(
        (:xmlDocGetRootElement, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid},),
        doc.node.ptr) != C_NULL
    return Node(root_ptr)
end

"""
    setroot!(doc::Document, node::Node)

Set the root element of `doc` to `node` and return the root element.
"""
function setroot!(doc::Document, root::Node)
    if !iselement(root)
        throw(ArgumentError("not an element node"))
    end
    old_root_ptr = ccall(
        (:xmlDocSetRootElement, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid}, Ptr{Cvoid}),
        doc.node.ptr, root.ptr)
    update_owners!(root, doc.node)
    if old_root_ptr != C_NULL
        old_root = Node(old_root_ptr)
        update_owners!(old_root, old_root)
    end
    return root
end


# DTD and validation
# ------------------

"""
    hasdtd(doc::Document)

Return if `doc` has a DTD node.
"""
function hasdtd(doc::Document)
    dtd_ptr = ccall(
        (:xmlGetIntSubset, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid},),
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
    dtd_ptr = @check ccall(
        (:xmlGetIntSubset, libxml2),
        Ptr{_Node},
        (Ptr{Cvoid},),
        doc.node.ptr) != C_NULL
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

struct _ValidCtxt
    # type tag
end

"""
    readdtd(filename::AbstractString)

Read `filename` and create a DTD node.
"""
function readdtd(filename::AbstractString)
    dtd_ptr = @check ccall(
        (:xmlParseDTD, libxml2),
        Ptr{_Node},
        (Cstring, Cstring),
        C_NULL, filename) != C_NULL
    return Node(dtd_ptr)
end

"""
    validate(doc::Document, [dtd::Node])

Validate `doc` against `dtd` and return the validation log.

The validation log is empty if and only if `doc` is valid. The DTD node in `doc`
will be used if `dtd` is not passed.
"""
function validate(doc::Document)
    ctxt_ptr = new_valid_context()
    @assert isempty(XML_GLOBAL_ERROR_STACK)
    valid = ccall(
        (:xmlValidateDocument, libxml2),
        Cint,
        (Ptr{Cvoid}, Ptr{Cvoid}),
        ctxt_ptr, doc.node.ptr)
    free(ctxt_ptr)
    @assert (valid == 1) == isempty(XML_GLOBAL_ERROR_STACK)
    log = copy(XML_GLOBAL_ERROR_STACK)
    empty!(XML_GLOBAL_ERROR_STACK)
    return log
end

function validate(doc::Document, dtd::Node)
    ctxt_ptr = new_valid_context()
    @assert isempty(XML_GLOBAL_ERROR_STACK)
    valid = ccall(
        (:xmlValidateDtd, libxml2),
        Cint,
        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
        ctxt_ptr, doc.node.ptr, dtd.ptr)
    free(ctxt_ptr)
    @assert (valid == 1) == isempty(XML_GLOBAL_ERROR_STACK)
    log = copy(XML_GLOBAL_ERROR_STACK)
    empty!(XML_GLOBAL_ERROR_STACK)
    return log
end

function new_valid_context()
    ctxt_ptr = @check ccall(
        (:xmlNewValidCtxt, libxml2),
        Ptr{_ValidCtxt},
        ()) != C_NULL
    return ctxt_ptr
end

function free(ptr::Ptr{_ValidCtxt})
    ccall(
        (:xmlFreeValidCtxt, libxml2),
        Cvoid,
        (Ptr{Cvoid},),
        ptr)
end
