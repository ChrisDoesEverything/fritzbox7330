<?lua
if not gl or not gl.logged_in then
box.end_page()
end
box.out([[<!-- MainMenu. -->]])
function get_used_space_all()
local global_used = 0;
if gl.bib.store.internal_memory_available() then
global_used = global_used + (tonumber(box.query("usbdevices:settings/internalflash/usedspace")) or 0)
end
if gl.bib.store.check_usb_useable() then
local usb_dev = gl.bib.store.get_usb_devices_list()
for i,v in ipairs(usb_dev) do
global_used = global_used + tonumber(v.usedspace)
end
if box.query("webdavclient:settings/enabled")=="1" then
global_used = global_used + (tonumber(box.query("webdavclient:status/storage_quota_used")) or 0)
end
end
return global_used
end
local logo_class = ""
if config.oem == "ewetel" then logo_class = [[class="oemlogo_ewetel"]] end
box.out([[
<div id="mm_balken_box">
<div id="mm_balken">
<div id="mm_links" ]]..logo_class..[[></div>
<div id="mm_boxinfo">
]])
if not gl.filelink_mode then
box.out([[<p>]]..box.tohtml(box.query("box:settings/hostname"))..[[</p>
<p>]]..box.tohtml(config.PRODUKT_NAME)..[[</p>
]])
end
box.out([[
</div>
<div id="mm_mitte"></div>
</div>
<div id="mm_info_box"></div>
<div id="mm_link_box">
]])
box.out([[<div id="sideMenu">]])
if gl.logged_in and not gl.filelink_mode then
if gl.show_logout then
require"sso_dropdown"
sso_dropdown.write_head()
box.out([[ | ]])
end
box.out([[<a class="mm_link_bold" href="]]..gl.bib.href.get_zone_link('box')..[[">]]..box.tohtml(TXT([[{?917:542?}]]))..[[</a> |
<a class="mm_link_selected mm_link_bold" href="]]..gl.bib.href.get_zone_link('nas')..gl.bib.gpl.get_parameter_line_for_link({})..[["><span>]]..box.tohtml(TXT([[{?917:213?}]]))..[[</span></a>]])
box.out([[ | <a class="mm_link_bold" href="]]..gl.bib.href.get_zone_link('myfritz')..[[">]]..box.tohtml(TXT([[{?917:1?}]]))..[[</a>]])
box.out([[ | ]])
end
local onclick_str = [[onclick="window.open('', 'HelpWindow', 'width=1024,height=600,resizable=yes,scrollbars=yes,toolbar=yes,location=yes');"]]
box.out([[<a target="HelpWindow" ]]..onclick_str..[[ href="/nas/index.lua]]..gl.bib.gpl.get_parameter_line_for_link({site="help",helppage="hilfe_speicher_fritz_nas.html"})..[[" title="]]..box.tohtml([[{?txtHelp?}]])..[[" class="iconHelp"><img alt="" src="/nas/css/]]..box.tohtml(gl.var.style)..[[/images/icon_hilfe.png"></a>]])
box.out([[</div></div>]])
box.out([[<form id="reloadPage" method="post" action="/nas/index.lua">]]..gl.bib.gpl.get_parameter_line_for_form({})..[[</form>]])
box.out([[</div>]])
?>
<script type="text/javascript">
var jsonInfo = makeJSONParser();
var gIndexSearch = "";
var g_ScanInfoActiv=false;
var gMmInfoInterval = null;
function firstInfoData()
{
if (gl.logged_in) gMmInfoInterval = window.setTimeout(doInfoRequest, 1000);
}
ready.onReady( firstInfoData );
function show_scan_state_info(resp)
{
var index_creation_running = false
for (i = 0; i < resp.length; i++)
{
if ( (resp[i].partition_scan_status && (resp[i].partition_scan_status == "scan running" || resp[i].partition_scan_status == "update running" || resp[i].partition_scan_status == "error")) ||
(resp[i].scan_status && (resp[i].scan_status == "scan running" || resp[i].scan_status == "update running" || resp[i].scan_status == "error")) )
{
index_creation_running = true
break
}
}
jxl.display("mm_scan_info", index_creation_running);
}
function infoCallbackState( response )
{
if (response && response.status == 200)
{
try
{
var resp = jsonInfo(response.responseText);
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
if (resp[0] && resp[0].scan_status)
{
show_scan_state_info(resp);
}
else if(resp[0] && resp[0].partition_scan_status)
{
show_scan_state_info(resp);
refreshScanInfo(resp);
}
}
if(!gMmInfoInterval) gMmInfoInterval = window.setTimeout(doInfoRequest, 10000);
}
}
function doInfoRequest()
{
gMmInfoInterval = window.clearTimeout(gMmInfoInterval);
var scan_detail = "0";
if (g_ScanInfoActiv)
{
scan_detail = "1";
}
var parameter = [];
parameter.push( encodeURIComponent( "sid" ) + "=" + encodeURIComponent( gl.sid ) );
parameter.push( encodeURIComponent( "scan_detail" ) + "=" + encodeURIComponent( scan_detail ) );
ajaxPost( encodeURI( "/nas/get_scan_info.lua" ), parameter.join( "&" ), infoCallbackState );
}
function get_status(status)
{
var str = "{?917:6?}";
switch(status)
{
case 'scan running':
str = "{?917:611?}";
break;
case 'update running':
str = "{?917:235?}";
break;
case 'failed':
str = "{?917:906?}";
break;
case 'inactive':
str = "{?917:719?}";
break;
case 'complete':
str = "{?917:761?}";
break;
}
return str;
}
function refreshScanInfo(resp)
{
var head = '<h2>{?917:479?}</h2>';
var middle = '';
var total_file_count = 0;
var total_mediafile_count = 0;
if (gl.from_internet)
{
middle = "<div>{?917:545?}: ";
if (resp[i].partition_scan_status=="scan running")
middle += "{?917:510?}";
else if (resp[i].partition_scan_status=="update running")
middle += "{?917:149?}";
else if (resp[i].partition_scan_status=="complete")
middle += "{?917:200?}";
else
middle += "{?917:219?}";
middle += "</div><br>";
}
else
{
for (i=0; i < resp.length; i++)
{
partition = resp[i].partition_path.substring(15);
if (partition==null || partition=="")
partition = "{?917:36?}";
var cnt_audio = parseInt(resp[i].partition_audio_count);
if (cnt_audio < 0)
cnt_audio = 0;
var cnt_video = parseInt(resp[i].partition_video_count);
if (cnt_video < 0)
cnt_video = 0;
var cnt_image = parseInt(resp[i].partition_image_count);
if (cnt_image < 0)
cnt_image = 0;
var cnt_other = parseInt(resp[i].partition_other_count);
if (cnt_other < 0)
cnt_other = 0;
var cnt_doc = parseInt(resp[i].partition_doc_count);
if (cnt_doc < 0)
cnt_doc = 0;
var media_files = cnt_audio + cnt_video + cnt_image;
var all_files = media_files + cnt_doc + cnt_other;
var in_progress = (resp[i].partition_scan_status=="scan running" || resp[i].partition_scan_status=="update running");
var singPluFileTxt = '{?917:523?}';
if ((resp[i].partition_total_file_count < 1 && all_files == 1) || resp[i].partition_total_file_count == 1 )
singPluFileTxt = '{?917:632?}';
middle += '<div>';
if (in_progress) middle += '<b>';
middle += partition+': ';
if (all_files < 1 && in_progress)
middle += '{?917:1389?}';
else
middle += get_status(resp[i].partition_scan_status);
if (in_progress && all_files > 0)
{
middle += ', '+all_files;
if (resp[i].partition_total_file_count > 0)
middle += ' von '+resp[i].partition_total_file_count;
middle += ' '+singPluFileTxt;
}
if (resp[i].partition_scan_status=="complete")
middle += ', '+all_files+' '+singPluFileTxt+' {?917:576?}';
if (in_progress) middle += '</b>';
middle += '</div><br>';
total_file_count += all_files;
total_mediafile_count += media_files;
}
var singPluAllFileTxt = jxl.sprintf('{?917:701?}',total_file_count ,total_mediafile_count );
if (total_mediafile_count == 1) singPluAllFileTxt = jxl.sprintf('{?917:258?}',total_file_count ,total_mediafile_count );
if (total_file_count == 1)
{
singPluAllFileTxt = jxl.sprintf('{?917:868?}',total_file_count ,total_mediafile_count );
if (total_mediafile_count == 1) singPluAllFileTxt = jxl.sprintf('{?917:116?}',total_file_count ,total_mediafile_count );
}
middle += '<br><div>'+singPluAllFileTxt+'</div>';
}
var foot = '<button tabindex="2" class="disable_main_page_content_box_btn" id="idBtnCancel" onclick="closeInfo()">{?917:132?}</button>';
fillBoxContent(head, middle, foot);
}
function showFirstInfo()
{
var head = '<h2>{?917:560?}</h2>';
var middle = '<div>{?917:793?}</div><br>';
var foot = '<button tabindex="2" class="disable_main_page_content_box_btn" id="idBtnCancel" onclick="closeInfo()">{?917:346?}</button>';
fillBoxContent(head, middle, foot);
doInfoRequest();
}
function showUploadInfo()
{
var head = '<b>{?917:412?}</b>';
var middle = '<div><?lua box.html(gl.upload_error_str) ?></div>';
middle += '<div>{?917:459?} (<?lua box.html(gl.result_code) ?>)</div>';
var foot = '<button tabindex="2" class="disable_main_page_content_box_btn" id="idBtnCancel" onclick="closeInfo()">{?917:93?}</button>';
fillBoxContent(head, middle, foot);
}
function onScanInfoClick()
{
if(gDisableMainPageBox=="first") gDisableMainPageBox = createModalBox(createBoxContent("all"));
g_ScanInfoActiv=true;
showFirstInfo();
gDisableMainPageBox.open();
}
function onUploadInfoClick()
{
if(gDisableMainPageBox=="first") gDisableMainPageBox = createModalBox(createBoxContent("all"));
showUploadInfo();
gDisableMainPageBox.open();
}
function closeInfo()
{
g_ScanInfoActiv=false;
fillBoxContent( "", "", "");
gDisableMainPageBox.close();
}
function sendSearchWord()
{
gSearch = jxl.getValue( "mm_search_word" );
if ( gSearch && 0 < gSearch.length )
{
gSearchItems = null;
gContentDiv.innerHTML = "";
gWaitItem = null;
gSearchSartEntry = 1;
gSearchBrowseMode = "type:directory";
jxl.get( "sm_address_line_desc" ).innerHTML = "{?917:655?}:";
refreshPathDisplay( "/" );
getNasData( gCurNasDir );
}
else
{
gSearch = "";
}
}
function localSearch( file )
{
var toLowerIndexSearch = gIndexSearch.toLowerCase();
return ( -1 < file.filename.toLowerCase().indexOf( toLowerIndexSearch ) ) ||
( -1 < file.showType.toLowerCase().indexOf( toLowerIndexSearch ) ) ||
( -1 < file.mtime.toLowerCase().indexOf( toLowerIndexSearch ) ) ||
( -1 < file.showSize.toLowerCase().indexOf( toLowerIndexSearch ) )
}
function del_search_word()
{
jxl.setValue( "mm_search_word", "" );
checkSearchwordSet();
return false;
}
function checkSearchwordSet()
{
gIndexSearch = jxl.getValue("mm_search_word");
if ( gSearch && 0 < gSearch.length )
{
gSearch = "";
gSearchItems = null;
setSizeInfo( gSize[gCurNasDir].free, gSize[gCurNasDir].total );
jxl.get( "sm_address_line_desc" ).innerHTML = "{?917:109?}:";
refreshPathDisplay( gCurNasDir );
checkEnableBtn();
}
if ( "" == gIndexSearch )
{
jxl.disable( "mm_search_del" );
jxl.display( "mm_searchhint", false );
for ( var i in gCurItems[gCurNasDir] )
{
gCurItems[gCurNasDir][i].showItem = true;
}
}
else
{
jxl.enable( "mm_search_del" );
jxl.display( "mm_searchhint", true );
for ( var i in gCurItems[gCurNasDir] )
{
gCurItems[gCurNasDir][i].showItem = localSearch( gCurItems[gCurNasDir][i] );
}
}
drawNasDataFromCache( gCurNasDir );
resumeGetData( gStartEntry[gCurNasDir], gCurNasDir );
}
function fillInSearch( evt )
{
evt = evt || window.event;
var search = jxl.get( "mm_search_word" );
var siteDisabled = gAktDisableBox || jxl.get( "galeryBox" ) || jxl.get( "videoPlayerBox" );
if ( !siteDisabled )
{
var keyCode = 0;
if( evt.keyCode )
{
keyCode = evt.keyCode;
}
else if ( evt.which )
{
keyCode = evt.which;
}
else if ( evt.charCode )
{
keyCode = evt.charCode;
}
if ( 13 == keyCode )
{
if ( evt && evt.stopPropagation )
{
evt.stopPropagation();
}
if ( evt && evt.preventDefault )
{
evt.preventDefault();
}
sendSearchWord();
return;
}
else if ( 27 == keyCode )
{
del_search_word();
}
}
if ( !siteDisabled && "files" == gl["var"].site && !search.disabled && document.activeElement != search )
{
search.focus();
}
}
document.addEventListener( "keydown", fillInSearch, false );
</script>
<!-- MainMenuEND -->
