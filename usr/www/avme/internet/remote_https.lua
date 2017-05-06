<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_internet_remote_https.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("general")
require("href")
if box.post.boxCertDelete or box.get.boxCertDelete then
local ctlmgr_save = {}
cmtable.add_var( ctlmgr_save, "remoteman:settings/user_cert_delete" , "1" )
local err,msg = box.set_config( ctlmgr_save )
end
local ftp_service =
{
description = "FTP-Server",
port = "21",
endport = "21",
fwport = "21",
protocol = "TCP"
}
g_DEFAULT_HTTPS_PORT = "443"
g_ctlmgr = {}
function get_param()
g_ctlmgr.enabled = box.query("remoteman:settings/enabled") == "1"
g_ctlmgr.https_port = box.query("remoteman:settings/https_port")
g_ctlmgr.user_cert = box.query("remoteman:settings/user_cert_present") == "1"
g_ctlmgr.cert_fingerprint = box.query("remoteman:settings/cert_sha1_fingerprint")
g_ctlmgr.expertmode_active = box.query("box:settings/expertmode/activated")
g_ctlmgr.ftp_from_internet = box.query("ctlusb:settings/storage-ftp-internet") == "1"
g_ctlmgr.ftps_only = box.query("ctlusb:settings/internet-secured") == "1"
g_ctlmgr.forwardrules = {}
g_ctlmgr.forwardrules = general.listquery("forwardrules:settings/rule/list(activated,description,protocol,port,fwip,fwport,endport)")
g_ctlmgr.ddns_aktivated = box.query("ddns:settings/account0/activated")
g_ctlmgr.ddns_domain = box.query("ddns:settings/account0/domain")
g_ctlmgr.myfritz_dyndns_name = ""
if config.MYFRITZ then
local opmodes_to_lock = { opmode_usb_modem = true, opmode_eth_ipclient = true }
g_ctlmgr.opmode = box.query("box:settings/opmode")
g_ctlmgr.mf_enabled = box.query("jasonii:settings/enabled") == "1"
g_ctlmgr.mf_state = tonumber(box.query("jasonii:settings/myfritzstate")) or 0
if not opmodes_to_lock[g_ctlmgr.opmode] and g_ctlmgr.mf_enabled and g_ctlmgr.mf_state >= 300 then
g_ctlmgr.myfritz_dyndns_name = box.query("jasonii:settings/dyndnsname")
end
end
g_ctlmgr.local_ipv4 = box.query("interfaces:settings/lan0/ipaddr")
g_ctlmgr.local_ipv6 = box.query("ipv6:status/ipv6_lan")
g_ctlmgr.pppoe_ip = box.query("connection0:status/ip")
g_ctlmgr.no_ipv4_internet = (g_ctlmgr.pppoe_ip == nil or g_ctlmgr.pppoe_ip == "" or g_ctlmgr.pppoe_ip == "er" or g_ctlmgr.pppoe_ip == "no-emu" or g_ctlmgr.pppoe_ip == "-" or g_ctlmgr.pppoe_ip == "0.0.0.0")
g_ctlmgr.dslite_active=false
if config.IPV6 and box.query("ipv6:settings/enabled") == "1" then
g_ctlmgr.dslite_active = box.query("ipv6:settings/ipv4_active_mode") ~= "ipv4_normal"
if (g_ctlmgr.dslite_active) then
g_ctlmgr.no_ipv4_internet=true
end
g_ctlmgr.no_ipv6_internet = box.query("ipv6:settings/state") ~= "5"
g_ctlmgr.ipv6_ip = box.query("ipv6:settings/ip")
else
g_ctlmgr.no_ipv6_internet = true
g_ctlmgr.ipv6_ip = false
end
end
get_param()
function refill_user_input()
if box.post.activate_remote_https then
g_ctlmgr.enabled = true
else
g_ctlmgr.enabled = false
end
if box.post.activate_remote_ftp then
g_ctlmgr.ftp_from_internet = true
else
g_ctlmgr.ftp_from_internet = false
end
if box.post.use_ftps then
g_ctlmgr.ftps_only = true
else
g_ctlmgr.ftps_only = false
end
if box.post.remote_port and box.post.remote_port ~= "" then
g_ctlmgr.https_port = box.post.remote_port
else
g_ctlmgr.https_port = g_DEFAULT_HTTPS_PORT
end
end
g_val = {
prog = [[
not_empty(uiViewRemotePort/remote_port, port_error_txt)
char_range_regex(uiViewRemotePort/remote_port, decimals, port_error_txt)
num_range(uiViewRemotePort/remote_port, 1, 65535, port_error_txt)
]]
}
val.msg.port_error_txt = {
[val.ret.empty] = [[{?159:415?}]],
[val.ret.format] = [[{?159:941?}]],
[val.ret.outofrange] = [[{?159:640?}]]
}
if next(box.post) and box.post.btn_save then
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
local ctlmgr_del={}
cmtable.save_checkbox(ctlmgr_save, "remoteman:settings/enabled" , "activate_remote_https")
if box.post.remote_port then
cmtable.add_var(ctlmgr_save, "remoteman:settings/https_port" , box.post.remote_port)
else
cmtable.add_var(ctlmgr_save, "remoteman:settings/https_port" , g_DEFAULT_HTTPS_PORT)
end
ctlmgr_save = array.cat(ctlmgr_save, ctlmgr_del)
cmtable.save_checkbox(ctlmgr_save, "ctlusb:settings/storage-ftp-internet" , "activate_remote_ftp")
if box.post.activate_remote_ftp then
cmtable.save_checkbox(ctlmgr_save, "ctlusb:settings/internet-secured" , "use_ftps")
else
cmtable.add_var(ctlmgr_save, "ctlusb:settings/internet-secured" , "0")
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr = general.create_error_div(err,msg)
box.out(criterr)
refill_user_input()
else
get_param()
end
else
refill_user_input()
end
end
function get_ftp_address()
local address = ""
local prefix = "ftp://"
local postfix = ""
local port = ""
local count = 0
if g_ctlmgr.no_ipv4_internet and g_ctlmgr.no_ipv6_internet then
address = [[<span class="ShowPath">]]..box.tohtml([[{?159:384?}]])..[[</span>]]
else
if g_ctlmgr.ddns_aktivated == "1" then
address = [[<span class="ShowPath">]]..prefix..box.tohtml(g_ctlmgr.ddns_domain)..box.tohtml(port)..postfix..[[</span>]]
count = count + 1
end
if not g_ctlmgr.no_ipv4_internet then
if count == 0 then
address = [[<span class="ShowPath">]]..prefix..box.tohtml(g_ctlmgr.pppoe_ip)..box.tohtml(port)..postfix..[[</span>]]
else
address = address..[[ ]]..box.tohtml([[{?159:22?}]])..[[<span class="ShowPath form_input_note">]]..prefix..box.tohtml(g_ctlmgr.pppoe_ip)..box.tohtml(port)..postfix..[[</span>]]
end
count = count + 1
end
if not g_ctlmgr.no_ipv6_internet then
if count == 0 then
address = [[<span class="ShowPath">]]..prefix.."["..box.tohtml(g_ctlmgr.ipv6_ip).."]"..box.tohtml(port)..postfix..[[</span>]]
else
address = address..[[ ]]..box.tohtml([[{?159:326?}]])..[[<span class="ShowPath form_input_note">]]..prefix.."["..box.tohtml(g_ctlmgr.ipv6_ip).."]"..box.tohtml(port)..postfix..[[</span>]]
end
count = count + 1
end
end
return address
end
function is_ftp_forwarded()
for i,rule in ipairs(g_ctlmgr.forwardrules) do
if (rule.activated == "1" and rule.port == ftp_service.port and rule.endport == ftp_service.endport and rule.fwport == ftp_service.fwport and rule.protocol == ftp_service.protocol) then
return true
end
end
return false
end
function get_internet_address( prefix, port )
local count = 0
local address = ""
if g_ctlmgr.no_ipv4_internet and g_ctlmgr.no_ipv6_internet then
address = [[<span id="dyndns_address" class="ShowPath">]]..box.tohtml([[{?159:5236?}]])..[[</span>]]
else
if g_ctlmgr.myfritz_dyndns_name ~= "" then
address = [[<span id="myfritz_dyndns_address" class="ShowPath">]]..prefix..box.tohtml(g_ctlmgr.myfritz_dyndns_name)..port..[[</span>]]
count = count + 1
end
if g_ctlmgr.ddns_aktivated == "1" then
if count == 0 then
address = [[<span id="dyndns_address" class="ShowPath">]]..prefix..box.tohtml(g_ctlmgr.ddns_domain)..port..[[</span>]]
else
address = address..[[ ]]..box.tohtml([[{?159:875?}]])..[[<span id="dyndns_address" class="ShowPath form_input_note">]]..prefix..box.tohtml(g_ctlmgr.ddns_domain)..port..[[</span>]]
end
count = count + 1
end
if not g_ctlmgr.no_ipv4_internet then
if count == 0 then
address = [[<span id="ipv4_address" class="ShowPath">]]..prefix..box.tohtml(g_ctlmgr.pppoe_ip)..port..[[</span>]]
else
address = address..[[ ]]..box.tohtml([[{?159:465?}]])..[[<span id="ipv4_address" class="ShowPath form_input_note">]]..prefix..box.tohtml(g_ctlmgr.pppoe_ip)..port..[[</span>]]
end
count = count + 1
end
if not g_ctlmgr.no_ipv6_internet then
if count == 0 then
address = [[<span id="ipv6_address" class="ShowPath">]]..prefix.."["..box.tohtml(g_ctlmgr.ipv6_ip).."]"..port..[[</span>]]
else
address = address..[[ ]]..box.tohtml([[{?159:216?}]])..[[<span id="ipv6_address" class="ShowPath form_input_note">]]..prefix.."["..box.tohtml(g_ctlmgr.ipv6_ip).."]"..port..[[</span>]]
end
count = count + 1
end
if count == 1 then
address = address..[[<p class="form_input_note">]]..box.tohtml([[{?159:358?}]])..[[</p>]]
elseif count > 1 then
address = address..[[<p class="form_input_note">]]..box.tohtml([[{?159:430?}]])..[[</p>]]
end
end
return address
end
function get_local_address( prefix, port )
local address = ""
local or_txt = box.tohtml([[{?159:45?}]])
address = [[<span class="ShowPath">]] .. prefix .. [[fritz.box]] .. port .. [[</span>]]
if g_ctlmgr.local_ipv4 and 0 < #g_ctlmgr.local_ipv4 then
address = address .. [[ ]] .. or_txt .. [[<span class="ShowPath form_input_note">]] .. prefix .. box.tohtml(g_ctlmgr.local_ipv4) .. port .. [[</span>]]
end
if g_ctlmgr.local_ipv6 and 0 < #g_ctlmgr.local_ipv6 then
address = address .. [[ ]] .. or_txt .. [[<span class="ShowPath form_input_note">]] .. prefix .. "[" .. box.tohtml(g_ctlmgr.local_ipv6) .. "]" .. port .. [[</span>]]
end
address = address .. [[<p class="form_input_note">]] .. box.tohtml([[{?159:986?}]]) .. [[</p>]]
return address
end
function get_address( internet_address )
local address = ""
local prefix = box.tohtml("https://")
local port = g_ctlmgr.https_port
if port ~= nil and port ~= "" and port ~= g_DEFAULT_HTTPS_PORT then
port = box.tohtml(':'..port)
else
port = ""
end
if internet_address then
address = get_internet_address( prefix, port )
else
address = get_local_address( prefix, port )
end
return address
end
function write_myfritz_hint()
if config.MYFRITZ then
require"html"
html.br().write()
html.strong({},
[[{?txtHinweis?}]]
).write()
html.p({},
[[{?159:19?}]]
).write()
end
end
function write_cert_state()
local certTxt1 = [[{?159:244?} ]]
box.out([[<div class="certStateBox">]] )
if g_ctlmgr.user_cert then
box.html( [[{?159:693?}]] )
box.out( [[<br>]] )
box.html( certTxt1, g_ctlmgr.cert_fingerprint )
box.out( [[</div>]] )
box.out( [[<button type="button" class="icon certStateBtn" title="]], box.tohtml( [[{?159:402?}]] ), [[" onclick="return onCertDelete();"><img src="/css/default/images/loeschen.gif" alt="]], box.tohtml( [[{?159:769?}]] ), [["></button>]] )
elseif g_ctlmgr.cert_fingerprint and 0 < #g_ctlmgr.cert_fingerprint then
box.html( [[{?159:4525?}]] )
box.out( [[<br>]] )
box.html( certTxt1, g_ctlmgr.cert_fingerprint )
box.out( [[</div>]] )
else
box.html( [[{?159:508?}]] )
box.out( [[</div>]] )
box.out( [[<button type="button" class="icon certStateBtn" title="]], box.tohtml( [[{?159:813?}]] ), [[" onclick="return onCertRefresh();"><img src="/css/default/images/aktualisieren.gif" alt="]], box.tohtml( [[{?159:194?}]] ), [["></button>]] )
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.certStateBox {
border: 1px solid #90a6a5;
padding: 5px;
display: inline-block;
}
.certStateBtn {
vertical-align: top;
margin-left: 10px;
}
.formular .formular .formular label.specialStyle {
width: 110px;
}
.formular .formular .form_input_note {
margin-left: 210px
}
</style>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<div id="uiMain">
<p>
{?159:259?}
</p>
<?lua write_myfritz_hint() ?>
<hr>
<h4>{?159:394?}</h4>
<div class="formular">
<div>
<p>
{?159:948?}
</p>
<label for="uiViewRemotePort">{?159:646?}</label>
<input type="text" id="uiViewRemotePort" name="remote_port" maxlength="5" onkeyup="modifyAddress()" value="<?lua box.html(g_ctlmgr.https_port) ?>" <?lua val.write_attrs(g_val, "uiViewRemotePort") ?>>
<label for="uiViewRemotePort">{?159:446?}</label>
<?lua val.write_html_msg(g_val, "uiViewRemotePort") ?>
</div>
<br>
<div id="uiViewLocalAddressBox">
<span class="ShowPathLabel">{?159:782?}</span>
<?lua box.out(get_address( false ))?>
</div>
</div>
<hr>
<h4>{?159:800?}</h4>
<div class="formular">
<div <?lua if box.query("connection0:status/ip_is_private") == "0" then box.out([[style="display:none;"]]) end ?>>
<span class="hintMsg">{?txtHinweis?}</span>
<p>{?159:997?}</p>
</div>
<input type="checkbox" id="uiViewActivateRemoteHTTPS" name="activate_remote_https" onclick="onRemoteHttpsActiv()" <?lua if g_ctlmgr.enabled then box.out('checked') end ?>>
<label for="uiViewActivateRemoteHTTPS">{?159:54?}</label>
<p class="form_input_explain">
{?159:93?}
</p>
<div id="disable_http" class="formular">
<div id="uiViewAddressBox">
<span class="ShowPathLabel">{?159:639?}</span>
<?lua box.out(get_address( true ))?>
</div>
</div>
<br>
<input type="checkbox" id="remoteFtpActive" name="activate_remote_ftp" onclick="onRemoteftpActiv(this.checked)" <?lua if g_ctlmgr.ftp_from_internet then box.out('checked') end ?>>
<label for="remoteFtpActive">{?159:818?}</label>
<p class="form_input_explain">
{?159:106?}
</p>
<div class="formular" id="ftp_box">
<div id="ftpAddressBox">
<span class="ShowPathLabel">{?159:759?}</span>
<?lua box.out(get_ftp_address()) ?>
</div>
<div <?lua if g_ctlmgr.expertmode_active == "0" then box.out([[style="display:none;"]]) end ?>>
<br>
<input type="checkbox" id="uiViewUseFtps" name="use_ftps" onclick="onFtpsOnly()" <?lua if g_ctlmgr.ftps_only then box.out('checked') end ?>>
<label for="uiViewUseFtps">{?159:13?}</label>
</div>
</div>
</div>
</div>
<hr>
<h4>{?159:741?}</h4>
<div class="formular">
<p>
{?159:277?}
</p>
<br>
<h4>{?159:210?}</h4>
<div>
<?lua
write_cert_state()
?>
</div>
<div id="fboxCertDownload">
<br>
<h4>{?159:663?}</h4>
</div>
<br>
<h4>{?159:559?}</h4>
<p>
{?159:528?}
</p>
<div class="formular">
<p>
{?159:576?}
</p>
<div class="formular">
<label class="specialStyle" for="uiPass">{?159:665?}</label><input type="text" id="uiPass" name="BoxCertPassword" autocomplete="off"/>
<br>
<input type="file" id="uiImport" name="BoxCertImportFile" size="20"/>
</div>
<p>
{?159:627?}
</p>
<div class="formular">
<button type="button" title="{?159:793?}" onclick="return onCertImport();">{?159:930?}</button>
</div>
</div>
</div>
<div id="btn_form_foot">
<button type="submit" name="btn_save" id="btnSave">{?txtApply?}</button>
<button type="submit" name="btn_cancel">{?txtCancel?}</button>
</div>
</form>
<form action="/cgi-bin/firmwarecfg" method="POST" enctype="multipart/form-data" name="uiCertExport" onsubmit="return false" style="display:none">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="BoxCertExport" />
</form>
<form action="<?lua box.html( box.glob.script ) ?>" method="POST" name="uiCertRefresh" onsubmit="return false;" style="display:none">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
</form>
<form action="<?lua href.write(box.glob.script) ?>" method="POST" name="uiCertDelete" style="display:none">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="boxCertDelete" />
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/dialog.js"></script>
<script type="text/javascript">
var gUserCert = <?lua box.js( tostring( g_ctlmgr.user_cert ) ) ?>;
var gCertFingerprint = "<?lua box.js( tostring( g_ctlmgr.cert_fingerprint ) ) ?>";
<?lua
val.write_js_error_strings()
?>
function onFtpsOnly()
{
var labelElem = jxl.getByClass("ShowPathLabel","ftpAddressBox","span");
var pathElems = jxl.getByClass("ShowPath","ftpAddressBox","span");
var labelTxt = "{?159:108?}";
var elemTxtOld = "ftps://";
var elemTxtNew = "ftp://";
if (labelElem && pathElems)
{
if (jxl.getChecked("uiViewUseFtps"))
{
labelTxt = "{?159:458?}";
elemTxtOld = "ftp://";
elemTxtNew = "ftps://";
}
labelElem[0].innerHTML = labelTxt;
for (idx in pathElems)
{
pathElems[idx].innerHTML = pathElems[idx].innerHTML.replace(elemTxtOld,elemTxtNew);
}
}
}
function onRemoteftpActiv(checked)
{
if (checked && <?lua box.out(tostring(is_ftp_forwarded())) ?>)
{
alert('{?159:449?}');
jxl.setChecked("remoteFtpActive", false);
return;
}
var activ = jxl.getChecked("remoteFtpActive");
jxl.display( "ftp_box", activ );
}
function onRemoteHttpsActiv()
{
var activ = jxl.getChecked("uiViewActivateRemoteHTTPS");
jxl.display( "uiViewAddressBox", activ );
}
function addOrRemovePort(str, ipv6)
{
if (<?lua box.js(tostring(g_ctlmgr.no_ipv4_internet and g_ctlmgr.no_ipv6_internet)) ?>)
{
return str
}
var splitter = ":";
if (ipv6) splitter = "]";
var tmp = str.split(splitter, 2);
if (ipv6)
tmp = tmp[0]+splitter+tmp[1].substring(0, tmp[1].indexOf(":"));
else
tmp = tmp[0]+splitter+tmp[1];
return tmp+":"+jxl.getValue("uiViewRemotePort");
}
function modifyAddress()
{
var myfritzDdnsAddr = jxl.getHtml("myfritz_dyndns_address");
var ddAddrTxt = jxl.getHtml("dyndns_address");
var ipv4AddrTxt = jxl.getHtml("ipv4_address");
var ipv6AddrTxt = jxl.getHtml("ipv6_address");
if ( myfritzDdnsAddr!="" )
{
jxl.setHtml("myfritz_dyndns_address", addOrRemovePort(myfritzDdnsAddr, false));
}
if ( ddAddrTxt!="" )
{
jxl.setHtml("dyndns_address", addOrRemovePort(ddAddrTxt, false));
}
if ( ipv4AddrTxt!="" )
{
jxl.setHtml("ipv4_address", addOrRemovePort(ipv4AddrTxt, false));
}
if ( ipv6AddrTxt!="" )
{
jxl.setHtml("ipv6_address", addOrRemovePort(ipv6AddrTxt, true));
}
}
function cbCertDelete()
{
jxl.submitForm( "uiCertDelete" );
}
function onCertDelete()
{
dialog.confirm( "{?159:16?}", "{?159:826?} {?159:332?}", cbCertDelete );
return false;
}
function onCertExport()
{
jxl.submitForm("uiCertExport");
return false;
}
function onCertRefresh()
{
jxl.submitForm("uiCertRefresh");
return false;
}
function onCertImport()
{
jxl.get("uiMainForm").action = "/cgi-bin/firmwarecfg";
jxl.get("uiMainForm").enctype = "multipart/form-data";
jxl.disableNode("uiMain", true);
window.setTimeout('jxl.submitForm("uiMainForm")', 2000);
return true;
}
function onRemoteHttpsSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
}
function init()
{
/* FritzBox Certi */
var fritzCertBox = jxl.get( "fboxCertDownload" );
if ( fritzCertBox )
{
fritzCertBox.innerHTML = "<br> \
<h4>{?159:899?}</h4>\
<p>";
if ( gCertFingerprint && 0 < gCertFingerprint.length )
{
fritzCertBox.innerHTML += " {?159:609?}\
</p>\
<div>\
<button type='button' title='{?159:263?}' onclick='return onCertExport();'>{?159:262?}</button>\
</div>";
}
else
{
fritzCertBox.innerHTML += " {?159:188?}\
</p>\
<div>\
<button type='button' title='{?159:544?}' onclick='return onCertRefresh();'>{?159:629?}</button>\
</div>";
}
}
onRemoteHttpsActiv();
onRemoteftpActiv(false);
onFtpsOnly();
}
ready.onReady(val.init(onRemoteHttpsSubmit, "btn_save", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
