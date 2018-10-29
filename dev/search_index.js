var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#Home-1",
    "page": "Home",
    "title": "Home",
    "category": "section",
    "text": "EzXML.jl is a package for handling XML and HTML documents. The APIs are simple and consistent, and provide a range of functionalities including:Reading and writing XML/HTML documents.\nTraversing XML/HTML trees with DOM interfaces.\nSearching elements using XPath.\nProper namespace handling.\nCapturing error messages.\nAutomatic memory management.\nDocument validation.\nStreaming parsing for large XML files.Here is an example of parsing and traversing an XML document:# Load the package.\nusing EzXML\n\n# Parse an XML string\n# (use `readxml(<filename>)` to read a document from a file).\ndoc = parsexml(\"\"\"\n<primates>\n    <genus name=\"Homo\">\n        <species name=\"sapiens\">Human</species>\n    </genus>\n    <genus name=\"Pan\">\n        <species name=\"paniscus\">Bonobo</species>\n        <species name=\"troglodytes\">Chimpanzee</species>\n    </genus>\n</primates>\n\"\"\")\n\n# Get the root element from `doc`.\nprimates = root(doc)\n\n# Iterate over child elements.\nfor genus in eachelement(primates)\n    # Get an attribute value by name.\n    genus_name = genus[\"name\"]\n    println(\"- \", genus_name)\n    for species in eachelement(genus)\n        # Get the content within an element.\n        species_name = nodecontent(species)\n        println(\"  └ \", species[\"name\"], \" (\", species_name, \")\")\n    end\nend\nprintln()\n\n# Find texts using XPath query.\nfor species_name in nodecontent.(findall(\"//species/text()\", primates))\n    println(\"- \", species_name)\nendIf you are new to this package, read the manual page first. It provides a general guide to the package. The reference page offers a full documentation for each function, and the developer notes page explains about the internal design for developers."
},

{
    "location": "manual/#",
    "page": "Manual",
    "title": "Manual",
    "category": "page",
    "text": ""
},

{
    "location": "manual/#Manual-1",
    "page": "Manual",
    "title": "Manual",
    "category": "section",
    "text": "This page is dedicated to those who are new to EzXML.jl. It is recommended to read this page before reading other pages to grasp the concepts of the package first. Once you have read it, the reference page would be a better place to find necessary functions. The developer notes page is for developers and most users do not need to read it.In this manual, we use using EzXML to load the package for brevity.  However, it is recommended to use import EzXML or something similar for non-trivial scripts or packages because EzXML.jl exports a number of names to your environment. These are useful in an interactive session but easily conflict with other names. If you would like to know the list of exported names, please go to the top of src/EzXML.jl, where you will see a long list of type and function names.EzXML.jl is built on top of libxml2, a portable C library compliant to the XML standard. If you are no familiar with XML itself, the following links offer good resources to learn the basic concents of XML:XML Tutorial\nXML Tree\nXML XPath# Ignore pointers.\nDocTestFilters = r\"@0x[0-9a-f]{16}\"\n# Load EzXML.jl\nDocTestSetup = :(using EzXML)"
},

{
    "location": "manual/#Data-types-1",
    "page": "Manual",
    "title": "Data types",
    "category": "section",
    "text": "There are two types that constitute an XML document and its components: Document and Node, respectively. The Document type represents a whole XML document. A Document object points to the topmost node of the XML document, but note that it is different from the root node you see in an XML file.  The Node type represents almost everything in an XML document; elements, attributes, texts, CDATAs, comments, documents, etc. are all Node type objects. These two type names are not exported from EzXML.jl because their names are very general and easily conflict with other names exported from other packages.  However, the user can expect them as public APIs and use them with the EzXML. prefix.Here is an example to create an empty XML document using the XMLDocument constructor:julia> using EzXML\n\njulia> doc = XMLDocument()\nEzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fd9f1f14370>))\n\njulia> typeof(doc)\nEzXML.Document\n\njulia> doc.node\nEzXML.Node(<DOCUMENT_NODE@0x00007fd9f1f14370>)\n\njulia> typeof(doc.node)\nEzXML.Node\n\njulia> print(doc)  # print an XML-formatted text\n<?xml version=\"1.0\" encoding=\"UTF-8\"?>\nThe text just before the @ sign shows the node type (in this example, DOCUMENT_NODE), and the text just after @ shows the pointer address (0x00007fd9f1f14370) to a node struct of libxml2.Let\'s add a root node to the document and a text node to the root node:julia> elm = ElementNode(\"root\")  # create an element node\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f2a1b5f0>)\n\njulia> setroot!(doc, elm)\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f2a1b5f0>)\n\njulia> print(doc)\n<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root/>\n\njulia> txt = TextNode(\"some text\")  # create a text node\nEzXML.Node(<TEXT_NODE@0x00007fd9f2a81ee0>)\n\njulia> link!(elm, txt)\nEzXML.Node(<TEXT_NODE@0x00007fd9f2a81ee0>)\n\njulia> print(doc)\n<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root>some text</root>\nFinally you can write the document object to a file using the write function:julia> write(\"out.xml\", doc)\n62\n\njulia> print(String(read(\"out.xml\")))\n<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root>some text</root>\nA Node object has some properties. The most important one would be the type property, which we already saw in the example above. Other properties (name, path, content and namespace) are demonstrated in the following example. The value of a property will be nothing when there is no corresponding value.julia> elm = ElementNode(\"element\")\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f44122f0>)\n\njulia> println(elm)\n<element/>\n\njulia> elm.type\nELEMENT_NODE\n\njulia> elm.name\n\"element\"\n\njulia> elm.path\n\"/element\"\n\njulia> elm.content\n\"\"\n\njulia> elm.namespace === nothing\ntrue\n\njulia> elm.name = \"ELEMENT\"  # set element name\n\"ELEMENT\"\n\njulia> println(elm)\n<ELEMENT/>\n\njulia> elm.content = \"some text\"  # set content\n\"some text\"\n\njulia> println(elm)\n<ELEMENT>some text</ELEMENT>\n\njulia> txt = TextNode(\"  text  \")\nEzXML.Node(<TEXT_NODE@0x00007fd9f441f3f0>)\n\njulia> println(txt)\n  text\n\njulia> txt.type\nTEXT_NODE\n\njulia> txt.name\n\"text\"\n\njulia> txt.path\n\"/text()\"\n\njulia> txt.content\n\"  text  \"\naddelement!(<parent>, <child>, [<content>]) is handy when you want to add a child element to an existing node:julia> user = ElementNode(\"User\")\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f427c510>)\n\njulia> println(user)\n<User/>\n\njulia> addelement!(user, \"id\", \"167492\")\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f41ad580>)\n\njulia> println(user)\n<User><id>167492</id></User>\n\njulia> addelement!(user, \"name\", \"Kumiko Oumae\")\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f42942d0>)\n\njulia> println(user)\n<User><id>167492</id><name>Kumiko Oumae</name></User>\n\njulia> prettyprint(user)\n<User>\n  <id>167492</id>\n  <name>Kumiko Oumae</name>\n</User>On Julia 0.6, these properties can be accessed via accessor functions:julia> elm = ElementNode(\"element\")\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f41acbc0>)\n\njulia> nodetype(elm)\nELEMENT_NODE\n\njulia> nodename(elm)\n\"element\"\n\njulia> nodepath(elm)\n\"/element\"\n\njulia> nodecontent(elm)\n\"\"\n\njulia> println(elm)\n<element/>\n\njulia> setnodecontent!(elm, \"content\")\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f41acbc0>)\n\njulia> println(elm)\n<element>content</element>\n"
},

