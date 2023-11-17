#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2022 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Checks stats for additional resources (resource packs, dedicated agents and GitHub large runners)

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"

JSON_FILE="${SCRIPT_FOLDER}/cbiSponsorships.json"

SPONSOR_NAME="${1:-}"
RES="${2:-}" # resourcePacks/dedicatedAgents/ghLargeRunners

if [ -z "${SPONSOR_NAME}" ]; then
  printf "ERROR: a sponsor name must be given.\n"
  exit 1
fi

if [ -z "${RES}" ]; then
  printf "ERROR: a resource name must be given ('resourcePacks', 'dedicatedAgents' or 'ghLargeRunners').\n"
  exit 1
fi

if [ "${RES}" != "resourcePacks" ] && [ "${RES}" != "dedicatedAgents" ] && [ "${RES}" != "ghLargeRunners" ]; then
  printf "ERROR: resource name must be either 'resourcePacks', 'dedicatedAgents' or 'ghLargeRunners'.\n"
  exit 1
fi

exit_code=0

get_total() {
  # get total number of resource packs/dedicated agents/ghLargeRunners
  local name="${1:-}"
  local res="${2:-}"
  jq -r ".memberOrganizationsBenefits[] | select(.displayName==\"${name}\") | .${res}" < "${JSON_FILE}"
}

get_used() {
  # get number of used resource packs/dedicated agents/ghLargeRunners
  local sponsorList="${1:-}"
  local name="${2:-}"
  local res="${3:-}"
  local jq_query=".[] | select(.displayName==\"${name}\") | .${res}"
  echo "${sponsorList}" | jq -r "${jq_query}"
}

check_usage_stats() {
  local title="${1:-}"
  local res="${2:-}"
  if [[ "${res}" != "resourcePacks" ]] && [[ "${res}" != "dedicatedAgents" ]] && [[ "${res}" != "ghLargeRunners" ]]; then
    echo "Only 'resourcePacks', 'dedicatedAgents' or 'ghLargeRunners' are supported as second parameter!"
    exit 1
  fi
  printf "%s\n" "${title}"
  local sponsorList
  sponsorList="$(jq "[ .sponsoredProjects[].sponsoringOrganizations | map({displayName: .displayName, ${res}: .${res}}) | .[] ] | group_by(.displayName) | map({displayName: map(.displayName)[0], ${res}: map(.${res}) | add})" < "${JSON_FILE}")"
  local names
  names="$(echo "${sponsorList}" | jq -r '.[].displayName')"
  printf "\n%-70s %5s %4s %5s\n" "SPONSOR" "Total" "Used" "Avail"
  for name in ${names}; do
    local total
    total="$(get_total "${name}" "${res}")"
    local used
    used="$(get_used "${sponsorList}" "${name}" "${res}")"
    # skip if nothing is used
    if [[ "${used}" -eq 0 ]]; then
      continue
    fi
    local avail="$((total - used))"
    if [[ "${avail}" -lt 0 ]]; then
      printf "%-70s %5s \e[1;31m%4s %5s\e[0m\n" "${name}" "${total}" "${used}" "${avail}"
      exit_code=1
    fi
  done
  echo
}

# check if sponsor name exists
if ! jq -e '[.memberOrganizationsBenefits[].displayName] | any(.=="'"${SPONSOR_NAME}"'")' < "${JSON_FILE}" > /dev/null; then
  echo "ERROR: Sponsor '${SPONSOR_NAME}' not found! Please check the spelling." >&2
fi

total="$(get_total "${SPONSOR_NAME}" "${RES}")"
sponsorList="$(jq "[ .sponsoredProjects[].sponsoringOrganizations | map({displayName: .displayName, ${RES}: .${RES}}) | .[] ] | group_by(.displayName) | map({displayName: map(.displayName)[0], ${RES}: map(.${RES}) | add})" < "${JSON_FILE}")"
used="$(get_used "${sponsorList}" "${SPONSOR_NAME}" "${RES}")"
if [[ -z "${used}" ]]; then
  used=0
fi

avail="$((total - used))"
if [[ "${avail}" -lt 0 ]]; then
  echo "No additional resources available" >&2
  exit_code=1
else
  echo "${avail}"
fi

exit ${exit_code}