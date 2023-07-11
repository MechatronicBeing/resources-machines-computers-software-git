// Create a new stylesheet by SCRIPT to overwrite some style (hide, unhide...)
var sheet = document.createElement('style');
sheet.innerHTML = ".hide {display: none; }";
sheet.innerHTML += " .unhide-inline {display: inline !important;}";
sheet.innerHTML += " .unhide-td {display: table-row !important;}";
sheet.innerHTML += " .file-link {pointer-events: none; cursor: default; color:black; }";
sheet.innerHTML += " .odd, .even {background-color: White;}";
sheet.innerHTML += " .file-row *:hover { cursor: default; }";
sheet.innerHTML += " .file-row:hover td { background-color: AliceBlue;}";
sheet.innerHTML += " .selected {background-color: LightSkyBlue;}";
document.head.appendChild(sheet);

/* echo "<input type='button' onclick='makeZipFile()' value='Create archive'>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename" */

MBWebScriptElement=document.getElementById('MBWebScript');
folderExpandedIconPath = MBWebScriptElement.getAttribute('data-folderExpandedIconPath');
folderExpandableIconPath = MBWebScriptElement.getAttribute('data-folderExpandableIconPath');

// Array of inputs behind cursor, important as full row can be clicked !
var inputsBehindCursor = [];

// Add the focused input to the array
function mouseIn(itemId) {
  inputsBehindCursor.push(itemId);
}

// Remove the input, not focused anymore, of the array
function mouseOut(itemId) {
  const itemIndex = inputsBehindCursor.indexOf(itemId); 
  if(itemIndex !== -1){
    inputsBehindCursor.splice(itemIndex, 1);
  }
}

// Action if the row is clicked
function rowClicked(itemId, file) {
  // Verify that NO inputs are focused UNDER the row
  if(inputsBehindCursor.length == 0){
    if(file.endsWith('/')) {
      expandFolders(itemId);
    }else{
      viewFile(file);
    }
  }
}

// Expand (OR collapse) the folders
function expandFolders(itemId, modifyFolder=true) {
  var fromClassname, toClassname;
  var currentRow = document.getElementById('tr_'+itemId+'_');
  var skipSubFolder="&";
  
  //Load external data
  if(hasClassName(currentRow, 'loadData')){
    const scriptToLoad = currentRow.getAttribute('data-addFilesScript');
    loadJsScript(scriptToLoad);
    replaceClassname(currentRow, 'loadData', '');
  }
  
  if( modifyFolder) { 
    expandFolder(itemId);
  }
  folderIsExpanded=hasClassName(document.getElementById('folderExpandIcon_'+itemId), 'file-folderExpanded-icon');
  if(folderIsExpanded){
    fromClassname="hide"; toClassname="unhide-td";
  }else{
    fromClassname="unhide-td"; toClassname="hide";
  }
  
  const idItemLength = currentRow.getAttribute('id').length;
  var elements = document.querySelectorAll('[id^="tr_'+itemId+'"]');
  for(var i=0;i<elements.length;i++) {
    if (currentRow !== elements[i]) {
      var idElement = elements[i].getAttribute('id');
      
      // Get the substring : remove the first part (starting with the same id of the current folder)
      const subStringIdElement=idElement.substring(idItemLength);
      if(! subStringIdElement.startsWith(skipSubFolder)){
        const splitedItemId = subStringIdElement.split('/');
        // 
        if (splitedItemId.length == 1 || (splitedItemId.length == 2 && splitedItemId[1] == '_')) {
          replaceClassname(elements[i], fromClassname, toClassname);
        }else{
          if(folderIsExpanded && hasClassName(elements[i], 'file-folderExpanded-icon')){

            lastPart=subStringIdElement.slice(0, -1);
            console.log('auto-expand ', lastPart);
            expandFolders(itemId+lastPart, false);
            skipSubFolder=lastPart;
          }else{
            replaceClassname(elements[i], "unhide-td", "hide");
          }
        }
      }
    }
  }
}

