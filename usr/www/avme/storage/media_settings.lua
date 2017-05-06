<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_mediaserver_einstellungen.html"
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require("store")
require("general")
require("http")
require("cmtable")
require("val")
require("href")
conv = require("convert_file_size")
g_back_to_page = http.get_back_to_page( "/storage/media_settings.lua" )
g_err_addon=[[{?966:71?}]]
g_all_media=[[{?966:924?}]]
g_hint_txt = [[{?txtHinweis?}]]
g_synch_txt = [[{?966:883?} ]]
g_wait_txt = [[{?966:780?}]]
g_synchro = false
g_is_online = true
function get_all_var()
g_ctlmgr =
{
mediasrv_enabled = box.query("mediasrv:settings/enabled"),
mediasrv_name = box.query("mediasrv:settings/name"),
mediasrv_path = box.query("mediasrv:settings/homedir"),
mediasrv_path_status = box.query("mediasrv:settings/homedir_status"),
mediasrv_status = box.query("plugin:status/mediasrv"),
nas_enabled = box.query("ctlusb:settings/ftp-server-enabled") == "1" and ((not config.SAMBA) or (config.SAMBA and box.query("ctlusb:settings/samba-server-enabled") == "1")),
google_enabled = box.query("gpmsrv:settings/enabled") == "1",
google_mail = box.query("gpmsrv:settings/emailaddress"),
google_pw = box.query("gpmsrv:settings/password"),
google_servername = box.query("gpmsrv:settings/servername"),
google_part = box.query("gpmsrv:settings/partition"),
cds_enabled = box.query("mediasrv:settings/cds_enabled"),
t_media_enabled = box.query("t_media:settings/enabled"),
partition_status = box.query("gpmsrv:settings/partition_status")
}
require("connection")
g_coninf_data = connection.get_conn_inf_part()
g_is_online = connection.Ppp_Led() == "1"
if box.post.gpm or not box.post.btn_save and g_ctlmgr.google_enabled then
local google_db_status = tonumber(box.query("gpmsrv:settings/build_db_status")) or 0
if google_db_status > 0 and google_db_status < 90 then
g_synchro = true
end
end
end
get_all_var()
function check_param(name)
local s=string.find(name,"_i$")
if (s) then
return false
end
if (name=="add_media_path") then
return false
end
if (name=="add_inet_path") then
return false
end
if (name=="media_srv_path") then
return false
end
return true
end
function refill_user_input_from_post()
if box.post.use_mediasrv then
g_ctlmgr.mediasrv_enabled="1"
else
g_ctlmgr.mediasrv_enabled="0"
end
if box.post.media_srvname then
g_ctlmgr.mediasrv_name=box.post.media_srvname
end
if (box.post.mediapath) then
g_ctlmgr.mediasrv_path=box.post.mediapath
end
if box.post.cur_mediapath then
g_ctlmgr.mediasrv_path=box.post.cur_mediapath
end
end
function storage_count()
local storage_count = 0
local usb_devices = store.get_usb_devices_list()
for i,v in ipairs(usb_devices) do
if v.devtype == "storage" then
if v.any_log and not(store.aura_for_storage_aktiv()) then
storage_count = storage_count + #v.log_vol
end
end
end
return storage_count
end
function get_google_db_status(db_status)
local status_text = ""
if db_status == "10" then
status_text = [[{?966:866?}]]
elseif db_status == "20" then
status_text = [[{?966:688?}]]
elseif db_status == "30" then
status_text = g_synch_txt
elseif db_status == "90" then
status_text = [[{?966:425?}]]
elseif db_status == "100" then
status_text = [[{?966:277?}]]
elseif db_status == "-1" then
status_text = [[{?966:111?}]]
elseif db_status == "-10" then
status_text = [[{?966:761?}]]
elseif db_status == "-20" then
status_text = [[{?966:871?}]]
elseif db_status == "-30" then
status_text = [[{?966:152?}]]
elseif db_status == "-40" then
status_text = [[{?966:774?}]]
elseif db_status == "-110" then
status_text = [[{?966:758?}]]
elseif db_status == "-120" then
status_text = [[{?966:235?}]]
elseif db_status == "-130" then
status_text = [[{?966:439?}]]
elseif db_status == "-140" then
status_text = [[{?966:512?}]]
end
if g_ctlmgr.partition_status == "2" or g_ctlmgr.partition_status == "4" then
status_text = status_text..[[<p>]]..box.tohtml([[{?966:284?}]])..[[</p>]]
end
return status_text
end
g_val = {
prog = [[
if __checked(uiViewUseMediaSrv/use_mediasrv) then
not_empty(uiViewMediaSrvName/media_srvname, mediasrv_error_txt)
end
if __checked(uiGpm/gpm) then
not_all_checked(uigpath/gpath,]]..storage_count()..[[, gpart_error)
end
]]
}
val.msg.mediasrv_error_txt = {
[val.ret.empty] = [[{?966:964?}]]
}
val.msg.gpart_error = {
[val.ret.empty] = [[{?966:636?}]]
}
g_error = ""
if next(box.post) and box.post.btn_save then
local ctlmgr_save={}
if val.validate(g_val) == val.ret.ok then
cmtable.save_checkbox(ctlmgr_save, "mediasrv:settings/enabled" , "use_mediasrv")
if box.post.use_mediasrv then
cmtable.add_var(ctlmgr_save, "mediasrv:settings/name",box.post.media_srvname)
cmtable.add_var(ctlmgr_save, "mediasrv:settings/homedir",box.post.path)
g_ctlmgr.mediasrv_path=box.post.cur_mediapath
cmtable.save_checkbox(ctlmgr_save, "mediasrv:settings/cds_enabled", "1und1")
cmtable.save_checkbox(ctlmgr_save, "t_media:settings/enabled", "tkm")
if box.post.tkm then
local redirect_uri = [[http://fritz.box/storage/oauth.lua?sid=]] .. box.glob.sid
cmtable.add_var(ctlmgr_save, "t_media:settings/redirect_uri", redirect_uri)
end
cmtable.save_checkbox(ctlmgr_save, "gpmsrv:settings/enabled", "gpm")
if box.post.gpm then
cmtable.add_var(ctlmgr_save, "gpmsrv:settings/emailaddress",box.post.google_mail)
cmtable.add_var(ctlmgr_save, "gpmsrv:settings/password",box.post.google_pw)
cmtable.add_var(ctlmgr_save, "gpmsrv:settings/servername",box.post.google_servername)
cmtable.add_var(ctlmgr_save, "gpmsrv:settings/partition",box.post.gpath)
if g_is_online and (box.query("gpmsrv:settings/emailaddress") ~= box.post.google_mail
or box.query("gpmsrv:settings/partition") ~= box.post.gpath or box.post.google_pw ~= "****") then
g_synchro = true
cmtable.add_var(ctlmgr_save, "gpmsrv:settings/build_db", "1")
end
end
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=general.create_error_div(err,msg,g_err_addon)
g_error = criterr
end
get_all_var()
else
refill_user_input_from_post()
end
elseif next(box.post) and box.post.cancel then
local params = box.post.oldparams..'&mediapath='..box.post.oldpath
target = g_back_to_page
local str=href.get(target, params)
http.redirect(str)
return
elseif g_is_online and next(box.post) and box.post.google_refresh then
g_synchro = true
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "gpmsrv:settings/partition", box.post.gpath)
cmtable.add_var(ctlmgr_save, "gpmsrv:settings/build_db", "1")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_error=general.create_error_div(err,msg,g_err_addon)
end
get_all_var()
end
if box.get.ajax and box.get.ajax == "scan" then
require("js")
local response = {}
local db_status = box.query("gpmsrv:settings/build_db_status")
response.db_status = db_status
response.partition_status = g_ctlmgr.partition_status
response.synchro = g_synchro
response.text = ""
local db_status_num = tonumber(db_status)
if 30 <= db_status_num or 0 > db_status_num then
response.text = get_google_db_status(db_status)
else
response.text = g_wait_txt
end
box.out(js.table(response))
box.end_page()
end
local function get_t_media_url()
local link = box.query("t_media:settings/authurl")
local redirect_uri = [[http://fritz.box/storage/oauth.lua?sid=]] .. box.glob.sid
link = link .. [[&]] .. http.url_param("redirect_uri", redirect_uri)
return link
end
function write_t_media_link()
if box.query("t_media:settings/enabled") == "1" then
require"html"
local popup_link = [[window.open("]]..get_t_media_url()..[[", "popup", "width=970,height=600,statusbar,resizable=yes,scrollbars=yes"); return false;]]
html.a{
id="uiTMediaLink", class="textlink popup", href=get_t_media_url(), target="_blank", onclick=popup_link,
[[{?966:669?}]]
}.write()
end
end
function write_t_media_link_js()
local link = ""
if box.query("t_media:settings/enabled") == "0" then
link = get_t_media_url()
end
box.js(link)
end
function write_checked(condition)
if condition then
box.out("checked")
end
end
function write_nas_disabled()
if not g_ctlmgr.nas_enabled then
box.out(" disabled")
end
end
function write_1und1_disabled()
require("webdav")
if not string.find(webdav.wd_data.host_url, webdav.wd_data.einsueins_url) then
box.out([[ disabled="disabled" class="disableNode" ]])
end
end
function write_visible(visible)
if not visible then box.out([[ display:none; ]]) end
end
function write_gpm_disabled()
--if not g_ctlmgr.google_enabled and (not store.check_usb_useable() or not g_is_online)then
if not store.check_usb_useable() or not g_is_online then
box.out([[ disabled="disabled" class="disableNode" ]])
end
end
function write_index_msg()
local refresh_txt = [[{?966:867?} ]]
if "3" == g_ctlmgr.partition_status or "4" == g_ctlmgr.partition_status then
refresh_txt = [[{?966:334?} ]]
end
box.out([[<div id="indexInProgress" style="display: none;">
]]..box.tohtml([[{?966:922?}]])..[[<img id="uiWaitImg" src="/css/default/images/please_wait_bright.gif">
</div>
<div id="indexNotInProgress" style="display: none;">
<span id="indexFinished" style="display: none;">
]]..general.sprintf([[{?966:1?}]], box.query("gpmsrv:settings/build_db_titlecount"))..[[
</span>
<span id="indexToBeDone" style="display: none;">
]]..general.sprintf([[{?966:183?}]], box.query("gpmsrv:settings/build_db_titlecount"))..[[
</span>
<div><span id="uiGoogleRefreshTxt">]]..box.tohtml( refresh_txt )..[[</span>
<button id="uiGoogleRefresh" class="icon" title="]]..box.tohtml( refresh_txt )..[[" name="google_refresh" type="submit">
<img id="uiRefresh" alt="]]..box.tohtml( refresh_txt )..[[" src="/css/default/images/aktualisieren.gif">
</button>
</div>
</div>]] )
end
function write_usb_devices(name, path)
if not(store.check_usb_available()) then
return [[<p>]]..box.tohtml(TXT([[{?966:374?}]]))..[[</p>]]
end
local check_next = false
local partition_status_text = ""
if name=="gpath" then
if path == "" then
check_next = true
end
end
local path_found = false
local count = 1
local ret_str = ""
local usb_devices = store.get_usb_devices_list()
for i,v in ipairs(usb_devices) do
if v.devtype == "storage" then
if v.any_log and not(store.aura_for_storage_aktiv()) then
for j,logvol in ipairs(v.log_vol) do
local index_str = ""
local p_class = ""
local params=""
if check_next then
params=[[checked="checked"]]
check_next = false
elseif (path==logvol.name) then
params=[[checked="checked"]]
path_found = true
index_str = partition_status_text
if g_ctlmgr.partition_status == "2" or g_ctlmgr.partition_status == "4" then
params = params..[[ disabled="disabled"]]
p_class = [[ class="disableNode"]]
end
end
ret_str = [[<div]]..p_class..[[><input type="radio" onclick="onGoogleUsbChange( ']] .. box.tohtml(logvol.name) .. [[' )" name="]]..name..[[" id="ui]]..tostring(name)..count..[[" value="]]..box.tohtml(logvol.name)..[[" ]]..params..[[>&nbsp;<label for="ui]]..tostring(name)..count..[[">]]..box.tohtml(logvol.name)..[[</label></div>]]
box.out(ret_str)
count = count + 1
end
end
end
end
if not path_found and path ~= "" and name == "gpath" then
box.out([[<p class="disableNode"><input type="radio" name="]]..name..[[" id="ui]]..tostring(name)..tostring(count)..[[" value="]]..box.tohtml(path)..[[" checked="checked" disabled="disabled">&nbsp;<label for="ui]]..tostring(name)..count..[[">]]..box.tohtml(path)..[[</label><label>{?966:570?}</label></p>]])
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<style type="text/css">
.icon {
position: relative;
top: 2px;
}
.index_msg {
margin-top: 5px;
margin-bottom: 5px;
}
.index_msg img {
height: 16px;
}
</style>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>" class="narrow">
<div>
<div>
{?966:659?}
<?lua
if not g_ctlmgr.nas_enabled then
box.out([[
<span class="hintMsg">{?txtHinweis?}</span>
<p>
]]..general.sprintf(
[[{?966:80?}]],
[[<a href=']]..href.get("/storage/settings.lua")..[['>]], [[</a>]]
)..[[
</p>]])
end
?>
</div>
<hr>
<div <?lua if not g_ctlmgr.nas_enabled then box.out([[class="disableNode"]]) end ?>>
<input type="checkbox" id="uiViewUseMediaSrv" name="use_mediasrv" onclick="onUseMediaserver()" <?lua if g_ctlmgr.mediasrv_enabled == "1" then box.out('checked') end write_nas_disabled()?>>
<label for="uiViewUseMediaSrv"><?lua box.html([[{?966:491?}]]) ?> {?966:861?}</label>
</div>
<div id="uiViewUseMediaSrvInfo">
<div class="formular">
<?lua
if (g_ctlmgr.mediasrv_name~=nil and g_ctlmgr.mediasrv_name~="err") then
local tmp=""
tmp=tmp..[[<p>]]..box.tohtml([[{?966:450?}]])..[[</p>]]
tmp=tmp..[[<label for="uiViewMediaSrvName">]]..box.tohtml([[{?966:524?}]])..[[</label>]]
tmp=tmp..[[<input type="text" size="30" maxlength="100" id="uiViewMediaSrvName" name="media_srvname" value="]]..box.tohtml(g_ctlmgr.mediasrv_name)..[["]]..val.get_attrs(g_val, "uiViewMediaSrvName")..[[>]]
tmp=tmp..val.get_html_msg(g_val, "uiViewMediaSrvName")
box.out(tmp)
end
?>
</div>
<hr>
<h4>{?966:534?}</h4>
<p>{?966:739?}</p>
<br>
<p>{?966:388?}</p>
<div class="formular">
<input type="radio" name="path" id="uipath0" value="" <?lua write_checked(g_ctlmgr.mediasrv_path=="")?>>
<label for="uipath0">{?966:804?}</label>
<?lua write_usb_devices("path", g_ctlmgr.mediasrv_path)?>
</div>
<br>
<span>{?966:520?}</span>
<div class="formular">
<p>
<span <?lua write_1und1_disabled() ?>>
<input type="checkbox" name="1und1" id="ui1und1" <?lua write_checked(g_ctlmgr.cds_enabled == "1") write_1und1_disabled()?>>
<label for="ui1und1">{?966:522?}</label>
</span>
<a href="<?lua box.html(href.get('/storage/settings.lua')) ?>">{?966:593?}</a>
</p>
<p>
<input type="checkbox" name="tkm" id="uiTkm" <?lua write_checked(g_ctlmgr.t_media_enabled == "1")?> onclick="onChangeTkm(this)">
<label for="uiTkm">{?966:408?}</label>
<?lua write_t_media_link() ?>
</p>
<p>
<span <?lua write_gpm_disabled() ?>>
<input type="checkbox" name="gpm" id="uiGpm" <?lua write_checked(g_ctlmgr.google_enabled) write_gpm_disabled()?> onclick="onGoogleChange(this)">
<label for="uiGpm">Google Play Music</label>
</span>
<?lua
if not g_is_online then
box.out([[
<p class="hintMsg">{?txtHinweis?}</p>
<p>{?966:129?}</<p>]])
elseif not store.check_usb_useable() then
box.out([[
<p class="hintMsg">{?txtHinweis?}</p>
<p>{?966:784?}</<p>]])
end
?>
</p>
<div style="<?lua write_visible(g_ctlmgr.google_enabled) ?>" class="formular wide" id="uiGoogleElems">
<label for="uiGoogleMail">{?966:391?}</label>
<input class="ShowPathLabel" type="text" name="google_mail" id="uiGoogleMail" value="<?lua box.html(g_ctlmgr.google_mail)?>">
<br>
<label for="uiGooglePw">{?966:846?}</label>
<input class="ShowPathLabel" type="text" name="google_pw" id="uiGooglePw" autocomplete="off" value="<?lua box.html(g_ctlmgr.google_pw)?>">
<br>
<label for="uiGoogleServer">{?966:385?}</label>
<input class="ShowPathLabel" type="text" name="google_servername" id="uiGoogleServer" value="<?lua if not g_ctlmgr.google_servername or '' == g_ctlmgr.google_servername then box.html('Google Play Music') else box.html(g_ctlmgr.google_servername) end ?>">
<div id="uiGoogleIndexBox">
<p>
<span>{?966:3861?}:</span>
</p>
<?lua write_usb_devices("gpath", g_ctlmgr.google_part)?>
<div class="form_input_explain">
<div id="curGooglePartition">
<div class="index_msg"><?lua write_index_msg() ?></div>
<div style="<?lua write_visible(g_synchro) ?>" id="uiStatus"><?lua box.out(g_wait_txt) ?></div>
</div>
<div id="newGooglePartition" style="display:none;">
<div class="index_msg">
<span>
{?966:796?}
</span>
<div>
<span>
{?966:244?}
</span>
<button class="icon" title="{?966:8?}" name="google_refresh" type="submit">
<img id="uiRefresh" alt="{?966:893?}" src="/css/default/images/aktualisieren.gif">
</button>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
<?lua
if g_error ~= "" then
box.out([[
<div>
]]..tostring(g_error)..[[
</div>
]])
end
?>
<div id="btn_form_foot">
<input type="hidden" name="oldpath" value="<?lua box.html(g_ctlmgr.mediasrv_path) ?>">
<input type="hidden" name="cur_mediapath" value="<?lua box.html(g_ctlmgr.mediasrv_path) ?>">
<button type="submit" name="btn_save" id="btnSave">{?txtApply?}</button>
<button type="submit" name="btn_cancel" id="btnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/convert_file_size.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function onGoogleUsbChange( partName )
{
jxl.display( "curGooglePartition" ,"<?lua box.js(g_ctlmgr.google_part) ?>" == partName);
jxl.display( "newGooglePartition" ,"<?lua box.js(g_ctlmgr.google_part) ?>" != partName);
}
function setCurGText( synchro, partitionStatus )
{
var refreshTxt = "{?966:84?} ";
if ( ( "3" == partitionStatus || "4" == partitionStatus ) )
{
refreshTxt = "{?966:497?} ";
}
jxl.get( "uiGoogleRefreshTxt" ).innerHTML = refreshTxt;
jxl.get( "uiGoogleRefresh" ).setAttribute( "title", refreshTxt );
jxl.get( "uiRefresh" ).setAttribute( "alt", refreshTxt );
jxl.display("indexInProgress", synchro);
jxl.display("indexNotInProgress", !synchro );
jxl.display("indexFinished", !synchro && ( partitionStatus == "3" || partitionStatus == "4" ) );
jxl.display("indexToBeDone", !synchro && !( partitionStatus == "3" || partitionStatus == "4" ) );
}
function init()
{
setCurGText( <?lua box.js( g_synchro ) ?>, "<?lua box.js( g_ctlmgr.partition_status ) ?>" );
if (!jxl.getChecked("uiViewUseMediaSrv"))
onUseMediaserver();
if (<?lua box.js(g_synchro) ?>)
window.setTimeout(doRequest, "5000");
disableGoogleElems();
}
var gStatelesRequestCount = 0;
function callback_state( response )
{
var nextScanTime = 2000;
if (response && response.status == 200)
{
var json = makeJSONParser();
var resp = json(response.responseText);
if (resp)
{
if (Number(resp.db_status) > 0)
{
if (Number(resp.db_status) >= 90)
{
setCurGText( resp.synchro, resp.partition_status );
}
else
{
window.setTimeout(doRequest, nextScanTime);
}
jxl.setText("uiStatus", resp.text);
}
else if (Number(resp.db_status) < 0)
{
setCurGText( resp.synchro, resp.partition_status );
jxl.setText("uiStatus", resp.text);
}
else
{
gStatelesRequestCount++;
if ( gStatelesRequestCount < 10 )
{
doRequest();
return;
}
else
{
setCurGText( resp.synchro, resp.partition_status );
jxl.setText("uiStatus", "{?966:96?}");
}
}
gStatelesRequestCount = 0;
}
}
}
function doRequest()
{
ajaxGet("<?lua href.write(box.glob.script, 'ajax=scan') ?>", callback_state);
}
function onUseMediaserver()
{
jxl.disableNode("uiViewUseMediaSrvInfo", !jxl.getChecked("uiViewUseMediaSrv"));
addPopupOpeners();
}
function onChangeTkm(elem)
{
jxl.display("uiTMediaLink", jxl.getChecked(elem));
}
function openTMediaLink() {
var tMediaLink = "<?lua write_t_media_link_js() ?>";
var opts = "width=970,height=600,statusbar,resizable=yes,scrollbars=yes"
if (tMediaLink && jxl.getChecked("uiTkm")) {
window.open(tMediaLink, "Zweitfenster", opts);
}
}
function addPopupOpeners() {
var popupWin = null;
var opts = "width=970,height=600,statusbar,resizable=yes,scrollbars=yes"
function openPopup(evt) {
var elem = jxl.evtTarget(evt);
var url = elem.href;
if (!popupWin || popupWin.closed) {
popupWin = open(url, "Zweitfenster", opts);
}
else {
popupWin.location.href = url;
}
if (popupWin) {
popupWin.focus();
}
return jxl.cancelEvent(evt);
}
var links = document.links;
i = links.length || 0;
while (i--) {
if (jxl.hasClass(links[i], "popup")) {
jxl.addEventHandler(links[i], 'click', openPopup);
}
}
}
function disableGoogleElems()
{
var gOnline = <?lua box.js(tostring(g_is_online)) ?>;
var usbUsable = <?lua box.js(tostring(store.check_usb_useable())) ?>;
jxl.disableNode("uiGoogleElems", !(gOnline && usbUsable));
jxl.display("uiGoogleIndexBox", gOnline && usbUsable);
}
function onGoogleChange(elem)
{
jxl.display("uiGoogleElems", jxl.getChecked(elem));
disableGoogleElems();
}
function uiDoOnMainFormSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
openTMediaLink();
return true;
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "btn_save", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
