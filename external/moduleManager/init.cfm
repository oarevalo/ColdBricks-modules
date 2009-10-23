<cfset getService("UIManager").registerModule(name = "moduleManager",
												description = "Manage current ColdBricks modules and discover new modules from ColdBricks.com")>
												
<cfset getService("UIManager").registerServerFeature(href = "index.cfm?event=my.moduleManager.ehGeneral.dspMain",
												alt = "Module Manager",
												label = "Module Manager",
												accessMapKey = "moduleManager",
												description = "Manage current ColdBricks modules and discover new modules from ColdBricks.com")>

<cfset getService("Permissions").addResource(id = "moduleManager",
											event = "moduleManager.ehGeneral.*",
											roles = "admin")>
											