{
    "location": "manual/#DOM-1",
    "page": "Manual",
    "title": "DOM",
    "category": "section",
    "text": "The DOM (Document Object Model) API regards an XML document as a tree of nodes. There is a root node at the top of a document tree and each node has zero or more child nodes. Some nodes (e.g. texts, attributes, etc.) cannot have child nodes.For the demonstration purpose, save the next XML in \"primates.xml\" file.<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<primates>\n    <genus name=\"Homo\">\n        <species name=\"sapiens\">Human</species>\n    </genus>\n    <genus name=\"Pan\">\n        <species name=\"paniscus\">Bonobo</species>\n        <species name=\"troglodytes\">Chimpanzee</species>\n    </genus>\n</primates>readxml(<filename>) reads an XML file and builds a document object in memory. Likewise, parsexml(<string or byte array>) parses an XML string or a byte array in memory and builds a document object:julia> doc = readxml(\"primates.xml\")\nEzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fd9f410a5f0>))\n\njulia> data = String(read(\"primates.xml\"));\n\njulia> doc = parsexml(data)\nEzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fd9f4051f80>))\nBefore traversing a document we need to get the root of the document tree. The .root property returns the root element (if any) of a document:julia> primates = doc.root  # get the root element\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f4086880>)\n\njulia> root(doc)  # on Julia 0.6\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f4086880>)\n\njulia> genus = elements(primates)  # `elements` returns all child elements.\n2-element Array{EzXML.Node,1}:\n EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)\n EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)\n\njulia> genus[1].type, genus[1].name\n(ELEMENT_NODE, \"genus\")\n\njulia> genus[2].type, genus[2].name\n(ELEMENT_NODE, \"genus\")\nAttribute values can be accessed by its name like a dictionary; haskey, getindex, setindex! and delete! are overloaded for element nodes. Qualified name, which may or may not have the prefix of a namespace, can be used as a key name:julia> haskey(genus[1], \"name\")  # check whether an attribute exists\ntrue\n\njulia> genus[1][\"name\"]  # get a value as a string\n\"Homo\"\n\njulia> genus[2][\"name\"]  # same above\n\"Pan\"\n\njulia> println(genus[1])  # print a \"genus\" element before updating\n<genus name=\"Homo\">\n        <species name=\"sapiens\">Human</species>\n    </genus>\n\njulia> genus[1][\"taxonID\"] = \"9206\"  # insert a new attribute\n\"9206\"\n\njulia> println(genus[1])  # the \"genus\" element has been updated\n<genus name=\"Homo\" taxonID=\"9206\">\n        <species name=\"sapiens\">Human</species>\n    </genus>\nIn this package, a Node object is regarded as a container of its child nodes. This idea is reflected on its property and function names; for example, a property returning the first child node is named as .firstnode instead of .firstchildnode. All properties and functions provided by the EzXML module are named in this way, and the tree traversal API of a node works on its child nodes by default. Properties (functions) with a direction prefix work on that direction; for example, .nextnode returns the next sibling node and .parentnode returns the parent node.Distinction between nodes and elements is what every user should know about before using the DOM API.  There are good explanations on this topic: http://www.w3schools.com/xml/dom_nodes.asp, http://stackoverflow.com/questions/132564/whats-the-difference-between-an-element-and-a-node-in-xml. Some properties (functions) have a suffix like node or element that indicate a node type the property (function) is interested in. For example, .firstnode returns the first child node (if any), which may be a text node, but .firstelement always returns the first element node (if any):julia> primates.firstnode\nEzXML.Node(<TEXT_NODE@0x00007fd9f409f200>)\n\njulia> primates.firstelement\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)\n\njulia> primates.firstelement == genus[1]\ntrue\n\njulia> primates.lastnode\nEzXML.Node(<TEXT_NODE@0x00007fd9f404bec0>)\n\njulia> primates.lastelement\nEzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)\n\njulia> primates.lastelement === genus[2]\ntrue\nTree traversal properties return nothing when there is no corresponding node:julia> primates.firstelement.nextelement === primates.lastelement\ntrue\n\njulia> primates.firstelement.prevelement === nothing\ntrue\nHere is the list of tree traversal properties:The Document type:\n.root\n.dtd\nThe Node type:\n.document\n.parentnode\n.parentelement\n.firstnode\n.firstelement\n.lastelement\n.lastnode\n.nextnode\n.nextelement\n.nextnode\n.prevnodeIf you would like to iterate over child nodes or elements, you can use the eachnode(<parent node>) or the eachelement(<parent node>) function.  The eachnode function generates all nodes including texts, elements, comments, and so on, while eachelement selects only element nodes. nodes(<parent node>) and elements(<parent node>) are handy functions that return a vector of nodes and elements, respectively:julia> for node in eachnode(primates)\n           @show node\n       end\nnode = EzXML.Node(<TEXT_NODE@0x00007fd9f409f200>)\nnode = EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)\nnode = EzXML.Node(<TEXT_NODE@0x00007fd9f4060f70>)\nnode = EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)\nnode = EzXML.Node(<TEXT_NODE@0x00007fd9f404bec0>)\n\njulia> for node in eachelement(primates)\n           @show node\n       end\nnode = EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)\nnode = EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)\n\njulia> nodes(primates)\n5-element Array{EzXML.Node,1}:\n EzXML.Node(<TEXT_NODE@0x00007fd9f409f200>)\n EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)\n EzXML.Node(<TEXT_NODE@0x00007fd9f4060f70>)\n EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)\n EzXML.Node(<TEXT_NODE@0x00007fd9f404bec0>)\n\njulia> elements(primates)\n2-element Array{EzXML.Node,1}:\n EzXML.Node(<ELEMENT_NODE@0x00007fd9f4041a40>)\n EzXML.Node(<ELEMENT_NODE@0x00007fd9f40828e0>)\n"
},

