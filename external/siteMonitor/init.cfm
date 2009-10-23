<cfset getService("UIManager").registerModule(name = "siteMonitor",
												description = "Displays runtime statistics and insight into the current status of a site")>
	
<cfset getService("UIManager").registerSiteFeature(href = "index.cfm?event=siteMonitor.ehSiteMonitor.dspMain",
												imgSrc = "images/gnome-monitor_48x48.png",
												alt = "Site Monitor",
												label = "Site Monitor",
												accessMapKey = "siteMonitor",
												description = "Displays runtime statistics and insight into the current status of a site")>

<cfset getService("Permissions").addResource(id = "siteMonitor",
											event = "siteMonitor.ehSiteMonitor.*",
											roles = "admin")>
											