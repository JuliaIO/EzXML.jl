using EzXML
using Base.Test

@testset "Error" begin
    for i in 1:21
        t = convert(EzXML.NodeType, i)
        @test ismatch(r"^XML_[A-Z_]+$", repr(t))
        @test string(t) == string(i)
    end
    @test_throws AssertionError repr(convert(EzXML.NodeType, 0))
    @test_throws AssertionError repr(convert(EzXML.NodeType, 100))

    err = XMLError(1, "some parser error")
    @test isa(err, XMLError)
    buf = IOBuffer()
    showerror(buf, err)
    @test takebuf_string(buf) == "XMLError: some parser error (from XML parser)"
end

@testset "Reader" begin
    @testset "XML" begin
        valid_file = joinpath(dirname(@__FILE__), "sample1.xml")
        invalid_file = joinpath(dirname(@__FILE__), "sample1.invalid.xml")
        doc = read(Document, valid_file)
        @test isa(doc, Document)
        @test nodetype(doc.node) === EzXML.XML_DOCUMENT_NODE
        @test nodetype(readxml(valid_file).node) === EzXML.XML_DOCUMENT_NODE
        @test_throws XMLError read(Document, invalid_file)
    end

    @testset "HTML" begin
        valid_file = joinpath(dirname(@__FILE__), "sample1.html")
        doc = read(Document, valid_file)
        @test isa(doc, Document)
        @test nodetype(doc.node) === EzXML.XML_HTML_DOCUMENT_NODE
        @test nodetype(readhtml(valid_file).node) === EzXML.XML_HTML_DOCUMENT_NODE
    end
end

@testset "Writer" begin
    docstr = """
    <?xml version="1.0" encoding="UTF-8"?>
    <root>
        <foo>ok</foo>
    </root>
    """
    doc = parse(Document, docstr)
    tmp = tempname()
    try
        @test write(tmp, doc) == length(docstr)
        @test readstring(tmp) == docstr
        @test string(read(Document, tmp)) == docstr
    finally
        rm(tmp)
    end
end

@testset "Parser" begin
    @testset "XML" begin
        doc = parse(Document, """
        <?xml version="1.0"?>
        <root>
            <child attr="value">content</child>
        </root>
        """)
        @test isa(doc, Document)
        @test nodetype(doc.node) === EzXML.XML_DOCUMENT_NODE

        doc = parse(Document, """
        <root>
            <child attr="value">content</child>
        </root>
        """)
        @test isa(doc, Document)
        @test nodetype(doc.node) === EzXML.XML_DOCUMENT_NODE

        doc = parse(Document, """
        <?xml version="1.0"?>
        <root>
            <child attr="value">content</child>
        </root>
        """.data)
        @test nodetype(doc.node) === EzXML.XML_DOCUMENT_NODE

        @test nodetype(parsexml("<xml/>").node) === EzXML.XML_DOCUMENT_NODE
        @test nodetype(parsexml("<html/>").node) === EzXML.XML_DOCUMENT_NODE
        @test nodetype(parsexml("<xml/>".data).node) === EzXML.XML_DOCUMENT_NODE
        @test nodetype(parsexml("<html/>".data).node) === EzXML.XML_DOCUMENT_NODE

        @test_throws ArgumentError parse(Document, "")
        @test_throws XMLError parse(Document, " ")
        @test_throws XMLError parse(Document, "abracadabra")
        @test_throws XMLError parse(Document, """<?xml version="1.0"?>""")
    end

    @testset "HTML" begin
        doc = parse(Document, """
        <!DOCTYPE html>
        <html>
            <head>
                <title>Title</title>
            </head>
            <body>
                Hello, world!
            </body>
        </html>
        """)
        @test isa(doc, Document)
        @test nodetype(doc.node) === EzXML.XML_HTML_DOCUMENT_NODE

        doc = parse(Document, """
        <html>
            <head>
                <title>Title</title>
            </head>
            <body>
                Hello, world!
            </body>
        </html>
        """)
        @test isa(doc, Document)
        @test nodetype(doc.node) === EzXML.XML_HTML_DOCUMENT_NODE

        doc = parse(Document, """
        <!DOCTYPE html>
        <html>
            <head>
                <title>Title</title>
            </head>
            <body>
                Hello, world!
            </body>
        </html>
        """.data)
        @test isa(doc, Document)
        @test nodetype(doc.node) === EzXML.XML_HTML_DOCUMENT_NODE

        @test nodetype(parsehtml("<html/>").node) === EzXML.XML_HTML_DOCUMENT_NODE
        @test nodetype(parsehtml("<html/>".data).node) === EzXML.XML_HTML_DOCUMENT_NODE

        @test_throws ArgumentError parsehtml("")
    end
