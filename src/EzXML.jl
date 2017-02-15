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
    # istext,
    iscdata,
    iscomment,
    isdtd,
    hasdocument,
    document,
    name,
    setname!,
    content,
    setcontent!,
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
    depth,
    expandtree


if !isdefined(Base, :istext)
    # deprecated but not removed yet on Julia 0.5
    export istext
end

if is_windows()
    const libxml2 = Pkg.dir("WinRPM","deps","usr","$(Sys.ARCH)-w64-mingw32","sys-root","mingw","bin","libxml2-2")
else
    const libxml2 = "libxml2"
end

import Compat: @compat

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
