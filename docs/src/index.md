Home
====

EzXML.jl is a package for handling XML and HTML documents. The APIs are simple
and consistent, and provide a range of functionalities including:
* Traversing XML/HTML documents with DOM-like interfaces.
* Properly handling XML namespaces.
* Searching elements using XPath.
* Parsing large files with streaming APIs.
* Automatic memory management.

Here is an example of parsing and traversing an XML document:
```julia
using EzXML

# Parse an XML string
# (use `readxml(<filename>)` to read a document from a file).
doc = parsexml("""
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
        species_name = nodecontent(species)
        println("  └ ", species["name"], " (", species_name, ")")
    end
end
println()

# Find texts using XPath query.
for species_name in nodecontent.(findall("//species/text()", primates))
    println("- ", species_name)
end
```

If you are new to this package, read [the manual page](manual.md) first. It
provides a general guide to the package. [The reference page](reference.md)
offers a full documentation for each function and [the developer notes
page](devnotes.md) explains about the internal design for developers.
