<cfcomponent extends="ColdBricks.handlers.ehColdBricks">

	<cfset variables.RESOURCE_TYPE = "outline">
	<cfset variables.RESOURCE_TYPE_FOLDER = "Outlines">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var lst = "";
			var aPathItems = arrayNew(1);
			var aPaths = arrayNew(1);
			var path = getValue("path");
			var edit = getValue("edit");
			var itemName = getValue("itemName");
			var itemURL = getValue("itemURL");
			var hp = getService("sessionContext").getContext().getHomePortals();
			var nodeAttributes = structNew();
	
			try {
				hasType = hp.getResourceLibraryManager().hasResourceType(variables.RESOURCE_TYPE);
				if(hasType) {
					qryResources = hp.getCatalog().getResourcesByType(variables.RESOURCE_TYPE);
					setValue("qryResources", qryResources );
				} else {
					setNextEvent("outlineEditor.ehGeneral.dspSetup");
				}

				if(qryResources.recordCount eq 0) {
					setMessage("warning","There are no resources of type '#variables.RESOURCE_TYPE#'. Please create at least one before using the Outline Editor");
					setNextEvent("resources.ehResources.dspMain","resourceType=#variables.RESOURCE_TYPE#");
				}

				xmlDoc = loadDoc();
				
				xmlBase = xmlDoc.xmlRoot.body;
				for(i=1;i lte listLen(path);i++) {
					if(listGetAt(path,i) gt 0) {
						xmlBase = xmlBase.xmlChildren[ listGetAt(path,i) ];
						lst = listAppend(lst, listGetAt(path,i) );
						arrayAppend(aPathItems,xmlBase.xmlAttributes.text);
						arrayAppend(aPaths,lst);
					}
				}
					
				if(edit neq "") {
					xmlEditBase = xmlDoc.xmlRoot.body;
					for(i=1;i lte listLen(edit);i++) {
						if(listGetAt(edit,i) gt 0) {
							xmlEditBase = xmlEditBase.xmlChildren[ listGetAt(edit,i) ];
							itemName = xmlEditBase.xmlAttributes.text;
							itemURL = xmlEditBase.xmlAttributes.href;
							nodeAttributes = duplicate(xmlEditBase.xmlAttributes);
						} else {
							itemName = "";
							itemURL = "";
						}
					}
				}	
				
				if(structKeyExists(session,"outlineEditor_selResID")) 
					setValue("selectedResourceID", session.outlineEditor_selResID);	
				setValue("path", path );				
				setValue("xmlBase", xmlBase );
				setValue("aPathItems", aPathItems );
				setValue("aPaths", aPaths );
				setValue("itemName", itemName );
				setValue("itemURL", itemURL );
				setValue("nodeAttributes", nodeAttributes );
				
				setValue("cbPageTitle", "Outline Editor");
				setValue("cbPageIcon", "/ColdBricksModules/outlineEditor/images/view-tree.png");
				setValue("cbShowSiteMenu", true);
				setView("vwMain");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehGeneral.dspMain");			
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="dspSetup" access="public" returntype="void">
		<cfscript>
			try {
				setValue("resourceType", variables.RESOURCE_TYPE);
				setValue("cbPageTitle", "Outline Editor - Setup");
				setValue("cbPageIcon", "/ColdBricksModules/outlineEditor/images/view-tree.png");
				setValue("cbShowSiteMenu", true);
				setView("vwSetup");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehGeneral.dspMain");			
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSaveItem" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var itemName = getValue("name");
			var itemURL = getValue("url");
			var attributes = getValue("attributes");
			var str = "xmlDoc.xmlRoot.body";
			var newpath = "";

			try {
				xmlDoc = loadDoc();
				
				for(i=1;i lte listLen(path);i++) {
					if(listGetAt(path,i) gt 0) {
						str = str & ".xmlChildren[" & listGetAt(path,i) & "]";
						if(i lt listLen(path)) newpath = listAppend(newpath, listGetAt(path,i));
					}
				}
				xmlNode = evaluate(str);
				
				if(itemName eq "") {
					setMessage("warning","Item name cannot be empty");
					setNextEvent("outlineEditor.ehGeneral.dspMain&path=#newpath#");
				}
				
				if(listLast(path) eq 0 or path eq "") {
					xmlNew = xmlElemNew(xmlDoc,"outline");
					xmlNew.xmlAttributes["text"] = xmlFormat(itemName);
					xmlNew.xmlAttributes["href"] = xmlFormat(itemURL);
					
					if(getValue("newAttr_name") neq "") {
						xmlNew.xmlAttributes[ getValue("newAttr_name") ] = xmlFormat( getValue("newAttr_value") );
					}
					
					arrayAppend(xmlNode.xmlChildren, xmlNew);
					newpath = path;
					
				} else {
					xmlNode.xmlAttributes.text = xmlFormat(itemName);
					xmlNode.xmlAttributes.href = xmlFormat(itemURL);
					for(i=1;i lte listLen(attributes);i++) {
						attr = listGetAt(attributes,i);
						if(not listFindNoCase("text,href",attr)) {
							xmlNode.xmlAttributes[attr] = xmlFormat(getValue(attr));

							if(getValue(attr & "_delete",false) and structKeyExists(xmlNode.xmlAttributes,attr)){
								structDelete(xmlNode.xmlAttributes,attr);
							}
						}
					}
					if(getValue("newAttr_name") neq "") {
						xmlNode.xmlAttributes[ getValue("newAttr_name") ] = xmlFormat( getValue("newAttr_value") );
					}
				}
	
				saveDoc(xmlDoc);	
				
				setMessage("info","Element saved");
				setNextEvent("outlineEditor.ehGeneral.dspMain&path=#newpath#");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("outlineEditor.ehGeneral.dspMain");			
			}		
		</cfscript>
	</cffunction>
	
	<cffunction name="doDeleteItem" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var str = "xmlDoc.xmlRoot.body";
			var newpath = "";

			try {
				xmlDoc = loadDoc();
				
				for(i=1;i lt listLen(path);i++) {
					if(listGetAt(path,i) gt 0) {
						str = str & ".xmlChildren[" & listGetAt(path,i) & "]";
						newpath = listAppend(newpath, listGetAt(path,i));
					}
				}
				xmlNode = evaluate(str);
				
				arrayDeleteAt(xmlNode.xmlChildren,listLast(path));
	
				saveDoc(xmlDoc);	
				
				setMessage("info","Element deleted");
				setNextEvent("outlineEditor.ehGeneral.dspMain&path=#newpath#");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("outlineEditor.ehGeneral.dspMain");			
			}		
		</cfscript>	
	</cffunction>

	<cffunction name="doMoveUp" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var str = "xmlDoc.xmlRoot.body";
			var newpath = "";

			try {
				xmlDoc = loadDoc();
				
				for(i=1;i lt listLen(path);i++) {
					if(listGetAt(path,i) gt 0) {
						str = str & ".xmlChildren[" & listGetAt(path,i) & "]";
						newpath = listAppend(newpath, listGetAt(path,i));
					}
				}
				xmlNode = evaluate(str);
	
				if(listLast(path) lt 2) {
					setMessage("warning","Element already at first position");
					setNextEvent("outlineEditor.ehGeneral.dspMain&path=#newpath#");
				}
				
				nodeCopy = duplicate( xmlNode.xmlChildren[listLast(path)] );

				arrayDeleteAt(xmlNode.xmlChildren,listLast(path));
				arrayInsertAt(xmlNode.xmlChildren,listLast(path)-1,nodeCopy);

				saveDoc(xmlDoc);	
				
				setMessage("info","Element moved");
				setNextEvent("outlineEditor.ehGeneral.dspMain&path=#newpath#");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("outlineEditor.ehGeneral.dspMain");			
			}		
		</cfscript>	
	</cffunction>

	<cffunction name="doMoveDown" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var str = "xmlDoc.xmlRoot.body";
			var newpath = "";

			try {
				xmlDoc = loadDoc();
				
				for(i=1;i lt listLen(path);i++) {
					if(listGetAt(path,i) gt 0) {
						str = str & ".xmlChildren[" & listGetAt(path,i) & "]";
						newpath = listAppend(newpath, listGetAt(path,i));
					}
				}
				xmlNode = evaluate(str);
	
				if(listLast(path) eq arrayLen(xmlNode.xmlChildren)) {
					setMessage("warning","Element already at last position");
					setNextEvent("outlineEditor.ehGeneral.dspMain&path=#newpath#");
				}

				nodeCopy = duplicate( xmlNode.xmlChildren[listLast(path)] );

				arrayDeleteAt(xmlNode.xmlChildren,listLast(path));
				arrayInsertAt(xmlNode.xmlChildren,listLast(path)+1,nodeCopy);

				saveDoc(xmlDoc);	
				
				setMessage("info","Element moved");
				setNextEvent("outlineEditor.ehGeneral.dspMain&path=#newpath#");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("outlineEditor.ehGeneral.dspMain");			
			}		
		</cfscript>	
	</cffunction>

	<cffunction name="doSetup" access="public" returntype="void">
		<cfscript>
			try {
				oContext = getService("sessionContext").getContext();
				oConfig = getService("configManager").getAppHomePortalsConfigBean(oContext);
				stLibTypes = oConfig.getResourceLibraryTypes();

				oConfig.setResourceType(name = variables.RESOURCE_TYPE,
										folderName = variables.RESOURCE_TYPE_FOLDER,
										fileTypes = "opml");	
		
 				getService("configManager").saveAppHomePortalsConfigBean(oContext, oConfig);
 				
 				reloadSite();
 			
				setMessage("info","Outline resource setup");
				setNextEvent("outlineEditor.ehGeneral.dspMain");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("outlineEditor.ehGeneral.dspSetup");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSetResource" access="public" returntype="void">
		<cfscript>
			var resID = getValue("resID");
			var hp = getService("sessionContext").getContext().getHomePortals();
			
			try {
				if(resID neq "") {
					resLib = hp.getResourceLibraryManager().getResourceLibrary(listFirst(resID,"|"));
					oResourceBean = resLib.getResource(variables.RESOURCE_TYPE, listGetAt(resID,2,"|"), listLast(resID,"|"));
					session.outlineEditor_selRes = oResourceBean;
					session.outlineEditor_selResID = resID;
				} else {
					structDelete(session,"outlineEditor_selRes");
					structDelete(session,"outlineEditor_selResID");
				}
				setNextEvent("outlineEditor.ehGeneral.dspMain");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("outlineEditor.ehGeneral.dspMain");
			}
		</cfscript>	
	</cffunction>


	<!--- Private Methods --->
	
	<cffunction name="loadDoc" access="private" returntype="xml">
		<cfscript>
			var path = getDocPath();
			var xmlDoc = 0;
			
			if(fileExists(expandPath(path))) {
				xmlDoc = xmlParse(expandPath(path));
			} else {
				xmlDoc = xmlNew();
				xmlDoc.xmlRoot = xmlElemNew(xmlDoc,"opml");
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc,"head"));
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc,"body"));
			}
			
			return xmlDoc;
		</cfscript>
	</cffunction>

	<cffunction name="saveDoc" access="private" returntype="void">
		<cfargument name="xmlDoc" type="xml" required="true">
		<cfset var oFormatter = createObject("component","ColdBricks.components.xmlStringFormatter").init()>
		<cfset var resBean = session.outlineEditor_selRes>
		<cfset resBean.saveFile( resBean.getID() & ".opml", oFormatter.makePretty(arguments.xmlDoc.xmlRoot) )>
	</cffunction>

	<cffunction name="getDocPath" access="private" returntype="string">
		<cfscript>
			var path = "";
			
			if(structKeyExists(session,"outlineEditor_selRes")) {
				path = session.outlineEditor_selRes.getFullHREF();
			}
			
			return path;
		</cfscript>
	</cffunction>


</cfcomponent>