{
    "location": "manual/#XPath-1",
    "page": "Manual",
    "title": "XPath",
    "category": "section",
    "text": "XPath is a query language for XML. You can retrieve target elements using a short query string. For example, \"//genus/species\" selects all \"species\" elements just under a \"genus\" element.The findall, findfirst and findlast functions are overloaded for XPath query and return a vector of selected nodes:julia> primates = readxml(\"primates.xml\")\nEzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fbeddc2a1d0>))\n\njulia> findall(\"/primates\", primates)  # Find the \"primates\" element just under the document\n1-element Array{EzXML.Node,1}:\n EzXML.Node(<ELEMENT_NODE@0x00007fbeddc1e190>)\n\njulia> findall(\"//genus\", primates)\n2-element Array{EzXML.Node,1}:\n EzXML.Node(<ELEMENT_NODE@0x00007fbeddc12c50>)\n EzXML.Node(<ELEMENT_NODE@0x00007fbeddc16ea0>)\n\njulia> findfirst(\"//genus\", primates)\nEzXML.Node(<ELEMENT_NODE@0x00007fbeddc12c50>)\n\njulia> findlast(\"//genus\", primates)\nEzXML.Node(<ELEMENT_NODE@0x00007fbeddc16ea0>)\n\njulia> println(findfirst(\"//genus\", primates))\n<genus name=\"Homo\">\n        <species name=\"sapiens\">Human</species>\n    </genus>\nIf you would like to change the starting node of a query, you can pass the node as the second argument of find*:julia> genus = findfirst(\"//genus\", primates)\nEzXML.Node(<ELEMENT_NODE@0x00007fbeddc12c50>)\n\njulia> println(genus)\n<genus name=\"Homo\">\n        <species name=\"sapiens\">Human</species>\n    </genus>\n\njulia> println(findfirst(\"species\", genus))\n<species name=\"sapiens\">Human</species>\nfind*(<xpath>, <node>) automatically registers namespaces applied to <node>, which means prefixes are available in the XPath query. This is especially useful when an XML document is composed of elements originated from different namespaces.There is a caveat on the combination of XPath and namespaces: if a document contains elements with a default namespace, you need to specify its prefix to the find* function. For example, in the following example, the root element and its descendants have a default namespace \"http://www.foobar.org\", but it does not have its own prefix.  In this case, you need to assign a prefix to the namespance when finding elements in the namespace:julia> doc = parsexml(\"\"\"\n       <parent xmlns=\"http://www.foobar.org\">\n           <child/>\n       </parent>\n       \"\"\")\nEzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x00007fdc67710030>))\n\njulia> findall(\"/parent/child\", doc.root)  # nothing will be found\n0-element Array{EzXML.Node,1}\n\njulia> namespaces(doc.root)  # the default namespace has an empty prefix\n1-element Array{Pair{String,String},1}:\n \"\" => \"http://www.foobar.org\"\n\njulia> ns = namespace(doc.root)  # get the namespace\n\"http://www.foobar.org\"\n\njulia> findall(\"/x:parent/x:child\", doc.root, [\"x\"=>ns])  # specify its prefix as \"x\"\n1-element Array{EzXML.Node,1}:\n EzXML.Node(<ELEMENT_NODE@0x00007fdc6774c990>)\n"
},

