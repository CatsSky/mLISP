#!/bin/sh

rm ./test_data/*.out

for f in ./test_data/*.lsp
do
    filename=$(basename $f)
    echo "${filename%.*}: "
    # directing both stdout and stderr to file output
    ./mlisp < $f > $f.out 2> $f.out
    DIFF=$(diff $f.ans $f.out)
    if ["$DIFF" == ""]; then
        echo "[PASSED]"
    else
        echo "[FAILED]"
        echo "$DIFF"
    fi
    echo ""
done