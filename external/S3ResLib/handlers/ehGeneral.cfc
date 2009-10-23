<cfcomponent extends="ColdBricks.handlers.ehColdBricks">

	<cfset variables.S3Prefix = "s3">
	<cfset variables.S3Path = "ColdBricksModules.S3ResLib.components.s3ResourceLibrary">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			try {
				// check if s3lib is setup for this site
				oContext = getService("sessionContext").getContext();
				oConfig = getService("configManager").getAppHomePortalsConfigBean(oContext);
				stLibTypes = oConfig.getResourceLibraryTypes();

				if(structKeyExists(stLibTypes,variables.S3Prefix)) {
					setValue("aResLibs",oConfig.getResourceLibraryPaths());
					setValue("S3Prefix",variables.S3Prefix);
					setView("vwMain");
				} else {
					setView("vwSetup");
				}
				
				setValue("cbPageTitle", "S3 Resource Libraries");
				setValue("cbPageIcon", "images/configure_48x48-2.png");
				setValue("cbShowSiteMenu", true);
			
			} catch(any e) {
				getService("bugTracker").notifyService(e.message, e);
				setMessage("error", e.message);
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspSetup" access="public" returntype="void">
		<cfscript>
			try {
				setView("vwSetup");
				setValue("cbPageTitle", "S3 Resource Libraries");
				setValue("cbPageIcon", "images/configure_48x48-2.png");
				setValue("cbShowSiteMenu", true);
			
			} catch(any e) {
				getService("bugTracker").notifyService(e.message, e);
				setMessage("error", e.message);
			}
		</cfscript>
	</cffunction>	
	
	<cffunction name="doSetup" access="public" returntype="void">
		<cfscript>
			try {
				// check if s3lib is setup for this site
				oContext = getService("sessionContext").getContext();
				oConfig = getService("configManager").getAppHomePortalsConfigBean(oContext);
				stLibTypes = oConfig.getResourceLibraryTypes();

				if(getValue("key") eq "") throw("S3 Access key cannot be empty","coldbricks.validation");
				if(getValue("secret") eq "") throw("S3 Secret key cannot be empty","coldbricks.validation");
 			
 				oConfig.setResourceLibraryType(variables.S3Prefix, variables.S3Path);
 				oConfig.setResourceLibraryTypeProperty(variables.S3Prefix, "key", getValue("key"));
 				oConfig.setResourceLibraryTypeProperty(variables.S3Prefix, "secret", getValue("secret"));
 				getService("configManager").saveAppHomePortalsConfigBean(oContext, oConfig);
 				
 				reloadSite();
 			
				setMessage("info","S3 access credentials saved. You can now add your S3-backed resource libraries");
				setNextEvent("S3ResLib.ehGeneral.dspMain");
				
			} catch(coldbricks.validation e) {
				setMessage("warning", e.message);
				setNextEvent("S3ResLib.ehGeneral.dspMain");

			} catch(any e) {
				setMessage("error", e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("S3ResLib.ehGeneral.dspMain");
			}
		</cfscript>
	
	</cffunction>
	
	<cffunction name="doSaveResLibPath" access="public" returntype="void">
		<cfscript>
			var index = getValue("index");
			var path = getValue("path");
			var oConfigBean = 0;
			var aResLibs = arrayNew(1);
			
			try {
				oContext = getService("sessionContext").getContext();
				
				if(path eq "") throw("The resource library path is required","validation");

				oConfigBean = getService("configManager").getAppHomePortalsConfigBean(oContext);
				
				// remove resource lib
				if(index gt 0) {
					aResLibs = oConfigBean.getResourceLibraryPaths();
					if(index lte arrayLen(aResLibs))
						oConfigBean.removeResourceLibraryPath(aResLibs[index]);
				}
				
				// add new values for resource
				oConfigBean.addResourceLibraryPath(variables.S3Prefix & "://" & path);
				
				// save changes
				getService("configManager").saveAppHomePortalsConfigBean( oContext, oConfigBean );
				
				setMessage("info", "Resource library updated");
				setNextEvent("S3ResLib.ehGeneral.dspMain");
			
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("S3ResLib.ehGeneral.dspMain","resLibPathEditIndex=#index#");

			} catch(any e) {
				setMessage("error", e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("S3ResLib.ehGeneral.dspMain");
			}
		</cfscript>		
	</cffunction>	

	<cffunction name="doDeleteResLibPath" access="public" returntype="void">
		<cfscript>
			var index = getValue("index");
			var oConfigBean = 0;
			var aResLibs = arrayNew(1);
			
			try {
				oContext = getService("sessionContext").getContext();
				
				if(val(index) eq 0) throw("You must select a resource library to delete","validation");

				oConfigBean = getService("configManager").getAppHomePortalsConfigBean(oContext);
				
				// remove resource lib
				aResLibs = oConfigBean.getResourceLibraryPaths();
				if(index lte arrayLen(aResLibs))
					oConfigBean.removeResourceLibraryPath(aResLibs[index]);
				
				// save changes
				getService("configManager").saveAppHomePortalsConfigBean( oContext, oConfigBean );

				setMessage("info", "Resource library removed");
				setNextEvent("S3ResLib.ehGeneral.dspMain");
			
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("S3ResLib.ehGeneral.dspMain");

			} catch(any e) {
				setMessage("error", e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("S3ResLib.ehGeneral.dspMain");
			}
		</cfscript>	
	</cffunction>	

		
</cfcomponent>