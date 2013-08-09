#!/bin/bash

# Script to score users

# Prepare input file
sort -t$'\t' -k2,2n input_users_to_score/training.features.all |  grep -v $'\t\t' | sed 's/NA/0/g' > __training.data

# Score users
code/score.R __training.data model.rda output_users_to_score/users.scored

