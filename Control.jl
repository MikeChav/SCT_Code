module Control

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


function veto(C, V::Vector{Vector{Char}}, w::WinnerModel)
    if length(C) == 0
        return Vector{Char}()
    end

    scores = Dict{Char,Int}()

    for c in C
        scores[c] = length(V)
    end

    for v in V
        scores[v[length(v)]] -= 1
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

function pv(E, C, V::Vector{Vector{Char}}, ctype::ControlType, t::TieHandling, w::WinnerModel)
    results = Dict{Char,Vector{Vector{Char}}}()

    for i in IterTools.subsets(eachindex(V))
        w1 = E(C, V[i], (t == TE) ? UW : NUW)
        w2 = E(C, V[setdiff(eachindex(V), i)], (t == TE) ? UW : NUW)
        winners = E(∪(w1, w2), maskVotes(∪(w1, w2), V), w)

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

function pc(E, C, V::Vector{Vector{Char}}, ctype::ControlType, t::TieHandling, w::WinnerModel)
    results = Dict{Char,Vector{Char}}()

    for i in IterTools.subsets(eachindex(C))
        w1 = E(C[i], maskVotes(C[i], V), (t == TE) ? UW : NUW)
        survived = ∪(C[setdiff(eachindex(C), i)], w1)
        winners = E(survived, maskVotes(survived, V), w)

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

function rpc(E, C, V::Vector{Vector{Char}}, ctype::ControlType, t::TieHandling, w::WinnerModel)
    results = Dict{Char,Vector{Char}}()

    for i in IterTools.subsets(eachindex(C))
        w1 = E(C[i], maskVotes(C[i], V), (t == TE) ? UW : NUW)
        w2 = E(C[setdiff(eachindex(C), i)], maskVotes(C[setdiff(eachindex(C), i)], V), (t == TE) ? UW : NUW)
        winners = E(∪(w1, w2), maskVotes(∪(w1, w2), V), w)

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

function ac(E, C, S::Vector{Char}, V::Vector{Vector{Char}}, k, ctype::ControlType, w::WinnerModel)
    results = Dict{Char,Vector{Char}}()

    for i=0:k
        for j in IterTools.subsets(eachindex(S), i)
            winners = E(∪(C, S[j]), maskVotes(∪(C, S[j]), V), w)

            if ctype == CC
                for c in ∩(C, winners)
                    results[c] = S[j]
                end
            elseif ctype == DC
                losers = setdiff(C, winners)

                for l in losers
                    results[l] = S[j]
                end
            end
        end
    end

    return results
end

function dc(E, C, V::Vector{Vector{Char}}, k, ctype::ControlType, w::WinnerModel)
    results = Dict{Char,Vector{Char}}()

    for i=length(C):-1:length(C) - k
        for j in IterTools.subsets(eachindex(C), i)
            winners = E(C[j], maskVotes(C[j], V), w)

            if ctype == CC
                for c in winners
                    results[c] = C[setdiff(eachindex(C), j)]
                end
            elseif ctype == DC
                losers = setdiff(C, winners)

                for l in losers
                    if !(l in C[setdiff(eachindex(C), j)])
                        results[l] = C[setdiff(eachindex(C), j)]
                    end
                end
            end
        end
    end

    return results
end

function dv(E, C, V::Vector{Vector{Char}}, k, ctype::ControlType, w::WinnerModel)
    results = Dict{Char,Vector{Vector{Char}}}()

    for i=length(V):-1:length(V) - k
        for j in IterTools.subsets(eachindex(V), i)
            # Note this assumes all votes in V are subsets of C,
            # otherwise we would use maskVotes
            winners = E(C, V[j], w)

            if ctype == CC
                for c in winners
                    results[c] = V[setdiff(eachindex(V), j)]
                end
            elseif ctype == DC
                losers = setdiff(C, winners)

                for l in losers
                    results[l] = V[setdiff(eachindex(V), j)]
                end
            end
        end
    end

    return results
end

function av(E, C, V::Vector{Vector{Char}}, U::Vector{Vector{Char}}, k, ctype::ControlType, w::WinnerModel)
    results = Dict{Char, Vector{Vector{Char}}}()

    for i=0:k
        for j in IterTools.subsets(eachindex(U), i)
            winners = E(C, ∪(V, U[j]), w)

            if ctype == CC
                for c in winners
                    results[c] = U[j]
                end
            elseif ctype == DC
                losers = setdiff(C, winners)

                for l in losers
                    results[l] = U[j]
                end
            end
        end
    end

    return results
end

function uac(E, C, S, V::Vector{Vector{Char}}, ctype::ControlType, w::WinnerModel)
    return ac(E, C, S, V, length(S), ctype, w)
end

function test_control(ctstr, E, C, S, V, U, k)
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
        return
    end

    if ctypeparts[2] == "PV"
        f = pv
    elseif ctypeparts[2] == "PC"
        f = pc
    elseif ctypeparts[2] == "RPC"
        f = rpc
    elseif ctypeparts[2] == "AC"
        f = ac
    elseif ctypeparts[2] == "DC"
        f = dc
    elseif ctypeparts[2] == "DV"
        f = dv
    elseif ctypeparts[2] == "AV"
        f = av
    elseif ctypeparts[2] == "UAC"
        f = uac
    else
        println(stderr, "Unrecognized control type ", ctypeparts[2], ", skipping")
        return
    end

    if length(ctypeparts) == 4
        if ctypeparts[3] == "TP"
            t = TP
        elseif ctypeparts[3] == "TE"
            t = TE
        else
            println(stderr, "Unrecognized tie-handling protocol ", ctypeparts[3], ", skipping")
            return
        end
    end

    if ctypeparts[length(ctypeparts)] == "UW"
        w = UW
    elseif ctypeparts[length(ctypeparts)] == "NUW"
        w = NUW
    else
        println(stderr, "Unrecognized winner model ", ctypeparts[length(ctypeparts)], ", skipping")
        return
    end

    if !isnothing(t)
        # Type 1
        return f(E, C, V, ctype, t, w)
    elseif ctypeparts[2] == "AC"
        # Type 2
        return f(E, C, S, V, k, ctype, w)
    elseif ctypeparts[2] in ("DC", "DV")
        # Type 3
        return f(E, C, V, k, ctype, w)
    elseif ctypeparts[2] == "AV"
        # Type 4
        return f(E, C, V, U, k, ctype, w)
    elseif ctypeparts[2] == "UAC"
        # Type 5
        return f(E, C, S, V, ctype, w)
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    tvote = JSON.parsefile(ARGS[1])
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

    if lowercase(ARGS[2]) == "plurality"
        E = Control.plurality
    elseif lowercase(ARGS[2]) == "veto"
        E = Control.veto
    else
        println(stderr, "This only checks plurality and veto")
        exit(1)
    end

    for ctstr in ARGS[3:length(ARGS)]
        println(ctstr, " ", keys(Control.test_control(ctstr, E, C, S, V, U, k)))
    end
end

end
