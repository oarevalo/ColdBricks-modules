<cfset rs = request.requestState>
<cfoutput>
	
	<p style="font-size:14px;">
		This site is not configured for using resources of type <strong>'#rs.resourceType#'</strong>.
		This resource type is required in order to create and manage outlines
		using the Outline Editor.
	</p>
	<p>
		<form name="frmSetup" action="index.cfm" method="post">
			<input type="hidden" name="event" value="outlineEditor.ehGeneral.doSetup">
			<input type="submit" name="btn" value="Configure Resource Type">
		</form>
	</p>
	<br /><br /><br />
</cfoutput>