<cfset getService("UIManager").registerModule(name = "moduleManager",
												description = "Manage current ColdBricks modules and discover new modules from ColdBricks.com",
												version = "1.0",
												author = "ColdBricks",
												authorURL = "http://www.coldbricks.com")>
												
<cfset getService("UIManager").registerServerFeature(href = "index.cfm?event=moduleManager.ehGeneral.dspMain",
												alt = "Module Manager",
												label = "Module Manager",
												accessMapKey = "moduleManager",
												description = "Manage current ColdBricks modules and discover new modules from ColdBricks.com")>

<cfset getService("Permissions").addResource(id = "moduleManager",
											event = "moduleManager.ehGeneral.*",
											roles = "admin")>
											