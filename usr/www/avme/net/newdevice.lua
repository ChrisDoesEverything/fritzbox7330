<?lua
g_page_type = "all"
g_page_title = [[{?122:82?}]]
g_page_help = "hilfe_net_newdevice.html"
g_menu_active_page = "/net/network_user_devices.lua"
dofile("../templates/global_lua.lua")
require("general")
require("cmtable")
require("val")
require("http")
require("ip")
g_back_to_page = http.get_back_to_page( "/net/network_user_devices.lua" )
if next(box.post) and box.post.cancel then
http.redirect(href.get(g_back_to_page))
end
g_name = ""
g_mac = {}
g_ip = {}
g_macstr = ""
g_ipstr = ""
g_device = nil
g_errmsg = nil
g_txt_used = [[{?122:584?}]]
g_val = {
prog = [[
char_range_regex(uiName/name, pcname, name)
mac(uiMac/mac, mac)
box_client_ip(uiIp/ip, ip)
]]
}
val.msg.name = {
[val.ret.outofrange] = [[{?122:827?}]]
}
val.msg.mac = {
[val.ret.empty] = [[{?122:991?}]],
[val.ret.format] = [[{?122:625?}]],
[val.ret.group] = [[{?122:391?}]]
}
val.msg.ip = {
[val.ret.empty] = [[{?122:179?}]],
[val.ret.format] = [[{?122:524?}]],
[val.ret.outofrange] = [[{?122:116?}]],
[val.ret.outofnet] = [[{?122:223?}]],
[val.ret.thenet] = [[{?122:416?}]],
[val.ret.broadcast] = [[{?122:409?}]],
[val.ret.thebox] = [[{?122:760?}]]
}
function landev_callback(idx, row)
if string.upper(row.mac) == g_macstr then
g_device = "landevice"..tostring(idx-1)
else
if row.ip == g_ipstr then
g_errmsg = general.sprintf(g_txt_used, row.ip, row.name, row.mac)
end
end
end
function read_box_values()
g_mac = { "", "", "", "", "", "" }
g_ip = ip.quad2table(box.query("box:status/dhcpserver/free_ip"))
end
function refill_user_input()
g_name = box.post.name
g_mac = { box.post.mac0, box.post.mac1, box.post.mac2, box.post.mac3, box.post.mac4, box.post.mac5 }
g_ip = { box.post.ip0, box.post.ip1, box.post.ip2, box.post.ip3 }
end
if next(box.post) and box.post.apply then
if val.validate(g_val) == val.ret.ok then
for i=0,5 do
g_macstr = g_macstr .. string.upper(box.post["mac"..tostring(i)])
if i < 5 then
g_macstr = g_macstr .. ":"
end
end
g_ipstr = ip.read_from_post("ip")
g_devs = general.listquery("landevice:settings/landevice/list(mac,ip,name)", landev_callback)
if not g_errmsg then
local saveset = {}
if not g_device or string.len(g_device)<10 then
g_device = box.query("landevice:settings/landevice/newid")
cmtable.add_var(saveset, "landevice:settings/"..g_device.."/mac", g_macstr)
end
cmtable.add_var(saveset, "landevice:settings/"..g_device.."/ip", g_ipstr)
cmtable.add_var(saveset, "landevice:settings/"..g_device.."/static_dhcp", "1")
if box.post.name and string.len(box.post.name)>0 then
cmtable.add_var(saveset, "landevice:settings/"..g_device.."/name", box.post.name)
end
local err
err, g_errmsg = box.set_config(saveset)
if err==0 then
http.redirect(href.get(g_back_to_page))
else
refill_user_input()
end
else
refill_user_input()
end
else
refill_user_input()
end
else
read_box_values()
end
g_devs = general.listquery("landevice:settings/landevice/list(mac,ip,name)")
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
<?lua
val.write_js_globals_for_ip_check()
val.write_js_error_strings()
?>
var g_txtMacExists = "{?122:848?}";
var g_devs = {
<?lua
for idx,dev in ipairs(g_devs) do
if idx > 1 then
box.out(",\n")
end
box.out([["m]]..box.tojs(string.upper(string.gsub(dev.mac,":","")))..[[": { name:"]]..box.tojs(dev.name)..[[", ip:"]]..box.tojs(dev.ip)..[[" }]])
end
?>
};
function init()
{
fc.init("ipbox", 3, 'ip');
fc.init("macbox", 2, 'mac');
jxl.focus("uiName");
}
function uiDoOnMainFormSubmit()
{
var ret;
<?lua
val.write_js_checks(g_val)
?>
var macstr = "m";
for (var i=0; i<6; i++)
macstr += jxl.getValue("uiMac"+i).toUpperCase();
if (g_devs[macstr]) {
if (!confirm(jxl.sprintf(g_txtMacExists, g_devs[macstr].name, g_devs[macstr].ip))) {
return false;
}
}
return true;
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div class="formular">
<p>{?122:566?}</p>
<label for="uiName">{?122:668?}</label>
<input type="text" id="uiName" name="name" value="<?lua box.html(g_name) ?>" <?lua val.write_attrs(g_val, "uiName") ?>/>
<?lua val.write_html_msg(g_val, "uiName") ?>
<br>
<div id="macbox">
<label for="uiMac0">{?122:492?}</label>
<input type="text" size="2" maxlength="2" id="uiMac0" name="mac0" value="<?lua box.html(g_mac[1]) ?>" <?lua val.write_attrs(g_val, 'uiMac0') ?> /> :
<input type="text" size="2" maxlength="2" id="uiMac1" name="mac1" value="<?lua box.html(g_mac[2]) ?>" <?lua val.write_attrs(g_val, 'uiMac1') ?> /> :
<input type="text" size="2" maxlength="2" id="uiMac2" name="mac2" value="<?lua box.html(g_mac[3]) ?>" <?lua val.write_attrs(g_val, 'uiMac2') ?> /> :
<input type="text" size="2" maxlength="2" id="uiMac3" name="mac3" value="<?lua box.html(g_mac[4]) ?>" <?lua val.write_attrs(g_val, 'uiMac3') ?> /> :
<input type="text" size="2" maxlength="2" id="uiMac4" name="mac4" value="<?lua box.html(g_mac[5]) ?>" <?lua val.write_attrs(g_val, 'uiMac4') ?> /> :
<input type="text" size="2" maxlength="2" id="uiMac5" name="mac5" value="<?lua box.html(g_mac[6]) ?>" <?lua val.write_attrs(g_val, 'uiMac5') ?> />
</div>
<?lua val.write_html_msg(g_val, "uiMac0", "uiMac1", "uiMac2", "uiMac3", "uiMac4", "uiMac5") ?>
<p>{?122:538?}</p>
<div id="ipbox">
<label for="uiIp0">{?122:617?}</label>
<input type="text" size="3" maxlength="3" id="uiIp0" name="ip0" value="<?lua box.html(g_ip[1]) ?>" <?lua val.write_attrs(g_val, 'uiIp0', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIp1" name="ip1" value="<?lua box.html(g_ip[2]) ?>" <?lua val.write_attrs(g_val, 'uiIp1', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIp2" name="ip2" value="<?lua box.html(g_ip[3]) ?>" <?lua val.write_attrs(g_val, 'uiIp2', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIp3" name="ip3" value="<?lua box.html(g_ip[4]) ?>" <?lua val.write_attrs(g_val, 'uiIp3', 'ip') ?> />
</div>
<?lua val.write_html_msg(g_val, "uiIp0", "uiIp1", "uiIp2", "uiIp3") ?>
<?lua
if g_errmsg and string.len(g_errmsg)>0 then
box.out([[<p class="form_input_note ErrorMsg">]])
box.html(g_errmsg)
box.out([[</p>]])
end
?>
</div>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>"/>
<button type="submit" name="apply" id="uiApply">{?txtApplyOk?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
