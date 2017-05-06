<?lua
g_page_type = "all"
g_page_needs_js = true
g_page_help = "hilfe_internet_dslsnrset.html"
g_page_title = [[]]
dofile("../templates/global_lua.lua")
require("cmtable")
require("newval")
require("general")
require"html"
require"http"
require"js"
require"libluadsl"
g_errcode = 0
g_errmsg = [[]]
g_data={}
g_annex = ""
g_forecast = {}
function InitMode()
g_data.marge_receive = tostring(tonumber(box.query("sar:settings/DownstreamMarginOffset")))
g_data.marge_receive_all_values = {"0","1","2","3","4"}
g_data.marge_receive_smart_dsl = tostring(tonumber(box.query("sar:status/AdvisedDownstreamMarginOffset")))
g_data.marge_send = box.query("sar:settings/UsNoiseBits")
g_data.marge_send_all_values = {"0","1","2","3","4"}
g_data.marge_send_smart_dsl = box.query("sar:status/AdvisedUsNoiseBits")
g_data.rfi = box.query("sar:settings/RFI_mode")
g_data.rfi_all_values = {"0","1","2","3","4"}
g_data.rfi_smart_dsl = box.query("sar:status/AdvisedRFI_mode")
g_data.inp = box.query("sar:settings/DsINP")
g_data.inp_all_values = {"0","1","2","3","4"}
g_data.inp_smart_dsl = box.query("sar:status/AdvisedDsINP")
end
function refill_user_input()
g_data.marge_receive = tostring(box.post.marge_receive_value)
g_data.inp = tostring( box.post.inp_value)
g_data.rfi = tostring( box.post.rfi_value)
g_data.marge_send = tostring( box.post.marge_send_value)
if config.DSL_2DP then
if ( box.post.data_pump == nil) then
g_data.data_pump = "0"
else
g_data.data_pump = "1"
end
end
end
function get_var()
InitMode()
g_advice_quality = box.query( "sar:settings/AdviseQuality")
if config.DSL_2DP then
g_data.data_pump = box.query( "sar:settings/IsLastReleasedDP")
end
g_annex = box.query("sar:settings/Annex")
if luadsl then
g_forecast.us = luadsl.getSmartDsl(1, "us")
g_forecast.ds = luadsl.getSmartDsl(1, "ds")
end
end
function forecast_available()
if g_forecast.us and g_forecast.ds then
return g_forecast.us.EXPECTED_AVAILABLE and g_forecast.ds.EXPECTED_AVAILABLE
end
return false
end
function build_forecast_url()
local url = "/internet/isp_change.lua"
local params = {
http.url_param("pagemaster", box.glob.script),
http.url_param("pagetype", "all"),
http.url_param("showtabs", ""),
http.url_param("query", "forecast"),
http.url_param("title", g_page_title),
http.url_param("button", "ok"),
http.url_param("cancel", ""),
http.url_param("toptext", html.p{
[[{?5085:595?}]]
}.get(true)),
}
table.insert(params, http.url_param("marge_receive", g_data.marge_receive))
table.insert(params, http.url_param("inp", g_data.inp))
table.insert(params, http.url_param("rfi", g_data.rfi))
table.insert(params, http.url_param("marge_send", g_data.marge_send))
return url .. "?" .. table.concat(params, "&")
end
function get_selected(selected_id,cur_id)
if (selected_id==cur_id) then
return [[ checked ]]
end
return ""
end
function get_smart_style( )
local szStyle = ""
if ( g_advice_quality ~= "0") then
szStyle = [[smart]]
if ( g_advice_quality == "2") then
szStyle = [[smart_good]]
end
end
return szStyle
end
function get_smart( smart_id, cur_id)
if ( g_advice_quality ~= "0") then
local szStyle = [[smart]]
if ( g_advice_quality == "2") then
szStyle = [[smart_good]]
end
if (smart_id == cur_id) then
return szStyle
end
end
return ""
end
function create_row(title,val_name,val_id,cb_func,selected_id,smart_id,all_values)
local str=""
local click=""
if ((cb_func ~= nil) and (cb_func ~= "")) then
click=[[onclick="]]..cb_func..[[(this.value)"]]
end
str=[[<tr>
<td>]]..title..[[</td>
<td class="radio"><div><input type="radio" name="]]..val_name..[[" ]]..get_selected( selected_id, all_values[5])..[[ value="]]..all_values[5]..[[" id="]]..val_id..[[4" ]]..click..[[ /></div></td>
<td class="line"><div></div></td>
<td class="radio"><div><input type="radio" name="]]..val_name..[[" ]]..get_selected( selected_id, all_values[4])..[[ value="]]..all_values[4]..[[" id="]]..val_id..[[3" ]]..click..[[ /></div></td>
<td class="line"><div ></div></td>
<td class="radio"><div><input type="radio" name="]]..val_name..[[" ]]..get_selected( selected_id, all_values[3])..[[ value="]]..all_values[3]..[[" id="]]..val_id..[[2" ]]..click..[[ /></div></td>
<td class="line"><div ></div></td>
<td class="radio"><div><input type="radio" name="]]..val_name..[[" ]]..get_selected( selected_id, all_values[2])..[[ value="]]..all_values[2]..[[" id="]]..val_id..[[1" ]]..click..[[ /></div></td>
<td class="line"><div ></div></td>
<td class="radio"><div><input type="radio" name="]]..val_name..[[" ]]..get_selected( selected_id, all_values[1])..[[ value="]]..all_values[1]..[[" id="]]..val_id..[[0" ]]..click..[[ /></div></td>
</tr>]]
if (get_smart_style()~="") then
str=str..[[<tr>
<td>&nbsp;</td>
<td class="radio"><div class="]]..get_smart( smart_id, all_values[5])..[[">&nbsp;</div></td>
<td class="emptyline"><div></div></td>
<td class="radio"><div class="]]..get_smart( smart_id, all_values[4])..[[">&nbsp;</div></td>
<td class="emptyline"><div ></div></td>
<td class="radio"><div class="]]..get_smart( smart_id, all_values[3])..[[">&nbsp;</div></td>
<td class="emptyline"><div ></div></td>
<td class="radio"><div class="]]..get_smart( smart_id, all_values[2])..[[">&nbsp;</div></td>
<td class="emptyline"><div ></div></td>
<td class="radio"><div class="]]..get_smart( smart_id, all_values[1])..[[">&nbsp;</div></td>
</tr>]]
end
return str
end
function write_row(title,val_name,val_id,cb_func,selected_id,smart_id,all_values)
box.out(create_row(title,val_name,val_id,cb_func,selected_id,smart_id,all_values))
end
function create_headline(title)
local str=[[<tr>
<td class="subtitle">]]..title..[[</td>
<td colspan="9"></td>
</tr>
]]
return str
end
function write_data_pump_section()
if config.DSL_2DP then
box.out([[<hr><h4>]])
box.html([[{?5085:302?}]])
box.out([[</h4><div>]])
box.out([[<p><input type="checkbox" id="uiViewDslVersion" name="data_pump" onclick="onDataPump(this.checked)"]])
if g_data.data_pump=="1" then
box.out([[ checked]])
end
box.out([[>]])
box.out([[<label for="uiViewDslVersion">]])
box.html([[{?5085:16?}]])
box.out([[</label>]])
box.out([[<div class="formular">]])
box.html([[{?5085:856?}]])
box.out([[</div>]])
box.out([[</div>]])
end
end
function write_headline(title)
box.out(create_headline(title))
end
function write_datapump_checked()
if g_data.data_pump=="1" then
box.out([[checked]])
end
end
function get_annex_checked(annex)
if ( annex == g_annex) then
return [[checked]]
end
return [[]]
end
function write_multi_annex_visible()
if config.DSL_MULTI_ANNEX then
box.out([[<hr><h4>]])
box.html([[{?5085:755?}]])
box.out([[</h4><div class="formular">]])
box.out([[<input id="uiAnnexA" type="radio" name="annex" value="A" ]], get_annex_checked("A"), [[>]])
box.out([[<label for="uiAnnexA">]])
box.html([[{?5085:195?}]])
box.out([[</label><br>]])
box.out([[<input id="uiAnnexB" type="radio" name="annex" value="B" ]], get_annex_checked("B"), [[>]])
box.out([[<label for="uiAnnexB">]])
box.html([[{?5085:419?}]])
box.out([[</label></div>]])
box.out([[<p>]])
box.html([[{?5085:554?}]])
box.out([[</p>]])
box.out([[<p><strong>]])
box.html([[{?5085:422?}]])
box.out([[</strong>]])
box.html([[ {?5085:975?}]])
box.out([[</p>]])
end
end
function write_orig_annex_js()
local result = ""
if config.DSL_MULTI_ANNEX then
result = box.query("sar:settings/Annex")
end
box.js(tostring(result))
end
function valprog()
end
if box.post.validate == 'apply' then
local valresult, answer = newval.validate(valprog)
box.out(js.table(answer))
box.end_page()
end
if box.get.query == "forecast" then
local answer = {}
answer.done = false
local state = tonumber(box.query("sar:settings/PlannedParamsEval")) or -1
answer.done = state > 1
answer.error = state == 3
if not answer.done then
local starttime = box.get.addinfo
local diff = starttime and os.difftime(os.time(), starttime) or 0
if not starttime then
answer.addinfo = os.time()
elseif diff > 10 then
answer.done = true
end
end
g_forecast.us = luadsl.getSmartDsl(1, "us")
g_forecast.ds = luadsl.getSmartDsl(1, "ds")
if answer.done then
local exp_analysis = tonumber(g_forecast.us.EXPECTED_ANALYSIS) or -1
if not (exp_analysis == 0 or exp_analysis == 3) then
answer.error = true
end
exp_analysis = tonumber(g_forecast.ds.EXPECTED_ANALYSIS) or -1
if not (exp_analysis == 0 or exp_analysis == 3) then
answer.error = true
end
answer.showresult = true
if answer.error then
answer.showhtml = html.div{
[[{?5085:992?}]],
html.br{},
[[{?5085:33?}]],
html.br{},
[[{?5085:108?}]]
}.get(true)
else
local unit = [[ {?5085:943?}]]
answer.showhtml = html.div{
[[{?5085:450?}]],
html.p{
[[{?5085:439?} ]] .. (g_forecast.ds.EXPECTED_ACTUAL_DR or "") .. unit,
html.br{},
[[{?5085:417?} ]] .. (g_forecast.us.EXPECTED_ACTUAL_DR or "") .. unit
},
html.br{},
[[{?5085:802?}]],
html.br{},
[[{?5085:664?}]]
}.get(true)
end
end
box.out(js.table(answer))
box.end_page()
end
if box.post.ispchangedone and not box.post.ispchangecancel then
local saveset = {}
cmtable.add_var(saveset, "sar:settings/DownstreamMarginOffset", box.post.marge_receive)
cmtable.add_var(saveset, "sar:settings/DsINP", box.post.inp)
cmtable.add_var(saveset, "sar:settings/UsNoiseBits", box.post.marge_send)
cmtable.add_var(saveset, "sar:settings/RFI_mode", box.post.rfi)
local err, msg = box.set_config(saveset)
if err == 0 then
http.redirect(box.glob.script)
else
local criterr=general.create_error_div(err,msg)
box.out(criterr)
end
end
get_var()
if ( next(box.post) and ((box.post.apply) or (box.post.reset) or box.post.forecast)) then
local saveset={}
local reboot_needed = false
if box.post.forecast == "1" then
refill_user_input()
cmtable.add_var(saveset, "sar:settings/PlannedDownstreamMarginOffset", g_data.marge_receive)
cmtable.add_var(saveset, "sar:settings/PlannedDsINP", g_data.inp)
cmtable.add_var(saveset, "sar:settings/PlannedRFI_mode", g_data.rfi)
cmtable.add_var(saveset, "sar:settings/PlannedUsNoiseBits", g_data.marge_send)
cmtable.add_var(saveset, "sar:settings/PlannedParamsEval", "1")
local err, msg = box.set_config(saveset)
if err == 0 then
http.redirect(build_forecast_url())
else
http.redirect(href.get("/internet/dsl_line_settings.lua"))
end
elseif (box.post.reset=="1") then
cmtable.add_var( saveset, "sar:settings/ResetUserStabilitySettings", "1")
local err, msg = box.set_config( saveset)
if err ~= 0 then
end
http.redirect(href.get("/internet/dsl_line_settings.lua"))
elseif ( box.post.apply) then
refill_user_input()
cmtable.add_var(saveset, "sar:settings/DownstreamMarginOffset", g_data.marge_receive)
cmtable.add_var(saveset, "sar:settings/DsINP", g_data.inp)
cmtable.add_var(saveset, "sar:settings/RFI_mode", g_data.rfi)
cmtable.add_var(saveset, "sar:settings/UsNoiseBits", g_data.marge_send)
if config.DSL_MULTI_ANNEX and box.post.annex then
cmtable.add_var(saveset, "sar:settings/Annex", box.post.annex)
end
if config.DSL_2DP then
if g_data.data_pump ~= box.query("sar:settings/IsLastReleasedDP") then
reboot_needed = true
cmtable.add_var(saveset, "sar:settings/IsLastReleasedDP", g_data.data_pump)
end
end
local err, msg = box.set_config(saveset)
if config.DSL_MULTI_ANNEX and box.post.annex then
reboot_needed = reboot_needed or box.query("box:status/rebooting") ~= "0"
end
if reboot_needed then
http.redirect(href.get("/reboot.lua", http.url_param("extern_reboot", "1")))
end
if err ~= 0 then
local criterr=general.create_error_div(err,msg)
box.out(criterr)
end
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/dsl_line_settings.css">
<style type="text/css">
</style>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript">
var g_IsApplyPressed = true;
var g_old_dsl_version = "<?lua box.js(g_data.data_pump)?>"=="1";
var gForecastAvailable = <?lua box.out(tostring(forecast_available())) ?>;
function initForecastLinkDisplay() {
var radios = {
"marge_receive_value": "",
"inp_value": "",
"rfi_value": "",
"marge_send_value": ""
};
function onClick(evt) {
var clicked = jxl.evtTarget(evt);
if (clicked.name && radios[clicked.name]) {
for (var radio in radios) {
var val = jxl.getRadioValue(radio);
if (val !== radios[radio]) {
jxl.show("uiForecastLink");
return;
}
}
jxl.hide("uiForecastLink");
}
}
if (gForecastAvailable){
for (var radio in radios) {
radios[radio] = jxl.getRadioValue(radio);
}
jxl.addEventHandler("uiSNRSetTable", "click", onClick);
}
}
function annexChanged() {
var origAnnex = "<?lua write_orig_annex_js() ?>";
if (origAnnex) {
return !jxl.getChecked("uiAnnex" + origAnnex);
}
}
function ui_DoOnMainFormSubmit() {
if (g_IsApplyPressed == true) {
var msgtext = ["{?5085:142?}"];
if (annexChanged()) {
msgtext.push("{?5085:620?}");
}
if (g_old_dsl_version != jxl.getChecked("uiViewDslVersion")) {
msgtext.push("{?5085:727?}");
}
else {
msgtext.push("{?5085:944?}");
}
if (!confirm(msgtext.join("\n"))) {
return false;
}
} else if (g_IsApplyPressed == false) {
}
}
function OnReset()
{
var res = confirm("{?5085:777?}");
if (res == false) {
return;
}
g_IsApplyPressed = false;
jxl.setValue("ui_Reset","1");
jxl.get("uiApply").click();
return;
}
function onForecast() {
g_IsApplyPressed = false;
jxl.setValue("uiForecast","1");
jxl.get("uiApply").click();
return;
}
function init() {
}
function onDataPump(isChecked) {
if (isChecked)
{
alert("{?5085:851?}\n{?5085:521?}");
}
}
ready.onReady(ajaxValidation({
okCallback: ui_DoOnMainFormSubmit
}));
ready.onReady(init);
ready.onReady(initForecastLinkDisplay);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div>
<p>{?5085:828?}</p>
<hr>
<p>{?5085:492?}</p>
<div>
<table id="uiSNRSetTable" class="SNRSetTable" style="">
<colgroup>
<col width="120px">
<col width="40px">
<col width="70px">
<col width="40px">
<col width="70px">
<col width="40px">
<col width="70px">
<col width="40px">
<col width="70px">
<col width="40px">
</colgroup>
<tr>
<td></td>
<td style="" colspan="2">{?5085:720?}</td>
<td style="" colspan="5">&nbsp;</td>
<td style="text-align:right;" colspan="2"><div>{?5085:580?}</div></td>
</tr>
<tr>
<td></td>
<td><div class="smart_marker">&nbsp;</div></td>
<td colspan="7">&nbsp;</td>
<td ><div class="smart_marker">&nbsp;</div></td>
</tr>
<?lua
write_headline(box.tohtml([[{?5085:92?}]]))
write_row(box.tohtml([[{?5085:18?}]]), [[marge_receive_value]], [[uiViewDefaultMargeReceive]], nil, g_data.marge_receive, g_data.marge_receive_smart_dsl, g_data.marge_receive_all_values)
write_row(box.tohtml([[{?5085:118?}]]), [[inp_value]], [[uiViewDefaultINP]], nil, g_data.inp, g_data.inp_smart_dsl, g_data.inp_all_values)
write_row(box.tohtml([[{?5085:673?}]]), [[rfi_value]], [[uiViewDefaultRFI]], nil, g_data.rfi, g_data.rfi_smart_dsl, g_data.rfi_all_values)
write_headline(box.tohtml([[{?5085:540?}]]))
write_row(box.tohtml([[{?5085:356?}]]), [[marge_send_value]], [[uiViewDefaultMargeSend]], nil, g_data.marge_send, g_data.marge_send_smart_dsl, g_data.marge_send_all_values)
if (get_smart_style()~="") then
box.out([[<td></td><td><div class="]], get_smart_style(), [[">&nbsp;</td><td colspan="8" class="legend">]])
box.html([[{?5085:455?}]])
box.out([[</div></td>]])
end
?>
</table>
</div>
<?lua
box.out([[<p><a href="javascript:OnReset();">]])
box.html([[{?5085:123?}]])
box.out([[</a>]])
box.out([[<input type="hidden" name="reset" id="ui_Reset" value="0">]])
if forecast_available() then
box.out([[<a id="uiForecastLink" style="display:none;margin-left: 30px;" href="javascript:onForecast();">]])
box.html([[{?5085:508?}]])
box.out([[</a>]])
box.out([[<input type="hidden" name="forecast" id="uiForecast" value="0">]])
end
box.out([[</p>]])
?>
<p class="normal_p">
<b>{?5085:666?}</b><br>
{?5085:421?}<br>
</p>
<?lua write_data_pump_section() ?>
</div>
<?lua
write_multi_annex_visible()
?>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?5085:452?}</button>
<button type="submit" name="cancel">{?5085:129?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
