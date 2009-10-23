<cfparam name="request.requestState.done" default="false">
<cfparam name="request.requestState.path" default="">

<cfset done = request.requestState.done>
<cfset path = request.requestState.path>

<cfsavecontent variable="tmpHTML">
<link type="text/css" rel="stylesheet" href="includes/css/style.css" />
<link type="text/css" rel="stylesheet" href="includes/floatbox/floatbox.css" />
<script type="text/javascript" src="includes/floatbox/floatbox.js"></script>
<script type="text/javascript">
	function hideMessageBox() {
		var d = document.getElementById("app_messagebox");
		d.style.display = "none";
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


<cfoutput>
	<form name="frm" action="index.cfm" method="post" style="margin:0px;padding:0px;">
		<input type="hidden" name="event" value="moduleMaker.ehModuleMaker.doAddModule">

		<div class="cp_sectionTitle" 
				style="padding:0px;margin:0px;font-size:14px; width:99%;margin-bottom:5px;">
			<div style="margin:4px;">
				Create New Module
			</div>
		</div>		
		
		<div style="margin:5px;">
			<br />
			<table style="margin:5px;">
				<tr>
					<td style="width:100px;"><b>Module Name:</b></td>
					<td><input type="text" name="name" value="" class="formField" style="width:500px;"></td>
				</tr>
				<tr>
					<td style="width:100px;"><b>Path:</b></td>
					<td><input type="text" name="path" value="#path#" class="formField"></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td>
						<div class="formFieldTip">
							Location where the module files will be saved. If the directory
							does not exist, it will be created
						</div>
					</td>
				</tr>
				<tr valign="top">
					<td style="width:100px;"><b>Description:</b></td>
					<td><textarea name="description" rows="4" class="formField"></textarea></td>
				</tr>
			</table>
		</div>
			
		<div style="text-align:center;">
			<input type="submit" name="btnAdd" value="Create Module">
		</div>
	</form>
</cfoutput>

<cfif isBoolean(done) and done>
	<script type="text/javascript">
		setTimeout("fb.end()",100);
	</script>
</cfif>
