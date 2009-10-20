<cfcomponent name="s3" displayname="Amazon S3 REST Wrapper v1.7">

<!---
Amazon S3 REST Wrapper

Written by Joe Danziger (joe@ajaxcf.com) with much help from
dorioo on the Amazon S3 Forums.  See the readme for more
details on usage and methods.
Thanks to Steve Hicks for the bucket ACL updates.
Thanks to Carlos Gallupa for the EU storage location updates.
Thanks to Joel Greutman for the fix on the getObject link.
Thanks to Jerad Sloan for the Cache Control headers.

Version 1.7 - Released: December 15, 2008


------------------------------------------------------------
LICENSE 
Copyright 2006 Joe Danziger (joe@ajaxcf.com)

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
------------------------------------------------------------

--->

	<cfset variables.accessKeyId = "">
	<cfset variables.secretAccessKey = "">
	<cfset variables.DEFAULT_ACL = "public-read">

	<cffunction name="init" access="public" returnType="s3" output="false"
				hint="Returns an instance of the CFC initialized.">
		<cfargument name="accessKeyId" type="string" required="true" hint="Amazon S3 Access Key ID.">
		<cfargument name="secretAccessKey" type="string" required="true" hint="Amazon S3 Secret Access Key.">
		
		<cfset variables.accessKeyId = arguments.accessKeyId>
		<cfset variables.secretAccessKey = arguments.secretAccessKey>
	
		<cfreturn this>
	</cffunction>
	
	<cffunction name="HMAC_SHA1" returntype="binary" access="private" output="false" hint="NSA SHA-1 Algorithm">
	   <cfargument name="signKey" type="string" required="true" />
	   <cfargument name="signMessage" type="string" required="true" />
	
	   <cfset var jMsg = JavaCast("string",arguments.signMessage).getBytes("iso-8859-1") />
	   <cfset var jKey = JavaCast("string",arguments.signKey).getBytes("iso-8859-1") />
	   <cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") />
	   <cfset var mac = createObject("java","javax.crypto.Mac") />
	
	   <cfset key = key.init(jKey,"HmacSHA1") />
	   <cfset mac = mac.getInstance(key.getAlgorithm()) />
	   <cfset mac.init(key) />
	   <cfset mac.update(jMsg) />
	
	   <cfreturn mac.doFinal() />
	</cffunction>

	<cffunction name="createSignature" returntype="string" access="public" output="false">
	   <cfargument name="stringIn" type="string" required="true" />
		
		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(arguments.stringIn,"\n","#chr(10)#","all")>
		<!--- Calculate the hash of the information --->
		<cfset var digest = HMAC_SHA1(variables.secretAccessKey,fixedData)>
		<!--- fix the returned data to be a proper signature --->
		<cfset var signature = ToBase64("#digest#")>
		
		<cfreturn signature>
	</cffunction>

	<cffunction name="getBuckets" access="public" output="true" returntype="array" 
				description="List all available buckets.">
		
		<cfset var data = "">
		<cfset var bucket = "">
		<cfset var buckets = "">
		<cfset var thisBucket = "">
		<cfset var allBuckets = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		
		<!--- Create a canonical string to send --->
		<!--- <cfset var cs = "GET\n\n\n#dateTimeString#\n/">--->
		<cfset var cs = "GET\n\ntext/html; charset=UTF-8\n#dateTimeString#\n/">
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		
		<!--- get all buckets via REST --->
		<cfhttp method="GET" url="http://s3.amazonaws.com">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cfset data = xmlParse(cfhttp.FileContent)>
		<cfset buckets = xmlSearch(data, "//:Bucket")>

		<!--- create array and insert values from XML --->
		<cfset allBuckets = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(buckets)#">
		   <cfset bucket = buckets[x]>
		   <cfset thisBucket = structNew()>
		   <cfset thisBucket.Name = bucket.Name.xmlText>
		   <cfset thisBucket.CreationDate = bucket.CreationDate.xmlText>
		   <cfset arrayAppend(allBuckets, thisBucket)>   
		</cfloop>
		
		<cfreturn allBuckets>		
	</cffunction>
	
	<cffunction name="putBucket" access="public" output="false" returntype="boolean" 
				description="Creates a bucket.">
		<cfargument name="bucketName" type="string" required="true">
		<cfargument name="acl" type="string" required="false" default="#variables.DEFAULT_ACL#">
		<cfargument name="storageLocation" type="string" required="false" default="">
		
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "PUT\n\ntext/html\n#dateTimeString#\nx-amz-acl:#arguments.acl#\n/#arguments.bucketName#">

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>

		<cfif arguments.storageLocation eq "EU">
			<cfsavecontent variable="strXML">
				<CreateBucketConfiguration><LocationConstraint>EU</LocationConstraint></CreateBucketConfiguration>
			</cfsavecontent>
		<cfelse>
			<cfset strXML = "">
		</cfif>

		<!--- put the bucket via REST --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#" charset="utf-8">
			<cfhttpparam type="header" name="Content-Type" value="text/html">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="x-amz-acl" value="#arguments.acl#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="body" value="#trim(variables.strXML)#">
		</cfhttp>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getBucket" access="public" output="false" returntype="array" 
				description="Creates a bucket.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="prefix" type="string" required="false" default="">
		<cfargument name="marker" type="string" required="false" default="">
		<cfargument name="maxKeys" type="string" required="false" default="">
		
		<cfset var data = "">
		<cfset var content = "">
		<cfset var contents = "">
		<cfset var thisContent = "">
		<cfset var allContents = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send --->
		<!--- <cfset var cs = "GET\n\n\n#dateTimeString#\n/#arguments.bucketName#"> --->
		<cfset var cs = "GET\n\ntext/html; charset=UTF-8\n#dateTimeString#\n/#arguments.bucketName#">

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>

		<!--- get the bucket via REST --->
		<cfhttp method="GET" url="http://s3.amazonaws.com/#arguments.bucketName#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfif compare(arguments.prefix,'')>
				<cfhttpparam type="URL" name="prefix" value="#arguments.prefix#"> 
			</cfif>
			<cfif compare(arguments.marker,'')>
				<cfhttpparam type="URL" name="marker" value="#arguments.marker#"> 
			</cfif>
			<cfif isNumeric(arguments.maxKeys)>
				<cfhttpparam type="URL" name="max-keys" value="#arguments.maxKeys#"> 
			</cfif>
		</cfhttp>
		
		<cfset data = xmlParse(cfhttp.FileContent)>
		<cfset contents = xmlSearch(data, "//:Contents")>

		<!--- create array and insert values from XML --->
		<cfset allContents = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(contents)#">
			<cfset content = contents[x]>
			<cfset thisContent = structNew()>
			<cfset thisContent.Key = content.Key.xmlText>
			<cfset thisContent.LastModified = content.LastModified.xmlText>
			<cfset thisContent.Size = content.Size.xmlText>
			<cfset arrayAppend(allContents, thisContent)>   
		</cfloop>

		<cfreturn allContents>
	</cffunction>
	
	<cffunction name="deleteBucket" access="public" output="false" returntype="boolean" 
				description="Deletes a bucket.">
		<cfargument name="bucketName" type="string" required="yes">	
		
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		
		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "DELETE\n\n\n#dateTimeString#\n/#arguments.bucketName#"> 
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		
		<!--- delete the bucket via REST --->
		<cfhttp method="DELETE" url="http://s3.amazonaws.com/#arguments.bucketName#" charset="utf-8">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="putObject" access="public" output="false" returntype="boolean" 
				description="Puts an object into a bucket.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="filePath" type="string" required="yes">
		<cfargument name="contentType" type="string" required="yes">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="300">
		<cfargument name="cacheControl" type="boolean" required="false" default="true">
		<cfargument name="cacheDays" type="numeric" required="false" default="30">
		
		<cfset var binaryFileData = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send --->
		<cfset var cs = "PUT\n\n#arguments.contentType#\n#dateTimeString#\nx-amz-acl:#variables.DEFAULT_ACL#\n/#arguments.bucketName#/#arguments.fileKey#">
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		
		<!--- Read the image data into a variable --->
		<cfif find("text",arguments.contentType)>
			<cffile action="read" file="#arguments.filePath#" variable="binaryFileData">
		<cfelse>
			<cffile action="readbinary" file="#arguments.filePath#" variable="binaryFileData">
		</cfif>

		<!--- Send the file to amazon. The "X-amz-acl" controls the access properties of the file --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#" timeout="#arguments.HTTPtimeout#" result="info">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="x-amz-acl" value="#variables.DEFAULT_ACL#">
			<cfhttpparam type="body" value="#binaryFileData#">
			<cfif arguments.cacheControl>
				<cfhttpparam type="header" name="Cache-Control" value="max-age=2592000">
				<cfhttpparam type="header" name="Expires" value="#DateFormat(now()+arguments.cacheDays,'ddd, dd mmm yyyy')# #TimeFormat(now(),'H:MM:SS')# GMT">
			</cfif>
		</cfhttp> 		

		<cfreturn true>
	</cffunction>

	<cffunction name="putObjectContent" access="public" output="false" returntype="boolean" 
				description="Puts an object into a bucket (accepts the object contents)">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="content" type="any" required="yes">
		<cfargument name="contentType" type="string" required="yes">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="300">
		<cfargument name="cacheControl" type="boolean" required="false" default="true">
		<cfargument name="cacheDays" type="numeric" required="false" default="30">
		
		<cfset var binaryFileData = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send --->
		<cfset var cs = "PUT\n\n#arguments.contentType#\n#dateTimeString#\nx-amz-acl:#variables.DEFAULT_ACL#\n/#arguments.bucketName#/#arguments.fileKey#">
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		
		<!--- Send the file to amazon. The "X-amz-acl" controls the access properties of the file --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#" timeout="#arguments.HTTPtimeout#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="x-amz-acl" value="#variables.DEFAULT_ACL#">
			<cfhttpparam type="body" value="#arguments.content#">
			<cfif arguments.cacheControl>
				<cfhttpparam type="header" name="Cache-Control" value="max-age=2592000">
				<cfhttpparam type="header" name="Expires" value="#DateFormat(now()+arguments.cacheDays,'ddd, dd mmm yyyy')# #TimeFormat(now(),'H:MM:SS')# GMT">
			</cfif>
		</cfhttp> 		
		
		<cfreturn true>
	</cffunction>

	<!--- The original S3CFC (http://amazons3.riaforge.org)/ uses GET intead of POST to send files, but POST is better since files don't have to be read into memory --->
    <cffunction name="postObject" access="public" output="true" returntype="string">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="filePath" type="string" required="yes">
		<cfargument name="contentType" type="string" required="no">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="300">
        
        <cfsavecontent variable="policyArgs">
        {
		  "expiration": "2010-01-01T12:00:00.000Z",
		  "conditions": [
		    {"key": "#arguments.fileKey#" },
		    {"bucket": "#arguments.bucketName#" },
            {"success_action_status": "201" },
		    {"acl": "#variables.DEFAULT_ACL#" },
		    {"content-type": "#arguments.contentType#" },
		  ]
		}
        </cfsavecontent>

		<cfset policy = ToBase64(policyArgs)>
        <cfset signature = createSignature(policy)>
        
		<cfhttp method="POST" url="http://s3.amazonaws.com/#arguments.bucketName#" timeout="#arguments.HTTPtimeout#">
			  <cfhttpparam type="formfield" name="policy" value="#policy#">
			  <cfhttpparam type="formfield" name="AWSAccessKeyId" value="#variables.accessKeyId#">
			  <cfhttpparam type="formfield" name="signature" value="#signature#">
			  <cfhttpparam type="formfield" name="key" value="#arguments.fileKey#">
              <cfhttpparam type="formfield" name="success_action_status" value="201">
			  <cfhttpparam type="formfield" name="content-type" value="#arguments.contentType#">
			  <cfhttpparam type="formfield" name="acl" value="#variables.DEFAULT_ACL#">
			  <cfhttpparam type="file" name="file" file="#arguments.filePath#">
		</cfhttp> 
        
	   <cfif CFHTTP.ResponseHeader.Status_Code neq 201>
		   	<cfdump var="#CFHTTP#">
		   	<cfabort>
		   	<cfthrow message="error while uploading file">
    	</cfif>
	
		<cfreturn true>
	</cffunction>

	<cffunction name="getObject" access="public" output="false" returntype="string" 
				description="Returns a link to an object.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="minutesValid" type="string" required="false" default="60">
		
		<cfset var timedAmazonLink = "">
		<cfset var epochTime = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), now()) + (arguments.minutesValid * 60)>

		<!--- Create a canonical string to send --->
		<cfset var cs = "GET\n\n\n#epochTime#\n/#arguments.bucketName#/#arguments.fileKey#"> 
		<!--- <cfset var cs = "GET\n\ntext/html; charset=UTF-8\n#epochTime#\n/#arguments.bucketName#/#arguments.fileKey#">--->

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>

		<!--- Create the timed link for the image --->
		<cfset timedAmazonLink = "http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#?AWSAccessKeyId=#URLEncodedFormat(variables.accessKeyId)#&Expires=#epochTime#&Signature=#URLEncodedFormat(signature)#">

		<cfreturn timedAmazonLink>
	</cffunction>

	<cffunction name="deleteObject" access="public" output="false" returntype="boolean" 
				description="Deletes an object.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">

		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<!--- <cfset var cs = "DELETE\n\n\n#dateTimeString#\n/#arguments.bucketName#/#arguments.fileKey#"> --->
		<cfset var cs = "DELETE\n\napplication/x-www-form-urlencoded; charset=UTF-8\n#dateTimeString#\n/#arguments.bucketName#/#arguments.fileKey#"> 

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>

		<!--- delete the object via REST --->
		<cfhttp method="DELETE" url="http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>

		<cfreturn true>
	</cffunction>


	<cffunction name="copyObject" access="public" output="false" returntype="boolean" 
				description="Copies an object.">
		<cfargument name="oldBucketName" type="string" required="yes">
		<cfargument name="oldFileKey" type="string" required="yes">
		<cfargument name="newBucketName" type="string" required="yes">
		<cfargument name="newFileKey" type="string" required="yes">
	
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "PUT\n\napplication/octet-stream\n#dateTimeString#\nx-amz-copy-source:/#arguments.oldBucketName#/#arguments.oldFileKey#\n/#arguments.newBucketName#/#arguments.newFileKey#"> 

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>	
		
		<cfif compare(arguments.oldBucketName,arguments.newBucketName) or compare(arguments.oldFileKey,arguments.newFileKey)>
		
			<!--- delete the object via REST --->
			<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.newBucketName#/#arguments.newFileKey#">
				<cfhttpparam type="header" name="Date" value="#dateTimeString#">
				<cfhttpparam type="header" name="x-amz-copy-source" value="/#arguments.oldBucketName#/#arguments.oldFileKey#">
				<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			</cfhttp>
	
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="renameObject" access="public" output="false" returntype="boolean" 
				description="Renames an object by copying then deleting original.">
		<cfargument name="oldBucketName" type="string" required="yes">
		<cfargument name="oldFileKey" type="string" required="yes">
		<cfargument name="newBucketName" type="string" required="yes">
		<cfargument name="newFileKey" type="string" required="yes">
		
		<cfif compare(arguments.oldBucketName,arguments.newBucketName) or compare(arguments.oldFileKey,arguments.newFileKey)>
			<cfset copyObject(arguments.oldBucketName,arguments.oldFileKey,arguments.newBucketName,arguments.newFileKey)>
			<cfset deleteObject(arguments.oldBucketName,arguments.oldFileKey)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
</cfcomponent>