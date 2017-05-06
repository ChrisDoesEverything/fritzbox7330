<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_fon_dect_einstellungen.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("config")
require("general")
require("fon_devices")
require("fon_numbers")
require("libaha")
g_val = {
prog = [[
if __checked(uiViewActivateDect/dect_activ) then
char_range_regex(uiViewDectPin/dect_pin, dectpin, pin_error_txt)
end
]]
}
val.msg.pin_error_txt = {
[val.ret.outofrange] = [[{?2121:831?}]]
}
g_ctlmgr = {}
function get_var()
g_ctlmgr.expert = box.query("box:settings/expertmode/activated") == "1"
g_ctlmgr.dect_enabled = box.query("dect:settings/enabled") == "1"
g_ctlmgr.repeater_enabled = false
if config.DECT then
g_ctlmgr.eco_enabled = box.query("dect:settings/EcoMode") == "1"
end
if config.DECT_MONI then
g_ctlmgr.repeater_mode = box.query("dect:settings/RepeaterMode") == "1"
g_ctlmgr.overlaped_sending = box.query("dect:settings/OverlappedSending") == "0"
end
g_ctlmgr.no_emission = box.query("dect:settings/NoEmission")
g_ctlmgr.dect_pin = "****"
g_ctlmgr.NightStart_Values = {}
g_ctlmgr.NightStart_Values[1] = [[00]]
g_ctlmgr.NightStart_Values[2] = [[00]]
g_ctlmgr.NightEnd_Values = {}
g_ctlmgr.NightEnd_Values[1] = [[00]]
g_ctlmgr.NightEnd_Values[2] = [[00]]
local night_time = box.query([[dect:settings/NightTime]])
if #night_time > 0 then
g_ctlmgr.NightStart_Values[1] = string.sub(night_time,1,2)
g_ctlmgr.NightStart_Values[2] = string.sub(night_time,4,5)
g_ctlmgr.NightEnd_Values[1] = string.sub(night_time,6,7)
g_ctlmgr.NightEnd_Values[2] = string.sub(night_time,9,10)
end
end
get_var()
function write_repeater_explain_style()
if g_ctlmgr.dect_enabled or not g_ctlmgr.repeater_enabled then
box.out([[ style="display:none;"]])
end
end
function refill_user_input()
if box.post.dect_activ then
g_ctlmgr.dect_enabled = true
else
g_ctlmgr.dect_enabled = false
end
if config.DECT then
g_ctlmgr.eco_enabled = box.post.dect_power or false
end
if config.DECT_MONI then
g_ctlmgr.repeater_mode = box.post.dect_security == "1"
g_ctlmgr.overlaped_sending = box.post.dect_problems or false
end
if box.post.dect_eco then
g_ctlmgr.no_emission = box.post.dect_eco_modi
else
g_ctlmgr.no_emission = "0"
end
g_ctlmgr.dect_pin = box.post.dect_pin
end
function check_for_dect_fon()
local phones, dect_cnt = fon_devices.read_fon_control()
if dect_cnt > 0 then
return "0"
end
local num_tab = fon_numbers.get_all_numbers()
if num_tab.number_count > 0 then
return "1"
end
return "2"
end
function check_ule_present()
local aha = require"libaha"
local ulecount = #(aha.GetDeviceList() or {})
if ulecount > 0 then
return "1"
else
return "0"
end
end
function assi_check_redirect()
local phone_state = check_for_dect_fon()
if phone_state ~= "0" then
local redirect = true
if g_ctlmgr.repeater_enabled then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "dect:settings/DECTRepeaterEnabled" , "0")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr = general.create_error_div(err,msg)
box.out(criterr)
redirect = false
end
end
if redirect then
if phone_state == "1" then
http.redirect(href.get("/assis/assi_telefon.lua", 'DeviceTyp=Fon', 'Port=20', 'Submit_Goto=AssiFonDectConStart', 'TechTyp=DECT', 'FonAssiFromPage=dectsettings', 'HTMLConfigAssiTyp=FonOnly'))
else
local page = '/assis/assi_fon_nums.lua'
http.redirect(href.get( page, 'back_to_page=/dect/dect_settings.lua'))
end
end
end
end
if next(box.post) and box.post.btnSave then
if (box.post.dect_pin and box.post.dect_pin == "****") or val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
if box.post.dect_activ then
cmtable.add_var(ctlmgr_save, "dect:settings/enabled" , "1")
if box.post.dect_pin and box.post.dect_pin ~= "****" then
cmtable.add_var(ctlmgr_save, "dect:command/PIN" , box.post.dect_pin)
end
if box.post.dect_assi == "0" then
local check_dect_fons = true
if config.DECT then
cmtable.save_checkbox(ctlmgr_save, "dect:settings/EcoMode" , "dect_power")
end
if config.DECT_MONI and box.post.dect_security then
cmtable.add_var(ctlmgr_save, "dect:settings/RepeaterMode" , box.post.dect_security)
if box.post.dect_problems then
cmtable.add_var(ctlmgr_save, "dect:settings/OverlappedSending" , "0")
else
cmtable.add_var(ctlmgr_save, "dect:settings/OverlappedSending" , "1")
end
end
if box.post.dect_eco and box.post.dect_eco_modi then
local eco_modi = box.post.dect_eco_modi
cmtable.add_var(ctlmgr_save, "dect:settings/NoEmission" , eco_modi)
if eco_modi == "2" then
local night_time_on = string.format("%02d", tonumber(box.post.starthh)) .. ":" .. string.format("%02d", tonumber(box.post.startmm))
local night_time_off = string.format("%02d", tonumber(box.post.endhh)) .. ":" .. string.format("%02d", tonumber(box.post.endmm))
cmtable.add_var(ctlmgr_save, "dect:settings/NightTime" , night_time_on..night_time_off)
end
else
cmtable.add_var(ctlmgr_save, "dect:settings/NoEmission" , "0")
end
end
else
cmtable.add_var(ctlmgr_save, "dect:settings/enabled" , "0")
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=[[<div class="LuaSaveVarError">{?2121:12?}.]]
if msg ~= nil and msg ~= "" then
criterr = criterr..[[<br>{?2121:789?}: ]]..msg
else
criterr = criterr..[[<br>{?2121:763?}: ]]..err
end
criterr = criterr..[[<br>{?2121:900?}</div>]]
box.out(criterr)
refill_user_input()
else
get_var()
if box.post.dect_assi ~= "0" and box.post.dect_activ then
assi_check_redirect()
end
end
else
refill_user_input()
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function showRepeaterModeInfo()
{
if (!confirm('{?2121:913?}'))
jxl.setChecked("uiViewDectSecure", true);
}
function onEco()
{
jxl.disableNode("uiViewEcoModiBox", !jxl.getChecked("uiViewDectEco"));
}
function onDectPower()
{
if (jxl.getChecked("uiViewDectPower"))
if (!confirm('{?2121:340?}'))
jxl.setChecked("uiViewDectPower", false);
}
function dectFonAssiNeeded()
{
var assi = <?lua box.out(check_for_dect_fon())?>;
if ( assi != 0 && jxl.getChecked("uiViewActivateDect"))
{
var first_txt = "{?2121:749?}"
var second_txt = " {?2121:114?}";
if (assi == 2)
{
first_txt = "{?2121:674?}";
second_txt = " {?2121:647?}";
}
return confirm(first_txt+second_txt);
}
return true;
}
function dectULEPresent()
{
var ulepresent = <?lua box.out(check_ule_present())?>;
if ( ulepresent != 0 && (<?lua if g_ctlmgr.dect_enabled then box.out('true') else box.out('false') end ?> && !jxl.getChecked("uiViewActivateDect")))
{
var first_txt = "{?2121:6?}"
var second_txt = " {?2121:213?}";
return confirm(first_txt+second_txt);
}
return true;
}
function onDectActiv()
{
var disable = !jxl.getChecked("uiViewActivateDect");
jxl.disableNode("disable_dect_page", disable);
}
function onDectSubmit()
{
val.active = true;
if (!dectFonAssiNeeded())
return false;
if (!dectULEPresent())
return false;
var pin_check = jxl.getValue("uiViewDectPin");
if (pin_check == "****")
return true;
<?lua
val.write_js_checks(g_val)
?>
return true;
}
function init()
{
onDectActiv();
onEco();
<?lua
function is_ule_present( ulelist)
if (ulelist ~= nil) then
if (type(ulelist)=="table") then
for k, v in pairs(ulelist) do
if ((type(v)=="table") and ((v.ID > 0) and (v.ID < 900) )) then
return true
end
end
end
end
return false
end
local devicelist = {}
devicelist = aha.GetDeviceList()
if ( is_ule_present(devicelist) == true) then
box.out("jxl.disableNode('uiViewDectEcoSettings', true);")
end
?>
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
{?2121:891?}
</p>
<hr>
<h4>{?2121:413?}</h4>
<div class="formular">
<input type="checkbox" id="uiViewActivateDect" name="dect_activ" onclick="onDectActiv()" <?lua if g_ctlmgr.dect_enabled then box.out('checked') end ?>>
<label for="uiViewActivateDect">{?2121:283?}</label>
</div>
<div id="disable_dect_page">
<div class="formular">
<p class="form_input_explain">
{?2121:223?}
</p>
</div>
<hr>
<h4>{?2121:379?}</h4>
<div class="close">
<div class="formular">
<p id="uiViewRegistrationTxt1">
{?2121:842?}
</p>
<p>
{?2121:408?}
</p>
<label>{?2121:244?}</label>
<input type="text" maxlength="4" size="4" id="uiViewDectPin" name="dect_pin" value="<?lua box.html(g_ctlmgr.dect_pin) ?>" <?lua val.write_attrs(g_val, "uiViewDectPin") ?>>
<?lua val.write_html_msg(g_val, "uiViewDectPin") ?>
<p id="uiViewRegistrationTxt2">
{?2121:481?}
</p>
</div>
</div>
<div id="hide_page">
<hr>
<h4>{?2121:686?}</h4>
<div class="formular">
<input type="checkbox" id="uiViewDectPower" name="dect_power" onclick="onDectPower();" <?lua if g_ctlmgr.eco_enabled then box.out('checked') end ?>>
<label for="uiViewDectPower">{?2121:402?}</label>
<p class="form_input_explain">
{?2121:868?}
</p>
<span class="form_input_explain hintMsg">{?txtHinweis?}</span>
<p class="form_input_explain">
{?2121:948?}
</p>
<div id="uiViewDectEcoSettings">
<input type="checkbox" id="uiViewDectEco" name="dect_eco" onclick="onEco();" <?lua if g_ctlmgr.no_emission == "1" or g_ctlmgr.no_emission == "2" then box.out('checked') end ?>>
<label for="uiViewDectEco">{?2121:766?}</label>
<p class="form_input_explain">
{?2121:9?}
</p>
<div id="uiViewEcoModiBox" class="formular">
<input type="radio" name="dect_eco_modi" value="1" id="uiViewDectEcoModiAlways" <?lua if g_ctlmgr.no_emission == "1" or g_ctlmgr.no_emission == "0" then box.out('checked') end ?>>
<label for="uiViewDectEcoModiAlways">{?2121:711?}</label>
<br>
<input type="radio" name="dect_eco_modi" value="2" id="uiViewDectEcoModiSelect" <?lua if g_ctlmgr.no_emission == "2" then box.out('checked') end ?>>
<label for="uiViewDectEcoModiSelect">{?2121:18?} </label>
<input type="text" name="starthh" size="3" maxlength="2" value="<?lua box.html(tostring(g_ctlmgr.NightStart_Values[1])) ?>"/> :
<input type="text" name="startmm" size="3" maxlength="2" value="<?lua box.html(tostring(g_ctlmgr.NightStart_Values[2])) ?>"/>
<label>{?2121:621?}</label>
<input type="text" name="endhh" size="3" maxlength="2" value="<?lua box.html(tostring(g_ctlmgr.NightEnd_Values[1])) ?>"/> :
<input type="text" name="endmm" size="3" maxlength="2" value="<?lua box.html(tostring(g_ctlmgr.NightEnd_Values[2])) ?>"/>
<label>{?2121:125?}</label>
</div>
</div>
</div>
<hr>
<h4>{?2121:9047?}</h4>
<div class="formular">
<input type="radio" name="dect_security" value="0" id="uiViewDectSecure" <?lua if not(g_ctlmgr.repeater_mode) then box.out('checked') end ?>>
<label for="uiViewDectSecure">{?2121:736?}</label>
<p class="form_input_explain">
{?2121:353?}
</p>
<br>
<input type="radio" name="dect_security" value="1" id="uiViewDectOpen" onclick="showRepeaterModeInfo();" <?lua if g_ctlmgr.repeater_mode then box.out('checked') end ?>>
<label for="uiViewDectOpen">{?2121:133?}</label>
<p class="form_input_explain">
{?2121:837?}
</p>
<br>
<span class="form_input_explain hintMsg">{?txtHinweis?}</span>
<p class="form_input_explain">
{?2121:296?}
</p>
</div>
<hr>
<h4>{?2121:845?}</h4>
<div class="formular">
<input type="checkbox" id="uiViewDectProblems" name="dect_problems" <?lua if g_ctlmgr.overlaped_sending then box.out('checked') end ?>>
<label for="uiViewDectProblems">{?2121:912?}</label>
<p class="form_input_explain">
{?2121:89?}
</p>
</div>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="dect_assi" value="<?lua box.out(check_for_dect_fon()) ?>" />
<button type="submit" name="btnSave" id="btnSave" onclick="return onDectSubmit();">{?txtApply?}</button>
<button type="submit" name="btnChancel" id="btnChancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
