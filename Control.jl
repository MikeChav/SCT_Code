module PluralityControl

import IterTools
import JSON

@enum ControlType CC DC

@enum WinnerModel UW NUW

@enum TieHandling TP TE

function plurality(C, V::Vector{Vector{Char}}, w::WinnerModel)
    if length(C) == 0
        return Vector{Char}()
    end

    scores = Dict{Char,Int}()

    for c in C
        scores[c] = 0
    end

    for v in V
        scores[v[1]] += 1
    end

    maxscore = maximum(values(scores))
    winners = [c for (c, s) in scores if s == maxscore]

    if (w == UW) && (length(winners) > 1)
        winners = Vector{Char}()
    end

    return winners
end

function maskVotes(C, V)
    return [[c for c in v if c in C] for v in V]
end

function pv(C, V::Vector{Vector{Char}}, ctype::ControlType, t::TieHandling, w::WinnerModel)
    results = Dict{Char,Vector{Vector{Char}}}()

    for i in IterTools.subsets(eachindex(V))
        w1 = plurality(C, V[i], (t == TE) ? UW : NUW)
        w2 = plurality(C, V[setdiff(eachindex(V), i)], (t == TE) ? UW : NUW)
        winners = plurality(∪(w1, w2), maskVotes(∪(w1, w2), V), w)

        if ctype == CC
            for c in winners
                results[c] = V[i]
            end
        elseif ctype == DC
            losers = setdiff(C, winners)

            for l in losers
                results[l] = V[i]
            end
        end
    end

    return results
end

function pc(C, V::Vector{Vector{Char}}, ctype::ControlType, t::TieHandling, w::WinnerModel)
    results = Dict{Char,Vector{Char}}()

    for i in IterTools.subsets(eachindex(C))
        w1 = plurality(C[i], maskVotes(C[i], V), (t == TE) ? UW : NUW)
        survived = ∪(C[setdiff(eachindex(C), i)], w1)
        winners = plurality(survived, maskVotes(survived, V), w)

        if ctype == CC
            for c in winners
                results[c] = C[i]
            end
        elseif ctype == DC
            losers = setdiff(C, winners)

            for l in losers
                results[l] = C[i]
            end
        end
    end

    return results
end

function rpc(C, V::Vector{Vector{Char}}, ctype::ControlType, t::TieHandling, w::WinnerModel)
    results = Dict{Char,Vector{Char}}()

    for i in IterTools.subsets(eachindex(C))
        w1 = plurality(C[i], maskVotes(C[i], V), (t == TE) ? UW : NUW)
        w2 = plurality(C[setdiff(eachindex(C), i)], maskVotes(C[setdiff(eachindex(C), i)], V), (t == TE) ? UW : NUW)
        winners = plurality(∪(w1, w2), maskVotes(∪(w1, w2), V), w)

        if ctype == CC
            for c in winners
                results[c] = C[i]
            end
        elseif ctype == DC
            losers = setdiff(C, winners)

            for l in losers
                results[l] = C[i]
            end
        end
    end

    return results
end

tvote = JSON.parsefile(ARGS[1])
C = [Char('`' + i) for i=1:tvote["C"]]
V = Vector{Vector{Char}}()

for v in tvote["V"]
    push!(V, [i[1] for i in v])
end

for ctstr in ARGS[2:length(ARGS)]
    ctype = nothing
    f = nothing
    t = nothing
    w = nothing
    ctypeparts = split(ctstr, "-")

    if ctypeparts[1] == "CC"
        ctype = CC
    elseif ctypeparts[1] == "DC"
        ctype = DC
    else
        println(stderr, "Unrecognized control type ", ctypeparts[1], ", skipping")
        continue
    end

    if ctypeparts[2] == "PV"
        f = pv
    elseif ctypeparts[2] == "PC"
        f = pc
    elseif ctypeparts[2] == "RPC"
        f = rpc
    else
        println(stderr, "Unrecognized control type ", ctypeparts[2], ", skipping")
        continue
    end

    if ctypeparts[3] == "TP"
        t = TP
    elseif ctypeparts[3] == "TE"
        t = TE
    else
        println(stderr, "Unrecognized tie-handling protocol ", ctypeparts[3], ", skipping")
        continue
    end

    if ctypeparts[4] == "UW"
        w = UW
    elseif ctypeparts[4] == "NUW"
        w = NUW
    else
        println(stderr, "Unrecognized winner model ", ctypeparts[4], ", skipping")
        continue
    end

    println(ctstr, " ", keys(f(C, V, ctype, t, w)))
end

end
