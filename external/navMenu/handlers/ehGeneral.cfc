<cfcomponent extends="ColdBricks.handlers.ehColdBricks">

	<cfset variables.MAP_FILE = "config/navMenu-config.xml">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var lst = "";
			var aPathItems = arrayNew(1);
			var aPaths = arrayNew(1);
			var path = getValue("path");
			var edit = getValue("edit");
			var itemName = getValue("itemName");
			var itemURL = getValue("itemURL");

			try {
				xmlDoc = loadNavMap();
				
				xmlBase = xmlDoc.xmlRoot;
				for(i=1;i lte listLen(path);i++) {
					if(listGetAt(path,i) gt 0) {
						xmlBase = xmlBase.xmlChildren[ listGetAt(path,i) ];
						lst = listAppend(lst, listGetAt(path,i) );
						arrayAppend(aPathItems,xmlBase.xmlAttributes.title);
						arrayAppend(aPaths,lst);
					}
				}
					
				if(edit neq "") {
					xmlEditBase = xmlDoc.xmlRoot;
					for(i=1;i lte listLen(edit);i++) {
						if(listGetAt(edit,i) gt 0) {
							xmlEditBase = xmlEditBase.xmlChildren[ listGetAt(edit,i) ];
							itemName = xmlEditBase.xmlAttributes.title;
							itemURL = xmlEditBase.xmlAttributes.href;
						} else {
							itemName = "";
							itemURL = "";
						}
					}
				}	
					
				setValue("path", path );
				setValue("xmlBase", xmlBase );
				setValue("aPathItems", aPathItems );
				setValue("aPaths", aPaths );
				setValue("itemName", itemName );
				setValue("itemURL", itemURL );
				
				setValue("cbPageTitle", "NavMenu");
				setValue("cbPageIcon", "images/cb-blocks.png");
				setValue("cbShowSiteMenu", true);
				setView("vwMain");

			} catch(any e) {
				setMessage("error",e.message);
				setNextEvent("ehGeneral.dspMain");			
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSaveItem" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var itemName = getValue("name");
			var itemURL = getValue("url");
			var str = "xmlDoc.xmlRoot";
			var newpath = "";

			try {
				xmlDoc = loadNavMap();
				
				for(i=1;i lte listLen(path);i++) {
					if(listGetAt(path,i) gt 0) {
						str = str & ".xmlChildren[" & listGetAt(path,i) & "]";
						if(i lt listLen(path)) newpath = listAppend(newpath, listGetAt(path,i));
					}
				}
				xmlNode = evaluate(str);
				
				if(itemName eq "") {
					setMessage("warning","Item name cannot be empty");
					setNextEvent("navMenu.ehGeneral.dspMain&path=#newpath#");
				}
				
				if(listLast(path) eq 0 or path eq "") {
					xmlNew = xmlElemNew(xmlDoc,"item");
					xmlNew.xmlAttributes["title"] = xmlFormat(itemName);
					xmlNew.xmlAttributes["href"] = xmlFormat(itemURL);
					arrayAppend(xmlNode.xmlChildren, xmlNew);
					newpath = path;
					
				} else {
					xmlNode.xmlAttributes.title = xmlFormat(itemName);
					xmlNode.xmlAttributes.href = xmlFormat(itemURL);
				}
	
				saveNavMap(xmlDoc);	
				
				setMessage("info","Element saved");
				setNextEvent("navMenu.ehGeneral.dspMain&path=#newpath#");

			} catch(any e) {
				setMessage("error",e.message);
				setNextEvent("navMenu.ehGeneral.dspMain");			
			}		
		</cfscript>
	</cffunction>
	
	<cffunction name="doDeleteItem" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var str = "xmlDoc.xmlRoot";
			var newpath = "";

			try {
				xmlDoc = loadNavMap();
				
				for(i=1;i lt listLen(path);i++) {
					if(listGetAt(path,i) gt 0) {
						str = str & ".xmlChildren[" & listGetAt(path,i) & "]";
						newpath = listAppend(newpath, listGetAt(path,i));
					}
				}
				xmlNode = evaluate(str);
				
				arrayDeleteAt(xmlNode.xmlChildren,listLast(path));
	
				saveNavMap(xmlDoc);	
				
				setMessage("info","Element deleted");
				setNextEvent("navMenu.ehGeneral.dspMain&path=#newpath#");

			} catch(any e) {
				setMessage("error",e.message);
				setNextEvent("navMenu.ehGeneral.dspMain");			
			}		
		</cfscript>	
	</cffunction>

	<cffunction name="doMoveUp" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var str = "xmlDoc.xmlRoot";
			var newpath = "";

			try {
				xmlDoc = loadNavMap();
				
				for(i=1;i lt listLen(path);i++) {
					if(listGetAt(path,i) gt 0) {
						str = str & ".xmlChildren[" & listGetAt(path,i) & "]";
						newpath = listAppend(newpath, listGetAt(path,i));
					}
				}
				xmlNode = evaluate(str);
	
				if(listLast(path) lt 2) {
					setMessage("warning","Element already at first position");
					setNextEvent("navMenu.ehGeneral.dspMain&path=#newpath#");
				}
				
				nodeCopy = duplicate( xmlNode.xmlChildren[listLast(path)] );

				arrayDeleteAt(xmlNode.xmlChildren,listLast(path));
				arrayInsertAt(xmlNode.xmlChildren,listLast(path)-1,nodeCopy);

				saveNavMap(xmlDoc);	
				
				setMessage("info","Element moved");
				setNextEvent("navMenu.ehGeneral.dspMain&path=#newpath#");

			} catch(any e) {
				setMessage("error",e.message);
				setNextEvent("navMenu.ehGeneral.dspMain");			
			}		
		</cfscript>	
	</cffunction>

	<cffunction name="doMoveDown" access="public" returntype="void">
		<cfscript>
			var path = getValue("path");
			var str = "xmlDoc.xmlRoot";
			var newpath = "";

			try {
				xmlDoc = loadNavMap();
				
				for(i=1;i lt listLen(path);i++) {
					if(listGetAt(path,i) gt 0) {
						str = str & ".xmlChildren[" & listGetAt(path,i) & "]";
						newpath = listAppend(newpath, listGetAt(path,i));
					}
				}
				xmlNode = evaluate(str);
	
				if(listLast(path) eq arrayLen(xmlNode.xmlChildren)) {
					setMessage("warning","Element already at last position");
					setNextEvent("navMenu.ehGeneral.dspMain&path=#newpath#");
				}

				nodeCopy = duplicate( xmlNode.xmlChildren[listLast(path)] );
		
				arrayDeleteAt(xmlNode.xmlChildren,listLast(path));
				arrayInsertAt(xmlNode.xmlChildren,listLast(path)+1,nodeCopy);

				saveNavMap(xmlDoc);	
				
				setMessage("info","Element moved");
				setNextEvent("navMenu.ehGeneral.dspMain&path=#newpath#");

			} catch(any e) {
				setMessage("error",e.message);
				setNextEvent("navMenu.ehGeneral.dspMain");			
			}		
		</cfscript>	
	</cffunction>


	<!--- Private Methods --->
	
	<cffunction name="loadNavMap" access="private" returntype="xml">
		<cfscript>
			var path = getNavMapPath();
			var xmlDoc = 0;
			
			if(fileExists(expandPath(path))) {
				xmlDoc = xmlParse(expandPath(path));
			} else {
				xmlDoc = xmlNew();
				xmlDoc.xmlRoot = xmlElemNew(xmlDoc,"site");
			}
			
			return xmlDoc;
		</cfscript>
	</cffunction>

	<cffunction name="saveNavMap" access="private" returntype="void">
		<cfargument name="xmlDoc" type="xml" required="true">
		<cfset var path = getNavMapPath()>
		<cflock name="navMenu_savefile_lock" type="exclusive" timeout="10">
			<!---
			<cfset var oFormatter = createObject("component","ColdBricks.components.xmlStringFormatter").init()>
			<cfset fileWrite(expandPath(path), oFormatter.makePretty(arguments.xmlDoc.xmlRoot), "utf-8") >
			--->
			<cfset fileWrite(expandPath(path), toString(arguments.xmlDoc), "utf-8") >
		</cflock>
	</cffunction>

	<cffunction name="getNavMapPath" access="private" returntype="string">
		<cfscript>
			var oSiteInfo = getService("sessionContext").getContext().getSiteInfo();
			var path = oSiteInfo.getPath();
			if(right(path,1) neq "/") path = path & "/";
			path  = path & variables.MAP_FILE;
			return path;
		</cfscript>
	</cffunction>

</cfcomponent>