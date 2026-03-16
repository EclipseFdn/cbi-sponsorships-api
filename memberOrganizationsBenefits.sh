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
CLIENT_ID="$("${SCRIPT_FOLDER}/utils/local_config.sh" "get_var" "client_id" "members_oauth")"
CLIENT_SECRET="$("${SCRIPT_FOLDER}/utils/local_config.sh" "get_var" "client_secret" "members_oauth")"

OUTPUT_JSON="${SCRIPT_FOLDER}/memberOrganizationsBenefits.json"

#Get OAuth access token
TOKEN_URL="https://auth.eclipse.org/auth/realms/community_realm/protocol/openid-connect/token"

#TODO: use json instead?
echo "Fetching OAuth access token..."
ACCESS_TOKEN=$(curl -s "${TOKEN_URL}" --data-urlencode 'grant_type=client_credentials'\
                                      --data-urlencode "client_id=${CLIENT_ID}"\
                                      --data-urlencode "client_secret=${CLIENT_SECRET}"\
                                      | jq -r .access_token)

#Get Membership API data
MEMBERSHIP_API_URL="https://membership.eclipse.org/api/foundation/organizations"

echo "INFO: Downloading membership API data..."
curl -s "${MEMBERSHIP_API_URL}" --header "Authorization: Bearer ${ACCESS_TOKEN}"\
                                --header 'content-type: application/json' | jq . > membership_api_response.json

membership_api_result="$(cat membership_api_response.json)"

#echo "API result:\n ${membership_api_result}"
> "${OUTPUT_JSON}"

echo "INFO: Parsing membership API data..."
printf '[\n' > "${OUTPUT_JSON}"
for orgbenefits in $(echo "${membership_api_result}" | jq -c '.[] | {id: .organization_id, displayName: .name, levels: .levels[]}'); do
  #echo "${orgbenefits}"
  printf "{\"id\": %d, \"displayName\": %s," \
  "$(jq '.id' <<< "${orgbenefits}")" \
  "$(jq '.displayName' <<< "${orgbenefits}")" \
  >> "${OUTPUT_JSON}"
  #determine resources
  #echo "ID: "$(jq '.id' <<< "${orgbenefits}")" - Levels: "$(jq '.levels.level' <<< "${orgbenefits}")""
  dues_tier="$(jq -r '.levels.dues_tier' <<< "${orgbenefits}")"

  da=0
  ghlr=0

  # Associate [$0, $5k]
  if [[ ${dues_tier} -lt 18 ]]; then # < 18 THEN 0
    rp=0
  # Solution [$0, $15k)
  elif [[ ${dues_tier} -ge 18 ]] && [[ ${dues_tier} -lt 23 ]]; then # >= 18 AND < 23 THEN 1
    rp=1
  # Solution [$15k, $20k)
  elif [[ ${dues_tier} -ge 23 ]] && [[ ${dues_tier} -lt 30 ]]; then # >= 23 AND < 30 THEN 2
    rp=2
  # Enterprise [$50k, $100k)
  elif [[ ${dues_tier} -ge 30 ]] && [[ ${dues_tier} -lt 40 ]]; then # >= 30 AND < 40 THEN 3
    rp=3
  # Strategic [$25k, $50k)
  elif [[ ${dues_tier} -ge 40 ]] && [[ ${dues_tier} -lt 45 ]]; then # >= 40 AND < 45 THEN 3
    rp=3
  # Strategic [$50k, $100k)
  elif [[ ${dues_tier} -ge 45 ]] && [[ ${dues_tier} -lt 46 ]]; then # >= 45 AND < 46 THEN 5
    rp=5
  # Strategic [$100k, $500k)
  elif [[ ${dues_tier} -ge 46 ]] && [[ ${dues_tier} -lt 50 ]]; then # >= 46 AND < 50 THEN 10
    da=2
    rp=10
    ghlr=2
  else
    rp=0
    da=0
    ghlr=0
  fi

  printf "\"resourcePacks\": %d, \"dedicatedAgents\": %d, \"ghLargeRunners\": %d},\n" "${rp}" "${da}" "${ghlr}" \
  >> "${OUTPUT_JSON}"
done

# Remove last comma
sed -i "$ s/,$//" "${OUTPUT_JSON}"

printf ']\n' >> "${OUTPUT_JSON}"

# Pretty-print and sort
cat "${OUTPUT_JSON}" | jq -S  'sort_by(.displayName)' > output.json
mv output.json "${OUTPUT_JSON}" 

printf "INFO: Regenerated benefits for %d member organizations\n" "$(jq '. | length' "${OUTPUT_JSON}")"
