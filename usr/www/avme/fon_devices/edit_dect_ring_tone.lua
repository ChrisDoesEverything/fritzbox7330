<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_fon_dect_klingeltoene.html"
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
function redirect_back()
http.redirect(href.get(g_back_to_page, http.url_param('popup_url', popup_url)))
end
g_ctlmgr = {}
g_isAVM = false
g_isMtf = false
g_showRadioRing = false
function get_var()
g_ctlmgr.idx = ""
if box.post.idx and box.post.idx ~= "" then
g_ctlmgr.idx = box.post.idx
elseif box.get.idx and box.get.idx ~= "" then
g_ctlmgr.idx = box.get.idx
end
g_ctlmgr.name = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/Name")
g_page_title = [[{?8358:471?} ]]..g_ctlmgr.name
g_ctlmgr.custom_ringtone_name = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/G722RingToneName")
g_ctlmgr.ringtone_url = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/G722RingTone")
g_ctlmgr.number_ringtone_list = {}
for i = 0, 9, 1 do
g_ctlmgr.number_ringtone_list[i + 1] = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/MSN"..i.."/RingTone")
end
g_ctlmgr.int_ringtone = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/IntRingTone")
g_ctlmgr.vip_ringtone = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/VIPRingTone")
g_ctlmgr.alarm_ringtone = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/AlarmRingTone0")
g_ctlmgr.radio_ring_id = box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/RadioRingID")
g_ctlmgr.webradio_list = general.listquery("configd:settings/WEBRADIO/list(Name,URL)")
for k, radio in ipairs(g_ctlmgr.webradio_list) do
if radio.Name ~= "" and radio.URL ~= "" then
g_showRadioRing = true
end
end
g_ctlmgr.act_on_numbers = {}
local fon_control_list = fon_devices.read_fon_control(true)
local l, device = fon_devices.find_elem(fon_control_list, "foncontrol", "idx", tonumber(g_ctlmgr.idx))
if device then
if device.manufacturer == "AVM" then
g_isAVM = true
if device.model == "0x03" or device.model == "0x04" or tonumber(device.model) > 5 then
g_isMtf = true
end
end
g_ctlmgr.act_on_numbers = device.incoming
g_ctlmgr.out_only=device.out_only
end
end
get_var()
g_val = {
prog = [[
if __exists(uiViewRingToneName/ringtone_name) then
if __callfunc(uiViewRingToneName/ringtone_name, custom_ringtone_exist) then
char_range_regex(uiViewRingToneName/ringtone_name, url, error_txt)
end
end
]]
}
function custom_ringtone_exist(ringtone_name)
if g_ctlmgr.ringtone_url == "" or g_ctlmgr.ringtone_url == "er" or g_ctlmgr.ringtone_url == "err" then
return false
else
return true
end
end
val.msg.error_txt = {
[val.ret.notfound] = [[{?8358:894?}]],
[val.ret.outofrange] = [[{?5569:633?}]]
}
if next(box.post) then
if box.post.button_save and val.validate(g_val) == val.ret.ok then
local saveset = {}
if g_isMtf then
local ringtoneurl = g_ctlmgr.ringtone_url
if (ringtoneurl ~= "" and ringtoneurl ~= "er" and ringtoneurl ~= "err" and box.post.ringtone_name ~= "") then
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/G722RingToneName", box.post.ringtone_name)
end
end
local start=0
if g_ctlmgr.out_only then
start=1
end
for k = 0, 9, 1 do
local ring = box.post["ring"..k]
if ring == "empty" then
ring = "0"
end
if ring and ring ~= "" then
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/MSN"..k+start.."/RingTone", ring)
end
end
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/VIPRingTone", box.post.vip_ringtone)
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/IntRingTone", box.post.int_ringtone)
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/AlarmRingTone0", box.post.wecker0_ringtone)
if g_showRadioRing then
if box.post.wecker0_ringtone == "33" then
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/RadioRingID", box.post.wecker0_ringtone_radio)
end
end
local err, msg = box.set_config(saveset)
if err == 0 then
redirect_back()
else
box.out(general.create_error_div(err,msg))
end
get_var()
elseif box.post.ringtone_upload then
local param = {}
param[1] = http.url_param('entryid', box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/Intern"))
param[2] = http.url_param('bookid', "255")
param[3] = http.url_param('phototype', "1")
param[4] = http.url_param('back_to_page', g_back_to_page)
http.redirect(href.get("/fon_devices/edit_dect_ring_tone_upload.lua", unpack(param)))
elseif box.post.button_cancel then
redirect_back()
end
end
if next(box.get) then
if box.get.start_ringtest == "1" or box.get.start_ringtest == "2" or box.get.stop_ringtest == "1" then
local response = "stop_ringtest"
local ctlmgr_save={}
if box.get.start_ringtest == "1" then
response = "start_ringtest1"
cmtable.add_var(ctlmgr_save, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/IntRingTone", box.get.ringtone)
if (g_showRadioRing) then
if(box.get.ringtone == "33") then
cmtable.add_var(ctlmgr_save, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/RadioRingID", box.get.ring_tone_radio_test)
end
end
elseif box.get.start_ringtest == "2" then
response = "start_ringtest2"
cmtable.add_var(ctlmgr_save, "telcfg:command/Dial", "**"..tostring(box.query("telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/Intern")))
cmtable.add_var(ctlmgr_save, "telcfg:settings/DialPort", "50")
elseif box.get.stop_ringtest == "1" then
response = "stop_ringtest"
cmtable.add_var(ctlmgr_save, "telcfg:command/Hangup", "1")
cmtable.add_var(ctlmgr_save, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/IntRingTone", box.get.ringtone)
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local x=general.create_error_div(err,msg)
else
box.out(box.js(response))
end
box.end_page()
end
end
function write_ringtone_combo(tr_id, span_txt, select_id, select_name, show_radio, bauswaehlen, ringtone, show_music_list)
local onchange = [[]]
if show_radio then
onchange = [[ onchange="ViewWecker0RingTone_Change()"]]
end
box.out([[<div id="]]..tr_id..[[">
<label>]]..span_txt..[[</label>
<select size="1" id="]]..select_id..[[" name="]]..select_name..[[" ]]..onchange..[[>]])
fill_ringtone_combo(show_radio, bauswaehlen, ringtone, show_music_list);
box.out([[</select>]])
if show_radio then
write_ringtone_radio_combo("uiWeckerRadioStation", "uiViewWecker0RingToneRadio", "wecker0_ringtone_radio", tostring(ringtone) == "33")
end
box.out([[</div>]])
end
function write_ringtone_radio_combo(p_id, select_id, select_name, display)
local style = [[ style="display:none;"]]
if display then
style = ""
end
box.out([[<span id="]]..p_id..[[" ]]..style..[[>
<select size="1" id="]]..select_id..[[" name="]]..select_name..[[" >]])
for i, radio in ipairs(g_ctlmgr.webradio_list) do
if radio.Name ~= "" and radio.URL ~= "" then
write_ringtone(i - 1, radio.Name, g_ctlmgr.radio_ring_id)
end
end
box.out([[</select>
</span>
]])
end
function write_ringtone(value, name, saved_ringtone)
local selected = ""
value = tostring(value)
if value == tostring(saved_ringtone) then
selected = [[selected = "selected" ]]
end
box.out([[<option ]]..selected..[[value="]]..value..[[">]]..name..[[</option>]])
end
function fill_ringtone_combo(show_radio, bauswaehlen, saved_ringtone, show_music_list)
if not saved_ringtone then
saved_ringtone = "0"
end
write_ringtone("0", "{?5569:636?}", saved_ringtone)
write_ringtone("1", "{?5569:712?}", saved_ringtone)
write_ringtone("2", "{?5569:485?}", saved_ringtone)
if g_isAVM then
if g_isMtf then
write_ringtone("9", "{?5569:530?}", saved_ringtone)
end
if g_showRadioRing then
if show_radio then
write_ringtone("33", "{?5569:768?}", saved_ringtone)
end
end
if show_music_list == true then
write_ringtone("34", "{?8358:614?}", saved_ringtone)
end
local ringtones = {"Standard", "Eighties", "Alarm", "Ring", "Ring Ring", "News", "Bamboo", "Andante", "Cha Cha", "Budapest", "Asia", "Kullabaloo", "Comedy", "Funky", "Fatboy", "Calypso", "Pingpong", "Melodica", "Minimal", "Signal", "Blok1", "Musicbox", "Blok2", "2Jazz"}
local offset = 2
for i, ringtone in ipairs(ringtones) do
if ((i+offset) == 9) then
offset = offset + 1
end
if ((i+offset) == 16) then
offset = offset + 1
end
write_ringtone(i + offset, ringtone, saved_ringtone)
end
else
for k = 3, 9, 1 do
write_ringtone(k, "{?5569:45?} "..k, saved_ringtone)
end
end
write_ringtone(16, "{?5569:30?}", saved_ringtone)
if(bauswaehlen) then
write_ringtone("empty", "", saved_ringtone)
end
end
function write_custom_ringtone()
if (g_isMtf) then
local disabled = ""
local ringtone_name = g_ctlmgr.custom_ringtone_name
if not custom_ringtone_exist() then
disabled = [[disabled = "disabled" ]]
ringtone_name = [[{?5569:576?}]]
end
box.out([[
<p>
{?5569:170?}
</p>
<div class="formular">
<label for="uiViewRingToneName">{?5569:739?}</label>
<input type="text" size="40" id="uiViewRingToneName" name="ringtone_name" maxlength="70" ]]..disabled..[[ value="]]..ringtone_name..[[">
<button type="submit" name="ringtone_upload" class="icon" onclick="onRingtoneUpload()">
<img src="/css/default/images/bearbeiten.gif">
</button>
<span>{?5569:929?}</span>
</div>]])
end
end
g_local_tabs = fon_devices_html.get_edit_dect_tabs(g_ctlmgr.idx, {back_to_page=g_back_to_page, popup_url=popup_url})
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<style type="text/css">
.formular button.icon {
vertical-align:middle;
margin-top:-1px;
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
}
var g_isMtf = <?lua box.out(g_isMtf) ?>;
var g_isAVM = <?lua box.out(g_isAVM) ?>;
var g_showRadioRing = <?lua box.out(g_showRadioRing) ?>;
var g_OldInternerRingtone = <?lua box.out(box.js(g_ctlmgr.int_ringtone)) ?>
function ViewWecker0RingTone_Change()
{
if (g_showRadioRing)
jxl.display("uiWeckerRadioStation", (jxl.getValue("uiViewWecker0RingTone") == "33"));
}
function ViewRingToneTest_Change()
{
if (g_showRadioRing)
jxl.display("uiWeckerRadioStationTest", (jxl.getValue("uiViewRingTestTone") == "33"));
}
function onRingtoneUpload() {
var str = "<?lua box.out(box.js(box.glob.script..'?idx='..g_ctlmgr.idx..'&back_to_page='..g_back_to_page..'&popup_url='..popup_url))?>";
storeCookie("backtopage", str, 1);
}
function doRingTest()
{
var url = "/fon_devices/edit_dect_ring_tone.lua?idx=<?lua box.out(box.js(g_ctlmgr.idx)) ?>";
url += "&sid=<?lua box.js(box.glob.sid) ?>";
function cbRingTest(response)
{
if (response.status == 200)
{
if (response.responseText == "start_ringtest1")
{
ajaxGet(url + "&start_ringtest=2", cbRingTest);
}
else if (response.responseText == "start_ringtest2")
{
alert("{?5569:367?}");
ajaxGet(url + "&stop_ringtest=1&ringtone=" + g_OldInternerRingtone, cbRingTest);
}
}
}
if (g_showRadioRing){
if(jxl.getValue('uiViewRingTestTone') == "33"){
jxl.setSelection('uiViewWecker0RingToneRadio', jxl.getValue('uiViewRingToneRadioTest'));
url += "&ring_tone_radio_test=" + jxl.getValue("uiViewRingToneRadioTest");
}
}
ajaxGet(url + "&start_ringtest=1&ringtone=" + jxl.getValue("uiViewRingTestTone"), cbRingTest);
}
function customRingtoneExist(uiViewRingToneName)
{
return <?lua box.out(custom_ringtone_exist()) ?>
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
<div id="uiShowKlingeltone">
<p>{?5569:400?}</p>
<h4>{?5569:608?}</h4>
<?lua write_custom_ringtone() ?>
<div class="formular">
<?lua
local number = g_ctlmgr.act_on_numbers[1]
local start=0
if g_ctlmgr.out_only then
start=1
end
for k = 0, 9, 1 do
number = g_ctlmgr.act_on_numbers[k+1]
if number and number ~= "" then
write_ringtone_combo("uiShowRing"..k, "{?txtRufnummer?} "..number, "uiViewRing"..k, "ring"..k, false, false, g_ctlmgr.number_ringtone_list[k+1+start])
end
end
write_ringtone_combo("", "{?5569:509?}", "uiViewIntRingTone", "int_ringtone", false, false, g_ctlmgr.int_ringtone)
write_ringtone_combo("", "{?5569:490?}", "uiViewVIPRingTone", "vip_ringtone", false, false, g_ctlmgr.vip_ringtone)
write_ringtone_combo("", "{?txtWakeupCall?}", "uiViewWecker0RingTone", "wecker0_ringtone", true, false, g_ctlmgr.alarm_ringtone, true)
?>
</div>
<h4>{?5569:364?}</h4>
<p>{?5569:974?}</p>
<div class="formular">
<input type="button" onclick="doRingTest()" value="{?5569:726?}" class="Pushbutton">
<select size="1" id="uiViewRingTestTone" name="ring_test_tone" onchange="ViewRingToneTest_Change()">
<?lua fill_ringtone_combo(true, false, "") ?>
</select>
<?lua write_ringtone_radio_combo("uiWeckerRadioStationTest", "uiViewRingToneRadioTest", "ring_tone_radio_test", false) ?>
</div>
</div>
<div id="btn_form_foot">
<button type="submit" name="button_save" >{?txtApplyOk?}</button>
<button type="submit" name="button_cancel">{?txtCancel?}</button>
<input type="hidden" name="idx" value="<?lua box.html(g_ctlmgr.idx) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
