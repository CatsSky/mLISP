#!/bin/bash

for f in ./test_data/*.lsp
do
    filename=$(basename -s .lsp $f)
    # echo "${filename%.*}: "
    # directing both stdout and stderr to file output
    # ./mlisp < $f > $f.out 2> $f.out
    DIFF=$(./mlisp < $f |& diff -y --width=80 --suppress-common-lines $f.ans -)
    if [ -z "$DIFF" ]
    then
        echo "${filename}: [PASSED]"
    else
        echo "${filename}: [FAILED]"
        echo "$DIFF"
    fi
    # echo ""
done