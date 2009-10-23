<cfparam name="request.requestState.appRoot" default="">
<cfset appRoot = request.requestState.appRoot>

<cfsavecontent variable="tmpHTML">
	<script type="text/javascript" src="includes/js/prototype-1.6.0.js"></script>
	<script type="text/javascript">
		function selectTreeNode(path) {
			doEvent("siteMap.ehSiteMap.dspNode","nodePanel",{path: path});
		}
		
		function deleteNode(path) {
			if(confirm("Delete node?")) {
				var loc = "index.cfm?event=siteMap.ehSiteMap.doDeleteNode&path=" + path;
				document.location = loc;
			}
		}
		
		function reloadNode(path,account) {
			doEvent("siteMap.ehSiteMap.dspNode","nodePanel",{path: path,account: account});
		}
		
		function loadTreeNode(id,path) {
			doEvent('siteMap.ehSiteMap.dspTreeNode',id,{path:path});
		}
	</script>
</cfsavecontent>
<cfhtmlhead text="#tmpHTML#">

<cfoutput>

<table width="100%" cellpadding="0" cellspacing="0">
	<tr valign="top">
		<td width="200">
			<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title" 
					style="width:200px;padding:0px;margin:0px;">
				<div style="margin:2px;">
					&nbsp; #appRoot#
				</div>
			</div>
			<div class="cp_sectionBox" 
				style="margin:0px;width:200px;padding:0px;height:450px;border-top:0px;">
				<div id="accountsTree" style="margin:5px;">
				</div>
			</div>			
		</td>
		<td>
			<div style="margin-left:10px;margin-right:10px;">
				<div style="background-color:##fff;height:470px;border:1px dashed ##ccc;overflow:auto;" id="nodePanel">
					<div style="line-height:24px;margin:30px;font-size:14px;">
					
						<img src="images/quick_start.gif"><br><br>
						
						&bull; Select a directory node to either create subdirectories or new file mappings.<br><br>

						&bull; Clicking on a folder node (<img src="images/folder.png" border="0" align="absmiddle">) will 
							display the folder contents.<br><br>

						&bull; Mapping a physical file to a site page allows site visitors to
							have an easier way to access the page. 
							For example, instead of accessing a page using the URL 
							<em><strong>http://mysite.com/index.cfm?account=default&page=aboutMe</strong></em>,
							that same page could be mapped to a physical file and be accessed as
							<em><strong>http://mysite.com/aboutMe.cfm</strong></em> <br><br>

						&bull; <b>Did you know?</b> Shorter, more concise file names with less dynamic variables are better for search
							engine optimization.

					</div>

				</div>
			</div>
		</td>
		<td width="200">
			<div class="cp_sectionBox helpBox"  style="margin:0px;height:470px;line-height:18px;">
				<div style="margin:10px;">
					<h2>SiteMap Tool</h2>
					<p>
						The SiteMap Tool allows you to create friendlier URLs to the pages on the site. It works
						by creating directories and files that act as placeholders that can be linked to existing 
						pages on the site.
					</p>
					<p>
						Use the tree view on the left to navigate to the place where you wish to create a
						directory or file and then select to which page the new directory or file should be linked to. 
					</p>
				</div>
			</div>		
		</td>
	</tr>
</table>

<script>
loadTreeNode("accountsTree","")
</script>
</cfoutput>
