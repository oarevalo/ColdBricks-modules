<cfset getService("UIManager").registerModule(name = "siteMap",
												description = "Allows creation of friendly urls for accounts enabled sites")>
	
<cfset getService("UIManager").registerSiteFeature(href = "index.cfm?event=siteMap.ehSiteMap.dspMain",
												imgSrc = "images/Globe_48x48.png",
												alt = "Site Map Tool",
												label = "Site Map",
												accessMapKey = "siteMap",
												bindToPlugin = "accounts",
												description = "The SiteMap Tool allows you to create friendlier URLs to the pages on the site. It works by creating directories and files that act as placeholders that can be linked to existing pages on the site.")>

<cfset getService("Permissions").addResource(id = "siteMap",
											event = "siteMap.ehSiteMap.*",
											roles = "admin,mngr")>
													