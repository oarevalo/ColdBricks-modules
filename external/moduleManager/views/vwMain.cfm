<cfset rs = request.requestState>
<cfset index = 1>

<cfoutput>
	<script type="text/javascript">
		function confirmUninstall(uuid,type,name) {
			if(confirm("Are you sure you wish to UNINSTALL the " + type + " module '" + name + "' ?\n\nThis action cannot be undone")) {
				document.location = "index.cfm?event=#rs.eh#.ehGeneral.doUninstall&uuid="+uuid+"&type="+type;
			}
		}
	</script>

	<cfif structKeyExists(rs,"showReset")>
		<div style="margin:10px;border:1px solid silver;background-color:##ebebeb;padding:10px;font-weight:bold;margin-left:0px;color:green;">
			To complete the install/uninstall process <a href="index.cfm?event=ehGeneral.doLogoff&resetapp=1">Click Here</a> to reset ColdBricks. You will be 
			asked to login again.
		</div>
	</cfif>


	<form name="frmInstall" method="post" action="index.cfm" enctype="multipart/form-data">
		<input type="hidden" name="event" value="#rs.eh#.ehGeneral.doInstall">
		<table style="width:100%;border:1px solid silver;background-color:##ebebeb;" cellpadding="3" cellspacing="0">
			<tr><td colspan="2"><b>Install ColdBricks Module:</b></td></tr>
			<tr>
				<td style="width:110px;">Install from URL:</td>
				<td>
					http://<input type="text" name="installURL" value="" class="formField">
					<input type="submit" name="btnInstallURL" value="Install">
				</td>
			</tr>
			<tr>
				<td>Install from archive:</td>
				<td>
					<input type="file" name="installZip" value="">
					<input type="submit" name="btnInstallZIP" value="Install">
				</td>
			</tr>
		</table>
	</form>
	<br />
	
	<table class="browseTable">
		<tr>
			<th style="width:60px;">Type</th>
			<th>Name</th>
			<th style="width:60px;">Version</th>
			<th>Description</th>
			<th style="width:100px;">Author</th>
			<th style="width:70px;">Actions</th>
		</tr>
		<cfloop from="1" to="#arrayLen(rs.serverModules)#" index="i">
			<tr <cfif index mod 2>class="altRow"</cfif>>
				<td align="center">Server</td>
				<td><strong>#rs.serverModules[i].label#</strong></td>
				<td align="center">#rs.serverModules[i].version#</td>
				<td>#rs.serverModules[i].description#</td>
				<td align="center">
					<cfif rs.serverModules[i].author neq "" and rs.serverModules[i].authorurl neq "">
						<a href="#rs.serverModules[i].authorurl#" target="_blank">#rs.serverModules[i].author#</a>
					<cfelseif rs.serverModules[i].author neq "" and rs.serverModules[i].authorurl eq "">
						#rs.serverModules[i].author#
					<cfelseif rs.serverModules[i].author eq "" and rs.serverModules[i].authorurl neq "">
						<a href="#rs.serverModules[i].authorurl#" target="_blank">website</a>
					</cfif>
				</td>
				<td align="center">
					<cfif structKeyExists(rs.serverModules[i],"core") and rs.serverModules[i].core>
						<em>core</em>
					<cfelse>
						<a href="##" onclick="confirmUninstall('#rs.serverModules[i].uuid#','server','#jsStringFormat(rs.serverModules[i].label)#')"><img src="images/delete.png" align="absmiddle" border="0" alt="Uninstall"></a>
						<a href="##" onclick="confirmUninstall('#rs.serverModules[i].uuid#','server','#jsStringFormat(rs.serverModules[i].label)#')">Uninstall</a>
					</cfif>
				</td>
			</tr>
			<cfset index = index + 1>
		</cfloop>
		<tr><td colspan="6">&nbsp;</td></tr>
		<cfloop from="1" to="#arrayLen(rs.siteModules)#" index="i">
			<tr <cfif index mod 2>class="altRow"</cfif>>
				<td align="center">Site</td>
				<td><strong>#rs.siteModules[i].label#</strong></td>
				<td align="center">#rs.siteModules[i].version#</td>
				<td>#rs.siteModules[i].description#</td>
				<td align="center">
					<cfif rs.siteModules[i].author neq "" and rs.siteModules[i].authorurl neq "">
						<a href="#rs.siteModules[i].authorurl#" target="_blank">#rs.siteModules[i].author#</a>
					<cfelseif rs.siteModules[i].author neq "" and rs.siteModules[i].authorurl eq "">
						#rs.siteModules[i].author#
					<cfelseif rs.siteModules[i].author eq "" and rs.siteModules[i].authorurl neq "">
						<a href="#rs.siteModules[i].authorurl#" target="_blank">website</a>
					</cfif>
				</td>
				<td align="center">
					<cfif structKeyExists(rs.siteModules[i],"core") and rs.siteModules[i].core>
						<em>core</em>
					<cfelse>
						<a href="##" onclick="confirmUninstall('#rs.siteModules[i].uuid#','site','#jsStringFormat(rs.siteModules[i].label)#')"><img src="images/delete.png" align="absmiddle" border="0" alt="Uninstall"></a>
						<a href="##" onclick="confirmUninstall('#rs.siteModules[i].uuid#','site','#jsStringFormat(rs.siteModules[i].label)#')">Uninstall</a>
					</cfif>
				</td>
			</tr>
			<cfset index = index + 1>
		</cfloop>
	</table>
</cfoutput>