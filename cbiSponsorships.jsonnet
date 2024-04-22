{
    local cbi_sp = import 'cbiSponsoredProjects.json',

    local filter_by_name(array, name) = std.filter(function(it) it.name == name, array),

    //std.sum requires jsonnet version 0.20.0, here is an alternative
    local sum(array) = std.foldl(function(x, y) (x + y), array, 0),

    local rp_used(name) = sum([
     //can resourcePacks be replaced with a variable?
     so.resourcePacks
     for sp in cbi_sp
     for so in filter_by_name(sp.sponsoringOrganizations, name)
    ]),

    local da_used(name) = sum([
     //can dedicatedAgents be replaced with a variable?
     so.dedicated
     for sp in cbi_sp
     for so in filter_by_name(sp.sponsoringOrganizations, name)
    ]),

    local ghr_used(name) = sum([
     //can ghLargeRunners be replaced with a variable?
     so.runners
     for sp in cbi_sp
     for so in filter_by_name(sp.sponsoringOrganizations, name)
    ]),

	local memberOrgBen(name, id, membership, packs=0, dedicated=0, runners=0) = {
	  displayName: name,
	  id: id,
	  membership: membership,
      resourcePacks: packs,
      resourcePacks_used: rp_used(name),
      dedicatedAgents: dedicated,
      dedicatedAgents_used: da_used(name),
      ghLargeRunners: runners,
      ghLargeRunners_used: ghr_used(name),
	},

    memberOrganizationsBenefits: [
      memberOrgBen(mob["displayName"], mob["id"], mob["membership"], mob["resourcePacks"], mob["dedicatedAgents"], mob["ghLargeRunners"])
      for mob in import 'memberOrganizationsBenefits.jsonnet'
    ],

    local sponsoringOrg(name, packs=0, dedicated=0, runners=0, tickets=[], comment="") = {
      id: std.filter(function(it) it.displayName == name, $.memberOrganizationsBenefits)[0].id,
      displayName: name,
      resourcePacks: packs,
      dedicatedAgents: dedicated,
      ghLargeRunners: runners,
      requestTickets: tickets,
      comment: comment,
    },
    local sponsoredProject(project_id, sponsorOrgs) = {
      project: {id: project_id},
      sponsoringOrganizations: [
        //TODO: or just copy content from import?
        sponsoringOrg(so["name"], so["resourcePacks"], so["dedicated"], so["runners"], so["tickets"], so["comment"]) for so in sponsorOrgs
      ]
    },

    sponsoredProjects: [
      sponsoredProject(sponProj["project_id"], sponProj["sponsoringOrganizations"])
      for sponProj in import 'cbiSponsoredProjects.json'
    ],
}
