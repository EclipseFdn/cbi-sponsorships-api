#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

#"${SCRIPT_FOLDER}/memberOrganizationsBenefits.sh"
jsonnet "${SCRIPT_FOLDER}/cbiSponsorships.jsonnet" > "${SCRIPT_FOLDER}/cbiSponsorships.json"
