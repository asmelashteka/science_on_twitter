#!/bin/bash

# Script to generate data sets
mkdir -p input_experiment input_users_to_score

function split_dataset {
  data_set=$1
  ids=$2
  
  cat $data_set | awk -F"\t" '{print $2"\t"$0}' | sort -t$'\t' -k1,1 | join -t$'\t' -1 1 -2 1 - $ids | cut -f2-
}

function experiment {
   SEED=10001
   POSITIVE_SIZE=3500
   NEGATIVE_SIZE=1500

   #----------------------------------------
   # sampling
   # sample from users who have content info.
   cut -f2 output_features/features.content |grep '^[0-9]' | sort -u > __all.ids
   grep '^dblp'  output_features/features.content | cut -f2 | code/sample_users.py $SEED $POSITIVE_SIZE | sort -u > __positive.ids
   grep '^rand' output_features/features.content | cut -f2 | code/sample_users.py $SEED $NEGATIVE_SIZE | sort -u > __negative.ids
   grep '^conf' output_features/features.content | cut -f2 | sort -u >> __negative.ids

   # Learning sample
   cat __positive.ids __negative.ids <(echo "Id") | sort -u >  __learning.ids
   # Validation sample
   comm -2 -3 __all.ids __learning.ids | cat - <(echo "Id") | sort -u > __validation.ids 

   #----------------------------------------
   # splitting dataset
   
   # learning sample
   split_dataset output_features/features.profile __learning.ids > __learning.profile
   split_dataset output_features/features.content __learning.ids > __learning.content
   split_dataset output_features/features.network __learning.ids > __learning.network
   code/generate_experiment_datasets.py __learning.profile __learning.content __learning.network True input_experiment/

   # validation sample
   split_dataset output_features/features.network __validation.ids > __validation.network
   split_dataset output_features/features.content __validation.ids > __validation.content
   split_dataset output_features/features.profile __validation.ids > __validation.profile
   code/generate_experiment_datasets.py __validation.profile __validation.content __validation.network True input_validation/

}

function scoring {
# Datasets for prediction
code/generate_experiment_datasets.py output_features/features.user.profile output_features/features.user.content output_features/features.user.network False input_users_to_score/

}

if [[ $# -eq 1 ]]
then
   option=$1
   if [[ $option == 0 ]]
   then
      experiment
   elif [[ $option == 1 ]]
   then
      scoring
   else
      echo "Wrong argument <option>"
      exit 1
   fi
else
   echo "usage: generate_datasets <option 0 learning 1 scoring>"
   exit 1
fi
