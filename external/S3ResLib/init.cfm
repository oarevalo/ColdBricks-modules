<cfset getService("UIManager").registerModule(name = "S3ResLib",
												description = "Provides an adapter to allow resource libraries to store assets using the Amazon S3 service",
												version = "1.0",
												author = "ColdBricks",
												authorURL = "http://www.coldbricks.com")>
				
<cfset getService("UIManager").registerSiteFeature(href = "index.cfm?event=S3ResLib.ehGeneral.dspMain",
												alt = "S3 Resource Libraries",
												imgSrc = "images/Globe_48x48.png",
												label = "S3 Resource Libraries",
												accessMapKey = "s3ResLib",
												description = "Provides an adapter to allow resource libraries to store assets using the Amazon S3 service")>

<cfset getService("Permissions").addResource(id = "s3ResLib",
											event = "S3ResLib.ehGeneral.*",
											roles = "admin,mngr")>
											