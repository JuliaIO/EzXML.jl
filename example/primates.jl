#!/usr/bin/env julia

using EzXML

# Parse an XML string
# (use `read(Document, <filename>)` to read a document from a file).
doc = parse(EzXML.Document, """
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
for genus in each_element(primates)
    # Get an attribute value by name.
    genus_name = genus["name"]
    println("- ", genus_name)
    for species in each_element(genus)
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
