<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_wlan_sicherheit_wps.html"
dofile("../templates/global_lua.lua")
require("general")
require("http")
require("config")
require("cmtable")
require("val")
require("href")
g_back_to_page = http.get_back_to_page( "/wlan/wps.lua" )
g_error_shown=0
g_oldpin=""
g_noPin=[[{?357:988?}]]
g_errmsg = nil
g_val = {
prog = [[
]]
}
g_sta_enabled=box.query("wlan:settings/STA_enabled")
g_ap_enabled =box.query("wlan:settings/ap_enabled")
g_rep_mode=general.get_bridge_mode()
g_is_repeater=false
function translateWpsMode(mode)
mode = tonumber(mode) or 0;
return mode;
end
function retranslateWpsMode(mode)
mode = tonumber(mode) or 0;
return mode
end
function get_mode_as_str(mode)
return tostring(retranslateWpsMode(mode))
end
function read_box_values()
end
function refill_user_input_from_post()
end
function refill_user_input_from_get()
end
if next(box.post) then
if box.post.apply then
local saveset = {}
local wpspin = ""
local err=0
local redirect_to_wps_test = true
if (box.query("wlan:settings/hidden_ssid")=="1") then
if (box.post.ShowSSID) then
cmtable.add_var(saveset, "wlan:settings/hidden_ssid","0")
cmtable.add_var(saveset, "wlan:settings/wps_mode",get_mode_as_str(1))
redirect_to_wps_test = false
end
else
if (box.post.WpsActive==nil) then
cmtable.add_var(saveset, "wlan:settings/wps_mode","0")
redirect_to_wps_test = false
else
cmtable.add_var(saveset, "wlan:settings/wps_mode","1")
if (box.post.wpsmode=="pbc") then
cmtable.add_var(saveset, "wlan:settings/wps_mode",get_mode_as_str(2))
elseif (box.post.wpsmode=="pin_intern") then
cmtable.add_var(saveset, "wlan:settings/wps_mode",get_mode_as_str(3))
cmtable.add_var(saveset, "wlan:settings/wps_pin",box.post.oldpin)
wpspin=box.post.oldpin
elseif (box.post.wpsmode=="pin_extern") then
wpspin=box.post.wps_pin
local pat1=[[^%d%d%d%d$]]
local pat2=[[^%d%d%d%d%d%d%d%d$]]
if (string.find(wpspin, pat1) or string.find(wpspin, pat2)) then
if (string.len(wpspin)==8 and box.post.pinchecked=="0") then
local sum=0
for i=0,7,1 do
local z = tonumber(string.sub(wpspin,i+1,i+1))
if ((i%2)==0) then
sum=sum+3*z
else
sum=sum+z
end
end
if ((sum%10)~=0) then
g_errmsg=general.sprintf([[{?357:464?}]],wpspin)
end
end
if (g_errmsg==nil) then
cmtable.add_var(saveset, "wlan:settings/wps_mode",get_mode_as_str(4))
cmtable.add_var(saveset, "wlan:settings/wps_pin",box.post.wps_pin)
end
else
g_errmsg=g_noPin
end
end
end
end
if (g_errmsg~=nil) then
refill_user_input_from_post()
else
err, g_errmsg = box.set_config(saveset)
if err==0 and redirect_to_wps_test then
http.redirect(href.get("/wlan/wps_test.lua","wpsmode="..tostring(box.post.wpsmode).."&wpspin="..tostring(wpspin)))
else
refill_user_input_from_post()
end
end
elseif box.post.cancel then
http.redirect(href.get(g_back_to_page))
return
end
end
g_CurrentEncrypt =box.query("wlan:settings/encryption")
g_CurrentSecLevel ="none"
g_is_double_wlan =false
if config.WLAN.is_double_wlan then
g_is_double_wlan =true
end
read_box_values()
math.randomseed(os.time())
function calc_new_pin()
function stRandZiff()
return math.floor(math.random()*10);
end
local i=0
local pin = ''
local sum = 0
for i=0,6,1 do
local z = stRandZiff()
pin =pin..tostring(z)
if ((i%2)==0) then
sum=sum+3*z
else
sum=sum+z
end
end
pin =pin.. tostring((10-(sum%10))%10)
return pin
end
function write_dorename_apply_btn_js()
box.out(tostring(box.query("wlan:settings/hidden_ssid") ~= "1"))
end
function write_new_pin()
g_oldpin=calc_new_pin()
box.out(g_oldpin)
end
function get_apply_state()
if (g_error_shown==1) then
return "disabled"
end
return ""
end
function init()
if (g_error_shown==0) then
if (box.query("wlan:settings/hidden_ssid")=="1") then
g_error_shown=2
end
local current_encrypt=box.query("wlan:settings/encryption")
if not(current_encrypt=="3" or current_encrypt=="4" or (current_encrypt=="2" and config.WLAN.is_wps_wpa_allowed)) then
g_error_shown=1
end
end
end
function write_show(explainId)
if (explainId=="hiddenssid") then
if (box.query("wlan:settings/hidden_ssid")~="1") then
box.out("display:none;")
return
end
g_error_shown=2
end
if (explainId=="nowpa") then
local current_encrypt=box.query("wlan:settings/encryption")
if not(current_encrypt=="0" or current_encrypt=="1") then
box.out("display:none;")
return
end
g_error_shown=1
end
if (explainId=="nowpa2") then
local current_encrypt=box.query("wlan:settings/encryption")
if (current_encrypt=="3" or current_encrypt=="4" or (current_encrypt=="2" and config.WLAN.is_wps_wpa_allowed)) then
box.out("display:none;")
return
end
g_error_shown=1
end
if (explainId=="all") then
if (g_error_shown~=0) then
box.out("display:none;")
return
end
end
return
end
function write_wps_checked()
if (box.query("wlan:settings/wps_mode")~="0") then
box.out([[checked="checked"]])
end
end
function write_explain2()
box.out(general.sprintf([[{?357:641?}]],[[<a href="]]..href.get('/wlan/encrypt.lua')..[[">]],[[</a>]]))
end
init()
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<style type="text/css">
</style>
<link rel="stylesheet" type="text/css" href="/css/default/wds.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var g_CurrentMode ="<?lua box.out(g_CurrentMode) ?>";
var g_isDoubleWlan =<?lua box.out(tostring(g_is_double_wlan)) ?>;
var g_seclevel ="<?lua box.out(g_CurrentSecLevel) ?>";
function init()
{
uiOnChangeWPSActivated(jxl.getChecked("uiView_WPSActivated"))
}
function uiDoOnMainFormSubmit()
{
var ret;
<?lua
val.write_js_checks(g_val)
?>
var ssidhidden="<?lua box.out(g_error_shown) ?>"=="2"
if (ssidhidden)
{
if (jxl.getChecked("uiViewShowSSID"))
return true;
return false;
}
if (!jxl.getChecked("uiView_WPSActivated"))
return true;
if (!checkPin(jxl.getValue("uiWpsPin")))
{
return false;
}
return true;
}
function checkPin(pin){
if (!jxl.getChecked("uiViewMode3"))
{
return true;
}
if (pin.match(/^\d\d\d\d$/)|| pin.match(/^\d\d\d\d\d\d\d\d$/))
{
if (pin.length==8)
{
var sum=0;
for (i=0;i<8;i++)
sum += ((i%2==0) ? 3*Number(pin.charAt(i)) : Number(pin.charAt(i)));
if (sum%10!=0)
{
alert(jxl.sprintf("{?357:156?}",pin));
val.markError("uiWpsPin");
return false;
}
}
return true;
}
var msg="<?lua box.js(g_noPin) ?>";
msg=msg.replace(". ",".\n");
alert(msg);
val.markError("uiWpsPin");
return false;
}
function uiOnChangeInput(value,id)
{
jxl.setText(id,value.length);
}
function onSelectMode(wpsmode)
{
switch(wpsmode)
{
case "pbc":
jxl.show("uiPbc");
jxl.hide("uiPin_intern");
jxl.hide("uiPin_extern");
break;
case "pin_intern":
jxl.hide("uiPbc");
jxl.show("uiPin_intern");
jxl.hide("uiPin_extern");
break;
case "pin_extern":
jxl.hide("uiPbc");
jxl.hide("uiPin_intern");
jxl.show("uiPin_extern");
break;
}
}
function uiOnChangeWPSActivated(checked)
{
jxl.disableNode("uiViewAll",!checked);
if (<?lua write_dorename_apply_btn_js() ?>) {
if (checked) {
jxl.setHtml("uiApply", "{?357:353?}");
}
else {
jxl.setHtml("uiApply", "{?357:348?}");
}
}
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div id="content">
<div style="<?lua write_show('hiddenssid') ?>" class="formular">
<p>{?357:209?}</p><br>
<input type="checkbox" name="ShowSSID" id="uiViewShowSSID">&nbsp;<label for="uiViewShowSSID">{?357:512?}</label>
</div>
<?lua
if config.WLAN.is_wps_wpa_allowed then
box.out([[
<div style="]]) write_show('nowpa') box.out([[" class="formular">
<p>{?357:404?}</p>
<p>]]) write_explain2() box.out([[</p>
</div>]])
else
box.out([[
<div style="]]) write_show('nowpa2') box.out([[" class="formular">
<p>{?357:78?}</p>
<p>]]) write_explain2() box.out([[</p>
</div>]])
end
?>
<div style="<?lua write_show('all') ?>" >
<p>
<?lua
if g_rep_mode=="wlan_bridge" and g_is_repeater then
box.out([[{?357:775?}]])
else
box.out([[{?357:501?}]])
end
?>
</p>
<input type="checkbox" name="WpsActive" onclick="uiOnChangeWPSActivated(this.checked)" id="uiView_WPSActivated" <?lua write_wps_checked()?>>&nbsp;<label for="uiView_WPSActivated">{?357:9381?}</label>
<hr>
<div id="uiViewAll">
<h2>{?357:545?}</h2>
<p>
{?357:915?}<br>
{?357:8167?}
</p>
<div class="formular" >
<input type="radio" id="uiViewMode1" name="wpsmode" value="pbc" onclick="onSelectMode(this.value)" checked="checked">
<label for="uiViewMode1">
{?357:49?}
</label>
<div id="uiPbc" class="formular">
<ol>
<?lua
if g_rep_mode=="wlan_bridge" and g_is_repeater then
box.out([[<li>{?357:9493?}</li>]])
else
box.out([[<li>{?357:491?}</li>]])
end
?>
<li>{?357:419?}</li>
<li>{?357:173?}</li>
</ol>
<p>
<?lua
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
if g_rep_mode=="wlan_bridge" then
box.html([[{?357:648?}]])
else
box.html([[{?357:334?}]])
end
else
if g_rep_mode=="wlan_bridge" then
box.html([[{?357:857?}]])
else
box.html([[{?357:136?}]])
end
end
else
box.html([[{?357:219?}]])
end
?>
</p>
</div>
</div>
<div class="formular" >
<input type="radio" id="uiViewMode2" name="wpsmode" value="pin_intern" onclick="onSelectMode(this.value)">
<label for="uiViewMode2">
{?357:932?}
</label>
<div id="uiPin_intern" style="display:none;" class="formular">
<p>
{?357:973?}
</p>
<ol>
<li>{?357:455?}</li>
<li>
<p>{?357:111?}</p>
<p>{?txtPin?}: <span id="RouterPin" class="CssPin"><?lua write_new_pin() ?></span></p>
<p>{?357:198?}</p>
</li>
</ol>
</div>
</div>
<div class="formular" >
<input type="radio" id="uiViewMode3" name="wpsmode" value="pin_extern" onclick="onSelectMode(this.value)">
<label for="uiViewMode3" >
{?357:930?}
</label>
<div id="uiPin_extern" style="display:none;" class="formular">
<p>
{?357:436?}
</p>
<ol class="ml25">
<li>{?357:400?}</li>
<li>
<p>{?357:238?}<p>
<p>
<label for="uiWpsPin">{?txtPin?}:&nbsp;</label><input type="text" id="uiWpsPin" name="wps_pin" size="8" maxlength="8" >
</p>
</li>
<li>{?357:580?}</li>
</ol>
</div>
</div>
</div>
<?lua
if g_errmsg and string.len(g_errmsg)>0 then
box.out([[<p class="form_input_note ErrorMsg">]])
box.html(g_errmsg)
box.out([[</p>]])
end
?>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="oldpin" value="<?lua box.out(g_oldpin)?>">
<input type="hidden" name="pinchecked" id="uiPinChecked" value="0">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page)?>">
<button type="submit" id="uiApply" name="apply" <?lua box.out(get_apply_state())?>>{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
