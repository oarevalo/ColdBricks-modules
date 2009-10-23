<cfset rs = request.requestState>
<cfset index = 1>

<cfoutput>
	<script type="text/javascript">
		function confirmUninstall(name) {
			if(confirm("Are you sure you wish to UNINSTALL module '" + name + "' ?\n\nThis action cannot be undone")) {
				document.location = "index.cfm?event=moduleManager.ehGeneral.doUninstall&name="+name;
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
		<input type="hidden" name="event" value="moduleManager.ehGeneral.doInstall">
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
	
	<div style="margin-bottom:8px;">
		<b>NOTE:</b> 'core' modules cannot be uninstalled.
	</div>

	<table class="browseTable">
		<tr>
			<th>Name</th>
			<th style="width:60px;">Version</th>
			<th>Description</th>
			<th style="width:100px;">Author</th>
			<th style="width:70px;">Actions</th>
		</tr>
		<cfloop from="1" to="#arrayLen(rs.modules)#" index="i">
			<tr <cfif index mod 2>class="altRow"</cfif>>
				<td><strong>#rs.modules[i].name#</strong></td>
				<td align="center">#rs.modules[i].version#</td>
				<td>#rs.modules[i].description#</td>
				<td align="center">
					<cfif rs.modules[i].author neq "" and rs.modules[i].authorurl neq "">
						<a href="#rs.modules[i].authorurl#" target="_blank">#rs.modules[i].author#</a>
					<cfelseif rs.modules[i].author neq "" and rs.modules[i].authorurl eq "">
						#rs.modules[i].author#
					<cfelseif rs.modules[i].author eq "" and rs.modules[i].authorurl neq "">
						<a href="#rs.modules[i].authorurl#" target="_blank">website</a>
					</cfif>
				</td>
				<td align="center">
					<cfif structKeyExists(rs.modules[i],"core") and rs.modules[i].core>
						<em>core</em>
					<cfelse>
						<a href="##" onclick="confirmUninstall('#jsStringFormat(rs.modules[i].name)#')"><img src="images/delete.png" align="absmiddle" border="0" alt="Uninstall"></a>
						<a href="##" onclick="confirmUninstall('#jsStringFormat(rs.modules[i].name)#')">Uninstall</a>
					</cfif>
				</td>
			</tr>
			<cfset index = index + 1>
		</cfloop>
	</table>
</cfoutput>