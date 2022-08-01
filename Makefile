all: Plur.30.json Plur.35.json Plur.60.json Plur.62.json Plur.63.json Plur.65.json veto veto.json

veto:
	g++ -o veto main.cpp

veto.json: veto
	./veto > veto.json

Plur.30.json:
	python3 pluralityexamples.py 6 -N 7 -s 1658788009515158060 -i DC-RPC-TE-NUW -i DC-RPC-TP-NUW -i DC-PC-TP-UW -n DC-PV-TP-UW -n DC-PV-TE-UW | tail -1 > Plur.30.json

Plur.35.json:
	python3 pluralityexamples.py 7 -N 9 -s 1658788811309398511 -i DC-PV-TP-NUW -n DC-PV-TE-UW | tail -1 > Plur.35.json

Plur.60.json:
	python3 pluralityexamples.py 4 -N 7 -s 1658788937723933585 -i CC-PC-TE-UW -i CC-PC-TP-UW -n CC-RPC-TP-NUW -n CC-RPC-TE-NUW | tail -1 > Plur.60.json

Plur.62.json:
	python3 pluralityexamples.py 5 -N 11 -s 1658563864499853536 -i CC-PC-TP-UW -n CC-PC-TE-NUW | tail -1 > Plur.62.json

Plur.63.json:
	python3 pluralityexamples.py 4 -N 9 -s 1658788977997662957 -i CC-RPC-TE-UW -i CC-RPC-TP-UW -n CC-PC-TE-NUW -n CC-PC-TP-NUW | tail -1 > Plur.63.json

Plur.65.json:
	python3 pluralityexamples.py 5 -N 9 -s 1658789028345627636 -i CC-PV-TP-UW -n CC-PV-TE-NUW | tail -1 > Plur.65.json

clean:
	rm -f Plur.30.json Plur.35.json Plur.60.json Plur.62.json Plur.63.json Plur.65.json veto veto.json

