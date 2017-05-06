<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_fon_rufumleitung.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("fon_numbers")
require("general")
require("http")
g_back_to_page = http.get_back_to_page( "/fon_num/rul_list.lua" )
g_val = {
prog = [[
]]
}
g_pb=nil
if (next(box.post) and (box.post.cancel)) then
end
g_errcode = 0
g_errmsg = [[]]
g_data={}
g_RefreshDiversity= box.query("telcfg:settings/RefreshDiversity")
function read_data()
g_data.pots=fon_numbers.get_pots()
g_data.msnlist=fon_numbers.get_msn()
g_data.siplist=fon_numbers.get_sip_num()
end
if (next(box.post) and (box.post.apply)) then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
local saveset={}
for i=0,2 do
local spezialRulState = box.query("telcfg:settings/MSN/Port"..tostring(i).."/Diversion")
if spezialRulState ~= "" and ((spezialRulState == "0" and box.post["port_"..i]) or (spezialRulState ~= "0" and box.post["port_"..i] == nil)) then
cmtable.save_checkbox(saveset,"telcfg:settings/MSN/Port"..tostring(i).."/Diversion","port_"..tostring(i))
end
end
local num_of_rul=box.query("telcfg:settings/Diversity/count")
for i=0,num_of_rul-1 do
cmtable.save_checkbox(saveset,"telcfg:settings/Diversity"..tostring(i).."/Active","rul_"..tostring(i))
end
local num_of_rub=box.query("telcfg:settings/CallerIDActions/count")
for i=0,num_of_rub-1 do
if (box.query("telcfg:settings/CallerIDActions"..tostring(i).."/Action")~="1") then
cmtable.save_checkbox(saveset,"telcfg:settings/CallerIDActions"..tostring(i).."/Active","rub_"..tostring(i))
end
end
local err, msg = box.set_config( saveset)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
read_data()
else
end
elseif (next(box.post) and box.post.delete) then
local saveset={}
if string.find(box.post.delete,"port_") then
local idx=tonumber(string.gsub(box.post.delete,"port_",""),10) or -1
cmtable.add_var(saveset,"telcfg:settings/MSN/Port"..tostring(idx).."/DiversionNumber","")
cmtable.add_var(saveset,"telcfg:settings/MSN/Port"..tostring(idx).."/Diversion","0")
elseif string.find(box.post.delete,"rul_") then
local idx=tonumber(string.gsub(box.post.delete,"rul_",""),10) or 0
local cmd="Diversity"..tostring(idx)
cmtable.add_var(saveset,"telcfg:command/"..cmd,"delete")
elseif string.find(box.post.delete,"rub_") then
local idx=tonumber(string.gsub(box.post.delete,"rub_",""),10) or 0
local cmd="CallerIDActions"..tostring(idx)
cmtable.add_var(saveset,"telcfg:command/"..cmd,"delete")
end
local err, msg = box.set_config( saveset)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
read_data()
elseif (next(box.post) and box.post.edit) then
local param = {}
param[1]="uid="..box.post.edit
param[2]='back_to_page='..box.glob.script
http.redirect(href.get("/fon_num/rul_edit.lua",unpack(param)))
elseif (next(box.post) and box.post.new) then
local param = {}
param[1]="newid=new"
param[2]='back_to_page='..box.glob.script
http.redirect(href.get("/fon_num/rul_edit.lua",unpack(param)))
else
read_data()
end
function get_display_out(num)
return fon_numbers.get_num_txt(g_data, num)
end
function write_rul_all_list()
local rul_list=fon_numbers.get_rul_all()
box.js([[var g_RulList=]])
box.out(js.table(rul_list))
return true
end
local g_tams={
["600"] = box.query("tam:settings/TAM0/Name"),
["601"] = box.query("tam:settings/TAM1/Name"),
["602"] = box.query("tam:settings/TAM2/Name"),
["603"] = box.query("tam:settings/TAM3/Name"),
["604"] = box.query("tam:settings/TAM4/Name")
}
for i=0,4 do
if g_tams["60"..tostring(i)]=="" then
g_tams["60"..tostring(i)]=[[{?835:633?} ]]..tostring(i+1)
end
end
function get_display_dest(num)
if g_tams[num] then
return g_tams[num]
end
return num;
end
function get_display_mode(action,elemtype)
local str=""
if elemtype=="port" then
str=fon_numbers.get_port_txt(action)
elseif elemtype=="rul" then
str=fon_numbers.get_rul_txt(action)
end
if (not str) then
return ""
end
return str
end
function getspan(txt,spantxt)
if not spantxt then
spantxt=txt
end
return general.sprintf([[<span title="%1">%2</span>]],box.tohtml(spantxt),box.tohtml(txt))
end
function create_row(elem)
local checked=""
if elem.active then
checked="checked"
end
if (elem.type=="rub" and elem.action=="1") then
return ""
end
local rowstr=[[<tr><td class="c1"><input type="checkbox" id="uiView_]]..elem.uid..[[" name="]]..elem.uid..[[" ]]..checked..[[ onclick="OnActivateRule(this)"></td>]]
if elem.type=="port" then
rowstr=rowstr..[[<td class="c2">{?835:258?} ]]..elem.portname..[[</td>]]
rowstr=rowstr..[[<td class="c3">]]..getspan(get_display_out(elem.num_out))..[[</td>]]
rowstr=rowstr..[[<td class="c4">]]..getspan(get_display_dest(elem.num_dest))..[[</td>]]
rowstr=rowstr..[[<td class="c5">]]..getspan(get_display_mode(elem.action,elem.type))..[[</td>]]
elseif elem.type=="rul" then
rowstr=rowstr..[[<td class="c2">{?835:456?} ]]..getspan(get_display_out(elem.caller_id))..[[</td>]]
rowstr=rowstr..[[<td class="c3">]]..getspan(get_display_out(elem.num_out))..[[</td>]]
rowstr=rowstr..[[<td class="c4">]]..getspan(get_display_dest(elem.num_dest))..[[</td>]]
rowstr=rowstr..[[<td class="c5">]]..getspan(get_display_mode(elem.action,elem.type))..[[</td>]]
elseif elem.type=="rub" then
if elem.action=="0" then
require "fon_book"
local name=elem.num_dest
if (not g_pb) then
g_pb = fon_book.read_fonbook(0, 0, "name")
end
name=fon_book.get_name_by_num(g_pb,name)
txt,spantxt=fon_numbers.get_caller_id_txt(elem)
rowstr=rowstr..[[<td class="c2">]]..getspan(txt,spantxt)..[[</td>]]
rowstr=rowstr..[[<td class="c3">]]..getspan(get_display_out(elem.num_out))..[[</td>]]
rowstr=rowstr..[[<td class="c4">]]..getspan(get_display_dest(name),elem.num_dest)..[[</td>]]
rowstr=rowstr..[[<td class="c5">{?835:3395?}</td>]]
elseif elem.action=="2" then
rowstr=rowstr..[[<td class="c1"></td>]]
rowstr=rowstr..[[<td class="c2">]]..getspan([[{?835:998?} ]]..elem.name)..[[</td>]]
rowstr=rowstr..[[<td class="c3"></td>]]
rowstr=rowstr..[[<td class="c4"></td>]]
rowstr=rowstr..[[<td class="c5">{?835:608?}</td>]]
end
end
if not(elem.action=="2" and elem.type=="rub") then
rowstr=rowstr..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..elem.uid, "edit" , elem.uid, [[{?txtIconBtnEdit?}]])..[[</td>]]
end
rowstr=rowstr..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..elem.uid, "delete", elem.uid, [[{?txtIconBtnDelete?}]],[[OnDelete(this)]]) ..[[</td>]]
return rowstr..[[</tr>]]
end
function get_rul_all_table()
local rul_list=fon_numbers.get_rul_all()
local str=[[
<table id="tMsnRul" class="zebra">
<tr class="thead">
<th class="c1">{?835:996?}</th>
<th class="sortable c2">{?835:399?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable c3">{?835:795?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable c4">{?835:981?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable c5">{?835:6530?}<span class="sort_no">&nbsp;</span></th>
<th class="c7">&nbsp;</th>
<th class="c8">&nbsp;</th>
</tr>
]]
local strlist=array.map(rul_list,create_row)
if #strlist~=0 then
str=str..table.concat(strlist,"\n")
else
str=str..[[<tr><td colspan="7" class="hint">{?835:699?}</td></tr>]]
end
str=str..[[</table>]]
return str
end
function write_rul_all_table()
box.out(get_rul_all_table())
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#tMsnRul {margin: auto; width: 100%; table-layout: fixed; height: 12px; white-space:nowrap; }
#tMsnRul td {overflow:hidden;}
#tMsnRul th {overflow:hidden;}
#tMsnRul .c1 {text-align: center; width: 40px}
#tMsnRul .c2 {text-align: left; width: 130px;}
#tMsnRul .c3 {text-align: left; width: 95px;}
#tMsnRul .c4 {text-align: left; width: 115px;}
#tMsnRul .c5 {text-align: left; width: 80px;}
#tMsnRul .c6 {text-align: left; width: 0px;}
#tMsnRul .c7 {text-align: right; width: 30px;}
#tMsnRul .c8 {text-align: right; width: 30px;}
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
write_rul_all_list()
?>
function FindRule(key,val)
{
for (var i=0;i<g_RulList.length;i++)
{
if (g_RulList[i][key]==val)
return g_RulList[i];
}
return 0;
}
function FindOtherActiveRule(uid,key,val)
{
for (var i=0;i<g_RulList.length;i++)
{
if (g_RulList[i][key]==val && g_RulList[i].active && g_RulList[i].uid!=uid)
return g_RulList[i];
}
return 0;
}
function OnActivateRule(obj)
{
var elem=FindRule("uid", obj.name);
if (!elem)
{
return true;
}
if (!obj.checked)
{
elem.active=false;
return true;
}
var other=FindOtherActiveRule(elem.uid,"caller_id",elem.caller_id)
if (other)
{
var number=other.displaytxt;
var msg=jxl.sprintf("{?835:147?}\n{?835:272?}",number);
alert(msg);
}
elem.active=true;
return true;
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
if (confirm("{?835:253?}"))
return true;
return false;
}
function init()
{
}
function initTableSorter() {
sort.init("tMsnRul");
sort.setDirection(3,-1);
sort.sort_table(3);
}
ready.onReady(initTableSorter);
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div>
<p>{?835:724?}</p>
<?lua
write_rul_all_table()
?>
<div class="btn_form"><button type="submit" name="new" >{?835:336?}</button></div>
</div>
<?lua
if (g_errmsg) then
box.out(g_errmsg)
end
?>
<div id="btn_form_foot">
<button type="submit" name="apply" style="">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
<input type="hidden" name="back_to_page" value="<?lua box.out(g_back_to_page) ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
