#!/usr/bin/env julia

using EzXML

# Convert a Julia expression to an XML document.
function expr2xml(expr)
    doc = XMLDocument()
    setroot!(doc, expr2elem(expr))
    return doc
end

function expr2elem(expr)
    if isa(expr, Expr)
        # <expr/>
        expr_node = ElementNode("expr")
        # <head/>
        head_node = ElementNode("head")
        link!(head_node, TextNode(repr(expr.head)))
        link!(expr_node, head_node)
        # <args/>
        args_node = ElementNode("args")
        for arg in expr.args
            link!(args_node, expr2elem(arg))
        end
        link!(expr_node, args_node)
        return expr_node
    else
        # <literal/>
        literal_node = ElementNode("literal")
        literal_node["type"] = string(typeof(expr))
        link!(literal_node, TextNode(repr(expr)))
        return literal_node
    end
end

prettyprint(expr2xml(Meta.parse(String(read(stdin)))))
