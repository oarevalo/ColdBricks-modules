<cfparam name="request.requestState.appRoot" default="">
<cfparam name="request.requestState.accountsRoot" default="">
<cfparam name="request.requestState.resourcesRoot" default="">
<cfparam name="request.requestState.qryAccounts" default="#queryNew('accountName')#">
<cfparam name="request.requestState.account" default="">
<cfparam name="request.requestState.aPages" default="">
<cfparam name="request.requestState.pageName" default="">
<cfparam name="request.requestState.hpRoot" default="/homePortals">
<cfparam name="request.requestState.path" default="">
<cfparam name="request.requestState.oUser" default="">

<cfset account = request.requestState.account>
<cfset pageName = request.requestState.pageName>
<cfset appRoot = request.requestState.appRoot>
<cfset accountsRoot = request.requestState.accountsRoot>
<cfset resourcesRoot = request.requestState.resourcesRoot>
<cfset qryAccounts = request.requestState.qryAccounts>
<cfset aPages = request.requestState.aPages>
<cfset hpRoot = request.requestState.hpRoot>
<cfset path = request.requestState.path>
<cfset oUser = request.requestState.oUser>

<cfscript>
	coldbricksRoot = "/coldBricks/";
	cfideRoot = "/CFIDE/";
	webinfRoot = "/WEB-INF/";
	
	isFile = right(path,4) eq ".cfm" or right(path,4) eq ".htm";
	aPagesSorted = arrayNew(1);
	
	// correct paths
	if(not isFile and right(path,1) neq "/") path = path & "/";
	if(right(appRoot,1) neq "/") appRoot = appRoot & "/";
	if(right(accountsRoot,1) neq "/") accountsRoot = accountsRoot & "/";
	if(right(resourcesRoot,1) neq "/") resourcesRoot = resourcesRoot & "/";
	if(right(hpRoot,1) neq "/") hpRoot = hpRoot & "/";

	path = replace(path,"//","/","all");
	lstRestrictedFiles = "#appRoot#index.cfm,#appRoot#debug.cfm,#appRoot#gateway.cfm";
	
	isRestricted = (findnocase(accountsRoot,path) 
						or findnocase(resourcesRoot,path)
						or findnocase(accountsRoot,path) 
						or findnocase(resourcesRoot,path)
						or listFindNoCase(lstRestrictedFiles, path)
						or findnocase(hproot,path)
						or findnocase(coldbricksRoot,path)
						or findnocase(cfideRoot,path)
						or findnocase(webinfRoot,path));
						
						
	// sort account pages
	if(account neq "") {
		for(i=1;i lte arrayLen(aPages);i=i+1) {
			arrayAppend(aPagesSorted, aPages[i].href);
		}
		arraySort(aPagesSorted,"textnocase","asc");
	}	
	
	
	// check if the user is allowed to edit pages
	stAccessMap = oUser.getAccessMap();
	allowedToEditPages = stAccessMap.pages;
</cfscript>

<cfquery name="qryAccounts" dbtype="query">
	SELECT *
		FROM qryAccounts
		ORDER BY accountName
</cfquery>

