<cfparam name="request.requestState.stContentRenderers" default="#structNew()#">
<cfparam name="request.requestState.moduleType" default="">
<cfparam name="request.requestState.cbModulesPath" default="">

<cfset stContentRenderers = request.requestState.stContentRenderers>
<cfset moduleType = request.requestState.moduleType>
<cfset cbModulesPath = request.requestState.cbModulesPath>

<cfsavecontent variable="tmpHTML">
	<script type="text/javascript" src="includes/js/prototype-1.6.0.js"></script>
	<cfoutput><script type="text/javascript" src="#cbModulesPath#/moduleMaker/includes/main.js"></script></cfoutput>
	<style type="text/css">
		.buttonImage {
			white-space:nowrap;
			height:1%;
			height:25px;
			padding-top:10px;
			text-align:center;
		}
		.buttonImage a {
			text-decoration:none !important;
			font-weight:bold;
			color:#333;
		}
		.buttonImage a:hover {
			color:green !important;
		}	
		#btnImport {
			background:transparent url(images/btn_120x24.gif) no-repeat scroll 0%;
			width:120px;
			margin:0 auto;
		}
	</style>
	<link type="text/css" rel="stylesheet" href="includes/floatbox/floatbox.css" />
	<script type="text/javascript" src="includes/floatbox/floatbox.js"></script>
</cfsavecontent>
<cfhtmlhead text="#tmpHTML#">

<cfoutput>
<table width="100%" cellpadding="0" cellspacing="0">
	<tr valign="top">
		<td width="150">
			<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title" 
					style="width:150px;padding:0px;margin:0px;">
				<div style="margin:2px;">
					&nbsp; Custom Modules
				</div>
			</div>
			<div style="border-bottom:1px solid black;background-color:##ccc;text-align:left;line-height:22px;font-size:11px;">
				<img src="images/add.png" align="absmiddle" style="margin-left:5px;"> 
				<a href="##" onclick="loadInFB('index.cfm?event=moduleMaker.ehModuleMaker.dspAddModule',true)" style="font-weight:bold;">Create Module</a>
			</div>
			<div class="cp_sectionBox" 
				style="margin:0px;width:150px;padding:0px;height:428px;border-top:0px;">
				<div style="margin:5px;">
					<cfset lstTags = structKeyList(stContentRenderers)>
					<cfset lstTags = listSort(lstTags,"textnocase","asc")>
					<cfloop list="#lstTags#" index="key">
						<div style="margin-bottom:2px;">
							<img src="images/brick.png" align="absmiddle">
							<a href="##" 
								onclick="selectModuleType('#key#')"
								class="resTreeItem" 
								id="resTreeItem_#key#">#key#</a> 
						</div>
					</cfloop>
					<br />
				</div>
			</div>			

		</td>
		<td>
			<div style="margin-left:5px;margin-right:5px;">
				<div style="background-color:##fff;" id="nodePanel">

					<div style="line-height:24px;margin:30px;font-size:14px;">
					
						<img src="images/quick_start.gif"><br><br>
						
						&bull; The list on the left shows the module types defined for this site.
						<b>Note:</b> Modules defined at a global level are not shown and cannot be edited from
						within a site.
						<br><br>
						
						&bull; Select a module type from the list on the left to edit its contents<br><br>
						
						&bull; Click on <b>Create Module</b> to create a new custom module for this site<br><br>
						
						&bull; <b>Did you know?</b> Your custom modules can use any existing item from the resource
						library or you can also create your own custom resource types.
							
					</div>

				</div>
			</div>
		</td>
		<td width="180">
			<div class="cp_sectionBox helpBox"  style="margin:0px;height:470px;line-height:18px;">
				<div style="margin:10px;">
					<h2>Module Maker</h2>
					<p>
						Modules are functional blocks that determine how content is displayed on a page. Pages may contain
						any number of modules to display content in different ways.
					</p>
					<p>
						The Module Maker is a tool to allow you to create simple modules that can be configured to display
						any content you like. A module is defined by its properties, and its content. Content is divided into
						<b>Head</b> content and <b>Body</b> content, referring to the section on the final HTML document where
						that particular content will be placed. Head content is used generally for CSS declarations and JavaScript
						code. The Body is typically where the user-visible content will go.
					</p>
					<p>
						When you write your head or body content you can access any module properties by using the notation <b>$module_PROP-NAME$</b>,
						where PROP-NAME is the name of the property or module attribute you wish to use.
					</p>
				</div>
			</div>		
		</td>
	</tr>
</table>

<cfif moduleType neq "">
	<script type="text/javascript">
		selectModuleType('#jsstringformat(moduleType)#');
	</script>
</cfif>
</cfoutput>
				