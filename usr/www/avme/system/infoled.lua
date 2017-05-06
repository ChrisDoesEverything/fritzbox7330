<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_infoanzeige.html"
dofile("../templates/global_lua.lua")
require("cmtable")
if box.post.action then
local num = tonumber(box.post.event)
if num >= 0 and num < 17 then
local saveset = {}
cmtable.add_var(saveset, "box:settings/infoled_reason", tostring(num))
local errcode, errmsg = box.set_config(saveset)
end
end
g_event = box.query("box:settings/infoled_reason")
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<p>{?4893:3913?}</p>
<hr>
<form action="/system/infoled.lua" method="POST" class="close">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<h4>{?4893:583?}</h4>
<div class="formular">
<p>{?4893:976?}</p>
<label for="uiEvent">{?4893:2332?}</label>
<select id="uiEvent" name="event">
<optgroup label="&nbsp;">
<option value="4" <?lua if g_event=="4" then box.out("selected") end ?>>{?4893:6945?}</option>
<?lua
local is_umts_on = function()
return config.USB_GSM and box.query("umts:settings/enabled") == '1'
end
local pppoe_or_umts_on = function()
return box.query("connection0:settings/type") == 'pppoe' or is_umts_on()
end
if ( not config.DOCSIS and pppoe_or_umts_on())then
local sel=""
if g_event=="1" then sel="selected" end
box.out([[<option value="1" ]]..sel..[[>{?4893:4613?}</option>]])
end
?>
</optgroup>
<?lua
if config.WLAN and config.WLAN_GUEST then
box.out([[
<optgroup label="&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;">
]])
box.out([[<option value="15"]])
if g_event == "15" then box.out([[ selected]]) end
box.out([[>]])
box.html([[{?4893:278?}]])
box.out([[</option>]])
box.out([[<option value="16"]])
if g_event == "16" then box.out([[ selected]]) end
box.out([[>]])
box.html([[{?4893:441?}]])
box.out([[</option>]])
end
if config.ETH_COUNT > 1 or config.USB_HOST or config.USB_HOST_AVM or config.USB_HOST_TI then
box.out([[
<optgroup label="&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;">
]])
if config.ETH_COUNT > 1 then
box.out([[
<option value="5"]])
if g_event=="5" then box.out(" selected") end
box.out([[>{?4893:9456?}</option>
]])
end
if config.USB_HOST or config.USB_HOST_AVM or config.USB_HOST_TI then
box.out([[
<option value="7"]])
if g_event=="7" then box.out(" selected") end
box.out([[>{?4893:8314?}</option>
]])
end
box.out([[
</optgroup>
]])
end
local gui_use_fritz_app_fon = false
if config.DECT2 or (config.FON and not gui_use_fritz_app_fon) then
box.out([[
<optgroup label="&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;">
]])
if config.FON and not gui_use_fritz_app_fon then
box.out([[<option value="9"]])
if g_event=="9" then box.out(" selected") end
box.out([[>{?4893:8544?}</option>]])
if config.TAM_MODE > 0 then
box.out([[
<option value="11"]])
if g_event=="11" then box.out(" selected") end
box.out([[>{?4893:4839?}</option>
<option value="13"]])
if g_event=="13" then box.out(" selected") end
if config.FAX2MAIL then
box.out([[>{?4893:8451?}</option>
]])
else
box.out([[>{?4893:4243?}</option>
]])
end
end
box.out([[
<option value="8"]])
if g_event=="8" then box.out(" selected") end
box.out([[>{?4893:8089?}</option>
]])
end
if config.DECT2 then
box.out([[
<option value="12"]])
if g_event=="12" then box.out(" selected") end
box.out([[>{?4893:6757?}</option>
]])
end
box.out([[
</optgroup>
]])
end
?>
<optgroup label="&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;&mdash;">
<option value="14" <?lua if g_event=="14" or g_event=="3" or g_event=="0" then box.out("selected") end ?>>{?4893:241?}</option>
</optgroup>
</select>
</div>
<hr>
<h4>{?4893:779?}</h4>
<div class="formular">
<p>{?4893:6099?}</p>
<p>{?4893:419?}</p>
<ul>
<li>{?4893:186?}</li>
<?lua
if config.WLAN and (config.USB_HOST or config.USB_HOST_AVM or config.USB_HOST_TI) then
box.out([[
<li>{?4893:8140?}</li>
]])
end
if config.DECT2 then
box.out([[
<li>{?4893:7701?}</li>
]])
end
if config.HOME_AUTO then
box.out([[
<li>{?4893:696?}</li>
]])
end
?>
</ul>
</div>
<div id="btn_form_foot">
<button type="submit" name="action">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
