<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_fon_wahlregeln.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("fon_numbers")
require("general")
require("http")
g_back_to_page = http.get_back_to_page( "/fon_num/dialrul_list.lua" )
g_val = {
prog = [[
]]
}
TXT_CHANGE = config.oem == 'kdg' and config.DOCSIS
g_errcode = 0
g_errmsg = [[]]
g_data={}
g_RefreshDiversity= box.query("telcfg:settings/RefreshDiversity")
g_data.is_telecom = box.query("providerlist:settings/activeprovider") == 'tonline'
function read_data()
g_data.prefix_table = fon_numbers.get_prefix_list()
g_data.siplist=general.listquery("sip:settings/sip/list(ID,displayname)")
g_data.least_cost_version=box.query("telcfg:settings/Routing/Version")
g_data.use_external_lcr=true
if g_data.least_cost_version=="0" or g_data.least_cost_version=="3" then
g_data.use_external_lcr=false
end
if (g_data.use_external_lcr) then
local t=box.query("telcfg:settings/ParseExternLCR")
end
end
if (next(box.post) and (box.post.apply)) then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
local saveset={}
local err, msg = box.set_config( saveset)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
read_data()
else
end
elseif (next(box.post) and box.post.reset) then
read_data()
if (g_data.use_external_lcr) then
local saveset={}
cmtable.add_var( saveset, "telcfg:command/Routing/RestoreFactorySettings","")
local err, msg = box.set_config( saveset)
if err == 0 then
http.redirect(g_back_to_page)
else
g_errmsg=general.create_error_div(err,msg)
end
end
elseif (next(box.post) and box.post.delete) then
local saveset={}
cmtable.add_var( saveset, "telcfg:command/Routing/"..tostring(box.post.delete),"delete")
local err, msg = box.set_config( saveset)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
read_data()
elseif (next(box.post) and box.post.edit) then
local param = {}
param[1]="uid="..box.post.edit
param[2]='back_to_page='..box.glob.script
http.redirect(href.get("/fon_num/dialrul_edit.lua",unpack(param)))
elseif (next(box.post) and box.post.new) then
local param = {}
param[1]="newid=new"
param[2]='back_to_page='..box.glob.script
http.redirect(href.get("/fon_num/dialrul_edit.lua",unpack(param)))
else
read_data()
end
function get_display_out(num)
return fon_numbers.get_num_txt(g_data, num)
end
function get_number(number)
if number== "mobile" then
return [[{?7746:255?}]]
elseif number== "ortsnetz" then
return [[{?7746:171?}]]
elseif number== "national" then
return [[{?7746:551?}]]
elseif number== "international"then
return [[{?7746:21?}]]
elseif number== "sonderrufnrn" then
return [[{?7746:50?}]]
elseif number== "auskunft" then
return [[{?7746:770?}]]
end
return number;
end
function get_fixed(provider)
local id=(tonumber(provider) or 0)+1
local prefix=g_data.prefix_table[id] or ""
if prefix=="" then
if g_data.is_telecom then
return [[{?7746:636?}]]
else
return [[{?7746:971?}]]
end
end
if g_data.is_telecom then
return [[{?7746:540?} ]]..prefix
end
return [[{?7746:475?} ]]..prefix
end
function get_sip_route(route)
for i,e in ipairs(g_data.siplist) do
if (e.ID==route) then
if fon_numbers.use_PSTN()=="1" then
return box.tohtml(e.displayname)..[[ {?7746:964?}]]
else
return box.tohtml(e.displayname)
end
end
end
return ""
end
function get_route(route,provider)
if (route=="f") then
return get_fixed(provider)
elseif (route=="s") then
return [[{?7746:695?}]]
elseif (route=="v") then
return [[{?7746:297?}]]
elseif (route=="m" and config.USB_GSM_VOICE) then
return box.tohtml(box.query("telcfg:settings/Mobile/MSN"))
end
return get_sip_route(route)
end
function getspan(txt)
return general.sprintf([[<span title="%1">%2</span>]],txt,txt)
end
function create_row(elem)
if (elem.Route=="s") then
return nil
end
rowstr=[[<tr>]]
rowstr=rowstr..[[<td class="c1">]]..getspan(get_number(elem.Number))..[[</td>]]
rowstr=rowstr..[[<td class="c2">]]..getspan(get_route(elem.Route,elem.Provider))..[[</td>]]
rowstr=rowstr..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..elem.uid, "edit" , elem.uid, [[{?txtIconBtnEdit?}]])..[[</td>]]
rowstr=rowstr..[[<td class="buttonrow">]]
if not fon_numbers.is_special_num(elem.Number) then
rowstr=rowstr..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..elem.uid, "delete", elem.uid, [[{?txtIconBtnDelete?}]],[[OnDelete(this)]])
end
return rowstr..[[</td></tr>]]
end
function get_array_len(a)
local count = 0
if a then
for index, value in pairs( a ) do
count = count + 1
end
end
return count
end
function concat_array(a,addstr)
if not a then
return ""
end
if not addstr then
addstr=""
end
local str=""
for index, value in pairs( a ) do
str=str..tostring(a[index])..addstr
end
return str
end
function get_rul_all_table()
local rul_list=fon_numbers.get_dialruls()
local str=[[
<table id="tDialRul" class="zebra">
<tr class="thead">
<th class="sortable c1">{?7746:711?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable c2">{?7746:427?}<span class="sort_no">&nbsp;</span></th>
<th class="buttonrow">&nbsp;</th>
<th class="c3">&nbsp;</th>
</tr>
]]
local strlist=array.map(rul_list,create_row)
if get_array_len(strlist)>0 then
str=str..concat_array(strlist,"\n")
else
str=str..[[<tr><td colspan="4" class="hint">{?7746:412?}</td></tr>]]
end
str=str..[[</table>]]
return str
end
function write_rul_all_table()
box.out(get_rul_all_table())
end
function write_visible(block)
if (block=="lcr" and not g_data.use_external_lcr) or
(block=="normal" and g_data.use_external_lcr) then
box.out("display:none;")
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#tDialRul {margin: auto; width: 100%; table-layout: fixed; height: 12px; white-space:nowrap; }
#tDialRul td {overflow:hidden;}
#tDialRul th {overflow:hidden;}
#tDialRul .c1 {width: 200px}
#tDialRul .c2 {width: 270px;}
#tDialRul .c3 {width: 30px;}
.btn_form {
padding-top:10px;
}
</style>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
var sort=sorter();
<?lua
val.write_js_error_strings()
?>
function OnOpenLCR()
{
window.open("/html/lcr.html", "LCR");
return false;
}
function uiDoOnMainFormSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
return true;
}
function OnDelete(Button)
{
if (confirm("{?7746:384?}"))
return true;
return false;
}
function OnReset()
{
if (!confirm("{?7746:818?}"))
return false;
return true;
}
function init()
{
}
function initTableSorter() {
sort.init("tDialRul");
sort.setDirection(0,-1);
sort.sort_table(0);
}
ready.onReady(initTableSorter);
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div style="<?lua write_visible('lcr')?>">
<p>{?7746:493?}</p>
<hr>
<?lua
if (general.is_expert()) then
box.out([[<h4>{?7746:422?}</h4>
<p>{?7746:900?}</p>
<div class="btn_form"><button type="submit" id="uiViewLCR" onclick="return OnOpenLCR();">{?7746:609?}</button></div>
<hr>
<h4>{?txtReset?}</h4>]])
end
?>
<p>{?7746:251?}</p>
<div class="btn_form"><button type="submit" id="uiViewReset" name="reset" onclick="return OnReset();">{?txtReset?}</button></div>
</div>
<div style="<?lua write_visible('normal')?>">
<?lua
box.out([[<p>]])
if fon_numbers.use_PSTN()=="1" then
box.html([[{?7746:396?}]])
elseif TXT_CHANGE then
box.html([[{?7746:119?}]])
else
box.html([[{?7746:134?}]])
end
box.out([[</p>]])
write_rul_all_table()
?>
<div class="btn_form"><button type="submit" name="new" >{?7746:141?}</button></div>
</div>
<?lua
if (g_errmsg) then
box.out(g_errmsg)
end
?>
<input type="hidden" name="back_to_page" value="<?lua box.out(g_back_to_page) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
