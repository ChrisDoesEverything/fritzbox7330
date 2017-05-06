<?lua
if not gl or not gl.logged_in then
box.end_page()
end
box.out([[<!-- begin share -->]])
g_good_username = not(string.find(gl.username, '@', 1, true) == 1)
g_shares = nil
function get_share_name(share)
local revers_share_path = string.reverse(share.path)
local name_end_idx = string.find(revers_share_path, "/", 1, true)
if name_end_idx == 1 then
name_end_idx = string.find(revers_share_path, "/", 2, true)
revers_share_path = string.sub(revers_share_path, 2, name_end_idx-1)
else
revers_share_path = string.sub(revers_share_path, 1, name_end_idx-1)
end
return string.reverse(revers_share_path)
end
function get_share_path(share)
return string.sub(share.path, #gl.nas_user_dir + 1)
end
function get_share_icon(share)
if share.is_directory == "1" then
return "ordner.png"
else
return "icon_andere_datei_20x20px.png"
end
end
function get_share_user(users,share)
for key, user in pairs(users) do
if user.id == share.userid then
return user.name
end
end
return gl.username or ""
end
function get_buttons(share)
local onclickEdit = [[onEditShare(']]..share._node..[[');]]
local onclickDel = [[onDeleteShare(']]..share._node..[[');]]
return [[<td class="buttonrow">]]..general.get_icon_button("/nas/css/"..box.tohtml(gl.var.style).."/images/bearbeiten.gif", "edit_"..share.id, "edit", share.id, [[{?txtIconBtnEdit?}]], onclickEdit, false)..[[</td><td class="buttonrow">]]..general.get_icon_button("/nas/css/"..box.tohtml(gl.var.style).."/images/loeschen.gif", "delete_"..share.id, "delete", share.id, [[{?txtIconBtnDelete?}]], onclickDel, false)..[[</td>]]
end
function get_valid_row(share)
local str = ""
if share.is_valid == "0" then
str = box.tohtml([[{?84:981?}]])
elseif share.is_valid == "1" and (share.expire == "0" or share.expire == "999") and share.access_count_limit == "0" then
str = box.tohtml([[{?84:412?}]])
elseif share.is_valid == "1" then
if share.expire ~= "0" and share.expire ~= "999" and share.expire_date ~= "" then
str = box.tohtml(general.sprintf([[{?84:886?}]], tostring(share.expire_date)))
end
local akt_access_cnt = tonumber(share.access_count_limit) - tonumber(share.access_count)
if share.access_count_limit ~= "0" and akt_access_cnt > 0 then
if #str > 0 then str = str..[[<br>]] end
str = str..box.tohtml(general.sprintf([[{?84:787?}]], tostring(akt_access_cnt)))
end
end
return str
end
function sort_share( share_to_sort, sorted_shares )
if not sorted_shares then
sorted_shares = {}
sorted_shares[1] = share_to_sort
else
for idx, share in ipairs( sorted_shares ) do
if string.lower( share_to_sort.displayName ) < string.lower( share.displayName ) then
for i = #sorted_shares, idx, -1 do
sorted_shares[i + 1] = sorted_shares[i]
end
sorted_shares[idx] = share_to_sort
break;
elseif idx == #sorted_shares then
sorted_shares[idx + 1] = share_to_sort
break;
end
end
end
return sorted_shares
end
function write_share_tab_content()
box.out([[<table id="share_table_content" class="tcontent">]])
if not gl.bib.general then gl.bib.general = require("general") end
g_shares = gl.bib.general.listquery("filelinks:settings/link/list(id,path,is_directory,userid,is_valid,expire,expire_date,access_count_limit,access_count)")
sorted_shares = nil
for key, share in pairs(g_shares) do
if share.id and #share.id > 0 then
share.displayName = get_share_name(share)
sorted_shares = sort_share( share, sorted_shares )
else
share = nil
end
end
local users = {}
if g_good_username then
users = gl.bib.general.listquery("boxusers:settings/user/list(id,UID,name)")
end
if sorted_shares then
for idx, share in ipairs(sorted_shares) do
box.out([[<tr title="]]..box.tohtml(get_share_path(share))..[[">
<td class="iconrow"><img class="symbol_detail_img" alt="" src="/nas/css/]]..box.tohtml(gl.var.style)..[[/images/]]..get_share_icon(share)..[["></td>
<td class="tname">]]..box.tohtml(share.displayName)..[[</td>]])
if g_good_username then
box.out([[<td class="tuser">]]..box.tohtml(get_share_user(users,share))..[[</td>]])
end
box.out([[ <td class="tvalid">]]..get_valid_row(share)..[[</td>
<td class="tlink">]]..box.tohtml(gl.bib.share.get_link(share._node))..[[</td>
]]..get_buttons(share)..[[
</tr>]])
end
else
local colspan = 4
if g_good_username then
colspan = 5
end
box.out([[<tr><td colspan="]]..colspan..[[">]]..box.tohtml([[{?84:935?}]])..[[</td></tr>]])
end
box.out([[</table>]])
end
?>
<div id="share_table_box"><div class="fixed_inner">
<table id="share_table_head" class="thead">
<tr>
<th class="iconrow"></th>
<th class="tname">{?84:770?}</th>
<?lua
if g_good_username then
box.out([[<th class="tuser">]]..box.tohtml([[{?84:12?}]])..[[</th>]])
end
?>
<th class="tvalid">{?84:67?}</th>
<th class="tlink">{?84:650?}</th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>
</table>
</div></div>
<div id="content_show_share">
<div id="jsMsgWait" class="js_msg_and_wait">
{?84:374?}
</div>
<script type="text/javascript">
jxl.display( "jsMsgWait", false );
</script>
<?lua write_share_tab_content() ?>
<form id="delete_filelink" method="post" action="/nas/index.lua">
<?lua
box.out(gl.bib.gpl.get_parameter_line_for_form({}))
box.out(gl.bib.gpl.get_single_parameter_line_for_form("script", "/index.lua"))
box.out(gl.bib.gpl.get_single_parameter_line_for_form("cmd", "del_share"))
box.out(gl.bib.gpl.get_single_parameter_line_for_form("cmd_files", ""))
?>
</form>
</div>
<div class="page_middle_foot"><div></div></div>
<!-- **************** Nötige Javascript Funktionen *************************************************************************** -->
<script type="text/javascript">
<?lua
local tmpShares = {}
for key, share in pairs(g_shares) do
tmpShares[share._node] = share
tmpShares[share._node].link = gl.bib.share.get_link(share._node)
end
box.out([[gShares = ]]..gl.bib.js.table(tmpShares)..[[;]])
box.out([[gHttpsEnabled = "]]..box.tojs(box.query("remoteman:settings/enabled","0"))..[[";]])
?>
function onDeleteShare( node )
{
if ( confirm( "{?84:543?}" ) )
{
formular = jxl.get( "delete_filelink" );
formular.elements["cmd_files"].value = node + gl.delim;
formular.submit();
}
}
function onEditShare( node )
{
if( "first" == gDisableMainPageBox )
{
gDisableMainPageBox = createModalBox( createBoxContent( "all" ) );
}
disablePage( gDisableMainPageBox );
showShareLinkDetails( gHttpsEnabled, gShares[node].link, node, gShares[node].displayName, gShares[node].expire, ( parseInt( gShares[node].access_count_limit, 10 ) - parseInt( gShares[node].access_count, 10 ) ) + "" );
}
</script>
<!-- end share -->
