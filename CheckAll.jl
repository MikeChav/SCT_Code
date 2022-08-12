include("Control.jl")

import .Control
import JSON

f = open(ARGS[1])
ctypere = r"[CD]C-.*-N?UW"
examplere = r"(Plur|Veto|Appr)\.\d+"

for l in eachline(f)
    parts = split(l, "&")
    results = Dict{String,Any}()
    
    if length(parts) != 4
        continue
    end
    
    m1 = match(ctypere, parts[1])
    m2 = match(ctypere, parts[2])
    
    if isnothing(m1) || isnothing(m2)
        continue
    end
    
    println(m1.match, " ", m2.match)
    
    for i in eachmatch(examplere, parts[4])
        tvote = JSON.parsefile(joinpath(ARGS[2], i.match * ".json"))
        C = [Char('`' + i) for i=1:tvote["C"]]
        V = Vector{Vector{Char}}()
        S = Vector{Char}([Char('`' + length(C) + i) for i=1:tvote["S"]])
        U = Vector{Vector{Char}}()
        k = tvote["k"]
        E = nothing

        for v in tvote["V"]
            push!(V, [i[1] for i in v])
        end

        for v in tvote["U"]
            push!(U, [i[1] for i in v])
        end
            
        if i[1] == "Plur"
            E = Control.plurality
        elseif i[1] == "Veto"
            E = Control.veto
        elseif i[1] == "Appr"
            E = Control.approval
        end
            
        m1res = Control.test_control(m1.match, E, C, S, V, U, k)
        m2res = Control.test_control(m2.match, E, C, S, V, U, k)
        results[i.match] = (m1res, m2res)
    end

    if parts[3] == "\$\\subsetneq\$"
        @assert length(results) == 1
        @assert ⊊(keys(results[first(keys(results))][1]), keys(results[first(keys(results))][2])) first(keys(results))
    elseif parts[3] == "\$\\supsetneq\$"
        @assert length(results) == 1
        @assert ⊋(keys(results[first(keys(results))][1]), keys(results[first(keys(results))][2])) first(keys(results))
    elseif parts[3] == "INCOMP"
        @assert length(results) == 2
        a, b = collect(String, keys(results))
        @assert (!isempty(setdiff(keys(results[a][2]), keys(results[a][1]))) && !isempty(setdiff(keys(results[b][1]), keys(results[b][2])))) || (!isempty(setdiff(keys(results[b][2]), keys(results[b][1]))) && !isempty(setdiff((keys(results[a][1]), keys(results[a][2]))))) a * " " * b
    elseif parts[3] == "INCOMP\${}^*\$"
        @assert length(results) == 1
        @assert !isempty(setdiff(keys(results[first(keys(results))][2]), keys(results[first(keys(results))][1]))) && !isempty(setdiff(keys(results[first(keys(results))][1]), keys(results[first(keys(results))][2]))) first(keys(results))
    elseif parts[3] == "EQ"
        continue
    else
        error(parts[3]) 
    end
end
