using EzXML
using Test
using Logging: SimpleLogger, with_logger
using Aqua: Aqua

Aqua.test_all(EzXML; ambiguities=false)

# Capture logging messages using a local logger.
function capture_logging_messages(proc)
    buf = IOBuffer()
    ret = with_logger(proc, SimpleLogger(buf))
    messages = String(take!(buf))
    return ret, messages
end

# This simply creates an immutable ::IO object that behaves the same
# as an IOBuffer for everything but memory management purposes.
wrapped_buff(args...) = IOContext(IOBuffer(args...))

# Unit tests
# ----------

@testset "Error" begin
    for i in 1:21
        t = convert(EzXML.NodeType, i)
        @test t == i
        @test occursin(r"^[A-Z_]+_(NODE|DECL|START|END)$", repr(t))
        @test string(t) == string(i)
        @test convert(EzXML.NodeType, t) === t
    end
    @test_throws AssertionError repr(convert(EzXML.NodeType, 0))
    @test_throws AssertionError repr(convert(EzXML.NodeType, 100))

    err = EzXML.XMLError(1, 77, "some parser error", EzXML.XML_ERR_ERROR, 123)
    @test isa(err, EzXML.XMLError)
    buf = IOBuffer()
    showerror(buf, err)
    @test take!(buf) == b"XMLError: some parser error from XML parser (code: 77, line: 123)"
end

@testset "Reader" begin
    @testset "XML" begin
        valid_file = joinpath(dirname(@__FILE__), "sample1.xml")
        invalid_file = joinpath(dirname(@__FILE__), "sample1.invalid.xml")
        doc = readxml(valid_file)
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.DOCUMENT_NODE
        @test nodetype(readxml(valid_file).node) === EzXML.DOCUMENT_NODE
        @test_throws EzXML.XMLError readxml(invalid_file)
        @assert !isfile("not-exist.xml")
        @test_throws EzXML.XMLError readxml("not-exist.xml")

        # from compressed file
        compressed = joinpath(dirname(@__FILE__), "sample1.xml.gz")
        @test isa(readxml(compressed), EzXML.Document)

        # from stream
        doc = open(readxml, valid_file)
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.DOCUMENT_NODE
        @test_throws EzXML.XMLError open(readxml, invalid_file)

        # properties
        doc = readxml(joinpath(dirname(@__FILE__), "sample1.xml"))
        @test hasversion(doc)
        @test version(doc) == "1.0"
        @test !hasencoding(doc)
        @test_throws ArgumentError encoding(doc)
        doc = readxml(joinpath(dirname(@__FILE__), "sample2.xml"))
        @test hasversion(doc)
        @test version(doc) == "1.0"
        @test hasencoding(doc)
        @test encoding(doc) == "UTF-8"
    end

    @testset "HTML ($buff_f)" for buff_f in [IOBuffer, wrapped_buff]
        valid_file = joinpath(dirname(@__FILE__), "sample1.html")
        doc = readhtml(valid_file)
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.HTML_DOCUMENT_NODE
        @test nodetype(readhtml(valid_file).node) === EzXML.HTML_DOCUMENT_NODE
        @assert !isfile("not-exist.html")
        @test_throws EzXML.XMLError readxml("not-exist.html")
        @test_throws EzXML.XMLError readhtml("not-exist.html")

        # from compressed file
        compressed = joinpath(dirname(@__FILE__), "sample1.html.gz")
        @test isa(readxml(compressed), EzXML.Document)
        @test isa(readhtml(compressed), EzXML.Document)

        # from stream (FIXME: this causes "Misplaced DOCTYPE declaration")
        #doc = open(readhtml, valid_file)
        #@test isa(doc, EzXML.Document)
        #@test nodetype(doc.node) === EzXML.HTML_DOCUMENT_NODE
        buf = buff_f("""
        <html>
            <head><title>hey</title></head>
            <body>Hey</body>
        </html>
        """)
        doc = readhtml(buf)
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.HTML_DOCUMENT_NODE

        buf = buff_f("""
        <a href="http://mbgd.genome.ad.jp">MBGD</a>
        &#124
        <a href="https://github.com/qfo/OrthologyOntology">Ontology</a>
        &#124
        <a href="http://mbgd.genome.ad.jp/sparql/index_2015.php">To Previous Version (2015)</a>
        """)
        doc, messages = capture_logging_messages() do
            readhtml(buf)
        end
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.HTML_DOCUMENT_NODE
        # in XML2_jll v2.14 "Several non-standard syntax warnings were removed."
        # https://github.com/GNOME/libxml2/blob/v2.14.4/NEWS#L90
        # @test occursin("Warning: XMLError: htmlParseCharRef: missing semicolon from HTML parser (code: 7, line: 2)", messages)
        # @test occursin("Warning: XMLError: htmlParseCharRef: missing semicolon from HTML parser (code: 7, line: 4)", messages)
    end
end

@testset "Writer" begin
    docstr = """
    <?xml version="1.0" encoding="UTF-8"?>
    <root>
        <foo>ok</foo>
    </root>
    """
    doc = parsexml(docstr)
    tmp = tempname()
    try
        @test write(tmp, doc) == sizeof(docstr)
        @test String(read(tmp)) == docstr
        @test string(readxml(tmp)) == docstr
    finally
        rm(tmp)
    end
end

