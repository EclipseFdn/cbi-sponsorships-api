# CBI Sponsorships API

Available at https://api.eclipse.org/cbi/sponsorships

## API

The API provides 2 root objects:
* `memberOrganizationsBenefits`, an array listing the number of resource packs and dedicated agents each eligible member gets as per https://wiki.eclipse.org/CBI#Resource_Packs_Included_in_Membership
* `sponsoredProjects`, an array on project sponsorship. For each sponsored project, there is a list of `sponsoringOrganizations` describing the number of resource packs and/or dedicated agent attributed to the project. It can also contain some metadata (`requestTickets`) about the sponsorship request and an eventual `comment`.
* 
## Build locally `cbiSponsorships.json`?

```bash
memberOrganizationsBenefits.sh
```

Should generate file: `memberOrganizationsBenefits.jsonnet`


```bash
./build.sh
```
Should generate file: `cbiSponsorships.json`

Commit `cbiSponsorships.json` file to repo.

## Build docker image and Deploy

Run job in jenkins webdev instance: `https://foundation.eclipse.org/ci/webdev/job/cbi-sponsorships-api`

## Show stats

```bash
./showStats.sh
```

## Requirements
* jq
* jsonnet
* kubectl
* pass (with access to the IT pass repository)