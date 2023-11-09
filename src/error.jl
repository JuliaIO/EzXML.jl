# Error Handling
# ==============
#
# XML error handling utils.

struct _Error
    domain::Cint
    code::Cint
    message::Cstring
    level::Cint
    file::Cstring
    line::Cint
    str1::Cstring
    str2::Cstring
    str3::Cstring
    int1::Cint
    int2::Cint
    ctxt::Ptr{Cvoid}
    node::Ptr{Cvoid}
end

"""
An error detected by libxml2.
"""
struct XMLError
    domain::Int
    code::Int
    message::String
    level::Int
    line::Int
end

function Base.showerror(io::IO, err::XMLError)
    print(io, "XMLError: $(err.message) from $(errordomain2string(err.domain)) (code: $(err.code), line: $(err.line))")
end

const XML_GLOBAL_ERROR_STACK = XMLError[]

# Error levels.
const XML_ERR_WARNING = Cint(1)  # A simple warning
const XML_ERR_ERROR   = Cint(2)  # A recoverable error
const XML_ERR_FATAL   = Cint(3)  # A fatal error

# Check return value of ccall.
macro check(ex)
    ccallex = ex.args[2]
    ex.args[2] = :ret
    quote
        @assert isempty(XML_GLOBAL_ERROR_STACK)
        ret = $(esc(ccallex))
        if !$(ex)
            throw_xml_error()
        end
        ret
    end
end

# Initialize an error handler.
function init_error_handler()
    error_handler = @cfunction(Cvoid, (Ptr{Cvoid}, Ptr{Cvoid})) do ctx, err_ptr
        if ctx == pointer_from_objref(_Error)
            err = unsafe_load(convert(Ptr{_Error}, err_ptr))
            push!(XML_GLOBAL_ERROR_STACK, XMLError(err.domain, err.code, chomp(unsafe_string(err.message)), err.level, err.line))
        end
        return
    end
    ccall(
        (:xmlSetStructuredErrorFunc, libxml2),
        Cvoid,
        (Ptr{Cvoid}, Ptr{Cvoid}),
        pointer_from_objref(_Error), error_handler)
end

# Throw an XMLError exception.
function throw_xml_error()
    if isempty(XML_GLOBAL_ERROR_STACK)
        error("unknown error of libxml2")
    elseif length(XML_GLOBAL_ERROR_STACK) > 1
        @warn("caught $(length(XML_GLOBAL_ERROR_STACK)) errors; throwing the first one")
    end
    # DEBUG
    # for err in XML_GLOBAL_ERROR_STACK
    #     @show err
    # end
    err = XML_GLOBAL_ERROR_STACK[1]
    empty!(XML_GLOBAL_ERROR_STACK)
    throw(err)
end

# Show warning massages if any.
function show_warnings(; noerror = false, nowarning = true)
    for err in XML_GLOBAL_ERROR_STACK
        noerror && err.level == XML_ERR_ERROR && continue
        nowarning && err.level == XML_ERR_WARNING && continue
        buf = IOBuffer()
        showerror(buf, err)
        @warn(String(take!(buf)))
    end
    empty!(XML_GLOBAL_ERROR_STACK)
end

# Convert an error domain number to a human-readable string.
function errordomain2string(domain)
    domain ==  1 ? "XML parser" :
    domain ==  2 ? "tree module" :
    domain ==  3 ? "XML Namespace module" :
    domain ==  4 ? "XML DTD validation with parser contex" :
    domain ==  5 ? "HTML parser" :
    domain ==  6 ? "memory allocator" :
    domain ==  7 ? "serialization code" :
    domain ==  8 ? "Input/Output stack" :
    domain ==  9 ? "FTP module" :
    domain == 10 ? "HTTP module" :
    domain == 11 ? "XInclude processing" :
    domain == 12 ? "XPath module" :
    domain == 13 ? "XPointer module" :
    domain == 14 ? "regular expressions module" :
    domain == 15 ? "W3C XML Schemas Datatype module" :
    domain == 16 ? "W3C XML Schemas parser module" :
    domain == 17 ? "W3C XML Schemas validation module" :
    domain == 18 ? "Relax-NG parser module" :
    domain == 19 ? "Relax-NG validator module" :
    domain == 20 ? "Catalog module" :
    domain == 21 ? "Canonicalization module" :
    domain == 22 ? "XSLT engine from libxslt" :
    domain == 23 ? "XML DTD validation with valid context" :
    domain == 24 ? "error checking module" :
    domain == 25 ? "xmlwriter module" :
    domain == 26 ? "dynamically loaded module modul" :
    domain == 27 ? "module handling character conversion" :
    domain == 28 ? "Schematron validator module" :
    domain == 29 ? "buffers module" :
    domain == 30 ? "URI module" : error("unknown domain: $(domain)")
end
