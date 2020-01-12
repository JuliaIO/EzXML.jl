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

using Printf: @printf
using XML2_jll: libxml2

include("error.jl")
include("node.jl")
include("document.jl")
include("buffer.jl")
include("xpath.jl")
include("streamreader.jl")

function __init__()
    init_error_handler()
end

end # module
