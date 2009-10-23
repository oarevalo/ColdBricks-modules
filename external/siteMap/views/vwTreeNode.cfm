<cfparam name="request.requestState.path" default="">
<cfparam name="request.requestState.qryDir" default="">
<cfset path = request.requestState.path>
<cfset qryDir = request.requestState.qryDir>

<cfoutput query="qryDir">
	<cfset thisPath = jsStringFormat(path & "/" & qryDir.name)>
	<cfset newNodeID = createUUID()>
	<div style="margin-bottom:3px;">
		<cfif qryDir.type eq "dir">
			<a href="javascript:loadTreeNode('#newNodeID#','#thisPath#');selectTreeNode('#thisPath#')"><img src="images/folder.png" border="0" align="absmiddle"></a>	
			<a href="javascript:loadTreeNode('#newNodeID#','#thisPath#');selectTreeNode('#thisPath#')">#qryDir.name#</a>
			<div id="#newNodeID#" style="margin-left:10px;"></div>
		<cfelse>
			<a href="javascript:selectTreeNode('#thisPath#')"><img src="images/page.png" border="0" align="absmiddle"></a> 
			<a href="javascript:selectTreeNode('#thisPath#')">#qryDir.name#</a>
		</cfif>
	</div>
</cfoutput>