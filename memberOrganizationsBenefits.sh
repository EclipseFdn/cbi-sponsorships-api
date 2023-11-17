#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# Membership metadata are in foundation's DB
read -r -d '' MYSQL_CONFIG <<EOF || :
[client]
user=ef_rw
password=$(pass IT/accounts/mysql/foundation/eclipsefoundation/ef_rw)
database=eclipsefoundation
host=foundation
EOF

read -r -d '' QUERY <<'EOF' || :
SELECT	Organizations.Name1 AS Organization,
	Organizations.OrganizationID,
	CASE
		# Associate [$0, $5k]
		WHEN OrganizationMemberships.DuesTier < 18 THEN 0
		# Solution [$0, $15k)
		WHEN OrganizationMemberships.DuesTier >= 18 AND OrganizationMemberships.DuesTier < 23 THEN 1
		# Solution [$15k, $20k)
		WHEN OrganizationMemberships.DuesTier >= 23 AND OrganizationMemberships.DuesTier < 30 THEN 2
		# Enterprise [$50k, $100k)
		WHEN OrganizationMemberships.DuesTier >= 30 AND OrganizationMemberships.DuesTier < 40 THEN 3
		# Strategic [$25k, $50k)
		WHEN OrganizationMemberships.DuesTier >= 40 AND OrganizationMemberships.DuesTier < 45 THEN 3
		# Strategic [$50k, $100k)
		WHEN OrganizationMemberships.DuesTier >= 45 AND OrganizationMemberships.DuesTier < 46 THEN 5
		# Strategic [$100k, $500k)
		WHEN OrganizationMemberships.DuesTier >= 46 AND OrganizationMemberships.DuesTier < 50 THEN 10
		ELSE 0
	END AS PacksNumbers,
	CASE
		WHEN OrganizationMemberships.DuesTier < 46 THEN 0
		WHEN OrganizationMemberships.DuesTier >= 46 AND OrganizationMemberships.DuesTier < 50 THEN 2
		ELSE 0
	END as StaticAgentNumbers, OrganizationMemberships.Relation


FROM Organizations	JOIN OrganizationMemberships
		ON OrganizationMemberships.OrganizationID = Organizations.OrganizationID

WHERE	(OrganizationMemberships.ExpiryDate = "0000-00-00 00:00:00" OR OrganizationMemberships.ExpiryDate IS NULL OR OrganizationMemberships.ExpiryDate >= CURDATE() )

GROUP BY Organizations.Name1, OrganizationMemberships.Relation
ORDER BY Organizations.Name1
;
EOF

# shellcheck disable=SC2088
REMOTE_MYSQL_CONFIG_FILE="~/mysql.foundation.config"
OUTPUT_JSONNET="${SCRIPT_FOLDER}/memberOrganizationsBenefits.jsonnet"

ssh foundation /bin/bash -c "cat > ${REMOTE_MYSQL_CONFIG_FILE}" <<<"${MYSQL_CONFIG}"
printf '[\n' > "${OUTPUT_JSONNET}"

# shellcheck disable=SC2029
for orgbenefits in $(ssh foundation "mysql --defaults-extra-file='${REMOTE_MYSQL_CONFIG_FILE}' --default-character-set=utf8mb4 --batch --skip-column-names --execute '${QUERY}'" | tr '\t' '|' ); do
  printf $'\t{id: %d, displayName: "%s", resourcePacks: %d, dedicatedAgents: %d, ghLargeRunners: %d, membership: "%s"},\n' \
    "$(cut -d'|' -f2 <<<"${orgbenefits}")" \
    "$( (cut -d'|' -f1 | perl -CS -MHTML::Entities -ne 'print decode_entities($_)' ) <<<"${orgbenefits}")" \
    "$(cut -d'|' -f3 <<<"${orgbenefits}")" \
    "$(cut -d'|' -f4 <<<"${orgbenefits}")" \
    "$(cut -d'|' -f4 <<<"${orgbenefits}")" \
    "$(ms=$(cut -d'|' -f5 <<<"${orgbenefits}"); [[ "${ms}" == "OH"* ]] && echo "OpenHardware" || echo "Eclipse" )" \
     >> "${OUTPUT_JSONNET}"
done
printf ']\n' >> "${OUTPUT_JSONNET}"

# shellcheck disable=SC2029
ssh foundation "rm -vf ${REMOTE_MYSQL_CONFIG_FILE}"

printf "INFO: Regenerated benefits for %d member organizations\n" "$(jsonnet "${OUTPUT_JSONNET}" | jq 'length')"
