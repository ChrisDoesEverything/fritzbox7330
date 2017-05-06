<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_clients.html"
dofile("../templates/global_lua.lua")
require("http")
require("general")
require("cmtable")
local ndev = {}
g_dev = {}
function get_var()
g_dev = ndev.g_list
g_dev.macfilter = box.query("wlan:settings/is_macfilter_active")
g_dev.wlan_count = tonumber(box.query("wlan:settings/wlanlist/count")) or 0
end
if next(box.post) then
if box.post.edit and box.post.edit~="" then
http.redirect(href.get('/net/edit_device.lua','dev='..box.post.edit, 'back_to_page='..box.glob.script))
elseif box.post.btn_new_device then
http.redirect(href.get('/net/newdevice.lua', 'back_to_page='..box.glob.script))
elseif box.post.delete and box.post.delete~="" then
ndev = require("net_devices")
get_var()
local idx,elem = ndev.find_dev_by_uid(g_dev, box.post.delete)
if not(elem) then
idx,elem = ndev.find_dev_by_node(g_dev, box.post.delete)
if not(elem) then
idx,elem = ndev.find_dev_by_name(g_dev, box.post.delete)
end
end
if idx and elem and elem.type=="user" and elem.kisi and elem.kisi=="active" then
local ctlmgr_del={}
cmtable.add_var(ctlmgr_del, "user:command/user["..elem.UID.."]" , "delete")
local err,msg = box.set_config(ctlmgr_del)
if err ~= 0 then
local criterr = general.create_error_div(err,msg, [[{?219:984?}]])
box.out(criterr)
end
elseif idx and elem and elem.type~="user" and elem.deleteable ~= "0" and
not(g_dev.macfilter=="1" and elem.wlan=="1" and g_dev.wlan_count and g_dev.wlan_count < 2) and
not(g_dev.macfilter=="0" and elem.wlan=="1" and elem.active=="1") then
local ctlmgr_del={}
cmtable.add_var(ctlmgr_del, "landevice:command/landevice["..elem.UID.."]" , "delete")
if elem.wlan=="1" and elem.wlan_node then
cmtable.add_var(ctlmgr_del, "wlan:command/"..elem.wlan_node , "delete")
end
local err,msg = box.set_config(ctlmgr_del)
if err ~= 0 then
local criterr=[[<div class="LuaSaveVarError">]]..box.tohtml([[{?219:910?}.]])
if msg ~= nil and msg ~= "" then
criterr = criterr..[[<br>]]..box.tohtml([[{?219:801?}: ]])..box.tohtml(msg)
else
criterr = criterr..[[<br>]]..box.tohtml([[{?219:527?}: ]])..box.tohtml(err)
end
criterr = criterr..[[<br>]]..box.tohtml([[{?219:667?}]])..[[</div>]]
box.out(criterr)
end
end
ndev.InitNetList()
end
end
ndev = require("net_devices")
get_var()
function create_colgroup()
if (general.is_expert()) then
return [[<colgroup><col width="24px"><col width="105px"><col width="85px"><col width="85px"><col width="102px"><col width="88px"><col width="40px"><col width="40px"></colgroup>]]
end
return [[<colgroup><col width="24px"><col width="200px"><col width="120px"><col width="150px"><col width="40px"><col width="40px"></colgroup>]]
end
function create_internal_table_header(id)
if (general.is_expert()) then
return [[<tr><td colspan="8"><table id="]]..id..[[" class="zebra_reverse noborder">]]..create_colgroup()
end
return [[<tr><td colspan="6"><table id="]]..id..[[" class="zebra_reverse noborder">]]..create_colgroup()
end
function create_internal_table_end()
return [[</table></td></tr>]]
end
function create_header()
local str=[[<tr class="thead">
<th class="notsortable iconrow"></th>
<th class="sortable">{?219:480?}<span class="sort_no">&nbsp;</span></th>
]]
if (general.is_expert()) then
str=str..[[<th class="sortable">{?219:299?}<span class="sort_no">&nbsp;</span></th>]]
str=str..[[<th class="sortable">{?219:651?}<span class="sort_no">&nbsp;</span></th>]]
end
str=str..[[<th class="sortable">{?219:874?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?219:656?}<span class="sort_no">&nbsp;</span></th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>]]
return str
end
local function show_device(dev)
if config.WLAN_WDS2 and dev.wlan_station_type == "wds_slave" then
return false
end
if (dev.guest=="1" and dev.active=="0") then
return false
end
if (dev.type=="plc" and dev.is_internal) then
return false
end
return true
end
function create_net_device_table()
local str_active = ""
local str_guest = ""
local str_user = ""
local str_passive = ""
local str=""
local max_col=6
if (general.is_expert()) then
max_col=8
end
local cnt_devs_toshow = #(g_dev or {})
cnt_devs_toshow = #array.filter(g_dev, show_device)
if cnt_devs_toshow and cnt_devs_toshow > 0 then
for idx, elem in ipairs(g_dev) do
if show_device(elem) then
if (elem.guest=="1") then
str_guest=str_guest..ndev.create_row_lan(elem)
elseif (elem.active=="1") then
str_active=str_active..ndev.create_row_lan(elem)
elseif elem.type=='user' then
str_user=str_user..ndev.create_row_lan(elem)
else
str_passive=str_passive..ndev.create_row_lan(elem)
end
end
end
local show_separator= (str_active ~="" and (str_guest ~="" or str_passive~="" or str_user~="")) or
(str_guest ~="" and (str_active~="" or str_passive~="" or str_user~="")) or
(str_user ~="" and (str_active~="" or str_passive~="" or str_guest~="")) or
(str_passive~="" and (str_active~="" or str_guest ~="" or str_user~=""))
if (str_active~="") then
str=str..create_internal_table_header("uiLanActive")
if (show_separator) then
str=str..ndev.get_separator("lan_active",max_col)
end
str=str..str_active
str=str..create_internal_table_end()
end
if (str_guest~="") then
str=str..create_internal_table_header("uiLanGuest")
if (show_separator) then
str=str..ndev.get_separator("lan_guest",max_col)
end
str=str..str_guest
str=str..create_internal_table_end()
end
if (str_user~="") then
str=str..create_internal_table_header("uiUser")
if (show_separator) then
str=str..ndev.get_separator("user",max_col)
end
str=str..str_user
str=str..create_internal_table_end()
end
if (str_passive~="") then
str=str..create_internal_table_header("uiLanPassive")
if (show_separator) then
str=str..ndev.get_separator("lan_passive",max_col)
end
str=str..str_passive
str=str..create_internal_table_end()
end
else
str = [[<tr><td colspan="]]..tostring(max_col)..[[" class="txt_center">]]..box.tohtml([[{?219:729?}]])..[[</td></tr>]]
end
return str
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
td.buttonrow {
height: 24px;
}
</style>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<table id="uiViewDevTable" class="OnlyHead">
<?lua
box.out(create_colgroup())
box.out(create_header())
box.out(create_net_device_table())
?>
</table>
<div <?lua
if box.query("box:settings/expertmode/activated") ~= "1"
or box.query("interfaces:settings/lan0/dhcpserver")~="1"
or box.query("box:settings/opmode") == "opmode_eth_ipclient" then
box.out('style="display:none;"')
end
?>>
<hr>
{?219:305?}
<div class="btn_form">
<button type="submit" name="btn_new_device" id="btnNewDevice">{?219:64?}</button>
</div>
</div>
<div id="btn_form_foot">
<button type="submit" name="btn_refresh" id="btnRefresh">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/dialog.js"></script>
<script type="text/javascript">
var sort=sorter();
function checkWlanDelete(devType, wlan, deleteable, devName, active, wdsRepeater, kisi)
{
if (devType=='user')
{
if (kisi=='active')
return confirm(jxl.sprintf('{?219:121?}\n{?219:753?}', devName));
else
{
alert('{?219:316?}');
return false;
}
}
if (wdsRepeater=="1" && active=="1")
{
alert('{?219:376?}');
return false;
}
if (wlan=="1" && <?lua box.js(tostring(g_dev.macfilter=="1")) ?> && <?lua box.js(tostring(g_dev.wlan_count and g_dev.wlan_count < 2)) ?>)
{
alert('{?219:726?}');
return false;
}
if (<?lua box.js(tostring(g_dev.macfilter=="0")) ?> && wlan=="1" && active=="1")
{
alert("{?219:332?}.");
return false;
}
if (deleteable=="1")
if(!confirm(jxl.sprintf('{?219:325?}\n{?219:157?}',devName)))
return false;
if (deleteable=="0")
{
alert('{?219:575?}');
return false;
}
return true;
}
function initTableSorter() {
sort.init("uiViewDevTable");
sort.addTbl("uiLanActive");
sort.addTbl("uiLanGuest");
sort.addTbl("uiUser");
sort.addTbl("uiLanPassive");
sort.setDirection(1,-1);
sort.sort_table(1);
}
ready.onReady(initTableSorter);
function showBlockedExplain() {
var alertParams = {}
alertParams.Text1 = "{?219:469?}";
alertParams.AddClass1 = "subtitle";
alertParams.Text2 = "\n\n";
alertParams.Text3 = "{?219:596?}";
alertParams.Text4 = "\n";
alertParams.Text5 = "{?219:712?}";
alertParams.Buttons = [{
txt: "{?219:149?}"
}];
dialog.messagebox(true, alertParams);
}
</script>
<?include "templates/html_end.html" ?>