{
    "location": "manual/#Streaming-API-1",
    "page": "Manual",
    "title": "Streaming API",
    "category": "section",
    "text": "In addition to the DOM API, EzXML.jl provides a streaming reader of XML files. The streaming reader processes, as the name suggests, a stream of XML data by incrementally reading data from a file instead of reading a whole XML tree into the memory. This enables processing extremely large files with limited memory.Let\'s use the following XML file (undirected.graphml) that represents an undirected graph in the GraphML format (slightly simplified for brevity):<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<graphml>\n    <graph edgedefault=\"undirected\">\n        <node id=\"n0\"/>\n        <node id=\"n1\"/>\n        <node id=\"n2\"/>\n        <node id=\"n3\"/>\n        <node id=\"n4\"/>\n        <edge source=\"n0\" target=\"n2\"/>\n        <edge source=\"n1\" target=\"n2\"/>\n        <edge source=\"n2\" target=\"n3\"/>\n        <edge source=\"n3\" target=\"n4\"/>\n    </graph>\n</graphml>The API of a streaming reader is quite different from the DOM API.  The first thing you needs to do is to create an EzXML.StreamReader object using the open function:julia> reader = open(EzXML.StreamReader, \"undirected.graphml\")\nEzXML.StreamReader(<READER_NONE@0x00007f9fe8d67340>)\nThe stream reader is stateful and parses components by pulling them from the stream. For example, when it reads an element from the stream, it changes the state to READER_ELEMENT and some information becomes accessible.  Its reading state is advanced by the iterate(reader) method:julia> reader.type  # the initial state is READER_NONE\nREADER_NONE\n\njulia> iterate(reader);  # advance the reader\'s state\n\njulia> reader.type  # now the state is READER_ELEMENT\nREADER_ELEMENT\n\njulia> reader.name  # the reader has just read a \"<graphml>\" element\n\"graphml\"\n\njulia> iterate(reader);\n\njulia> reader.type  # now the state is READER_SIGNIFICANT_WHITESPACE\nREADER_SIGNIFICANT_WHITESPACE\n\njulia> reader.name\n\"#text\"\n\njulia> iterate(reader);\n\njulia> reader.type\nREADER_ELEMENT\n\njulia> reader.name  # the reader has just read a \"<graph>\" element\n\"graph\"\n\njulia> reader[\"edgedefault\"]  # attributes are accessible\n\"undirected\"\nWhile reading data, a stream reader provides the following properties:.type:  node type it has read\n.depth: depth of the current node\n.name: name of the current node\n.content: content of the current node\n.namespace: namespace of the current nodeiterate(reader) returns nothing to indicate that there are no more data available from the file. When you finished reading data, you need to call close(reader) to release allocated resources:julia> reader = open(EzXML.StreamReader, \"undirected.graphml\")\nEzXML.StreamReader(<READER_NONE@0x00007fd642e80d90>)\n\njulia> while (item = iterate(reader)) != nothing\n           @show reader.type, reader.name\n       end\n(reader.type, reader.name) = (READER_ELEMENT, \"graphml\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_ELEMENT, \"graph\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_ELEMENT, \"node\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_ELEMENT, \"node\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_ELEMENT, \"node\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_ELEMENT, \"node\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_ELEMENT, \"node\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_ELEMENT, \"edge\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_ELEMENT, \"edge\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_ELEMENT, \"edge\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_ELEMENT, \"edge\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_END_ELEMENT, \"graph\")\n(reader.type, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(reader.type, reader.name) = (READER_END_ELEMENT, \"graphml\")\n\njulia> reader.type, reader.name\n(READER_NONE, nothing)\n\njulia> close(reader)  # close the reader\nThe open(...) do ... end pattern can be written as:julia> open(EzXML.StreamReader, \"undirected.graphml\") do reader\n           # do something\n       end\nEzXML.jl overloads the Base.iterate function to make a streaming reader iterable via the for loop. Therefore, you can iterate over all components without explicitly calling iterate as follows:julia> reader = open(EzXML.StreamReader, \"undirected.graphml\")\nEzXML.StreamReader(<READER_NONE@0x00007fd642e9a6b0>)\n\njulia> for typ in reader\n           @show typ, reader.name\n       end\n(typ, reader.name) = (READER_ELEMENT, \"graphml\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_ELEMENT, \"graph\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_ELEMENT, \"node\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_ELEMENT, \"node\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_ELEMENT, \"node\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_ELEMENT, \"node\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_ELEMENT, \"node\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_ELEMENT, \"edge\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_ELEMENT, \"edge\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_ELEMENT, \"edge\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_ELEMENT, \"edge\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_END_ELEMENT, \"graph\")\n(typ, reader.name) = (READER_SIGNIFICANT_WHITESPACE, \"#text\")\n(typ, reader.name) = (READER_END_ELEMENT, \"graphml\")\n\njulia> close(reader)\n(NOTE: This paragraph is for the backward compatibility of Julia 0.6. If you don\'t need to support Julia 0.6, you should use the iterate method instead.) Iteration is advanced by the done(<reader>) method, which updates the current reading position of the reader and returns false when there is at least one node to read from the stream:julia> reader = open(EzXML.StreamReader, \"undirected.graphml\")\nEzXML.StreamReader(<READER_NONE@0x00007f9fe8d67340>)\n\njulia> done(reader)  # Read the 1st node.\nfalse\n\njulia> nodetype(reader)\nREADER_ELEMENT\n\njulia> nodename(reader)\n\"graphml\"\n\njulia> done(reader)  # Read the 2nd node.\nfalse\n\njulia> nodetype(reader)\nREADER_SIGNIFICANT_WHITESPACE\n\njulia> nodename(reader)\n\"#text\"\n\njulia> done(reader)  # Read the 3rd node.\nfalse\n\njulia> nodetype(reader)\nREADER_ELEMENT\n\njulia> nodename(reader)\n\"graph\"\n\njulia> reader[\"edgedefault\"]\n\"undirected\"\n"
},

{
    "location": "reference/#",
    "page": "Reference",
    "title": "Reference",
    "category": "page",
    "text": ""
},

{
    "location": "reference/#Reference-1",
    "page": "Reference",
    "title": "Reference",
    "category": "section",
    "text": "CurrentModule = EzXML"
},

{
    "location": "reference/#EzXML.Document",
    "page": "Reference",
    "title": "EzXML.Document",
    "category": "type",
    "text": "An XML/HTML document type.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.Node",
    "page": "Reference",
    "title": "EzXML.Node",
    "category": "type",
    "text": "A proxy type to libxml2\'s node struct.\n\nProperties (Julia ≥ 0.7)\n\nName Type Description\ntype EzXML.NodeType the type of a node\nname String? the name of a node\npath String the absolute path to a node\ncontent String the content of a node\nnamespace String? the namespace associated with a node\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.StreamReader",
    "page": "Reference",
    "title": "EzXML.StreamReader",
    "category": "type",
    "text": "A streaming XML reader type.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.XMLError",
    "page": "Reference",
    "title": "EzXML.XMLError",
    "category": "type",
    "text": "An error detected by libxml2.\n\n\n\n\n\n"
},

{
    "location": "reference/#Types-1",
    "page": "Reference",
    "title": "Types",
    "category": "section",
    "text": "EzXML.Document\nEzXML.Node\nEzXML.StreamReader\nEzXML.XMLError"
},

{
    "location": "reference/#EzXML.parsexml",
    "page": "Reference",
    "title": "EzXML.parsexml",
    "category": "function",
    "text": "parsexml(xmlstring)\n\nParse xmlstring and create an XML document.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.parsehtml",
    "page": "Reference",
    "title": "EzXML.parsehtml",
    "category": "function",
    "text": "parsehtml(htmlstring)\n\nParse htmlstring and create an HTML document.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.readxml",
    "page": "Reference",
    "title": "EzXML.readxml",
    "category": "function",
    "text": "readxml(filename)\n\nRead filename and create an XML document.\n\n\n\n\n\nreadxml(input::IO)\n\nRead input and create an XML document.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.readhtml",
    "page": "Reference",
    "title": "EzXML.readhtml",
    "category": "function",
    "text": "readhtml(filename)\n\nRead filename and create an HTML document.\n\n\n\n\n\nreadhtml(input::IO)\n\nRead input and create an HTML document.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.prettyprint",
    "page": "Reference",
    "title": "EzXML.prettyprint",
    "category": "function",
    "text": "prettyprint([io], node::Node)\n\nPrint node with formatting.\n\n\n\n\n\nprettyprint([io], doc::Document)\n\nPrint doc with formatting.\n\n\n\n\n\n"
},

{
    "location": "reference/#I/O-1",
    "page": "Reference",
    "title": "I/O",
    "category": "section",
    "text": "parsexml\nparsehtml\nreadxml\nreadhtml\nprettyprint"
},

