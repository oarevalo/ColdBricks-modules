<cfcomponent extends="ColdBricks.handlers.ehColdBricks">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var oContext = getService("sessionContext").getContext();
			
			try {
				hp = oContext.getHomePortals();

				if(hp.getPluginManager().hasPlugin("accounts")) {
					setValue("accountsRoot", getAccountsService().getConfig().getAccountsRoot() );
				}
				
				setValue("appRoot", hp.getConfig().getAppRoot() );
				setValue("resourcesRoot", hp.getConfig().getResourceLibraryPath() );
				setValue("cbPageTitle", "SiteMap Tool");
				setValue("cbPageIcon", "Globe_48x48.png");
				setValue("cbShowSiteMenu", true);
	
				setView("vwMain");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("site.ehSite.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspNode" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var account = getValue("account");
			var hp = 0;
			var oAcc = 0;
			var oAccountSite = 0;
			var validChars = "a-zA-Z0-9_. -!";
			var pageName = "";
			var oContext = getService("sessionContext").getContext();
			var hasAccountsPlugin = 0;
			
			try {
				setLayout("Layout.None");

				hp = oContext.getHomePortals();
				hasAccountsPlugin = hp.getPluginManager().hasPlugin("accounts");
				
				if(hasAccountsPlugin) {
					oAcc = getAccountsService();
					setValue("accountsRoot", oAcc.getConfig().getAccountsRoot() );
					setValue("qryAccounts", oAcc.search() );
				}
	
				// if this is a .cfm file, then read it and check if it was generated with the sitemap tool
				if( right(path,4) eq ".cfm" ) {
					
					txtFile = readFile(expandPath(path));
					
					stResult = reFindNoCase("\$CB_SM_ACCOUNT:\[([#validChars#]*)]", txtFile, 1, true);
					if(stResult.len[1] gt 0) 
						account = mid(txtFile,stResult.pos[2],stResult.len[2]);

					stResult = reFindNoCase("\$CB_SM_PAGE:\[([#validChars#]*)]", txtFile, 1, true);
					if(stResult.len[1] gt 0) 
						pageName = mid(txtFile,stResult.pos[2],stResult.len[2]);
				}

				// if there is an account selected, get the account pages
				if(hasAccountsPlugin and account neq "") {
					oAccountSite = oAcc.getSite(account);		
					aPages = oAccountSite.getPages();
					setValue("aPages", aPages );
				}
	
				setValue("account", account );
				setValue("pageName", pageName );
				setValue("appRoot", hp.getConfig().getAppRoot() );
				setValue("resourcesRoot", hp.getConfig().getResourceLibraryPath() );
				setView("vwNode");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspTreeNode" access="public" returntype="void">
		<cfset var oContext = getService("sessionContext").getContext()>
		<cfset var path = getValue("path")>
		<cfset var hp = oContext.getHomePortals()>
		<cfset var appRoot = hp.getConfig().getAppRoot()>
		<cfset var qryDir = 0>

		<!--- remove duplicate forward slashes
			(this could make CF retrieve its own root directory instead of the
			web root directory for sites located at the root) --->
		<cfset path = replace(path, "//", "/", "ALL")>

		<cfif path eq "">
			<cfset qryDir = QueryNew("name,type")>
			<cfset queryAddRow(qryDir,1)>
			<cfset querySetCell(qryDir,"name",appRoot)>
			<cfset querySetCell(qryDir,"type","Dir")>
			<cfset path = "">
		<cfelse>
			<cfdirectory action="list" directory="#expandPath(path)#" name="qryDir">
		
			<cfquery name="qryDir" dbtype="query">
				SELECT *
					FROM qryDir
					WHERE (upper(type) = 'DIR'
						OR name like '%.cfm'
						OR name like '%.htm')
						and name not like '%.svn'
						and name not like 'config'
					ORDER BY type, name
			</cfquery>		
		</cfif>
	
		<cfset setValue("qryDir", qryDir)>
		<cfset setValue("path", path)>
		<cfset setView("vwTreeNode")>
		<cfset setLayout("Layout.None")>
	</cffunction>

		
	<cffunction name="doCreateDirectory" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var name = getValue("name");
			
			try {
				if(name eq "") throw("Directory name cannot be empty","coldBricks.validation");
				
				if(directoryExists(expandPath(path & "/" & name)))
					throw("You are trying to create a directory that already exists","coldBricks.validation");
			
				createDir(expandPath(path & "/" & name));
				
				setMessage("info", "Directory created");

			} catch(coldBricks.validation e) {
				setMessage("warning",e.message);
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
			setNextEvent("siteMap.ehSiteMap.dspMain");
		</cfscript>		
	</cffunction>	
				
	<cffunction name="doSaveFile" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var name = getValue("name");
			var account = getValue("account");
			var page = getValue("page");
			var update = getValue("update",false);
			var type = getValue("type");
			var crlf = chr(13);
			var fileContent = "";
			var fileName = "";
			var oPageRenderer = 0;
			var hp = 0;
			var oContext = getService("sessionContext").getContext();

			try {
				if(account eq "") throw("Account name cannot be empty","coldBricks.validation");
				
				if(update) {
					fileName = path;
					
				} else {
					if(name eq "") throw("File name cannot be empty");

					fileName = path & "/" & name;
					
					if(type eq "dynamic") {
						if(right(fileName,4) neq ".cfm") fileName = fileName & ".cfm";
					
					} else if(type eq "static") {
						if(right(fileName,4) neq ".htm") fileName = fileName & ".htm";
					}
				
					if(fileExists(expandPath(fileName)))
						throw("You are trying to create a file that already exists","coldBricks.validation");
				}
				
				switch(type) {
					
					case "dynamic":
						fileContent = "<!--- generated file mapping --->" & crlf;
						fileContent = fileContent & "<!--- DO NOT DELETE THESE COMMENTS -- REQUIRED FOR COLDBRICKS SITEMAP TOOL --->" & crlf;
						fileContent = fileContent & "<!--- $CB_SM_ACCOUNT:[#account#] --->" & crlf;
						fileContent = fileContent & "<!--- $CB_SM_PAGE:[#page#] --->" & crlf;
						fileContent = fileContent & "<!--- FINISHED COLDBRICKS COMMENTS --->" & crlf;
						fileContent = fileContent & "<cfset account=""#account#"">" & crlf;
						fileContent = fileContent & "<cfset page=""#page#"">" & crlf;
						fileContent = fileContent & "<cfinclude template=""/homePortalsAccounts/common/Templates/page.cfm"">";
						break;
				
					case "static":
						hp = oContext.getHomePortals();
						
						// put a refernce to the homeportals object in the application scope. 
						// This is needed for the rendering
						application.homePortals = hp;
					
						// load and parse page
						oPageRenderer = hp.loadPage(account, page);
					
						// render page html
						fileContent = oPageRenderer.renderPage();						

						// remove the hp reference from the app scope
						structDelete(application,"homePortals");
						
						break;
						
					default:
						throw("Invalid page type","coldBricks.validation");
				}
			
				writeFile(expandPath(fileName), fileContent);
				setMessage("info", "File created");
		
			} catch(coldBricks.validation e) {
				setMessage("warning",e.message);
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
			setNextEvent("siteMap.ehSiteMap.dspNode","account=#account#&path=#path#");
		</cfscript>		
	</cffunction>	
				
	<cffunction name="doDeleteNode" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var isFile = false;
			
			try {
				isFile = right(path,4) eq ".cfm" or right(path,4) eq ".htm";
				
				if(not isFile) {
					if(not directoryExists(expandPath(path)))
						throw("You are trying to delete a directory that does not exist","coldBricks.validation");
				
					deleteDir(expandPath(path));
					setMessage("info", "Directory deleted");

				} else {
					if(not fileExists(expandPath(path)))
						throw("You are trying to delete a directory that does not exist","coldBricks.validation");
				
					deleteFile(expandPath(path));
					setMessage("info", "File deleted");
				}

			} catch(coldBricks.validation e) {
				setMessage("warning",e.message);
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
			setNextEvent("siteMap.ehSiteMap.dspMain");
		</cfscript>		
	</cffunction>			
		
	<cffunction name="writeFile" access="private" returntype="void">
		<cfargument name="path" type="string" required="true">
		<cfargument name="content" type="string" required="true">
		<cffile action="write" file="#arguments.path#" output="#arguments.content#" >
	</cffunction>

	<cffunction name="deleteFile" access="private" returntype="void">
		<cfargument name="path" type="string" required="true">
		<cffile action="delete" file="#arguments.path#">
	</cffunction>

	<cffunction name="createDir" access="private" returntype="void">
		<cfargument name="path" type="string" required="true">
		<cfdirectory action="create" directory="#arguments.path#">
	</cffunction>

	<cffunction name="deleteDir" access="private" returntype="void">
		<cfargument name="path" type="string" required="true">
		<cfdirectory action="delete" recurse="true" directory="#arguments.path#">
	</cffunction>

	<cffunction name="readFile" access="private" returntype="string">
		<cfargument name="path" type="string" required="true">
		<cfset var txt = "">
		<cffile action="read" file="#arguments.path#" variable="txt">
		<cfreturn txt>
	</cffunction>
		
</cfcomponent>