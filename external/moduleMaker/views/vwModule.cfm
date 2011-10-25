<cfparam name="request.requestState.moduleType" default="">
<cfparam name="request.requestState.tagInfo" default="">
<cfparam name="request.requestState.head" default="">
<cfparam name="request.requestState.body" default="">
<cfparam name="request.requestState.isCustom" default="false">
<cfparam name="request.requestState.aFields" default="arrayNew(1)">

<cfset moduleType = request.requestState.moduleType>
<cfset tagInfo = request.requestState.tagInfo>
<cfset head = request.requestState.head>
<cfset body = request.requestState.body>
<cfset isCustom = request.requestState.isCustom>
<cfset aFields = request.requestState.aFields>


<cfparam name="tagInfo.name" default="">
<cfparam name="tagInfo.properties" default="#arrayNew(1)#">
<cfparam name="tagInfo.path" default="">
<cfparam name="tagInfo.hint" default="">

<cfoutput>
	<script type="text/javascript">
		<cfloop from="1" to="#arrayLen(aFields)#" index="i">
			aTokens[#i#] = "#jsStringFormat(aFields[i].token)#";
		</cfloop>
	</script>
	
	<form name="frm" action="index.cfm" method="post" style="margin:0px;padding:0px;">
		<input type="hidden" name="event" value="">
		<input type="hidden" name="moduleType" value="#moduleType#">
		<div>
			<div class="cp_sectionTitle" style="margin:0px;padding:0px;">
				&nbsp; <img src="images/brick.png" align="absmiddle"> Module Editor
			</div>
			<div style="margin-top:5px;margin-bottom:5px;font-size:11px;text-align:left;background-color:##ccc;border:1px solid ##333;padding:2px;">
				<div style="width:230px;float:right;font-size:11px;margin-top:2px;display:none;" id="selInsertField">
					<strong>Insert Field:</strong>
					<cfset index = 1>
					<select name="selInsertToken" onchange="insertToken(this.value)" style="width:150px;font-size:10px;">
						<option value="0">--- Select Field ---</option>
						<cfloop from="1" to="#arrayLen(aFields)#" index="i">
							<option value="#i#">#aFields[i].name#</option>
						</cfloop>
					</select>
				</div>

				<b>View:</b>
				&nbsp;&nbsp;&nbsp;
				<input type="radio" name="viewpanel" value="config" checked="true" onclick="selectPanel('config')" id="chkConfig"> <label for="chkConfig">Config</label>
				<cfif isCustom>
					<input type="radio" name="viewpanel" value="body" onclick="selectPanel('body')" id="chkBody"> <label for="chkBody">Body</label>
					<input type="radio" name="viewpanel" value="head" onclick="selectPanel('head')" id="chkHead"> <label for="chkHead">Head</label>
				<cfelse>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<span style="color:red;font-weight:bold;">This is not a custom module. Only custom modules can be edited using the Module Maker</span>
				</cfif>
			</div>
			<div id="pnl_editor">
				<cfif isCustom>
					<textarea name="body" 
								wrap="off" 
								onkeypress="checkTab(event)" 
								onkeydown="checkTabIE()"	
								id="body" 
								style="width:98%;border:1px solid silver;padding:2px;height:385px;display:none;">#htmlEditFormat(body)#</textarea>
	
					<textarea name="head" 
								wrap="off" 
								onkeypress="checkTab(event)" 
								onkeydown="checkTabIE()"	
								id="head" 
								style="width:98%;border:1px solid silver;padding:2px;height:385px;display:none;">#htmlEditFormat(head)#</textarea>
				</cfif>
				
				<div id="config">
					<div style="border:1px solid silver;padding:10px;">
						<table style="width:100%;">
							<tr>
								<td width="80"><b>Name:</b></td>
								<td><input type="text" name="name" value="#moduleType#" class="formField" disabled="true"></td>
							</tr>
							<tr>
								<td width="80"><b>CFC Path:</b></td>
								<td><input type="text" name="cfcpath" value="#tagInfo.name#" class="formField" disabled="true"></td>
							</tr>
							<tr valign="top">
								<td width="80"><b>Description:</b></td>
								<td><textarea name="hint" class="formField" rows="3">#tagInfo.hint#</textarea></td>
							</tr>
						</table>
					</div>
	
					<div style="margin-top:10px;height:240px;">	
						<table border="1" class="browseTable tblGrid" align="center" style="width:100%;">
							<tr>
								<th colspan="5" style="text-align:left;">
									<div style="float:right;font-weight:normal;margin-right:20px;">
										<img src="images/add.png" align="absmiddle" border="0" alt="Add Section" title="Add Section">
										<a href="##" onclick="loadInFB('index.cfm?event=moduleMaker.ehModuleMaker.dspEditProperty&moduleType=#moduleType#',true)">Add Property</a>
									</div>
									Module Properties
								</th>
							</tr>
							<tr>
								<th style="width:20px;">No.</th>
								<th>Name</th>
								<th style="width:150px;">Type</th>
								<th style="width:50px;">Required?</th>
								<th style="width:75px;">Action</th>
							</tr>
							<cfloop from="1" to="#arrayLen(tagInfo.properties)#" index="i">
								<cfset thisProp = tagInfo.properties[i]>
								<cfparam name="thisProp.name" default="">
								<cfparam name="thisProp.type" default="">
								<cfparam name="thisProp.hint" default="">
								<cfparam name="thisProp.required" default="false">
								<cfparam name="thisProp.default" default="">
								<cfset thisProp.required = isBoolean(thisProp.required) and thisProp.required>
								<tr>
									<td style="width:20px;text-align:right;"><strong>#i#.</strong></td>
									<cfif isCustom>
										<td><a href="##" onclick="loadInFB('index.cfm?event=moduleMaker.ehModuleMaker.dspEditProperty&moduleType=#moduleType#&name=#thisProp.name#',true)">#thisProp.name#</a></td>
									<cfelse>
										<td>#thisProp.name#</td>
									</cfif>
									<td style="width:150px;">#thisProp.type#</td>
									<td style="width:75px;text-align:center;">#yesNoFormat(thisProp.required)#</td>
									<td align="center">
										<cfif isCustom>
											<a href="##" onclick="loadInFB('index.cfm?event=moduleMaker.ehModuleMaker.dspEditProperty&moduleType=#moduleType#&name=#thisProp.name#',true)"><img src="images/brick_edit.png" align="absmiddle" border="0" alt="Edit Module" title="Edit Module"></a>
											&nbsp;
											<a href="##" onclick="deleteProperty('#moduleType#','#thisProp.name#')"><img src="images/brick_delete.png" align="absmiddle" border="0" alt="Delete Module" title="Delete Module"></a>
										</cfif>
									</td>
								</tr>
							</cfloop>
							<cfif arrayLen(tagInfo.properties) eq 0>
								<tr><td colspan="5"><em>Module has no properties</em></td></tr>
							</cfif>
						</table>
					</div>					
				</div>
			</div>
			
			<div class="pagingControls"style="clear:both;">
				<div style="float:right;font-weight:normal;">
					<b>Path:</b> #tagInfo.name#
				</div>
				&nbsp;
				<cfif isCustom>
					<input type="button" name="btnSave" value="Apply Changes" onclick="saveModule(this.form)">
					&nbsp;&nbsp;
					<input type="button" name="btnDelete" value="Delete" onclick="deleteModule(this.form)">
				</cfif>
			</div>
		</div>
	</form>	
</cfoutput>
