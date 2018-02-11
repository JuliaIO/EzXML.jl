__precompile__()

module EzXML

export
    # Types
    # -----
    # NOTE: These are not exported but considered as public APIs.
    # Node,
    # Document,
    # XMLError,
    # StreamReader,

    # Node constructors
    # -----------------
    XMLDocumentNode,
    HTMLDocumentNode,
    ElementNode,
    TextNode,
    CommentNode,
    CDataNode,
    AttributeNode,
    DTDNode,

    # Document constructors
    # ---------------------
    XMLDocument,
    HTMLDocument,

    # Functions
    # ---------
    hasparentnode,
    parentnode,
    hasparentelement,
    parentelement,
    hasnode,
    firstnode,
    lastnode,
    haselement,
    firstelement,
    lastelement,
    hasnextnode,
    nextnode,
    hasprevnode,
    prevnode,
    hasnextelement,
    nextelement,
    hasprevelement,
    prevelement,
    countnodes,
    countelements,
    countattributes,
    link!,
    linknext!,
    linkprev!,
    unlink!,
    addelement!,
    hasroot,
    root,
    setroot!,
    hasdtd,
    dtd,
    setdtd!,
    nodetype,
    nodepath,
    iselement,
    isattribute,
    istext,
    iscdata,
    iscomment,
    isdtd,
    hasdocument,
    document,
    nodename,
    setnodename!,
    nodecontent,
    setnodecontent!,
    systemID,
    externalID,
    eachnode,
    nodes,
    eachelement,
    elements,
    eachattribute,
    attributes,
    namespace,
    namespaces,
    prettyprint,
    readxml,
    readhtml,
    parsexml,
    parsehtml,
    readdtd,
    validate,
    nodedepth,
    expandtree

# Load libxml2.
const libxml2path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if !isfile(libxml2path)
    error("EzXML.jl is not installed properly, run Pkg.build(\"EzXML\") and restart Julia.")
end
include(libxml2path)
check_deps()

if VERSION > v"0.7.0-DEV.3052"
    import Printf: @printf
end

if !isdefined(Base, :Cvoid)
    const Cvoid = Void
end

include("error.jl")
include("node.jl")
include("document.jl")
include("buffer.jl")
include("xpath.jl")
include("streamreader.jl")

function __init__()
    init_error_handler()
end


# Deprecation
# -----------

function Base.read(::Type{Document}, filename::AbstractString)
    @static if VERSION > v"0.7-"
        @warn "read(Document, filename) is deprecated, use readxml(filename) or readhtml(filename) instead"
    else
        warn("read(Document, filename) is deprecated, use readxml(filename) or readhtml(filename) instead")
    end
    if endswith(filename, ".html") || endswith(filename, ".htm")
        return readhtml(filename)
    else
        return readxml(filename)
    end
end

function Base.parse(::Type{Document}, inputstring::AbstractString)
    @static if VERSION > v"0.7-"
        @warn "parse(Document, string) is deprecated, use parsexml(string) or parsehtml(string) instead"
    else
        warn("parse(Document, string) is deprecated, use parsexml(string) or parsehtml(string) instead")
    end
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

end # module
