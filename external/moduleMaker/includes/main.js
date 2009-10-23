var activeEditBox = "";
var aTokens = new Array();

function selectModuleType(itemName) {
	doEvent("moduleMaker.ehModuleMaker.dspModule","nodePanel",{moduleType: itemName});

	d = $$(".resTreeItem");
	for(var i=0;i < d.length;i++) {
		d[i].style.fontWeight="normal";
	}	
	
	// highlight selected account
	d = $("resTreeItem_"+itemName);
	if(d) d.style.fontWeight="bold";
}

function selectPanel(id) {
	d1 = $("head");
	d2 = $("body");
	d3 = $("config");
	s1 = $("selInsertField");
	
	d1.style.display = "none"
	d2.style.display = "none"
	d3.style.display = "none"
	
	if(id=="head") {d1.style.display="block";s1.style.display="block";activeEditBox="head";}
	if(id=="body") {d2.style.display="block";s1.style.display="block";activeEditBox="body";}
	if(id=="config") {d3.style.display="block";s1.style.display="none";activeEditBox="";}

}

function loadInFB(href,reload) {
	if(reload!=null && reload)
		fb.loadAnchor(href,"width:480 height:300 loadPageOnClose:self");
	else
		fb.loadAnchor(href,"width:480 height:300");
}

function saveModule(frm) {
	frm.event.value = "moduleMaker.ehModuleMaker.doSave";
	frm.submit();
}

function deleteModule(frm) {
	if(confirm("Delete this module?")) {
		frm.event.value = "moduleMaker.ehModuleMaker.doDelete";
		frm.submit();
	}
}

function deleteProperty(moduletype,propname) {
	if(confirm("Delete this property?")) {
		var href = "index.cfm?event=moduleMaker.ehModuleMaker.doDeleteProperty&moduleType="+moduletype+"&name="+propname;
		document.location = href;
	}
}

function insertAtCursor(myField, myValue) {

  //IE support
 if (document.selection) {
    myField.focus();
    sel = document.selection.createRange();
    sel.text = myValue;
  }

  //MOZILLA/NETSCAPE support
  else if (myField.selectionStart || myField.selectionStart == '0') {
    var startPos = myField.selectionStart;
    var endPos = myField.selectionEnd;
    myField.value = myField.value.substring(0, startPos)
                  + myValue
                  + myField.value.substring(endPos, myField.value.length);
  } else {
    myField.value += myValue;
  }
}

function insertToken(tokenIndex) {
	if(activeEditBox!="") {
		var f = $(activeEditBox);
		if(tokenIndex > 0)
			insertAtCursor(f, aTokens[tokenIndex]);	
	}
}
