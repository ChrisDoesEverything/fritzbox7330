<?lua
g_page_type = "all"
g_page_title = "{?9038:670?}"
g_page_help = "hilfe_internet_prio_neues-protokoll.html"
g_menu_active_page = "/internet/trafficappl.lua"
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("general")
require("cmtable")
g_remoteData = {}
function read_box_values()
local table_index = "get"
if (box.post.appl_id) then
table_index = "post"
end
g_remoteData.appl_id=""
if (box[table_index] and box[table_index].appl_id) then
g_remoteData.appl_id=box[table_index].appl_id
end
g_remoteData.rule_id = box[table_index].rule_id
g_remoteData.is_new = g_remoteData.rule_id == nil or g_remoteData.rule_id == "" or g_remoteData.rule_id == "xxx"
if g_remoteData.is_new then
g_remoteData.rule_id=box.query("netapp:settings/"..g_remoteData.appl_id.."/rules0/entry/newid")
g_remoteData.protocol = "TCP"
g_remoteData.port_src = "any"
g_remoteData.srcport = "0"
g_remoteData.srcstartport = ""
g_remoteData.srcendport = "0"
g_remoteData.port_dst = "any"
g_remoteData.dstport = "0"
g_remoteData.dststartport = ""
g_remoteData.dstendport = "0"
else
g_remoteData.protocol = box.query("netapp:settings/"..g_remoteData.appl_id.."/rules0/"..g_remoteData.rule_id.."/protocol")
g_remoteData.srcport = box.query("netapp:settings/"..g_remoteData.appl_id.."/rules0/"..g_remoteData.rule_id.."/srcport")
g_remoteData.srcstartport = g_remoteData.srcport
g_remoteData.srcendport = box.query("netapp:settings/"..g_remoteData.appl_id.."/rules0/"..g_remoteData.rule_id.."/srcendport")
g_remoteData.dstport = box.query("netapp:settings/"..g_remoteData.appl_id.."/rules0/"..g_remoteData.rule_id.."/dstport")
g_remoteData.dststartport = g_remoteData.dstport
g_remoteData.dstendport = box.query("netapp:settings/"..g_remoteData.appl_id.."/rules0/"..g_remoteData.rule_id.."/dstendport")
end
if (g_remoteData.srcendport ~= "0") then
g_remoteData.port_src = "fromTo"
g_remoteData.srcport = ""
elseif (g_remoteData.srcport ~= "0") then
g_remoteData.port_src = "src"
g_remoteData.srcstartport = ""
g_remoteData.srcendport = ""
else
g_remoteData.port_src = "any"
g_remoteData.srcport = ""
g_remoteData.srcstartport = ""
g_remoteData.srcendport = ""
end
if (g_remoteData.dstendport ~= "0") then
g_remoteData.port_dst = "fromTo"
g_remoteData.dstport = ""
elseif (g_remoteData.dstport ~= "0") then
g_remoteData.port_dst = "src"
g_remoteData.dststartport = ""
g_remoteData.dstendport = ""
else
g_remoteData.port_dst = "any"
g_remoteData.dstport = ""
g_remoteData.dststartport = ""
g_remoteData.dstendport = ""
end
g_remoteData.appl_name = box.query("netapp:settings/"..g_remoteData.appl_id.."/name")
end
read_box_values()
function refill_user_input()
if (box.post) then
if(box.post.portSrc) then
g_remoteData.port_src = box.post.portSrc
end
if(box.post.portDst) then
g_remoteData.port_dst = box.post.portDst
end
if(box.post.protocol) then
g_remoteData.protocol = box.post.protocol
end
if (box.post.portSrcInput) then
g_remoteData.srcport = box.post.portSrcInput
end
if (box.post.portSrcFromInput) then
g_remoteData.srcstartport = box.post.portSrcFromInput
end
if (box.post.portSrcToInput) then
g_remoteData.srcendport = box.post.portSrcToInput
end
if (box.post.portDstInput) then
g_remoteData.dstport = box.post.portDstInput
end
if (box.post.portDstFromInput) then
g_remoteData.dststartport = box.post.portDstFromInput
end
if (box.post.portDstToInput) then
g_remoteData.dstendport = box.post.portDstToInput
end
end
end
g_port_max_length = 5
g_port_min_length = 1
g_port_num_max = 65535
g_port_num_min = 1
g_port_validation = [[
if __radio_check (uiPortSrcPort/portSrc, src) then
length(uiPortSrcPortInput/portSrcInput,]]..g_port_min_length..[[,]]..g_port_max_length..[[, port_error_txt)
num_range(uiPortSrcPortInput/portSrcInput,]]..g_port_num_min..[[,]]..g_port_num_max..[[, port_error_txt)
end
if __radio_check (uiPortSrcFromTo/portSrc,fromTo) then
length(uiPortSrcFromInput/portSrcFromInput,]]..g_port_min_length..[[,]]..g_port_max_length..[[, port_error_txt)
length(uiPortSrcToInput/portSrcToInput,]]..g_port_min_length..[[,]]..g_port_max_length..[[, port_error_txt)
num_range(uiPortSrcFromInput/portSrcFromInput,]]..g_port_num_min..[[,]]..g_port_num_max..[[, port_error_txt)
num_range(uiPortSrcToInput/portSrcToInput,]]..g_port_num_min..[[,]]..g_port_num_max..[[, port_error_txt)
less_than(uiPortSrcFromInput/portSrcFromInput, uiPortSrcToInput/portSrcToInput, port_error_txt)
end
if __radio_check (uiPortDstPort/portDst,src) then
length(uiPortDstPortInput/portDstInput,]]..g_port_min_length..[[,]]..g_port_max_length..[[, port_error_txt)
num_range(uiPortDstPortInput/portDstInput,]]..g_port_num_min..[[,]]..g_port_num_max..[[, port_error_txt)
end
if __radio_check (uiPortDstFromTo/portDst,fromTo) then
length(uiPortDstFromInput/portDstFromInput,]]..g_port_min_length..[[,]]..g_port_max_length..[[, port_error_txt)
length(uiPortDstToInput/portDstToInput,]]..g_port_min_length..[[,]]..g_port_max_length..[[, port_error_txt)
num_range(uiPortDstFromInput/portDstFromInput,]]..g_port_num_min..[[,]]..g_port_num_max..[[, port_error_txt)
num_range(uiPortDstToInput/portDstToInput,]]..g_port_num_min..[[,]]..g_port_num_max..[[, port_error_txt)
less_than(uiPortDstFromInput/portDstFromInput, uiPortDstToInput/portDstToInput, port_error_txt)
end
]]
g_val = {
prog = [[
if __radio_check (uiProtocolTCP/protocol, TCP) then
]] .. g_port_validation ..[[
end
if __radio_check (uiProtocolUDP/protocol, UDP) then
]] .. g_port_validation ..[[
end
]]
}
local msg_port=[[{?9038:12?}]]
val.msg.port_error_txt = {
[val.ret.empty] = msg_port,
[val.ret.notfound] = msg_port,
[val.ret.format] = [[{?9038:441?}]],
[val.ret.outofrange] = general.sprintf([[{?9038:724?}]],g_port_num_min, g_port_num_max),
[val.ret.greaterthan] = [[{?9038:949?}]],
[val.ret.equalerr] = [[{?9038:337?}]],
[val.ret.tooshort] = [[{?9038:419?}]],
[val.ret.toolong] = [[{?9038:518?}]]
}
function write_checked(check)
if check then
box.out("checked")
end
end
function write_protocol_checked(protocol)
write_checked(protocol == g_remoteData.protocol)
end
if next(box.post) then
if box.post.btn_cancel then
local param = {}
param[1] = http.url_param('appl_id', box.post.appl_id)
http.redirect(href.get('/internet/trafficappl_edit.lua', unpack(param)))
elseif box.post.apply then
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
if (box.post.protocol and box.post.protocol ~= "") then
cmtable.add_var(ctlmgr_save, "netapp:settings/"..box.post.appl_id.."/rules0/"..g_remoteData.rule_id.."/protocol", box.post.protocol)
local srcport = "0"
local srcendport = "0"
local dstport = "0"
local dstendport = "0"
if (box.post.protocol == "TCP" or box.post.protocol == "UDP") then
if(box.post.portSrc and box.post.portSrc == "src") then
srcport = box.post.portSrcInput
elseif(box.post.portSrc and box.post.portSrc == "fromTo") then
srcport = box.post.portSrcFromInput
srcendport = box.post.portSrcToInput
end
if(box.post.portDst and box.post.portDst == "src") then
dstport = box.post.portDstInput
elseif(box.post.portDst and box.post.portDst == "fromTo") then
dstport = box.post.portDstFromInput
dstendport = box.post.portDstToInput
end
end
cmtable.add_var(ctlmgr_save, "netapp:settings/"..g_remoteData.appl_id.."/rules0/"..g_remoteData.rule_id.."/srcport", srcport)
cmtable.add_var(ctlmgr_save, "netapp:settings/"..g_remoteData.appl_id.."/rules0/"..g_remoteData.rule_id.."/srcendport",srcendport)
cmtable.add_var(ctlmgr_save, "netapp:settings/"..g_remoteData.appl_id.."/rules0/"..g_remoteData.rule_id.."/dstport", dstport)
cmtable.add_var(ctlmgr_save, "netapp:settings/"..g_remoteData.appl_id.."/rules0/"..g_remoteData.rule_id.."/dstendport", dstendport)
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
box.out(general.create_error_div(err, msg))
refill_user_input()
else
local param = {}
param[1] = http.url_param('appl_id', g_remoteData.appl_id)
http.redirect(href.get('/internet/trafficappl_edit.lua', unpack(param)))
end
end
else
refill_user_input()
end
end
else
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form id="MainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p><?lua box.html(general.sprintf([[{?9038:38?}]],g_remoteData.appl_name)) ?></p>
<hr>
<h4>{?9038:809?}</h4>
<div class="formular" >
<input type="radio" id="uiProtocolTCP" onclick="onProtocolChange()" name="protocol" value="TCP" <?lua write_protocol_checked("TCP") ?>>
<label for="uiProtocolTCP">{?9038:349?}</label>
<br>
<input type="radio" id="uiProtocolUDP" onclick="onProtocolChange()" name="protocol" value="UDP" <?lua write_protocol_checked("UDP") ?>>
<label for="uiProtocolUDP">{?9038:341?}</label>
<br>
<input type="radio" id="uiProtocolESP" onclick="onProtocolChange()" name="protocol" value="ESP" <?lua write_protocol_checked("ESP") ?>>
<label for="uiProtocolESP">{?9038:573?}</label>
<br>
<input type="radio" id="uiProtocolGRE" onclick="onProtocolChange()" name="protocol" value="GRE" <?lua write_protocol_checked("GRE") ?>>
<label for="uiProtocolGRE">{?9038:425?}</label>
<br>
<input type="radio" id="uiProtocolICMP" onclick="onProtocolChange()" name="protocol" value="ICMP" <?lua write_protocol_checked("ICMP") ?>>
<label for="uiProtocolICMP">{?9038:860?}</label>
</div>
<div id="uiPortElements">
<hr>
<h4>{?9038:198?}</h4>
<div class="formular" >
<input type="radio" id="uiPortSrcAny" onclick="onSrcPortChange()" name="portSrc" value="any" <?lua write_checked(g_remoteData.port_src == "any") ?>>
<label for="uiPortSrcAny">{?9038:17?}</label>
<br>
<input type="radio" id="uiPortSrcPort" onclick="onSrcPortChange()" name="portSrc" value="src" <?lua write_checked(g_remoteData.port_src == "src") ?>>
<label for="uiPortSrcPort">{?txtPort?}</label>
<input type="text" id="uiPortSrcPortInput" size="5" maxlength="<?lua box.html(g_port_max_length)?>" name="portSrcInput" value="<?lua box.html(g_remoteData.srcport) ?>">
<?lua val.write_html_msg(g_val, "cmd_vorn", "uiPortSrcPortInput")?>
<br>
<input type="radio" id="uiPortSrcFromTo" onclick="onSrcPortChange()" name="portSrc" value="fromTo" <?lua write_checked(g_remoteData.port_src == "fromTo") ?>>
<label for="uiPortSrcPortFromTo">{?txtPort?}</label>
<input type="text" id="uiPortSrcFromInput" name="portSrcFromInput" size="5" maxlength="<?lua box.html(g_port_max_length)?>" value="<?lua box.html(g_remoteData.srcstartport) ?>">
{?9038:751?}
<input type="text" id="uiPortSrcToInput" name="portSrcToInput" size="5" maxlength="<?lua box.html(g_port_max_length)?>" value="<?lua box.html(g_remoteData.srcendport) ?>">
<?lua val.write_html_msg(g_val, "cmd_vorn", "uiPortSrcToInput", "uiPortSrcFromInput")?>
</div>
<hr>
<h4>{?9038:219?}</h4>
<div class="formular" >
<input type="radio" id="uiPortDstAny" onclick="onDstPortChange()" name="portDst" value="any" <?lua write_checked(g_remoteData.port_dst == "any") ?>>
<label for="uiPortDstAny">{?9038:166?}</label>
<br>
<input type="radio" id="uiPortDstPort" onclick="onDstPortChange()" name="portDst" value="src" <?lua write_checked(g_remoteData.port_dst == "src") ?>>
<label for="uiPortDstPort">{?txtPort?}</label>
<input type="text" id="uiPortDstPortInput" size="5" maxlength="<?lua box.html(g_port_max_length)?>" name="portDstInput" value="<?lua box.html(g_remoteData.dstport) ?>">
<?lua val.write_html_msg(g_val, "cmd_vorn", "uiPortDstPortInput")?>
<br>
<input type="radio" id="uiPortDstFromTo" onclick="onDstPortChange()" name="portDst" value="fromTo" <?lua write_checked(g_remoteData.port_dst == "fromTo") ?>>
<label for="uiPortDstFromTo">{?txtPort?}</label>
<input type="text" id="uiPortDstFromInput" size="5" maxlength="<?lua box.html(g_port_max_length)?>" name="portDstFromInput" value="<?lua box.html(g_remoteData.dststartport) ?>">
{?9038:832?}
<input type="text" id="uiPortDstToInput" size="5" maxlength="<?lua box.html(g_port_max_length)?>" name="portDstToInput" value="<?lua box.html(g_remoteData.dstendport) ?>">
<?lua val.write_html_msg(g_val, "cmd_vorn", "uiPortDstFromInput", "uiPortDstToInput")?>
</div>
<p>{?9038:847?}</p>
</div>
<div class="formular" id="uiChiSaHint">
<span class="hintMsg">{?txtHinweis?}</span>
<p>{?9038:433?}</p>
</div>
<div id="btn_form_foot">
<input type="hidden" name="appl_id" value="<?lua box.html(g_remoteData.appl_id)?>">
<input type="hidden" name="rule_id" value="<?lua box.html(g_remoteData.rule_id)?>">
<button type="submit" name="apply" id="uiBtnOK">{?txtApplyOk?}</button>
<button type="submit" name="btn_cancel" id="uiBtnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
}
function onProtocolChange()
{
var tcpUdpChecked = jxl.getChecked("uiProtocolTCP") || jxl.getChecked("uiProtocolUDP");
jxl.display("uiPortElements", tcpUdpChecked);
jxl.display("uiChiSaHint", !tcpUdpChecked);
}
function onSrcPortChange()
{
jxl.disableNode("uiPortSrcPortInput", !jxl.getChecked("uiPortSrcPort"));
jxl.disableNode("uiPortSrcFromInput", !jxl.getChecked("uiPortSrcFromTo"));
jxl.disableNode("uiPortSrcToInput", !jxl.getChecked("uiPortSrcFromTo"));
}
function onDstPortChange()
{
jxl.disableNode("uiPortDstPortInput", !jxl.getChecked("uiPortDstPort"));
jxl.disableNode("uiPortDstFromInput", !jxl.getChecked("uiPortDstFromTo"));
jxl.disableNode("uiPortDstToInput", !jxl.getChecked("uiPortDstFromTo"));
}
function init() {
onProtocolChange();
onSrcPortChange();
onDstPortChange();
}
ready.onReady(val.init(onNumEditSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
