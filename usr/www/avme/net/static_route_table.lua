<?lua
g_page_type = "all"
g_page_title = [[{?653:403?}]]
g_page_help = "hilfe_iproute.html"
g_menu_active_page = "/net/network_settings.lua"
dofile("../templates/global_lua.lua")
require("http")
ndev = require("net_devices")
require("general")
require("cmtable")
function get_var()
g_route = general.listquery("route:settings/route/list(activated,ipaddr,netmask,gateway)")
end
get_var()
g_back_to_page = http.get_back_to_page( "/net/network_settings.lua" )
if next(box.post) then
if (box.post.edit and box.post.edit~="") or (box.post.btn_new_route) then
if box.post.edit == nil then
box.post.edit = ""
end
http.redirect(href.get('/net/new_static_route.lua','route='..box.post.edit, 'back_to_page='..box.glob.script))
elseif box.post.delete and box.post.delete~="" then
local ctlmgr_del={}
cmtable.add_var(ctlmgr_del, "route:command/"..box.post.delete , "delete")
local err,msg = box.set_config(ctlmgr_del)
if err ~= 0 then
local criterr = general.create_error_div(err,msg, [[{?653:645?}]])
box.out(criterr)
end
get_var()
elseif box.post.btn_cancel then
http.redirect(href.get(g_back_to_page))
elseif box.post.btn_save then
local ctlmgr_save={}
for i,e in ipairs(g_route) do
cmtable.save_checkbox(ctlmgr_save, "route:settings/"..e._node.."/activated" , e._node)
end
local err,msg = box.set_config(ctlmgr_save)
if err == 0 then
http.redirect(href.get(g_back_to_page))
else
local criterr=[[<div class="LuaSaveVarError">]]..box.tohtml([[{?653:988?}.]])
if msg ~= nil and msg ~= "" then
criterr = criterr..[[<br>]]..box.tohtml([[{?653:642?}: ]])..box.tohtml(msg)
else
criterr = criterr..[[<br>]]..box.tohtml([[{?653:903?}: ]])..box.tohtml(err)
end
criterr = criterr..[[<br>]]..box.tohtml([[{?653:17?}]])..[[</div>]]
box.out(criterr)
end
get_var()
end
end
function get_buttons(elem)
return [[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..elem._node, "edit", elem._node, [[{?txtIconBtnEdit?}]])..[[</td>
<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..elem._node, "delete", elem._node, [[{?txtIconBtnDelete?}]])..[[</td>]]
end
function create_route_table()
local str = ""
if g_route and g_route[1] then
for idx, elem in ipairs(g_route) do
local activ = ""
if elem.activated=="1" then
activ = "checked"
end
str = str..[[<tr><td><input type="checkbox" id="]]..elem._node..[[" name="]]..elem._node..[[" ]]..activ..[[></td>]]
str = str..[[<td>]]..box.tohtml(elem.ipaddr)..[[</td>]]
str = str..[[<td>]]..box.tohtml(elem.netmask)..[[</td>]]
str = str..[[<td>]]..box.tohtml(elem.gateway)..[[</td>]]
str = str..get_buttons(elem)..[[</tr>]]
end
else
str = [[<tr><td colspan="6" class="txt_center">]]..box.tohtml([[{?653:714?}.]])..[[</td></tr>]]
end
return str
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort = sorter();
function initTableSorter() {
sort.init("uiViewRouteTable");
sort.sort_table_again(1);
}
ready.onReady(initTableSorter);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
{?653:845?}
</p>
<p>
<span class="WarnMsgBold">
{?653:477?}
</span>
<br>
{?653:93?}
</p>
<table id="uiViewRouteTable" class="zebra">
<tr class="thead">
<th>{?653:721?}</th>
<th class="sortable">{?653:620?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?653:777?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?653:374?}<span class="sort_no">&nbsp;</span></th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>
<?lua box.out(create_route_table()) ?>
</table>
<div class="btn_form">
<button type="submit" name="btn_new_route" id="btnNewRoute">{?653:739?}</button>
</div>
<div id="btn_form_foot">
<button type="submit" name='btn_save' id='btnSave'>{?txtOk?}</button>
<button type="submit" name="btn_cancel" id="btnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
