<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_internet_freigabe_ipv6.html"
dofile("../templates/global_lua.lua")
require"menu"
if not menu.check_page("internet", "/internet/ipv6_fw.lua") then
require"http"
http.redirect("/home/home.lua")
end
require("cmtable")
require("elem")
require("general")
local l_szUrl = [[/internet/ipv6_fw_edit.lua?device=]]
if (next(box.post) and box.post.new_device) then
l_szUrl = l_szUrl..box.query( "ipv6firewall:settings/rule/newid")
l_szUrl = l_szUrl..[[&new=1]]
http.redirect( l_szUrl)
end
if (next(box.post) and (box.post.edit)) then
l_szUrl = l_szUrl..box.post.edit
http.redirect( l_szUrl)
end
g_szListQuery = [[ipv6firewall:settings/rule/list(enabled,neighbour_name,ifaceid)]]
g_t_ipv6_fwList = {}
g_errmsg=""
function init_page_vars()
g_t_ipv6_fwList = general.listquery( g_szListQuery)
end
function write_table_content( t_content)
local l_szRet = ""
if ( #t_content > 0 ) then
for i=1, #t_content do
local l_Str = [[<tr><td>]]..elem._checkbox("active_"..tostring(i),"ui_Active_"..tostring(i),"1",(tostring(g_t_ipv6_fwList[i].enabled)=="1"))..[[</td>]]
l_Str = l_Str..[[<td>]]..elem._span(tostring(g_t_ipv6_fwList[i].neighbour_name), true, true)..[[</td>]]
l_Str = l_Str..[[<td>]]..elem._span(tostring(g_t_ipv6_fwList[i].ifaceid), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..g_t_ipv6_fwList[i]._node, "edit", g_t_ipv6_fwList[i]._node, [[{?txtIconBtnEdit?}]])..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..g_t_ipv6_fwList[i]._node, "delete", g_t_ipv6_fwList[i]._node, [[{?txtIconBtnDelete?}]])..[[</td>]]
l_Str = l_Str..[[</tr>]]
l_szRet = l_szRet..l_Str
end
else
l_szRet = [[<tr id ="ui_NoDevices"><td colspan="5" style="text-align:center;">{?9199:856?}</td></tr>]]
end
box.out( l_szRet)
end
if ( next(box.post)) then
local saveset = {}
if ( box.post.apply) then
local l_list_count = tonumber( box.querycount( g_szListQuery))
for i=1, l_list_count do
local l_value = "0"
if ((box.post["active_"..tostring(i)]) ~= nil ) then
l_value = "1"
end
cmtable.add_var( saveset, ("ipv6firewall:settings/rule"..tostring(i-1).."/enabled"), l_value)
end
end
if ( box.post.delete) then
cmtable.add_var( saveset, ("ipv6firewall:command/"..box.post.delete), "delete")
end
errcode, errmsg = box.set_config( saveset)
if errcode ~= 0 then
g_errmsg = general.create_error_div(errcode, errmsg)
end
end
init_page_vars()
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form method="POST" action="/internet/ipv6_fw.lua" id="uiMainForm" name="main_form">
<p>
{?9199:334?}
</p>
<h4>{?9199:412?}</h4>
<table id="uiFwList" class="zebra">
<tr class="thead">
<th class="iconrow">{?9199:964?}</th>
<th class="sortable">{?9199:719?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?9199:555?}<span class="sort_no">&nbsp;</span></th>
<th class="buttonrow">&nbsp;</th>
<th class="buttonrow">&nbsp;</th>
</tr>
<?lua
write_table_content(g_t_ipv6_fwList)
?>
</table>
<p class="innerbutton">
<button type="submit" name="new_device">{?9199:414?}</button>
</p>
<?lua
if g_errmsg~="" then
box.out(g_errmsg)
end
?>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
g_ValPage = false;
var sort=sorter();
function initTableSorter() {
sort.init("uiFwList");
sort.sort_table(1);
}
ready.onReady(initTableSorter);
</script>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
