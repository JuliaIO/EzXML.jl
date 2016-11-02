using EzXML
using Base.Test

@test_throws ArgumentError parse(EzXML.Document, "")
@test_throws XMLError parse(EzXML.Document, " ")
@test_throws XMLError parse(EzXML.Document, "abracadabra")
@test_throws XMLError parse(EzXML.Document, """<?xml version="1.0"?>""")

doc = EzXML.Document()
@test isa(doc, EzXML.Document)
@test nodetype(doc.node) === EzXML.XML_DOCUMENT_NODE
@test_throws ArgumentError root(doc)

doc = parse(EzXML.Document, """
<?xml version="1.0"?>
<root></root>
""")
@test isa(doc, EzXML.Document)
@test isa(root(doc), EzXML.Node)
@test root(doc) == root(doc)
@test root(doc) === root(doc)
@test nodetype(doc.node) === EzXML.XML_DOCUMENT_NODE
@test nodetype(root(doc)) === EzXML.XML_ELEMENT_NODE
@test isa(name(root(doc)), String)
@test name(root(doc)) == "root"
@test set_name!(root(doc), "root2") == root(doc)
@test name(root(doc)) == "root2"
@test_throws ArgumentError name(doc.node)
@test isa(content(root(doc)), String)
@test content(root(doc)) == ""
@test content(doc.node) == ""
@test set_content!(root(doc), "root content") == root(doc)
@test content(root(doc)) == "root content"
@test document(root(doc)) == doc
@test document(root(doc)) === doc
@test document(doc.node) === doc
@test parent_node(root(doc)) === doc.node
@test_throws ArgumentError parent_node(doc.node)
@test ismatch(r"Node\(<[A-Z_]+@0x[a-f0-9]+>\)", repr(root(doc)))
@test ismatch(r"Node\(<[A-Z_]+@0x[a-f0-9]+>\)", repr(doc.node))

docstr = """
<?xml version="1.0" encoding="UTF-8"?>
<root>
    <foo>ok</foo>
</root>
"""
doc = parse(EzXML.Document, docstr)
tmp = tempname()
try
    @test write(tmp, doc) == length(docstr)
    @test readstring(tmp) == docstr
    @test string(read(EzXML.Document, tmp)) == docstr
finally
    rm(tmp)
end

doc = parse(EzXML.Document, """
<?xml version="1.0"?>
<r>
    <c1/>
    <c2/>
    <c3/>
</r>
""")
r = root(doc)
@test nodetype(first_child_node(r)) === EzXML.XML_TEXT_NODE
@test nodetype(last_child_node(r)) === EzXML.XML_TEXT_NODE
@test nodetype(first_child_element(r)) === EzXML.XML_ELEMENT_NODE
@test name(first_child_element(r)) == "c1"
@test nodetype(last_child_element(r)) === EzXML.XML_ELEMENT_NODE
@test name(last_child_element(r)) == "c3"
c1 = first_child_element(r)
@test has_next_element(c1)
@test !has_prev_element(c1)
c2 = next_element(c1)
@test name(c2) == "c2"
@test has_next_element(c2)
@test has_prev_element(c2)
@test prev_element(c2) == c1
c3 = next_element(c2)
@test name(c3) == "c3"
@test !has_next_element(c3)
@test has_prev_element(c3)
@test prev_element(c3) == c2
@test_throws ArgumentError prev_element(c1)
@test_throws ArgumentError next_element(c3)

doc = parse(EzXML.Document, """
<?xml version="1.0"?>
<root attr="some attribute value"><child>some content</child></root>
""")
@test content(root(doc)) == "some content"
@test haskey(root(doc), "attr")
@test !haskey(root(doc), "bah")
@test root(doc)["attr"] == "some attribute value"
@test_throws KeyError root(doc)["bah"]
@test delete!(root(doc), "attr") == root(doc)
@test !haskey(root(doc), "attr")
@test_throws KeyError root(doc)["attr"]

doc = parse(EzXML.Document, """
<root></root>
""")
nodes = EzXML.Node[]
for (i, node) in enumerate(each_node(root(doc)))
    @test isa(node, EzXML.Node)
    push!(nodes, node)
end
@test length(nodes) == 0
@test child_nodes(root(doc)) == nodes
nodes = EzXML.Node[]
for (i, node) in enumerate(each_element(root(doc)))
    @test isa(node, EzXML.Node)
    push!(nodes, node)
end
@test length(nodes) == 0
@test child_elements(root(doc)) == nodes

doc = parse(EzXML.Document, """
<root><c1></c1><c2></c2></root>
""")
nodes = EzXML.Node[]
for (i, node) in enumerate(each_node(root(doc)))
    @test isa(node, EzXML.Node)
    push!(nodes, node)
