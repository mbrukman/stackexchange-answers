#!/bin/bash

# Set common GCP variables. This allows us to either read from the environment,
# if those vars are set, or supply default values.
declare -r PROJECT="${PROJECT:-curious-lemmings-42}"
declare -r ZONE="${ZONE:-us-central1-b}"
declare -r MACHINE_TYPE="${MACHINE_TYPE:-g1-small}"
