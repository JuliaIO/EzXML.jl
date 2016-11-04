module EzXML

export
    Node,
    ElementNode,
    TextNode,
    CommentNode,
    CDataNode,
    DocumentNode,
    Document,
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
    add_node!,
    add_next_sibling!,
    add_prev_sibling!,
    add_element!,
    count_nodes,
    count_elements,
    count_attributes,
    unlink_node!,
    has_root,
    root,
    set_root!,
    nodetype,
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