{
    "location": "reference/#EzXML.XMLDocument",
    "page": "Reference",
    "title": "EzXML.XMLDocument",
    "category": "function",
    "text": "XMLDocument(version=\"1.0\")\n\nCreate an XML document.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.HTMLDocument",
    "page": "Reference",
    "title": "EzXML.HTMLDocument",
    "category": "function",
    "text": "HTMLDocument(uri=nothing, externalID=nothing)\n\nCreate an HTML document.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.XMLDocumentNode",
    "page": "Reference",
    "title": "EzXML.XMLDocumentNode",
    "category": "function",
    "text": "XMLDocumentNode(version)\n\nCreate an XML document node with version.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.HTMLDocumentNode",
    "page": "Reference",
    "title": "EzXML.HTMLDocumentNode",
    "category": "function",
    "text": "HTMLDocumentNode(uri, externalID)\n\nCreate an HTML document node.\n\nuri and externalID are either a string or nothing.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.ElementNode",
    "page": "Reference",
    "title": "EzXML.ElementNode",
    "category": "function",
    "text": "ElementNode(name)\n\nCreate an element node with name.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.TextNode",
    "page": "Reference",
    "title": "EzXML.TextNode",
    "category": "function",
    "text": "TextNode(content)\n\nCreate a text node with content.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.CommentNode",
    "page": "Reference",
    "title": "EzXML.CommentNode",
    "category": "function",
    "text": "CommentNode(content)\n\nCreate a comment node with content.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.CDataNode",
    "page": "Reference",
    "title": "EzXML.CDataNode",
    "category": "function",
    "text": "CDataNode(content)\n\nCreate a CDATA node with content.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.AttributeNode",
    "page": "Reference",
    "title": "EzXML.AttributeNode",
    "category": "function",
    "text": "AttributeNode(name, value)\n\nCreate an attribute node with name and value.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.DTDNode",
    "page": "Reference",
    "title": "EzXML.DTDNode",
    "category": "function",
    "text": "DTDNode(name, [systemID, [externalID]])\n\nCreate a DTD node with name, systemID, and externalID.\n\n\n\n\n\n"
},

{
    "location": "reference/#Constructors-1",
    "page": "Reference",
    "title": "Constructors",
    "category": "section",
    "text": "XMLDocument\nHTMLDocument\nXMLDocumentNode\nHTMLDocumentNode\nElementNode\nTextNode\nCommentNode\nCDataNode\nAttributeNode\nDTDNode"
},

{
    "location": "reference/#Node-types-1",
    "page": "Reference",
    "title": "Node types",
    "category": "section",
    "text": "Node type Integer\nEzXML.ELEMENT_NODE 1\nEzXML.ATTRIBUTE_NODE 2\nEzXML.TEXT_NODE 3\nEzXML.CDATA_SECTION_NODE 4\nEzXML.ENTITY_REF_NODE 5\nEzXML.ENTITY_NODE 6\nEzXML.PI_NODE 7\nEzXML.COMMENT_NODE 8\nEzXML.DOCUMENT_NODE 9\nEzXML.DOCUMENT_TYPE_NODE 10\nEzXML.DOCUMENT_FRAG_NODE 11\nEzXML.NOTATION_NODE 12\nEzXML.HTML_DOCUMENT_NODE 13\nEzXML.DTD_NODE 14\nEzXML.ELEMENT_DECL 15\nEzXML.ATTRIBUTE_DECL 16\nEzXML.ENTITY_DECL 17\nEzXML.NAMESPACE_DECL 18\nEzXML.XINCLUDE_START 19\nEzXML.XINCLUDE_END 20\nEzXML.DOCB_DOCUMENT_NODE 21"
},

{
    "location": "reference/#EzXML.nodetype-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.nodetype",
    "category": "method",
    "text": "nodetype(node::Node)\n\nReturn the type of node as an integer.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.nodepath-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.nodepath",
    "category": "method",
    "text": "nodepath(node::Node)\n\nReturn the path of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.nodename-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.nodename",
    "category": "method",
    "text": "nodename(node::Node)\n\nReturn the node name of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.nodecontent-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.nodecontent",
    "category": "method",
    "text": "nodecontent(node::Node)\n\nReturn the node content of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.namespace-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.namespace",
    "category": "method",
    "text": "namespace(node::Node)\n\nReturn the namespace associated with node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.namespaces-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.namespaces",
    "category": "method",
    "text": "namespaces(node::Node)\n\nCreate a vector of namespaces applying to node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasnodename-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.hasnodename",
    "category": "method",
    "text": "hasnodename(node::Node)\n\nReturn if node has a node name.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasnamespace-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.hasnamespace",
    "category": "method",
    "text": "hasnamespace(node::Node)\n\nReturn if node is associated with a namespace.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.iselement-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.iselement",
    "category": "method",
    "text": "iselement(node::Node)\n\nReturn if node is an element node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.isattribute-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.isattribute",
    "category": "method",
    "text": "isattribute(node::Node)\n\nReturn if node is an attribute node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.istext-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.istext",
    "category": "method",
    "text": "istext(node::Node)\n\nReturn if node is a text node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.iscdata-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.iscdata",
    "category": "method",
    "text": "iscdata(node::Node)\n\nReturn if node is a CDATA node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.iscomment-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.iscomment",
    "category": "method",
    "text": "iscomment(node::Node)\n\nReturn if node is a comment node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.isdtd-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.isdtd",
    "category": "method",
    "text": "isdtd(node::Node)\n\nReturn if node is a DTD node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.countnodes-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.countnodes",
    "category": "method",
    "text": "countnodes(parent::Node)\n\nCount the number of child nodes of parent.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.countelements-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.countelements",
    "category": "method",
    "text": "countelements(parent::Node)\n\nCount the number of child elements of parent.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.countattributes-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.countattributes",
    "category": "method",
    "text": "countattributes(elem::Node)\n\nCount the number of attributes of elem.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.systemID-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.systemID",
    "category": "method",
    "text": "systemID(node::Node)\n\nReturn the system ID of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.externalID-Tuple{EzXML.Node}",
    "page": "Reference",
    "title": "EzXML.externalID",
    "category": "method",
    "text": "externalID(node::Node)\n\nReturn the external ID of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#Node-accessors-1",
    "page": "Reference",
    "title": "Node accessors",
    "category": "section",
    "text": "nodetype(::Node)\nnodepath(::Node)\nnodename(::Node)\nnodecontent(::Node)\nnamespace(::Node)\nnamespaces(::Node)\nhasnodename(::Node)\nhasnamespace(::Node)\niselement(::Node)\nisattribute(::Node)\nistext(::Node)\niscdata(::Node)\niscomment(::Node)\nisdtd(::Node)\ncountnodes(::Node)\ncountelements(::Node)\ncountattributes(::Node)\nsystemID(::Node)\nexternalID(::Node)"
},

