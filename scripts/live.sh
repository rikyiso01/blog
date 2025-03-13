#!/usr/bin/env bash

set -euo pipefail

live-server -p 8080 out/"$1"-* -o &
find posts/"$1"-* | entr bash scripts/compile.sh "$1"
pkill -P $$
