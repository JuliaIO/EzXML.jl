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
    hasversion,
    version,
    hasencoding,
    encoding,
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
    hasnodecontent,
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
    expandtree,
    hasnodevalue,
    nodevalue,
    hasnodeattributes,
    nodeattributes

using Libdl
using Printf: @printf

# Load libxml2.
const libxml2path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if !isfile(libxml2path)
    error("EzXML.jl is not installed properly, run Pkg.build(\"EzXML\") and restart Julia.")
end
include(libxml2path)
check_deps()

include("error.jl")
include("node.jl")
include("document.jl")
include("buffer.jl")
include("xpath.jl")
include("streamreader.jl")

function __init__()
    init_error_handler()
end

# deprcated methods
import Base: findall, findfirst, findlast
@deprecate findall(doc::Document, xpath::AbstractString)   findall(xpath, doc)
@deprecate findfirst(doc::Document, xpath::AbstractString) findfirst(xpath, doc)
@deprecate findlast(doc::Document, xpath::AbstractString)  findlast(xpath, doc)
@deprecate findall(node::Node, xpath::AbstractString, ns=namespaces(node))   findall(xpath, node, ns)
@deprecate findfirst(node::Node, xpath::AbstractString, ns=namespaces(node)) findfirst(xpath, node, ns)
@deprecate findlast(node::Node, xpath::AbstractString, ns=namespaces(node))  findlast(xpath, node, ns)

end # module
