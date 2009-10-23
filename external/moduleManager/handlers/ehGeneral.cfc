<cfcomponent extends="ColdBricks.handlers.ehColdBricks">
	
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			try {
				ui = getService("UIManager");
				
				setValue("modules", ui.getModules());
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
		<cfset var name = getValue("name")>
		<cfset var fullpath = "">

		<cftry>
			<cfset ui = getService("UIManager")>
			
			<cfif not ui.hasModule(name)>
				<cfthrow message="Module '#name#' not found">
			</cfif>
			
			<cfif directoryExists(expandPath("/ColdBricks/modules/#name#"))>
				<cfset fullpath = "/ColdBricks/modules/#name#">
			<cfelseif directoryExists(expandPath("/ColdBricksModules/#name#"))>
				<cfset fullpath = "/ColdBricksModules/#name#">
			<cfelse>
				<cfthrow message="Module not found">
			</cfif>
			
			<cfdirectory action="delete" directory="#expandPath(fullpath)#" recurse="true">

			<cfset setMessage("info","The module has been uninstalled. You must reset ColdBricks now")>
			<cfset setNextEvent("moduleManager.ehGeneral.dspMain","showReset=true")>

			<cfcatch type="any">
				<cfset setMessage("error",cfcatch.message)>
				<cfset setNextEvent("moduleManager.ehGeneral.dspMain")>
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
			
			<cfelse>
				<cfthrow message="Please provide a URL or archive to install">
			</cfif>

			<cfif not directoryExists(expandPath(installpath))>
				<cfdirectory action="create" directory="#expandPath(installpath)#" mode="777">
			</cfif>

			<cfzip action="unzip" destination="#expandPath(installpath)#" file="#zippath#" overwrite="yes" recurse="true"></cfzip>

			<cffile action="delete" file="#zippath#">

			<cfset setMessage("info","The module has been installed. You must reset ColdBricks now")>
			<cfset setNextEvent("moduleManager.ehGeneral.dspMain","showReset=true")>

			<cfcatch type="any">
				<cfset setMessage("error",cfcatch.message)>
				<cfset setNextEvent("moduleManager.ehGeneral.dspMain")>
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>