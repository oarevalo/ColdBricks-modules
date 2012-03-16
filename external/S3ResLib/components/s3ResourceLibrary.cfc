<cfcomponent implements="homePortals.components.resourceLibrary">

	<cfscript>
		variables.resourceDescriptorFile = "info.xml";
		variables.resourcesRoot = "";
		variables.resourceTypeRegistry = 0;
		variables.s3 = 0;
		variables.bucket = "";
		variables.stTimers = structNew();
		variables.HTTP_TIMEOUT = 60;
		variables.s3Key = "";
		variables.s3Secret = "";
	</cfscript>
	
	<cffunction name="init" returntype="homePortals.components.resourceLibrary" access="public" hint="This is the constructor">
		<cfargument name="resourceLibraryPath" type="string" required="true">
		<cfargument name="resourceTypeRegistry" type="homePortals.components.resourceTypeRegistry" required="true">
		<cfargument name="configStruct" type="struct" required="true">
		<cfset variables.resourcesRoot = arguments.resourceLibraryPath>
		<cfset variables.resourceTypeRegistry = arguments.resourceTypeRegistry>
		<cfset variables.bucket = replace(arguments.resourceLibraryPath,"s3://","")>
		<cfif structKeyExists(arguments.configStruct,"key")>
			<cfset variables.s3Key = arguments.configStruct.key>
		</cfif>
		<cfif structKeyExists(arguments.configStruct,"secret")>
			<cfset variables.s3Secret = arguments.configStruct.secret>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="getResourceTypeRegistry" access="public" returntype="homePortals.components.resourceTypeRegistry" hint="returns a reference to the registry for resource types">
		<cfreturn variables.resourceTypeRegistry>
	</cffunction>

	<cffunction name="getResourcePackagesList" returntype="query" access="public" hint="returns a query with the names of all resource packages">
		<cfargument name="resourceType" type="string" required="false" default="">
		<cfscript>
			var qry = QueryNew("ResType,Name");
			var reg = getResourceTypeRegistry();
			var tmpDir = "";
			var start = getTickCount();
			var res = "";
			var aItems = arrayNew(1);
			var i = 0;
			var j = 0;
			var aResTypes = arrayNew(1);
			
			if(arguments.resourceType neq "")
				aResTypes[1] = arguments.resourceType;
			else
				aResTypes = reg.getResourceTypes();

			for(i=1;i lte arrayLen(aResTypes);i=i+1) {
				res = aResTypes[i];
				tmpDir =  reg.getResourceType(res).getFolderName() & "/";
				
				aItems = getS3().getBucket(variables.bucket, tmpDir);

				if(isArray(aItems)) {
					for (j=1;j lte arraylen(aItems); j=j+1){
					   name = aItems[j].key;
					   if(listLen(name,"/") eq 2 and find("_$folder$",name)) {
					   		queryAddRow(qry);
					   		querySetCell(qry,"resType",res);
					   		querySetCell(qry,"name",listFirst(listLast(name,"/"),"_"));
					   }
					}				
				}
			}
			
			variables.stTimers.getResourcePackagesList = getTickCount()-start;
			
			return qry;
		</cfscript>
	</cffunction>
	
	<cffunction name="getResourcesInPackage" access="public" returntype="Array" hint="returns all resources on a package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfscript>
			var aResources = arrayNew(1);
			var start = getTickCount();
			var oResourceBean = 0;
			
			// check if there is a resource descriptor for the package
			if(hasResourceDescriptor(arguments.resourceType, arguments.packageName)) {
				// resource descriptor exists, so read all resources on the descriptor
				aResources = getResourcesInDescriptorFile(arguments.resourceType, arguments.packageName);
			} else {
				// no resource descriptor, so register resources based on package name
				// this will only register ONE resource per package
				oResourceBean = getDefaultResourceInPackage(arguments.resourceType, arguments.packageName);
				if(not isSimpleValue(oResourceBean)) arrayAppend(aResources, oResourceBean);
			}

			variables.stTimers.getResourcesInPackage = getTickCount()-start;
			return aResources;
		</cfscript>
	</cffunction>
	
	<cffunction name="getResource" access="public" returntype="homePortals.components.resourceBean" hint="returns the resource bean for the given resource">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfargument name="resourceID" type="string" required="true">
		<cfscript>
			var oResourceBean = 0; var o = 0;
			var start = getTickCount();
			var aResources = arrayNew(1);
			
			// check that resourceID is not empty
			if(arguments.resourceID eq "") throwException("Resource ID cannot be blank","HomePortals.resourceLibrary.blankResourceID");
			
			// check if there is a resource descriptor for the package
			if(hasResourceDescriptor(arguments.resourceType, arguments.packageName)) {
				// resource descriptor exists, so read the resource from the descriptor
				aResources = getResourcesInDescriptorFile(arguments.resourceType, arguments.packageName, arguments.resourceID);
				if(arrayLen(aResources) gt 0) {
					oResourceBean = aResources[1];
				}
			} else {
				// no resource descriptor, so create resource based on package name
				oResourceBean = getDefaultResourceInPackage(arguments.resourceType, arguments.packageName);
			}
			
			if( isSimpleValue(oResourceBean) ) {
				throwException("The requested resource [#arguments.packageName#][#arguments.resourceID#] was not found",
						"homePortals.resourceLibrary.resourceNotFound");
			}

			variables.stTimers.getResource = getTickCount()-start;
			return oResourceBean;
		</cfscript>
	</cffunction>

	<cffunction name="saveResource" access="public" returntype="void" hint="Adds or updates a resource in the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true" hint="the resource to add or update"> 		
		<cfscript>
			var href = "";
			var packageDir = "";
			var resDir = "";
			var reg = getResourceTypeRegistry();
			var rb = arguments.resourceBean;
			var resType = rb.getType();
			var resTypeDir = reg.getResourceType(resType).getFolderName();
			var xmlNode = 0;
			var infoHREF = "";
		
			// validate bean			
			if(rb.getID() eq "") throwException("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(rb.getType() eq "") throwException("No resource type has been specified for the resource","homePortals.resourceLibrary.validation");
			if(rb.getPackage() eq "") throwException("No package has been specified for the resource","homePortals.resourceLibrary.validation");
			if(not reg.hasResourceType(resType)) throwException("The resource type is invalid or not supported","homePortals.resourceLibrary.invalidResourceType");

			// get location of descriptor file
			infoHREF = getResourceDescriptorFilePath( rb.getType(), rb.getPackage() );

			// setup directories

			// check if we need to create the res type directory
			resDir = variables.resourcesRoot & "/" & resTypeDir;
		/*	if(not directoryExists(expandPath(resDir))) {
				createDir( resDir );
			}*/

			// check if we need to create the package directory
			packageDir = resDir & "/" & rb.getPackage();
		/*	if(not directoryExists(expandPath(packageDir))) {
				createDir( packageDir );
			}*/

			// check for file descriptor, if doesnt exist, then create one
			if(s3FileExists(infoHREF)) {
				xmlDoc = getResourceDescriptor(rb.getType(), rb.getPackage());
			} else {
				// create file descriptor
				xmlDoc = xmlNew();
				xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "resLib");
				xmlDoc.xmlRoot.xmlAttributes["type"] = rb.getType();
			}
			
			// check if we need to update the file descriptor
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlAttributes.id eq rb.getID()) {
					// node found so we will delete it to add it again
					arrayDeleteAt(xmlDoc.xmlRoot.xmlChildren, i);
					break;
				}
			}

			// create and append new xml node for res bean			
			xmlNode = rb.toXMLNode(xmlDoc);
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			
			// save resource descriptor file
			getS3().putObjectContent(variables.bucket, infoHREF, toString(xmlDoc), "text/xml");
		</cfscript>
	</cffunction>

	<cffunction name="deleteResource" access="public" returntype="void" hint="Removes a resource from the library. If the resource has a related file then the file is deleted">
		<cfargument name="ID" type="string" required="true">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="package" type="string" required="true">

		<cfscript>
			var packageDir = "";
			var resHref = "";
			var resTypeDir = "";
			var infoHREF = "";
			var reg = getResourceTypeRegistry();
			var resType = reg.getResourceType(arguments.resourceType);
			var defaultExtension = listFirst(resType.getFileTypes());
			
			if(arguments.id eq "") throwException("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(arguments.package eq "") throwException("No folder has been specified","homePortals.resourceLibrary.validation");
			if(not reg.hasResourceType(arguments.resourceType)) throwException("The resource type is invalid","homePortals.resourceLibrary.invalidResourceType");

			// get location of descriptor file
			infoHREF = getResourceDescriptorFilePath( arguments.resourceType, arguments.package  );
			
			resTypeDir = resType.getFolderName();

			// remove from descriptor (if exists)
			packageDir = resTypeDir & "/" & arguments.package;
			
			if(s3FileExists(infoHREF)) {
				xmlDoc = getResourceDescriptor(arguments.resourceType, arguments.package);

				for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
					xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
					if(xmlNode.xmlAttributes.id eq id) {
						if(structKeyExists(xmlNode.xmlAttributes, "href"))
							resHref = xmlNode.xmlAttributes.href;
					
						// remove node from document
						arrayDeleteAt(xmlDoc.xmlRoot.xmlChildren, i);
						
						// save modified resource descriptor file
						getS3().putObjectContent(variables.bucket, infoHREF, toString(xmlDoc), "text/xml");					
									
						break;
					}
				}					
			} else {
			
				resHref = packageDir & "/" & arguments.package & "." & defaultExtension;

			}				
			
			// remove resource file
			getS3().deleteObject(variables.bucket, resHref);
		</cfscript>
	</cffunction>	

	<cffunction name="getNewResource" access="public" returntype="homePortals.components.resourceBean" hint="creates a new empty instance of a given resource type for this library">
		<cfargument name="resourceType" type="string" required="true">
		<cfset var rt = getResourceTypeRegistry().getResourceType(arguments.resourceType)>
		<cfset var oResBean = rt.createBean(this)>
		<cfreturn oResBean>
	</cffunction>

	<cffunction name="getPath" access="public" returntype="string" hint="returns the path for this library">
		<cfreturn variables.resourcesRoot>
	</cffunction>

	<cffunction name="setS3Keys" access="public" returntype="void" hint="Sets the key values for the S3 account">
		<cfargument name="key" type="string" required="true">
		<cfargument name="secret" type="string" required="true">
		<cfset variables.s3Key = arguments.key>
		<cfset variables.s3Secret = arguments.s3Secret>
	</cffunction>

	<!------------------------------------------------->
	<!--- Resource (Target) File Operations   	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceFileHREF" access="public" returntype="string" hint="returns the full (web accessible) path to a file object on the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<!--- <cfreturn getS3().getObject(variables.bucket, arguments.resourceBean.getHref())> --->
		<cfreturn "http://" & variables.bucket & ".s3.amazonaws.com/" & arguments.resourceBean.getHREF()>
	</cffunction>

	<cffunction name="getResourceFilePath" access="public" returntype="string" hint="If the object can be reached through the file system, then returns the absolute path on the file system to a file object on the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfreturn "">
	</cffunction>

	<cffunction name="resourceFileExists" access="public" output="false" returntype="boolean" hint="Returns whether the file associated with a resource exists on the local file system or not.">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfset var href = "http://" & variables.bucket & ".s3.amazonaws.com/" & arguments.resourceBean.getHREF()>
		<cfset var httpInfo = structnew()>
		<cfhttp url="#href#" 
				method="get" 
				result="httpInfo" 
				timeout="#variables.HTTP_TIMEOUT#">
		</cfhttp>
		<cfreturn (httpInfo.responseHeader.status_code eq "200")>
	</cffunction>
	
	<cffunction name="readResourceFile" access="public" output="false" returntype="any" hint="Reads the file associated with a resource. If there is no associated file then returns a missingTargetFile error. This only works for target files stored within the resource library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="readAsBinary" type="boolean" required="false" default="false" hint="Reads the file as a binary document">
		<cfset var href = getResourceFileHREF(arguments.resourceBean)>
		<cfset var httpInfo = structnew()>
		<cfhttp url="#href#" 
				method="get" 
				getasbinary="#arguments.readAsBinary#" 
				throwonerror="true" 
				timeout="#variables.HTTP_TIMEOUT#"	
				result="httpInfo">
		</cfhttp>
		<cfreturn httpInfo.FileContent>
	</cffunction>
	
	<cffunction name="saveResourceFile" access="public" output="false" returntype="void" hint="Saves a file associated to this resource">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="fileContent" type="any" required="true" hint="File contents">
		<cfargument name="fileName" type="string" required="false" hint="filename to use" default="">
		<cfargument name="contentType" type="string" required="false" hint="MIME content type of the resource file" default="">
		<cfscript>
			var rb = arguments.resourceBean;
			var href = buildResourceFileHREF(arguments.resourceBean, arguments.fileName);
			
			if(arguments.contentType eq "") arguments.contentType = "binary/octet-stream";
			getS3().putObjectContent(variables.bucket, href, arguments.fileContent, arguments.contentType);
			
			rb.setHREF(href);
			saveResource(rb);
		</cfscript>
	</cffunction>

	<cffunction name="addResourceFile" access="public" output="false" returntype="void" hint="Copies an existing file to the resource library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="filePath" type="string" required="true" hint="absolute location of the file">
		<cfargument name="fileName" type="string" required="false" hint="filename to use" default="">
		<cfargument name="contentType" type="string" required="false" hint="MIME content type of the resource file" default="">
		<cfscript>
			var rb = arguments.resourceBean;
			var href = buildResourceFileHREF(arguments.resourceBean, arguments.fileName);
					
			if(arguments.contentType eq "") arguments.contentType = "binary/octet-stream";
			getS3().postObject(variables.bucket, href, arguments.filePath, arguments.contentType);

			rb.setHREF(href);
			saveResource(rb);
		</cfscript>
	</cffunction>

	<cffunction name="deleteResourceFile" access="public" output="false" returntype="void" hint="Deletes the file associated with a resource">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfset getS3().deleteObject(variables.bucket, arguments.resourceBean.getHREF() )>
		<cfset arguments.resourceBean.setHREF("")>
		<cfset saveResource(arguments.resourceBean)>
	</cffunction>


	<!---- Private Methods --->

	<cffunction name="getS3" access="private" returntype="any">
		<cfif not isObject(variables.s3)>
			<cfset variables.s3 = createObject("component","s3").init(variables.s3Key,variables.s3Secret)>
		</cfif>
		<cfreturn variables.s3>
	</cffunction>
	
	<cffunction name="s3FileExists" access="private" returntype="boolean">
		<cfargument name="filePath" type="string" required="true">
		<cfset var httpInfo = structNew()>
		<cfset var href = getS3().getObject(variables.bucket, arguments.filePath)>
		
		<cfhttp url="#href#" method="head" result="httpInfo">
		</cfhttp>

		<cfreturn (httpInfo.responseHeader.status_code eq "200")>
	</cffunction>

	<cffunction name="buildResourceFileHREF" access="private" returntype="string">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="fileName" type="string" required="false" hint="filename to use" default="">
		<cfscript>
			var rb = arguments.resourceBean;
			var rt = getResourceTypeRegistry().getResourceType( rb.getType() );
			var defaultExtension = listFirst(rt.getFileTypes());
			var href = "";
			var fileNameNoExt = "";

			// get default filename and extension
			if(arguments.fileName eq "") {
				arguments.fileName = rb.getID();
			}

			if(listLen(arguments.fileName,".") eq 0
					and defaultExtension neq "") {
				arguments.fileName  = arguments.fileName 
										& "." 
										& defaultExtension;
			}	
			
			if(listLen(arguments.fileName,".") gt 0) {
				fileNameNoExt = listDeleteAt(arguments.fileName,listLen(arguments.fileName,"."),".");
				arguments.fileName = urlEncodedFormat(fileNameNoExt) & "." & listLast(arguments.fileName,".");
			} else {
				arguments.fileName = urlEncodedformat(arguments.fileName);
			}
			
			href = rt.getFolderName() 
					& "/" 
					& rb.getPackage() 
					& "/" 
					& arguments.fileName;	
			
			return href;		
		</cfscript>
	</cffunction>

	<cffunction name="hasResourceDescriptor" access="private" returntype="boolean">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfset var infoHREF = getResourceDescriptorFilePath(arguments.resourceType, arguments.packageName)>
		<cfset var href = "http://" & variables.bucket & ".s3.amazonaws.com/" & urlEncodedFormat(infoHREF)>
		<cfhttp url="#href#" method="get" result="httpInfo">
		</cfhttp>
		<cfreturn (httpInfo.responseHeader.status_code eq "200")>
	</cffunction>
	
	<cffunction name="getResourceDescriptorFilePath" access="private" returntype="string" hint="Returns the relative path to the resource descriptor file for a given resource package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfreturn  getResourceTypeRegistry().getResourceType(arguments.resourceType).getFolderName() 
					& "/" 
					& arguments.packageName 
					& "/" 
					& variables.resourceDescriptorFile>
	</cffunction>
	
	<cffunction name="getResourceDescriptor" access="public" returntype="xml">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfset var infoHREF = getResourceDescriptorFilePath(arguments.resourceType, arguments.packageName)>
		<cfset var href = getS3().getObject(variables.bucket, infoHREF)>
		<cfreturn xmlParse(href)>
	</cffunction>
	
	<cffunction name="getResourcesInDescriptorFile"  returntype="array" access="private" hint="returns all resources on the given file descriptor, also if a resourceID is given, only returns that resource instead of all resources on the package">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource to search">
		<cfargument name="packageName" type="string" required="true" hint="Name of the package to search">
		<cfargument name="resourceID" type="string" required="false" default="" hint="Name of a specific resource to search for. If given, then the returning array only contains that resource">
		<cfscript>
			var xmlDescriptorDoc = 0;
			var i = 0;
			var xpath = "";
			var oResourceBean = 0; 
			var aResBeans = arrayNew(1); 
			var aNodes = arrayNew(1);

			// read resource descriptor
			xmlDescriptorDoc = getResourceDescriptor(arguments.resourceType, arguments.packageName);
			
			if(arguments.resourceID neq "") {
				xpath = "//resLib[@type='#arguments.resourceType#']/resource[@id='#arguments.resourceID#']";
			} else {
				xpath = "//resLib[@type='#arguments.resourceType#']/resource";
			}
			
			aNodes = xmlSearch(xmlDescriptorDoc, xpath);
			
			for(i=1;i lte ArrayLen(aNodes);i=i+1) {
				oResourceBean = getNewResource(arguments.resourceType);

				oResourceBean.loadFromXMLNode( aNodes[i] );
				oResourceBean.setPackage( arguments.packageName );

				// add resource bean to returning array
				arrayAppend(aResBeans, oResourceBean);
			}
			
			return aResBeans;
		</cfscript>
	</cffunction>

	<cffunction name="getDefaultResourceInPackage" access="private" returntype="Any">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource to import">
		<cfargument name="packageName" type="string" required="true" hint="Name of the package to import">
		<cfscript>
			var tmpHREF = "";
			var oResourceBean = 0;
			var rt = getResourceTypeRegistry().getResourceType( arguments.resourceType );
			var defaultExtension = listFirst(rt.getFileTypes());
			
			// build the default name of the resource to register
			tmpHREF = rt.getFolderName() 
						& "/" 
						& arguments.packageName 
						& "/" 
						& arguments.packageName 
						& "." 
						& defaultExtension;

			// if the file exists, then register it
			if(s3FileExists(tmpHREF)) {

				// create resource bean
				oResourceBean = getNewResource(arguments.resourceType);
				oResourceBean.setID( arguments.packageName );
				oResourceBean.setHREF( tmpHREF );
				oResourceBean.setPackage( arguments.packageName );

			}
			
			return oResourceBean;
		</cfscript>
	</cffunction>
	
	
	
	
	<cffunction name="throwException" access="private">
		<cfargument name="message" type="string">
		<cfargument name="type" type="string" default="homePortals.resourceLibrary.exception"> 
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>

	<cffunction name="abort" access="private" returntype="void">
		<cfabort>
	</cffunction>
	
	<cffunction name="dump" access="private" returntype="void">
		<cfargument name="data" type="any">
		<cfdump var="#arguments.data#">
	</cffunction>
	
</cfcomponent>