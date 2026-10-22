#!/bin/bash
set -euo pipefail
cd ~/programs
wget --output-document sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-alma_linux64.tar.gz
tar -vxzf sratoolkit.tar.gz
rm -r sratoolkit.tar.gz
echo 'export PATH="$HOME/programs/sratoolkit.3.4.1-alma_linux64/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
