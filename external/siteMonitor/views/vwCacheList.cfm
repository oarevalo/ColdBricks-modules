<cfparam name="request.requestState.done" default="false">

<cfset stInfo = request.requestState.stInfo>
<cfset aItems = request.requestState.aItems>
<cfset cacheName = request.requestState.cacheName>
<cfset done = request.requestState.done>

<cfsavecontent variable="tmpHTML">
<link type="text/css" rel="stylesheet" href="includes/css/style.css" />
<link type="text/css" rel="stylesheet" href="includes/floatbox/floatbox.css" />
<script type="text/javascript" src="includes/floatbox/floatbox.js"></script>
<script type="text/javascript">
	function hideMessageBox() {
		var d = document.getElementById("app_messagebox");
		d.style.display = "none";
	}		
	function deleteCacheItem(key) {
		if(confirm("Remove item from cache?")) {
			<cfoutput>var tmp = "index.cfm?event=siteMonitor.ehSiteMonitor.doCacheFlushItem&cacheName=#jSStringFormat(cacheName)#&key="+key;</cfoutput>
			document.location = tmp;
		}
	}
</script>
<style type="text/css">
	#app_messagebox {
		top:5px;
	}
</style>
</cfsavecontent>
<cfhtmlhead text="#tmpHTML#">

<cfoutput>
	<div class="cp_sectionTitle" 
			style="padding:0px;margin:0px;font-size:14px; width:99%;margin-bottom:5px;">
		<div style="margin:4px;">
			View Cache Contents: #cacheName#
		</div>
	</div>		
	<div style="margin:5px;">
		<strong>Size/Max:</strong> #stInfo.currentSize#/#stInfo.maxSize#
		&nbsp;&nbsp;&nbsp;
		<strong>Hit/Miss:</strong> #stInfo.hitCount#/#stInfo.missCount#
	</div>
	<br />
	<table border="1" class="browseTable tblGrid" style="width:100%">
		<tr>
			<th style="width:15px;">No.</th>
			<th>Key</th>
			<th style="width:50px;">TTL</th>
			<th style="width:40px;">&nbsp;</th>
		</tr>
		<cfloop from="1" to="#arrayLen(aItems)#" index="i">
			<tr>
				<td align="right"><b>#i#.</b></td>
				<td>#aItems[i].key#</td>
				<td align="center">#aItems[i].ttl#</td>
				<td align="center"><a href="##" onclick="deleteCacheItem('#jsStringFormat(aItems[i].key)#')"><img src="images/delete.png" align="absmiddle" alt="Remove item from cache" title="Remove item from cache" border="0"></a></td>
			</tr>
		</cfloop>
	</table>
</cfoutput>

<cfif isBoolean(done) and done>
	<script type="text/javascript">
		setTimeout("fb.end()",100);
	</script>
</cfif>
