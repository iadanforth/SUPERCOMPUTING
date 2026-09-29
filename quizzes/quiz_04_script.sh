#!/bin/bash
set -ueo pipefail

DIR=$1

ls -1 $1 | wc -l 