{
    "location": "reference/#EzXML.setnodename!-Tuple{EzXML.Node,AbstractString}",
    "page": "Reference",
    "title": "EzXML.setnodename!",
    "category": "method",
    "text": "setnodename!(node::Node, name::AbstractString)\n\nSet the name of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.setnodecontent!-Tuple{EzXML.Node,AbstractString}",
    "page": "Reference",
    "title": "EzXML.setnodecontent!",
    "category": "method",
    "text": "setnodecontent!(node::Node, content::AbstractString)\n\nReplace the content of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#Node-modifiers-1",
    "page": "Reference",
    "title": "Node modifiers",
    "category": "section",
    "text": "setnodename!(::Node, ::AbstractString)\nsetnodecontent!(::Node, ::AbstractString)"
},

{
    "location": "reference/#EzXML.version",
    "page": "Reference",
    "title": "EzXML.version",
    "category": "function",
    "text": "version(doc::Document)\n\nReturn the version string of doc.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.encoding",
    "page": "Reference",
    "title": "EzXML.encoding",
    "category": "function",
    "text": "encoding(doc::Document)\n\nReturn the encoding string of doc.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasversion",
    "page": "Reference",
    "title": "EzXML.hasversion",
    "category": "function",
    "text": "hasversion(doc::Document)\n\nReturn if doc has a version string.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasencoding",
    "page": "Reference",
    "title": "EzXML.hasencoding",
    "category": "function",
    "text": "hasencoding(doc::Document)\n\nReturn if doc has an encoding string.\n\n\n\n\n\n"
},

{
    "location": "reference/#Document-properties-1",
    "page": "Reference",
    "title": "Document properties",
    "category": "section",
    "text": "version\nencoding\nhasversion\nhasencoding"
},

{
    "location": "reference/#EzXML.document",
    "page": "Reference",
    "title": "EzXML.document",
    "category": "function",
    "text": "document(node::Node)\n\nReturn the document of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.root",
    "page": "Reference",
    "title": "EzXML.root",
    "category": "function",
    "text": "root(doc::Document)\n\nReturn the root element of doc.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.dtd",
    "page": "Reference",
    "title": "EzXML.dtd",
    "category": "function",
    "text": "dtd(doc::Document)\n\nReturn the DTD node of doc.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.parentnode",
    "page": "Reference",
    "title": "EzXML.parentnode",
    "category": "function",
    "text": "parentnode(node::Node)\n\nReturn the parent of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.parentelement",
    "page": "Reference",
    "title": "EzXML.parentelement",
    "category": "function",
    "text": "parentelement(node::Node)\n\nReturn the parent element of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.firstnode",
    "page": "Reference",
    "title": "EzXML.firstnode",
    "category": "function",
    "text": "firstnode(node::Node)\n\nReturn the first child node of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.lastnode",
    "page": "Reference",
    "title": "EzXML.lastnode",
    "category": "function",
    "text": "lastnode(node::Node)\n\nReturn the last child node of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.firstelement",
    "page": "Reference",
    "title": "EzXML.firstelement",
    "category": "function",
    "text": "firstelement(node::Node)\n\nReturn the first child element of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.lastelement",
    "page": "Reference",
    "title": "EzXML.lastelement",
    "category": "function",
    "text": "lastelement(node::Node)\n\nReturn the last child element of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.nextnode",
    "page": "Reference",
    "title": "EzXML.nextnode",
    "category": "function",
    "text": "nextnode(node::Node)\n\nReturn the next node of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.prevnode",
    "page": "Reference",
    "title": "EzXML.prevnode",
    "category": "function",
    "text": "prevnode(node::Node)\n\nReturn the previous node of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.nextelement",
    "page": "Reference",
    "title": "EzXML.nextelement",
    "category": "function",
    "text": "nextelement(node::Node)\n\nReturn the next element of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.prevelement",
    "page": "Reference",
    "title": "EzXML.prevelement",
    "category": "function",
    "text": "prevelement(node::Node)\n\nReturn the previous element of node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.eachnode",
    "page": "Reference",
    "title": "EzXML.eachnode",
    "category": "function",
    "text": "eachnode(node::Node, [backward=false])\n\nCreate an iterator of child nodes.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.nodes",
    "page": "Reference",
    "title": "EzXML.nodes",
    "category": "function",
    "text": "nodes(node::Node, [backward=false])\n\nCreate a vector of child nodes.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.eachelement",
    "page": "Reference",
    "title": "EzXML.eachelement",
    "category": "function",
    "text": "eachelement(node::Node, [backward=false])\n\nCreate an iterator of child elements.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.elements",
    "page": "Reference",
    "title": "EzXML.elements",
    "category": "function",
    "text": "elements(node::Node, [backward=false])\n\nCreate a vector of child elements.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.eachattribute",
    "page": "Reference",
    "title": "EzXML.eachattribute",
    "category": "function",
    "text": "eachattribute(node::Node)\n\nCreate an iterator of attributes.\n\n\n\n\n\neachattribute(reader::StreamReader)\n\nReturn an AttributeReader object for the current node of reader\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.attributes",
    "page": "Reference",
    "title": "EzXML.attributes",
    "category": "function",
    "text": "attributes(node::Node)\n\nCreate a vector of attributes.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasroot",
    "page": "Reference",
    "title": "EzXML.hasroot",
    "category": "function",
    "text": "hasroot(doc::Document)\n\nReturn if doc has a root element.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasdtd",
    "page": "Reference",
    "title": "EzXML.hasdtd",
    "category": "function",
    "text": "hasdtd(doc::Document)\n\nReturn if doc has a DTD node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasnode",
    "page": "Reference",
    "title": "EzXML.hasnode",
    "category": "function",
    "text": "hasnode(node::Node)\n\nReturn if node has a child node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasnextnode",
    "page": "Reference",
    "title": "EzXML.hasnextnode",
    "category": "function",
    "text": "hasnextnode(node::Node)\n\nReturn if node has a next node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasprevnode",
    "page": "Reference",
    "title": "EzXML.hasprevnode",
    "category": "function",
    "text": "hasprevnode(node::Node)\n\nReturn if node has a previous node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.haselement",
    "page": "Reference",
    "title": "EzXML.haselement",
    "category": "function",
    "text": "haselement(node::Node)\n\nReturn if node has a child element.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasnextelement",
    "page": "Reference",
    "title": "EzXML.hasnextelement",
    "category": "function",
    "text": "hasnextelement(node::Node)\n\nReturn if node has a next node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasprevelement",
    "page": "Reference",
    "title": "EzXML.hasprevelement",
    "category": "function",
    "text": "hasprevelement(node::Node)\n\nReturn if node has a previous node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasdocument",
    "page": "Reference",
    "title": "EzXML.hasdocument",
    "category": "function",
    "text": "hasdocument(node::Node)\n\nReturn if node belongs to a document.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasparentnode",
    "page": "Reference",
    "title": "EzXML.hasparentnode",
    "category": "function",
    "text": "hasparentnode(node::Node)\n\nReturn if node has a parent node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasparentelement",
    "page": "Reference",
    "title": "EzXML.hasparentelement",
    "category": "function",
    "text": "hasparentelement(node::Node)\n\nReturn if node has a parent node.\n\n\n\n\n\n"
},

