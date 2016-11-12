#!/usr/bin/env julia

using LightGraphs
using EzXML

function load_graphml(filename)
    open(XMLReader, filename) do reader
        serial = 0
        nodes = Dict{String,Int}()
        edges = Pair{Int,Int}[]

        # scan nodes
        for typ in reader
            if typ == EzXML.READER_ELEMENT
                elname = name(reader)
                if elname == "node"
                    serial += 1
                    nodes[reader["id"]] = serial
                elseif elname == "edge"
                    source_id = nodes[reader["source"]]
                    target_id = nodes[reader["target"]]
                    push!(edges, source_id => target_id)
                end
            end
        end

        # build an undirected graph
        graph = Graph(serial)
        for edge in edges
            add_edge!(graph, edge)
        end

        # return the graph and the ID-to-name mapping
        return graph, Dict(id => name for (name, id) in nodes)
    end
end

graph, idmap = load_graphml(ARGS[1])
@show graph
@show idmap
