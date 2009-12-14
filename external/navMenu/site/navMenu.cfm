<script type="text/javascript" src="/ColdBricksModules/navMenu/site/navMenu.js"></script>

<cfset checkCache()>
<cfset variables.xmlDoc = getFromCache()>

<cfoutput>
	<div class="sidebarmenu">
		#renderBranch(variables.xmlDoc.xmlRoot,"sidebarmenu1")#
	</div>
</cfoutput>

<cffunction name="renderBranch" output="true">
	<cfargument name="xmlNode">
	<cfargument name="id" default="">
	<cfset var i = 0>
	<ul <cfif arguments.id neq "">id="#arguments.id#"</cfif>>
		<cfloop from="1" to="#arrayLen(arguments.xmlNode.xmlChildren)#" index="i">
			<cfif arguments.xmlNode.xmlChildren[i].xmlAttributes.href eq "">
				<cfset href = "##">
			<cfelse>
				<cfset href = arguments.xmlNode.xmlChildren[i].xmlAttributes.href>
			</cfif>
			<li>
				<a href="#href#">#arguments.xmlNode.xmlChildren[i].xmlAttributes.title#</a>
				<cfif arrayLen(arguments.xmlNode.xmlChildren[i].xmlChildren) gt 0>
					<cfset renderBranch(arguments.xmlNode.xmlChildren[i])>
				</cfif>
			</li>
		</cfloop>
	</ul>
</cffunction>

<cffunction name="checkCache" access="private">
	<cfset var cacheName = "navMenuCache">
	<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
	<cfset var oCacheService = 0>

	<cflock type="exclusive" name="navmenu_lock" timeout="30">
		<cfif not oCacheRegistry.isRegistered(cacheName)>
			<!--- crate cache instance and add to registry --->
			<cfset oCacheService = createObject("component","homePortals.components.cacheService").init(1, 0)>
			<cfset oCacheRegistry.register(cacheName, oCacheService)>
		</cfif>
	</cflock>
</cffunction>

<cffunction name="getFromCache" access="private">
	<cfset var MAP_FILE = "config/navMenu-config.xml">
	<cfset var filePath = getHomePortals().getConfig().getAppRoot() & "/" & MAP_FILE>
	<cfset var cache = createObject("component","homePortals.components.cacheRegistry").getCache("navMenuCache")>
	<cfset var xmlDoc = 0>

	<cftry>
		<cfset xmlDoc = cache.retrieve("data")>
		<cfcatch type="homePortals.cacheService.itemNotFound">
			<cfif fileExists(expandPath(filePath))>
				<cfset xmlDoc = xmlParse(expandPath(filePath))>
			<cfelse>
				<cfset xmlDoc = xmlNew()>
				<cfset xmlDoc.xmlRoot = xmlElemNew(xmlDoc,"site")>
			</cfif>
			<cfset cache.store("data",xmlDoc)>
		</cfcatch>
	</cftry>
	
	<cfreturn xmlDoc>		
</cffunction>