<cfoutput>

	<div style="font-size:16px;margin:10px;">
		<b>Path:</b>
		#path#
		<cfif Not isRestricted and path neq appRoot>
			(<img src="images/waste_small.gif" align="absmiddle"> <a href="##" onclick="deleteNode('#jsstringformat(path)#')" style="font-size:11px;"><strong>Delete</strong></a>)
		<cfelse>
			<cfif path eq appRoot>
				<span style="color:green;font-weight:bold;font-size:10px;">(App Root)</span>

			<cfelseif path eq accountsRoot>
				<span style="color:green;font-weight:bold;font-size:10px;">(Accounts Root)</span>

			<cfelseif path eq resourcesRoot>
				<span style="color:green;font-weight:bold;font-size:10px;">(Resource Library Root)</span>

			<cfelseif path eq hproot>
				<span style="color:green;font-weight:bold;font-size:10px;">(HomePortals Engine Root)</span>

			<cfelseif path eq coldbricksRoot>
				<span style="color:green;font-weight:bold;font-size:10px;">(ColdBricks Application)</span>

			<cfelseif path eq cfideRoot>
				<span style="color:green;font-weight:bold;font-size:10px;">(ColdFusion Administrator)</span>

			<cfelseif path eq webinfRoot>
				<span style="color:green;font-weight:bold;font-size:10px;">(Restricted Java Directory)</span>

			<cfelseif listFindNoCase(lstRestrictedFiles, path)>
				<span style="color:green;font-weight:bold;font-size:10px;">(Application File)</span>
			</cfif>
		</cfif>
	</div>

	<form name="frmCreateDir1" method="post" action="index1.cfm" style="margin-left:20px;">
	</form>


	<cfif not isFile>
		<cfif isRestricted>
			<span style="color:red">This directory is restricted and cannot be used with the siteMap tool to create mappings</span>
		</cfif>
		<div style="margin:10px;margin-top:20px;">
		<fieldset class="formEdit" style="width:480px;">
			<legend><img src="images/folder.png" align="absmiddle"> <b>Create Sub-Directory</b></legend>

			<form name="frmCreateDir" method="post" action="index.cfm" style="margin-left:20px;">
				<input type="hidden" name="event" value="siteMap.ehSiteMap.doCreateDirectory">
				<input type="hidden" name="path" value="#path#">
				<table align="center">
					<tr>
						<td><b>Name:</b></td>
						<td>
							<input type="text" name="name" value="" size="50" class="formField" style="width:310px;" <cfif isRestricted>disabled</cfif>>
							<input type="submit" name="btnSave" value="Apply" <cfif isRestricted>disabled</cfif>>
						</td>
					</tr>
				</table>
			</form>
		</fieldset>
		</div>

		<div style="margin:10px;margin-top:20px;">
		<fieldset class="formEdit" style="width:480px;">
			<legend><img src="images/page_add.png" align="absmiddle"> <b>Create File</b>	</legend>
			<form name="frmCreateFile" method="post" action="index.cfm">
				<input type="hidden" name="path" value="#path#">
					
				<table align="center">
					<tr>
						<td><b>Account:</b></td>
						<td>
							<select name="account" class="formField"  style="width:350px;"
									<cfif isRestricted>disabled</cfif> 
									onchange="reloadNode('#path#',this.value)">
								<option value=""></option>
								<cfloop query="qryAccounts">
									<option value="#qryAccounts.accountName#" <cfif account eq qryAccounts.accountName>selected</cfif>>#qryAccounts.accountName#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td><b>Page:</b></td>
						<td>
							<cfif not isRestricted>
								<cfif account neq "">
									<select name="page" class="formField" style="width:350px;"
											onchange="this.form.name.value=this.value">
										<option value=""></option>
										<cfloop from="1" to="#arrayLen(aPagesSorted)#" index="i">
											<option value="#aPagesSorted[i]#">#aPagesSorted[i]#</option>
										</cfloop>
									</select>
								<cfelse>
									Select account name to display pages.
								</cfif>
							<cfelse>
								<input type="text" name="page" value="" size="50" class="formField" disabled>
							</cfif>
						</td>
					</tr>
					<cfif account neq "">
						<tr>
							<td><b>Name:</b></td>
							<td>
								<input type="text" name="name" value="" size="50" style="width:340px;" 
										class="formField" <cfif isRestricted>disabled</cfif>>
							</td>
						</tr>
						<tr valign="top">
							<td><b>Type:</b></td>
							<td>
								<input type="radio" name="type" value="dynamic" checked> Dynamic
								&nbsp;&nbsp;&nbsp;
								<input type="radio" name="type" value="static"> Static
								&nbsp;&nbsp;
								<a href="##" onclick="togglePanel('pageTypeHelp')"><img src="images/help.png" border="0" align="absmiddle" 
									alt="Click here for help about this field"
										title="Click here for help about this field"></a>
								
								<div style="font-size:11px;border:1px solid silver;padding:10px;display:none;width:320px;margin-top:10px;line-height:16px;" 
										id="pageTypeHelp" class="helpBox">
									&bull; Choose <b>Dynamic</b> to maintain all functionality and any module
									interactivity in the page intact. By default all pages in the site
									are dynamic. Dynamic always pages end in .cfm<br> <br> 
									
									&bull; <b>Static</b> allows you to create a static version of the page,
									this increases the performance dramatically, however some module 
									interactivity may be lost. Static always pages end in .htm<br>
									<b style="color:red;">Warning:</b> Not all pages can be rendered as Static
								</div>
							</td>
						</tr>
					</cfif>
				</table>
				<br>
				&nbsp;&nbsp;<input type="button" name="btnSave" value="Create File" 
									<cfif isRestricted>disabled</cfif> 
									onclick="doFormEvent('siteMap.ehSiteMap.doSaveFile','nodePanel',this.form)">
			</form>
		</fieldset>
		</div>
	<cfelseif isFile and pageName neq "">
		<!--- this is a file that was successfully parsed --->

		<div style="margin:10px;margin-top:20px;">
		<fieldset class="formEdit" style="width:480px;">
			<legend><img src="images/page_add.png" align="absmiddle"> <b>Edit File</b>	</legend>
			<form name="frmCreateFile" method="post" action="index.cfm">
				<input type="hidden" name="path" value="#path#">
				<input type="hidden" name="update" value="true">
					
				<table align="center">
					<tr>
						<td><b>Account:</b></td>
						<td>
							<select name="account" class="formField" style="width:350px;" 
									<cfif isRestricted>disabled</cfif> 
									onchange="reloadNode('#path#',this.value)">
								<option value=""></option>
								<cfloop query="qryAccounts">
									<option value="#qryAccounts.accountName#" <cfif account eq qryAccounts.accountName>selected</cfif>>#qryAccounts.accountName#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td><b>Page:</b></td>
						<td>
							<cfif not isRestricted>
								<cfif account neq "">
									<select name="page" class="formField" style="width:350px;">
										<option value=""></option>
										<cfloop from="1" to="#arrayLen(aPagesSorted)#" index="i">
											<option value="#aPagesSorted[i]#" <cfif pageName eq listFirst(aPagesSorted[i],".")>selected</cfif>>#aPagesSorted[i]#</option>
										</cfloop>
									</select>
								<cfelse>
									Select account name to display pages.
								</cfif>
							<cfelse>
								<input type="text" name="page" value="" size="50" style="width:350px;" class="formField" disabled>
							</cfif>
						</td>
					</tr>
					<tr>
						<td><b>Name:</b></td>
						<td><input type="text" name="name" value="#getFileFromPath(path)#" size="50" style="width:270px;" class="formField" disabled>
							<cfif allowedToEditPages>
								<a href="index.cfm?event=ehSite.doLoadAccountPage&account=#account#&page=#pageName#"><img src="images/page_edit.png" align="absmiddle" border="0"> Edit Page</a>
							</cfif>
						</td>
					</tr>
					<tr>
						<td><b>Type:</b></td>
						<td><cfif right(path,4) eq ".cfm">Dynamic<cfelse>Static</cfif></td>
					</tr>
				</table>
				<br>
				&nbsp;&nbsp;<input type="button" name="btnSave" value="Apply Changes" 
									<cfif isRestricted>disabled</cfif>
									onclick="doFormEvent('siteMap.ehSiteMap.doSaveFile','nodePanel',this.form)">
			</form>
		</fieldset>
		</div>
	<cfelseif isFile and pageName eq "">
		<div style="margin:10px;">
		<cfif isRestricted>
			<span style="color:red">This file is restricted and cannot be used with the siteMap tool to create mappings</span>
		<cfelse>
			The current file could not be recognized as file mapping created using the SiteMap tool.<br><br>
			<b style="color:red;">CAUTION!</b> Deleting a file that is not a file used for mapping to site pages can
			be dangerous and may cause the site to malfunction.
		</cfif>
		</div>
	<cfelse>
		<div style="margin:10px;">
			Select a directory node to either create subdirectories or new file mappings.
		</div>
	</cfif>

</cfoutput>