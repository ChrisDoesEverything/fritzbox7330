var jsonBrowse = makeJSONParser();
var emailTab = null;
var gMmInfoBox = null;
var gMmCmdInfoBox = null;
var gLastPressedKeyCode = 0;
var gAktDisableBox = null;
var gNothingToPaste = true;
function disablePage( disableBox )
{
gAktDisableBox = disableBox;
disableBox.open();
}
function enablePage()
{
gAktDisableBox.close();
gAktDisableBox = null;
if ( "undefined" == typeof gShares )
{
selectAllFilesAndDirs( false );
}
}
function onDownloadClick( formular )
{
if ( !formular ) formular = jxl.get("sm_multidownload");
if ( !formular ) return;
var items = getCheckedFilesAndDirs();
if ( 0 >= items.length ) return;
selectAllFilesAndDirs( false );
checkEnableBtn();
var files = "";
for ( var idx = 0; idx < items.length; idx++ )
{
files += items[idx].path + gl.delim;
}
formular.elements["sid"].value = gl.sid;
formular.elements["cmd_files"].value = files;
formular.submit();
}
function getFilesAndDirsToDelete( pItem )
{
var items = [];
if ( pItem )
{
items[0] = pItem;
}
else
{
items = getCheckedFilesAndDirs();
}
if ( 0 >= items.length ) return "cancel";
if ( 1 == items.length )
{
var delTxt = jxl.sprintf('{?2422:936?}', items[0].filename );
if ( "directory" == items[0].type || "D" == items[0].type )
{
delTxt = jxl.sprintf('{?2422:512?}', items[0].filename );
}
if( false == confirm( delTxt ) ) return "cancel";
}
else
{
if ( false == confirm( jxl.sprintf( '{?2422:241?}', items.length ) ) ) return "cancel";
}
var files = "";
for ( var idx = 0; idx < items.length; idx++ )
{
files += items[idx].path + gl.delim;
}
var parameter = [];
parameter.push( encodeURIComponent( "sid" ) + "=" + encodeURIComponent( gl.sid ) );
parameter.push( encodeURIComponent( "script" ) + "=" + encodeURIComponent( "/index.lua" ) );
parameter.push( encodeURIComponent( "cmd" ) + "=" + encodeURIComponent( "delete" ) );
parameter.push( encodeURIComponent( "cmd_files" ) + "=" + encodeURIComponent( files ) );
ajaxPost( encodeURI( "/nas/cgi-bin/luacgi_notimeout" ), parameter.join( "&" ), cbCmdErrorHandling );
}
function createNewDir()
{
if ( "first" == gDisableMainPageBox_newdir )
{
gDisableMainPageBox_newdir = createModalBox( createBoxContent( "newdir", "renew" ) );
jxl.get("disable_page_new_name_newdir").onkeydown = checkEnterPressed;
}
disablePage( gDisableMainPageBox_newdir );
jxl.get( "disable_page_new_name_newdir" ).value = "";
jxl.get( "idBtnOknewdir").disabled = true;
}
function createFilelink( pItem )
{
var items = [];
if ( pItem )
{
items[0] = pItem;
}
else
{
items = getCheckedFilesAndDirs();
}
if ( 1 == items.length )
{
if ( "first" == gDisableMainPageBox ) gDisableMainPageBox = createModalBox( createBoxContent( "all" ) );
fillBoxContent( "<img alt='' src='/nas/css/" + gJsStyle + "/images/please_wait_bright.gif'><br>{?2422:511?}", "{?2422:790?}", "" );
disablePage( gDisableMainPageBox );
var itemType = "F";
if ( "directory" == items[0].type || "D" == items[0].type ) itemType = "D";
var parameter = [];
parameter.push( encodeURIComponent( "sid" ) + "=" + encodeURIComponent( gl.sid ) );
parameter.push( encodeURIComponent( "cmd" ) + "=" + encodeURIComponent( "create_share" ) );
parameter.push( encodeURIComponent( "cmd_files" ) + "=" + encodeURIComponent( itemType + items[0].path + gl.delim ) );
parameter.push( encodeURIComponent( "flname" ) + "=" + encodeURIComponent( itemType + items[0].filename + gl.delim ) );
ajaxPost( encodeURI( "/nas/index.lua" ), parameter.join( "&" ), cbFilelink );
}
}
function refreshFilelink( fileLinkNode )
{
var expireTime = jxl.getValue( "uiValidTime" );
var accessLimit = jxl.getValue( "uiAccessCnt" );
var err = false;
if ( "string" != typeof expireTime || "" == expireTime )
{
expireTime = 0;
}
else
{
expireTime = parseInt( expireTime, 10 );
}
if ( "string" != typeof accessLimit || "" == accessLimit )
{
accessLimit = 0;
}
else
{
accessLimit = parseInt( accessLimit, 10 );
}
if ( isNaN( expireTime ) || 0 > expireTime || 400 < expireTime )
{
jxl.addClass( "uiValidTime", "error" );
jxl.addClass( "validTimeError", "show" );
err = true;
}
else
{
jxl.removeClass( "uiValidTime", "error" );
jxl.removeClass( "validTimeError", "show" );
}
if ( isNaN( accessLimit ) || 0 > accessLimit || 9999 < accessLimit )
{
jxl.addClass( "uiAccessCnt", "error" );
jxl.addClass( "accessCntError", "show" );
err = true;
}
else
{
jxl.removeClass( "uiAccessCnt", "error" );
jxl.removeClass( "accessCntError", "show" );
}
if ( err ) return;
var parameter = [];
parameter.push( encodeURIComponent( "sid" ) + "=" + encodeURIComponent( gl.sid ) );
parameter.push( encodeURIComponent( "cmd" ) + "=" + encodeURIComponent( "ref_share" ) );
parameter.push( encodeURIComponent( "fl_node" ) + "=" + encodeURIComponent( fileLinkNode ) );
parameter.push( encodeURIComponent( "expire" ) + "=" + encodeURIComponent( expireTime ) );
parameter.push( encodeURIComponent( "limit" ) + "=" + encodeURIComponent( accessLimit ) );
ajaxPost( encodeURI( "/nas/index.lua" ), parameter.join( "&" ), cbRefreshFilelink );
if ( gAktDisableBox )
{
enablePage();
}
if ( "undefined" == typeof gShares && !( "string" == typeof days && "string" == typeof accessCnt ) )
{
refreshPageContent();
}
}
function cbRefreshFilelink( response )
{
var err = true;
if ( response && 200 == response.status )
{
var resp = jsonBrowse( response.responseText );
if ( resp && "0" == resp.err_code )
{
err = false;
if ( "share" == gl["var"].site )
{
var reloadPageForm = jxl.get( "reloadPage" );
if( reloadPageForm )
{
reloadPageForm.submit();
}
return;
}
}
}
if ( err )
{
alert( "{?2422:396?}" );
}
}
function closeEmailTab()
{
if (emailTab && emailTab.history.length == 0) emailTab.close();
emailTab = null;
}
function openEmailClient(link)
{
emailTab=window.open('','_blank');
emailTab.location.href = "mailto:?subject="+encodeURIComponent("{?2422:245?}")+"&body="+encodeURIComponent("{?2422:47?} "+link);
setTimeout(closeEmailTab, 100);
}
function showShareLinkDetails( https_active, fileLink, fl_node, flName, days, accessCnt )
{
var editMode = "string" == typeof days && "string" == typeof accessCnt;
if ( !editMode )
{
var items = getCheckedFilesAndDirs();
if ( 1 == items.length )
{
items[0].shared = true;
}
}
var fileLinkName = ' "' + flName + '"';
jxl.setHtml( "disable_main_page_content_head", "<h2>{?2422:222?}" + fileLinkName + "</h2>" );
var httpsWarning = "";
if ( "1" != https_active )
{
httpsWarning = '<p>{?2422:208?}</p><p>{?2422:782?}</p>';
}
var successTxt = "";
if ( !editMode )
{
successTxt = "{?2422:819?}";
}
if ( "string" != typeof days || 0 == days )
{
days = "";
}
if ( "string" != typeof accessCnt || 1 > accessCnt )
{
accessCnt = "";
}
var link = '<h2>{?2422:224?}</h2><p>' + fileLink + ' <button type="button" tabindex="1" class="" id="emailBtn" onclick="openEmailClient(\'' + fileLink + '\');">{?2422:678?}</button></p>';
var infoTxt = "<p>{?2422:517?}</p>";
var validTxt = "<hr><h2>{?2422:7278?}</h2><div class='formular'>";
validTxt += '<label for="uiValidTime">{?2422:22?}</label><input type="text" size="5" tabindex="2" maxlength="3" id="uiValidTime" name="valid_time" value="'+days+'"><label for="uiValidTime">{?2422:280?}</label><p id="validTimeError" class="error">{?2422:792?}</p><br>';
validTxt += '<label for="uiAccessCnt">{?2422:461?}</label><input type="text" size="5" tabindex="3" maxlength="4" id="uiAccessCnt" name="access_cnt" value="'+accessCnt+'"><label for="uiAccessCnt">{?2422:683?}</label><p id="accessCntError" class="error">{?2422:676?}</p>';
validTxt += "</div>";
jxl.setHtml( "disable_main_page_content_middle", "<hr>" + successTxt + link + infoTxt + httpsWarning + validTxt );
var btnOk = '<button type="button" tabindex="4" class="disable_main_page_content_box_btn" id="idBtnOk" onclick="refreshFilelink(\'' + fl_node + '\')">{?2422:3021?}</button>';
var btnCancel = "";
if ( editMode )
{
btnCancel = '<button type="button" tabindex="5" class="disable_main_page_content_box_btn" id="idBtnCancel" onclick="enablePage()">{?2422:831?}</button>';
}
jxl.setHtml( "disable_main_page_content_foot", btnOk + btnCancel );
}
function cbFilelink( response )
{
if (gCgiTimeout) gCgiTimeout = window.clearTimeout(gCgiTimeout);
if (response && response.status == 200)
{
try
{
var resp = jsonBrowse(response.responseText);
}
catch ( evt )
{
var resp = null;
}
if ( resp )
{
if (resp.login && resp.login == "failed")
{
var reloadPageForm = jxl.get("reloadPage");
if(reloadPageForm) reloadPageForm.submit();
return;
}
if (resp.err == "false")
{
showShareLinkDetails(resp.https_active, resp.link, resp.fl_node, resp.fl_name);
}
else
{
jxl.setHtml("disable_main_page_content_head", "{?2422:730?}");
jxl.setHtml("disable_main_page_content_middle", resp.err_msg);
jxl.setHtml("disable_main_page_content_foot", '<button type="button" tabindex="1" class="disable_main_page_content_box_btn" id="idBtnCancel" onclick="enablePage()">{?2422:409?}</button>');
}
}
}
}
function renameFileOrDir()
{
var items = getCheckedFilesAndDirs();
if ( 0 < items.length )
{
if ( "first" == gDisableMainPageBox_rename )
{
gDisableMainPageBox_rename = createModalBox( createBoxContent( "rename", "renew" ) );
jxl.get("disable_page_new_name_rename").onkeydown = checkEnterPressed;
}
disablePage( gDisableMainPageBox_rename );
jxl.get("idBtnOkrename").disabled = false;
var tmpName = items[0].filename;
if ( 1 < items.length && "D" != items[0].type && "directory" != items[0].type )
{
var idx = items[0].filename.lastIndexOf( "." );
if ( 0 < idx )
{
tmpName = items[0].filename.slice( 0, idx );
}
}
jxl.get("disable_page_new_name_rename").value = tmpName;
}
}
function sendRenameNewDir( action )
{
var items = getCheckedFilesAndDirs();
if ( "newdir" == action || ( "rename" == action && 0 < items.length ) )
{
var newName = jxl.get( "disable_page_new_name_" + action ).value;
fillgCurDirFiles();
if ( null == newName || "" == newName || ( "rename" == action && items[0].filename == newName ) || !gCurDirFiles )
{
enablePage();
return;
}
var workItems = newName + gl.delim;
if ( "rename" == action )
{
workItems = "";
for ( var idx = 0; idx < items.length; idx++ )
{
var itemType = "D";
if ( "directory" != items[idx].type && "D" != items[idx].type )
{
itemType = "F";
}
var newFilename = newName;
if ( 1 < items.length )
{
newFilename = createRenameName( newName, "", items[idx].filename, itemType );
}
//Erstellen der namen
if ( gCurDirFiles[newFilename] )
{
if ( "number" == typeof gCurDirFiles[newFilename].suffixCnt )
{
gCurDirFiles[newFilename].suffixCnt++;
}
else
{
gCurDirFiles[newFilename].suffixCnt = 1;
}
var tmpNewFilename = createRenameName( newName, " (" + gCurDirFiles[newFilename].suffixCnt + ")", items[idx].filename, itemType );
while( gCurDirFiles[tmpNewFilename] )
{
gCurDirFiles[newFilename].suffixCnt++;
tmpNewFilename = createRenameName( newName, " (" + gCurDirFiles[newFilename].suffixCnt + ")", items[idx].filename, itemType );
}
newFilename = tmpNewFilename;
}
gCurDirFiles[newFilename] = { type:itemType, path:gCurNasDir + "/" + newFilename, size:0 };
workItems += itemType + items[idx].path + gl.delim + newFilename + gl.delim;
items[idx].locked = true;
if ( items[idx]["domItemlist"] )
{
items[idx]["domItemlist"].filenameBox.innerHTML = newFilename;
jxl.disableNode( items[idx]["domItemlist"], true, false);
}
if ( items[idx]["domItemtile"] )
{
items[idx]["domItemtile"].filenameBox.innerHTML = newFilename;
jxl.disableNode( items[idx]["domItemtile"], true, false);
}
}
}
var parameter = [];
parameter.push( encodeURIComponent( "sid" ) + "=" + encodeURIComponent( gl.sid ) );
parameter.push( encodeURIComponent( "script" ) + "=" + encodeURIComponent( "/index.lua" ) );
parameter.push( encodeURIComponent( "cmd" ) + "=" + encodeURIComponent( action ) );
parameter.push( encodeURIComponent( "cmd_files" ) + "=" + encodeURIComponent( workItems ) );
if ( "newdir" == action )
{
parameter.push( encodeURIComponent( "dir" ) + "=" + encodeURIComponent( gCurNasDir ) );
}
ajaxPost( encodeURI( "/nas/cgi-bin/luacgi_notimeout" ), parameter.join( "&" ), cbCmdErrorHandling );
}
enablePage();
}
function cbCmdErrorHandling( response )
{
if ( gCgiTimeout ) gCgiTimeout = window.clearTimeout( gCgiTimeout );
if ( response && 200 == response.status )
{
try
{
var resp = jsonBrowse( response.responseText );
}
catch ( evt )
{
var resp = null;
}
if ( resp )
{
if ( resp.errors )
{
var errMsg = "";
var errCodes = {};
for ( var idx = 0; idx < resp.errors.length; idx++ )
{
if ( 0 != resp.errors[idx].err_code && !errCodes[resp.errors[idx].err_code] )
{
errMsg += "<p>" + resp.errors[idx].err_msg + "</p>";
if ( 5 > resp.errors[idx].err_code || 8 < resp.errors[idx].err_code )
{
errCodes[resp.errors[idx].err_code] = true;
}
}
}
if ( "" != errMsg )
{
if ( !gMmInfoBox )
{
gMmInfoBox = jxl.get( "mm_info_box" );
}
if ( gMmInfoBox )
{
if ( gMmCmdInfoBox )
{
gMmInfoBox.removeChild( gMmCmdInfoBox );
}
gMmCmdInfoBox = document.createElement( "div" );
gMmCmdInfoBox.id = "mm_cmd_info";
gMmCmdInfoBox.title = "{?2422:470?}";
gMmCmdInfoBox.setAttribute( "class", "mm_info" );
gMmCmdInfoBox.innerHTML = "{?2422:474?}";
gMmCmdInfoBox.addEventListener( "click", function() { onCmdInfoClick( 0, errMsg ); }, false );
gMmInfoBox.appendChild( gMmCmdInfoBox );
}
}
}
else
{
if ( 0 == resp.err_code )
{
if ( "copy" == resp.cmd )
{
gNothingToPaste = false;
jxl.setDisabled( "sm_btn_paste", gSearch && 0 < gSearch.length );
}
else if ( "paste" == resp.cmd )
{
gNothingToPaste = true;
jxl.setDisabled( "sm_btn_paste", true );
}
}
else
{
if ( !gMmInfoBox )
{
gMmInfoBox = jxl.get( "mm_info_box" );
}
if ( gMmInfoBox )
{
if ( gMmCmdInfoBox )
{
gMmInfoBox.removeChild( gMmCmdInfoBox );
}
gMmCmdInfoBox = document.createElement( "div" );
gMmCmdInfoBox.id = "mm_cmd_info";
gMmCmdInfoBox.title = "{?2422:119?}";
gMmCmdInfoBox.setAttribute( "class", "mm_info" );
switch ( resp.cmd )
{
case "delete":
gMmCmdInfoBox.innerHTML = "{?2422:690?}";
break;
case "newdir":
gMmCmdInfoBox.innerHTML = "{?2422:159?}";
break;
case "copy":
gMmCmdInfoBox.innerHTML = "{?2422:567?}";
gNothingToPaste = true;
jxl.setDisabled( "sm_btn_paste", true );
break;
case "paste":
gMmCmdInfoBox.innerHTML = "{?2422:149?}";
gNothingToPaste = true;
jxl.setDisabled( "sm_btn_paste", true );
break;
default:
gMmCmdInfoBox.innerHTML = "{?2422:197?}";
}
gMmCmdInfoBox.addEventListener( "click", function() { onCmdInfoClick( resp.err_code, resp.err_msg ); }, false );
gMmInfoBox.appendChild( gMmCmdInfoBox );
}
}
}
}
}
refreshPageContent();
}
function checkEnterPressed( event )
{
if( !event ) event = event || window.event;
if( event.keyCode ) gLastPressedKeyCode = event.keyCode;
else if ( event.which ) gLastPressedKeyCode = event.which;
else if ( event.charCode ) gLastPressedKeyCode = event.charCode;
}
function checkFileOrDirForForbiddenChar( action )
{
if ( gLastPressedKeyCode == 13 )
{
gLastPressedKeyCode = 0;
sendRenameNewDir( action );
}
else if ( gLastPressedKeyCode == 27 )
{
gLastPressedKeyCode = 0;
enablePage();
}
else
{
var checkString = jxl.get( "disable_page_new_name_" + action ).value;
if ( 255 < checkString.length )
{
checkString = checkString.substr( 0,255 );
jxl.get( "disable_page_new_name_" + action ).value = checkString;
}
if ( checkString.match( /\/|\\|\:|\*|\?|\"|\<|\>|\|/g ) )
{
jxl.get( "disable_page_new_name_" + action ).value = checkString.replace( /\/|\\|\:|\*|\?|\"|\<|\>|\|/g, "" );
jxl.get( "check_file_or_dir_for_forbidden_char_error_" + action ).innerHTML = "{?2422:6699?} \/ \\ \: \* \? \" \< \> \|"
}
jxl.get( "idBtnOk" + action ).disabled = ( "" == checkString );
}
}
function copyData()
{
var items = getCheckedFilesAndDirs();
if ( 0 >= items.length ) return;
var files = "";
for ( var idx = 0; idx < items.length; idx++ )
{
files += items[idx].path + gl.delim;
}
var parameter = [];
parameter.push( encodeURIComponent( "sid" ) + "=" + encodeURIComponent( gl.sid ) );
parameter.push( encodeURIComponent( "script" ) + "=" + encodeURIComponent( "/index.lua" ) );
parameter.push( encodeURIComponent( "cmd" ) + "=" + encodeURIComponent( "copy" ) );
parameter.push( encodeURIComponent( "cmd_files" ) + "=" + encodeURIComponent( files ) );
ajaxPost( encodeURI( "/nas/cgi-bin/luacgi_notimeout" ), parameter.join( "&" ), cbCmdErrorHandling );
}
function pasteData()
{
var parameter = [];
parameter.push( encodeURIComponent( "sid" ) + "=" + encodeURIComponent( gl.sid ) );
parameter.push( encodeURIComponent( "script" ) + "=" + encodeURIComponent( "/index.lua" ) );
parameter.push( encodeURIComponent( "cmd" ) + "=" + encodeURIComponent( "paste" ) );
parameter.push( encodeURIComponent( "dir" ) + "=" + encodeURIComponent( gCurNasDir ) );
ajaxPost( encodeURI( "/nas/cgi-bin/luacgi_notimeout" ), parameter.join( "&" ), cbCmdErrorHandling );
}
function checkEnableBtn()
{
var count = getCheckedFilesAndDirsCount(),
search = gSearch && 0 < gSearch.length,
paste = jxl.get( "sm_btn_paste" ),
cut = jxl.get( "sm_btn_cut" ),
del = jxl.get( "sm_btn_delete" ),
rename = jxl.get( "sm_btn_rename" ),
upload = jxl.get( "sm_btn_upload" ),
newdir = jxl.get( "sm_btn_newdir" );
if ( gl.write_rights )
{
cut.title = "{?2422:620?}";
paste.title = "{?2422:860?}";
del.title = "{?2422:170?}";
rename.title = "{?2422:68?}";
newdir.title = "{?2422:521?}";
upload.title = "{?2422:261?}";
}
else
{
var tmp = "{?2422:735?}"
cut.title = tmp;
paste.title = tmp;
del.title = tmp;
rename.title = tmp;
newdir.title = tmp;
upload.title = tmp;
}
jxl.setDisabled( "sm_btn_paste" , gNothingToPaste || search );
jxl.setDisabled( "sm_btn_cut", !gl.write_rights || count < 1 );
jxl.setDisabled( "sm_btn_delete", !gl.write_rights || count < 1 );
jxl.setDisabled( "sm_btn_rename", !gl.write_rights || count < 1 );
jxl.setDisabled( "sm_btn_upload", !gl.write_rights || search );
jxl.setDisabled( "sm_btn_download", (gl["var"].site != "files" && gl["var"].site != "pictures") || count < 1 );
jxl.setDisabled( "sm_btn_create_filelink", count != 1 );
jxl.setDisabled( "sm_btn_newdir", !gl.write_rights || count != 0 || search );
if ( 0 == count )
{
jxl.setChecked( "file_list_select_all", false );
}
}
function refreshPage()
{
if ( jxl.get( "content_show_files" ) && gCurNasDir ) changeNasDir( gCurNasDir );
}
function refreshPageContent()
{
gTmpCurItems = null;
if ( "undefined" != typeof gSearch && gSearch && 0 < gSearch.length )
{
gSearchItems = [];
gSearchSartEntry = 1;
gSearchBrowseMode = "type:directory";
}
else
{
gCurItems[gCurNasDir] = [];
gStartEntry[gCurNasDir] = 1;
gBrowseMode[gCurNasDir] = "type:directory";
}
getNasData( gCurNasDir );
}
function onCmdInfoClick( errCode, errMsg )
{
if ( "first" == gDisableMainPageBox ) gDisableMainPageBox = createModalBox( createBoxContent( "all" ) );
var head = '<b>{?2422:445?}</b>';
var middle = '<div>' + errMsg + '</div>';
var foot = '<button tabindex="2" class="disable_main_page_content_box_btn" id="idBtnCancel" onclick="closeCmd()">{?2422:639?}</button>';
fillBoxContent( head, middle, foot );
disablePage( gDisableMainPageBox );
}
function closeCmd()
{
if ( gMmInfoBox && gMmCmdInfoBox )
{
gMmInfoBox.removeChild( gMmCmdInfoBox );
gMmCmdInfoBox = null;
}
fillBoxContent( "", "", "" );
enablePage();
}
