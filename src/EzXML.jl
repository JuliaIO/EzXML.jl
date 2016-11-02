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
    has_child_node,
    first_child_node,
    last_child_node,
    has_child_element,
    first_child_element,
    last_child_element,
    has_next_node,
    next_node,
    has_prev_node,
    prev_node,
    has_next_element,
    next_element,
    has_prev_element,
    prev_element,
    add_child_node!,
    add_next_sibling!,
    add_prev_sibling!,
    unlink_node!,
    root,
    nodetype,
    document,
    name,
    set_name!,
    content,
    set_content!,
    each_node,
    child_nodes,
    each_element,
    child_elements,
    each_attribute,
    attributes,
    namespace,
    namespaces,
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
