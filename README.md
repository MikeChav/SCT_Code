# Overview

This repository will allow the user to reproduce the generation of all nine 
computer-generated separation examples in the paper "Separating and Collapsing 
Electoral Control Types."


This repository also has verification code that was used to verify
all human-generated and all computer-generated separation examples.

This repository also provides all our separation examples in JSON
format. These are generated using the `latex_to_json.py` script
included in this repository, and the input to that script is the 
LaTeX source (taken from our paper) and included in the directory
`texsrc` in this repository. More details are provided in Section
"Verification of Human-Generated Examples."


**Current Version: 2022-08-14 12:50**

# Computer-Generated Examples

## Requirements
- A C++17 compiler (e.g., GCC <http://gcc.gnu.org>)
- Python 3 <https://www.python.org/>
- Make (e.g., GNU Make <https://www.gnu.org/software/make/>)

## Description

    $ make all

will reproduce the nine examples. These are stored as JSON files, which are 
output into the root directory of the repository.

Each JSON file has a "C" field, which is the number of candidates, and a "V" 
field, which is a list of lists that should be interpreted as a list of linear 
orders of the candidates, i.e., a list of votes.

The `computer_generated_examples` folder contains the examples that we (the authors) generated by running `make all` prior to releasing this repository. 
The output to `make all` does not overwrite these files. Users interested in verifying that the output
to `make all` is what we claim should check that the "C" and "V" fields of each
generated example match the "C" and "V" fields of the corresponding example in `computer_generated_examples`.

Our examples were generated on a single Intel(R) Core(TM) 
i7-9750H CPU @ 2.60GHz running Linux 5.18.9 with 16 GB of RAM.

## Runtimes
Each example in `computer_generated_examples` contains an "elapsedTime" field 
that contains the number of seconds that it took to generate that example.


# Verification of Computer-Generated Examples

## Requirements
- Julia <https://julialang.org/>
  - IterTools package
  - JSON package

## Description

The following checker can be used to verify the computer-generated examples.

Suppose we want to verify that a computer-generated election (C,V), stored in a file called
`election.json`, witnesses that two types T1 and T2 separated under election system E.
(Since our computer-generated examples are about only plurality and veto, E is either plurality or
veto.) Then we can use the script `Control.jl` as follows:

    $ julia Control.jl E election.json T1 T2

The output will show each candidate p such that (C, V, p) is in E-T1 or in E-T2. So if there is a candidate p such 
that (C, V, p) is in E-T1 and not in E-T2, then (C, V) witnesses that E-T1 \not\subseteq E-T2, and if there is a 
candidate p such that (C, V, p) is in E-T2 and not in E-T1, then (C, V) witnesses that E-T2 \not\subseteq E-T1.
Of course, in some cases, both will hold for a given (C, V).

A more concrete example is:

    $ julia Control.jl plurality Plur.49 CC-RPC-TP-UW CC-PC-TE-NUW

## Runtimes

There is no runtime information available for this checker, as we have a 
separate checker that checks the correctness of *all* our examples (see next 
section).

# Verification of Human-Generated Examples

## Requirements
- Julia <https://julialang.org/>
  - IterTools package
  - JSON package

## Description

To aid us in the verification of human-generated examples, we wrote a script 
that reads in our examples, in JSON format.
For convenience, the directory 
`jsons_of_examples` already contains each of our examples in JSON format. To 
regenerate those JSON files, make sure that the following two directories are 
present: 
(1) `texsrc` and (2) `jsons_of_examples`, and then run

    $ python3 latex_to_json.py

The script takes no arguments and simply reads the files `texsrc/approvaltexsrc`, 
`texsrc/pluralitytexsrc`, and `texsrc/vetotexsrc`, which are our tables of examples taken
from the paper's LaTeX source, and outputs the JSON files in directory `jsons_of_examples`.


The files `texsrc/tbl-approval.tex`, `texsrc/tbl-plurality.tex`, and `texsrc/tbl-veto.tex` 
contain our results for approval, plurality, and veto. They contain the results in LaTeX format,
taken from our paper's source code.
To check the JSON examples versus the claims in each entry in the tables for 
plurality, veto, and approval, we provide a Julia script. For example, to check 
all the claims in the plurality table it suffices to run

    $ julia CheckAll.jl texsrc/tbl-plurality.tex jsons_of_examples/

The script will stop when it finds an incorrect row in the input table and will declare that row incorrect.
It is true that running this script provides a way to verify computer-generated examples. However,
when verifying a single computer-generated example, it is easier to use `Control.jl` as the arguments
to that script allow the user to specify an example and two control types, and thus it makes it easier to
verify if a given example is a witness for the separation between two
specified (as part of the arguments provided to `Control.jl`) control types.

## Runtimes

- The time taken for `CheckAll.jl` to verify the plurality table was 4.474 CPU seconds.
- The time taken for `CheckAll.jl` to verify the veto table was 2.241 CPU seconds.
- The time taken for `CheckAll.jl` to verify the approval table was 4.991 CPU seconds.
