<table style="margin:0px;padding:0px;width:100%;" cellpadding="0" cellspacing="0">
	<tr valign="top">
		<td>
			<b>Setup an S3-backed Resource Library </b>
			<div class="formFieldTip">
				<br />
				
				<p>
					To be able to use your <a href="http://aws.amazon.com/s3/" target="_blank">Amazon S3</a> account to store a resource library, you must
					provide your Access Key and Secret Key for your S3 account.
				</p>
			</div>
			<form name="frm" method="post" action="index.cfm">
				<input type="hidden" name="event" value="my.S3ResLib.ehGeneral.doSetup">
				<table>
					<tr>
						<td><b>S3 Access Key:</b></td>
						<td><input type="text" name="key" value="" style="width:200px;" class="formField"></td>
					</tr>
					<tr>
						<td><b>S3 Secret Key:</b></td>
						<td><input type="text" name="secret" value="" style="width:200px;" class="formField"></td>
					</tr>
				</table>
				<br />
				<input type="submit" name="btn" value="Apply Changes">
			</form>
		</td>
		<td width="200">
			<div class="cp_sectionBox helpBox"  style="margin:10px;margin-right:0px;margin-bottom:0px;height:400px;line-height:18px;">
				<div style="margin:10px;">
					<h2>S3 Resource Libraries</h2>
					This ColdBricks module provides support to create a Resource Library based on an Amazon S3 bucket.<br /><br />
					<b>Amazon S3 (Simple Storage Service)</b> is a service that provides a highly scalable and available data storage service.
					To find more about Amazon S3, go to <strong><a href="http://aws.amazon.com/s3/">http://aws.amazon.com/s3/</a></strong>
					<br /><br />
					With the S3ResLib extension, you can transparently use an S3 bucket to store your resources, just like if they were stored
					on the local file system.
				</div>
			</div>
		</td>
	</tr>
</table>
