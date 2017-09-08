#!/usr/bin/env julia

using EzXML

doc = readhtml(ARGS[1])
# Select <a/> links that contain a non-blank text node.
links = find(doc, "//a[@href and normalize-space(text()) != '']")
width = ndigits(length(links))
for (i, link) in enumerate(links)
    println(lpad(i, width), ": ", strip(nodecontent(link)), " -- ", link["href"])
end
