<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = 'hilfe_syslog.html'
dofile("../templates/global_lua.lua")
require("general")
require("cmtable")
require("date")
require("net_devices")
if g_print_mode then
g_page_title = general.sprintf([[{?430:377?}]], date.get_current_timestr())
end
g_tabs = {
{ box = "0", param="aus" },
{ box = "3", param="telefon" },
{ box = "2", param="internet" },
{ box = "5", param="usb" },
{ box = "4", param="wlan" },
{ box = "1", param="system" }
}
if next(box.post) and box.post.delete then
local saveset = {}
cmtable.add_var(saveset, "logger:command/clear", "1")
box.set_config(saveset)
end
if next(box.post) and box.post.apply then
local saveset = {}
if (box.post.filter) then
cmtable.add_var(saveset, "wlan:settings/event_control", "7")
else
cmtable.add_var(saveset, "wlan:settings/event_control", "6")
end
box.set_config(saveset)
end
if box.get.tab then
local filter = "0"
for _,tab in ipairs(g_tabs) do
if tab.param == box.get.tab then
filter = tab.box
break
end
end
saveset = {}
cmtable.add_var(saveset, "logger:settings/filter", filter)
box.set_config(saveset)
end
g_filter = box.query("logger:settings/filter")
for _,tab in ipairs(g_tabs) do
if tab.box == g_filter then
g_tab_options.currtab = tab.param
break
end
end
g_log = box.multiquery("logger:status/log_separate") or {}
function write_event(idx, t)
local help_href = href.help_get('hilfe_syslog_' .. t[4] .. '.html')
local addInfo=""
local n_start, n_end=string.find(t[3],"#MAC#")
local evt_txt=t[3]
if (n_start~=nil) then
local mac_str=string.sub(t[3],n_end+1,string.len(t[3])-1)
local idx, elem=net_devices.find_dev_by_mac(net_devices.g_list, mac_str)
if (elem) then
local ip=elem.ip
if ip=="" then
ip="-"
end
addInfo=[[{?430:2835?}: ]]..net_devices.get_name(elem)..[[, {?430:993?}: ]]..tostring(ip)
end
evt_txt=string.gsub(t[3],"#MAC#","")
end
box.out([[<tr><td>]]..t[1]..[[</td><td class="date">]]..t[2]..[[</td><td><a ]])
if (addInfo~="") then
box.out([[title="]]..box.tohtml(addInfo)..[[" ]])
end
box.out([[target="_blank" href="]] .. help_href)
box.out([[" onclick="help.popup(']] .. help_href .. [['); return false;">]])
box.html(evt_txt)
box.out("</a></td></tr>\n")
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/syslog.css"/>
<script type="text/javascript">
function uiDoShowPrintView() {
var url = "<?lua href.write('/system/syslog.lua','stylemode=print','popupwnd=1') ?>";
var ppWindow = window.open(url, "Zweitfenster", "width=815,height=600,statusbar,resizable=yes,scrollbars=yes");
ppWindow.focus();
}
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="/system/syslog.lua">
<?lua
if g_tab_options.currtab=="wlan" then
local str=[[<p><input type="checkbox" name="filter" id="uiFilter" ]]
if (box.query("wlan:settings/event_control")=="7") then
str=str..[[checked]]
end
str=str..[[><label for="uiFilter">{?430:876?}</label></p>]]
box.out(str)
end
?>
<div class="scroll_area">
<table class="zebra">
<?lua
for i,t in ipairs(g_log) do
write_event(i, t)
end
?>
</table>
</div>
<?lua
if not g_print_mode then
box.out([[
<p>{?430:30?}</p>
]])
end
?>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua
if g_tab_options.currtab=="aus" then
box.out([[<button type="submit" name="delete">{?430:599?}</button>]])
end
if g_tab_options.currtab=="wlan" then
box.out([[<button type="submit" name="apply">{?txtApply?}</button>]])
end
?>
<button type="submit" name="reload">{?txtRefresh?}</button>
<button type="button" name="print" onclick="uiDoShowPrintView()">{?430:128?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
