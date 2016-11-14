module EzXML

export
    # types
    Node,
    Document,
    XMLError,
    XMLReader,

    # node constructors
    XMLDocumentNode,
    HTMLDocumentNode,
    ElementNode,
    TextNode,
    CommentNode,
    CDataNode,
    AttributeNode,

    # document constructors
    XMLDocument,
    HTMLDocument,

    # functions
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
    nodetype,
    iselement,
    isattribute,
    istext,
    iscdata,
    iscomment,
    hasdocument,
    document,
    name,
    setname!,
    content,
    setcontent!,
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
    depth,
    expandtree

if is_windows()
    const libxml2 = Pkg.dir("WinRPM","deps","usr","$(Sys.ARCH)-w64-mingw32","sys-root","mingw","bin","libxml2-2")
else
    const libxml2 = "libxml2"
end

include("node.jl")
include("document.jl")
include("buffer.jl")
include("xpath.jl")
include("reader.jl")
include("error.jl")

function __init__()
    init_error_handler()
end

end # module