function expandFolder(itemId) {
  var folderExpandIconElement = document.getElementById('folderExpandIcon_'+itemId);
  if ( hasClassName(folderExpandIconElement, 'file-folderExpandable-icon') ){
    replaceClassname(folderExpandIconElement, 'file-folderExpandable-icon', 'file-folderExpanded-icon');
    folderExpandIconElement.src = folderExpandedIconPath;
  }else{
    replaceClassname(folderExpandIconElement, 'file-folderExpanded-icon', 'file-folderExpandable-icon');
    folderExpandIconElement.src = folderExpandableIconPath;
  }
}

function hasClassName(element, classNameToFound) {
  var classFounded = false;
  const splitedClassnames = element.className.split(' ');
  for(var i=0;i<splitedClassnames.length;i++) {
    if(splitedClassnames[i]==classNameToFound) {
      classFounded = true;
      break;
    }
  }
  return classFounded;
}

function replaceClassname(element, previousClassname, newClassname) {
  var classNameReplaced = "";
  var classFounded = false;
  const previousClassnameTrimmed=previousClassname.trim();
  const newClassnameTrimmed=newClassname.trim();
  const splitedClassnames = element.className.split(' ');
  var spaceBetweenElement = "";
  for(var i=0;i<splitedClassnames.length;i++) {
    currentClassnameTrimmed=splitedClassnames[i].trim();
    
    if(currentClassnameTrimmed==previousClassnameTrimmed) {
      if(newClassname != ''){
        classNameReplaced+=spaceBetweenElement+newClassnameTrimmed;
      }
      classFounded = true;
    }else{
      classNameReplaced+=spaceBetweenElement+currentClassnameTrimmed;
    }
    
    spaceBetweenElement=' ';
  }
  if ((! classFounded) && (newClassname != '')) {
    classNameReplaced+=spaceBetweenElement+newClassnameTrimmed;
  }
  element.className=classNameReplaced;
}

function viewFile(file) {
  // var fileviewer = document.getElementById('div-file-viewer');
  // fileviewer.innerHTML = '<embed class="embed-file-viewer" frameborder="0" allowfullscreen src="'+file+'" >'; 
}

function loadJsScript(scriptPath) {
  var newScript = document.createElement('script');
  newScript.src = scriptPath;
  newScript.type = "text/javascript";
  newScript.async = true;
  document.body.appendChild(newScript);
  newScript.addEventListener("load", () => {console.log(newScript.src+' loaded.');});
}

function changeCheckedItems(idCheckbox) {
  const currentIdCheckbox='cb_'+idCheckbox+'_';
  var isChecked=document.getElementById(currentIdCheckbox).checked;
  var checkboxes = document.querySelectorAll('[id^="cb_'+idCheckbox+'"]');
  for(var i=0;i<checkboxes.length;i++) {
    if(currentIdCheckbox != checkboxes[i].getAttribute('id')){
      checkboxes[i].checked=isChecked;
    }
  }
}

// Create a zip with the selected files
function makeZipFile() {
  var z=new Zip('MechatronicBeing');
  var markedCheckboxes = [];
  var filesCount=0;
  var checkboxes = document.querySelectorAll('input[type="checkbox"]');
  for(var i=0;i<checkboxes.length;i++) {
    if(checkboxes[i].checked){
      markedCheckboxes.push(checkboxes[i]);
    }
  }
  for(var i=0;i<markedCheckboxes.length;i++) {
    var filename = markedCheckboxes[i].getAttribute('data-file');
    var filepath = markedCheckboxes[i].getAttribute('data-path');
    var dataExt = markedCheckboxes[i].getAttribute('data-ext');
    if(dataExt != '/'){
      filesCount++;
      z.fecth2zip([filename], filepath);
    }
  }
  var waitFilesLoadBeforeMakeZip = function(){
    if(z.filesCounted() == filesCount){
      z.makeZip();
    } else {
      setTimeout(waitFilesLoadBeforeMakeZip, 500);
    }
  }
  waitFilesLoadBeforeMakeZip();
}