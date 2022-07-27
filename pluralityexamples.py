import itertools
import random
import collections
import sys
import time
import datetime
import json
import argparse


class Control:
    def __init__(self, f, ties_promote, unique_winner):
        self.f = f
        self.ties_promote = ties_promote
        self.unique_winner = unique_winner

    def __call__(self, V, C):
        return self.f(V, C, self.ties_promote, self.unique_winner)


def powerset(iterable):
    s = list(iterable)
    return itertools.chain.from_iterable(itertools.combinations(s, r) for r in range(len(s)+1))


def mask(profile, candidates):
    new_profile = []
    for vote in profile:
        new_vote = []
        for v in vote:
            if v in candidates:
                new_vote.append(v)
        if len(new_vote) > 0:
            new_profile.append(new_vote)
    return new_profile


def winners(profile, candidates):
    if len(candidates) == 0:
        return []
    counts = {c: 0 for c in candidates}
    for vote in profile:
        counts[vote[0]] += 1
    potential_winner = max(counts, key=counts.get)
    return [t for t in candidates if counts[t] == counts[potential_winner]]


def subelection(profile, candidates, ties_promote):
    w = winners(mask(profile, candidates), candidates)
    if not ties_promote and len(w) > 1:
        return []
    return w


def finalround(profile, candidates, unique_winner):
    return subelection(profile, candidates, not unique_winner)


def vote_partition_winners(candidates, votes, tie, model):
    '''Computes Plurality_{CC-PV-X-Y}'''
    overall = collections.defaultdict(list)
    for subset1 in powerset(votes):
        w1 = subelection(subset1, candidates, tie)
        w2 = subelection([v for v in votes if v not in subset1], candidates, tie)
        current = finalround(votes, set(w1) | set(w2), model)
        for w in current:
            overall[w].append(subset1)
    return overall


def runoff_candidate_partition_winners(candidates, profile, tie, model):
    '''Computes Plurality_{CC-RPC-X-Y}'''
    overall = collections.defaultdict(list)
    for subset1 in powerset(candidates):
        w1 = subelection(profile, subset1, tie)
        w2 = subelection(profile, [p for p in candidates if p not in subset1], tie)
        current = finalround(profile, set(w1) | set(w2), model)
        for w in current:
            overall[w].append(subset1)
    return overall


def candidate_partition_winners(candidates, profile, tie, model):
    '''Computes Plurality_{CC-PC-X-Y}'''
    overall = collections.defaultdict(list)
    for subset1 in powerset(candidates):
        w1 = subelection(profile, subset1, tie)
        current = finalround(profile, set(w1) | set([p for p in candidates if p not in subset1]), model)
        for w in current:
            overall[w].append(subset1)
    return overall


def runoff_candidate_partition_losers(candidates, votes, tie, uw):
    '''Computes Plurality_{DC-RPC-X-Y}'''
    overall = collections.defaultdict(list)
    for subset1 in powerset(candidates):
        w1 = subelection(votes, subset1, tie)
        w2 = subelection(votes, list(set(candidates) - set(subset1)), tie)
        current = finalround(votes, set(w1) | set(w2), uw)
        for c in candidates:
            if c not in current:
                overall[c].append(subset1)
    return overall


def candidate_partition_losers(candidates, votes, tie, uw):
    '''Computes Plurality_{DC-PC-X-Y}'''
    overall = collections.defaultdict(list)
    for subset1 in powerset(candidates):
        w1 = subelection(votes, subset1, tie)
        current = finalround(votes, set(w1) | (set(candidates) - set(subset1)), uw)
        for c in candidates:
            if c not in current:
                overall[c].append(subset1)
    return overall


