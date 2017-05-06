<?lua
g_page_type = "all"
g_page_title = [[{?302:170?}]]
g_page_help = "hilfe_ipv4route_edit_route.html"
g_menu_active_page = "/net/network_settings.lua"
dofile("../templates/global_lua.lua")
require("general")
require("http")
require("cmtable")
require("newval")
require("ip")
function read_route_values()
g_ip = ip.quad2table(box.query("route:settings/"..akt_route.."/ipaddr"))
g_mask = ip.quad2table(box.query("route:settings/"..akt_route.."/netmask"))
g_gw = ip.quad2table(box.query("route:settings/"..akt_route.."/gateway"))
g_active = (box.query("route:settings/"..akt_route.."/activated")=="1")
end
function refill_user_input()
g_ip = { box.post.ip0, box.post.ip1, box.post.ip2, box.post.ip3 }
g_mask = { box.post.mask0, box.post.mask1, box.post.mask2, box.post.mask3 }
g_gw = { box.post.gw0, box.post.gw1, box.post.gw2, box.post.gw3 }
g_active = (box.post.route_activ ~= nil)
if g_ip[1] == nil then
g_ip = { "", "", "", "" }
end
if g_mask[1] == nil then
g_mask = { "", "", "", "" }
end
if g_gw[1] == nil then
g_gw = { "", "", "", "" }
end
end
g_back_to_page = http.get_back_to_page( "/net/static_route_table.lua" )
new_route = false
if box.get.route then
akt_route = box.get.route
elseif box.post.route then
akt_route = box.post.route
end
if akt_route==nil or akt_route=="" then
akt_route = box.query("route:settings/route/newid")
new_route = true
end
newval.msg.default_route = {
different = [[{?302:295?}]],
equalerr = [[{?302:145?}]]
}
newval.msg.not_backup = {
wrong = [[{?302:975?}]]
}
newval.msg.ip = {
[newval.ret.empty] = [[{?302:656?}]],
[newval.ret.notfound] = [[{?302:748?}]],
[newval.ret.format] = [[{?302:604?}]],
[newval.ret.outofrange] = [[{?302:469?}]],
[newval.ret.outofnet] = [[{?302:909?}]],
[newval.ret.thenet] = [[{?302:499?}]],
[newval.ret.broadcast] = [[{?302:172?}]],
[newval.ret.thebox] = [[{?302:916?}]],
[newval.ret.unsized] = [[{?302:376?}]]
}
newval.msg.mask = {
[newval.ret.empty] = [[{?302:980?}]],
[newval.ret.format] = [[{?302:606?}]],
[newval.ret.outofrange] = [[{?302:761?}]],
[newval.ret.nomask] = [[{?302:927?}]]
}
local function validation()
newval.ipv4("ip", "ip")
newval.netmask_null("mask", "mask")
newval.ipv4("gw", "ip")
newval.default_route("ip", "mask", akt_route, "default_route")
newval.ip_not_backup_network("ip", "not_backup")
end
if next(box.post) and box.post.btn_chancel then
http.redirect( href.get( g_back_to_page ) )
end
if next(box.post) then
if box.post.validate == "apply" then
require"js"
local valresult, answer = newval.validate(validation)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
if newval.validate(validation)==newval.ret.ok then
local ctlmgr_save={}
cmtable.save_checkbox(ctlmgr_save, "route:settings/"..akt_route.."/activated" , "route_activ")
cmtable.add_var(ctlmgr_save, "route:settings/"..akt_route.."/ipaddr" , ip.read_from_post("ip"))
cmtable.add_var(ctlmgr_save, "route:settings/"..akt_route.."/netmask" , ip.read_from_post("mask"))
cmtable.add_var(ctlmgr_save, "route:settings/"..akt_route.."/gateway" , ip.read_from_post("gw"))
local err,msg = box.set_config(ctlmgr_save)
if err == 0 then
http.redirect(href.get( g_back_to_page ))
else
local criterr = general.create_error_div(err,msg)
box.out(criterr)
refill_user_input()
end
else
refill_user_input()
end
end
else
read_route_values()
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
function onNewRouteSubmit()
{
}
function init()
{
fc.init("ipbox", 3, 'ip');
fc.init("sumaskbox", 3, 'ip');
fc.init("gwbox", 3, 'ip');
jxl.focus("uiIp0");
}
ready.onReady(ajaxValidation({
okCallback: onNewRouteSubmit
}));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form name="main_form" class="narrow" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div class="formular">
<div id="ipbox">
<label for="uiIp0">{?302:552?}</label>
<input type="text" size="3" maxlength="3" id="uiIp0" name="ip0" value="<?lua box.html(g_ip[1]) ?>" /> .
<input type="text" size="3" maxlength="3" id="uiIp1" name="ip1" value="<?lua box.html(g_ip[2]) ?>" /> .
<input type="text" size="3" maxlength="3" id="uiIp2" name="ip2" value="<?lua box.html(g_ip[3]) ?>" /> .
<input type="text" size="3" maxlength="3" id="uiIp3" name="ip3" value="<?lua box.html(g_ip[4]) ?>" />
</div>
<div id="sumaskbox">
<label for="uiMask0">{?302:702?}</label>
<input type="text" size="3" maxlength="3" id="uiMask0" name="mask0" value="<?lua box.html(g_mask[1]) ?>" /> .
<input type="text" size="3" maxlength="3" id="uiMask1" name="mask1" value="<?lua box.html(g_mask[2]) ?>" /> .
<input type="text" size="3" maxlength="3" id="uiMask2" name="mask2" value="<?lua box.html(g_mask[3]) ?>" /> .
<input type="text" size="3" maxlength="3" id="uiMask3" name="mask3" value="<?lua box.html(g_mask[4]) ?>" />
</div>
<div id="gwbox">
<label for="uiGw0">{?302:887?}</label>
<input type="text" size="3" maxlength="3" id="uiGw0" name="gw0" value="<?lua box.html(g_gw[1]) ?>" /> .
<input type="text" size="3" maxlength="3" id="uiGw1" name="gw1" value="<?lua box.html(g_gw[2]) ?>" /> .
<input type="text" size="3" maxlength="3" id="uiGw2" name="gw2" value="<?lua box.html(g_gw[3]) ?>" /> .
<input type="text" size="3" maxlength="3" id="uiGw3" name="gw3" value="<?lua box.html(g_gw[4]) ?>" />
</div>
<div>
<label for="uiRouteActiv">{?302:677?}</label>
<input type="checkbox" id="uiRouteActiv" name="route_activ" <?lua if new_route or g_active then box.out('checked') end ?>>
</div>
</div>
<input type="hidden" id="backToPage" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" id="aktRoute" name="route" value="<?lua box.html(akt_route) ?>">
<div id="btn_form_foot">
<button type="submit" name='apply'>{?txtOk?}</button>
<button type="submit" name="btn_chancel" id="btnChancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
