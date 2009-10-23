<cfset probeURL = request.requestState.probeURL>
<cfset probeURLExists = request.requestState.probeURLExists>		

<cfoutput>
	<li><b>Probe URL:</b> #probeURL#</li>
	<li><b>Exists?</b> #yesNoFormat(probeURLExists)#</li>
	<br /><br />
	<a href="index.cfm?event=siteMonitor.ehSiteMonitor.doInstallProbe">Install Remote Probe</a>
</cfoutput>
	