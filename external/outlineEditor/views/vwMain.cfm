<cfset rs = request.requestState>
<cfparam name="rs.edit" default="">
<cfparam name="rs.path" default="">
<cfparam name="rs.itemName" default="">
<cfparam name="rs.itemURL" default="">

<cfoutput>
	<script type="text/javascript">
		function confirmDelete(path,item) {
			if(confirm("Are you sure you wish to delete item '" + item + "' ?\n\nThis action cannot be undone")) {
				document.location = "index.cfm?event=outlineEditor.ehGeneral.doDeleteItem&path="+path;
			}
		}
	</script>

	<p style="font-size:13px;">
		<b>Path:</b>
		( <a href="index.cfm?event=outlineEditor.ehGeneral.dspMain">Top</a> )
		<cfloop from="1" to="#arrayLen(rs.aPathItems)#" index="i">
			<cfif i lt arrayLen(rs.aPathItems)>
				&raquo; <a href="index.cfm?event=outlineEditor.ehGeneral.dspMain&path=#rs.aPaths[i]#">#rs.aPathItems[i]#</a>
			<cfelse>
				&raquo; #rs.aPathItems[i]#
			</cfif>
		</cfloop>
	</p>

	<table style="margin:0px;padding:0px;width:100%;" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td>
				<cfif rs.edit neq "">
					<form name="frm" method="post" action="index.cfm">
						<input type="hidden" name="event" value="outlineEditor.ehGeneral.doSaveItem">
						<input type="hidden" name="path" value="#rs.edit#">
						<table class="browseTable" style="border:1px solid silver;background-color:##ebebeb;" cellpadding="3" cellspacing="0">
							<tr>
								<td><b>Name:</b></td>
								<td><input type="text" name="name" value="#rs.itemName#" class="formField"></td>
							</tr>
							<tr>
								<td><b>URL:</b></td>
								<td><input type="text" name="url" value="#rs.itemURL#" class="formField"></td>
							</tr>
							<tr>
								<td colspan="2">
									<input type="submit" name="btnsave" value="Apply Changes">
									&nbsp;&nbsp;
									<a href="index.cfm?event=outlineEditor.ehGeneral.dspMain&path=#rs.path#">Cancel</a>
								</td>
							</tr>
						</table>
					</form>
					<br /><br />
				<cfelse>
					<div class="buttonImage btnLarge" style="margin:0px;">
						<a href="index.cfm?event=outlineEditor.ehGeneral.dspMain&path=#rs.path#&edit=#listAppend(rs.path,0)#"
							><img src="images/add.png" align="absmiddle" border="0"> Add New Item</a>
					</div>	
				</cfif> 

			
				
				<table class="browseTable" style="width:100%;">	
					<tr>
						<th>Item</th>
						<th>URL</th>
						<th style="width:100px;">Has Children?</th>
						<th style="width:120px;">Actions</th>
					</tr>
					<cfloop from="1" to="#arrayLen(rs.xmlBase.xmlChildren)#" index="i">
						<cfset node = rs.xmlBase.xmlChildren[i]>
						<cfset thisPath = listAppend(rs.path,i)>
						<tr <cfif i mod 2>class="altRow"</cfif>>
							<td>#node.xmlAttributes.text#</td>
							<td><a href="#node.xmlAttributes.href#" target="_blank">#node.xmlAttributes.href#</a></td>
							<td align="center">
								#yesNoFormat(arrayLen(node.xmlChildren) gt 0)#
								<cfif arrayLen(node.xmlChildren) gt 0>
									(#arrayLen(node.xmlChildren)#)
								</cfif>
							</td>
							<td align="center">
								<a href="index.cfm?event=outlineEditor.ehGeneral.dspMain&edit=#thisPath#&path=#rs.path#"><img src="images/page_edit.png" alt="Edit item" border="0" align="absmiddle"></a>
								<a href="##" onclick="confirmDelete('#thisPath#','#jsStringFormat(node.xmlAttributes.title)#')"><img src="images/waste_small.gif" alt="Delete" border="0" align="absmiddle"></a>
								<cfif i gt 1>
									<a href="index.cfm?event=outlineEditor.ehGeneral.doMoveUp&path=#thisPath#"><img src="images/arrow_up.png" alt="Move up" border="0" align="absmiddle"></a>
								</cfif>
								<cfif i lt arrayLen(rs.xmlBase.xmlChildren)>
									<a href="index.cfm?event=outlineEditor.ehGeneral.doMoveDown&path=#thisPath#"><img src="images/arrow_down.png" alt="Move down" border="0" align="absmiddle"></a>
								</cfif>
								<a href="index.cfm?event=outlineEditor.ehGeneral.dspMain&path=#thisPath#"><img src="images/chart_organisation.png" alt="View Sub-Items" border="0" align="absmiddle"></a>
							</td>
						</tr>
					</cfloop>
					<cfif arrayLen(rs.xmlBase.xmlChildren) eq 0>
						<tr><td colspan="3"><em>No elements found</em></td></tr>
					</cfif>
				</table>
				<p>
					<b>Legend:</b> &nbsp;&nbsp;
					<img src="images/page_edit.png" align="absmiddle" border="0"> Edit Item &nbsp;&nbsp;
					<img src="images/waste_small.gif" align="absmiddle" border="0"> Delete Item &nbsp;&nbsp;
					<img src="images/arrow_up.png" align="absmiddle" border="0"> Move Item Up &nbsp;&nbsp;
					<img src="images/arrow_down.png" align="absmiddle" border="0"> Move Item Down &nbsp;&nbsp;
					<img src="images/chart_organisation.png" align="absmiddle" border="0"> View Subitems &nbsp;&nbsp;
				</p>

			</td>
			<td width="200">
				<div class="cp_sectionBox helpBox"  style="margin:0px;margin-left:10px;height:450px;line-height:18px;">
					<div style="margin:10px;">
						<h2>Outline Editor</h2>
						This module allows you to define and manage a documents that contain a hierarchical structure of elements.
					</div>
				</div>
			</td>
		</tr>
	</table>
</cfoutput>