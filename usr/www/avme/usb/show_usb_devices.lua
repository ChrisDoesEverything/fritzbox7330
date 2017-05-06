<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_usb_status.html"
dofile("../templates/global_lua.lua")
udev = require("usb_devices")
conv = require("convert_file_size")
require("cmtable")
require("general")
if next(box.post) and (box.post.eject_usb or box.post.eject_all) then
local eject_usbdev = "all"
if box.post.eject_usb then
eject_usbdev = box.tohtml(box.post.eject_usb)
end
http.redirect(href.get('/usb/usb_diskcut.lua', 'usbdev='..eject_usbdev, 'back_to_page='..box.glob.script))
end
g_usb_var = {}
function get_var()
g_usb_var.spindown = box.query("ctlusb:settings/storage_spindown")
g_usb_var.spindown_time = box.query("ctlusb:settings/storage_spindown_time")
g_usb_var.hubcount = tonumber(box.query("ctlusb:settings/hubcount")) or 0
g_usb_var.power_rejected_cnt= tonumber(box.query("ctlusb:settings/power_rejected")) or 0
g_usb_var.expert = box.query("box:settings/expertmode/activated")
g_usb_var.morphstick = box.query("morphstick:settings/enabled")
g_usb_var.can_disconnect = udev.usb_mem_mount_check()
end
get_var()
if next(box.post) and box.post.btn_refresh then
if box.post.spindown then
g_usb_var.spindown = "1"
else
g_usb_var.spindown = "0"
end
if box.post.spin_down_time then
g_usb_var.spindown_time = box.post.spin_down_time
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
box.out(general.create_error_div(err,msg))
else
get_var()
end
end
function get_pri_status(state)
local num_state = tonumber(state)
local pri_err = {[[{?5283:750?}]],
[[{?5283:234?}]],
[[{?5283:172?}]],
[[{?5283:178?}]],
[[{?5283:653?}]]
}
if num_state and type(num_state) == "number" and num_state <= #pri_err and num_state >= 0 then
num_state = num_state + 1
else
num_state = #pri_err
end
return pri_err[num_state]
end
function get_gsm_status(state)
local str = ""
local num_state = tonumber(state)
str = [[<a href="]]..href.get("/internet/umts_settings.lua")..[[">]]..box.tohtml([[{?5283:80?}]])..[[</a> / ]]..box.tohtml([[{?5283:91?}: ]])
if state == "0" then
str = str..box.tohtml([[{?5283:512?}]])
elseif state == "1" then
str = str..box.tohtml([[{?5283:279?}]])
elseif state == "2" then
str = str..box.tohtml([[{?5283:202?}]])
elseif state == "3" then
str = str..box.tohtml([[{?5283:24?}]])
elseif state == "5" then
str = str..box.tohtml([[{?5283:37?}]])
else
str = str..box.tohtml([[{?5283:711?}]])
end
return str
end
function get_filesystem(log_vol)
local tab = {}
for i,v in ipairs(log_vol) do
tab[box.tohtml(string.upper(v.filesystem))] = true
end
tab = table.keys(tab)
return table.concat(tab, ', ')
end
function get_usb_dev_str(dev)
local tmp = ""
if dev.vendor then
tmp = box.tohtml(dev.vendor)
end
if dev.model then
if tmp ~= "" then
tmp = tmp..[[ ]]
end
tmp = tmp..box.tohtml(dev.model)
elseif dev.name then
if tmp ~= "" then
tmp = tmp..[[ ]]
end
tmp = tmp..box.tohtml(dev.name)
end
if tmp == "" then
tmp = box.tohtml([[{?5283:161?}]])
end
return tmp
end
function get_device_name(ip)
local str = ip
require("net_devices")
g_dev = net_devices.g_list
if g_dev and g_dev[1] then
for idx, elem in ipairs(g_dev) do
if elem.ip and elem.ip == ip then
str = net_devices.get_displayname(elem)
break;
end
end
end
return str
end
function create_usb_dev_table()
local str = ""
str = str..[[<table class="zebra" id="uiViewUsbDevTable">
<tr class="thead">
<th class="sortable usb_dev_col">{?5283:451?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable usb_typ_col">{?5283:33?}<span class="sort_no">&nbsp;</span></th>
<th >{?5283:856?}</th>
<th class="buttonrow"></th>
</tr>]]
local usb_dev = udev.get_list_of_usb_devices()
local usb_dev_count = udev.get_total_usb_devices_count()
local usb_show_count = 0
if usb_dev_count == 0 then
str = str..[[<tr><td colspan="4" class="hint">]]
str = str..[[{?5283:858?}</td></tr>]]
else
for i,v in pairs(usb_dev) do
if i == "mem" and v then
for j,val in ipairs(v) do
local can_disconnect, not_accessable_disc, not_accessable_part = udev.usb_mem_mount_check(val)
usb_show_count=usb_show_count + 1
local tt_txt = ""
if val.any_log then
tt_txt = tt_txt..box.tohtml([[{?5283:989?}]])..[[: ]]..conv.humanReadable(val.capacity, "byte", 2, true, true)..[[<br>]]
tt_txt = tt_txt..box.tohtml([[{?5283:766?}]])..[[: ]]..get_filesystem(val.log_vol)..[[<br>]]
tt_txt = tt_txt..box.tohtml([[{?5283:446?}]])..[[: ]]..box.tohtml(val.conntype)..[[, ]]..box.tohtml([[{?5283:651?}]])..[[: ]]..box.tohtml(val.speed)..[[ {?5283:590?}]]
elseif val.status == "Online" then
tt_txt = tt_txt..box.tohtml([[{?5283:739?}]])
else
if tt_txt ~= "" then
tt_txt = tt_txt..[[<br>]]
end
if val.status == "Standby" then
tt_txt = tt_txt..box.tohtml([[{?5283:308?} ]])
end
if val.status == "Offline" then
tt_txt = tt_txt..box.tohtml([[{?5283:861?} ]])
end
tt_txt = tt_txt..[[<a href="]]..href.get("/system/syslog.lua", "tab=usb")..[[">]]..box.tohtml([[({?5283:397?}).]])..[[</a> ]]
if val.status == "Standby" then
tt_txt = tt_txt..box.tohtml([[{?5283:579?}]])
end
end
str = str..[[<tr><td class="usb_dev_col"><span>]]
str = str..get_usb_dev_str(val)
str = str..[[</span></td><td class="usb_typ_col"><span>]]
str = str..box.tohtml([[{?5283:448?}]])
str = str..[[</span></td><td>]]
str = str..tt_txt
str = str..[[</td><td class="buttonrow">]]
if can_disconnect then
str = str..general.get_icon_button("/css/default/images/eject_usb.gif", "eject_"..box.tohtml(val.idx), "eject_usb", box.tohtml(val.idx), [[{?5283:6?}]], "", false)
end
str = str..[[</td></tr>]]
end
elseif i == "pri" and v and v.avail == "1" then
usb_show_count=usb_show_count + 1
str = str..[[<tr><td class="usb_dev_col"><span>]]
str = str..get_usb_dev_str(v)
str = str..[[</span></td><td class="usb_typ_col"><span>]]
str = str..box.tohtml([[{?5283:687?}]])
str = str..[[</span></td><td>]]
str = str..box.tohtml(get_pri_status(v.status))
str = str..[[</td><td class="buttonrow"></td></tr>]]
elseif i == "gsm" and v and v.avail == "1" then
usb_show_count=usb_show_count + 1
str = str..[[<tr><td class="usb_dev_col"><span>]]
str = str..get_usb_dev_str(v)
str = str..[[</span></td><td class="usb_typ_col"><span>]]
str = str..box.tohtml([[{?5283:508?}]])
str = str..[[</span></td><td>]]
str = str..get_gsm_status(v.status)
str = str..[[</td><td class="buttonrow"></td></tr>]]
elseif i == "gsm" and box.query("ctlusb:settings/tethering_device") ~= "" then
usb_show_count=usb_show_count + 1
str = str..[[<tr><td class="usb_dev_col"><span>]]
str = str..box.query("ctlusb:settings/tethering_device")
str = str..[[</span></td><td class="usb_typ_col"><span>]]
str = str..box.tohtml([[{?5283:655?}]])
str = str..[[</span></td><td>]]
str = str..[[<a href="]]..href.get("/internet/umts_settings.lua")..[[">]]..box.tohtml([[{?5283:2734?}]])..[[</a> / ]]..box.tohtml([[{?5283:506?}]])
str = str..[[</td><td class="buttonrow"></td></tr>]]
elseif i == "aur" and v then
for j,val in pairs(v) do
usb_show_count=usb_show_count + 1
local usb_typ = ""
if val.class and val.class ~= "" then
if val.class == "08" then
usb_typ = box.tohtml([[{?5283:718?}]])
elseif val.class == "07" then
usb_typ = box.tohtml([[{?5283:629?}]])
end
end
if usb_typ == "" then
usb_typ = box.tohtml([[{?5283:546?}]])
end
local usb_prop = box.tohtml([[{?5283:874?}]])
if val.client and val.client ~= "" then
if usb_prop ~= "" then
usb_prop = usb_prop..[[<br>]]
end
usb_prop = usb_prop..box.tohtml([[{?5283:50?} ]])..box.tohtml(get_device_name(val.client))
end
if val.comment and val.comment ~= "" then
if usb_prop ~= "" then
usb_prop = usb_prop..[[<br>]]
end
usb_prop = usb_prop..val.comment
end
str = str..[[<tr><td class="usb_dev_col">]]..get_usb_dev_str(val)..[[</td>]]
str = str..[[<td class="usb_typ_col">]]..usb_typ..[[</td>]]
str = str..[[<td>]]..usb_prop
str = str..[[</td><td class="buttonrow"></td></tr>]]
end
end
end
if g_usb_var.hubcount > 0 then
str = str..[[<tr><td class="usb_dev_col">]]
if g_usb_var.hubcount == 1 then
str = str..box.tohtml([[{?5283:693?}]])
elseif g_usb_var.hubcount > 1 then
str = str..tostring(g_usb_var.hubcount)..[[ ]]..box.tohtml([[{?5283:315?}]])
end
str = str..[[</td><td class="usb_typ_col">]]..box.tohtml([[{?5283:486?}]])..[[</td>]]
str = str..[[<td>]]..box.tohtml([[{?5283:259?}]])..[[</td><td class="buttonrow"></td></tr>]]
usb_show_count=usb_show_count + g_usb_var.hubcount
end
if usb_show_count < usb_dev_count then
local diff = usb_dev_count - usb_show_count
local tmp_hub = ""
local tmp_aura = ""
if g_usb_var.power_rejected_cnt > 0 then
if g_usb_var.power_rejected_cnt >= diff then
if diff == 1 then
tmp_hub = [[<br>]]..box.tohtml([[{?5283:841?}]])
else
tmp_hub = [[<br>]]..box.tohtml([[{?5283:112?}]])
end
else
tmp_hub = [[<br>]]..box.tohtml(general.sprintf([[{?5283:672?}]], tostring(g_usb_var.power_rejected_cnt)))
end
tmp_hub = tmp_hub..box.tohtml([[ {?5283:602?}]])
end
if config.AURA and not(udev.aura_for_other_aktiv()) and g_usb_var.power_rejected_cnt < diff then
tmp_aura = [[<br>]]..box.tohtml([[{?5283:277?}]])
end
if diff == 1 then
str = str..[[<tr><td>]]..box.tohtml([[{?5283:457?}]])..[[</td><td>]]..box.tohtml([[{?5283:751?}]])..[[</td>]]
str = str..[[<td>]]..box.tohtml([[{?5283:26?}]])..tmp_aura..tmp_hub..[[</td><td class="buttonrow"></td></tr>]]
else
str = str..[[<tr><td>]]..diff..box.tohtml([[ {?5283:108?}]])..[[</td><td>]]..box.tohtml([[{?5283:356?}]])..[[</td>]]
str = str..[[<td>]]..box.tohtml([[{?5283:237?}]])..tmp_hub..tmp_aura..[[</td><td class="buttonrow"></td></tr>]]
end
end
end
box.out(str..[[</table>]])
box.out([[<div class="btn_form">]])
box.out([[<button type="submit" name="btn_refresh" id="btnRefresh">]])
box.html([[{?txtRefresh?}]])
box.out([[</button></div>]])
end
--function get_spindowntime_select()
-- local txt= [[<select id="uiViewSpinDownTime" name="spin_down_time">]]
-- local times = {{val=300, show=5},
-- {val=600, show=10},
-- {val=1200, show=20},
-- {val=1800, show=30},
-- {val=3600, show=60},
-- {val=5400, show=90},
-- {val=7200, show=120}}
--
-- for i,v in ipairs(times) do
-- txt = txt..[[<option value="]]..v.val..[[" ]]
-- local time = tonumber(g_usb_var.spindown_time)
-- if time and time == v.val then
-- txt = txt..[[selected="selected"]]
-- end
-- txt = txt..[[>]]..v.show..[[</option>]]
-- end
-- return txt..[[</select>]]
--end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
{?5283:971?}
<?lua
local txt = [[ {?5283:551?}]]
txt = general.sprintf(txt, [[<a href="]]..href.get("/storage/settings.lua")..[[">]], [[</a>]])
box.out(txt)
?>
</p>
<hr>
<h4>{?5283:917?}</h4>
<div class="formular">
<?lua box.out(create_usb_dev_table()) ?>
<div id="uiViewShowDisconnect" <?lua if config.AURA and not(g_usb_var.can_disconnect) then box.out([[style="display:none;"]]) end ?>>
<span class="hintMsg">{?5283:885?}</span>
<p>
{?5283:945?}
</p>
<div class="btn_form">
<button type="submit" id="uiViewBtnDisconnect" name ="eject_all">{?5283:850?}</button>
</div>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/mouseover.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
function onSpindownActiv()
{
jxl.disableNode("uiViewShowSpinDownTimeBox", !jxl.getChecked("uiViewSpindown"));
}
function initTableSorter() {
sort.init("uiViewUsbDevTable");
sort.setDirection(0,-1);
sort.sort_table(0);
}
ready.onReady(initTableSorter);
ready.onReady(onSpindownActiv);
</script>
<?include "templates/html_end.html" ?>
