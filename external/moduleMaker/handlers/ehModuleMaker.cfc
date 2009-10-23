<cfcomponent extends="ColdBricks.handlers.ehColdBricks">
	
	<cfset pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator")>

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			try {
				oContext = getService("sessionContext").getContext();
				stContRenders = getService("configManager").getAppHomePortalsConfigBean(oContext).getContentRenderers();
				
				setView("vwMain");
				setValue("stContentRenderers",stContRenders);
				setValue("cbPageTitle", "Module Maker");
				setValue("cbPageIcon", "images/configure_48x48-2.png");
				setValue("cbShowSiteMenu", true);
			
			} catch(any e) {
				setMessage("error", e.message);
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspModule" access="public" returntype="void">
		<cfscript>
			var moduleType = getValue("moduleType");
			var isCustom = false;
			var aFields = arrayNew(1);
			
			try {
				setLayout("Layout.None");
				
				oContext = getService("sessionContext").getContext();
				oConfig = getService("configManager").getAppHomePortalsConfigBean(oContext);

				path = oConfig.getContentRenderer(moduleType);
				oCR = createObject("component",path);
				md = duplicate(getMetaData(oCR));
				isCustom = isCustomContentRenderer(oCR);
					
				aFields = [
							{name = "Module ID", token = "$MODULE_ID$"},
							{name = "Module Title", token = "$MODULE_TITLE$"},
							{name = "Module Icon", token = "$MODULE_ICON$"},
							{name = "------------", token = ""}
				];	
				
				
				if(structKeyExists(md,"properties")) {
					for(i=1;i lte arrayLen(md.properties);i++) {
						if(structKeyExists(md.properties[i],"displayName"))
							tmpName = md.properties[i].displayName;
						else
							tmpName = md.properties[i].name;

						if(structKeyExists(md.properties[i],"type") and listfirst(md.properties[i].type,":") eq "resource") {
							rlm = getService("sessionContext").getContext().getHomePortals().getResourceLibraryManager();
							oResType = rlm.getResourceTypeInfo(listLast(md.properties[i].type,":"));
							stResProps = oResType.getProperties();
							
							st = {name = tmpName & ":href", token = "$MODULE_#md.properties[i].name#|href$"};
							arrayAppend(aFields,duplicate(st));

							for(prop in stResProps) {
								st = {name = tmpName & ":" & prop, token = "$MODULE_#md.properties[i].name#|#stResProps[prop].name#$"};
								arrayAppend(aFields,duplicate(st));
							}
							
						} else {
							st = {name = tmpName, token = "$MODULE_#md.properties[i].name#$"};
							arrayAppend(aFields,duplicate(st));
						}
					}
				}
					
				setValue("moduleType",moduleType);
				setValue("isCustom",isCustom);
				setValue("aFields",aFields);
				setValue("tagInfo",md);
				if(isCustom) {
					setValue("head",oCR.getHead());
					setValue("body",oCR.getBody());
				}

				setView("vwModule");
							
			} catch(coldbricks.validation e) {
				setMessage("warning",e.message);

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}				
		</cfscript>
	</cffunction>

	<cffunction name="dspAddModule" access="public" returntype="void">
		<cfscript>
			var oContext = 0;
			var appRoot = 0;
			var path = "";
			
			try {
				oContext = getService("sessionContext").getContext();
				appRoot = oContext.getHomePortals().getConfig().getAppRoot();
				path = appRoot & "/components";

				setValue("path", replace(path,"//","/","ALL"));
				setLayout("Layout.Clean");
				setView("vwAddModule");
							
			} catch(coldbricks.validation e) {
				setMessage("warning",e.message);

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}				
		</cfscript>
	</cffunction>
	
	<cffunction name="dspEditProperty" access="public" returntype="void">
		<cfscript>
			var moduleType = getValue("moduleType");
			var name = getValue("name");
			var oContext = getService("sessionContext").getContext();
			var oConfig = oContext.getHomePortals().getConfig();
			var oAppConfig = 0;
			var propInfo = structNew();
			
			try {
				oAppConfig = getService("configManager").getAppHomePortalsConfigBean(oContext);

				path = oAppConfig.getContentRenderer(moduleType);
				oCR = createObject("component",path);
				md = duplicate(getMetaData(oCR));
				
				if(name neq "" and structKeyExists(md,"properties")) {
					for(i=1;i lte arrayLen(md.properties);i++) {
						if(structKeyExists(md.properties[i],"name") and md.properties[i].name eq name) {
							propInfo = md.properties[i];
							break;
						}
					}
				}

				setLayout("Layout.Clean");
				setValue("moduleType",moduleType);
				setValue("name",name);
				setValue("propInfo",propInfo);
				setValue("stResTypes",oConfig.getResourceTypes());
				setView("vwEditProperty");
							
			} catch(coldbricks.validation e) {
				setMessage("warning",e.message);

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}				
		</cfscript>
	</cffunction>

	<cffunction name="doAddModule" access="public" returntype="void">
		<cfscript>
			var name = getValue("name");
			var path = getValue("path");
			var description = getValue("description");
			var dotpath = "";
			
			try {
				oContext = getService("sessionContext").getContext();
				oConfig = getService("configManager").getAppHomePortalsConfigBean(oContext);

				if(name eq "") throw("Module name cannot be blank","coldbricks.validation");
				if(path eq "") throw("Module path cannot be blank","coldbricks.validation");
				if(reFind("[^A-Za-z0-9_]",name)) 
					throw("Module names can only contain characters from the alphabet, digits and the underscore symbol","coldbricks.validation");

				// create module cfc
				createModule(name,path,description);
					
				// register module
				dotpath = replace(path & "/" & name,"//","/","ALL");
				dotpath = replace(dotpath,"/",".","ALL");
				if(left(dotpath,1) eq ".") dotpath = right(dotpath,len(dotpath)-1);
				
				oConfig.setContentRenderer(name, dotpath);	
				getService("configManager").saveAppHomePortalsConfigBean(oContext, oConfig);
					
				setMessage("info", "Module created");
				setNextEvent("moduleMaker.ehModuleMaker.dspAddModule","done=true");
							
			} catch(coldbricks.validation e) {
				setMessage("warning",e.message);
				setNextEvent("moduleMaker.ehModuleMaker.dspAddModule");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("moduleMaker.ehModuleMaker.dspAddModule");
			}				
		</cfscript>
	</cffunction>

	<cffunction name="doSave" access="public" returntype="void">
		<cfscript>
			var moduleType = getValue("moduleType");
			var description = getValue("hint");
			var body = getValue("body");
			var head = getValue("head");
			var aprops = arrayNew(1);
			
			try {
				oContext = getService("sessionContext").getContext();
				oConfig = getService("configManager").getAppHomePortalsConfigBean(oContext);

				path = oConfig.getContentRenderer(moduleType);
				oCR = createObject("component",path);
				md = duplicate(getMetaData(oCR));
				if(structKeyExists(md,"properties")) {
					aprops = md.properties;
				}

				updateModule(moduleType,getDirectoryFromPath(md.path),hint,body,head,aprops);
				
				setMessage("info", "Module saved");
				setNextEvent("moduleMaker.ehModuleMaker.dspMain","moduleType=#moduleType#");
							
			} catch(coldbricks.validation e) {
				setMessage("warning",e.message);
				setNextEvent("moduleMaker.ehModuleMaker.dspMain","moduleType=#moduleType#");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("moduleMaker.ehModuleMaker.dspMain","moduleType=#moduleType#");
			}				
		</cfscript>
	</cffunction>

	<cffunction name="doDelete" access="public" returntype="void">
		<cfscript>
			var moduleType = getValue("moduleType");
			
			try {
				oContext = getService("sessionContext").getContext();
				oConfig = getService("configManager").getAppHomePortalsConfigBean(oContext);
	
				if(moduleType eq "") throw("Module name cannot be blank","coldbricks.validation");

				path = oConfig.getContentRenderer(moduleType);
				oCR = createObject("component",path);
				md = duplicate(getMetaData(oCR));
				
				deleteModule(moduleType, getDirectoryFromPath(md.path));
				
				oConfig.removeContentRenderer(moduleType);
				getService("configManager").saveAppHomePortalsConfigBean(oContext, oConfig);
				
				setMessage("info", "Module deleted");
				setNextEvent("moduleMaker.ehModuleMaker.dspMain");
							
			} catch(coldbricks.validation e) {
				setMessage("warning",e.message);
				setNextEvent("moduleMaker.ehModuleMaker.dspMain","moduleType=#moduleType#");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("moduleMaker.ehModuleMaker.dspMain","moduleType=#moduleType#");
			}				
		</cfscript>
	</cffunction>

	<cffunction name="doSaveProperty" access="public" returntype="void">
		<cfscript>
			var moduleType = getValue("moduleType");
			var isNewProp = getValue("isNewProp");
			var name = getValue("name");
			var type = getValue("type");
			var aprops = arrayNew(1);
			var desc = "";
			
			try {
				oContext = getService("sessionContext").getContext();
				oConfig = getService("configManager").getAppHomePortalsConfigBean(oContext);

				if(name eq "") throw("The module property name is required","coldbricks.validation");
				if(type eq "") throw("The module property type is required","coldbricks.validation");
				if(type eq "resource") type = "resource:" & getValue("resourceType");

				path = oConfig.getContentRenderer(moduleType);
				oCR = createObject("component",path);
				md = duplicate(getMetaData(oCR));
				if(structKeyExists(md,"properties")) {
					for(i=1;i lte arrayLen(md.properties);i++) {
						st = duplicate(md.properties[i]);
						arrayAppend(aProps,st);
					}
				}
				if(structKeyExists(md,"hint")) {
					desc = md.hint;
				}
							
				st = structNew();
				st.name = name;
				st.type = type;
				st.values = getValue("values");
				st.resourceType = getValue("resourceType");
				st.default = getValue("default");
				st.displayName = getValue("displayName");
				st.required = getValue("required",false);
				st.hint = getValue("hint");
							
				if(isNewProp) {
					arrayAppend(aProps,st);
				} else {
					for(i=1;i lte arrayLen(md.properties);i++) {
						if(structKeyExists(md.properties[i],"name") and md.properties[i].name eq name) {
							aprops[i] = st;
							break;
						}
					}
				}

				updateModule(moduleType,getDirectoryFromPath(md.path),desc,oCR.getBody(),oCR.getHead(),aprops);

				setMessage("info", "Module saved");
				setNextEvent("moduleMaker.ehModuleMaker.dspEditProperty","done=true&moduleType=#moduleType#");
							
			} catch(coldbricks.validation e) {
				setMessage("warning",e.message);
				setNextEvent("moduleMaker.ehModuleMaker.dspEditProperty","moduleType=#moduleType#");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("moduleMaker.ehModuleMaker.dspEditProperty","moduleType=#moduleType#");
			}				
		</cfscript>
	</cffunction>

	<cffunction name="doDeleteProperty" access="public" returntype="void">
		<cfscript>
			var moduleType = getValue("moduleType");
			var name = getValue("name");
			var aprops = arrayNew(1);
			
			try {
				oContext = getService("sessionContext").getContext();
				oConfig = getService("configManager").getAppHomePortalsConfigBean(oContext);

				path = oConfig.getContentRenderer(moduleType);
				oCR = createObject("component",path);
				md = duplicate(getMetaData(oCR));
				if(structKeyExists(md,"properties")) {
					for(i=1;i lte arrayLen(md.properties);i++) {
						st = duplicate(md.properties[i]);
						arrayAppend(aProps,st);
					}
				}
				if(structKeyExists(md,"hint")) {
					desc = md.hint;
				}

				for(i=1;i lte arrayLen(md.properties);i++) {
					if(structKeyExists(md.properties[i],"name") and md.properties[i].name eq name) {
						arrayDeleteAt(aProps,i);
						break;
					}
				}

				updateModule(moduleType,getDirectoryFromPath(md.path),desc,oCR.getBody(),oCR.getHead(),aprops);
				
				setMessage("info", "Module property deleted");
				setNextEvent("moduleMaker.ehModuleMaker.dspMain","moduleType=#moduleType#");
							
			} catch(coldbricks.validation e) {
				setMessage("warning",e.message);
				setNextEvent("moduleMaker.ehModuleMaker.dspMain","moduleType=#moduleType#");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("moduleMaker.ehModuleMaker.dspMain","moduleType=#moduleType#");
			}				
		</cfscript>
	</cffunction>
	
	<!---- utilities ---->

	<cffunction name="createModule" access="private" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfargument name="description" type="string" required="true">
		<cfset var tmppath = expandPath(arguments.path & "/" & arguments.name & ".cfc")>
		<cfset var txt = "<cfcomponent extends=""homePortals.components.contentTagRenderers.custom"" hint=""#xmlFormat(arguments.description)#""></cfcomponent>">
		<cfif not directoryExists(expandPath(arguments.path))>
			<cfdirectory action="create" directory="#expandPath(arguments.path)#">
		</cfif>
		<cffile action="write" output="#txt#" file="#tmppath#">
		<cfset reloadSite()>
	</cffunction>

	<cffunction name="updateModule" access="private" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfargument name="description" type="string" required="true">
		<cfargument name="body" type="string" required="true">
		<cfargument name="head" type="string" required="true">
		<cfargument name="properties" type="array" required="true">
		
		<cfset var tmppath = arguments.path & arguments.name & ".cfc">
		<cfset var txt = "">
		<cfset var crlf = chr(13) & chr(10)>
		<cfset var tab = chr(9)>
		<cfset var i = 0>
		<cfset var thisProp = 0>

		<cfset var tmpBodyPath = arguments.path & arguments.name & "_body.inc">
		<cfset var tmpHeadPath = arguments.path & arguments.name & "_head.inc">

		<cfset txt = "<cfcomponent extends=""homePortals.components.contentTagRenderers.custom"" hint=""#xmlFormat(arguments.description)#"">" & crlf>
		<cfloop from="1" to="#arrayLen(arguments.properties)#" index="i">
			<cfset thisProp = arguments.properties[i]>
			<cfparam name="thisProp.name" default="">
			<cfparam name="thisProp.type" default="">
			<cfparam name="thisProp.hint" default="">
			<cfparam name="thisProp.required" default="">
			<cfparam name="thisProp.default" default="">
			<cfparam name="thisProp.displayName" default="">
			<cfparam name="thisProp.values" default="">
			
			<cfset txt = txt & tab & "<cfproperty name=""#thisProp.name#"" type=""#thisProp.type#""">
			<cfif thisProp.hint neq "">
				<cfset txt = txt & " hint=""#xmlFormat(thisProp.hint)#""">
			</cfif>
			<cfif thisProp.required neq "">
				<cfset txt = txt & " required=""#thisProp.required#""">
			</cfif>
			<cfif thisProp.values neq "">
				<cfset txt = txt & " values=""#thisProp.values#""">
			</cfif>
			<cfif thisProp.default neq "" or thisProp.default eq "" and (isBoolean(thisProp.required) and thisProp.required)>
				<cfset txt = txt & " default=""#thisProp.default#""">
			</cfif>
			<cfif thisProp.displayName neq "">
				<cfset txt = txt & " displayName=""#thisProp.displayName#""">
			</cfif>
			<cfset txt = txt & ">" & crlf>
		</cfloop>
		<cfset txt = txt & "</cfcomponent>">

		<cffile action="write" output="#txt#" file="#tmppath#">
		<cffile action="write" output="#arguments.body#" file="#tmpBodyPath#">
		<cffile action="write" output="#arguments.head#" file="#tmpHeadPath#">
		
		<cfset reloadSite()>
	</cffunction>
	
	<cffunction name="deleteModule" access="private" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfset var tmpFilepath = expandPath(arguments.path & "/" & arguments.name & ".cfc")>
		<cfset var tmpBodyPath = expandPath(arguments.path & "/" & arguments.name & "_body.inc")>
		<cfset var tmpHeadPath = expandPath(arguments.path & "/" & arguments.name & "_head.inc")>

		<cfif fileExists(tmpFilepath)>
			<cffile action="delete" file="#tmpFilepath#">
		</cfif>
		<cfif fileExists(tmpBodyPath)>
			<cffile action="delete" file="#tmpBodyPath#">
		</cfif>
		<cfif fileExists(tmpHeadPath)>
			<cffile action="delete" file="#tmpHeadPath#">
		</cfif>
		
		<cfset reloadSite()>
	</cffunction>	
			
	<cffunction name="isCustomContentRenderer" access="public" returntype="boolean">
		<cfargument name="obj" type="any" required="true">
		<cftry>
			<cfset __dummy_check_type__(arguments.obj)>
			<cfreturn true>
			<cfcatch type="any">
				<cfreturn false>
			</cfcatch>
		</cftry>
	</cffunction>	
	
	<cffunction name="__dummy_check_type__" access="private" returntype="void">
		<cfargument name="obj" type="homePortals.components.contentTagRenderers.custom" required="true">
		<!--- nothing ---->
		<cfreturn>
	</cffunction>
		
</cfcomponent>