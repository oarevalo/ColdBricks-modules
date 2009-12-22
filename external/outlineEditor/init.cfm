<cfset getService("UIManager").registerModule(name = "outlineEditor",
												description = "This module allows you to manage a hierarchical outline structure",
												version = "1.0",
												author = "ColdBricks",
												authorURL = "http://www.coldbricks.com")>
												
<cfset getService("UIManager").registerSiteFeature(href = "index.cfm?event=outlineEditor.ehGeneral.dspMain",
												imgSrc = "/ColdBricksModules/outlineEditor/images/view-tree.png",
												alt = "Outline Editor",
												label = "Outline Editor",
												accessMapKey = "outlineEditor",
												description = "This module allows you to manage a hierarchical outline structure")>

<cfset getService("Permissions").addResource(id = "outlineEditor",
											event = "outlineEditor.ehGeneral.*",
											roles = "admin,mngr")>
					