# Error Handling
# --------------
#
# XML error handling utils.

immutable _Error
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
    ctxt::Ptr{Void}
    node::Ptr{Void}
end

"""
An error detected by libxml2.
"""
immutable XMLError
    domain::Int
    message::String
end

function Base.showerror(io::IO, err::XMLError)
    print(io, "XMLError: ", err.message, " (from ", errordomain2string(err.domain), ")")
end

const XML_GLOBAL_ERROR_STACK = _Error[]

# Initialize an error handler.
function init_error_handler()
    error_handler = cfunction(Void, (Ptr{Void}, Ptr{Void})) do ctx, err_ptr
        if ctx === C_NULL
            err = unsafe_load(convert(Ptr{_Error}, err_ptr))
            push!(XML_GLOBAL_ERROR_STACK, err)
        end
        return
    end
    ccall(
        (:xmlSetStructuredErrorFunc, libxml2),
        Void,
        (Ptr{Void}, Ptr{Void}),
        C_NULL, error_handler)
end

# Throw an XMLError exception.
function throw_xml_error()
    @assert !isempty(XML_GLOBAL_ERROR_STACK)
    if length(XML_GLOBAL_ERROR_STACK) > 1
        warn("caught some errors; show the last one")
    end
    err_str = pop!(XML_GLOBAL_ERROR_STACK)
    msg = chomp(unsafe_string(err_str.message))
    throw(XMLError(err_str.domain, msg))
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
