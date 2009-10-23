<cfcomponent extends="ColdBricks.handlers.ehColdBricks">
	
	<cfset variables.PROXY_FILENAME = "homePortalsProxy.cfc">
	
	
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			try {
				// check if monitoring probe is installed
				if(not checkProbe()) {
					setNextEvent("siteMonitor.ehSiteMonitor.dspInstallProbe");
				}
				setValue("probeWS",getProbeWS());
				setValue("cbPageTitle", "Site Monitor");
				setValue("cbPageIcon", "images/gnome-monitor_48x48.png");
				setValue("cbShowSiteMenu", true);
				setView("vwMain");
			
			} catch(any e) {
				setMessage("error", e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehSite.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspInstallProbe" access="public" returntype="void">
		<cfscript>
			try {
			
				setValue("probeURL",getProbeURL());
				setValue("probeURLExists",fileExists(expandPath(getProbeURL())));
			
				setValue("cbPageTitle", "Site Monitor > Install/Verify Remote Probe");
				setValue("cbPageIcon", "images/gnome-monitor_48x48.png");
				setValue("cbShowSiteMenu", true);
				setView("vwInstallProbe");

			} catch(any e) {
				setMessage("error", e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehSite.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspCacheList" access="public" returntype="void">
		<cfscript>
			var cacheName = getValue("cacheName");
			
			try {
				ws = getProbeWS();

				setValue("stInfo", ws.getCacheInfo(cacheName));
				setValue("aItems", ws.listCache(cacheName));
				setView("vwCacheList");
				setLayout("Layout.Clean");
			
			} catch(any e) {
				setMessage("error", e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
		</cfscript>
	</cffunction>


	<cffunction name="doInstallProbe" access="public" returntype="void">
		<cfscript>
			try {
				installProbe();
				
				setMessage("info","Remote probe installed succesfully!");
				setNextEvent("siteMonitor.ehSiteMonitor.dspMain");

			} catch(any e) {
				setMessage("error", e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("siteMonitor.ehSiteMonitor.dspInstallProbe");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doResetSite" access="public" returntype="void">
		<cfscript>
			try {
				ws = getProbeWS();
				ws.reset();
				
				setMessage("info", "Done!");
				setNextEvent("siteMonitor.ehSiteMonitor.dspMain");
			
			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("siteMonitor.ehSiteMonitor.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doCacheClear" access="public" returntype="void">
		<cfscript>
			try {
				ws = getProbeWS();
				ws.clearCache(getValue("cacheName"));

				setMessage("info", "Done!");
				setNextEvent("siteMonitor.ehSiteMonitor.dspMain");
			
			} catch(any e) {
				setMessage("error", e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("siteMonitor.ehSiteMonitor.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doCacheReap" access="public" returntype="void">
		<cfscript>
			try {
				ws = getProbeWS();
				ws.cleanupCache(getValue("cacheName"));

				setMessage("info", "Done!");
				setNextEvent("siteMonitor.ehSiteMonitor.dspMain");
			
			} catch(any e) {
				setMessage("error", e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("siteMonitor.ehSiteMonitor.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doCacheFlushItem" access="public" returntype="void">
		<cfscript>
			var cacheName = getValue("cacheName");
			var key = getValue("key");
			
			try {
				ws = getProbeWS();
				ws.flushCacheItem(cacheName,key);

				setMessage("info", "Item removed from cache");
				setNextEvent("siteMonitor.ehSiteMonitor.dspCacheList","cacheName=#cacheName#");
			
			} catch(any e) {
				setMessage("error", e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("siteMonitor.ehSiteMonitor.dspCacheList","cacheName=#cacheName#");
			}
		</cfscript>
	</cffunction>


	<!--- Private Methods --->

	<cffunction name="installProbe" access="private" returntype="void">
		<cfset var txt = "">
		<cfset var hpRefStr = "application.homePortals">
		<cfset var appRoot = getService("sessionContext").getContext().getSiteInfo().getPath()>
		<cfset var crlf = chr(13) & chr(10)>
		<cfset var path = getProbeURL()>
		
		<cfset txt = "<cfcomponent extends=""homePortals.components.homePortalsProxy"">" & crlf
					& "<!--- THIS FILE HAS BEEN GENERATED AUTOMATICALLY BY COLDBRICKS --->" & crlf
					& "<cfset variables.HOMEPORTALS_INSTANCE_VAR = ""#hpRefStr#"">" & crlf
					& "<cfset variables.APP_ROOT = ""#appRoot#"">" & crlf
					& "</cfcomponent>">
		
		<cffile action="write" file="#expandPath(path)#" output="#txt#">
	</cffunction>

	<cffunction name="checkProbe" access="private" returntype="boolean">
		<cfscript>
			var isOK = false;
			try {
				getProbeWS();
				isOK = true;
			} catch(any e) {
				// something happened
			}
			return isOK;
		</cfscript>
	</cffunction>
	
	<cffunction name="getProbeWS" access="private" returntype="any">
		<cfscript>
			var publicHost = "http://" & CGI.HTTP_HOST;
			var wsdl = getProbeURL() & "?wsdl";
			var ws = createObject("webservice",publicHost & wsdl);
			return ws;
		</cfscript>
	</cffunction>

	<cffunction name="getProbeURL" access="private" returntype="string">
		<cfscript>
			var path = "";
			var oSiteInfo = getService("sessionContext").getContext().getSiteInfo();
			
			path = oSiteInfo.getPath();
			
			if(right(path,1) neq "/") path = path & "/";
			path  = path & variables.PROXY_FILENAME;

			return path;
		</cfscript>
	</cffunction>

</cfcomponent>