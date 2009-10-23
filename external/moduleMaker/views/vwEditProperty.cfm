<cfparam name="request.requestState.done" default="false">
<cfparam name="request.requestState.stResTypes" default="#structNew()#">
<cfparam name="request.requestState.moduleType" default="">
<cfparam name="request.requestState.name" default="">
<cfparam name="request.requestState.propInfo" default="">

<cfset done = request.requestState.done>
<cfset stResTypes = request.requestState.stResTypes>
<cfset moduleType = request.requestState.moduleType>
<cfset name = request.requestState.name>
<cfset propInfo = request.requestState.propInfo>

<cfsavecontent variable="tmpHTML">
<link type="text/css" rel="stylesheet" href="includes/css/style.css" />
<link type="text/css" rel="stylesheet" href="includes/floatbox/floatbox.css" />
<script type="text/javascript" src="includes/floatbox/floatbox.js"></script>
<script type="text/javascript">
	function hideMessageBox() {
		var d = document.getElementById("app_messagebox");
		d.style.display = "none";
	}		
	function togglePropType(type) {
		var s1 = document.getElementById("rowValues");
		var s2 = document.getElementById("rowResourceTypes");

		if(type=="list") {
			s1.style.display = "table-row";
			s2.style.display = "none";
		} else if(type=="resource") {
			s2.style.display = "table-row";
			s1.style.display = "none";
		} else {
			s1.style.display = "none";
			s2.style.display = "none";
		}
	}
</script>
<style type="text/css">
	#app_messagebox {
		top:5px;
	}
	.formField {
		width:250px !important;
	}
</style>
</cfsavecontent>
<cfhtmlhead text="#tmpHTML#">

<cfparam name="propInfo.name" default="">
<cfparam name="propInfo.hint" default="">
<cfparam name="propInfo.type" default="">
<cfparam name="propInfo.values" default="">
<cfparam name="propInfo.required" default="">
<cfparam name="propInfo.default" default="">
<cfparam name="propInfo.displayName" default="">

<cfif listLen(propInfo.type,":") eq 2 and listfirst(propInfo.type,":") eq "resource">
	<cfset tmpType = listfirst(propInfo.type,":")>
	<cfset tmpResourceType = listlast(propInfo.type,":")>
<cfelse>
	<cfset tmpType = propInfo.type>
	<cfset tmpResourceType = "">
</cfif>

<cfset isNewProp = (name eq "")>
<cfset aPropTypes = ["text","list","resource","boolean"]>

<cfoutput>
	<form name="frm" action="index.cfm" method="post" style="margin:0px;padding:0px;">
		<input type="hidden" name="event" value="moduleMaker.ehModuleMaker.doSaveProperty">
		<input type="hidden" name="isNewProp" value="#isNewProp#">
		<input type="hidden" name="moduleType" value="#moduleType#">

		<div class="cp_sectionTitle" 
				style="padding:0px;margin:0px;font-size:14px; width:99%;margin-bottom:5px;">
			<div style="margin:4px;">
				Add/Edit Module Property
			</div>
		</div>		
		
		<div style="margin:5px;">
			<table>
				<tr>
					<td><b>Name:</b></td>
					<td>
						<cfif isNewProp>
							<input type="text" name="name" value="#propInfo.name#" class="formField">
						<cfelse>
							<input type="hidden" name="name" value="#propInfo.name#">
							<input type="text" name="namex" value="#propInfo.name#" class="formField" disabled>
						</cfif>
					</td>
				</tr>
				<tr>
					<td><b>Type:</b></td>
					<td>
						<select name="type" style="width:200px;" class="formField" onchange="togglePropType(this.value)">
							<cfloop from="1" to="#arrayLen(aPropTypes)#" index="j">
								<option value="#aPropTypes[j]#" <cfif tmpType eq aPropTypes[j]>selected</cfif>>#aPropTypes[j]#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr id="rowValues" <cfif tmpType neq "list">style="display:none;"</cfif>>
					<td><b>Values:</b></td>
					<td><input type="text" name="values" value="#propInfo.values#"  class="formField"></td>
				</tr>
				<tr id="rowResourceTypes" <cfif tmpType neq "resource">style="display:none;"</cfif>>
					<td><b>Resource Type:</b></td>
					<td>
						<select name="resourceType"  class="formField">
							<cfloop collection="#stResTypes#" item="key">
								<option value="#key#" <cfif tmpResourceType eq key>selected</cfif>>#key#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td><b>Default:</b></td>
					<td><input type="text" name="default" value="#propInfo.default#" class="formField"></td>
				</tr>
				<tr>
					<td><b>Label:</b></td>
					<td><input type="text" name="displayName" value="#propInfo.displayName#" class="formField"></td>
				</tr>
				<tr>
					<td><b>Required:</b></td>
					<td>
						<input type="radio" name="required" value="true" 
								style="width:auto;" 
								<cfif isBoolean(propInfo.required) and propInfo.required>checked</cfif>> Yes
						&nbsp;&nbsp;
						<input type="radio" name="required" value="false" 
								style="width:auto;" 
								<cfif isBoolean(propInfo.required) and not propInfo.required>checked</cfif>> No
					</td>
				</tr>
				<tr valign="top">
					<td><b>Description:</b></td>
					<td><textarea name="hint" class="formField" rows="3">#propInfo.hint#</textarea></td>
				</tr>
			</table>
		</div>
			
		<div style="text-align:center;">
			<input type="submit" name="btnAdd" value="Apply Changes">
		</div>
	</form>
</cfoutput>

<cfif isBoolean(done) and done>
	<script type="text/javascript">
		setTimeout("fb.end()",100);
	</script>
</cfif>
