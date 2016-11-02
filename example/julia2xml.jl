#!/usr/bin/env julia

using EzXML

# Convert a Julia expression to an XML document.
function expr2xml(expr)
    doc = Document()
    add_child_node!(doc.node, expr2elem(expr))
    return doc
end

function expr2elem(expr)
    if isa(expr, Expr)
        # <expr/>
        expr_node = ElementNode("expr")
        # <head/>
        head_node = ElementNode("head")
        add_child_node!(head_node, TextNode(repr(expr.head)))
        add_child_node!(expr_node, head_node)
        # <args/>
        args_node = ElementNode("args")
        for arg in expr.args
            add_child_node!(args_node, expr2elem(arg))
        end
        add_child_node!(expr_node, args_node)
        return expr_node
    else
        # <literal/>
        literal_node = ElementNode("literal")
        literal_node["type"] = string(typeof(expr))
        add_child_node!(literal_node, TextNode(repr(expr)))
        return literal_node
    end
end

print(expr2xml(parse(readstring(STDIN))))
