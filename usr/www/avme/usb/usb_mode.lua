<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_usb_einstellungen.html"
dofile("../templates/global_lua.lua")
require("http")
udev = require("usb_devices")
conv = require("convert_file_size")
require("cmtable")
require("general")
g_data = {}
g_data.back="2"
g_data.side="2"
function get_var()
local bitmask=box.query("ctlusb:settings/usb3port_config")
if bitmask=="0" then
g_data.back="2"
g_data.side="2"
elseif bitmask=="1" then
g_data.back="3"
g_data.side="2"
elseif bitmask=="2" then
g_data.back="2"
g_data.side="3"
elseif bitmask=="3" then
g_data.back="3"
g_data.side="3"
end
g_data.spindown = box.query("ctlusb:settings/storage_spindown")
g_data.spindown_time = box.query("ctlusb:settings/storage_spindown_time")
g_data.can_disconnect = udev.usb_mem_mount_check()
end
get_var()
if next(box.post) and box.post.btn_spin_down then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "ctlusb:settings/storage_spindown_test" , "1")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
box.out(general.create_error_div(err,msg))
else
if box.post.spindown then
g_data.spindown = "1"
end
g_data.spindown_time = box.post.spin_down_time
end
end
if next(box.post) and box.post.btn_save then
local ctlmgr_save={}
cmtable.save_checkbox(ctlmgr_save, "ctlusb:settings/storage_spindown" , "spindown")
if box.post.spindown and box.post.spin_down_time then
cmtable.add_var(ctlmgr_save, "ctlusb:settings/storage_spindown_time" , box.post.spin_down_time)
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=general.create_error_div(err,msg)
box.out(criterr)
else
get_var()
end
end
function write_checked(usbport, usbmode)
if g_data[usbport]==usbmode then
box.out([[ checked ]])
end
end
function get_spindowntime_select()
local txt= [[<select id="uiViewSpinDownTime" name="spin_down_time">]]
local times = {{val=300, show=5},
{val=600, show=10},
{val=1200, show=20},
{val=1800, show=30},
{val=3600, show=60},
{val=5400, show=90},
{val=7200, show=120}}
for i,v in ipairs(times) do
txt = txt..[[<option value="]]..v.val..[[" ]]
local time = tonumber(g_data.spindown_time)
if time and time == v.val then
txt = txt..[[selected="selected"]]
end
txt = txt..[[>]]..v.show..[[</option>]]
end
return txt..[[</select>]]
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript">
function init()
{
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div id="uiViewShowSpinDown" <?lua if not(g_data.can_disconnect) then box.out([[style="display:none;"]]) end ?>>
<h4>{?33:805?}</h4>
<div class="formular">
<input type="checkbox" name="spindown" id="uiViewSpindown" onclick="onSpindownActiv()" <?lua if g_data.spindown=="1" then box.out("checked") end?>>
<label for="uiViewSpindown">{?33:198?}</label>
<div id="uiViewShowSpinDownTimeBox" class="formular">
<p>
<?lua
local txt = [[{?33:837?}]]
txt = general.sprintf(txt, get_spindowntime_select())
box.out(txt)
?>
</p>
<p>
{?33:348?}
</p>
<div class="btn_form">
<button type="submit" id="uiViewSpinTest" name="btn_spin_down">{?33:597?}</button>
</div>
</div>
</div>
</div>
<div id="btn_form_foot">
<button type="submit" name="btn_save" id="btnSave">{?txtApply?}</button>
<button type="submit" name="btn_cancel" id="btnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/mouseover.js"></script>
<script type="text/javascript">
function onSpindownActiv()
{
jxl.disableNode("uiViewShowSpinDownTimeBox", !jxl.getChecked("uiViewSpindown"));
}
ready.onReady(onSpindownActiv);
</script>
<?include "templates/html_end.html" ?>
