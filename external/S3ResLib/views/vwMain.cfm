<cfparam name="request.requestState.resLibPathEditIndex" default="">
<cfparam name="request.requestState.s3prefix" default="">
<cfparam name="request.requestState.aResLibs" default="#arrayNew(1)#">

<cfset resLibPathEditIndex = request.requestState.resLibPathEditIndex>
<cfset s3prefix = request.requestState.s3prefix>
<cfset aResLibs = request.requestState.aResLibs>

<script type="text/javascript">
function confirmDeleteResLibPath(index) {
	if(confirm("Delete resource library path?")) {
		document.location = "index.cfm?event=S3ResLib.ehGeneral.doDeleteResLibPath&index=" + index;
	}
}
</script>

<cfoutput>
	<table style="margin:0px;padding:0px;width:100%;" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td>

				<div class="formFieldTip">
					The following resource libraries use S3 as their backend storage. Use the link below the table to add a new S3 Resource Library.
					<br />
					<br />
					To modify your Amazon S3 access credentials, <a href="index.cfm?event=S3ResLib.ehGeneral.dspSetup">Click Here</a>
				</div>
			
				<table style="width:100%;border:1px solid silver;">
					<tr>
						<th style="background-color:##ccc;width:50px;">No.</th>
						<th style="background-color:##ccc;">S3 Bucket Name</th>
						<th style="background-color:##ccc;width:100px;">Action</th>
					</tr>
					<cfloop from="1" to="#arrayLen(aResLibs)#" index="i">
						<cfset path = aResLibs[i]>
						<cfif find("://",path) and left(path,find("://",path)-1) eq s3prefix>
							<tr <cfif resLibPathEditIndex eq i>style="font-weight:bold;"</cfif>>
								<cfset bucketName = replace(path, s3prefix & "://", "")>
								<td style="width:50px;" align="right"><strong>#i#.</strong></td>
								<td><a href="index.cfm?event=S3ResLib.ehGeneral.dspMain&resLibPathEditIndex=#i#">#bucketName#</a></td>
								<td align="center">
									<a href="index.cfm?event=S3ResLib.ehGeneral.dspMain&resLibPathEditIndex=#i#"><img src="images/page_edit.png" border="0" alt="Edit resource library path" title="Edit resource library path"></a>
									<a href="##" onclick="confirmDeleteResLibPath(#i#)"><img src="images/page_delete.png" border="0" alt="Delete resource library path" title="Delete resource library path"></a>
								</td>
							</tr>
						</cfif>
					</cfloop>
				</table>
				<cfif resLibPathEditIndex gte 0>
					<cfset bucketName = "">
					<cfif resLibPathEditIndex gt 0 and resLibPathEditIndex lte arrayLen(aResLibs)>
						<cfset bucketName = replace(aResLibs[resLibPathEditIndex], s3prefix & "://", "")>
					</cfif>
					<form name="frmSaveResLibPath" action="index.cfm" method="post">
						<input type="hidden" name="event" value="S3ResLib.ehGeneral.doSaveResLibPath">
						<input type="hidden" name="index" value="#resLibPathEditIndex#">
						<p style="margin:10px;margin-top:20px;">
							<b>Enter the name of the S3 bucket to use as the root for the resource library:</b><br /><br />
							<input type="text" name="path" value="#bucketName#" style="width:340px;" class="formField">
							&nbsp;&nbsp;
							<input type="submit" name="btnSave" value="Apply" style="font-size:11px;">
							<input type="button" name="btnCancel" value="Cancel" style="font-size:11px;" onclick="document.location='index.cfm?event=S3ResLib.ehGeneral.dspMain'">
						</p>
					</form>
				<cfelse>
					<br>
					<a href="index.cfm?event=S3ResLib.ehGeneral.dspMain&resLibPathEditIndex=0">Click Here</a> to add a resource library
				</cfif>
			</td>
			<td width="200">
				<div class="cp_sectionBox helpBox"  style="margin:10px;margin-right:0px;margin-bottom:0px;height:400px;line-height:18px;">
					<div style="margin:10px;">
						<h2>S3 Resource Libraries</h2>
						This ColdBricks module provides support to create a Resource Library based on an Amazon S3 bucket.<br /><br />
						<b>Amazon S3 (Simple Storage Service)</b> is a service that provides a highly scalable and available data storage service.
						To find more about Amazon S3, go to <strong><a href="http://aws.amazon.com/s3/">http://aws.amazon.com/s3/</a></strong>
						<br /><br />
						With the S3ResLib extension, you can transparently use an S3 bucket to store your resources, just like if they were stored
						on the local file system.
					</div>
				</div>
			</td>
		</tr>
	</table>

</cfoutput>
