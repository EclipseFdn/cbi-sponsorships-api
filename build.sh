#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

#"${SCRIPT_FOLDER}/memberOrganizationsBenefits.sh"
jsonnet "${SCRIPT_FOLDER}/cbiSponsorships.jsonnet" > "${SCRIPT_FOLDER}/cbiSponsorships.json"

# Builder and push docker image
docker build -t eclipsefdn/cbi-sponsorships-api:latest .
docker push eclipsefdn/cbi-sponsorships-api:latest

# Apply deployments changes (if any)
kubectl apply -f "k8s/production.yml"
# Force restart to pull new image (already deployed image tag ':latest' may be outdated)
kubectl rollout restart -n foundation-internal-webdev-apps deployment/cbi-sponsorships-api