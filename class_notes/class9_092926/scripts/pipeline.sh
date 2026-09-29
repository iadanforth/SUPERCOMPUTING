#!/bin/bash

set -euo pipefail

./scripts/install_seq_kit.sh

export PATH=$HOME/programs:$PATH

./scripts/chop_files.sh

./scripts/get_stats.sh