end

@testset "Streaming Reader" begin
    reader = open(XMLReader, joinpath(dirname(@__FILE__), "simple.graphml"))
    @test isa(reader, XMLReader)
    for typ in reader
        @test isa(typ, EzXML.ReaderType)
    end
    @test close(reader) === nothing
end

@testset "Constructors" begin
    n = XMLDocumentNode("1.0")
    @test isa(n, Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.XML_DOCUMENT_NODE
    @test document(n) === Document(n.ptr)

    n = HTMLDocumentNode(nothing, nothing)
    @test isa(n, Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.XML_HTML_DOCUMENT_NODE
    @test document(n) === Document(n.ptr)

    n = HTMLDocumentNode("http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd",
                         "-//W3C//DTD XHTML 1.0 Strict//EN")
    @test isa(n, Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.XML_HTML_DOCUMENT_NODE
    @test document(n) === Document(n.ptr)

    n = ElementNode("node")
    @test isa(n, Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.XML_ELEMENT_NODE
    @test iselement(n)
    @test_throws ArgumentError document(n)

    n = TextNode("some text")
    @test isa(n, Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.XML_TEXT_NODE
    @test EzXML.istext(n)  # Base.istext is deprecated.
    @test_throws ArgumentError document(n)

    n = CommentNode("some comment")
    @test isa(n, Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.XML_COMMENT_NODE
    @test iscomment(n)
    @test_throws ArgumentError document(n)

    n = CDataNode("some CDATA")
    @test isa(n, Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.XML_CDATA_SECTION_NODE
    @test iscdata(n)
    @test_throws ArgumentError document(n)

    n = AttributeNode("attr", "value")
    @test isa(n, Node)
    @test n.owner == n
    @test nodetype(n) == EzXML.XML_ATTRIBUTE_NODE
    @test isattribute(n)
    @test_throws ArgumentError document(n)

    doc = XMLDocument()
    @test isa(doc, Document)
    @test doc.node.owner === doc.node
    @test nodetype(doc.node) === EzXML.XML_DOCUMENT_NODE
    @test !hasroot(doc)
    @test_throws ArgumentError root(doc)

    doc = HTMLDocument()
    @test isa(doc, Document)
    @test doc.node.owner === doc.node
    @test nodetype(doc.node) == EzXML.XML_HTML_DOCUMENT_NODE
    @test !hasroot(doc)
    @test_throws ArgumentError root(doc)

    doc = HTMLDocument("http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd",
                       "-//W3C//DTD XHTML 1.0 Strict//EN")
    @test isa(doc, Document)
    @test doc.node.owner === doc.node
    @test nodetype(doc.node) == EzXML.XML_HTML_DOCUMENT_NODE
    @test !hasroot(doc)
    @test_throws ArgumentError root(doc)
end

@testset "Traversal" begin
    doc = parsexml("<root/>") 
    @test hasroot(doc)
    @test isa(root(doc), Node)
    @test root(doc) == root(doc)
    @test root(doc) === root(doc)
    @test hash(root(doc)) === hash(root(doc))
    @test nodetype(root(doc)) === EzXML.XML_ELEMENT_NODE
    @test name(root(doc)) == "root"
    @test content(root(doc)) == ""
    @test document(root(doc)) == doc
    @test document(root(doc)) === doc
    @test !hasparentnode(doc.node)
    @test_throws ArgumentError parentnode(doc.node)
    @test hasparentnode(root(doc))
    @test parentnode(root(doc)) === doc.node

    doc = parse(Document, """
    <?xml version="1.0"?>
    <r>
        <c1/>
        <c2/>
        <c3/>
    </r>
    """)
    r = root(doc)
    @test nodetype(firstnode(r)) === EzXML.XML_TEXT_NODE
    @test nodetype(lastnode(r)) === EzXML.XML_TEXT_NODE
    @test nodetype(firstelement(r)) === EzXML.XML_ELEMENT_NODE
    @test name(firstelement(r)) == "c1"
    @test nodetype(lastelement(r)) === EzXML.XML_ELEMENT_NODE
    @test name(lastelement(r)) == "c3"
    c1 = firstelement(r)
    @test hasnextnode(c1)
    @test hasprevnode(c1)
    @test nodetype(nextnode(c1)) === EzXML.XML_TEXT_NODE
    @test nodetype(prevnode(c1)) === EzXML.XML_TEXT_NODE
    @test hasnextelement(c1)
    @test !hasprevelement(c1)
    c2 = nextelement(c1)
    @test name(c2) == "c2"
    @test hasnextelement(c2)
    @test hasprevelement(c2)
    @test prevelement(c2) == c1
    c3 = nextelement(c2)
    @test name(c3) == "c3"
    @test !hasnextelement(c3)
    @test hasprevelement(c3)
    @test prevelement(c3) == c2
    @test_throws ArgumentError prevelement(c1)
    @test_throws ArgumentError nextelement(c3)

    doc = parse(Document, """
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

    doc = parse(Document, "<root/>")
    x = root(doc)
    @test_throws ArgumentError firstnode(x)
    @test_throws ArgumentError lastnode(x)
    @test_throws ArgumentError firstelement(x)
    @test_throws ArgumentError lastelement(x)
    @test_throws ArgumentError nextnode(x)
    @test_throws ArgumentError prevnode(x)
    @test_throws ArgumentError nextelement(x)
    @test_throws ArgumentError prevelement(x)

    doc = parsexml("""
    <root xmlns:x="http://xxx.com" xmlns:y="http://yyy.com">
        <x:child x:attr="xxx" y:attr="yyy"/>
    </root>
    """)
    x = firstelement(root(doc))
    @test namespace(x) == "http://xxx.com"
    @test namespace(attributes(x)[1]) == "http://xxx.com"
    @test namespace(attributes(x)[2]) == "http://yyy.com"

    # http://www.xml.com/pub/a/1999/01/namespaces.html
    doc = parsexml("""
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
          namespaces(elements(root(doc))[1]) ==
          namespaces(elements(root(doc))[2]) == [
        "xdc" => "http://www.xml.com/books",
        "h"   => "http://www.w3.org/HTML/1998/html4"]
    @test name(root(doc)) == "html"
    @test namespace(root(doc)) == "http://www.w3.org/HTML/1998/html4"
    @test namespace(elements(elements(root(doc))[2])[1]) == "http://www.xml.com/books"

    # default namespace
    doc = parsexml("""
    <html xmlns="http://www.w3.org/HTML/1998/html4"
          xmlns:xdc="http://www.xml.com/books">
    </html>
    """)
    @test namespaces(root(doc)) == [
        "" => "http://www.w3.org/HTML/1998/html4",
        "xdc" => "http://www.xml.com/books"]
    @test namespace(root(doc)) == "http://www.w3.org/HTML/1998/html4"

    doc = parsexml("""
    <html xmlns=""
          xmlns:xdc="http://www.xml.com/books">
    </html>
    """)
    @test namespaces(root(doc)) == [
        "" => "",
        "xdc" => "http://www.xml.com/books"]

    # no namespace
    doc = parsexml("""
    <root></root>
    """)
    @test isempty(namespaces(root(doc)))
    @test_throws ArgumentError namespace(root(doc))

    @testset "Counters" begin
        doc = parse(Document, "<root/>")
        @test !hasnode(root(doc))
        @test countnodes(root(doc)) === 0
        @test countelements(root(doc)) === 0
        @test countattributes(root(doc)) === 0
        @test addelement!(root(doc), "c1") == root(doc)
        root(doc)["attr1"] = "1"
        @test countnodes(root(doc)) === 1
        @test countelements(root(doc)) === 1
        @test countelements(root(doc)) === 1
        @test countattributes(root(doc)) === 1
        @test addelement!(root(doc), "c2", "some content") == root(doc)
        @test countnodes(root(doc)) === 2
        @test countelements(root(doc)) === 2
        @test_throws ArgumentError countattributes(doc.node)
    end

    @testset "Iterators" begin
        doc = parse(Document, "<root/>")
        ns = Node[]
        for (i, node) in enumerate(eachnode(root(doc)))
            @test isa(node, Node)
            push!(ns, node)
        end
        @test length(ns) == 0
        @test nodes(root(doc)) == ns
        ns = Node[]
        for (i, node) in enumerate(eachelement(root(doc)))
            @test isa(node, Node)
            push!(ns, node)
        end
        @test length(ns) == 0
        @test elements(root(doc)) == ns

        doc = parse(Document, """
        <root><c1></c1><c2></c2></root>
        """)
        ns = Node[]
        for (i, node) in enumerate(eachnode(root(doc)))
            @test isa(node, Node)
            push!(ns, node)
        end
        @test length(ns) == 2
        @test nodes(root(doc)) == ns
        ns = Node[]
        for (i, node) in enumerate(eachelement(root(doc)))
            @test isa(node, Node)
            push!(ns, node)
        end
        @test length(ns) == 2
        @test elements(root(doc)) == ns

        doc = parse(Document, """
        <root>
            <c1></c1>
            <c2></c2>
        </root>
        """)
        ns = Node[]
        for (i, node) in enumerate(eachnode(root(doc)))
            @test isa(node, Node)
            push!(ns, node)
        end
        @test length(ns) == 5
        @test nodes(root(doc)) == ns
        ns = Node[]
        for (i, node) in enumerate(eachelement(root(doc)))
            @test isa(node, Node)
            push!(ns, node)
        end
        @test length(ns) == 2
        @test elements(root(doc)) == ns

        doc = parse(Document, """
        <?xml version="1.0"?>
        <root attr1="foo" attr2="bar"></root>
        """)
        for node in eachattribute(root(doc))
            attr = name(node)
            val = content(node)
            @test val == (attr == "attr1" ? "foo" : "bar")
        end
        @test [(name(n), content(n)) for n in attributes(root(doc))] == [("attr1", "foo"), ("attr2", "bar")]
        @test_throws ArgumentError eachattribute(doc.node)
        @test_throws ArgumentError attributes(doc.node)
    end
end

@testset "Construction" begin
    doc = XMLDocument()
    @test isa(doc, Document)
    @test nodetype(doc.node) === EzXML.XML_DOCUMENT_NODE
    @test !hasroot(doc)
    @test_throws ArgumentError root(doc)
    r1 = ElementNode("r1")
    @test setroot!(doc, r1) == doc
    @test hasroot(doc)
    @test root(doc) === r1
    @test_throws ArgumentError setroot!(doc, TextNode("some text"))
    r2 = ElementNode("r2")
    setroot!(doc, r2)
    @test root(doc) == r2
    @test r1.owner === r1

    doc = XMLDocument()
    el = ElementNode("el")
    setroot!(doc, el)
    @test name(el) == "el"
    setname!(el, "EL")
    @test name(el) == "EL"
    @test content(el) == ""
    setcontent!(el, "some content")
    @test content(el) == "some content"

    # <e1>t1<e2>t2<e3 a1="val"/></e2></e1>
    doc = XMLDocument()
    e1 = ElementNode("e1")
    e2 = ElementNode("e2")
    e3 = ElementNode("e3")
    t1 = TextNode("t1")
    t2 = TextNode("t2")
    a1 = AttributeNode("a1", "val")
    setroot!(doc, e1)
    link!(e1, t1)
    link!(e1, e2)
    link!(e2, t2)
    link!(e2, e3)
    link!(e3, a1)
    @test root(doc) === e1
    @test document(e1) === doc
    @test document(e2) === doc
    @test document(e3) === doc
    @test document(t1) === doc
    @test document(t2) === doc
    @test document(a1) === doc
    @test e1.owner === doc.node
    @test e2.owner === doc.node
    @test e3.owner === doc.node
    @test t1.owner === doc.node
    @test t2.owner === doc.node
    @test a1.owner === doc.node
    @test e2 ∈ nodes(e1)
    unlink!(e2)
    @test e2 ∉ nodes(e1)
    @test root(doc) === e1
    @test document(e1) === doc
    @test document(t1) === doc
    @test !hasdocument(e2)
    @test !hasdocument(e3)
    @test !hasdocument(t2)
    @test !hasdocument(a1)
    @test e1.owner === doc.node
    @test t1.owner === doc.node
    @test e2.owner === e2
    @test e3.owner === e2
    @test t2.owner === e2
    @test a1.owner === e2

    doc = parse(Document, "<root/>")
    @test isempty(nodes(root(doc)))
    c1 = ElementNode("c1")
    link!(root(doc), c1)
    @test nodes(root(doc)) == [c1]
    c2 = ElementNode("c2")
    linknext!(c1, c2)
    @test nodes(root(doc)) == [c1, c2]
    c0 = ElementNode("c0")
    linkprev!(c1, c0)
    @test nodes(root(doc)) == [c0, c1, c2]

    doc = XMLDocument()
    @test !hasparentnode(doc.node)
    @test !hasparentelement(doc.node)
    @test_throws ArgumentError parentelement(doc.node)
    x = ElementNode("x")
    setroot!(doc, x)
    @test hasparentnode(x)
    @test !hasparentelement(x)
    @test_throws ArgumentError parentelement(x)
    y = ElementNode("y")
    link!(x, y)
    @test hasparentnode(y)
    @test hasparentelement(y)
    @test parentelement(y) == x

    el = ElementNode("el")
    el["attr1"] = "1"
    el["attr2"] = "2"
    doc = XMLDocument()
    setroot!(doc, el)
    @test root(doc) == el
    @test [(name(n), content(n)) for n in attributes(root(doc))] == [("attr1", "1"), ("attr2", "2")]

    doc = parse(Document, """
    <root></root>
    """)
    @test string(doc.node) == """
    <?xml version="1.0" encoding="UTF-8"?>
    <root/>
    """
    @test !hasnode(root(doc))
    c1 = ElementNode("child1")
    link!(root(doc), c1)
    @test hasnode(root(doc))
    c2 = ElementNode("child2")
    link!(root(doc), c2)
    @test nodes(root(doc)) == [c1, c2]
    @test !hasnode(c1)
    link!(c1, TextNode("some text"))
    @test hasnode(c1)
    c3 = CommentNode("some comment")
    link!(root(doc), c3)
    c4 = CDataNode("<cdata>")
    link!(root(doc), c4)
    @test string(doc.node) == """
    <?xml version="1.0" encoding="UTF-8"?>
    <root><child1>some text</child1><child2/><!--some comment--><![CDATA[<cdata>]]></root>
    """

    doc = parse(Document, """
    <?xml version="1.0" encoding="UTF-8"?>
    <root>
        <c1>
            <c2>
                <c3>ok</c3>
            </c2>
        </c1>
    </root>
    """)
    @test haselement(root(doc))
    c1 = firstelement(root(doc))
    c2 = firstelement(c1)
    @test unlink!(c1) == c1
    @test !haselement(root(doc))
    @test c1.owner == c1
    @test c2.owner == c1

    doc = parse(Document, """
    <root xmlns:x="http://xxx.org/" xmlns:y="http://yyy.org/">
        <c x:attr="x-attr" y:attr="y-attr"/>
        <c y:attr="y-attr" x:attr="x-attr"/>
        <c x:attr=""/>
    </root>
    """)
    c = firstelement(root(doc))
    @test haskey(c, "attr")
    @test haskey(c, "x:attr")
    @test haskey(c, "y:attr")
    @test !haskey(c, "z:attr")
    @test c["attr"] == c["x:attr"] == "x-attr"
    @test c["y:attr"] == "y-attr"
    @test_throws ArgumentError c["z:attr"]
    c = nextelement(c)
    @test haskey(c, "attr")
    @test haskey(c, "x:attr")
    @test haskey(c, "y:attr")
    @test c["attr"] == c["y:attr"] == "y-attr"
    @test c["x:attr"] == "x-attr"
    c = nextelement(c)
    c["x:attr"] = "x-attr"
    @test c["x:attr"] == "x-attr"
    c["y:attr"] = "y-attr"
    @test c["y:attr"] == "y-attr"
    delete!(c, "x:attr")
    @test !haskey(c, "x:attr")
    delete!(c, "y:attr")
    @test !haskey(c, "y:attr")
    delete!(c, "z:attr")
end

@testset "XPath" begin
    doc = parse(Document, """
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
    @test find(doc, "/root/foo")[1] === elements(root(doc))[1]
    @test find(doc, "/root/foo")[2] === elements(root(doc))[2]
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
    @test find(doc, "root") == find(root(doc), "/root")
    @test find(root(doc), "foo") == find(doc, "//foo")
    @inferred find(doc, "root")
    @inferred findfirst(doc, "root")
    @inferred findlast(doc, "root")
end

@testset "Misc" begin
    @testset "show" begin
        doc = parsexml("<root/>")
        @test ismatch(r"^EzXML.Node\(<[A-Z_]+@0x[a-f0-9]+>\)$", repr(root(doc)))
        @test ismatch(r"^EzXML.Node\(<[A-Z_]+@0x[a-f0-9]+>\)$", repr(doc.node))
        @test ismatch(r"^EzXML.Document\(EzXML.Node\(<[A-Z_]+@0x[a-f0-9]+>\)\)$", repr(doc))
    end

    @testset "print" begin
        doc = parsexml("<e1><e2/></e1>")
        buf = IOBuffer()
        print(buf, doc)
        @test takebuf_string(buf) == """
        <?xml version="1.0" encoding="UTF-8"?>
        <e1><e2/></e1>
        """

        doc = parsexml("<e1><e2/></e1>")
        buf = IOBuffer()
        prettyprint(buf, doc)
        @test takebuf_string(buf) == """
        <?xml version="1.0" encoding="UTF-8"?>
        <e1>
          <e2/>
        </e1>
        """
    end
end

# Check no uncaught errors.
@test isempty(EzXML.XML_GLOBAL_ERROR_STACK)
