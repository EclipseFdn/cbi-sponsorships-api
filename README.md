# CBI Sponsorships API

Available at https://api.eclipse.org/cbi/sponsorships

## API

The API provides 2 root objects:
* `memberOrganizationsBenefits`, an array listing the number of resource packs and dedicated agents each eligible member gets as per https://wiki.eclipse.org/CBI#Resource_Packs_Included_in_Membership
* `sponsoredProjects`, an array on project sponsorship. For each sponsored project, there is a list of `sponsoringOrganizations` describing the number of resource packs and/or dedicated agent attributed to the project. It can also contain some metadata (`requestTickets`) about the sponsorship request and an eventual `comment`.
## How to build and deploy?

```bash
./build.sh
```

## Requirements
* jq
* jsonnet
* kubectl
* pass (with access to the IT pass repository)