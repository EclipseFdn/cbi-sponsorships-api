#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

cbiSponsoredProjectsFile="cbiSponsoredProjects.json"
memberOrganizationsBenefitsFile="memberOrganizationsBenefits.json"

"${SCRIPT_FOLDER}/memberOrganizationsBenefits.sh"
if [[ -f "${memberOrganizationsBenefitsFile}" ]]; then
  echo "Checking if all sponsor orgs are still members..."
  for sponsorOrg in $(jq '[ .[].sponsoringOrganizations[].name ] | unique | .[]' "${cbiSponsoredProjectsFile}"); do
    if ! grep -e "${sponsorOrg}" "${memberOrganizationsBenefitsFile}" > /dev/null; then
      echo "ERROR: ${sponsorOrg} was not found in list of member organizations. Please double-check!"
      exit 1
    fi
  done
  echo "Done."
else
  echo "ERROR: ${memberOrganizationsBenefitsFile} does not exist."
  exit 1
fi
echo "Updating sponsorship API json file..."
jsonnet "${SCRIPT_FOLDER}/cbiSponsorships.jsonnet" > "${SCRIPT_FOLDER}/cbiSponsorships.json"
echo "Done."