def vote_partition_losers(candidates, votes, tie, uw):
    '''Computes Plurality_{DC-PV-X-Y}'''
    overall = collections.defaultdict(list)
    for subset1 in powerset(votes):
        w1 = subelection(subset1, candidates, tie)
        subset2 = [v for v in votes if v not in subset1]
        w2 = subelection(subset2, candidates, tie)
        current = finalround(votes, set(w1) | set(w2), uw)
        for c in candidates:
            if c not in current:
                if subset1 not in overall[c]:
                    overall[c].append(subset1)
    return overall


def pretty_print(votes):
    print(sorted([" > ".join([v for v in vote]) for vote in votes]))


def parse_function(cname):
    parts = cname.split("-")
    TP = False
    UW = False

    if parts[0] == "CC":
        if parts[1] == "PV":
            f = vote_partition_winners
        elif parts[1] == "PC":
            f = candidate_partition_winners
        elif parts[1] == "RPC":
            f = runoff_candidate_partition_winners
        else:
            print("This is not a partition control type, ignoring %s" % cname)
    elif parts[0] == "DC":
        if parts[1] == "PV":
            f = vote_partition_losers
        elif parts[1] == "PC":
            f = candidate_partition_losers
        elif parts[1] == "RPC":
            f = runoff_candidate_partition_losers
        else:
            print("This is not a partition control type, ignoring %s" % cname)

    if parts[2] == "TE":
        TP  = False
    elif parts[2] == "TP":
        TP = True
    else:
        print("Unknown tie-handling model, ignoring %s" % cname)

    if parts[3] == "UW":
        UW = True
    elif parts[3] == "NUW":
        UW = False
    else:
        print("Unknown winner model, ingoring %s" % cname)

    return Control(f, TP, UW)


def search_example(ncandidates, inset, notinset, N, seed):
    random.seed(seed)

    C = [chr(ord('a') + x) for x in range(ncandidates)]
    all_votes = sorted(itertools.permutations(C))
    rounds = 0
    finset = [parse_function(c) for c in inset]
    fnotinset = [parse_function(c) for c in notinset]

    while rounds < 1000:  # usually 1000 is more than enough; increase if needed
        if rounds in [5, 10, 50, 100, 250, 750, 1000, 2500, 5000, 7500, 10000, 100000]:
            print("round=", rounds, file=sys.stderr)
        rounds += 1
        N = round(random.uniform(0.25, .75) * len(all_votes)) if N is None else N
        V = [random.choice(all_votes) for i in range(N)] 
        insetresults = [f(C, V) for f in finset]
        notinsetresults = [f(C, V) for f in fnotinset]
        insetint = set(C)
        notinsetun = set()

        for r in insetresults:
            insetint &= set(r.keys())

        for r in notinsetresults:
            notinsetun |= set(r.keys())

        if insetint > notinsetun:
            witness = sorted(insetint - notinsetun)[0]

            return (V, witness, [r[witness] for r in insetresults])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Find examples of plurality control instances that are in some sets but not in others")
    parser.add_argument("ncandidates", type=int, help="Number of candidates")
    parser.add_argument("--votes", "-N", type=int, help="Number of random votes (picked with replacement)")
    parser.add_argument("--seed", "-s", type=int, help="Random seed")
    parser.add_argument("--inset", "-i", help="Find an example in this control type", action="append", default=[])
    parser.add_argument("--notinset", "-n", help="Find an example not in this control type", action="append", default=[])
    opt = parser.parse_args()
    seed = time.time_ns()

    if opt.seed is not None:
        seed = opt.seed
    else:
        print(seed)

    start = time.process_time()
    res = search_example(opt.ncandidates, opt.inset, opt.notinset, opt.votes, seed)
    elapsed = time.process_time() - start

    if res is not None:
        V, w, witnesses  = res
        print("%s %s" % (w, witnesses))
        print("|V|=", len(V))
        pretty_print(V)
        print(json.dumps({"C": opt.ncandidates, "V": V, "version": "1.0", "date": datetime.datetime.utcnow().ctime(), "elapsedTime": elapsed}))
    else:
        sys.exit(1)

