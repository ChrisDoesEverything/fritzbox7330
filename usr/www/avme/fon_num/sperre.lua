<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_fon_sperre.html"
dofile("../templates/global_lua.lua")
require("config")
require("cmtable")
require("val")
require("boxvars")
require("elem")
require("general")
?>
<?lua
local l_szUrl = [[/fon_num/sperre_edit.lua]]
if (next(box.post) and box.post.new_blocknumber) then
l_szUrl = l_szUrl..[[?new=1]]
http.redirect( l_szUrl)
end
if (next(box.post) and (box.post.edit)) then
l_szUrl = l_szUrl..[[?rule=]]..box.post.edit
http.redirect( l_szUrl)
end
?>
<?lua
g_szListQuery_OutGoing = [[telcfg:settings/Routing/Group/list(Number,Route)]]
g_szListQuery_InComing = [[telcfg:settings/CallerIDActions/list(CallerID,Action)]]
g_t_out_going_rules = {}
g_t_in_coming_rules = {}
?>
<?lua
function init_page_vars()
local l_variablen_strings = {}
boxvars.init( l_variablen_strings)
box.query( "telcfg:settings/RefreshDiversity")
g_t_out_going_rules = general.listquery( g_szListQuery_OutGoing)
g_t_in_coming_rules = general.listquery( g_szListQuery_InComing)
end
function show_out_going_number( sz_number)
if ( sz_number == "mobile") then
return [[{?txtMobilfunk?}]]
elseif ( sz_number == "ortsnetz") then
return [[{?6836:9?}]]
elseif ( sz_number == "national") then
return [[{?6836:48?}]]
elseif ( sz_number == "international") then
return [[{?6836:978?}]]
elseif ( sz_number == "sonderrufnrn") then
return [[{?6836:538?}]]
elseif ( sz_number == "auskunft") then
return [[{?6836:220?}]]
else
return sz_number
end
end
function show_in_coming_number( sz_number)
if ( sz_number == "") then
return [[{?6836:739?}]]
end
return sz_number
end
function write_table_content()
local l_szRet = ""
local l_b_has_no_entries = true
for i=1, #g_t_out_going_rules do
if ( tostring( g_t_out_going_rules[i].Route) == "s" ) then
local sz_value = [[{?6836:209?}]]
local l_Str = [[<tr><td>]]..box.tohtml(sz_value)..[[</td>]]
sz_value = show_out_going_number( tostring( g_t_out_going_rules[i].Number))
l_Str = l_Str..[[<td>]]..box.tohtml(sz_value)..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..g_t_out_going_rules[i]._node, "edit", g_t_out_going_rules[i]._node, [[{?txtIconBtnEdit?}]])..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..g_t_out_going_rules[i]._node, "delete", g_t_out_going_rules[i]._node, [[{?txtIconBtnDelete?}]])..[[</td>]]
l_Str = l_Str..[[</tr>]]
l_szRet = l_szRet..l_Str
l_b_has_no_entries = false
end
end
for i=1, #g_t_in_coming_rules do
if ( tostring( g_t_in_coming_rules[i].Action) == "1" ) then
local sz_value = [[{?6836:477?}]]
local l_Str = [[<tr><td>]]..box.tohtml(sz_value)..[[</td>]]
sz_value = show_in_coming_number( tostring( g_t_in_coming_rules[i].CallerID))
l_Str = l_Str..[[<td>]]..box.tohtml(sz_value)..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..g_t_in_coming_rules[i]._node, "edit", g_t_in_coming_rules[i]._node, [[{?txtIconBtnEdit?}]])..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..g_t_in_coming_rules[i]._node, "delete", g_t_in_coming_rules[i]._node, [[{?txtIconBtnDelete?}]])..[[</td>]]
l_Str = l_Str..[[</tr>]]
l_szRet = l_szRet..l_Str
l_b_has_no_entries = false
end
end
if ( l_b_has_no_entries) then
l_szRet = [[<tr id ="ui_NoRules"><td colspan="4" class="hint">{?6836:694?}</td></tr>]]
end
box.out( l_szRet)
end
if ( next(box.post) and box.post.delete ) then
local saveset = {}
local szDelValue = box.post.delete
nBeginn, nEnde = string.find( box.post.delete, "Group")
if ( nBeginn == 1 and nEnde == 5) then
szDelValue = "Routing/"..box.post.delete
end
cmtable.add_var( saveset, ("telcfg:command/"..szDelValue), "delete")
errcode, errmsg = box.set_config( saveset)
if errcode ~= 0 then
g_val.errmsg = errmsg
end
end
init_page_vars()
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.extra {
width:180px;
}
</style>
<?include "templates/page_head.html" ?>
<form method="POST" action="/fon_num/sperre.lua" name="main_form">
<div>{?6836:974?}
<div>&nbsp;- {?6836:459?}</div>
<div>&nbsp;- {?6836:453?}</div>
</div>
<table id="uiList" class="zebra">
<tr class="thead">
<th class="sortable extra">{?6836:519?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?6836:964?}<span class="sort_no">&nbsp;</span></th>
<th class="buttonrow">&nbsp;</th>
<th class="buttonrow">&nbsp;</th>
</tr>
<?lua
write_table_content()
?>
</table>
<div style="text-align:right;">
<button type="submit" name="new_blocknumber">{?6836:336?}</button>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
</form>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
function initTableSorter() {
sort.init("uiList");
sort.setDirection(0,-1);
sort.sort_table(0);
}
ready.onReady(initTableSorter);
</script>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
