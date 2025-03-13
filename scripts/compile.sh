#!/usr/bin/env bash

set -euo pipefail

postname="$(basename posts/"$1"-*)"

make -f scripts/compile.makefile "out/$postname/index.html"

for file in posts/"$postname"/graphs/*.mmd
do
    graphname="$(basename "$file" .mmd)"
    make -f scripts/compile.makefile "out/$postname/graphs/$graphname.svg"
done

mkdir -p "out/$postname/images"
cp -r "posts/$postname/images"/* "out/$postname/images"

