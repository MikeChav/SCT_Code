import json


def del_items(s, to_delete):
    for item in to_delete:
        s = s.replace(item, '')
    return s


def parse_num(x):
    if x.isdigit():
        return x
    return 0


def reformat_votes_for_approval(V):
    if len(V) == 0:
        return []
    V = V[1:-1].split(",")
    if len(V) == 0:
        return []
    C = [chr(ord('a') + x) for x in range(len(V[0]))]
    return [[C[i] for i, c in enumerate(v) if c == '1'] for v in V]


def reformat_votes(V, t):
    if t == "approval":
        return reformat_votes_for_approval(V)
    if len(V) == 0:
        return []
    return [new_v.split(">") for new_v in V[1:-1].split(",")]


def parse_from_tex():
    count = 0
    types = ["approval", "plurality", "veto"]
    for t in types:
        print("Working on {}".format(t))
        with open("texsrc/{}texsrc".format(t), 'r') as f:
            for line in f:
                count += 1
                line = del_items(line, ["$", " ", "\n", "\\", "hline", "-", "allowbreak", "{}", "-", "^ddagger", "^dagger", "emptyset"]).split('&')
                C = line[1].split(",")
                S = line[2].split(",") if len(line[2]) > 0 else []
                V = reformat_votes(line[3], t)
                U = reformat_votes(line[4], t)
                k = parse_num(line[5])
                with open("jsons_of_examples/{}.json".format(line[0]), 'w') as g:
                    g.write(json.dumps({
                                "name": line[0],
                                "C": len(C),
                                 "S": len(S),
                                 "V" : V,
                                 "U": U,
                                 "k": int(k)}))


if __name__ == "__main__":
    parse_from_tex()
    print("done!")






