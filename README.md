This repository reproduces all the examples in the paper "Separating and 
Collapsing Electoral Control Types" that were computer-generated.

# Requirements
- A C++ compiler (e.g., GCC <http://gcc.gnu.org>)
- Python 3 <https://www.python.org/>
- Make (e.g., GNU Make <https://www.gnu.org/software/make/>)

# Instructions

    $ make all

will reproduce all examples. These are stored as JSON files, each having a field 
"V" that is a list of lists. Each list should be interpreted as a linear order 
of the candidates, i.e., a vote.

Sample files are provided in the examples folder, and each generated example 
should match the "C" and "V" fields of its corresponding sample file. The sample 
files were generated on a single Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz 
running Linux 5.18.9 with 16 GB or RAM.

# Checker

The Python scripts that generate random examples will output a witness (a 
candidate and a partition of voters/candidates) for each control type the 
election is found to belong to. In addition to that, we include a separate 
checker that can read the JSON output of the Python generator plus zero or more 
control types and outputs what candidates can witness membership in each control 
type. The requirements to run this checker are:

- Julia <https://julialang.org/>
  - IterTools package
  - JSON package

An example run would be

    $ julia Control.jl <plurality|veto> <JSON file> CC-RPC-TP-UW CC-PC-TE-NUW


# Verification of Human-Generated Examples

To aid us in the verification of human-generated examples, we wrote a script
that takes as input our examples in JSON format.
For convenience, the directory `jsons_of_examples` already contains each of our examples in JSON format.
To regenerate those JSON files,
make sure that the following two directories are present: 
(1) `texsrc` and (2) `jsons_of_examples`.
Then to generate them, simply run the script `latex_to_json.py` using Python 3.

To check the JSON examples versus the claims in each entry in the tables for 
plurality, veto, and approval, we provide a Julia script. For example, to check 
all the claims in the plurality table you can run

$ julia CheckAll.jl texsrc/tbl-plurality.tex jsons_of_examples/

The script will stop if it ever finds a claim that is not shown by the 
example(s) in the same row.