{
    "location": "reference/#DOM-tree-accessors-1",
    "page": "Reference",
    "title": "DOM tree accessors",
    "category": "section",
    "text": "document\nroot\ndtd\nparentnode\nparentelement\nfirstnode\nlastnode\nfirstelement\nlastelement\nnextnode\nprevnode\nnextelement\nprevelement\neachnode\nnodes\neachelement\nelements\neachattribute\nattributes\nhasroot\nhasdtd\nhasnode\nhasnextnode\nhasprevnode\nhaselement\nhasnextelement\nhasprevelement\nhasdocument\nhasparentnode\nhasparentelement"
},

{
    "location": "reference/#EzXML.setroot!",
    "page": "Reference",
    "title": "EzXML.setroot!",
    "category": "function",
    "text": "setroot!(doc::Document, node::Node)\n\nSet the root element of doc to node and return the root element.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.setdtd!",
    "page": "Reference",
    "title": "EzXML.setdtd!",
    "category": "function",
    "text": "setdtd!(doc::Document, node::Node)\n\nSet the DTD node of doc to node and return the DTD node.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.link!",
    "page": "Reference",
    "title": "EzXML.link!",
    "category": "function",
    "text": "link!(parent::Node, child::Node)\n\nLink child at the end of children of parent.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.linknext!",
    "page": "Reference",
    "title": "EzXML.linknext!",
    "category": "function",
    "text": "linknext!(target::Node, node::Node)\n\nLink node as the next sibling of target.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.linkprev!",
    "page": "Reference",
    "title": "EzXML.linkprev!",
    "category": "function",
    "text": "linkprev!(target::Node, node::Node)\n\nLink node as the prev sibling of target.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.unlink!",
    "page": "Reference",
    "title": "EzXML.unlink!",
    "category": "function",
    "text": "unlink!(node::Node)\n\nUnlink node from its context.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.addelement!",
    "page": "Reference",
    "title": "EzXML.addelement!",
    "category": "function",
    "text": "addelement!(parent::Node, name::AbstractString)\n\nAdd a new child element of name with no content to parent and return the new child element.\n\n\n\n\n\naddelement!(parent::Node, name::AbstractString, content::AbstractString)\n\nAdd a new child element of name with content to parent and return the new child element.\n\n\n\n\n\n"
},

{
    "location": "reference/#DOM-tree-modifiers-1",
    "page": "Reference",
    "title": "DOM tree modifiers",
    "category": "section",
    "text": "setroot!\nsetdtd!\nlink!\nlinknext!\nlinkprev!\nunlink!\naddelement!"
},

{
    "location": "reference/#Base.findall-Tuple{AbstractString,EzXML.Document}",
    "page": "Reference",
    "title": "Base.findall",
    "category": "method",
    "text": "findall(xpath::AbstractString, doc::Document)\n\nFind nodes matching xpath XPath query from doc.\n\n\n\n\n\n"
},

{
    "location": "reference/#Base.findfirst-Tuple{AbstractString,EzXML.Document}",
    "page": "Reference",
    "title": "Base.findfirst",
    "category": "method",
    "text": "findfirst(xpath::AbstractString, doc::Document)\n\nFind the first node matching xpath XPath query from doc.\n\n\n\n\n\n"
},

{
    "location": "reference/#Base.findlast-Tuple{AbstractString,EzXML.Document}",
    "page": "Reference",
    "title": "Base.findlast",
    "category": "method",
    "text": "findlast(doc::Document, xpath::AbstractString)\n\nFind the last node matching xpath XPath query from doc.\n\n\n\n\n\n"
},

{
    "location": "reference/#Base.findall-Tuple{AbstractString,EzXML.Node}",
    "page": "Reference",
    "title": "Base.findall",
    "category": "method",
    "text": "findall(xpath::AbstractString, node::Node, [ns=namespaces(node)])\n\nFind nodes matching xpath XPath query starting from node.\n\nThe ns argument is an iterator of namespace prefix and URI pairs.\n\n\n\n\n\n"
},

{
    "location": "reference/#Base.findfirst-Tuple{AbstractString,EzXML.Node}",
    "page": "Reference",
    "title": "Base.findfirst",
    "category": "method",
    "text": "findfirst(xpath::AbstractString, node::Node, [ns=namespaces(node)])\n\nFind the first node matching xpath XPath query starting from node.\n\n\n\n\n\n"
},

{
    "location": "reference/#Base.findlast-Tuple{AbstractString,EzXML.Node}",
    "page": "Reference",
    "title": "Base.findlast",
    "category": "method",
    "text": "findlast(node::Node, xpath::AbstractString, [ns=namespaces(node)])\n\nFind the last node matching xpath XPath query starting from node.\n\n\n\n\n\n"
},

{
    "location": "reference/#XPath-query-1",
    "page": "Reference",
    "title": "XPath query",
    "category": "section",
    "text": "findall(xpath::AbstractString, doc::Document)\nfindfirst(xpath::AbstractString, doc::Document)\nfindlast(xpath::AbstractString, doc::Document)\nfindall(xpath::AbstractString, node::Node)\nfindfirst(xpath::AbstractString, node::Node)\nfindlast(xpath::AbstractString, node::Node)"
},

