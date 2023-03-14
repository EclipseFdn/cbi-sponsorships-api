{
	memberOrganizationsBenefits: import 'memberOrganizationsBenefits.jsonnet',
	local sponsoringOrg(name, packs=0, dedicated=0, tickets=[], comment="") = {
		id: std.filter(function(it) it.displayName == name, $.memberOrganizationsBenefits)[0].id,
		displayName: name,
		resourcePacks: packs,
		dedicatedAgents: dedicated,
		comment: comment,
		requestTickets: tickets,
	},


	sponsoredProjects: [
		{
			project: { id: "ecd.codewind" },
			sponsoringOrganizations: [
				sponsoringOrg("IBM", 2, tickets=[
					"https://bugs.eclipse.org/bugs/show_bug.cgi?id=548054#c18",
					"https://bugs.eclipse.org/bugs/show_bug.cgi?id=549494",
				]),
			],
		},

		{
			project: { id: "ecd.theia" },
			sponsoringOrganizations: [
				sponsoringOrg("ARM Limited", 2, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=564771", ], comment="Windows + macOS shared agents"),
			]
		},

		{
			project: { id: "eclipse.jdt" },
			sponsoringOrganizations: [
				sponsoringOrg("IBM", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=559571", ]),
				sponsoringOrg("Red Hat, Inc.", 1, tickets=["https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/976", ]),
			]
		},

		{
			project: { id: "eclipse.platform" },
			sponsoringOrganizations: [
				sponsoringOrg("IBM", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=550270", ]),
				sponsoringOrg("Red Hat, Inc.", 2, tickets=[
					"https://bugs.eclipse.org/bugs/show_bug.cgi?id=550227",
					"https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/976",
				]),
			]
		},

		{
			project: { id: "eclipse.platform.releng" },
			sponsoringOrganizations: [
				sponsoringOrg("IBM", 3, dedicated=2, tickets=[
					"https://bugs.eclipse.org/bugs/show_bug.cgi?id=553027",
					"https://bugs.eclipse.org/bugs/show_bug.cgi?id=562609#c21",
					"https://bugs.eclipse.org/bugs/show_bug.cgi?id=562759",
				], comment="1 pack for Windows shared agent (natives build)"),
				sponsoringOrg("Red Hat, Inc.", 3, dedicated=1, tickets=[
					"https://bugs.eclipse.org/bugs/show_bug.cgi?id=552914",
					"https://bugs.eclipse.org/bugs/show_bug.cgi?id=562609#c15",
					"https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/976",
				], comment="1 pack for macOS shared agent (natives build)"),
			]
		},

		{
			project: { id: "ee4j.eclipselink" },
			sponsoringOrganizations: [
				sponsoringOrg("Oracle", 4, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=564240", ]),
			]
		},

		{
			project: { id: "ee4j.glassfish" },
			sponsoringOrganizations: [
				sponsoringOrg("Fujitsu Limited", 5, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=564312", ]),
				sponsoringOrg("Oracle", 6, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=564744", ]),
				sponsoringOrg("Payara Services Limited", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=564136", ]),
				sponsoringOrg("Omnifish OU", 1, tickets=["https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2102", ]),
			]
		},

		{
			project: { id: "ee4j.jakartaee-tck" },
			sponsoringOrganizations: [
				sponsoringOrg("Fujitsu Limited", 5, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=564312", ]),
				//sponsoringOrg("K-Teq Srls", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=564883", ]),
				//sponsoringOrg("London Jamocha Community", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=564592", ]),
				sponsoringOrg("Tomitribe Corporation", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=564137", ]),
				sponsoringOrg("Webtide LLC", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=564697", ]),
			]
		},

		{
			project: { id: "modeling.sirius" },
			sponsoringOrganizations: [
				sponsoringOrg("OBEO", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=548499", ]),
			]
		},

		{
			project: { id: "modeling.tmf.xtext" },
			sponsoringOrganizations: [
				sponsoringOrg("itemis AG", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=549182", ]),
			]
		},

		{
			project: { id: "polarsys.capella" },
			sponsoringOrganizations: [
				sponsoringOrg("Thales", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=558264", ]),
			]
		},

		{
			project: { id: "technology.egit" },
			sponsoringOrganizations: [
				sponsoringOrg("SAP SE", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=548126", ]),
			]
		},

		{
			project: { id: "technology.jgit" },
			sponsoringOrganizations: [
				sponsoringOrg("SAP SE", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=548126", ]),
			]
		},

		{
			project: { id: "technology.justj" },
			sponsoringOrganizations: [
				sponsoringOrg("Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR)", 2, comment="2 packs for macOS and Windows shared agents (natives build)"),
			]
		},

		{
			project: { id: "tools.cdt" },
			sponsoringOrganizations: [
				sponsoringOrg("Kichwa Coders Canada Inc.", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=551849", ]),
				//sponsoringOrg("QNX Software Systems", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=545547", ]),
				sponsoringOrg("Renesas Electronics Corporation", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=551849", ]),
			]
		},

		{
			project: { id: "tools.tracecompass" },
			sponsoringOrganizations: [
				sponsoringOrg("Ericsson AB", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=558483", ]),
			]
		},

		{
			project: { id: "tools.oomph" },
			sponsoringOrganizations: [
				sponsoringOrg("Vector Informatik GmbH", 1, tickets=["https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/1434", ])
			]
		},

		{
			project: { id: "modeling.mdt.papyrus" },
			sponsoringOrganizations: [
				sponsoringOrg("CEA LIST", 2, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=570916", ]),
			]
		},

		{
			project: { id: "automotive.openpass" },
			sponsoringOrganizations: [
				sponsoringOrg("BMW Group", 1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=571945", ]),
				sponsoringOrg("Robert Bosch GmbH", dedicated=1, tickets=["https://bugs.eclipse.org/bugs/show_bug.cgi?id=571989", ]),
			]
		},

		{
			project: { id: "automotive.sumo" },
			sponsoringOrganizations: [
				sponsoringOrg("Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR)", 1, tickets=["https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/813", ]),
			]
		},

        {
            project: { id: "iot.amlen" },
            sponsoringOrganizations: [
                sponsoringOrg("IBM", 1, tickets=["https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/1523", ]),
            ]
        },

        {
            project: { id: "technology.tycho" },
            sponsoringOrganizations: [
                sponsoringOrg("Renesas Electronics Corporation", 1, tickets=["https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/1958", ]),
                sponsoringOrg("Red Hat, Inc.", 1, tickets=["https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/1962", ]),
                sponsoringOrg("SAP SE", 2, tickets=["https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2197", ]),
            ]
        },

        {
            project: { id: "technology.set" },
            sponsoringOrganizations: [
                sponsoringOrg("Scheidt & Bachmann System Technik GmbH", 1, tickets=["https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2235", ]),
            ]
        },


	],
}
