all: Plur.4.json Plur.25.json Plur.26.json Plur.47.json Plur.48.json Plur.49.json Plur.50.json Veto.16.json Veto.43.json

veto:
	g++ -std=c++17 -o veto -O2 main.cpp

Veto.16.json: veto
	./veto >  Veto.16.json

Plur.4.json:
	python3 examples.py plurality 4 -n CC-RPC-TE-UW -i CC-RPC-TP-UW -s 1660159488460278524 | tail -1 > Plur.4.json

Plur.25.json:
	python3 examples.py plurality 6 -N 7 -s 1658788009515158060 -i DC-RPC-TE-NUW -i DC-RPC-TP-NUW -i DC-PC-TP-UW -n DC-PV-TP-UW -n DC-PV-TE-UW | tail -1 > Plur.25.json

Plur.26.json:
	python3 examples.py plurality 7 -N 9 -s 1658788811309398511 -i DC-PV-TP-NUW -n DC-PV-TE-UW | tail -1 > Plur.26.json

Plur.47.json:
	python3 examples.py plurality 4 -N 7 -s 1658788937723933585 -i CC-PC-TE-UW -i CC-PC-TP-UW -n CC-RPC-TP-NUW -n CC-RPC-TE-NUW | tail -1 > Plur.47.json

Plur.48.json:
	python3 examples.py plurality 5 -N 11 -s 1658563864499853536 -i CC-PC-TP-UW -n CC-PC-TE-NUW | tail -1 > Plur.48.json

Plur.49.json:
	python3 examples.py plurality 4 -N 9 -s 1658788977997662957 -i CC-RPC-TE-UW -i CC-RPC-TP-UW -n CC-PC-TE-NUW -n CC-PC-TP-NUW | tail -1 > Plur.49.json

Plur.50.json:
	python3 examples.py plurality 5 -N 9 -s 1658789028345627636 -i CC-PV-TP-UW -n CC-PV-TE-NUW | tail -1 > Plur.50.json
	
Veto.43.json:
	python3 examples.py veto 4 -N 6 -s 1659636527763808600 -i DC-RPC-TP-UW -n DC-PC-TP-UW | tail -1 > Veto.43.json

clean:
	rm -f Plur.4.json Plur.25.json Plur.26.json Plur.47.json Plur.48.json Plur.49.json Plur.50.json Veto.16.json Veto.43.json veto

