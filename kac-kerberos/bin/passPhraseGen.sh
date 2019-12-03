#!/usr/bin/env bash

wordlist="${1:-/usr/share/dict/words}"
numWords="${2:-5}"
numPhrases="${3:-10}"
joinChar="${4:- }"

echo #newline
echo "$numPhrases random lines:"
echo "-----------------"

RANGE=$(cat "$wordlist" | wc -l)
FLOOR=0
phrases=1
while [ "$phrases" -le $numPhrases ]
do
    words=1
    while [ "$words" -le $numWords ]      # Generate 10 ($numWords) random integers.
    do
        number=0   #initialize
        while [ "$number" -le $FLOOR ] # ?
        do
          number=$(openssl rand 4 | od -DAn)
          let "number %= $RANGE"  # Scales $number down within $RANGE.
        done
        word=$(tail -n+$number "$wordlist" | head -1)
        echo -n "${word}${joinChar}"
        let "words += 1"  # Increment count.
    done
    echo #newline
    let "phrases += 1"  # Increment count.
    echo #newline
done
echo "-----------------"
