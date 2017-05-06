var gUploadXhr = null;
var gConflictHandling = { file:0, folder:0 };
var gOldUploadHtml = "";
var gUploadTotalFileSize = 0;
var gUploadTotalProgress = 0;
var gUploadFiles = [];
var gFailedUploadFiles = [];
var gCurDirFiles = null;
var gDragAndDrop = false;
var gProgressAllTxt = "{?5116:47?}";
function folderApiSupport()
{
return window.requestFileSystem || window.webkitRequestFileSystem
}
function fileApiSupport()
{
return window.File && window.FileReader
}
function disableSingleUploadBox()
{
gDisableMainPageFormBox.disableThisBox( true );
return true;
}
function updateFileProgress( fileProgress, fileTotal )
{
if ( 0 > fileProgress )
{
fileProgress = 0;
}
if ( 1 > fileTotal )
{
fileTotal = 1;
}
if ( fileTotal < fileProgress )
{
fileProgress = fileTotal;
}
var totalProgress = Math.round( ( ( gUploadTotalProgress + fileProgress ) * 100 ) / gUploadTotalFileSize );
if ( 100 < totalProgress )
{
totalProgress = 100;
}
drawProgressBar( totalProgress, "totalProgressBox", gProgressAllTxt );
var aktFileProgress = Math.round( ( fileProgress * 100 ) / fileTotal );
if ( 100 < aktFileProgress )
{
aktFileProgress = 100;
}
if ( gUploadFiles[0].webkitRelativePath && "" != gUploadFiles[0].webkitRelativePath )
{
drawProgressBar( aktFileProgress, "aktFileProgressBox", gUploadFiles[0].webkitRelativePath );
}
else
{
drawProgressBar( aktFileProgress, "aktFileProgressBox", gUploadFiles[0].name );
}
}
function drawProgressBar( percent, parentId, title )
{
if ( "number" == typeof percent && 0 <= percent && 100 >= percent && parentId && title )
{
var parent = jxl.get( parentId );
if ( parent )
{
parent.innerHTML = title;
parent.innerHTML += "<div class='progressBarBox'><div class='progressBar'style='width: " + percent + "%;'></div><div class='progressBarDetail'>" + percent + " %</div></div>";
}
}
}
function checkUploadErrors( response )
{
}
function uploadFinished( evt )
{
gMmInfoInterval = setTimeout( doInfoRequest, 10000 );
disableFileSelectors( false );
var cancelBtn = jxl.get( "idBtnCancel" )
if ( cancelBtn )
{
cancelBtn.innerHTML = "{?5116:885?}";
cancelBtn.onclick = function() { uploadClose( true ); };
}
jxl.disableNode( "idBtnUpload", true );
gConflictHandling = { file:0, folder:0 };
}
function uploadStart( evt )
{
}
function updateUploadProgress( evt )
{
updateFileProgress( evt.loaded, gUploadFiles[0].cntSize);
}
function uploadComplete( evt )
{
gl.ds_free -= gUploadFiles[0].cntSize;
gUploadTotalProgress += gUploadFiles[0].cntSize;
updateFileProgress( 0, gUploadFiles[0].cntSize );
var fileId = gUploadFiles[0].name;
var fileType = "F";
if ( gUploadFiles[0].webkitRelativePath && "" != gUploadFiles[0].webkitRelativePath )
{
fileId = gUploadFiles[0].webkitRelativePath.substring( 0, gUploadFiles[0].webkitRelativePath.indexOf( "/" ) );
fileType = "D";
}
if ( !gCurDirFiles[fileId] )
{
gCurDirFiles[fileId] = { type:fileType, path:gCurNasDir + "/" + fileId, size:gUploadFiles[0].size };
if ( "D" == fileType )
{
gConflictHandling["folder"] = 1;
}
}
if ( gUploadFiles[0].realFileName && "string" == typeof gUploadFiles[0].realFileName && "" != gUploadFiles[0].realFileName && !gCurDirFiles[gUploadFiles[0].realFileName] )
{
gCurDirFiles[gUploadFiles[0].realFileName] = { type:fileType, path:gCurNasDir + "/" + gUploadFiles[0].realFileName, size:gUploadFiles[0].size };
if ( "D" == fileType )
{
gConflictHandling["folder"] = 1;
}
}
gUploadFiles.shift();
uploadNextFile();
}
function getRealFileName( fileId )
{
if ( "number" == typeof( gCurDirFiles[fileId].suffixCnt ) )
{
gCurDirFiles[fileId].suffixCnt++;
}
else
{
gCurDirFiles[fileId].suffixCnt = 1;
}
var newFilename = createRenameName( fileId, " (" + gCurDirFiles[fileId].suffixCnt + ")" );
while( gCurDirFiles[newFilename] )
{
gCurDirFiles[fileId].suffixCnt++;
newFilename = createRenameName( fileId, " (" + gCurDirFiles[fileId].suffixCnt + ")" );
}
gUploadFiles[0].realFileName = newFilename;
return newFilename;
}
function createRenameName( fileId, suffix, oldName, oldType )
{
var idx = fileId.lastIndexOf( "." );
if ( oldName && "F" == oldType )
{
idx = oldName.lastIndexOf( "." );
}
if ( 0 < idx )
{
var start = fileId.slice( 0, idx );
var end = fileId.slice( idx, fileId.length );
if ( oldName && "F" == oldType )
{
start = fileId;
end = oldName.slice( idx, oldName.length );
}
return start + suffix + end;
}
else
{
return fileId + suffix;
}
}
function uploadFailed( evt )
{
updateFileProgress( 0, gUploadFiles[0].cntSize );
gFailedUploadFiles[gFailedUploadFiles.length] = gUploadFiles[0];
gUploadFiles.shift();
uploadNextFile();
}
function uploadCanceled()
{
jxl.get( "aktFileProgressBox" ).innerHTML = '{?5116:888?}';
jxl.display( "idBtnContinue", true );
uploadFinished();
}
function uploadCancel()
{
if ( gUploadXhr )
{
gUploadXhr.abort();
gUploadXhr = null;
}
}
function uploadFile( file, realFileName )
{
gUploadXhr = new XMLHttpRequest();
gUploadXhr.upload.addEventListener( "progress", updateUploadProgress, false );
gUploadXhr.upload.addEventListener( "loadstart", uploadStart, false );
gUploadXhr.upload.addEventListener( "load", uploadComplete, false );
gUploadXhr.upload.addEventListener( "error", uploadFailed, false );
gUploadXhr.upload.addEventListener( "abort", uploadCanceled, false );
gUploadXhr.open( 'POST', '/nas/cgi-bin/nasupload_notimeout' );
var formData = new FormData();
formData.append( 'sid', gl.sid );
if ( realFileName && "string" == typeof realFileName && "" != realFileName )
{
formData.append( 'realfilename', realFileName );
}
formData.append( 'dir', gCurNasDir );
formData.append( 'ResultScript', '' );
formData.append( 'UploadFile', file );
gUploadXhr.send( formData );
}
function questioningCancel()
{
if ( "" != gOldUploadHtml )
{
var uploadBtn = jxl.get( "idBtnUpload" );
uploadBtn.innerHTML = "{?5116:119?}";
uploadBtn.onclick = function() {
uploadFilesOrFolder( false );
};
jxl.get( "disable_main_page_content_middle" ).innerHTML = gOldUploadHtml;
jxl.disableNode( uploadBtn, true );
jxl.display( uploadBtn, !gDragAndDrop );
gOldUploadHtml = "";
}
uploadCanceled();
}
function onUploadQuestion( type )
{
var uploadBtn = jxl.get( "idBtnUpload" );
uploadBtn.innerHTML = "{?5116:524?}";
uploadBtn.onclick = function() {
uploadFilesOrFolder( false );
};
jxl.get( "idBtnCancel" ).onclick = function() {
uploadCancel();
};
jxl.disableNode( "idBtnUpload", true );
jxl.display( uploadBtn, !gDragAndDrop );
jxl.get( "disable_main_page_content_middle" ).innerHTML = gOldUploadHtml;
gOldUploadHtml = "";
switch( gConflictHandling[type] )
{
case 1:
if ( "file" == type )
{
gConflictHandling[type] = 0;
}
case 2:
uploadFile( gUploadFiles[0] );
break;
case 3:
if ( "file" == type )
{
gConflictHandling[type] = 0;
}
case 4:
updateFileProgress( gUploadFiles[0].cntSize, gUploadFiles[0].cntSize );
gUploadTotalProgress += gUploadFiles[0].cntSize;
gUploadFiles.shift();
uploadNextFile();
break;
case 5:
gConflictHandling[type] = 0;
case 6:
uploadFile( gUploadFiles[0], getRealFileName( gUploadFiles[0].name ) );
break;
default:
questioningCancel();
break;
}
}
function cbDownloadCurFile()
{
uploadFile( gUploadFiles[0] );
}
function setAnswerForAll( type, foldername )
{
if ( "folder" == type || 0 >= gConflictHandling[type] )
{
return;
}
else
{
gConflictHandling[type] = ( jxl.getChecked( "forAllCheckBox" ) ) ? gConflictHandling[type] + 1 : gConflictHandling[type] - 1;
}
if ( 6 < gConflictHandling[type] )
{
gConflictHandling[type] = 6;
}
else if ( 1 > gConflictHandling[type] )
{
gConflictHandling[type] = 1;
}
}
function setAnswer( answer, type, foldername )
{
if ( "file" == type )
{
gConflictHandling[type] = ( jxl.getChecked( "forAllCheckBox" ) ) ? answer + 1 : answer;
}
else
{
gConflictHandling[type] = answer;
}
jxl.disableNode( "idBtnUpload", false );
}
function showUploadFaildFiles()
{
var headObj = jxl.get( "disable_main_page_content_head" );
var middleObj = jxl.get( "disable_main_page_content_middle" );
var footObj = jxl.get( "disable_main_page_content_foot" );
var oldHeadContent = headObj.innerHTML;
var oldMiddleContent = middleObj.innerHTML;
var oldFootContent = footObj.innerHTML;
var newHead = '<b>';
newHead += '{?8053:776?}</b>';
var newMiddle = '<hr><div class="fail_files_box">';
for ( var idx = 0; idx < gFailedUploadFiles.length; idx++ )
{
if ( gFailedUploadFiles[idx].webkitRelativePath &&
"" != gFailedUploadFiles[idx].webkitRelativePath &&
"." == gFailedUploadFiles[idx].name )
{
newMiddle += gFailedUploadFiles[idx].webkitRelativePath + '<br>';
}
else
{
newMiddle += gFailedUploadFiles[idx].name + '<br>';
}
}
newMiddle += '</div>';
var newFoot = '<button tabindex="1" id="idBtnClose" type="button">{?8053:142?}</button>';
fillBoxContent( newHead, newMiddle, newFoot );
footObj.children[0].addEventListener( "click", function() {
fillBoxContent( oldHeadContent, oldMiddleContent, oldFootContent );
}, false );
}
function createUploadError( errorObj )
{
var folderErrorCnt = 0;
var fileErrorCnt = 0;
for ( var idx = 0; idx < gFailedUploadFiles.length; idx++ )
{
if ( gFailedUploadFiles[idx].webkitRelativePath &&
"" != gFailedUploadFiles[idx].webkitRelativePath &&
"." == gFailedUploadFiles[idx].name )
{
folderErrorCnt++;
}
else
{
fileErrorCnt++;
}
}
var tmpTxt = "";
var errTxt = "";
tmpTxt += '<a href="javascript:showUploadFaildFiles()">';
if ( 0 < folderErrorCnt && 0 < fileErrorCnt )
{
if ( 1 == fileErrorCnt )
{
tmpTxt += jxl.sprintf( '{?8053:109?}', folderErrorCnt );
}
else
{
tmpTxt += jxl.sprintf( '{?8053:720?}', folderErrorCnt, fileErrorCnt );
}
tmpTxt += '</a>';
errTxt = "<br>{?8053:644?}";
}
else if ( 1 > fileErrorCnt )
{
if ( 1 == folderErrorCnt )
{
tmpTxt += '{?8053:311?}';
}
else
{
tmpTxt += jxl.sprintf( '{?8053:952?}', folderErrorCnt );
}
tmpTxt += '</a>';
errTxt = "<br>{?8053:805?}";
}
else if ( 1 > folderErrorCnt)
{
if ( 1 == fileErrorCnt)
{
tmpTxt += jxl.sprintf( '{?8053:557?}');
}
else
{
tmpTxt += jxl.sprintf( '{?8053:852?}', fileErrorCnt );
}
tmpTxt += '</a>';
errTxt = "<br>{?8053:197?}";
}
tmpTxt += "<p>{?8053:845?}" + errTxt + "</p>";
errorObj.innerHTML += tmpTxt;
}
function uploadNextFile()
{
if ( gUploadFiles.length )
{
var fileId = gUploadFiles[0].name;
var conflictFolderName = "";
var type = "file";
if ( gUploadFiles[0].webkitRelativePath && "" != gUploadFiles[0].webkitRelativePath )
{
fileId = gUploadFiles[0].webkitRelativePath.substring( 0, gUploadFiles[0].webkitRelativePath.indexOf( "/" ) );
type = "folder";
drawProgressBar( 0, "aktFileProgressBox", gUploadFiles[0].webkitRelativePath );
}
else
{
drawProgressBar( 0, "aktFileProgressBox", gUploadFiles[0].name );
}
if ( gCurDirFiles[fileId] )
{
if ( 0 == gConflictHandling[type] )
{
var headlineTxt = jxl.sprintf( '{?5116:926?}', gUploadFiles[0].name );
var overwriteTxt = '{?5116:243?}';
var ignoreTxt = '{?5116:586?}';
var renameTxt = '{?5116:124?}';
if ( "folder" == type )
{
headlineTxt = jxl.sprintf( '{?5116:927?}', fileId );
overwriteTxt = '{?5116:33?}';
ignoreTxt = '{?5116:215?}';
renameTxt = '{?5116:712?}';
}
gOldUploadHtml = jxl.get( "disable_main_page_content_middle" ).innerHTML;
var questionContent = '<hr>' + headlineTxt;
questionContent += '<div><p>{?5116:950?}</p>';
questionContent += '<input type="radio" onclick="setAnswer( 1, \'' + type + '\', \'' + fileId + '\' )" id="overwrite" name="uploadQuestion"><label for="overwrite">' + overwriteTxt + '</label><br>';
questionContent += '<input type="radio" onclick="setAnswer( 3, \'' + type + '\', \'' + fileId + '\' )" id="ignore" name="uploadQuestion"><label for="ignore">' + ignoreTxt + '</label><br>';
if ( "file" == type )
{
questionContent += '<input type="radio" onclick="setAnswer( 5, \'' + type + '\', \'' + fileId + '\' )" id="uploadRename" name="uploadQuestion"><label for="uploadRename">' + renameTxt + '</label><br>';
questionContent += '<br><input type="checkbox" id="forAllCheckBox" onclick="setAnswerForAll( \'' + type + '\', \'' + fileId + '\' )"><label for="forAllCheckBox">{?8053:716?}</label>';
}
questionContent += '</div>';
var uploadBtn = jxl.get( "idBtnUpload" );
uploadBtn.innerHTML = "{?5116:355?}";
uploadBtn.onclick = function() {
onUploadQuestion( type );
};
if ( gDragAndDrop )
{
jxl.display( uploadBtn, true );
}
jxl.get( "idBtnCancel" ).onclick = function() { questioningCancel(); };
jxl.get( "disable_main_page_content_middle" ).innerHTML = questionContent;
}
else if ( 4 == gConflictHandling["file"] || 3 == gConflictHandling["folder"] )
{
updateFileProgress( gUploadFiles[0].cntSize, gUploadFiles[0].cntSize );
gUploadTotalProgress += gUploadFiles[0].cntSize;
gUploadFiles.shift();
uploadNextFile();
}
else if ( 6 == gConflictHandling[type] )
{
uploadFile( gUploadFiles[0], getRealFileName( gUploadFiles[0].name ) );
}
else
{
uploadFile( gUploadFiles[0] );
}
}
else
{
uploadFile( gUploadFiles[0] );
}
}
else
{
if ( gDragAndDrop && 0 >= gUploadTotalProgress )
{
jxl.get( "copyBoxHeadline" ).innerHTML = '{?5116:90?}';
jxl.get( "aktFileProgressBox" ).innerHTML = '{?5116:536?}<br>';
jxl.get( "totalProgressBox" ).innerHTML = "";
}
else if ( 0 < gFailedUploadFiles.length )
{
if ( gDragAndDrop )
{
jxl.get( "copyBoxHeadline" ).innerHTML = "";
}
var tmpObj = jxl.get( "aktFileProgressBox" );
tmpObj.innerHTML = '<p>{?8053:771?}</p>';
createUploadError( tmpObj );
}
else
{
if ( gDragAndDrop )
{
jxl.get( "copyBoxHeadline" ).innerHTML = "";
}
jxl.get( "aktFileProgressBox" ).innerHTML = '{?5116:289?}';
}
uploadFinished();
}
}
function disableFileSelectors( disable )
{
jxl.disableNode( "chooseUploadFile", disable );
jxl.disableNode( "chooseUploadFolder", disable );
}
function uploadFilesOrFolder( copyRest, dropBoxFiles )
{
if ( !( true === copyRest && 0 < gUploadFiles.length ) )
{
var uploadFiles = null;
var folder = null;
if ( dropBoxFiles )
{
uploadFiles = dropBoxFiles;
}
else
{
uploadFiles = jxl.get( "chooseUploadFile" );
folder = jxl.get( "chooseUploadFolder" );
}
gUploadTotalFileSize = 0;
gUploadTotalProgress = 0;
gUploadFiles = [];
if ( uploadFiles && uploadFiles.files && 0 < uploadFiles.files.length )
{
for ( idx in uploadFiles.files )
{
if ( "number" == typeof( uploadFiles.files[idx].size ) )
{
gUploadFiles.push( uploadFiles.files[idx] );
gUploadFiles[gUploadFiles.length - 1].cntSize = gUploadFiles[gUploadFiles.length - 1].size;
if ( 1 > gUploadFiles[gUploadFiles.length - 1].cntSize )
{
gUploadFiles[gUploadFiles.length - 1].cntSize = 1;
}
gUploadTotalFileSize += gUploadFiles[gUploadFiles.length - 1].cntSize;
}
}
if ( !gDragAndDrop )
{
jxl.get( "fileSelection" ).innerHTML = jxl.get( "fileSelection" ).innerHTML;
}
}
if ( folder )
{
for ( idx in folder.files )
{
if ( "number" == typeof( folder.files[idx].size ) )
{
gUploadFiles.push( folder.files[idx] );
gUploadFiles[gUploadFiles.length - 1].cntSize = gUploadFiles[gUploadFiles.length - 1].size;
if ( 1 > gUploadFiles[gUploadFiles.length - 1].cntSize )
{
gUploadFiles[gUploadFiles.length-1].cntSize = 1;
}
gUploadTotalFileSize += gUploadFiles[gUploadFiles.length - 1].cntSize;
}
}
if ( !gDragAndDrop )
{
jxl.get( "folderSelection" ).innerHTML = jxl.get( "folderSelection" ).innerHTML;
}
}
}
if ( gl.ds_free > gUploadTotalFileSize )
{
if ( 0 < gUploadFiles.length )
{
gMmInfoInterval = window.clearTimeout( gMmInfoInterval );
disableFileSelectors( true );
jxl.disableNode( "idBtnUpload", true );
jxl.display( "idBtnContinue", false );
var cancelBtn = jxl.get( "idBtnCancel" )
if ( cancelBtn )
{
cancelBtn.innerHTML = "{?5116:134?}";
cancelBtn.onclick = function () { uploadCancel(); };
}
drawProgressBar( 0, "totalProgressBox", gProgressAllTxt );
uploadNextFile();
}
}
else
{
var errorTxt = "{?5116:710?}";
if ( gDragAndDrop )
{
jxl.get( "copyBoxHeadline" ).innerHTML = errorTxt;
jxl.get( "aktFileProgressBox" ).innerHTML = "";
jxl.get( "totalProgressBox" ).innerHTML = "";
}
else
{
jxl.get( "aktFileProgressBox" ).innerHTML = errorTxt;
jxl.get( "totalProgressBox" ).innerHTML = "";
}
}
}
function fillgCurDirFiles()
{
gCurDirFiles = {};
for ( var idx in gCurItems[gCurNasDir] )
{
var id = gCurItems[gCurNasDir][idx].filename;
gCurDirFiles[id] = {};
gCurDirFiles[id].path = gCurItems[gCurNasDir][idx].path;
gCurDirFiles[id].type = ( "D" == gCurItems[gCurNasDir][idx].type || "directory" == gCurItems[gCurNasDir][idx].type ) ? "D" : "F" ;
gCurDirFiles[id].size = parseInt( gCurItems[gCurNasDir][idx].size, 10 ) || 0;
}
}
function uploadClose( filesLoaded )
{
fillBoxContent( "", "", "" );
uploadCancel();
gConflictHandling = { file:0, folder:0 };
gOldUploadHtml = "";
gUploadTotalFileSize = 0;
gUploadTotalProgress = 0;
gUploadFiles = null;
gCurDirFiles = null;
gFailedUploadFiles = null;
if ( fileApiSupport() )
{
gDisableMainPageBox.close();
}
else
{
gDisableMainPageFormBox.close();
}
if ( filesLoaded || gDragAndDrop )
{
refreshPageContent();
}
}
function enableDisableUploadBtn( evt )
{
var disableBtn = false;
if ( fileApiSupport() )
{
var noFiles = !jxl.get( "chooseUploadFile" ) || 1 > jxl.get( "chooseUploadFile" ).files.length;
var noFolder = !jxl.get( "chooseUploadFolder" ) || 1 > jxl.get( "chooseUploadFolder" ).files.length;
disableBtn = noFiles && noFolder;
}
else
{
disableBtn = "" == jxl.getValue( "chooseUploadFile" );
}
jxl.disableNode( "idBtnUpload", disableBtn || !jxl.getEnabled( "idBtnCancel" ) );
}
function onFirstCopyClick()
{
gFailedUploadFiles = [];
uploadFilesOrFolder( false );
}
function onUploadClick( evt, dropBoxFiles )
{
var head = '<b>{?5116:620?}</b>';
var body = "";
var foot = "";
gDragAndDrop = false;
if ( gl.write_rights )
{
if ( dropBoxFiles )
{
if ( fileApiSupport() )
{
if ( "first" == gDisableMainPageBox )
{
gDisableMainPageBox = createModalBox( createBoxContent() );
}
body = '<hr><p id="copyBoxHeadline">{?5116:340?}</p>';
body += '<br>';
body += '<div id="aktFileProgressBox"></div>';
body += '<div id="totalProgressBox"></div>';
foot = '<button tabindex="2" id="idBtnContinue" type="button" onclick="uploadFilesOrFolder( true );" style="display:none;">{?5116:648?}</button>';
foot += '<button tabindex="3" id="idBtnUpload" type="button" onclick="onFirstCopyClick();" style="display:none;" disabled>{?5116:700?}</button>';
}
else
{
return false;
}
}
else if ( fileApiSupport() )
{
if ( "first" == gDisableMainPageBox )
{
gDisableMainPageBox = createModalBox( createBoxContent() );
}
body = '<hr><p>{?5116:999?}</p>';
body += '<div id="fileSelection"><input type="file" tabindex="1" name="UploadFile" id="chooseUploadFile" onchange="enableDisableUploadBtn()" size="50" multiple></div>';
if ( folderApiSupport() )
{
body += '<p>{?5116:699?}</p>';
body += '<p>{?5116:298?}</p>';
body += '<div id="folderSelection"><input type="file" tabindex="2" name="UploadFolder" id="chooseUploadFolder" onchange="enableDisableUploadBtn()" size="50" webkitdirectory directory></div>';
}
body += '<br>';
body += '<div id="aktFileProgressBox"></div>';
body += '<div id="totalProgressBox"></div>';
foot = '<button tabindex="2" id="idBtnContinue" type="button" onclick="uploadFilesOrFolder( true );" style="display:none;">{?5116:640?}</button>';
foot += '<button tabindex="3" id="idBtnUpload" type="button" onclick="onFirstCopyClick();" disabled>{?5116:686?}</button>';
}
else
{
if ( "first" == gDisableMainPageFormBox )
{
gDisableMainPageFormBox = createModalBox( createBoxContent( "form" ) );
}
body = '<hr><input type="hidden" name="sid" value="' + gl.sid + '">';
body += '<input type="hidden" name="dir" value="'+ gCurNasDir +'">';
body += '<input type="hidden" name="ResultScript" value="index.lua">';
body += '<p>{?5116:60?}</p>';
body += '<input type="file" tabindex="1" name="UploadFile" id="chooseUploadFile" onchange="enableDisableUploadBtn()" size="50" >';
foot = '<button tabindex="2" id="idBtnUpload" type="submit" name="Upload" onclick="disableSingleUploadBox(); return true;" disabled>{?5116:350?}</button>';
}
}
else
{
if ( "first" == gDisableMainPageBox )
{
gDisableMainPageBox = createModalBox( createBoxContent() );
}
body += '<p>{?5116:456?}</p>';
}
foot += '<button tabindex="4" id="idBtnCancel" type="button" onclick="uploadClose( false );">{?5116:384?}</button></div>';
fillBoxContent( head, body, foot );
fillgCurDirFiles();
if ( fileApiSupport() )
{
gDisableMainPageBox.open();
if ( dropBoxFiles )
{
gDragAndDrop = true;
gFailedUploadFiles = [];
uploadFilesOrFolder( false, dropBoxFiles );
}
}
else
{
gDisableMainPageFormBox.open();
}
}
