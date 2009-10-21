<cfcomponent extends="ColdBricks.handlers.ehColdBricks">
	
	<cfset eventPrefix = "my.">
	
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			try {
				ui = getService("UIManager");
				
				setValue("serverModules", ui.getServerModules());
				setValue("siteModules", ui.getSiteModules());
				setValue("eh", eventPrefix & "moduleManager");
				setValue("cbPageTitle", "Module Manager");
				setValue("cbPageIcon", "");
				setView("vwMain");

			} catch(any e) {
				setMessage("error",e.message);
				setNextEvent("ehGeneral.dspMain");			
			}
		</cfscript>
	</cffunction>

	<cffunction name="doUninstall" access="public" returntype="void">
		<cfset var type = getValue("type")>
		<cfset var uuid = getValue("uuid")>
		<cfset var path = "">
		<cfset var fullpath = "">

		<cftry>
			<cfset ui = getService("UIManager")>
			
			<cfif type eq "server">
				<cfset aModules = ui.getServerModules()>
			<cfelseif type eq "site">
				<cfset aModules = ui.getSiteModules()>
			<cfelse>
				<cfthrow message="Invalid module type [#type#]">
			</cfif>

			<cfloop from="1" to="#arrayLen(aModules)#" index="i">
				<cfif aModules[i].uuid eq uuid>
					<cfset path = aModules[i].accessMapKey>
				</cfif>
			</cfloop>
			
			<cfif path eq "">
				<cfthrow message="Module not registered">
			</cfif>
			
			<cfif directoryExists(expandPath("/ColdBricks/modules/#path#"))>
				<cfset fullpath = "/ColdBricks/modules/#path#">
			<cfelseif directoryExists(expandPath("/ColdBricksModules/#path#"))>
				<cfset fullpath = "/ColdBricksModules/#path#">
			<cfelse>
				<cfthrow message="Module not found">
			</cfif>
			
			<cfdirectory action="delete" directory="#expandPath(fullpath)#" recurse="true">

			<cfset setMessage("info","The module has been uninstalled. You must reset ColdBricks now")>
			<cfset setNextEvent("#eventPrefix#ModuleManager.ehGeneral.dspMain","showReset=true")>

			<cfcatch type="any">
				<cfset setMessage("error",cfcatch.message)>
				<cfset setNextEvent("#eventPrefix#ModuleManager.ehGeneral.dspMain")>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="doInstall" access="public" returntype="void">
		<cfset var installURL = getValue("installURL")>
		<cfset var installZip = getValue("installZip")>
		<cfset var zippath = getTempFile(getTempDirectory(),"coldbricksinstall")>
		<cfset var installpath = "/ColdBricksModules/">		

		<cftry>
			<cfset ui = getService("UIManager")>
			
			<cfif installURL neq "" and getValue("btnInstallURL") neq "">
				<!--- this is a URL install --->
				<cfset path = "/ColdBricksModules/" & getFileFromPath(installURL)>		
				
				<cfif left(installURL,4) neq "http">
					<cfset installURL = "http://" & installURL>
				</cfif>

				<cfhttp method="get" 
						url="#installURL#" 
						getasbinary="auto"
						result="content"
						throwonerror="true"
						redirect="true"
						file="#getFileFromPath(zipPath)#"
						path="#getTempDirectory()#">
				<cfif content.text>
					<cfthrow message="Module archive not found or not available">
				</cfif>

			<cfelseif installZip neq "">
				<!--- this is a ZIP install --->
				<cffile action="upload" destination="#zippath#" nameconflict="overwrite" filefield="installZip">
			</cfif>

			<cfif not directoryExists(expandPath(installpath))>
				<cfdirectory action="create" directory="#expandPath(installpath)#" mode="777">
			</cfif>

			<cfzip action="unzip" destination="#expandPath(installpath)#" file="#zippath#" overwrite="yes" recurse="true"></cfzip>

			<cffile action="delete" file="#zippath#">

			<cfset setMessage("info","The module has been installed. You must reset ColdBricks now")>
			<cfset setNextEvent("#eventPrefix#ModuleManager.ehGeneral.dspMain","showReset=true")>

			<cfcatch type="any">
				<cfset setMessage("error",cfcatch.message)>
				<cfset setNextEvent("#eventPrefix#ModuleManager.ehGeneral.dspMain")>
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>