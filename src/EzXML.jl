module EzXML

export
    Node,
    XMLDocumentNode,
    HTMLDocumentNode,
    ElementNode,
    TextNode,
    CommentNode,
    CDataNode,
    AttributeNode,
    Document,
    XMLDocument,
    HTMLDocument,
    has_parent_node,
    parent_node,
    has_parent_element,
    parent_element,
    has_node,
    first_node,
    last_node,
    has_element,
    first_element,
    last_element,
    has_next_node,
    next_node,
    has_prev_node,
    prev_node,
    has_next_element,
    next_element,
    has_prev_element,
    prev_element,
    count_nodes,
    count_elements,
    count_attributes,
    link!,
    link_next!,
    link_prev!,
    unlink!,
    add_element!,
    has_root,
    root,
    set_root!,
    nodetype,
    has_document,
    document,
    name,
    set_name!,
    content,
    set_content!,
    each_node,
    nodes,
    each_element,
    elements,
    each_attribute,
    attributes,
    namespace,
    namespaces,
    readxml,
    readhtml,
    parsexml,
    parsehtml,
    XMLError

const libxml2 = "libxml2"

include("node.jl")
include("document.jl")
include("buffer.jl")
include("xpath.jl")
include("error.jl")

function __init__()
    init_error_handler()
end

end # module
