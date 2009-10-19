<cfset getService("UIManager").registerSiteModule(href = "index.cfm?event=my.S3ResLib.ehGeneral.dspMain",
												alt = "S3 Resource Libraries",
												imgSrc = "images/Globe_48x48.png",
												label = "S3 Resource Libraries",
												accessMapKey = "s3ResLib",
												description = "Provides an adapter to allow resource libraries to store assets using the Amazon S3 service")>

<cfset getService("Permissions").addResource(id = "s3ResLib",
											event = "s3ResLib.ehGeneral.*",
											roles = "admin,mngr,edit,cont")>
											