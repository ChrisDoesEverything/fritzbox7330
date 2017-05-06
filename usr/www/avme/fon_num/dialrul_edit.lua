<?lua
g_page_type = "all"
g_page_title = [[{?9843:947?}]]
g_page_help = 'hilfe_fon_wahlregeln.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("fon_numbers")
require("general")
require("http")
g_back_to_page = http.get_back_to_page( "/fon_num/dialrul_list.lua" )
g_menu_active_page=g_back_to_page
if (next(box.post) and (box.post.cancel)) then
http.redirect(g_back_to_page)
end
g_errcode = 0
g_errmsg = [[]]
g_data={}
local lkz=box.query("telcfg:settings/Location/LKZ")
if (lkz=="49") then
g_data.options = {
{value="tochoose", id="", display=[[{?txtPleaseSelect?}]]},
{value="number", id="number", display=[[{?txtRufnummer?}]]},
{value="mobile", id="mobile", display=[[{?9843:920?}]]},
{value="local", id="ortsnetz", display=[[{?9843:373?}]]},
{value="distance", id="national", display=[[{?9843:238?}]]},
{value="foreign", id="international", display=[[{?9843:838?}]]},
{value="special", id="sonderrufnrn", display=[[{?9843:276?}]]},
{value="info", id="auskunft", display=[[{?9843:976?}]]}
}
else
g_data.options = {
{value="number", id="number", display=[[{?txtRufnummer?}]]}
}
end
g_data.is_telecom = box.query("providerlist:settings/activeprovider") == 'tonline'
g_Warning=general.sprintf([[{?9843:580?}%2%Umbruch%{?9843:295?}]],[[\n\n\n\n]],[[\n\n]],[[\n]])
function read_data()
g_data.provider_list=fon_numbers.get_prefix_list()
g_data.pots=nil
g_data.msnlist=nil
g_data.mobile_msnlist=fon_numbers.get_mobile_msn()
g_data.siplist=fon_numbers.get_sip_num()
g_data.is_germany=(box.query("box:settings/country")=="049")
g_data.new=(box.get and box.get.newid=="new") or (box.post and box.post.is_new=="true") or false
g_data.uid=""
if box.get and box.get.uid then
g_data.uid = box.get.uid
elseif box.post and box.post.uid then
g_data.uid = box.post.uid
end
g_data.rul_list=fon_numbers.get_dialruls()
g_data.cur_rule=nil
if (not g_data.new) then
local elem=fon_numbers.find_elem_in_list_by_uid(g_data.rul_list,g_data.uid)
if (elem) then
g_data.cur_rule={}
g_data.cur_rule.num=""
g_data.cur_rule.type=""
for i=2,7 do
if (g_data.options[i].id==elem.Number) then
g_data.cur_rule.type=g_data.options[i].value
break
end
end
if (g_data.cur_rule.type=="") then
g_data.cur_rule.type="number"
g_data.cur_rule.num=elem.Number
end
if (elem.Route=="v") then
g_data.cur_rule.via_num="INET"
elseif (elem.Route=="f") then
g_data.cur_rule.via_num="FIXED"..elem.Provider
elseif (elem.Route=="m") then
g_data.cur_rule.via_num="SIP99"
else
g_data.cur_rule.via_num="SIP"..elem.Route
end
end
else
if (next(box.post)) then
g_data.cur_rule={}
g_data.cur_rule.type=box.post.num_type
g_data.cur_rule.num=box.post.src_num or ""
g_data.cur_rule.via_num=box.post.via_num
end
end
end
read_data()
g_val = {
prog = [[
if __value_equal(uiNumType/num_type, tochoose) then
const_error(uiNumType/num_type, wrong, out_selection_type)
end
if __value_equal(uiNumType/num_type, number) then
not_empty(uiSrcNum/src_num,num_error)
char_range_regex(uiSrcNum/src_num, fonnum, num_error)
end
if __value_equal(uiViaNum/via_num, tochoose) then
const_error(uiViaNum/via_num, wrong, out_selection)
end
]]
}
val.msg.out_selection = {
[val.ret.wrong] = [[{?9843:466?}]]
}
val.msg.out_selection_type = {
[val.ret.wrong] = [[{?9843:514?}]]
}
val.msg.num_error = {
[val.ret.empty] = [[{?9843:12?}]],
[val.ret.outofrange] = [[{?9843:433?}]]
}
function get_route_num()
for i, e in ipairs(g_data.options) do
if (e.value==box.post.num_type and e.value~="number") then
return e.id
end
end
return box.post.src_num
end
function get_route_and_provider()
local route="0"
local provider="0"
if string.find(box.post.via_num,"SIP") then
if (box.post.via_num=="SIP99") then
route="m"
else
route=string.gsub(box.post.via_num,"SIP","")
end
elseif box.post.via_num=="INET" then
route="v"
elseif string.find(box.post.via_num,"FIXED") or g_data.is_telecom then
route="f"
provider=string.gsub(box.post.via_num,"FIXED","")
end
return route, provider
end
if (next(box.post) and (box.post.apply)) then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
local saveset={}
local id="0"
if g_data.new then
id=box.query("telcfg:settings/Routing/Group/newid")
else
id=g_data.uid
end
local route, provider=get_route_and_provider()
cmtable.add_var(saveset, "telcfg:settings/Routing/"..id.."/Number" ,get_route_num())
cmtable.add_var(saveset, "telcfg:settings/Routing/"..id.."/Route" ,route)
cmtable.add_var(saveset, "telcfg:settings/Routing/"..id.."/Provider" ,provider)
local err, msg = box.set_config( saveset)
if err == 0 then
http.redirect(g_back_to_page)
else
g_errmsg=general.create_error_div(err,msg)
end
end
end
function write_mode()
box.out(g_data.mode)
end
function get_numbers(num_to_select)
local str=""
local list=fon_numbers.get_list_of_numbers(g_data,'inet fixed', g_data.is_telecom)
if list then
str=str..[[<option value="tochoose">{?txtPleaseSelect?}</option>]]
for i,elem in ipairs(list) do
str=str..[[<option value="]]..elem.val..[["]]
if (num_to_select==elem.val) then
str=str..[[ selected ]]
end
str=str..[[>]]..box.tohtml(elem.key)
if (string.find(elem.val,"SIP99")) then
str=str..[[ {?9843:289?}]]
elseif (string.find(elem.val,"SIP") and fon_numbers.use_PSTN()=="1") then
str=str..[[ {?9843:719?}]]
end
str=str..[[</option>]]
end
end
return str
end
function is_fon_num(number)
local pattern=val.pr.fonnum.pat
if not(string.find(number, pattern)) then
return false
end
return true
end
function write_num_types()
local selected_type = "tochoose"
if g_data.cur_rule and g_data.cur_rule.type~="" then
selected_type = g_data.cur_rule.type
end
box.out([[<select id="uiNumType" name="num_type" onchange="return OnChangeType();">]])
local option = [[<option value="%1" %2>%3</option>]]
for i,e in ipairs(g_data.options) do
local selected = selected_type == e.value and [[ selected]] or ""
box.out(general.sprintf(option, box.tohtml(e.value), selected, box.tohtml(e.display)))
end
box.out([[</select>]])
end
function write_num()
if g_data.cur_rule and g_data.cur_rule.type=="number" then
box.html(g_data.cur_rule.num)
end
end
function del_hash(num)
return string.gsub(num,"#","")
end
function write_numbers()
local str=""
local num=nil
if g_data.cur_rule and g_data.cur_rule.via_num~="" then
num=g_data.cur_rule.via_num
end
str=get_numbers(num)
box.out(str)
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.formular select,
.formular input[type=text] {
width: 200px;
}
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var g_UseFixed = <?lua box.out(tostring(fon_numbers.use_PSTN()=="1"))?>;
var g_is_germany = <?lua box.out(tostring(g_data.is_germany))?>;
var g_language = "<?lua box.out(config.language)?>";
var g_new = <?lua box.out(tostring(g_data.new)) ?>;
var g_confirmMsgText = "<?lua box.js(g_Warning)?>";
var g_old_num = "<?lua if (g_data.cur_rule) then box.js(g_data.cur_rule.num) end?>";
function isInternetroute (nr)
{
return (nr.indexOf("SIP")==0);
}
function OnChangeType()
{
var num_active=jxl.getValue("uiNumType")=="number";
jxl.setDisabled("uiSrcNum",!num_active);
return true;
}
function isSpecialNum (nr) {
if (!g_UseFixed)
return false;
if (g_language=="en")
{
switch (nr) {
case "999":
case "112": return true;
}
}
else
{
switch (nr) {
case "19222":
case "110":
case "112": return true;
}
}
return false;
}
function uiDoOnMainFormSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
var NumType = jxl.getValue("uiNumType");
var Nr = jxl.getValue("uiSrcNum");
var Route = jxl.getValue("uiViaNum");
if (NumType=="" && isSpecialNum(Nr) && isInternetroute(Route)) {
ret = confirm(g_routing_confirmMsgText);
}
return true;
}
function OnChangeTo(val)
{
return true;
}
function init()
{
if (isSpecialNum(g_old_num))
{
jxl.setDisabled("uiNumType",true);
jxl.setDisabled("uiSrcNum",true);
jxl.enable("uiOldSrcNum");
jxl.enable("uiOldType");
}
else
OnChangeType()
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div class="formular">
<p>{?9843:725?}</p>
<div>
<div>
<label for="uiNumType">{?9843:81?}</label>
<?lua
write_num_types()
?>
</div>
<div>
<label for="uiSrcNum">{?9843:842?}</label>
<input type="text" value="<?lua write_num() ?>" id="uiSrcNum" name="src_num">
</div>
<div>
<label for="uiViaNum">{?9843:702?}</label>
<select size="1" id="uiViaNum" name="via_num" onchange="OnChangeTo(this.value)">
<?lua
write_numbers()
?>
</select>
</div>
</div>
<?lua
if (g_errmsg~="") then
box.out(g_errmsg)
end
?>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply" style="">{?txtOk?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="is_new" value="<?lua box.html(tostring(g_data.new)) ?>">
<input type="hidden" id="uiOldSrcNum" name="src_num" value="<?lua if (g_data.cur_rule) then box.html(tostring(g_data.cur_rule.num)) end?>" disabled>
<input type="hidden" id="uiOldType" name="via_num" value="<?lua if (g_data.cur_rule) then box.html(tostring(g_data.cur_rule.type)) end?>" disabled>
<input type="hidden" name="uid" value="<?lua box.html(tostring(g_data.uid)) ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
