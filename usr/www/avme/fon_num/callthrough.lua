<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_fon_durchwahl.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("fon_numbers")
require("bit")
require("general")
require("http")
g_back_to_page = http.get_back_to_page( "/fon_num/callthrough.lua" )
g_val = {
prog = [[
if __checked(uiViewActive/active) then
if __checked(uiViewCtId/ct_id) then
char_range_regex(uiCallerId0/caller_id0, fonnum, error_txt)
char_range_regex(uiCallerId1/caller_id1, fonnum, error_txt)
char_range_regex(uiCallerId2/caller_id2, fonnum, error_txt)
char_range_regex(uiCallerId3/caller_id3, fonnum, error_txt)
char_range_regex(uiCallerId4/caller_id4, fonnum, error_txt)
char_range_regex(uiCallerId5/caller_id5, fonnum, error_txt)
char_range_regex(uiCallerId6/caller_id6, fonnum, error_txt)
char_range_regex(uiCallerId7/caller_id7, fonnum, error_txt)
end
if __value_not_equal(uiViewPin/pin,****) then
char_range_regex(uiViewPin/pin, decimals, error_txt)
length(uiViewPin/pin, 4, 4, error_txt)
end
end
]]
}
val.msg.error_txt = {
[val.ret.tooshort] = [[{?431:500?}]],
[val.ret.outofrange] = [[{?431:824?}]]
}
if (next(box.post) and (box.post.cancel)) then
end
g_errcode = 0
g_errmsg = [[]]
g_data={}
function read_data()
local msn_list=fon_numbers.get_msn()
g_data.active =box.query("telcfg:settings/CallThrough/Active")
g_data.pin =box.query("telcfg:settings/CallThrough/PIN")
g_data.msn_in =box.query("telcfg:settings/CallThrough/MSN")
local elem=fon_numbers.get_elem_by_num(msn_list,g_data.msn_in)
if elem then
g_data.msn_in=elem.id
end
g_data.msn_out =box.query("telcfg:settings/CallThrough/OutgoingMSN")
local elem=fon_numbers.get_elem_by_num(msn_list,g_data.msn_out)
if elem then
g_data.msn_out=elem.id
end
g_data.call_id ={}
for i=1,8 do
g_data.call_id[i]=box.query("telcfg:settings/CallThrough/CallerID"..tostring(i-1))
end
end
if (next(box.post) and (box.post.update)) then
local saveset={}
cmtable.add_var( saveset, "telcfg:settings/CallThrough/Active", "0")
cmtable.add_var( saveset, "telcfg:settings/CallThrough/Extension", "")
cmtable.add_var( saveset, "telcfg:settings/CallThrough/Prefix" , "")
cmtable.add_var( saveset, "telcfg:settings/CallThrough/UsePrefix", "0")
local err, msg = box.set_config( saveset)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
read_data()
elseif (next(box.post) and (box.post.apply)) then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
local saveset={}
if box.post.active then
cmtable.add_var( saveset, "telcfg:settings/CallThrough/Active", "1")
local elem=fon_numbers.find_num_by_UID(box.post.msn)
local data=box.post.msn
if elem then
data=elem.id
if elem.type=="msn" then
data=elem.number
end
end
cmtable.add_var( saveset, "telcfg:settings/CallThrough/MSN", data)
if (box.post.pin~="****") then
cmtable.add_var( saveset, "telcfg:settings/CallThrough/PIN", box.post.pin )
end
elem=fon_numbers.find_num_by_UID(box.post.out_msn)
data=box.post.out_msn
if elem then
data=elem.id
if elem.type=="msn" then
data=elem.number
end
end
cmtable.add_var( saveset, "telcfg:settings/CallThrough/OutgoingMSN", data)
for i=0,7 do
if (box.post["caller_id"..tostring(i)]) then
cmtable.add_var( saveset, "telcfg:settings/CallThrough/CallerID"..tostring(i), box.post["caller_id"..tostring(i)])
else
cmtable.add_var( saveset, "telcfg:settings/CallThrough/CallerID"..tostring(i), "")
end
end
g_data.active ="1"
else
cmtable.add_var( saveset, "telcfg:settings/CallThrough/Active", "0")
g_data.active ="0"
end
local err, msg = box.set_config( saveset)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
read_data()
else
g_data.active = "0"
if box.post.active then
g_data.active = "1"
end
g_data.pin =box.post.pin
g_data.msn_in =box.post.msn
g_data.msn_out =box.post.out_msn
g_data.call_id ={}
for i=1,8 do
g_data.call_id[i]=box.post["caller_id"..tostring(i-1)] or ""
end
end
else
read_data()
end
function write_per_day_visible()
if (g_data.option~="per_day") then
box.out([[display:none;]])
end
end
function write_day(cur_day)
if (g_data.day[cur_day]) then
box.out([[ checked="checked"]])
end
if (g_data.option~="per_day") then
box.out([[ disabled]])
end
end
function write_option_checked(cur_option)
if (cur_option==g_data.option) then
box.out([[checked="checked"]])
end
end
function write_active_checked()
if (g_data.active=="1") then
box.out([[checked="checked"]])
end
end
function write_active()
return box.out(tostring(g_data.active=="1"))
end
function no_msn_defined(msnlist)
if (msnlist==nil) then
return true
end
return (msnlist.number_count==0)
end
function is_msn_in_siplist(number,siplist)
return fon_numbers.find_num_in_list(siplist,number)
end
function is_sip_in_msnlist(number,msnlist)
return fon_numbers.find_num_in_list(msnlist,number)
end
function is_sip_in_pots(number,pots)
return fon_numbers.find_num_in_list(pots,number)
end
function fill_select(cur_num)
local sel=""
local txt_fixed_line=[[{?gFestNetz?}]]
local txt_internet =[[{?gInternet?}]]
local pots=fon_numbers.get_pots()
local msnlist=fon_numbers.get_msn()
local siplist=fon_numbers.get_sip_num()
if (fon_numbers.use_PSTN()=="1") then
if pots.number_count>0 then
if (cur_num=="POTS") then
sel=[[selected]]
end
box.out([[<option value="POTS" ]]..sel..[[>]]..box.tohtml(pots.numbers[1].number)..[[ (]]..txt_fixed_line..[[)</option>]])
else
local cur_country=box.query("box:settings/country")
if (general.is_expert() or no_msn_defined(msnlist) or cur_country=="043") then
if (cur_num=="POTS") then
sel=[[selected]]
end
box.out([[<option value="POTS" ]]..sel..[[>]]..txt_fixed_line..[[</option>]])
end
end
end
if msnlist.number_count>0 then
for _,elem in ipairs(msnlist.numbers) do
sel=""
if (cur_num==elem.id) then
sel=[[selected]]
end
if (is_msn_in_siplist(elem.number,siplist)) then
box.out([[<option value="]]..elem.uid ..[[" ]]..sel..[[>]]..box.tohtml(elem.number)..[[ (]]..txt_fixed_line..[[)</option>]])
else
box.out([[<option value="]]..elem.uid ..[[" ]]..sel..[[>]]..box.tohtml(elem.number) ..[[</option>]])
end
end
end
local mobile_msnlist = fon_numbers.get_mobile_msn()
if mobile_msnlist.number_count>0 then
for ind,mobile_msn in ipairs(mobile_msnlist.numbers) do
sel=""
if (cur_num==[[SIP]]..mobile_msn.telcfg_id) then
sel=[[selected]]
end
box.out([[<option value="SIP]]..mobile_msn.telcfg_id ..[[" ]]..sel..[[>]]..box.tohtml(mobile_msn.number)..[[</option>]])
end
end
if siplist.number_count>0 then
for _,elem in ipairs(siplist.numbers) do
sel=""
if (cur_num==[[SIP]]..elem.telcfg_id) then
sel=[[selected]]
end
if (is_sip_in_msnlist(elem.number,msnlist) or is_sip_in_pots(elem.number,pots)) then
box.out([[<option value="SIP]]..elem.telcfg_id ..[[" ]]..sel..[[>]]..box.tohtml(elem.number)..[[ (]]..txt_internet..[[)</option>]])
else
box.out([[<option value="SIP]]..elem.telcfg_id ..[[" ]]..sel..[[>]]..box.tohtml(elem.number) ..[[</option>]])
end
end
end
end
function write_calls_in()
fill_select(g_data.msn_in)
end
function write_calls_out()
fill_select(g_data.msn_out)
end
function write_pin()
box.html(g_data.pin)
end
function any_callthrough_id()
for i=1,8 do
if g_data.call_id[i]~="" then
return true
end
end
return false
end
function write_callthrough_id()
if any_callthrough_id() then
box.out([[checked="checked"]])
end
end
function write_callthrough_visible()
if (g_data.active~="2") then
return
end
box.out([[display:none;]])
end
function write_hint_visible()
if (g_data.active~="2") then
return
end
box.out([[
<div class="formular">
<p >{?431:924?}</p>
</div>
]])
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#uiLeftBlock {
float:left;
width:200px;
margin:auto;
}
#uiRightBlock {
width:200px;
margin:auto;
}
#uiCallerIdBlock label {
width:auto;
}
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function uiDoOnMainFormSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
return true;
}
function OnClickCtId(checked)
{
jxl.disableNode("uiCallerIdBlock",!checked);
}
function AnyCallthroughId()
{
for (var i=0;i<8;i++)
{
if (jxl.getValue("uiCallerId"+i)!="")
{
return true;
}
}
return false;
}
function OnActive(checked)
{
jxl.disableNode("uiCallthroughBlock",!checked);
jxl.disableNode("uiCallerIdBlock",!AnyCallthroughId());
}
function init()
{
var checked=<?lua write_active() ?>;
OnActive(checked);
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>{?431:140?}</p>
<div class="narrow"><div class="formular" style="<?lua write_callthrough_visible()?>">
<p><input type="checkbox" id="uiViewActive" name="active" onclick="OnActive(this.checked)" <?lua write_active_checked() ?>>&nbsp;<label for="uiViewActive">{?431:201?}</label></p>
<div class="formular" id="uiCallthroughBlock">
<div>
<div class="subtitle">{?431:369?}</div>
<div class="formular">
<select size="1" id="uiViewCallsIn" name="msn">
<?lua write_calls_in() ?>
</select>
</div>
</div>
<div>
<div class="subtitle">{?431:486?}</div>
<div class="formular">
<select size="1" id="uiViewCallsOut" name="out_msn">
<?lua write_calls_out() ?>
</select>
</div>
</div>
<div class="subtitle">{?431:588?}</div>
<div class="formular">
<label for="uiViewPin">{?txtPin?}</label>
<input type="text" id="uiViewPin" name="pin" size="5" maxlength="4" autocomplete="off" value="<?lua write_pin()?>">
</div>
<div>
<input type="checkbox" id="uiViewCtId" name="ct_id" onclick="OnClickCtId(this.checked)" <?lua write_callthrough_id() ?>>&nbsp;<label for="uiViewCtId">{?431:785?}</label>
<div id="uiCallerIdBlock" class="formular">
<div id="uiLeftBlock">
<p><label for="uiCallerId0">1.</label><input type="text" id="uiCallerId0" name="caller_id0" size="21" maxlength="20" value="<?lua box.html(g_data.call_id[1]) ?>"></p>
<p><label for="uiCallerId1">2.</label><input type="text" id="uiCallerId1" name="caller_id1" size="21" maxlength="20" value="<?lua box.html(g_data.call_id[2]) ?>"></p>
<p><label for="uiCallerId2">3.</label><input type="text" id="uiCallerId2" name="caller_id2" size="21" maxlength="20" value="<?lua box.html(g_data.call_id[3]) ?>"></p>
<p><label for="uiCallerId3">4.</label><input type="text" id="uiCallerId3" name="caller_id3" size="21" maxlength="20" value="<?lua box.html(g_data.call_id[4]) ?>"></p>
</div>
<div id="uiRightBlock">
<p><label for="uiCallerId4">5.</label><input type="text" id="uiCallerId4" name="caller_id4" size="21" maxlength="20" value="<?lua box.html(g_data.call_id[5]) ?>"></p>
<p><label for="uiCallerId5">6.</label><input type="text" id="uiCallerId5" name="caller_id5" size="21" maxlength="20" value="<?lua box.html(g_data.call_id[6]) ?>"></p>
<p><label for="uiCallerId6">7.</label><input type="text" id="uiCallerId6" name="caller_id6" size="21" maxlength="20" value="<?lua box.html(g_data.call_id[7]) ?>"></p>
<p><label for="uiCallerId7">8.</label><input type="text" id="uiCallerId7" name="caller_id7" size="21" maxlength="20" value="<?lua box.html(g_data.call_id[8]) ?>"></p>
</div>
<div class="clear_float"></div>
</div>
</div>
</div>
</div></div>
<?lua
if (g_errmsg) then
box.out(g_errmsg)
end
write_hint_visible()
?>
<div id="btn_form_foot">
<button type="submit" name="update" style="<?lua if g_data.active~=[[2]] then box.out([[display:none;]]) end ?>">{?431:741?}</button>
<button type="submit" name="apply" style="<?lua if g_data.active==[[2]] then box.out([[display:none;]]) end ?>">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
<input type="hidden" name="back_to_page" value="<?lua box.out(g_back_to_page) ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