end
@test length(nodes) == 2
@test child_nodes(root(doc)) == nodes
nodes = EzXML.Node[]
for (i, node) in enumerate(each_element(root(doc)))
    @test isa(node, EzXML.Node)
    push!(nodes, node)
end
@test length(nodes) == 2
@test child_elements(root(doc)) == nodes

doc = parse(EzXML.Document, """
<root>
    <c1></c1>
    <c2></c2>
</root>
""")
nodes = EzXML.Node[]
for (i, node) in enumerate(each_node(root(doc)))
    @test isa(node, EzXML.Node)
    push!(nodes, node)
end
@test length(nodes) == 5
@test child_nodes(root(doc)) == nodes
nodes = EzXML.Node[]
for (i, node) in enumerate(each_element(root(doc)))
    @test isa(node, EzXML.Node)
    push!(nodes, node)
end
@test length(nodes) == 2
@test child_elements(root(doc)) == nodes

doc = parse(EzXML.Document, """
<?xml version="1.0"?>
<root attr1="foo" attr2="bar"></root>
""")
for (attr, val) in each_attribute(root(doc))
    @test val == (attr == "attr1" ? "foo" : "bar")
end
@test attributes(root(doc)) == ["attr1" => "foo", "attr2" => "bar"]
@test_throws ArgumentError each_attribute(doc.node)
@test_throws ArgumentError attributes(doc.node)

n = ElementNode("node")
@test isa(n, Node)
@test n.owner == n
@test nodetype(n) === EzXML.XML_ELEMENT_NODE
@test_throws ArgumentError document(n)

n = TextNode("some text")
@test isa(n, Node)
@test n.owner == n
@test nodetype(n) === EzXML.XML_TEXT_NODE
@test_throws ArgumentError document(n)

n = CommentNode("some comment")
@test isa(n, Node)
@test n.owner == n
@test nodetype(n) === EzXML.XML_COMMENT_NODE
@test_throws ArgumentError document(n)

n = CDataNode("some CDATA")
@test isa(n, Node)
@test n.owner == n
@test nodetype(n) === EzXML.XML_CDATA_SECTION_NODE
@test_throws ArgumentError document(n)

n = DocumentNode("1.0")
@test isa(n, Node)
@test n.owner == n
@test nodetype(n) === EzXML.XML_DOCUMENT_NODE
@test document(n) === Document(n.ptr)

doc = parse(EzXML.Document, """
<root></root>
""")
@test string(doc.node) == """
<?xml version="1.0" encoding="UTF-8"?>
<root/>
"""
@test !has_child_node(root(doc))
c1 = ElementNode("child1")
add_child_node!(root(doc), c1)
@test has_child_node(root(doc))
c2 = ElementNode("child2")
add_child_node!(root(doc), c2)
@test child_nodes(root(doc)) == [c1, c2]
@test !has_child_node(c1)
add_child_node!(c1, TextNode("some text"))
@test has_child_node(c1)
c3 = CommentNode("some comment")
add_child_node!(root(doc), c3)
c4 = CDataNode("<cdata>")
add_child_node!(root(doc), c4)
@test string(doc.node) == """
<?xml version="1.0" encoding="UTF-8"?>
<root><child1>some text</child1><child2/><!--some comment--><![CDATA[<cdata>]]></root>
"""

doc = parse(EzXML.Document, "<root/>")
@test isempty(child_nodes(root(doc)))
c1 = ElementNode("c1")
add_child_node!(root(doc), c1)
@test child_nodes(root(doc)) == [c1]
c2 = ElementNode("c2")
add_next_sibling!(c1, c2)
@test child_nodes(root(doc)) == [c1, c2]
c0 = ElementNode("c0")
add_prev_sibling!(c1, c0)
@test child_nodes(root(doc)) == [c0, c1, c2]

doc = parse(EzXML.Document, """
<?xml version="1.0" encoding="UTF-8"?>
<root>
    <c1>
        <c2>
            <c3>ok</c3>
        </c2>
    </c1>
</root>
""")
@test has_child_element(root(doc))
c1 = first_child_element(root(doc))
c2 = first_child_element(c1)
@test unlink_node!(c1) == c1
@test !has_child_element(root(doc))
@test c1.owner == c1
@test c2.owner == c1

