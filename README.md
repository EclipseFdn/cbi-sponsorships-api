# CBI Sponsorships API

Available at https://api.eclipse.org/cbi/sponsorships

## API

The API provides 2 root objects:
* `memberOrganizationsBenefits`, an array listing the number of resource packs and dedicated agents each eligible member gets as per https://wiki.eclipse.org/CBI#Resource_Packs_Included_in_Membership
* `sponsoredProjects`, an array on project sponsorship. For each sponsored project, there is a list of `sponsoringOrganizations` describing the number of resource packs and/or dedicated agent attributed to the project. It can also contain some metadata (`requestTickets`) about the sponsorship request and an eventual `comment`.

## Files

* cbiSponsoredProjects.json - defines actual sponsorship of one or more projects by one or more eligible member organisations
  * This file needs to be updated (manually or with a script) when a new sponsorship is requested via a HelpDesk ticket.
* cbiSponsorships.json - static content of the CBI Sponsorship API

## Build `cbiSponsorships.json` locally

To build `cbiSponsorships.json` locally, you can execute the `build.sh` script.

This script runs the following two actions:

1. Gather member organization benefits from Membership API (requires authenticated access to Membership API!)
```bash
memberOrganizationsBenefits.sh
```

Creates file: `memberOrganizationsBenefits.json`

2. Generate Sponsorship API

```bash
./build.sh
```

Creates file: `cbiSponsorships.json`

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