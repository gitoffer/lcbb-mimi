#!/bin/sh
# script to remove carriage returns from files (useful for processing
# excel tab-delimited files). use:
# removeCarriageReturn.sh FILENAME

tr "\r" "\n" < $1 > $1.ncr