@testset "Parser" begin
    @testset "XML" begin
        doc = parsexml("""
        <?xml version="1.0"?>
        <root>
            <child attr="value">content</child>
        </root>
        """)
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.DOCUMENT_NODE

        doc = parsexml("""
        <root>
            <child attr="value">content</child>
        </root>
        """)
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.DOCUMENT_NODE

        doc = parsexml(b"""
        <?xml version="1.0"?>
        <root>
            <child attr="value">content</child>
        </root>
        """)
        @test nodetype(doc.node) === EzXML.DOCUMENT_NODE

        @test nodetype(parsexml("<xml/>").node) === EzXML.DOCUMENT_NODE
        @test nodetype(parsexml("<html/>").node) === EzXML.DOCUMENT_NODE
        @test nodetype(parsexml(b"<xml/>").node) === EzXML.DOCUMENT_NODE
        @test nodetype(parsexml(b"<html/>").node) === EzXML.DOCUMENT_NODE

        # This includes multi-byte characters.
        doc = parsexml("""
        <?xml version="1.0" encoding="UTF-8" ?>
        <Link>
            <Name>pubmed_pubmed</Name>
            <Menu>Similar articles</Menu>
            <Description>... “linked from” ...</Description>
            <DbTo>pubmed</DbTo>
        </Link>
        """)
        @test nodetype(doc.node) === EzXML.DOCUMENT_NODE

        @test_throws ArgumentError parsexml("")
        @test_throws EzXML.XMLError parsexml(" ")
        @test_throws EzXML.XMLError parsexml("abracadabra")
        @test_throws EzXML.XMLError parsexml("""<?xml version="1.0"?>""")

        _, messages = capture_logging_messages() do
            @test_throws EzXML.XMLError parsexml("<gepa?>jgo<<<><<")
        end
        @test occursin("errors; throwing the first one", messages)

        # This is to test warnings are logged properly
        doc, messages = capture_logging_messages() do
            parsexml("""
            <?xml version="1.0"?>
            <root xmlns:ns="http://example.com">
                <ns:element>
                    <undeclared:child>content</undeclared:child>
                </ns:element>
            </root>
            """)
        end
        @test !isempty(messages)
    end

    @testset "HTML" begin
        doc = parsehtml("""
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
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.HTML_DOCUMENT_NODE
        @test hasdtd(doc)
        @test nodename(dtd(doc)) == "html"

        doc = parsehtml("""
        <html>
            <head>
                <title>Title</title>
            </head>
            <body>
                Hello, world!
            </body>
        </html>
        """)
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.HTML_DOCUMENT_NODE
        @test hasdtd(doc)

        doc = parsehtml(b"""
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
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.HTML_DOCUMENT_NODE

        doc = parsehtml("""
        <!DOCTYPE html>
        <html>
            <head><title>題名</title></head>
            <body>こんにちは、世界！</body>
        </html>
        """)
        @test isa(doc, EzXML.Document)
        @test nodetype(doc.node) === EzXML.HTML_DOCUMENT_NODE

        @test nodetype(parsehtml("<html/>").node) === EzXML.HTML_DOCUMENT_NODE
        @test nodetype(parsehtml(b"<html/>").node) === EzXML.HTML_DOCUMENT_NODE

        @test_throws ArgumentError parsehtml("")
    end
end

@testset "Stream Reader ($buff_f)" for buff_f in [IOBuffer, wrapped_buff]
    for i in 0:17
        t = convert(EzXML.ReaderType, i)
        @test t == i
        @test occursin(r"READER_[A-Z_]+$", repr(t))
        @test string(t) == string(i)
        @test convert(EzXML.ReaderType, t) === t
    end
    @test_throws AssertionError repr(convert(EzXML.ReaderType, -1))
    @test_throws AssertionError repr(convert(EzXML.ReaderType, 18))

    sample2 = joinpath(dirname(@__FILE__), "sample2.xml")
    reader = open(EzXML.StreamReader, sample2)
    @test isa(reader, EzXML.StreamReader)
    typs = []
    names = []
    depths = []
    contents = []
    attributes = []
    for typ in reader
        push!(typs, typ)
        push!(names, nodename(reader))
        push!(depths, nodedepth(reader))
        if typ == EzXML.READER_ELEMENT && nodename(reader) == "elm"
            push!(contents, nodecontent(reader))
            push!(attributes, reader["attr1"])
        end
        @test isa(expandtree(reader), EzXML.Node)
    end
    @test typs[1] === EzXML.READER_ELEMENT
    @test typs[2] === EzXML.READER_SIGNIFICANT_WHITESPACE
    @test names[1] == "root"
    @test names[3] == "elm"
    @test depths[1] === 0
    @test depths[end] === 0
    @test maximum(depths) === 2
    @test contents[1] == "some content 1"
    @test contents[2] == "some content 2"
    @test attributes[1] == "attr1 value 1"
    @test attributes[2] == "attr1 value 2"
    @test open(collect, EzXML.StreamReader, sample2) == typs

    simple_graphml = joinpath(dirname(@__FILE__), "simple.graphml")
    reader = open(EzXML.StreamReader, simple_graphml)
    @test isa(reader, EzXML.StreamReader)
    typs = []
    names = []
    namespaces = []
    for typ in reader
        push!(typs, typ)
        push!(names, nodename(reader))
        if typ == EzXML.READER_ELEMENT
            push!(namespaces, namespace(reader))
        end
        @test isa(expandtree(reader), EzXML.Node)
    end
    @test first(typs) === EzXML.READER_COMMENT
    @test first(names) == "#comment"
    @test last(typs) === EzXML.READER_END_ELEMENT
    @test last(names) == "graphml"
    @test first(namespaces) == "http://graphml.graphdrawing.org/xmlns"
    @test close(reader) === nothing

    reader = open(EzXML.StreamReader, simple_graphml)
    typs = []
    names = []
    for typ in reader
        push!(typs, typ)
        push!(names, nodename(reader))
    end
    @test first(typs) === EzXML.READER_COMMENT
    @test first(names) == "#comment"
    @test last(typs) === EzXML.READER_END_ELEMENT
    @test last(names) == "graphml"
    @test close(reader) === nothing

    input = open(simple_graphml)
    reader = EzXML.StreamReader(input)
    typs = []
    names = []
    for typ in reader
        push!(typs, typ)
        push!(names, nodename(reader))
    end
    @test first(typs) === EzXML.READER_COMMENT
    @test first(names) == "#comment"
    @test last(typs) === EzXML.READER_END_ELEMENT
    @test last(names) == "graphml"
    @test isopen(input)
    @test close(reader) === nothing
    @test !isopen(input)

    input = buff_f("""
    <root foo="FOO"/>
    """)
    reader = EzXML.StreamReader(input)
    for typ in reader
        if typ == EzXML.READER_ELEMENT
            @test haskey(reader, "foo")
            @test !haskey(reader, "bar")
            @test reader["foo"] == "FOO"
            @test_throws ArgumentError namespace(reader)
        end
    end

    input = buff_f("""
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head><title>Hey</title></head>
        <body/>
    </html>
    """)
    names = String[]
    reader = EzXML.StreamReader(input)
    for typ in reader
        @test reader.:type === typ
        push!(names, reader.name)
        if reader.name == "head" && reader.:type == EzXML.READER_ELEMENT
            @test reader.depth == 1
            @test reader.namespace == "http://www.w3.org/1999/xhtml"
        elseif reader.name == "title" && reader.:type == EzXML.READER_ELEMENT
            @test reader.depth == 2
            @test reader.content == "Hey"
            @test reader.namespace == "http://www.w3.org/1999/xhtml"
        elseif reader.:type == EzXML.READER_END_ELEMENT
            @test !hasnodecontent(reader)
            @test reader.content === nothing
        end
    end
    @test "head" ∈ names
    @test "title" ∈ names

    @test_throws EzXML.XMLError iterate(EzXML.StreamReader(buff_f("not xml")))

    # memory management test
    for _ in 1:10
        reader = EzXML.StreamReader(buff_f("<a><b/></a>"))
        for typ in reader
            if typ == EzXML.READER_ELEMENT && EzXML.nodename(reader) == "a"
                a = EzXML.expandtree(reader)
                b = EzXML.firstelement(a)
            end
        end
        close(reader)
    end
    @test true

    reader = EzXML.StreamReader(buff_f("""
    <a attr1="" attr2="This is cool">
        <b/>
    </a>
    """))
    for typ in reader
        if typ == EzXML.READER_ELEMENT
            if nodename(reader) == "a"
                @test !hasnodevalue(reader)
                @test_throws ArgumentError nodevalue(reader)
                @test hasnodeattributes(reader)
                @test countattributes(reader) == 2
                @test nodeattributes(reader) == Dict{String,String}("attr1"=>"", "attr2"=>"This is cool")
                @test reader[1] == ""
                @test reader[2] == "This is cool"
                @test_throws KeyError reader[3]
                @test_throws KeyError reader["noattr"]
                for (i, attr) in enumerate(eachattribute(reader))
                    @test hasnodevalue(attr)
                    @test nodedepth(attr) == 1
                    if i == 1
                        @test nodename(attr) == "attr1"
                        @test nodevalue(attr) == ""
                    else
                        @test nodename(attr) == "attr2"
                        @test nodevalue(attr) == "This is cool"
                    end
                end
            elseif nodename(reader) == "b"
                @test !hasnodeattributes(reader)
                @test nodeattributes(reader) == Dict{String,String}()
                @test countattributes(reader) == 0
            end
        elseif typ == EzXML.READER_END_ELEMENT
            @test_throws ArgumentError eachattribute(reader)
        end
    end
    close(reader)

    # memory management test (XPath)
    # FIXME: support XPath
    #for _ in 1:10
    #    reader = EzXML.StreamReader(buff_f("<a><b/></a>"))
    #    for typ in reader
    #        if typ == EzXML.READER_ELEMENT && EzXML.nodename(reader) == "a"
    #            a = EzXML.expandtree(reader)
    #            b = findall("//b[1]", a)
    #        end
    #    end
    #    close(reader)
    #end
    #@test true
    reader = EzXML.StreamReader(buff_f("<a><b/></a>"))
    for typ in reader
        if typ == EzXML.READER_ELEMENT && EzXML.nodename(reader) == "a"
            a = EzXML.expandtree(reader)
            @test_throws ArgumentError findall("//b[1]", a, String[])
        end
    end
    close(reader)
    @test true

    # TODO: Activate this test.
    #@assert !isfile("not-exist.xml")
    #@test_throws EzXML.XMLError open(EzXML.StreamReader, "not-exist.xml")
end

@testset "Constructors" begin
    n = XMLDocumentNode("1.0")
    @test isa(n, EzXML.Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.DOCUMENT_NODE
    @test document(n) === EzXML.Document(n.ptr)

    n = HTMLDocumentNode(nothing, nothing)
    @test isa(n, EzXML.Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.HTML_DOCUMENT_NODE
    @test document(n) === EzXML.Document(n.ptr)

    n = HTMLDocumentNode("http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd",
                         "-//W3C//DTD XHTML 1.0 Strict//EN")
    @test isa(n, EzXML.Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.HTML_DOCUMENT_NODE
    @test document(n) === EzXML.Document(n.ptr)

    n = ElementNode("node")
    @test isa(n, EzXML.Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.ELEMENT_NODE
    @test iselement(n)
    @test_throws ArgumentError document(n)
    @test getproperty.(Ref(n), propertynames(n)) isa Tuple

    n = TextNode("some text")
    @test isa(n, EzXML.Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.TEXT_NODE
    @test istext(n)
    @test_throws ArgumentError document(n)

    n = CommentNode("some comment")
    @test isa(n, EzXML.Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.COMMENT_NODE
    @test iscomment(n)
    @test_throws ArgumentError document(n)

    n = CDataNode("some CDATA")
    @test isa(n, EzXML.Node)
    @test n.owner == n
    @test nodetype(n) === EzXML.CDATA_SECTION_NODE
    @test iscdata(n)
    @test_throws ArgumentError document(n)

    n = AttributeNode("attr", "value")
    @test isa(n, EzXML.Node)
    @test n.owner == n
    @test nodetype(n) == EzXML.ATTRIBUTE_NODE
    @test isattribute(n)
    @test_throws ArgumentError document(n)

    n = DTDNode("open-hatch")
    @test isa(n, EzXML.Node)
    @test isdtd(n)
    @test n.owner === n
    @test nodetype(n) === EzXML.DTD_NODE
    @test nodename(n) == "open-hatch"
    @test_throws ArgumentError systemID(n)
    @test_throws ArgumentError externalID(n)

    n = DTDNode("open-hatch",
                "http://www.textuality.com/boilerplate/OpenHatch.xml")
    @test isa(n, EzXML.Node)
    @test isdtd(n)
    @test n.owner === n
    @test nodetype(n) === EzXML.DTD_NODE
    @test systemID(n) == "http://www.textuality.com/boilerplate/OpenHatch.xml"
    @test_throws ArgumentError externalID(n)

    n = DTDNode("open-hatch",
                "http://www.textuality.com/boilerplate/OpenHatch.xml",
                "-//Textuality//TEXT Standard open-hatch boilerplate//EN")
    @test isa(n, EzXML.Node)
    @test isdtd(n)
    @test n.owner === n
    @test nodetype(n) === EzXML.DTD_NODE
    @test systemID(n) == "http://www.textuality.com/boilerplate/OpenHatch.xml"
    @test externalID(n) == "-//Textuality//TEXT Standard open-hatch boilerplate//EN"

    doc = XMLDocument()
    @test isa(doc, EzXML.Document)
    @test doc.node.owner === doc.node
    @test nodetype(doc.node) === EzXML.DOCUMENT_NODE
    @test !hasroot(doc)
    @test_throws ArgumentError root(doc)
    @test getproperty.(Ref(doc), propertynames(doc)) isa Tuple

    doc = HTMLDocument()
    @test isa(doc, EzXML.Document)
    @test doc.node.owner === doc.node
    @test nodetype(doc.node) == EzXML.HTML_DOCUMENT_NODE
    @test !hasroot(doc)
    @test_throws ArgumentError root(doc)

    doc = HTMLDocument("http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd",
                       "-//W3C//DTD XHTML 1.0 Strict//EN")
    @test isa(doc, EzXML.Document)
    @test doc.node.owner === doc.node
    @test nodetype(doc.node) == EzXML.HTML_DOCUMENT_NODE
    @test !hasroot(doc)
    @test_throws ArgumentError root(doc)
end

@testset "Traversal" begin
    doc = parsexml("<root/>")
    @test hasroot(doc)
    @test !hasdtd(doc)
    @test isa(root(doc), EzXML.Node)
    @test root(doc) == root(doc)
    @test root(doc) === root(doc)
    @test hash(root(doc)) === hash(root(doc))
    @test nodetype(root(doc)) === EzXML.ELEMENT_NODE
    @test nodepath(root(doc)) == "/root"
    @test nodename(root(doc)) == "root"
    @test nodecontent(root(doc)) == ""
    @test document(root(doc)) == doc
    @test document(root(doc)) === doc
    @test !hasparentnode(doc.node)
    @test_throws ArgumentError parentnode(doc.node)
    @test hasparentnode(root(doc))
    @test parentnode(root(doc)) === doc.node
    @test_throws ArgumentError nodename(parentnode(root(doc)))
    @test_throws ArgumentError dtd(doc)

    doc = parsexml("""
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

    <html xmlns="http://www.w3.org/1999/xhtml">
        <head><title>hello</title></head>
        <body>Content</body>
    </html>
    """)
    @test hasroot(doc)
    @test hasdtd(doc)
    @test isa(dtd(doc), EzXML.Node)
    @test isdtd(dtd(doc))
    @test dtd(doc) === dtd(doc)
    @test nodename(dtd(doc)) == "html"
    @test systemID(dtd(doc)) == "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    @test externalID(dtd(doc)) == "-//W3C//DTD XHTML 1.0 Transitional//EN"
    @test parentnode(dtd(doc)) === doc.node
    @test_throws ArgumentError systemID(root(doc))
    @test_throws ArgumentError externalID(root(doc))

    doc = parsexml("""
    <?xml version="1.0"?>
    <r>
        <c1/>
        <c2/>
        <c3/>
    </r>
    """)
    r = root(doc)
    @test nodetype(firstnode(r)) === EzXML.TEXT_NODE
    @test nodetype(lastnode(r)) === EzXML.TEXT_NODE
    @test nodetype(firstelement(r)) === EzXML.ELEMENT_NODE
    @test nodename(firstelement(r)) == "c1"
    @test nodetype(lastelement(r)) === EzXML.ELEMENT_NODE
    @test nodename(lastelement(r)) == "c3"
    c1 = firstelement(r)
    @test hasnextnode(c1)
    @test hasprevnode(c1)
    @test nodetype(nextnode(c1)) === EzXML.TEXT_NODE
    @test nodetype(prevnode(c1)) === EzXML.TEXT_NODE
    @test hasnextelement(c1)
    @test !hasprevelement(c1)
    c2 = nextelement(c1)
    @test nodename(c2) == "c2"
    @test hasnextelement(c2)
    @test hasprevelement(c2)
    @test prevelement(c2) == c1
    c3 = nextelement(c2)
    @test nodename(c3) == "c3"
    @test !hasnextelement(c3)
    @test hasprevelement(c3)
    @test prevelement(c3) == c2
    @test_throws ArgumentError prevelement(c1)
    @test_throws ArgumentError nextelement(c3)

    doc = parsexml("""
    <?xml version="1.0"?>
    <root attr="some attribute value"><child>some content</child></root>
    """)
    @test nodecontent(root(doc)) == "some content"
    @test haskey(root(doc), "attr")
    @test !haskey(root(doc), "bah")
    @test root(doc)["attr"] == "some attribute value"
    @test_throws KeyError root(doc)["bah"]
    @test delete!(root(doc), "attr") == root(doc)
    @test !haskey(root(doc), "attr")
    @test_throws KeyError root(doc)["attr"]

    doc = parsexml("<root/>")
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
    @test_throws ArgumentError namespace(parentnode(root(doc)))

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
    @test nodename(root(doc)) == "html"
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

    doc = parsexml("""
    <root xmlns="http://xxx.com" xmlns:y="http://yyy.com">
        <child y:foo="Y"/>
    </root>
    """)
    child = firstelement(root(doc))
    @test haskey(child, "y:foo")
    @test !haskey(child, "foo")
    @test child["y:foo"] == "Y"
    @test_throws KeyError child["foo"]
    child["foo"] = "X"
    @test haskey(child, "foo")
    @test child["foo"] == "X"
    @test child["y:foo"] == "Y"

    doc = parsexml("""
    <root xmlns="http://xxx.com" xmlns:y="http://yyy.com">
        <child y:foo="Y" foo="X"/>
    </root>
    """)
    child = firstelement(root(doc))
    @test child["foo"] == "X"
    @test child["y:foo"] == "Y"
    delete!(child, "foo")
    @test !haskey(child, "foo")
    @test haskey(child, "y:foo")
    delete!(child, "y:foo")
    @test !haskey(child, "foo")
    @test !haskey(child, "y:foo")

    doc = parsexml("""
    <root xmlns="http://xxx.com" xmlns:y="http://yyy.com">
        <child foo="X" y:foo="Y"/>
    </root>
    """)
    child = firstelement(root(doc))
    @test child["foo"] == "X"
    @test child["y:foo"] == "Y"
    delete!(child, "foo")
    @test !haskey(child, "foo")
    @test haskey(child, "y:foo")
    delete!(child, "y:foo")
    @test !haskey(child, "foo")
    @test !haskey(child, "y:foo")

    # no namespace
    doc = parsexml("""
    <root></root>
    """)
    @test isempty(namespaces(root(doc)))
    @test_throws ArgumentError namespace(root(doc))

    @testset "Counters" begin
        doc = parsexml("<root/>")
        @test !hasnode(root(doc))
        @test countnodes(root(doc)) === 0
        @test countelements(root(doc)) === 0
        @test countattributes(root(doc)) === 0
        @test addelement!(root(doc), "c1") === lastelement(root(doc))
        root(doc)["attr1"] = "1"
        @test countnodes(root(doc)) === 1
        @test countelements(root(doc)) === 1
        @test countelements(root(doc)) === 1
        @test countattributes(root(doc)) === 1
        @test addelement!(root(doc), "c2", "some content") === lastelement(root(doc))
        @test countnodes(root(doc)) === 2
        @test countelements(root(doc)) === 2
        @test_throws ArgumentError countattributes(doc.node)
    end

    @testset "Iterators" begin
        doc = parsexml("<root/>")
        ns = EzXML.Node[]
        for (i, node) in enumerate(eachnode(root(doc)))
            @test isa(node, EzXML.Node)
            push!(ns, node)
        end
        @test length(ns) == 0
        @test nodes(root(doc)) == ns
        ns = EzXML.Node[]
        for (i, node) in enumerate(eachelement(root(doc)))
            @test isa(node, EzXML.Node)
            push!(ns, node)
        end
        @test length(ns) == 0
        @test elements(root(doc)) == ns

        doc = parsexml("""
        <root><c1></c1><c2></c2></root>
        """)
        ns = EzXML.Node[]
        for (i, node) in enumerate(eachnode(root(doc)))
            @test isa(node, EzXML.Node)
            push!(ns, node)
        end
        @test length(ns) == 2
        @test nodes(root(doc)) == ns
        ns = EzXML.Node[]
        for (i, node) in enumerate(eachelement(root(doc)))
            @test isa(node, EzXML.Node)
            push!(ns, node)
        end
        @test length(ns) == 2
        @test elements(root(doc)) == ns

        doc = parsexml("""
        <root>
            <c1></c1>
            <c2></c2>
        </root>
        """)
        ns = EzXML.Node[]
        for (i, node) in enumerate(eachnode(root(doc)))
            @test isa(node, EzXML.Node)
            push!(ns, node)
        end
        @test length(ns) == 5
        @test nodes(root(doc)) == ns
        ns = EzXML.Node[]
        for (i, node) in enumerate(eachelement(root(doc)))
            @test isa(node, EzXML.Node)
            push!(ns, node)
        end
        @test length(ns) == 2
        @test elements(root(doc)) == ns

        doc = parsexml("""
        <root>
            <c1/>
            <c2/>
            <c3/>
        </root>
        """)
        @test collect(eachnode(root(doc), true)) == reverse(collect(eachnode(root(doc))))
        @test collect(eachelement(root(doc), true)) == reverse(collect(eachelement(root(doc))))
        @test nodes(root(doc), true) == reverse(nodes(root(doc)))
        @test elements(root(doc), true) == reverse(elements(root(doc)))

        doc = parsexml("""
        <?xml version="1.0"?>
        <root attr1="foo" attr2="bar"></root>
        """)
        for node in eachattribute(root(doc))
            attr = nodename(node)
            val = nodecontent(node)
            @test val == (attr == "attr1" ? "foo" : "bar")
        end
        @test [(nodename(n), nodecontent(n)) for n in attributes(root(doc))] == [("attr1", "foo"), ("attr2", "bar")]
        @test_throws ArgumentError eachattribute(doc.node)
        @test_throws ArgumentError attributes(doc.node)
    end
end

@testset "Properties" begin
    doc = readxml(joinpath(dirname(@__FILE__), "sample1.xml"))
    @test doc.version == "1.0"
    @test doc.encoding === nothing
    doc = readxml(joinpath(dirname(@__FILE__), "sample2.xml"))
    @test doc.version == "1.0"
    @test doc.encoding == "UTF-8"

    doc = parsexml("<root/>")
    @test doc.node isa EzXML.Node
    @test doc.node.type === EzXML.DOCUMENT_NODE
    @test doc.node.name === nothing
    @test doc.node.path == "/"
    @test doc.node.content == ""
    @test doc.node.namespace === nothing
    @test doc.root isa EzXML.Node
    @test doc.root.type === EzXML.ELEMENT_NODE
    @test doc.root.name == "root"
    @test doc.root.path == "/root"
    @test doc.root.content == ""
    @test doc.root.namespace === nothing
    @test doc.dtd === nothing

    doc = parsexml("""<root attr="100">some content</root>""")
    @test doc.root.content == "some content"
    attr = attributes(doc.root)[1]
    @test attr.type === EzXML.ATTRIBUTE_NODE
    @test attr.name == "attr"
    @test attr.path == "/root/@attr"
    @test attr.content == "100"
    @test attr.namespace === nothing

    doc = parsexml("""
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head><title>Title</title></head>
        <body>Body</body>
    </html>
    """)
    @test doc.root.namespace == "http://www.w3.org/1999/xhtml"
    head = firstelement(doc.root)
    body = lastelement(doc.root)
    @test head.namespace == body.namespace == "http://www.w3.org/1999/xhtml"

    # node traversal
    doc = parsexml("""
    <root>
        <c1/>
        <c2/>
        <c3/>
    </root>
    """)
    @test doc.root.document === doc
    @test doc.root.parentnode === doc.node
    @test doc.root.parentelement === nothing
    @test doc.root.firstnode.type === EzXML.TEXT_NODE
    @test doc.root.lastnode.type === EzXML.TEXT_NODE
    @test doc.root.firstelement.name == "c1"
    @test doc.root.lastelement.name  == "c3"
    @test doc.root.firstnode.nextnode === doc.root.firstelement
    @test doc.root.firstnode.prevnode === nothing
    @test doc.root.firstelement.nextelement === doc.root.lastelement.prevelement

    # setproperty!
    elm = ElementNode("foo")
    # name
    @test elm.name == "foo"
    elm.name = "bar"
    @test elm.name == "bar"
    elm.name = 100
    @test elm.name == "100"
    # content
    @test elm.content == ""
    elm.content = "hi there"
    @test elm.content == "hi there"
    elm.content = 3.14
    @test elm.content == "3.14"
end

@testset "Construction" begin
    doc = XMLDocument()
    @test isa(doc, EzXML.Document)
    @test nodetype(doc.node) === EzXML.DOCUMENT_NODE
    @test !hasroot(doc)
    @test_throws ArgumentError root(doc)
    r1 = ElementNode("r1")
    @test setroot!(doc, r1) === r1
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
    @test nodename(el) == "el"
    setnodename!(el, "EL")
    @test nodename(el) == "EL"
    @test nodecontent(el) == ""
    setnodecontent!(el, "some content")
    @test nodecontent(el) == "some content"

    doc = XMLDocument()
    @test countnodes(doc.node) === 0
    d1 = DTDNode("hello", "hello.dtd")
    @test setdtd!(doc, d1) === d1
    @test countnodes(doc.node) === 1
    @test dtd(doc) === d1
    setroot!(doc, ElementNode("root"))
    @test countnodes(doc.node) === 2
    @test nextnode(d1) === root(doc)
    d2 = DTDNode("hello", "hello2.dtd")
    @test setdtd!(doc, d2) === d2
    @test countnodes(doc.node) === 2
    @test dtd(doc) === d2
    @test_throws ArgumentError setdtd!(doc, ElementNode("foo"))

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

    doc = parsexml("<root/>")
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
    @test [(nodename(n), nodecontent(n)) for n in attributes(root(doc))] == [("attr1", "1"), ("attr2", "2")]

    doc = parsexml("""
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

    doc = parsexml("""
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

    doc = parsexml("""
    <root xmlns:x="http://xxx.org/" xmlns:y="http://yyy.org/">
        <c x:attr="x-attr" y:attr="y-attr"/>
        <c y:attr="y-attr" x:attr="x-attr"/>
        <c x:attr=""/>
    </root>
    """)
    c = firstelement(root(doc))
    @test !haskey(c, "attr")
    @test haskey(c, "x:attr")
    @test haskey(c, "y:attr")
    @test !haskey(c, "z:attr")
    @test c["x:attr"] == "x-attr"
    @test c["y:attr"] == "y-attr"
    @test_throws KeyError c["attr"]
    @test_throws ArgumentError c["z:attr"]
    c = nextelement(c)
    @test !haskey(c, "attr")
    @test haskey(c, "x:attr")
    @test haskey(c, "y:attr")
    @test c["y:attr"] == "y-attr"
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

    # move <child/> of doc1 to doc2
    doc1 = parsexml("<root><child/></root>")
    doc2 = parsexml("<root/>")
    child = firstelement(root(doc1))
    @test_throws ArgumentError link!(root(doc2), child)
    unlink!(child)
    link!(root(doc2), child)
    @test child ∉ eachnode(root(doc1))
    @test child ∈ eachnode(root(doc2))

    doc1 = parsexml("<root><child/></root>")
    doc2 = parsexml("<root><target/></root>")
    child = firstelement(root(doc1))
    target = firstelement(root(doc2))
    @test_throws ArgumentError linknext!(target, child)
    @test_throws ArgumentError linkprev!(target, child)

    # Issue #28
    doc = readxml(joinpath(dirname(@__FILE__), "sample1.xml"))
    unlink!(firstelement(root(doc)))
    # No need to check the return value because this is a bug of memory
    # management. Regression will be detected as a SIGABRT.
    @test true
end

@testset "Validation" begin
    dtdfile = joinpath(dirname(@__FILE__), "note.dtd")
    system = relpath(dtdfile)
    if Sys.iswindows()
        system = replace(system, '\\' => '/')
    end

    doc = parsexml("""
    <?xml version="1.0"?>
    <!DOCTYPE note SYSTEM "$(system)">
    <note>
        <title>Note title</title>
        <body>Note body</body>
    </note>
    """)
    @test isempty(validate(doc))

    doc = parsexml("""
    <?xml version="1.0"?>
    <!DOCTYPE note SYSTEM "$(system)">
    <note>
        <body>Note body</body>
    </note>
    """)
    @test !isempty(validate(doc))

    doc = parsexml("""
    <?xml version="1.0"?>
    <note>
        <title>Note title</title>
        <body>Note body</body>
    </note>
    """)
    @test !isempty(validate(doc))

    doc = parsexml("""
    <?xml version="1.0"?>
    <note>
        <title>Note title</title>
        <body>Note body</body>
    </note>
    """)
    dtd = readdtd(dtdfile)
    @test isempty(validate(doc, dtd))
end

@testset "XPath" begin
    doc = parsexml("""
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
    @test length(findall("/root", doc)) == 1
    @test findall("/root", doc)[1] === root(doc)
    @test length(findall("/root/foo", doc)) == 2
    @test findall("/root/foo", doc)[1] === elements(root(doc))[1]
    @test findall("/root/foo", doc)[2] === elements(root(doc))[2]
    for (i, node) in enumerate(findall("//bar", doc))
        @test nodename(node) == "bar"
        @test nodecontent(node) == string(i)
    end
    for (i, node) in enumerate(findall("//bar/text()", doc))
        @test nodename(node) == "text"
        @test nodecontent(node) == string(i)
    end
    @test findfirst("//bar", doc) === findall("//bar", doc)[1]
    @test findlast("//bar", doc) === findall("//bar", doc)[3]
    @test length(findall("/baz", doc)) == 0
    @test_throws EzXML.XMLError findall("//bar!", doc)
    @test findall("foo", root(doc)) == findall("//foo", doc)
    @test findfirst("foo", root(doc)) === findfirst("//foo", doc)
    @test findlast("foo", root(doc)) === findlast("//foo", doc)
    @test findall("root", doc) == findall("/root", root(doc))
    @test findall("foo", root(doc)) == findall("//foo", doc)
    @test findfirst("bambam", doc) === nothing
    @test findlast("bambam", doc) === nothing
    @test findfirst("bambam", root(doc)) === nothing
    @test findlast("bambam", root(doc)) === nothing

    go = readxml(joinpath(dirname(@__FILE__), "go.sample.xml"))
    go_uri =  "http://www.geneontology.org/dtds/go.dtd#"
    @test findall("/go:go", root(go)) == [root(go)]
    @test findfirst("/go:go", root(go)) === root(go)
    @test findlast("/go:go", root(go)) === root(go)
    @test findall("/g:go", root(go), ["g" => go_uri]) == [root(go)]
    @test findfirst("/g:go", root(go), ["g" => go_uri]) === root(go)
    @test findlast("/g:go", root(go), ["g" => go_uri]) === root(go)
    @test nodename.(findall("/go:go/rdf:RDF/go:term", root(go))) == ["term", "term"]
    @test findall("/go:go/rdf:RDF/go:term", root(go)) == findall("//go:term", root(go))

    # default namespace
    doc = parsexml("""
    <go xmlns="http://www.geneontology.org/dtds/go.dtd#">
        <term><accession>GO:0000001</accession></term>
    </go>
    """)
    warnmsg = "ignored the empty prefix for 'http://www.geneontology.org/dtds/go.dtd#'; expected to be non-empty"
    @test isempty(@test_logs (:warn, warnmsg) findall("term", root(doc)))
    @test isempty(@test_logs (:warn, warnmsg) findall("./term", root(doc)))
    @test findall("go:term", root(doc), ["go" => "http://www.geneontology.org/dtds/go.dtd#"]) == elements(root(doc))
    @test findall("./go:term", root(doc), ["go" => "http://www.geneontology.org/dtds/go.dtd#"]) == elements(root(doc))

    # pull/8
    doc = parsexml("""<root xmlns="urn:foo"/>""")
    @test isempty(findall("//foo:notexit/*", root(doc), [("foo", "urn:foo")]))
end

@testset "Misc" begin
    @testset "show" begin
        doc = parsexml("""<root attr="val"/>""")
        @test occursin(r"^EzXML.Node\(<DOCUMENT_NODE@0x[a-f0-9]+>\)$", repr(doc.node))
        @test occursin(r"^EzXML.Node\(<ELEMENT_NODE\[root\]@0x[a-f0-9]+>\)$", repr(root(doc)))
        @test occursin(r"^EzXML.Node\(<ATTRIBUTE_NODE\[attr\]@0x[a-f0-9]+>\)$", repr(attributes(root(doc))[1]))
        @test occursin(r"^EzXML.Document\(EzXML.Node\(<DOCUMENT_NODE@0x[a-f0-9]+>\)\)$", repr(doc))

        sample2 = joinpath(dirname(@__FILE__), "sample2.xml")
        reader = open(EzXML.StreamReader, sample2)
        @test occursin(r"^EzXML.StreamReader\(<[A-Z_]+@0x[a-f0-9]+>\)$", repr(reader))
        close(reader)
    end

    @testset "print" begin
        elm = ElementNode("elm")
        @test string(elm) == "<elm/>"

        txt = TextNode("42 > 41")
        @test string(txt) == "42 &gt; 41"

        cdata = CDataNode("42 > 41")
        @test string(cdata) == "<![CDATA[42 > 41]]>"

        comment = CommentNode("some comment")
        @test string(comment) == "<!--some comment-->"

        doc = parsexml("<e1><e2/></e1>")
        buf = IOBuffer()
        print(buf, doc)
        @test take!(buf) == b"""
        <?xml version="1.0" encoding="UTF-8"?>
        <e1><e2/></e1>
        """

        doc = parsexml("<e1><e2/></e1>")
        buf = IOBuffer()
        prettyprint(buf, doc)
        @test take!(buf) == b"""
        <?xml version="1.0" encoding="UTF-8"?>
        <e1>
          <e2/>
        </e1>
        """
    end
end

# Check no uncaught errors.
@test isempty(EzXML.XML_GLOBAL_ERROR_STACK)

if Sys.isunix()
    julia = joinpath(Sys.BINDIR, "julia")
    julia = `$julia --startup-file=no`
    @testset "Examples" begin
        # Check examples work without error.
        cd(joinpath(dirname(@__FILE__), "..", "example")) do
            stdout = devnull

            @testset "primates.jl" begin
                try
                    run(pipeline(`$(julia) primates.jl`, stdout=stdout))
                    @test true
                catch
                    @test false
                end
            end

            @testset "julia2xml.jl" begin
                try
                    run(pipeline(pipeline(`echo "1 + sum([2,3])"`, `$(julia) julia2xml.jl`), stdout=stdout))
                    @test true
                catch
                    @test false
                end
            end

            @testset "listlinks.jl" begin
                try
                    links = joinpath(dirname(@__FILE__), "links.html")
                    run(pipeline(`$(julia) listlinks.jl $(links)`, stdout=stdout))
                    @test true
                catch
                    @test false
                end
            end
        end
    end
end

# Stress tests
# ------------
#
# Check the memory usage using the top command or something.

macro showprogress(name, loop)
    push!(loop.args[2].args, :(if n % 1000 == 0; print('\r', rpad($(name), 12), round(Int, n / N * 100), "%"); end))
    return :($loop; println())
end

if "stress" in ARGS
    const N = 1_000_000

    function parse_xml()
        @showprogress "parse_xml" for n in 1:N
            parsexml("""
            <?xml version="1.0" encoding="UTF-8"?>
            <root>
                <child>text</child>
                <child>text</child>
                <child>text</child>
            </root>
            """)
        end
    end

    function link_xml()
        @showprogress "link_xml" for n in 1:N
            doc = parsexml("""
            <?xml version="1.0" encoding="UTF-8"?>
            <root/>
            """)
            child = ElementNode("child")
            link!(root(doc), child)
            grandchild = ElementNode("grandchild")
            link!(child, grandchild)
        end
    end

    function unlink_xml()
        @showprogress "unlink_xml" for n in 1:N
            doc = parsexml("""
            <?xml version="1.0" encoding="UTF-8"?>
            <root>
                <child>
                    <grandchild attr="attribute value">text</grandchild>
                </child>
            </root>
            """)
            child = firstelement(root(doc))
            unlink!(child)
        end
    end

    function swap_xml()
        @showprogress "swap_xml" for n in 1:N
            doc1 = parsexml("<a><b><c/></b></a>")
            doc2 = parsexml("<a><b><c/></b></a>")
            b1 = firstelement(root(doc1))
            b2 = firstelement(root(doc2))
            unlink!(b1)
            link!(root(doc2), b1)
            unlink!(b2)
            link!(root(doc1), b2)
        end
    end

    parse_xml()
    link_xml()
    unlink_xml()
    swap_xml()
end

