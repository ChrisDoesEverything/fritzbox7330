--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require("general")
require("cmtable")
require("newval")
g_txt_name_hint=TXT([[{?2420:880?}]])
function get_area_for_num(num)
num.okz = tostring(box.query("telcfg:settings/Location/OKZ"))
num.okzprefix = tostring(box.query("telcfg:settings/Location/OKZPrefix"))
num.lkz = tostring(box.query("telcfg:settings/Location/LKZ"))
num.lkzprefix = tostring(box.query("telcfg:settings/Location/LKZPrefix"))
return num
end
function get_selected(value, option)
local out = [[]]
if tostring(value) == tostring(option) then
out = [[selected]]
end
return out
end
function get_hint()
return box.tohtml(g_txt_name_hint)
end
function show_number_input_html()
if not g_num then
return ""
end
function addClass(i)
if i % 2 == 0 then
return [[WhiteBox ]]
else
return [[GrayBox ]]
end
end
local str_out = [[<div id="uiNameExplainTextForTrunk" class="formular titlemark DontShow">]]
str_out=str_out..box.tohtml(TXT([[{?2420:353?}]]))
if g_num.is_expert and not general.is_assi() then
str_out=str_out.." "..box.tohtml(TXT([[{?2420:928?}]]))
end
str_out=str_out..[[</div><!--uiNameExplainTextForTrunk-->]]
str_out = str_out..[[<div id="uiPos1" class="formular titlemark">]]
str_out = str_out..[[<div id="uiNoTrunk" class="TrunkContent" >]]
str_out = str_out..[[<p><span id="uiNumberTitle1_1" class="form_input_note"></span><span id="uiNumberTitle2_1"></span></p>]]
str_out = str_out..[[<p id="uiInput"><label id="uiNumberLabel" for="uiNumberInput1_1"></label><span id="uiNumberFirstSpan_1"></span><input type="text" id="uiNumberInput1_1" name="numberinput1_1" onkeyup="onViewMSN()" value=""><span class="span_middle" id="uiNumberMiddleSpan_1"></span><input type="text" id="uiNumberInput2_1" name="numberinput2_1" value=""></p>]]
str_out = str_out..[[<p><span id="uiNumberFooder" class="form_input_note"></span></p>]]
str_out = str_out..[[<div id="ShowMSN" class="formular" style="display:none;">
<p>]]..box.tohtml(TXT([[{?2420:829?}]]))..[[</p>
<label id="labelMSN" for="uiMSN">]]..box.tohtml(TXT([[{?2420:751?}]]))..[[</label><input type="text" name="msn" id="uiMSN" value="" disabled>
</div><!--ShowMSN-->]]
if g_num.is_expert and not general.is_assi() then
str_out = str_out..[[<p id="uiNameExplainText">]]..get_hint()..[[</p>]]
str_out = str_out..[[<p><label for="uiSipName_1" >]]..box.tohtml(TXT([[{?2420:641?}]]))..[[</label><input type="text" name="sipname_1" id="uiSipName_1" maxlength="16" value=""></p>]]
end
str_out = str_out..[[</div><!--uiNoTrunk-->]]
str_out = str_out..[[<div id="uiTrunkAll" class="titlemark DontShow">]]
str_out = str_out..[[
<table class="zebra">
<tr>
<th id="uiNumberLabel_trunk">TXT({?2420:593?})</th>]]
if g_num.is_expert and not general.is_assi() then
str_out = str_out..[[<th>]]..box.tohtml(TXT([[{?2420:636?}]]))..[[</th>]]
end
str_out = str_out..[[<th>]]..box.tohtml(TXT([[{?2420:621?}]]))..[[</th>
</tr>]]
for i = 1, 20 do
str_out = str_out..[[
<tr id="uiNumberLine_]]..i..[[" class="DontShow">
<td id="]]..i..[["><input type="text" id="uiNumberInput1_trunk_]]..i..[[" name="numberinput1_trunk_]]..i..[[" value=""></td>]]
if g_num.is_expert and not general.is_assi() then
str_out = str_out..[[<td id="]]..i..[["><input type="text" maxlength="16" name="sipname_trunk_]]..i..[[" id="uiSipName_trunk_]]..i..[[" value=""></td>]]
end
str_out = str_out..[[<td id="]]..i..[[">]]
if i ~= 1 then
str_out = str_out..general.get_icon_button([[/css/default/images/loeschen.gif]], [[uiDeletenumber]]..i, [[deletenumber]]..i, "", "", "", false)
end
str_out = str_out..[[</td>
</tr>]]
end
str_out = str_out..[[</table>]]
str_out = str_out..[[<div class="btn_form"><button type="button" id="uiAddnumber" onclick="doAddTrunkNumber()">]]..box.tohtml(TXT([[{?2420:898?}]]))..[[</button></div>]]
str_out = str_out..[[</div><!--uiTrunkAll--></div><!--uiPos1-->]]
local val = ""
for i = 1, #g_num.fondata do
if g_num.fondata[i] then
val = g_num.fondata[i].number
end
str_out = str_out..general.sprintf([[<input type="hidden" value="%1" name="oldnumber_%2">]],val,i)
end
str_out = str_out..general.sprintf([[<input type="hidden" value="%1" name="countoldnumber">]],#g_num.fondata)
return str_out
end
function show_dialdirectin_input_html()
str_out = [[<div id="uiShowDirectDialIn" class="formular titlemark DontShow">]]
str_out = str_out..[[<p><label for="uiSerialNumber">]]..box.tohtml(TXT([[{?2420:698?}]]))..[[</label><input type="text" id="uiSerialNumber" name="serialnumber" value=""></p>]]
str_out = str_out..[[<p><label for="uiCentralPhoneExtension">]]..box.tohtml(TXT([[{?2420:619?}]]))..[[</label><input type="text" id="uiCentralPhoneExtension" name="centralphoneextension" value=""></p>]]
str_out = str_out..[[<p><label for="uiLengthSerialNumber">]]..box.tohtml(TXT([[{?2420:879?}]]))..[[</label>]]
str_out = str_out..[[<select id="uiLengthSerialNumber" name="lengthserialnumber">]]
str_out = str_out..[[<option value="1">]]..box.tohtml(TXT([[{?2420:863?}]]))..[[</option>]]
str_out = str_out..[[<option value="2">]]..box.tohtml(TXT([[{?2420:382?}]]))..[[</option>]]
str_out = str_out..[[<option value="3">]]..box.tohtml(TXT([[{?2420:384?}]]))..[[</option>]]
str_out = str_out..[[<option value="4">]]..box.tohtml(TXT([[{?2420:628?}]]))..[[</option>]]
str_out = str_out..[[<option value="5">]]..box.tohtml(TXT([[{?2420:107?}]]))..[[</option>]]
str_out = str_out..[[<option value="6">]]..box.tohtml(TXT([[{?2420:855?}]]))..[[</option>]]
str_out = str_out..[[<option value="7">]]..box.tohtml(TXT([[{?2420:606?}]]))..[[</option>]]
str_out = str_out..[[<option value="8">]]..box.tohtml(TXT([[{?2420:231?}]]))..[[</option>]]
str_out = str_out..[[<option value="9">]]..box.tohtml(TXT([[{?2420:893?}]]))..[[</option>]]
str_out = str_out..[[</select></p>]]
str_out = str_out..box.tohtml(TXT([[{?2420:876?}]]))
str_out = str_out..[[</div><!--uiShowDirectDialIn-->]]
return str_out
end
function is_trunk()
local trunk = false
if not g_num.new then
trunk = g_num.fondata[1].trunk_id and g_num.fondata[1].trunk_id ~= ""
end
return trunk
end
function isNew()
if g_num.new then
box.out([[<input type="hidden" name="isnew" id="uiIsNew" value="1">]])
else
box.out([[<input type="hidden" name="isnew" id="uiIsNew" value="0">]])
end
end
function is_checked(value)
if value == "1" then
return[[checked="checked"]]
end
return ""
end
function val_prog()
if general.is_assi() or newval.checked("sip_activ") then
local provider_user_interface = sip_providerlist.get_userInterface_from_providerlist(box.post.sipprovider)
local empty_txt = TXT([[{?2420:222?}]])
local char_err_txt = TXT([[{?2420:764?}]])
local only_num_txt = TXT([[{?2420:147?}]])
local errmsg_notrunk = {
emptyNumber = {general.sprintf(empty_txt,provider_user_interface.uiNumberLabel)},
outofrange1 = {general.sprintf(char_err_txt,provider_user_interface.uiNumberLabel)},
outofrange2 = {general.sprintf(only_num_txt,provider_user_interface.uiNumberLabel)}
}
local errmsg_trunk = {
emptyNumber = {general.sprintf(empty_txt,provider_user_interface.uiNumberLabel_trunk_1)},
outofrange1 = {general.sprintf(char_err_txt,provider_user_interface.uiNumberLabel_trunk_1)},
outofrange2 = {general.sprintf(only_num_txt,provider_user_interface.uiNumberLabel_trunk_1)}
}
local errmsg = {
change = {general.sprintf(TXT([[{?2420:754?}]])..[[\n]]..TXT([[{?2420:665?}]]),provider_user_interface.uiLabelPwd)},
emptyError = {general.sprintf(empty_txt,provider_user_interface.uiLabelPwd)},
emptyUsername = {general.sprintf(empty_txt,provider_user_interface.uiLabelUsername)},
emptyRegistrar = {general.sprintf(empty_txt,provider_user_interface.uiRegistrar)}
}
newval.msg.error_notrunk_number1 = {
[newval.ret.outofrange] = errmsg_notrunk.outofrange1,
[newval.ret.empty] = errmsg_notrunk.emptyNumber
}
newval.msg.error_notrunk_number2 = {
[newval.ret.outofrange] = errmsg_notrunk.outofrange2,
[newval.ret.empty] = errmsg_notrunk.emptyNumber
}
newval.msg.error_trunk_number1 = {
[newval.ret.outofrange] = errmsg_notrunk.outofrange1,
[newval.ret.empty] = errmsg_notrunk.emptyNumber
}
newval.msg.empty_username = {
[newval.ret.empty] = errmsg.emptyUsername,
[newval.ret.notfound] = errmsg.emptyUsername
}
newval.msg.empty_password = {
[newval.ret.empty] = errmsg.emptyError
}
newval.msg.error_changedata = {
[newval.ret.wrong] = errmsg.change
}
newval.msg.error_tonline_mail_txt = {
[newval.ret.outofrange] = TXT([[{?2420:835?}]])
}
newval.msg.empty_registrar_txt = {
[newval.ret.empty] = errmsg.emptyRegistrar
}
newval.msg.dropdown_outofrange_txt = {
[newval.ret.outofrange] = TXT([[{?2420:724?}]])
}
local list_dtmfcfg = {"0","1","2","3"}
local list_clirtype = {"0","1","2","4","5","6","7", "8"}
local list_dditype = {"0","1","2","3","4"}
if newval.value_equal("trunk_active","1") then
for i = 1, box.post.counttrunk ,1 do
newval.not_empty("numberinput1_trunk_1", "error_trunk_number1")
if not newval.value_empty("numberinput1_trunk_"..i) then
newval.char_range_regex("numberinput1_trunk_"..i, "fonnumex", "error_trunk_number1")
end
end
elseif newval.value_equal("trunk_active","0") then
if newval.value_equal("separatednumbers", "1") then
newval.not_empty("numberinput1_1", "error_notrunk_number1")
newval.char_range_regex("numberinput1_1", "sipnum", "error_notrunk_number1")
if newval.value_equal("msn_visible","1") then
newval.not_empty("msn", "error_notrunk_number1")
newval.char_range_regex("msn", "decimals", "error_notrunk_number1")
end
end
if newval.value_equal("separatednumbers", "2") then
newval.not_empty("numberinput1_1", "error_notrunk_number1")
newval.char_range_regex("numberinput1_1", "fonnumex", "error_notrunk_number1")
newval.not_empty("numberinput2_1", "error_notrunk_number2")
newval.char_range_regex("numberinput2_1", "fonnumex", "error_notrunk_number1")
end
end
if newval.value_equal("isusername","1") then
newval.not_empty("username", "empty_username")
newval.not_empty("pwd", "empty_password")
elseif newval.value_equal("isusername","2") and box.post.tcom_activ then
newval.char_range_regex("username", "email", "error_tonline_mail_txt")
elseif newval.value_equal("isregistrar","1") then
newval.not_empty("registrar", "empty_registrar_txt")
end
if box.post.dtmfcfg then
newval.is_in_list("dtmfcfg",list_dtmfcfg,"dropdown_outofrange_txt")
end
if box.post.clirtype then
newval.is_in_list("clirtype",list_clirtype,"dropdown_outofrange_txt")
end
if box.post.dditype then
newval.is_in_list("dditype",list_dditype,"dropdown_outofrange_txt")
end
end
end
function save_sip_data()
local ctlmgr_save={}
local webui_trunk_id = ""
local errmsg=""
local provider=""
if isp.show_1und1_select() then
if box.post.sipprovider_ui=="other_non_ui" then
provider=box.post.sipprovider or g_num.fondata[1].provider_id
else
provider=box.post.sipprovider_ui or g_num.fondata[1].provider_id
end
else
provider=box.post.sipprovider or g_num.fondata[1].provider_id
end
provider=box.tohtml(provider)
if (not g_provider_list[provider]) then
provider="other"
end
local cur_provider_details = g_provider_list[provider].dataValues.details
local cur_provider_telcfg = g_provider_list[provider].dataValues.telcfg
local cur_provider_display = g_provider_list[provider].display
local num1=""
local num2=""
function clearWhiteSpace(value)
return string.gsub(value, "%s+", "")
end
function createNumber(value, zero)
if not value then
return ""
end
value = clearWhiteSpace(value)
if string.len(value) == 0 then
return value
else
if zero then
if string.sub(value, 1 , 1) == "0" then
return value
else
return "0"..value
end
else
if string.find(value, "00") == 1 then
return string.sub(value,3)
elseif string.find(value, "0") == 1 then
return string.sub(value,2)
else
return value
end
end
end
end
function getPhoneNumber()
local str_number = ""
if provider == "1und1" or provider == "gmx" then
str_number = num2
elseif provider == "qsc" or provider == "arcor" or provider == "vodafone_lte" then
str_number = createNumber(num1,true)..num2
elseif provider == "tonline" then
str_number = num1..num2
elseif provider == "sipkom" then
require("sip_providerlist")
local prefix=sip_providerlist.get_one_value_from_providerlist("uiNumberFirstSpan", provider, "userInterface")
str_number = prefix..createNumber(num1,false)
elseif provider == "easybell" then
require("sip_providerlist")
local prefix=sip_providerlist.get_one_value_from_providerlist("uiNumberFirstSpan", provider, "userInterface")
if string.find(num1, prefix) == 1 then
str_number = num1
else
str_number =prefix..num1
end
else
str_number = num1
end
return str_number
end
function congstar_by_qsc()
local pppoe = box.query("connection0:pppoe:settings/username")
return string.find(pppoe, "ip/") == 1 or string.find(pppoe, "dsl/") == 1
end
function get_proxy()
local str_proxy = ""
if provider == "arcor" or provider == "vodafone_lte" then
str_proxy = createNumber(num1,true)..[[.]]..cur_provider_details.outboundproxy
return str_proxy
end
if cur_provider_display.ShowProxy then
if string.len(box.post.outboundproxy) ~= 0 then
return box.post.outboundproxy
end
end
if g_provider_list[provider].is_a_copy then
return g_provider_list.other.dataValues.details.outboundproxy
end
return cur_provider_details.outboundproxy
end
function get_registrar()
if cur_provider_display.ShowRegistrar then
if string.len(box.post.registrar) ~= 0 then
return box.post.registrar
end
end
if provider == "congstar" then
return cur_provider_details.registrar[1]
end
if provider == "1und1" then
if (type(g_num.fondata[1].dataValues.details.registrar)=="string") then
if string.find(g_num.fondata[1].dataValues.details.registrar,"1und1") then
return g_num.fondata[1].dataValues.details.registrar
end
end
end
return cur_provider_details.registrar[1]
end
function get_stun()
if cur_provider_display.ShowStun then
return box.post.stunserver
end
if provider == "1und1" then
if g_num.fondata[1].dataValues.details.stunserver and g_num.fondata[1].dataValues.details.stunserver ~="" and string.find(g_num.fondata[1].dataValues.details.stunserver, "1und1") then
return g_num.fondata[1].dataValues.details.stunserver
end
end
return cur_provider_details.stunserver
end
function get_msn()
if (not fon_numbers.is_trunkmode(g_provider_list[provider].mode)) then
if (box.post.msn and box.post.msn_visible=="1") then
return fon_numbers.get_only_number(box.post.msn)
end
end
if provider == "sipkom" then
return fon_numbers.get_only_number("49"..createNumber(num1,false))
end
if provider == "1und1" or provider == "gmx" or provider == "qsc" or provider == "tonline" or provider == "arcor" or provider == "vodafone_lte" then
return fon_numbers.get_only_number(num2)
end
if (num2~="")then
return fon_numbers.get_only_number(num2)
end
return fon_numbers.get_only_number(num1)
end
function get_username()
if provider == "dus" then
if string.find(box.post.username, "000387") == 1 then
return box.post.username
else
return "000387"..box.post.username
end
elseif provider == "tonline" then
if not box.post.tcom_activ then
return "anonymous@t-online.de"
end
elseif provider == "arcor" or provider == "vodafone_lte" then
return createNumber(num1,true)..num2
elseif provider == "1und1" or provider == "gmx" then
return "49"..createNumber(num1,false)..num2
elseif provider == "sipkom" then
return "49"..createNumber(num1,false)
elseif provider == "qsc" then
return createNumber(num1,true)..num2
elseif provider == "xs4all" or provider == "scarlet" or provider == "inode" then
return num1
end
return box.post.username
end
function get_okz()
if provider == "1und1" or provider == "gmx" or provider == "qsc" or provider == "tonline" then
return createNumber(num1,false)
end
if box.post.okz then
if string.sub(box.post.okz, 1 , 1) == "0" then
box.post.okz=string.sub(box.post.okz,2)
end
end
return box.post.okz or ""
end
function replace_num_in_fondevices(ctlmgr_save, OldRufNr, NewRufNr)
for i = 0, 9, 1 do
if (OldRufNr == box.query("tam:settings/MSN"..i)) then
cmtable.add_var(ctlmgr_save, "tam:settings/MSN"..i, NewRufNr)
end
if (OldRufNr == box.query("telcfg:settings/FaxMSN"..i)) then
cmtable.add_var(ctlmgr_save, "telcfg:settings/FaxMSN"..i, NewRufNr)
end
end
for i = 1, 8, 1 do
if (OldRufNr == box.query("telcfg:settings/NTHotDialList/Number"..i)) then
cmtable.add_var(ctlmgr_save, "telcfg:settings/NTHotDialList/Number"..i, NewRufNr)
end
end
return ctlmgr_save;
end
function reset_fallback(ctlmgr_save)
for i = 0, 19, 1 do
cmtable.add_var(ctlmgr_save, "telcfg:settings/SIP"..i.."/Fallback", "0")
end
end
function saveData(index, k)
local id, telcfg_id, telcfg = "", "", ""
if not g_num.fondata[index] then
id, telcfg_id = fon_numbers.new_SipNode()
telcfg = [[SIP]]..telcfg_id
else
if g_num.fondata and g_num.fondata[index].id~="" then
if g_num.fondata[index].telcfg_id ~= "" then
id, telcfg = g_num.fondata[index].id, [[SIP]]..g_num.fondata[index].telcfg_id
else
id, telcfg = g_num.fondata[index].id, fon_numbers.new_Telcfg()
end
else
return 1, TXT([[{?2420:914?}]])
end
end
ctlmgr_save={}
if box.post.sip_activ or box.post.isnew == "1"then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/activated", "1")
local phonenumber = getPhoneNumber()
local sipname = box.post['sipname_'..k] or ""
if g_num.is_expert and not general.is_assi() then
if fon_numbers.is_trunkmode(g_provider_list[provider].mode) then
sipname = box.post['sipname_trunk_'..k] or ""
end
cmtable.add_var(ctlmgr_save,"telcfg:settings/"..telcfg.."/Name", sipname)
end
if box.post.isnew == "0" then
if g_num.fondata[index] and phonenumber == g_num.fondata[index].number then
ctlmgr_save = fon_numbers.replaceNumbers(ctlmgr_save, g_num.fondata[index].number, get_msn())
ctlmgr_save = replace_num_in_fondevices(ctlmgr_save, g_num.fondata[index].number, get_msn())
end
end
if config.CONFIG_SRTP == "1" then
if box.post.srtp_supported then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/srtp_supported", "1")
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/srtp_supported", "0")
end
end
if box.query("telcfg:settings/MSN/NTDefault") == "" then
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/NTDefault", telcfg)
end
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/displayname", phonenumber)
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/outboundproxy", get_proxy())
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/registrar", get_registrar())
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/stunserver",get_stun())
local idx, e = array.find(ctlmgr_save, func.eq("telcfg:settings/"..telcfg.."/MSN", "name"))
if (not idx) then
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/MSN", get_msn())
end
if config.LTE then
function is_isp_equal_sip(sip_provider)
require"isp"
isp_provider=isp.activeprovider()
if sip_provider=="1und1" and isp_provider=="1und1_lte" then return true end
if sip_provider=="vodafone_lte" and isp.is("vodafone_lte") then return true end
return false
end
if (cur_provider_details.multi_pdn==[[1]] and is_isp_equal_sip(provider)) then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/use_seperate_vcc", cur_provider_details.seperate_vcc)
cmtable.add_var(ctlmgr_save, "connection_voip:settings/VCI", cur_provider_details.VCI)
cmtable.add_var(ctlmgr_save, "connection_voip:settings/encapsulation", cur_provider_details.encapsulation)
cmtable.add_var(ctlmgr_save, "lted:settings/hw_info/ue/multi_pdn", cur_provider_details.multi_pdn)
cmtable.add_var(ctlmgr_save, "lted:settings/hw_info/ue/apn1", cur_provider_details.apn1)
end
end
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/username", get_username())
if provider == "tonline" and not box.post.tcom_activ then
box.post.pwd=""
end
if cur_provider_display.ShowPassword then
if box.post.pwd ~= "****" then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/password", box.post.pwd)
end
end
if cur_provider_display.ShowSipUri then
if box.post.authname_needed then
cmtable.add_var(ctlmgr_save,"sip:settings/"..id.."/authname_needed", "1")
else
cmtable.add_var(ctlmgr_save,"sip:settings/"..id.."/authname_needed", "0")
end
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/authname_needed", cur_provider_details.authname_needed)
end
if cur_provider_display.ShowEmergency then
if box.post.emergencyrule then
cmtable.add_var(ctlmgr_save,"telcfg:settings/"..telcfg.."/EmergencyRule", "1")
else
cmtable.add_var(ctlmgr_save,"telcfg:settings/"..telcfg.."/EmergencyRule", "0")
end
else
cmtable.add_var(ctlmgr_save,"telcfg:settings/"..telcfg.."/EmergencyRule", cur_provider_telcfg.EmergencyRule)
end
if cur_provider_display.ShowSipAKN then
if box.post.akn then
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/AKN", "1")
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/AKN", "0")
end
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/AKN", cur_provider_telcfg.AKN)
end
if cur_provider_display.ShowDtmf and box.post.dtmfcfg then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/dtmfcfg", box.post.dtmfcfg)
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/dtmfcfg", cur_provider_details.dtmfcfg)
end
if cur_provider_display.ShowClir and box.post.clirtype then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/clirtype", box.post.clirtype)
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/clirtype", cur_provider_details.clirtype)
end
if cur_provider_display.ShowDditype and box.post.dditype then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/dditype", box.post.dditype)
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/dditype", cur_provider_details.dditype)
end
if cur_provider_display.ShowOverInternet then
if box.post.route_always_over_internet then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/route_always_over_internet", "1")
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/route_always_over_internet", "0")
end
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/route_always_over_internet", cur_provider_details.route_always_over_internet)
end
if cur_provider_display.ShowIp and box.post.prefer then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/protocolprefer", box.post.prefer)
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/protocolprefer", cur_provider_details.protocolprefer)
end
cmtable.add_var(ctlmgr_save, "settings/"..id.."/outboundproxy_without_route_header",cur_provider_details.outboundproxy_without_route_header)
cmtable.add_var(ctlmgr_save, "settings/"..id.."/read_p_asserted_identity_header", cur_provider_details.read_p_asserted_identity_header)
if (g_provider_list[provider]['packetization'] and g_provider_list[provider]['packetization']~="") then
cmtable.add_var(ctlmgr_save, "settings/"..id.."/packetization", g_provider_list[provider]['packetization'])
end
if g_num.okz=="" and g_num.is_assi then
cmtable.add_var(ctlmgr_save, "telcfg:settings/Location/OKZ", get_okz())
end
if provider == "unitymedia" then
reset_fallback(ctlmgr_save)
elseif provider == "inode" then
reset_fallback(ctlmgr_save)
elseif provider == "inodeisdn" then
reset_fallback(ctlmgr_save)
if config.T38 then
cmtable.add_var(ctlmgr_save, "ssipextra:settings/sip/t38_support_enabled", "0")
end
cmtable.add_var(ctlmgr_save,"sipextra:settings/sip/dyn_codec", "1")
cmtable.add_var(ctlmgr_save,"sipextra:settings/sip/prio_low_codec", "0")
end
if cur_provider_display.ShowExp or cur_provider_display.ShowOKZ then
local str_useokz = cur_provider_telcfg.UseOKZ
local str_useokzprefix = cur_provider_telcfg.KeepOKZPrefix
local str_uselkz = cur_provider_telcfg.UseLKZ
local str_uselkzprefix = cur_provider_telcfg.KeepLKZPrefix
if box.post.okz == "0" then
str_useokz = "0"
str_useokzprefix = "1"
elseif box.post.okz == "1" then
str_useokz = "1"
str_useokzprefix = "0"
elseif box.post.okz == "2" or (box.post.useokzprovider and cur_provider_display.ShowOKZ) then
str_useokz = "1"
str_useokzprefix = "1"
end
if box.post.lkz == "0" then
str_uselkz = "0"
str_uselkzprefix = "1"
elseif box.post.lkz == "1" then
str_uselkz = "1"
str_uselkzprefix = "0"
elseif box.post.lkz == "2" then
str_uselkz = "1"
str_uselkzprefix = "1"
else
str_uselkzprefix = "1"
end
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/UseOKZ", str_useokz)
if cur_provider_display.ShowExp or general.is_assi() then
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/UseLKZ", str_uselkz)
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/KeepOKZPrefix", str_useokzprefix)
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/KeepLKZPrefix", str_uselkzprefix)
end
else
if general.is_assi() then
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/UseOKZ",cur_provider_telcfg.UseOKZ)
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/UseLKZ", cur_provider_telcfg.UseLKZ)
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/KeepOKZPrefix", cur_provider_telcfg.KeepOKZPrefix)
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/KeepLKZPrefix", cur_provider_telcfg.KeepLKZPrefix)
end
end
if cur_provider_display.ShowAlternatePrefix_USA then
if box.post.alternateprefix then
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/AlternatePrefix", "011")
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/AlternatePrefix", "")
end
end
if cur_provider_display.ShowSuffixBlock then
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/Suffix", box.post.Suffix or [[]])
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/"..telcfg.."/Suffix", cur_provider_telcfg.Suffix)
end
if cur_provider_display.ShowG726NACHRFC3551 then
if box.post.g726_via_3551rfc then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/g726_via_3551rfc", "1")
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/g726_via_3551rfc", "0")
end
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/g726_via_3551rfc", cur_provider_details.g726_via_3551rfc)
end
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/clipnstype", cur_provider_details.clipnstype)
if cur_provider_display.ShowCCBS then
if box.post.ccbs_supported then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/ccbs_supported", "1")
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/ccbs_supported", "0")
end
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/ccbs_supported", cur_provider_details.ccbs_supported)
end
if cur_provider_display.ShowPacketsize then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/tx_packetsize_in_ms", box.post.tx_packetsize_in_ms)
elseif provider == "kdg" or provider == "dus" or config.sip_packetsize then
cmtable.add_var(ctlmgr_save,"sip:settings/"..id.."/tx_packetsize_in_ms", "20")
else
cmtable.add_var(ctlmgr_save,"sip:settings/"..id.."/tx_packetsize_in_ms", "30")
end
cmtable.add_var(ctlmgr_save,"telcfg:settings/"..telcfg.."/RegistryType", cur_provider_telcfg.RegistryType)
if cur_provider_display.ShowOnlycallfromregistrar then
if box.post.only_call_from_registrar then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/only_call_from_registrar", "1")
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/only_call_from_registrar", "0")
end
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/only_call_from_registrar", cur_provider_details.only_call_from_registrar)
end
if string.find(g_provider_list[provider]["id"], "unknown_") == 1 then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/providername", g_provider_list[provider].name)
end
if cur_provider_display.ShowDonotregister then
if box.post.do_not_register then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/do_not_register", "1")
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/do_not_register", "0")
end
else
if (fon_numbers.is_trunkmode(g_provider_list[provider].mode) ) and index == 1 then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/do_not_register", "0")
else
if (fon_numbers.is_trunkmode(g_provider_list[provider].mode) ) then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/do_not_register", "1")
end
end
end
if cur_provider_display.ShowUseinternatcallingnumbe then
if box.post.use_internat_calling_numb then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/use_internat_calling_numb", "1")
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/use_internat_calling_numb", "0")
end
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/use_internat_calling_numb", cur_provider_details.use_internat_calling_numb)
end
if (fon_numbers.is_trunkmode(g_provider_list[provider].mode) ) and index == 1 then
if g_provider_list[provider]["mode"] == "directdialin" then
webui_trunk_id= "direct:"..id
if box.post.lengthserialnumber then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/ExtensionLength", box.post.lengthserialnumber)
end
if box.post.centralphoneextension then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/Reception", box.post.centralphoneextension)
end
else
webui_trunk_id=id
end
end
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/webui_trunk_id", webui_trunk_id)
if fon_numbers.is_trunkmode(g_provider_list[provider].mode) then
if g_provider_list[provider]["mode"] == "directdialin" and index == 1 then
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/Trunk", createNumber(box.post.serialnumber,false))
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/Trunk", createNumber(phonenumber,false))
end
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/Trunk", "")
end
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..id.."/activated", "0")
end
return box.set_config(ctlmgr_save)
end
local err, msg, id, tlcfg = 0,"", "",""
local max_count=tonumber(box.post.counttrunk) or 0
if ONLY_SIP_NAME then
local sipname = ""
if fon_numbers.is_trunkmode(g_provider_list[provider].mode) then
for i = 1, max_count ,1 do
sipname = box.post['sipname_trunk_'..tostring(i)] or ""
cmtable.add_var(ctlmgr_save,"telcfg:settings/SIP"..g_num.fondata[i].telcfg_id.."/Name", sipname)
end
else
sipname = box.post['sipname_1'] or ""
cmtable.add_var(ctlmgr_save,"telcfg:settings/SIP"..g_num.fondata[1].telcfg_id.."/Name", sipname)
if box.post.msn_visible=="1" then
cmtable.add_var(ctlmgr_save,"telcfg:settings/SIP"..g_num.fondata[1].telcfg_id.."/MSN", get_msn())
end
end
err,msg=box.set_config(ctlmgr_save)
else
if fon_numbers.is_trunkmode(g_provider_list[provider].mode) then
local delCount = #g_num.fondata - max_count
if delCount > 0 then
for i = #g_num.fondata, max_count+1, -1 do
err,msg = fon_numbers.del_number_by_UID(g_num.fondata[i].uid)
end
end
end
local post_num_1='numberinput1_'
local post_num_2='numberinput2_'
if fon_numbers.is_trunkmode(g_provider_list[provider].mode) then
post_num_1='numberinput1_trunk_'
post_num_2='numberinput2_trunk_'
end
local start = 1
if g_provider_list[provider].mode == "directdialin" then
num1 = box.post.serialnumber..box.post.centralphoneextension
num2 = ""
start = 2
max_count=max_count+1
err,msg = saveData( 1, 1)
end
local k=1
if not fon_numbers.is_trunkmode(g_provider_list[provider].mode) then
max_count = 1
end
for i = start, max_count ,1 do
num1=box.post[post_num_1..k] or ""
num2=box.post[post_num_2..k] or ""
err,msg = saveData( i, k)
k=k+1
if err ~= 0 then
break
end
end
end
return err,msg
end
