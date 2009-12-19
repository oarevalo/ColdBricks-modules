<cfcomponent extends="homePortals.components.contentTagRenderer" hint="Renders a hierarchical navigation menu. Use the navMenu ColdBricks module to manage the menu items">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	

		<cfset var xmlDoc = 0>
		<cfset var tmpHTMLHead = "">
		<cfset var tmpHTMLBody = "">

		<cfset checkCache()>
		<cfset xmlDoc = getFromCache()>
		
		<cfsavecontent variable="tmpHTMLHead">
			<script type="text/javascript" src="/ColdBricksModules/navMenu/site/navMenu.js"></script>
		</cfsavecontent>
		
		<cfsavecontent variable="tmpHTMLBody">
			<cfoutput>
				<div class="sidebarmenu">
					#renderBranch(xmlDoc.xmlRoot,"sidebarmenu1")#
				</div>
			</cfoutput>
		</cfsavecontent>
		
		<cfset arguments.headContentBuffer.set( tmpHTMLHead )>
		<cfset arguments.bodyContentBuffer.set( tmpHTMLBody )>
	
	</cffunction>

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

</cfcomponent>


