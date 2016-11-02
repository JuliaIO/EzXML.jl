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
    has_next_node,
    next_node,
    has_prev_node,
    prev_node,
    add_child_node!,
    add_next_sibling!,
    add_prev_sibling!,
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
    each_attributes,
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
