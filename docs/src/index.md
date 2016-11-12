Home
====

EzXML.jl is a package for handling XML and HTML documents. The APIs are simple
and support a range of functionalities including:
* Traversing XML/HTML documents with
  [DOM](https://en.wikipedia.org/wiki/Document_Object_Model)-like interfaces.
* Searching elements using [XPath](https://en.wikipedia.org/wiki/XPath).
* Handling [XML namespaces](https://en.wikipedia.org/wiki/XML_namespace).
* Parsing with [streaming APIs](http://xmlsoft.org/xmlreader.html).
* Automatic memory management.

Here is an example of parsing and traversing an XML document:
```julia
using EzXML

# Parse an XML string
# (use `read(Document, <filename>)` to read a document from a file).
doc = parse(Document, """
<primates>
    <genus name="Homo">
        <species name="sapiens">Human</species>
    </genus>
    <genus name="Pan">
        <species name="paniscus">Bonobo</species>
        <species name="troglodytes">Chimpanzee</species>
    </genus>
</primates>
""")

# Get the root element from `doc`.
primates = root(doc)

# Iterate over child elements.
for genus in eachelement(primates)
    # Get an attribute value by name.
    genus_name = genus["name"]
    println("- ", genus_name)
    for species in eachelement(genus)
        # Get the content within an element.
        species_name = content(species)
        println("  └ ", species["name"], " (", species_name, ")")
    end
end
println()

# Find texts using XPath query.
for species_name in content.(find(primates, "//species/text()"))
    println("- ", species_name)
end
```

If you are new to this package, read [the manual page](manual.html) first. It
provides a general guide to the package. [The references page](references.html)
offers a full documentation for each function and [the developer notes
page](devnotes.html) explains about the internal design for developers.
