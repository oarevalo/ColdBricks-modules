<cfset getService("UIManager").registerModule(name = "navMenu",
												description = "This module allows you to manage a hierarchical site navigation structure",
												version = "1.0",
												author = "ColdBricks",
												authorURL = "http://www.coldbricks.com")>
												
<cfset getService("UIManager").registerSiteFeature(href = "index.cfm?event=navMenu.ehGeneral.dspMain",
												alt = "Site navigation",
												label = "navMenu",
												accessMapKey = "navMenu",
												description = "This module allows you to manage a hierarchical site navigation structure")>

<cfset getService("Permissions").addResource(id = "navMenu",
											event = "navMenu.ehGeneral.*",
											roles = "admin,mngr")>
					