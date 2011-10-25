<cfset getService("UIManager").registerModule(name = "moduleMaker",
												description = "Create your own custom modules to add to your pages",
												version = "1.1",
												author = "ColdBricks",
												authorURL = "http://www.coldbricks.com")>
												
<cfset getService("UIManager").registerSiteFeature(href = "index.cfm?event=moduleMaker.ehModuleMaker.dspMain",
												imgSrc = "images/configure_48x48-2.png",
												alt = "Module Maker",
												label = "Module Maker",
												accessMapKey = "moduleMaker",
												description = "Create your own custom modules to add to your pages")>

<cfset getService("Permissions").addResource(id = "moduleMaker",
											event = "moduleMaker.ehModuleMaker.*",
											roles = "admin,mngr")>
											