<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_fon_merkmale_dect.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("config")
require("general")
require("fon_devices")
require("fon_devices_html")
require("http")
g_back_to_page = http.get_back_to_page( "/dect/dect_list.lua" )
g_menu_active_page = g_back_to_page
if (string.find(g_back_to_page,"assi")) then
g_page_type = "wizard"
end
popup_url=""
if config.oem == '1und1' then
if box.get.popup_url then
popup_url = box.get.popup_url
elseif box.post.popup_url then
popup_url = box.post.popup_url
end
end
g_ctlmgr = {}
g_errmsg = [[]]
g_isAVM = false
g_isMtf = false
function get_var()
g_ctlmgr.idx = ""
if box.post.idx and box.post.idx ~= "" then
g_ctlmgr.idx = box.post.idx
elseif box.get.idx and box.get.idx ~= "" then
g_ctlmgr.idx = box.get.idx
end
local fon_control_list = fon_devices.read_fon_control(true)
local l, device = fon_devices.find_elem(fon_control_list, "foncontrol", "idx", tonumber(g_ctlmgr.idx))
if not device then
http.redirect(href.get(g_back_to_page, http.url_param('popup_url', popup_url)))
else
g_ctlmgr.use_pstn = box.query("telcfg:settings/UsePSTN")
g_ctlmgr.clir = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/CLIR") --uiPostClir0
g_ctlmgr.call_waiting_prot0 = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/CallWaitingProt") --uiPostWaiting0
g_ctlmgr.wideband_enable = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/WidebandEnable") --uiPostWidebandEnabled
g_ctlmgr.busy_on_busy = box.query("telcfg:settings/MSN/Port3/BusyOnBusy") --uiPostBusy
g_ctlmgr.call_waiting_prot = box.query("telcfg:settings/MSN/Port3/CallWaitingProt") --uiPostWaiting
g_ctlmgr.low_gain = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/LowGain") --uiPostLowGain
g_ctlmgr.mid_gain = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/MidGain") --uiPostMidGain
g_ctlmgr.high_gain = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/HighGain") --uiPostHighGain
g_ctlmgr.tam_monitor_bitmap = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/TAMMonitorBitmap") --uiPostMonitorTam
g_ctlmgr.pb_search_style = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/PBSearchStyle") --uiPostPBSearchStyle
g_ctlmgr.image = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/Image") --uiPostImage
g_ctlmgr.image_path = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/ImagePath")
g_ctlmgr.manufacturer = device.manufacturer
g_ctlmgr.codecs = device.codecs
g_ctlmgr.subscribed = device.subscribed
if device.manufacturer == "AVM" then
g_isAVM = true
if device.model == "0x03" or device.model == "0x04" or tonumber(device.model) > 5 then
g_isMtf = true
end
end
g_page_title = [[{?731:618?} ]]..device.name
end
end
get_var()
g_local_tabs = fon_devices_html.get_edit_dect_tabs(g_ctlmgr.idx, {back_to_page=g_back_to_page, popup_url=popup_url})
g_val = {
prog = [[]]
}
val.msg.error_txt = {}
function get_checkbox_value(checkbox_post, invert)
local checked_value = "1"
local unchecked_value = "0"
if invert then
checked_value = "0"
unchecked_value = "1"
end
if box.post[checkbox_post] then
return checked_value
else
return unchecked_value
end
end
if next(box.post) then
local redirect_url = g_back_to_page
local saveset = {}
if box.post.button_save then
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/CLIR", get_checkbox_value("clir0"))
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/CallWaitingProt", get_checkbox_value("anklopfen", true))
cmtable.add_var(saveset, "telcfg:settings/MSN/Port3/BusyOnBusy", get_checkbox_value("busy"))
if box.post.busy then
cmtable.add_var(saveset, "telcfg:settings/MSN/Port3/CallWaitingProt", get_checkbox_value("busy_delayed", true))
end
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/LowGain", box.post.low_gain)
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/MidGain", box.post.mid_gain)
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/HighGain", box.post.high_gain)
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/PBSearchStyle", get_checkbox_value("pb_search_style", true))
if box.post.wideband_enable then
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/WidebandEnable", box.post.wideband_enable)
end
local bits = 0
if box.post.monitor_tam then
for i = 0, 4, 1 do
bits = bit.set(bits, i)
end
end
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/TAMMonitorBitmap", bits)
elseif box.post.button_cancel then
http.redirect(href.get(redirect_url, http.url_param('popup_url', popup_url)))
elseif box.post.pic_upload then
local param = {}
param[1] = http.url_param('entryid', box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/Intern"))
param[2] = http.url_param('bookid', "255")
param[3] = http.url_param('phototype', "1")
param[4] = http.url_param('back_to_page', g_back_to_page)
http.redirect(href.get("/fon_num/photo_upload.lua", unpack(param)))
elseif box.post.pic_delete then
redirect_url = "/fon_devices/edit_dect_option.lua"
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/Image", "")
end
if (#saveset > 0) then
local err, msg = box.set_config(saveset)
if err == 0 then
if redirect_url and redirect_url~="" then
local param = {}
param[1] = http.url_param('idx', g_ctlmgr.idx)
param[2] = http.url_param('back_to_page', g_back_to_page)
param[3] = http.url_param('popup_url', popup_url)
http.redirect(href.get(redirect_url, unpack(param)))
end
else
g_errmsg=general.create_error_div(err,msg)
end
end
if (g_errmsg~="") then
get_var()
end
end
function write_monitor_tam()
local do_show = false
do_show = g_ctlmgr.manufacturer == "AVM/Swissvoice" or g_ctlmgr.manufacturer == "AVM"
if do_show then
box.out([[
<div>
<input type="checkbox" id="uiViewMonitorTam" name="monitor_tam" ]]) write_checked(tonumber(g_ctlmgr.tam_monitor_bitmap) > 0) box.out([[>
<label for="uiViewMonitorTam">{?2575:609?}</label>
</div>
]])
end
end
function write_pb_search_style()
if g_ctlmgr.manufacturer == "AVM" then
box.out([[
<div>
<input type="checkbox" id="uiViewPBSearchStyle" name="pb_search_style" ]]) write_checked(g_ctlmgr.pb_search_style == "0") box.out([[>
<label for="uiViewPBSearchStyle">{?2575:537?}</label>
</div>
]])
end
end
function write_custom_background()
if (g_isMtf) then
local img_container = ""
local delete_button = ""
local btn_txt = [[<span>{?2575:826?}</span>]]
local image_path = g_ctlmgr.image_path
box.out(
[[
<hr>
<h4>{?2575:923?}</h4>
<div class="formular">
<p>
{?2575:618?}
</p>
<div class="float_container">]])
if image_path == "" then
box.out(
[[<div id="uiImgContainer" class="img_container">
<span id="uiNoFoto">
{?2575:914?}
</span>
</div>]])
else
box.out(
[[<div id="uiImgContainer" class="img_container">
<img id="uiShowFoto" alt="{?2575:937?}" src="]]..href.get("/lua/photo.lua","photo="..image_path)..[[">
</div>]])
btn_txt = [[<span>{?2575:459?}</span>]]
delete_button = [[<p>
<button class="icon" type="button" onclick="onDeletePic()">
<img src="/css/default/images/loeschen.gif">
</button>
<span>{?2575:211?}</span>
</p>]]
end
box.out([[
<div class="img_buttons">
<p>
<button class="icon" type="submit" name="pic_upload" onclick="onPicupload()">
<img src="/css/default/images/bearbeiten.gif">
</button>
]]..btn_txt..[[
</p>
]]..delete_button..[[
</div>
</div>]])
local showusbhinweis = true
if showusbhinweis then
box.out([[
<h4>{?2575:4?}</h4>
<p>
{?2575:252?}
</p>
]])
end
box.out([[
</div>
]])
end
end
function write_checked(condition)
if condition then
box.out([[checked="checked"]])
end
end
function write_selected(condition)
if condition then
box.out([[selected="selected"]])
end
end
function has_hdd_support()
if not g_ctlmgr.codecs or g_ctlmgr.codecs =="" then
return false
elseif string.find(g_ctlmgr.codecs, "G.722") then
return true
else
return false
end
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<style type="text/css">
div.float_container {
overflow:hidden;
width: 100%;
}
div.img_container {
width: 160px;
height: 160px;
background-color: #ffffff;
margin: 10px 0;
float:left;
border: solid 1px;
}
div.img_container img {
max-width: 160px;
max-height: 160px;
float:right;
}
div.img_container span {
display:inline-block;
margin: 35% 10%;
}
div.img_buttons {
margin:10px 0 0 171px;
padding-left: 10px;
}
div.img_buttons p {
margin: 10px 0;
}
div.img_buttons button {
margin-right: 10px;
}
#uiViewWideBandOption {
width:200px;
}
</style>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/cookie.js"></script>
<script type="text/javascript">
<?lua
require("val")
val.write_js_error_strings()
?>
function init()
{
showPic();
OnClickBusy();
}
var g_mldClir = '{?2575:426?}\x0A\x0A{?2575:727?}';
var g_mldClir_ohneFestnetz = '{?2575:86?}\x0A\x0A{?2575:126?}';
var g_txt_Titel = "{?2575:395?}";
var g_picLoadable = false;
(function(img) {
function loading() {
g_picLoadable = true;
showPic();
};
function err(evt) {
g_picLoadable = false;
showPic();
};
var tstImage = new Image();
tstImage.onload = loading;
tstImage.onerror = err;
tstImage.src = "/lua/photo.lua?photo=" + img + "&sid=<?lua box.out(box.js(box.glob.sid)) ?>";
})("<?lua box.out(box.js(g_ctlmgr.image_path)) ?>");
function showPic()
{
if (g_picLoadable)
{
jxl.display("uiShowFoto", true);
jxl.display("uiNoFoto", false);
jxl.setStyle("uiImgContainer","border-width","0px");
} else {
jxl.display("uiShowFoto", false);
if ("<?lua box.out(box.js(g_ctlmgr.image_path)) ?>"!="")
{
jxl.setText("uiNoFoto", "{?2575:18?}");
}
jxl.display("uiNoFoto", true);
jxl.setStyle("uiImgContainer","border-width","1px");
}
}
function OnClickBusy() {
jxl.setDisabled("uiViewBusyDelayed", !jxl.getChecked("uiViewBusy"));
}
function OnClickClir (id) {
if (jxl.getChecked(id))
<?lua
if g_ctlmgr.use_pstn == "1" then
box.out("alert(g_mldClir)")
else
box.out("alert(g_mldClir_ohneFestnetz)")
end
?>
}
function onPicupload() {
var str = "<?lua box.out(box.js(box.glob.script..'?idx='..g_ctlmgr.idx..'&back_to_page='..g_back_to_page..'&popup_url='..popup_url))?>";
storeCookie("backtopage", str, 1);
}
function onDeletePic() {
if (confirm("{?2575:374?}"))
{
jxl.enable("deletePic")
jxl.submitForm("uiMainForm");
}
}
function uiDoOnMainFormSubmit()
{
<?lua
require("val")
val.write_js_checks(g_val)
?>
return true;
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "button_save", "uiMainForm" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div>
<h4>{?2575:312?}</h4>
<div class="formular">
<?lua write_monitor_tam() ?>
<?lua write_pb_search_style() ?>
<div>
<input type="checkbox" id="uiViewClir0" name="clir0" <?lua write_checked(g_ctlmgr.clir=="1") ?>>
<label for="uiViewClir0">{?2575:150?}</label>
<div class="form_checkbox_explain">
{?2575:344?}
</div>
</div>
<div>
<input type="checkbox" id="uiViewAnklopfen" name="anklopfen" <?lua write_checked(g_ctlmgr.call_waiting_prot0=="0") ?>>
<label for="uiViewAnklopfen">{?2575:232?}</label>
<div class="form_checkbox_explain">
{?2575:887?}
</div>
</div>
<div>
<input type="checkbox" id="uiViewBusy" onclick="OnClickBusy()" name="busy" <?lua write_checked(g_ctlmgr.busy_on_busy=="1") ?>>
<label for="uiViewBusy">{?2575:508?}</label>
<div class="form_checkbox_explain">
{?2575:285?}
</div>
</div>
</div>
<?lua write_custom_background() ?>
<?lua if general.is_expert() then
box.out([[
<hr>
<h4>{?2575:462?}</h4>
<div class="formular">
<select size="1" id="uiViewWideBandOption" name="wideband_enable">
<option ]]) write_selected(g_ctlmgr.wideband_enable=="0") box.out([[ value="0">{?2575:430?}</option>
<option ]]) write_selected(g_ctlmgr.wideband_enable=="1") box.out([[ value="1">{?2575:952?}</option>
<option ]]) write_selected(g_ctlmgr.wideband_enable=="2") box.out([[ value="2">{?2575:995?}</option>
</select>
</div>]])
end ?>
<hr>
<h4>{?2575:6?}</h4>
<div class="formular">
<p>{?2575:875?}</p>
<table class="grid">
<colgroup>
<col width="100px;">
<col width="25px;">
<col width="70px;">
<col width="25px;">
<col width="70px;">
<col width="25px;">
<col width="70px;">
</colgroup>
<tr>
<td colspan="2"></td>
<td>{?2575:614?}</td>
<td></td>
<td>{?2575:272?}</td>
<td></td>
<td>{?2575:164?}</td>
</tr>
<tr>
<td>{?2575:440?}</td>
<td></td>
<td><input type="radio" value="18" id="uiViewLow18" name="low_gain" <?lua write_checked(g_ctlmgr.low_gain=="18") ?>/></td>
<td></td>
<td><input type="radio" value="18" id="uiViewMid18" name="mid_gain" <?lua write_checked(g_ctlmgr.mid_gain=="18") ?>/></td>
<td></td>
<td><input type="radio" value="18" id="uiViewHigh18" name="high_gain" <?lua write_checked(g_ctlmgr.high_gain=="18") ?>/></td>
</tr>
<tr>
<td></td>
<td></td>
<td><input type="radio" value="12" id="uiViewLow12" name="low_gain" <?lua write_checked(g_ctlmgr.low_gain=="12") ?>/></td>
<td></td>
<td><input type="radio" value="12" id="uiViewMid12" name="mid_gain" <?lua write_checked(g_ctlmgr.mid_gain=="12") ?>/></td>
<td></td>
<td><input type="radio" value="12" id="uiViewHigh12" name="high_gain" <?lua write_checked(g_ctlmgr.high_gain=="12") ?>/></td>
</tr>
<tr>
<td></td>
<td></td>
<td><input type="radio" value="6" id="uiViewLow6" name="low_gain" <?lua write_checked(g_ctlmgr.low_gain=="6") ?>/></td>
<td></td>
<td><input type="radio" value="6" id="uiViewMid6" name="mid_gain" <?lua write_checked(g_ctlmgr.mid_gain=="6") ?>/></td>
<td></td>
<td><input type="radio" value="6" id="uiViewHigh6" name="high_gain" <?lua write_checked(g_ctlmgr.high_gain=="6") ?>/></td>
</tr>
<tr>
<td>{?2575:83?}</td>
<td></td>
<td><input type="radio" value="0" id="uiViewLow0" name="low_gain" <?lua write_checked(g_ctlmgr.low_gain=="0") ?>/></td>
<td></td>
<td><input type="radio" value="0" id="uiViewMid0" name="mid_gain" <?lua write_checked(g_ctlmgr.mid_gain=="0") ?>/></td>
<td></td>
<td><input type="radio" value="0" id="uiViewHigh0" name="high_gain" <?lua write_checked(g_ctlmgr.high_gain=="0") ?>/></td>
</tr>
<tr>
<td></td>
<td></td>
<td><input type="radio" value="-6" id="uiViewLow-6" name="low_gain" <?lua write_checked(g_ctlmgr.low_gain=="-6") ?>/></td>
<td></td>
<td><input type="radio" value="-6" id="uiViewMid-6" name="mid_gain" <?lua write_checked(g_ctlmgr.mid_gain=="-6") ?>/></td>
<td></td>
<td><input type="radio" value="-6" id="uiViewHigh-6" name="high_gain" <?lua write_checked(g_ctlmgr.high_gain=="-6") ?>/></td>
</tr>
<tr>
<td></td>
<td></td>
<td><input type="radio" value="-12" id="uiViewLow-12" name="low_gain" <?lua write_checked(g_ctlmgr.low_gain=="-12") ?>/></td>
<td></td>
<td><input type="radio" value="-12" id="uiViewMid-12" name="mid_gain" <?lua write_checked(g_ctlmgr.mid_gain=="-12") ?>/></td>
<td></td>
<td><input type="radio" value="-12" id="uiViewHigh-12" name="high_gain" <?lua write_checked(g_ctlmgr.high_gain=="-12") ?>/></td>
</tr>
<tr>
<td>{?2575:796?}</td>
<td></td>
<td><input type="radio" value="-18" id="uiViewLow-18" name="low_gain" <?lua write_checked(g_ctlmgr.low_gain=="-18") ?>/></td>
<td></td>
<td><input type="radio" value="-18" id="uiViewMid-18" name="mid_gain" <?lua write_checked(g_ctlmgr.mid_gain=="-18") ?>/></td>
<td></td>
<td><input type="radio" value="-18" id="uiViewHigh-18" name="high_gain" <?lua write_checked(g_ctlmgr.high_gain=="-18") ?>/></td>
</tr>
</table>
</div>
</div>
<div class="WarnMsg" >
<?lua
if (g_errmsg) then
box.out(g_errmsg)
end
?>
</div>
<div id="btn_form_foot">
<button type="submit" name="button_save" >{?txtApplyOk?}</button>
<button type="submit" name="button_cancel">{?txtCancel?}</button>
<input type="hidden" name="idx" value="<?lua box.html(g_ctlmgr.idx) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" id="deletePic" name="pic_delete" disabled="disabled">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