doc = parse(EzXML.Document, """
<?xml version="1.0"?>
<root>
    <foo>
        <bar>1</bar>
    </foo>
    <foo>
        <bar>2</bar>
        <bar>3</bar>
    </foo>
</root>
""")
@test length(find(doc, "/root")) == 1
@test find(doc, "/root")[1] === root(doc)
@test length(find(doc, "/root/foo")) == 2
@test find(doc, "/root/foo")[1] === child_elements(root(doc))[1]
@test find(doc, "/root/foo")[2] === child_elements(root(doc))[2]
for (i, node) in enumerate(find(doc, "//bar"))
    @test name(node) == "bar"
    @test content(node) == string(i)
end
for (i, node) in enumerate(find(doc, "//bar/text()"))
    @test name(node) == "text"
    @test content(node) == string(i)
end
@test findfirst(doc, "//bar") === find(doc, "//bar")[1]
@test findlast(doc, "//bar") === find(doc, "//bar")[3]
@test length(find(doc, "/baz")) == 0
@test_throws XMLError find(doc, "//bar!")
@test find(root(doc), "foo") == find(doc, "//foo")
@test findfirst(root(doc), "foo") === findfirst(doc, "//foo")
@test findlast(root(doc), "foo") === findlast(doc, "//foo")

# http://www.xml.com/pub/a/1999/01/namespaces.html
doc = parse(EzXML.Document, """
<h:html xmlns:xdc="http://www.xml.com/books"
        xmlns:h="http://www.w3.org/HTML/1998/html4">
 <h:head><h:title>Book Review</h:title></h:head>
 <h:body>
  <xdc:bookreview>
   <xdc:title>XML: A Primer</xdc:title>
   <h:table>
    <h:tr align="center">
     <h:td>Author</h:td><h:td>Price</h:td>
     <h:td>Pages</h:td><h:td>Date</h:td></h:tr>
    <h:tr align="left">
     <h:td><xdc:author>Simon St. Laurent</xdc:author></h:td>
     <h:td><xdc:price>31.98</xdc:price></h:td>
     <h:td><xdc:pages>352</xdc:pages></h:td>
     <h:td><xdc:date>1998/01</xdc:date></h:td>
    </h:tr>
   </h:table>
  </xdc:bookreview>
 </h:body>
</h:html>
""")
@test namespaces(root(doc)) ==
      namespaces(child_elements(root(doc))[1]) ==
      namespaces(child_elements(root(doc))[2]) == [
    "xdc" => "http://www.xml.com/books",
    "h"   => "http://www.w3.org/HTML/1998/html4"]
@test name(root(doc)) == "html"
@test namespace(root(doc)) == "http://www.w3.org/HTML/1998/html4"
@test namespace(child_elements(child_elements(root(doc))[2])[1]) == "http://www.xml.com/books"

doc = parse(EzXML.Document, """
<root xmlns:x="http://xxx.org/" xmlns:y="http://yyy.org/">
    <c x:attr="x-attr" y:attr="y-attr"/>
    <c y:attr="y-attr" x:attr="x-attr"/>
    <c x:attr=""/>
</root>
""")
c = first_child_element(root(doc))
@test haskey(c, "attr")
@test haskey(c, "x:attr")
@test haskey(c, "y:attr")
@test !haskey(c, "z:attr")
@test c["attr"] == c["x:attr"] == "x-attr"
@test c["y:attr"] == "y-attr"
@test_throws ArgumentError c["z:attr"]
c = next_element(c)
@test haskey(c, "attr")
@test haskey(c, "x:attr")
@test haskey(c, "y:attr")
@test c["attr"] == c["y:attr"] == "y-attr"
@test c["x:attr"] == "x-attr"
c = next_element(c)
c["x:attr"] = "x-attr"
@test c["x:attr"] == "x-attr"
c["y:attr"] = "y-attr"
@test c["y:attr"] == "y-attr"
delete!(c, "x:attr")
@test !haskey(c, "x:attr")
delete!(c, "y:attr")
@test !haskey(c, "y:attr")
delete!(c, "z:attr")

# default namespace
doc = parse(EzXML.Document, """
<html xmlns="http://www.w3.org/HTML/1998/html4"
      xmlns:xdc="http://www.xml.com/books">
</html>
""")
@test namespaces(root(doc)) == [
    "" => "http://www.w3.org/HTML/1998/html4",
    "xdc" => "http://www.xml.com/books"]
@test namespace(root(doc)) == "http://www.w3.org/HTML/1998/html4"

doc = parse(EzXML.Document, """
<html xmlns=""
      xmlns:xdc="http://www.xml.com/books">
</html>
""")
@test namespaces(root(doc)) == [
    "" => "",
    "xdc" => "http://www.xml.com/books"]

# no namespace
doc = parse(EzXML.Document, """
<root></root>
""")
@test isempty(namespaces(root(doc)))
@test_throws ArgumentError namespace(root(doc))

# Check no uncaught errors.
@test isempty(EzXML.global_error)
