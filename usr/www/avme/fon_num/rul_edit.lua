<?lua
g_page_type = "all"
g_page_title = [[{?605:517?}]]
g_page_help = 'hilfe_fon_neue_rufumleitung.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("fon_numbers")
require("fon_book")
require"general"
g_back_to_page = http.get_back_to_page( "/fon_num/rul_edit.lua" )
g_menu_active_page=g_back_to_page
if (next(box.post) and (box.post.cancel)) then
http.redirect(g_back_to_page)
end
g_errcode = 0
g_errmsg = [[]]
g_txtMSN=[[{?605:653?}]]
g_errTab= {
rul_exist = [[{?605:724?}]],
block_exist = [[{?605:157?}]]
}
g_data={}
function find_in_book(caller_id)
for i, entry in ipairs(g_data.fonbook) do
for j, num in ipairs(entry.numbers or {}) do
if caller_id == num.number or caller_id == num.number:gsub("%D+", "") then
g_data.fonbook_contact = entry.name or ""
return true
end
end
end
return false
end
function get_num_from_book(val)
local tt = string.split(val, "_")
local entry_uid = tonumber(tt[1])
local num_id = tonumber(tt[2])
local entry = fon_book.read_entry_by_uid(entry_uid)
local i, num = array.find(entry.numbers, func.eq(num_id, "id"))
if i then
return tostring(num.number)
end
return val
end
function get_mode()
g_data.mode="call_to"
if (g_data.new) then
if not g_data.is_germany then
g_data.mode="call_to"
else
g_data.mode="all"
end
return
end
if string.find(g_data.uid,"port_") then
g_data.mode="call_to_fon"
elseif string.find(g_data.uid,"rul_") then
g_data.mode="call_to"
elseif string.find(g_data.uid,"rub_") then
g_data.mode="call_from"
if (g_data.cur_rul) then
if (g_data.cur_rul.caller_id=="" or string.find(g_data.cur_rul.caller_id,"#")==1) then
g_data.mode="unknown"
elseif (g_data.cur_rul.caller_id=="*") then
g_data.mode="all"
elseif find_in_book(g_data.cur_rul.caller_id) then
g_data.mode="call_book"
end
end
end
if not g_data.is_germany and g_data.mode=="all" then
g_data.mode="call_to"
end
end
function read_data()
g_data.fonbook = fon_book.read_fonbook(0, 0, "name")
g_data.pots=fon_numbers.get_pots()
g_data.msnlist=fon_numbers.get_msn()
--g_data.mobile_msnlist=fon_numbers.get_mobile_msn()
g_data.mobile_msnlist={}
g_data.siplist=fon_numbers.get_sip_num()
g_data.is_germany=(box.query("box:settings/country")=="049")
g_data.new=(box.get and box.get.newid=="new") or (box.post and box.post.is_new=="true") or false
g_data.uid=""
if box.get and box.get.uid then
g_data.uid = box.get.uid
elseif box.post and box.post.uid then
g_data.uid = box.post.uid
end
if not g_data.uid then
http.redirect(g_back_to_page)
end
g_data.rul_list=fon_numbers.get_rul_all()
g_data.cur_rul=nil
if (not g_data.new) then
g_data.cur_rul=fon_numbers.find_elem_in_list_by_uid(g_data.rul_list,g_data.uid)
end
get_mode()
end
read_data()
g_val = {
prog = [[
if __radio_check(uiDestRuf/destination,phone) then
not_empty(uiViewDest/num_dest,num_error)
char_range_regex(uiViewDest/num_dest, fonnum, num_error)
if __value_equal(uiViewUeber/num_out, tochoose) then
const_error(uiViewUeber/num_out, wrong, out_selection)
end
end
]]
}
if (g_data.mode=="call_to_fon") then
g_val = {
prog = [[
if __radio_check(uiDestRuf/destination,phone) then
not_empty(uiViewDest/num_dest,num_error)
char_range_regex(uiViewDest/num_dest, fonnum, num_error)
end
]]
}
end
if (g_data.new) then
g_val = {
prog = [[
if __radio_check(uiModeTo/mode_new,call_to) then
if __value_equal(uiViewTo/call_to_sel, tochoose) then
const_error(uiViewTo/call_to_sel, wrong, out_selection_call_to)
end
end
if __radio_check(uiModeBook/mode_new,call_book) then
if __value_equal(uiViewFonbookEntries/fonbook_entry, tochoose) then
const_error(uiViewFonbookEntries/fonbook_entry, wrong, out_selection_call_book)
end
end
if __radio_check(uiModeUnknown/mode_new,unknown) then
if __value_equal(uiViewUnknown/unknown_num, tochoose) then
const_error(uiViewUnknown/unknown_num, wrong, out_selection_unknown)
end
end
if __radio_check(uiModeNr/mode_new,call_from) then
not_empty(uiViewNr/num_from,num_error)
end
if __radio_check(uiDestTam/destination,tam) then
end
if __radio_check(uiDestRuf/destination,phone) then
not_empty(uiViewDest/num_dest,num_error)
char_range_regex(uiViewDest/num_dest, fonnum, num_error)
if __value_equal(uiViewUeber/num_out, tochoose) then
const_error(uiViewUeber/num_out, wrong, out_selection)
end
end
]]
}
end
val.msg.out_selection = {
[val.ret.wrong] = [[{?605:527?}]]
}
val.msg.out_selection_call_to = {
[val.ret.wrong] = [[{?605:183?}]]
}
val.msg.out_selection_call_book = {
[val.ret.wrong] = [[{?605:955?}]]
}
val.msg.out_selection_unknown = {
[val.ret.wrong] = [[{?605:103?}]]
}
val.msg.num_error = {
[val.ret.empty] = [[{?605:974?}]],
[val.ret.outofrange] = [[{?605:836?}]]
}
if (next(box.post) and (box.post.apply)) then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
local saveset={}
local mode=box.post.mode
if box.post.is_new=="true" then
mode=box.post.mode_new
if (box.post.mode_new=="call_to" and string.find((box.post.call_to_sel or ""),"FON")) then
mode="call_to_fon"
end
end
local number=""
if (box.post.is_new=="true") then
if (mode=="call_to") then
number=box.post.call_to_sel
elseif (mode=="call_to_fon") then
number=box.post.call_to_sel
elseif (mode=="call_book") then
number=get_num_from_book(box.post.fonbook_entry)
elseif (mode=="all") then
number="*"
elseif (mode=="call_from") then
number=box.post.num_from
elseif (mode=="unknown") then
number=box.post.unknown_num
if (number=="*") then
number=""
end
if (string.find(number,"SIP")) then
local telcfgid=string.gsub(number,"SIP","")
local elem=fon_numbers.find_elem_in_list_by_telcfgid(g_data.siplist,telcfgid)
if (elem) then
--number=elem.number
number=elem.msnnum
end
elseif (string.find(number,"POTS")) then
number = g_data.pots.numbers[1].msnnum
else
local id=tonumber(number) or -1
local elem=g_data.msnlist.numbers[id+1]
if (elem) then
--number=elem.number
number=elem.msnnum
end
end
if number~="" then
number="#"..number
end
end
else
number=box.post.caller_id
end
local dest=box.post.num_dest
if box.post.destination=="tam" then
dest=box.post.tam_dest
end
if (box.post.num_out=="*" or box.post.destination=="tam") then
box.post.num_out=""
end
local val=number
local key="caller_id"
if (box.post.uid and box.post.uid~="") then
val=box.post.uid
key="uid"
end
local found,elem=fon_numbers.find_rul(g_data.rul_list,key,val)
local id=[[]]
if (elem) then
id=fon_numbers.create_id(elem)
end
if box.post.is_new=="true" and found then
local _,idx_tab=fon_numbers.find_all_ruls(g_data.rul_list,"caller_id",number)
for i,k in ipairs(idx_tab)do
cmtable.add_var( saveset, k ,"0")
end
end
if box.post.is_new=="true" then
id=[[telcfg:settings/]]
local newid=box.query("telcfg:settings/CallerIDActions/newid")
if (mode=="call_to") then
newid=box.query("telcfg:settings/Diversity/newid")
elseif (mode=="call_to_fon") then
local PortNr=box.post.call_to_sel
PortNr=(tonumber(string.gsub(PortNr,"FON",""),10) or 1)-1
newid=[[MSN/Port]]..tostring(PortNr)
end
id=id..newid..[[/]]
end
if (mode=="call_to") then
cmtable.add_var( saveset, id.."MSN" ,number)
cmtable.add_var( saveset, id.."Action" ,box.post.type_action or "0")
cmtable.add_var( saveset, id.."Active" ,"1")
cmtable.add_var( saveset, id.."Outgoing" ,box.post.num_out)
cmtable.add_var( saveset, id.."Destination" ,dest)
elseif (mode=="call_to_fon") then
if box.post.destination=="tam" then
cmtable.add_var( saveset,id.."Diversion","1")
else
cmtable.add_var( saveset,id.."Diversion",box.post.type_diversion)
end
cmtable.add_var( saveset,id.."DiversionNumber",dest)
elseif (mode=="all") then
cmtable.add_var( saveset, id.."Active" , "1")
cmtable.add_var( saveset, id.."CallerID" , number)
cmtable.add_var( saveset, id.."Action" , "0")
cmtable.add_var( saveset, id.."Destination", dest)
cmtable.add_var( saveset, id.."Outgoing" , box.post.num_out)
elseif (mode=="call_book") then
cmtable.add_var( saveset, id.."Active" , "1")
cmtable.add_var( saveset, id.."CallerID" , number)
cmtable.add_var( saveset, id.."Action" , "0")
cmtable.add_var( saveset, id.."Destination", dest)
cmtable.add_var( saveset, id.."Outgoing" , box.post.num_out)
elseif (mode=="call_from") then
cmtable.add_var( saveset, id.."Active" , "1")
cmtable.add_var( saveset, id.."CallerID" , number)
cmtable.add_var( saveset, id.."Action" , "0")
cmtable.add_var( saveset, id.."Destination", dest)
cmtable.add_var( saveset, id.."Outgoing" , box.post.num_out)
elseif (mode=="unknown") then
cmtable.add_var( saveset, id.."Active" , "1")
cmtable.add_var( saveset, id.."CallerID" , number)
cmtable.add_var( saveset, id.."Action" , "0")
cmtable.add_var( saveset, id.."Destination", dest)
cmtable.add_var( saveset, id.."Outgoing" , box.post.num_out)
end
if (g_errmsg=="") then
local err, msg = box.set_config( saveset)
if err == 0 then
http.redirect([[/fon_num/rul_list.lua]])
else
g_errmsg=general.create_error_div(err,msg)
end
end
if (g_errmsg~="") then
read_data()
end
end
end
function write_mode()
box.out(g_data.mode)
end
function get_numbers(num_to_select,restriction)
local str=""
local list=fon_numbers.get_list_of_numbers(g_data,restriction)
if list then
str=str..[[<option value="tochoose">{?txtPleaseSelect?}</option>]]
for i,elem in ipairs(list) do
str=str..[[<option value="]]..elem.val..[["]]
if (num_to_select==elem.val) then
str=str..[[ selected ]]
end
str=str..[[>]]..box.tohtml(elem.key)..[[</option>]]
end
end
return str
end
function write_numbers()
local str=""
if g_data.new then
str=get_numbers(nil,'FON')
else
str=get_numbers(nil,'auto')
end
box.out(str)
end
function write_unknown_caller()
local str=get_numbers(nil,'all_nums')
box.out(str)
end
function write_num_out()
local str=""
local num="*"
if (g_data.cur_rul) then
num=g_data.cur_rul.num_out
end
if (num=="") then
num="*"
end
if g_data.mode=="call_from" or g_data.mode=="call_book" or g_data.mode=="unknown" or g_data.mode=="call_to" then
str=get_numbers(num,'auto')
else
if g_data.new then
str=get_numbers("*",'auto')
else
str=get_numbers(num,'auto')
end
end
box.out(str)
end
function is_fon_num(number)
local pattern=val.pr.fonnum.pat
if not(string.find(number, pattern)) then
return false
end
return true
end
function get_num_table()
local nums={}
for i, entry in ipairs(g_data.fonbook) do
if entry.numbers then
for k, num in ipairs(entry.numbers) do
if num.type ~= "intern" and is_fon_num(num.number) then
local value = entry.uid .. "_" .. num.id
nums[value]={}
nums[value].node=value
nums[value].num=num.number or ""
end
end
end
end
return nums
end
function write_fonbook(selected_uid)
for i, entry in ipairs(g_data.fonbook) do
if entry.numbers then
for k, num in ipairs(entry.numbers) do
if num.type ~= "intern" and is_fon_num(num.number) then
local nn=entry.name or ""
local display = table.concat({
nn, fon_book.type_shortdisplay(num.type), num.number
}, ", ")
local value = entry.uid .. "_" .. num.id
local selected = selected_uid == value and [[ selected]] or ""
local option = [[<option value="%1"%2>%3</option>]]
option = general.sprintf(option, box.tohtml(value), selected, box.tohtml(display))
box.out(option)
end
end
end
end
end
function get_uid_from_num(find_num)
for i, entry in ipairs(g_data.fonbook) do
if entry.numbers then
for k, num in ipairs(entry.numbers) do
if num.number==find_num then
return entry.uid.."_"..num.id
end
end
end
end
return nil
end
function write_fonbook_select()
local selected_uid = "tochoose"
if box.post.FonbookEntry and box.post.FonbookEntry ~= "" then
selected_uid = box.post.FonbookEntry
end
box.out([[<select id="uiViewFonbookEntries" name="fonbook_entry" disabled>]])
box.out([[<option value="tochoose">{?txtPleaseSelect?}</option>]])
write_fonbook(selected_uid)
box.out([[</select>]])
end
function write_fon_option()
local str=""
local action = "1"
if (g_data.cur_rul and g_data.cur_rul.action) then
action=g_data.cur_rul.action
end
for i=0,7 do
str=str..[[<option value="]]..tostring(i)..[["]]
if (action==tostring(i)) then
str=str..[[ selected ]]
end
str=str..[[>]]..box.tohtml(fon_numbers.get_port_txt(tostring(i)))..[[</option>]]
end
box.out(str)
end
function write_msn_option()
local str=""
local action = "0"
if (g_data.cur_rul and g_data.cur_rul.action) then
action=g_data.cur_rul.action
end
for i=0,4 do
str=str..[[<option value="]]..tostring(i)..[["]]
if (action==tostring(i)) then
str=str..[[ selected ]]
end
str=str..[[>]]..box.tohtml(fon_numbers.get_rul_txt(tostring(i)))..[[</option>]]
end
box.out(str)
end
function write_tam()
require ("fon_devices")
local tamlist=fon_devices.read_tam()
local str=""
for i, elem in ipairs(tamlist) do
local num="60"..tostring(elem.idx)
str=str..[[<option value="]]..num..[["]]
if (g_data.cur_rul and g_data.cur_rul.number==num) then
str=str..[[ selected ]]
end
str=str..[[>]]..box.tohtml(elem.name)..[[</option>]]
end
box.out(str)
end
function write_num_dest_checked(dest_type)
local cur_type="phone"
if g_data.cur_rul then
num=g_data.cur_rul.num_dest
if fon_numbers.is_num_of_tam(num) then
cur_type="tam"
end
end
if dest_type== cur_type then
box.out([[checked="checked"]])
elseif dest_type== cur_type then
box.out([[checked="checked"]])
end
end
function write_num_dest_select()
box.out([[<select id ="uiViewNumSel" size="1" name="num_dest_sel" onchange="OnChangeDestNum(this)" >]])
box.out([[<option value="new_num">{?605:458?}</option>]])
local selected_uid=""
if g_data.cur_rul then
selected_uid=get_uid_from_num(g_data.cur_rul.num_dest)
end
write_fonbook(selected_uid)
box.out([[</select>]])
end
function write_num_dest()
local num=""
if g_data.cur_rul then
num=g_data.cur_rul.num_dest
if fon_numbers.is_num_of_tam(num) then
return
end
end
box.out(num)
end
function write_all_incoming()
if not g_data.is_germany or not g_data.mode=="all" then
box.out([[display:none;]])
end
end
function fon_display()
if g_data.new or not g_data.cur_rul then
return ""
end
if g_data.cur_rul.type == "port" then
return g_data.cur_rul.name
elseif g_data.cur_rul.type == "rul" then
if (g_data.cur_rul.caller_id~="") then
return fon_numbers.get_num_txt(g_data,g_data.cur_rul.caller_id)
else
return g_txtMSN
end
end
return ""
end
function del_hash(num)
if string.find(num,"#")==1 then
return string.gsub(num,"#","")
end
return num
end
function get_display_out(num)
return fon_numbers.get_num_txt(g_data, num)
end
function write_rule_type()
local rul_type=""
local rul_ext=""
local rul_head=[[{?605:845?}]]
if (g_data.mode=="all") then
rul_type=[[{?605:61?}]]
rul_head=""
elseif g_data.mode=="call_to" or g_data.mode=="call_to_fon" then
rul_type=[[{?605:798?}]]
rul_ext=fon_display()
elseif g_data.mode=="call_book" then
rul_type=[[{?605:924?}]]
rul_ext=[[{?txtTelefonbuch?}]]
if (g_data.cur_rul and g_data.cur_rul.caller_id~="") then
rul_ext=del_hash(g_data.cur_rul.caller_id)
rul_ext=get_display_out(rul_ext)
if (g_data.fonbook_contact and g_data.fonbook_contact~="") then
rul_ext=rul_ext..[[ (]]..box.tohtml(g_data.fonbook_contact)..[[)]]
end
end
elseif g_data.mode=="call_from" then
rul_type=[[{?605:39?}]]
rul_ext=[[{?txtRufnummer?}]]
if (g_data.cur_rul and g_data.cur_rul.caller_id~="") then
rul_ext=del_hash(g_data.cur_rul.caller_id)
rul_ext=get_display_out(rul_ext)
end
elseif g_data.mode=="unknown" then
rul_type=[[{?605:841?}]]
rul_ext=g_txtMSN
if (g_data.cur_rul and g_data.cur_rul.caller_id~="") then
rul_ext=del_hash(g_data.cur_rul.caller_id)
rul_ext=get_display_out(rul_ext)
else
rul_ext=[[{?605:308?}]]
end
end
if rul_head~="" then
box.out([[<p>]]) box.html(rul_head) box.out([[</p>]])
end
box.out([[<p><span class="hintMsg left_one">]]..rul_type..[[</span>]])
if rul_ext~="" then
box.out([[<span class="hintMsg">]]..rul_ext..[[</span>]])
end
box.out([[</p>]])
end
function write_num_out_visible()
if g_data.mode=="call_to_fon" then
box.out([[display:none;]])
end
end
function write_type_visible(_type)
local hide=true
if (_type=="msn") then
hide=g_data.mode=="call_to_fon"
elseif (_type=="fon") then
hide=g_data.mode~="call_to_fon"
end
if (hide) then
box.out([[display:none;]])
end
end
function write_book_visible()
if (g_data.cur_rul and not (g_data.mode=="call_book")) then
box.out([[display:none;]])
end
end
function write_tam_visible()
if (config.TAM_MODE==0) then
box.out([[display:none;]])
end
end
function get_tam_active()
require ("fon_devices")
local tamlist=fon_devices.read_tam()
if not tamlist then
return false
end
for i, elem in ipairs(tamlist) do
if elem.active then
return true
end
end
return false
end
function write_no_tam_active()
if (get_tam_active()) then
return
end
box.out([[<div>
<span class="hintMsg">{?605:483?}:</span>
<p>{?605:216?}</p>
</div>]])
end
function write_options()
if (g_data.mode~="call_to_fon") then
write_msn_option()
else
write_fon_option()
end
end
function write_init(id)
if (id=="all" and g_data.is_germany) then
box.out([[checked]])
return
end
if (id=="call_to" and not g_data.is_germany) then
box.out([[checked]])
return
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.NewArea {
<?lua
if not(g_data.new) then
box.out([[display:none;]])
end
?>
}
.only_in_049 {
<?lua
if not(g_data.is_germany) then
box.out([[display:none;]])
end
?>
}
.hideif_fonbookempty {
<?lua
if not g_data.fonbook or #g_data.fonbook == 0 then
box.out([[display:none;]])
end
?>
}
.EditArea {
<?lua
if (g_data.new) then
box.out([[display:none;]])
end
?>
}
.Common {
}
.NewArea .formular label,
.EditArea .formular label,
.Common .formular label
{
width:297px;
margin-left:0px;
}
.NewArea label,
.EditArea label,
.Common label{
width:300px;
margin-right:6px;
margin-left:5px;
}
.Common input[type=text],
.NewArea input[type=text],
.Common select,
.NewArea select {
width:158px;
}
.left_one {
width:335px;
display:inline-block;
}
.Common .sub_title {
margin-top:10px;
}
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var g_any_tam_active=<?lua box.out(tostring(get_tam_active()))?>;
var is_germany = <?lua box.out(g_data.is_germany)?>;
var g_cur_mode = "<?lua write_mode()?>";
var g_new = <?lua box.out(tostring(g_data.new)) ?>;
var g_numbers = <?lua box.out(js.table(get_num_table())) ?>;
function OnChangeTo (ToNum)
{
var b = ToNum.indexOf("FON") == 0;
jxl.display("uiType_Fon",b);
jxl.disableNode("uiType_Msn",b);
jxl.disableNode("uiOutNum",b);
jxl.display("uiType_Msn",!b);
jxl.disableNode("uiType_Fon",!b);
}
function OnChangeModeNew(cur_mode)
{
var show_viewTo =true;
var show_viewBook =true;
var show_viewNr =true;
var show_viewUnknown=true;
switch (cur_mode)
{
case "all" :
break;
case "call_to":
show_viewTo=false;
break;
case "call_book":
show_viewBook=false;
break;
case "call_from":
show_viewNr=false;
break;
case "unknown":
show_viewUnknown=false;
break;
}
jxl.disableNode("uiViewTo" ,show_viewTo);
jxl.disableNode("uiViewFonbookEntries" ,show_viewBook);
jxl.disableNode("uiViewNr" ,show_viewNr);
jxl.disableNode("uiViewUnknown",show_viewUnknown);
return OnChangeMode(cur_mode);
}
function OnChangeMode(cur_mode)
{
jxl.disableNode("uiTam",!g_any_tam_active);
if (g_any_tam_active && jxl.getChecked("uiDestTam"))
{
jxl.disableNode("uiViewTAM",false);
jxl.disableNode("uiViewDest",true);
jxl.disableNode("uiDestDetails",true);
}
else
{
jxl.disableNode("uiViewTAM",true);
jxl.disableNode("uiViewDest",false);
jxl.disableNode("uiDestDetails",false);
jxl.disableNode("uiType",cur_mode=="all" || cur_mode=="call_from" ||cur_mode=="call_book" || cur_mode=="unknown");
}
}
function OnDestination(TamOrPhone)
{
OnChangeMode(g_cur_mode);
return true;
}
function uiDoOnMainFormSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
return true;
}
function OnChangeDestNum(obj,from_init)
{
jxl.display("uiViewDestRow",obj.value=="new_num");
var num="";
if (obj.value!="new_num")
{
num=g_numbers[obj.value].num;
}
if (!from_init)
jxl.setValue("uiViewDest",num);
}
function init()
{
if (g_new)
{
OnChangeModeNew(g_cur_mode);
}
else
{
OnChangeMode(g_cur_mode);
}
OnChangeDestNum(jxl.get("uiViewNumSel"),true);
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div>
<div class="NewArea">
<p>{?605:597?}</p>
<div class="only_in_049">
<input type="radio" name="mode_new" value="all" id="uiModeAll" onclick="OnChangeModeNew('all')" <?lua write_init('all')?>>&nbsp;<label for="uiModeAll">{?605:877?}</label>
</div>
<div>
<input type="radio" name="mode_new" value="call_to" id="uiModeTo" onclick="OnChangeModeNew('call_to')" <?lua write_init('call_to')?>>&nbsp;<label for="uiModeTo">{?605:792?}</label>
<select size="1" id="uiViewTo" name="call_to_sel" onchange="OnChangeTo(this.value)">
<?lua
write_numbers()
?>
</select>
</div>
<div class="hideif_fonbookempty">
<input type="radio" name="mode_new" value="call_book" id="uiModeBook" onclick="OnChangeModeNew('call_book')">&nbsp;<label for="uiModeBook">{?605:287?}</label>
<?lua
write_fonbook_select()
?>
</div>
<div>
<input type="radio" name="mode_new" value="call_from" id="uiModeNr" onclick="OnChangeModeNew('call_from')">&nbsp;<label for="uiModeNr">{?605:386?}</label>
<input type="text" id="uiViewNr" name="num_from" maxlength="20">
</div>
<div>
<input type="radio" name="mode_new" value="unknown" id="uiModeUnknown" onclick="OnChangeModeNew('unknown')">&nbsp;<label for="uiModeUnknown">{?605:560?}</label>
<select size="1" id="uiViewUnknown" name="unknown_num">
<?lua
write_unknown_caller()
?>
</select>
</div>
</div>
<div class="EditArea">
<?lua
write_rule_type()
?>
</div>
<div class="Common">
<div class="sub_title">{?605:235?}</div>
<div>
<input type="radio" name="destination" value="phone" id="uiDestRuf" onclick="return OnDestination('phone')" <?lua write_num_dest_checked("phone")?>>&nbsp;<label for="uiDestRuf">{?605:953?}</label>
<?lua write_num_dest_select()?>
</div>
<div id="uiDestDetails" class="formular">
<div id="uiViewDestRow">
<label for="uiViewDest">{?605:222?}</label>
<input type="text" id="uiViewDest" name="num_dest" maxlength="20" value="<?lua write_num_dest()?>" >
</div>
<p style="">{?605:234?}</p>
<div id="uiOutNum" style="<?lua write_num_out_visible()?>">
<label for="uiViewUeber">{?605:708?}</label>
<select size="1" id="uiViewUeber" name="num_out">
<?lua
write_num_out()
?>
</select>
</div>
<div id="uiType" >
<div id="uiType_Msn" style="<?lua write_type_visible('msn')?>">
<label for="uiViewOptionMsn">{?605:892?}</label>
<select size="1" name="type_action" id="uiViewOptionMsn">
<?lua
write_msn_option()
?>
</select>
</div>
<div id="uiType_Fon" style="<?lua write_type_visible('fon')?>">
<label for="uiViewOptionFon">{?605:556?}</label>
<select size="1" name="type_diversion" id="uiViewOptionFon">
<?lua
write_fon_option()
?>
</select>
</div>
</div>
</div>
<div id="uiTam" style="<?lua write_tam_visible()?>">
<input type="radio" name="destination" value="tam" id="uiDestTam" onclick="return OnDestination('tam')" <?lua write_num_dest_checked("tam")?>>&nbsp;<label for="uiDestTam">{?605:840?}</label>
<select size="1" id="uiViewTAM" name="tam_dest">
<?lua
write_tam()
?>
</select>
</div>
<div class="formular">
<?lua
write_no_tam_active()
?>
</div>
</div>
<div class="WarnMsg" >
<?lua
if (g_errmsg) then
box.out(g_errmsg)
end
?>
</div>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply" style="">{?txtOk?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="is_new" value="<?lua box.html(tostring(g_data.new)) ?>">
<input type="hidden" name="uid" value="<?lua box.html(tostring(g_data.uid)) ?>">
<input type="hidden" name="caller_id" value="<?lua if (g_data.cur_rul) then box.html(g_data.cur_rul.caller_id) end ?>">
<input type="hidden" name="mode" value="<?lua box.html(g_data.mode) ?>">
<input type="hidden" name="rul_type" value="<?lua if (g_data.cur_rul) then box.html(g_data.cur_rul.type) end?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