{
    "location": "reference/#EzXML.validate",
    "page": "Reference",
    "title": "EzXML.validate",
    "category": "function",
    "text": "validate(doc::Document, [dtd::Node])\n\nValidate doc against dtd and return the validation log.\n\nThe validation log is empty if and only if doc is valid. The DTD node in doc will be used if dtd is not passed.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.readdtd",
    "page": "Reference",
    "title": "EzXML.readdtd",
    "category": "function",
    "text": "readdtd(filename::AbstractString)\n\nRead filename and create a DTD node.\n\n\n\n\n\n"
},

{
    "location": "reference/#Validation-1",
    "page": "Reference",
    "title": "Validation",
    "category": "section",
    "text": "validate\nreaddtd"
},

{
    "location": "reference/#Reader-node-types-1",
    "page": "Reference",
    "title": "Reader node types",
    "category": "section",
    "text": "Node type Integer\nEzXML.READER_NONE 0\nEzXML.READER_ELEMENT 1\nEzXML.READER_ATTRIBUTE 2\nEzXML.READER_TEXT 3\nEzXML.READER_CDATA 4\nEzXML.READER_ENTITY_REFERENCE 5\nEzXML.READER_ENTITY 6\nEzXML.READER_PROCESSING_INSTRUCTION 7\nEzXML.READER_COMMENT 8\nEzXML.READER_DOCUMENT 9\nEzXML.READER_DOCUMENT_TYPE 10\nEzXML.READER_DOCUMENT_FRAGMENT 11\nEzXML.READER_NOTATION 12\nEzXML.READER_WHITESPACE 13\nEzXML.READER_SIGNIFICANT_WHITESPACE 14\nEzXML.READER_END_ELEMENT 15\nEzXML.READER_END_ENTITY 16\nEzXML.READER_XML_DECLARATION 17"
},

{
    "location": "reference/#EzXML.expandtree-Tuple{EzXML.StreamReader}",
    "page": "Reference",
    "title": "EzXML.expandtree",
    "category": "method",
    "text": "expandtree(reader::StreamReader)\n\nExpand the current node of reader into a full subtree that will be available until the next read of node.\n\nNote that the expanded subtree is a read-only and temporary object. You cannot modify it or keep references to any nodes of it after reading the next node.\n\nCurrently, namespace functions and XPath query will not work on the expanded subtree.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.nodetype-Tuple{EzXML.StreamReader}",
    "page": "Reference",
    "title": "EzXML.nodetype",
    "category": "method",
    "text": "nodetype(reader::StreamReader)\n\nReturn the type of the current node of reader.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.nodename-Tuple{EzXML.StreamReader}",
    "page": "Reference",
    "title": "EzXML.nodename",
    "category": "method",
    "text": "nodename(reader::StreamReader)\n\nReturn the name of the current node of reader.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.nodecontent-Tuple{EzXML.StreamReader}",
    "page": "Reference",
    "title": "EzXML.nodecontent",
    "category": "method",
    "text": "nodecontent(reader::StreamReader)\n\nReturn the content of the current node of reader.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.nodedepth-Tuple{EzXML.StreamReader}",
    "page": "Reference",
    "title": "EzXML.nodedepth",
    "category": "method",
    "text": "nodedepth(reader::StreamReader)\n\nReturn the depth of the current node of reader.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.namespace-Tuple{EzXML.StreamReader}",
    "page": "Reference",
    "title": "EzXML.namespace",
    "category": "method",
    "text": "namespace(reader::StreamReader)\n\nReturn the namespace of the current node of reader.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasnodecontent-Tuple{EzXML.StreamReader}",
    "page": "Reference",
    "title": "EzXML.hasnodecontent",
    "category": "method",
    "text": "hasnodecontent(reader::StreamReader)\n\nReturn if the current node of reader has content.\n\n\n\n\n\n"
},

{
    "location": "reference/#EzXML.hasnodename-Tuple{EzXML.StreamReader}",
    "page": "Reference",
    "title": "EzXML.hasnodename",
    "category": "method",
    "text": "hasnodename(reader::StreamReader)\n\nReturn if the current node of reader has a node name.\n\n\n\n\n\n"
},

{
    "location": "reference/#Streaming-reader-1",
    "page": "Reference",
    "title": "Streaming reader",
    "category": "section",
    "text": "expandtree(::StreamReader)\nnodetype(::StreamReader)\nnodename(::StreamReader)\nnodecontent(::StreamReader)\nnodedepth(::StreamReader)\nnamespace(::StreamReader)\nhasnodecontent(::StreamReader)\nhasnodename(::StreamReader)"
},

{
    "location": "devnotes/#",
    "page": "Developer Notes",
    "title": "Developer Notes",
    "category": "page",
    "text": ""
},

{
    "location": "devnotes/#Developer-Notes-1",
    "page": "Developer Notes",
    "title": "Developer Notes",
    "category": "section",
    "text": "This package is built on top of libxml2 and the design is significantly influenced by it. The Node type is a proxy object that points to a C struct allocated by libxml2. There are several node-like types in libxml2 that have common fields to constitute an XML tree. These fields are always located at the first fields of struct definitions, so we can safely use them by casting a pointer to _Node. Especially, the first field, _private, is reserved for applications and EzXML.jl uses it to store a pointer to a Node object. That is, a Node object points to a node struct and the node struct keeps an opposite pointer to the Node object. These bidirectional references are especially important in this package.When creating a Node object from a pointer, the constructor first checks whether there is already a proxy object pointing to the same node. If it exists, the constructor extracts the proxy object from the _private field and then return it. Otherwise, it creates a new proxy object and stores a reference to it in _private. As a result, proxy objects pointing to the same node in an XML document are always unique and no duplication happens. This property is fundamental to resource management.A Node object has another field called owner that references another Node object or the object itself. The owner node is responsible for freeing memory resources of the node object allocated by libxml2. Freeing memories is done in the finalize_node function, which is registered using finalizer when creating a proxy node. If a node object does not own itself, there is almost nothing to do in finalize_node except canceling (i.e. assigning the null pointer) the _private field.  If a node object owns itself, it finalized all descendant nodes in finalize_node.  In this process, the owner node cancels all _private fields of its descendants because their finalizer may be called after finished freeing nodes, which may result in a segmentation fault. Another important role of keeping owner reference is that it prohibits owner objects from being deallocated by Julia\'s garbage collecter.Since the owner field is not managed by libxml2, EzXML.jl needs to update the field when changing the structure of an XML tree. For example, linking a tree with another tree will lead to an inconsistent situation where descendants nodes reference different owner nodes. update_owners! updates the owner node of a whole tree so that this situation won\'t happen. Therefore, functions like link! and unlink! update owner objects by calling this function."
},

]}
