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
# Only sponsors are shown where at least one resource pack, dedicated agent or GitHub large runner is used

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

JSON_FILE="cbiSponsorships.json"

get_total() {
  # get total number of resource packs or dedicated agents
  local name="${1:-}"
  local res="${2:-}"
  jq -r "[.memberOrganizationsBenefits[] | select(.displayName==\"${name}\") | .${res}] | add" < "${JSON_FILE}"
}

get_used() {
  # get number of used resource packs or dedicated agents
  local sponsorList="${1:-}"
  local name="${2:-}"
  local res="${3:-}"
  local jq_query=".[] | select(.displayName==\"${name}\") | .${res}"
  echo "${sponsorList}" | jq -r "${jq_query}"
}

show_usage_stats() {
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
    local color
    if [[ "${avail}" -lt 0 ]]; then
      color="\e[1;31m"
    elif [[ "${avail}" -eq 0 ]]; then
      color="\e[1;33m"
    else
      color="\e[1;32m"
    fi
    printf "%-70s %5s ${color}%4s %5s\e[0m\n" "${name}" "${total}" "${used}" "${avail}"
  done
  echo
}

show_usage_stats "Resource Packs Stats" "resourcePacks"
echo
show_usage_stats "Dedicated Agents Stats" "dedicatedAgents"
echo
show_usage_stats "GitHub Large Runners Stats" "ghLargeRunners"