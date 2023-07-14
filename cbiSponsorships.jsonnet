{
	memberOrganizationsBenefits: import './memberOrganizationsBenefits.jsonnet',
	local sponsoringOrg(name, packs=0, dedicated=0, tickets=[], comment="") = {
      id: std.filter(function(it) it.displayName == name, $.memberOrganizationsBenefits)[0].id,
      displayName: name,
      resourcePacks: packs,
      dedicatedAgents: dedicated,
      requestTickets: tickets,
      comment: comment,
    },
    local sponsoredProject(project_id, sponsorOrgs) = {
      project: {id: project_id},
      sponsoringOrganizations: [
        //TODO: or just copy content from import?
        sponsoringOrg(so["name"], so["resourcePacks"], so["dedicated"], so["tickets"], so["comment"]) for so in sponsorOrgs
      ]
    },

    sponsoredProjects: [
      sponsoredProject(sponProj["project_id"], sponProj["sponsoringOrganizations"])
      for sponProj in import 'cbiSponsoredProjects.json'
    ]
}
