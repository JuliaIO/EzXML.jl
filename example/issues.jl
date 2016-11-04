#!/usr/bin/env julia

# List latest issues of the Julia GitHub repository.

using EzXML
using Requests

res = get("https://github.com/JuliaLang/julia/issues")
doc = parse(Document, String(res.data))
for (i, title) in enumerate(strip.(content.(find(doc, "//li/div/div/a"))))
    println(lpad(i, 2), ": ", title)
end
