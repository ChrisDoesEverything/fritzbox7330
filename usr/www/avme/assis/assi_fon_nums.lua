<?lua
g_page_type = "wizard"
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require("cmtable")
require("http")
require("href")
require("webuicookie")
require("general")
general.set_assi(true)
require("fon_numbers")
require("sip_providerlist")
require("fon_numbers_html")
require("wizard")
require("js")
require("newval")
g_back_to_page = http.get_back_to_page( "/assis/home.lua" )
pagemaster = ""
if box.get.pagemaster or box.get["pagemaster"] then
pagemaster = box.get.pagemaster or box.get["pagemaster"]
elseif box.post.pagemaster or box.post["pagemaster"] then
pagemaster = box.post.pagemaster or box.post["pagemaster"]
end
page_mode=box.post.page_mode or box.get.page_mode or "nor"
popup_url=""
if config.oem == '1und1' then
if box.get.popup_url then
popup_url = box.get.popup_url
elseif box.post.popup_url then
popup_url = box.post.popup_url
end
end
g_start_with_step = 1
if box.get.step then
g_start_with_step = tonumber(box.get.step) or 1
elseif box.post.step then
g_start_with_step = tonumber(box.post.step) or 1
end
g_only_inet = false
if box.get.configure then
g_only_inet = box.get.configure=="inet"
elseif box.post.configure then
g_only_inet = box.post.configure=="inet"
end
g_configure="all"
if box.get.configure then
g_configure = box.get.configure
elseif box.post.configure then
g_configure = box.post.configure
end
g_only_pstn = false
if box.get.configure then
g_only_pstn = box.get.configure=="pstn"
elseif box.post.configure then
g_only_pstn = box.post.configure=="pstn"
end
g_first_wizard = box.get.configure == "first" or box.post.configure == "first"
or box.get.first_wizard or box.post.first_wizard
g_num = {}
g_num.pstn_type ="unconfigured"
g_provider_list = sip_providerlist.get_providerlist()
TXT_CHANGE = config.oem == 'kdg' and config.DOCSIS
ONLY_SIP_NAME = false
ONLY_SIP_NAME = fon_numbers.check_sip_nums_read_only() or config.oem == 'kdg'
if (ONLY_SIP_NAME) then
http.redirect(href.get("/home/home.lua"))
box.end_page()
return
end
g_page_title = [[{?829:938?}]]
g_state_msg={}
g_state_msg["0"]=[[{?829:913?}]]
if TXT_CHANGE then
local fault=[[{?829:820?}]].." "
g_state_msg["8"] = [[{?829:317?}]]
g_state_msg["9"] = [[{?829:383?}]]
g_state_msg["10"] = fault..[[{?829:1516?}]]
g_state_msg["11"] = fault..[[{?829:865?}]]
g_state_msg["12"] = fault..[[{?829:625?}]]
g_state_msg["13"] = fault..[[{?829:628?}]]
g_state_msg["14"] = fault..[[{?829:445?}]]
g_state_msg["15"] = fault..[[{?829:4640?}]]
else
local fault=[[{?829:5048?}]].." "
g_state_msg["8"] = [[{?829:477?}]]
g_state_msg["9"] = [[{?829:104?}]]
g_state_msg["10"] = fault..[[{?829:378?}]]
g_state_msg["11"] = fault..[[{?829:779?}]]
g_state_msg["12"] = fault..[[{?829:159?}]]
g_state_msg["13"] = fault..[[{?829:61?}]]
g_state_msg["14"] = fault..[[{?829:479?}]]
g_state_msg["15"] = fault..[[{?829:242?}]]
end
g_ajax = false
g_action = ""
if box.get.useajax then
g_ajax = true
g_action = box.get.action
g_sip_id = box.get.sip_id
elseif box.post.useajax then
g_ajax = true
g_action = box.post.action
g_sip_id = box.post.sip_id
end
if g_ajax then
if (g_action=="get_state") then
box.out(box.query([[sip:status/]]..g_sip_id..[[/Check/Status]]))
elseif(g_action=="start") then
local saveset={}
cmtable.add_var(saveset,[[sip:settings/]]..g_sip_id..[[/Check/Start]],"1")
local errcode,errmsg=box.set_config(saveset)
box.out("start="..tostring(errcode)..","..tostring(errmsg))
end
box.end_page()
end
function val_prog()
local empty_number=[[{?829:38?}]]
local only_num_txt=TXT([[{?829:273?}]])
local number_too_long=TXT([[{?829:864?}]])
newval.msg.error_txt_pots = {
[newval.ret.empty] = empty_number,
[newval.ret.outofrange] = only_num_txt
}
newval.msg.error_txt_isdn = {
[newval.ret.empty] = empty_number,
[newval.ret.toolong] = number_too_long,
[newval.ret.outofrange] = only_num_txt
}
if newval.radio_check("choose_pstn_or_inet","pstn") then
if newval.radio_check("choose_pots_or_isdn","pots") then
newval.not_empty("pots_num","error_txt_pots")
newval.length("pots_num", 0,20, "error_txt_isdn")
newval.char_range_regex("pots_num", "fonnum", "error_txt_pots")
end
if newval.radio_check("choose_pots_or_isdn","isdn") then
newval.values_not_all_empty("isdn",10,"error_txt_isdn")
newval.length("isdn1", 0, 20, "empty_allowed", "error_txt_isdn")
newval.length("isdn2", 0, 20, "empty_allowed", "error_txt_isdn")
newval.length("isdn3", 0, 20, "empty_allowed", "error_txt_isdn")
newval.length("isdn4", 0, 20, "empty_allowed", "error_txt_isdn")
newval.length("isdn5", 0, 20, "empty_allowed", "error_txt_isdn")
newval.length("isdn6", 0, 20, "empty_allowed", "error_txt_isdn")
newval.length("isdn7", 0, 20, "empty_allowed", "error_txt_isdn")
newval.length("isdn8", 0, 20, "empty_allowed", "error_txt_isdn")
newval.length("isdn9", 0, 20, "empty_allowed", "error_txt_isdn")
newval.length("isdn10",0, 20, "empty_allowed", "error_txt_isdn")
newval.char_range_regex("isdn1", "fonnum", "error_txt_isdn")
newval.char_range_regex("isdn2", "fonnum", "error_txt_isdn")
newval.char_range_regex("isdn3", "fonnum", "error_txt_isdn")
newval.char_range_regex("isdn4", "fonnum", "error_txt_isdn")
newval.char_range_regex("isdn5", "fonnum", "error_txt_isdn")
newval.char_range_regex("isdn6", "fonnum", "error_txt_isdn")
newval.char_range_regex("isdn7", "fonnum", "error_txt_isdn")
newval.char_range_regex("isdn8", "fonnum", "error_txt_isdn")
newval.char_range_regex("isdn9", "fonnum", "error_txt_isdn")
newval.char_range_regex("isdn10","fonnum", "error_txt_isdn")
end
end
end
g_data ={}
g_data.num = {"1","2","3","4","5","6","7","8","9","10"}
function read_box_values()
local uid=box.post.uid or ""
g_num.is_expert = general.is_expert()
g_num.is_assi = general.is_assi()
g_num.new=false
g_num.already_configured=tonumber(fon_numbers.get_number_count("all"))
g_num.configured_sips=tonumber(fon_numbers.get_number_count("sip"))
if not fon_numbers.getdata(uid,g_num) then
g_num.new=true
g_num['fondata'] = sip_providerlist.get_startdata()
else
end
if config.LTE then
g_num.lte = sip_providerlist.get_LTEInfos()
end
if config.T38 then
g_num.t38_support_enabled = box.query("sipextra:settings/sip/t38_support_enabled")
end
g_num = fon_numbers_html.get_area_for_num(g_num)
g_num.available_sip_accounts = fon_numbers.get_available_sip_accounts()
end
function read_from_post()
sip_providerlist.findUnknownSipProviders(true)
g_provider_list = sip_providerlist.get_providerlist()
if (g_only_pstn or g_num.pstn_type=="isdn" or g_num.pstn_type=="pots") then
g_start_with_step = -1
go_home()
end
local uid=g_num.fondata[1].uid
local pstn_type =g_num.pstn_type
g_num = {}
g_num.new=false
g_num.pstn_type=pstn_type
g_num.is_expert = general.is_expert()
g_num.is_assi = general.is_assi()
g_num.already_configured=tonumber(fon_numbers.get_number_count("all"))
g_num.configured_sips=tonumber(fon_numbers.get_number_count("sip"))
if not fon_numbers.getdata(uid,g_num) then
http.redirect(href.get(g_back_to_page))
end
if config.LTE then
g_num.lte = sip_providerlist.get_LTEInfos()
end
if config.T38 then
g_num.t38_support_enabled = box.query("sipextra:settings/sip/t38_support_enabled")
end
g_num = fon_numbers_html.get_area_for_num(g_num)
g_num.available_sip_accounts = fon_numbers.get_available_sip_accounts()
end
function go_home(valresult)
if (g_start_with_step==-1) then
local params = {}
if (g_back_to_page == "/assis/home.lua") then
table.insert(params, http.url_param("fonNumMode", "asall"))
http.redirect(href.get("/fon_num/fon_num_list.lua", unpack(params)))
end
if (g_back_to_page=="/assis/assi_fondevices_list.lua") then
table.insert(params, http.url_param('popup_url', popup_url))
if g_first_wizard then
table.insert(params, http.url_param('wiztype', "first"))
end
end
if (g_back_to_page=="/fon_devices/fondevices_list.lua") then
table.insert(params, http.url_param('FonAssiFromPage', "fonerweitert"))
table.insert(params, http.url_param('pagemaster', "fondevices_list"))
table.insert(params, http.url_param('popup_url', popup_url))
elseif g_back_to_page == "/fon_num/fon_num_list.lua" then
if g_first_wizard then
table.insert(params, http.url_param("fonNumMode", "asfirst"))
elseif g_configure == "inet" and page_mode~="nor" then
table.insert(params, http.url_param("fonNumMode", "asint"))
elseif g_configure == "all" and page_mode~="nor" then
table.insert(params, http.url_param("fonNumMode", "asall"))
end
end
if valresult then
table.insert(params, http.url_param("error_result", valresult))
end
http.redirect(href.get(g_back_to_page, unpack(params)))
end
end
if box.post.validate == "continue" then
if newval.radio_check("choose_pstn_or_inet","pstn") then
valresult, answer = newval.validate(val_prog)
else
valresult, answer = newval.validate(fon_numbers_html.val_prog)
end
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
go_home()
if newval.radio_check("choose_pstn_or_inet","pstn") then
valresult, answer = newval.validate(val_prog)
else
valresult, answer = newval.validate(fon_numbers_html.val_prog)
end
if valresult == newval.ret.ok then
read_box_values()
if (g_start_with_step~=1) then
local errcode, errmsg=0,""
local saveset = {}
if box.post.choose_pstn_or_inet=="inet" then
errcode, errmsg=fon_numbers_html.save_sip_data()
g_num.pstn_type ="inet"
if box.post.pstn_type then
if (box.post.pstn_type=="only_inet") then
cmtable.add_var(saveset, "telcfg:settings/tr069usePSTN", "0")
errcode1, errmsg1 = box.set_config(saveset)
elseif (box.post.pstn_type=="with_pstn") then
cmtable.add_var(saveset, "telcfg:settings/tr069usePSTN", "1")
errcode1, errmsg1 = box.set_config(saveset)
end
end
elseif box.post.choose_pots_or_isdn=="pots" then
for i=1,10 do
cmtable.add_var(saveset,"telcfg:settings/MSN/MSN"..i-1,"")
end
cmtable.add_var(saveset,"telcfg:settings/MSN/POTS",box.post.pots_num)
errcode, errmsg = box.set_config(saveset)
g_num.pstn_type ="pots"
else
cmtable.add_var(saveset,"telcfg:settings/MSN/POTS","")
for i=1,10 do
cmtable.add_var(saveset,"telcfg:settings/MSN/MSN"..i-1,box.post["isdn"..i] or "")
end
errcode, errmsg = box.set_config(saveset)
g_num.pstn_type ="isdn"
end
if (errcode>0) then
g_errmsg=general.create_error_div(errcode,errmsg)
end
read_from_post()
end
else
read_box_values()
end
elseif (box.post.cancel) then
if g_first_wizard then
http.redirect(href.get("/assis/home.lua"))
else
local param={}
if pagemaster ~="" then
require ("fon_devices_html")
g_back_to_page=fon_devices_html.get_full_page_name(pagemaster)
end
if (g_back_to_page=="/assis/assi_fondevices_list.lua") then
http.redirect(href.get_paramtable("/assis/home.lua",param))
elseif (g_back_to_page=="/assis/assi_telefon_start.lua") then
http.redirect(href.get_paramtable("/assis/home.lua",param))
end
http.redirect(href.get_paramtable(g_back_to_page,param))
end
else
read_box_values()
end
function use_pstn()
return ((config.CAPI_TE or config.CAPI_POTS) and box.query("telcfg:settings/UsePSTN")== "1")
end
function write_checked(radio_btn)
if (g_configure=="inet" and radio_btn=="inet" ) or
(g_configure=="all" and radio_btn=="inet" ) or
(g_configure=="pstn" and radio_btn=="pstn" ) then
box.out([[checked]])
end
end
function write_popup()
if popup_url=="1" then
require("tr069")
local url = tr069.get_servicecenter_url()
box.js(url)
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<link rel="stylesheet" type="text/css" href="/css/default/main.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<link rel="stylesheet" type="text/css" href="/css/default/trunk.css">
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<style type="text/css">
.formular.close label{
width:20px;
text-align:right;
}
.inputs {
display:inline-block;
width:200px;
}
#MainForm .inputs input[type=text] {
display:inline-block;
width:130px;
}
</style>
<script type="text/javascript" src="/js/dialog.js"></script>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript" src="/js/sip.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/wizard.js?lang=,<?lua box.out(config.language)?>,"></script>
<script type="text/javascript">
var g_step = <?lua box.js(tostring(g_start_with_step)) ?>;
var g_onlyInet = <?lua box.js(tostring(g_only_inet)) ?>;
var g_onlyPstn = <?lua box.js(tostring(g_only_pstn)) ?>;
var g_onlyPots = <?lua box.js(tostring(not config.CAPI_TE and config.CAPI_POTS)) ?>;
var g_usePSTN = <?lua box.js(tostring(use_pstn())) ?>;
var g_sipOnly=!g_usePSTN || g_onlyInet;
var control_areas = g_sipOnly ? AssiSipOnly:g_onlyPstn?AssiPstnOnly:AssiWithPstn;
var check_areas = g_sipOnly ? CheckSipOnly:g_onlyPstn?CheckPstnOnly:CheckWithPstn;
var g_TXT_CHANGE = <?lua box.js(TXT_CHANGE)?>;
var g_PstnType = "<?lua box.out(g_num.pstn_type)?>";
var gAvailableSipAccounts = <?lua box.out(g_num.available_sip_accounts)?>;
var g_ProviderList = <?lua box.out(js.table(g_provider_list)) ?>;
var g_ProviderId = "<?lua box.js(g_num.fondata[1].provider_id) ?>";
var g_Fondata = <?lua box.out(js.table(g_num.fondata)) ?>;
var g_StateMsg = <?lua box.out(js.table(g_state_msg)) ?>;
var g_PicturePath_Success = "/css/default/images/finished_ok_green.gif";
var g_PicturePath_Failed = "/css/default/images/finished_error.gif";
var g_PicturePath_Wait = "/css/default/images/wait.gif";
var g_sip = "<?lua box.js(g_num.fondata[1].id)?>";
var g_configured_nums=<?lua box.js(g_num.already_configured)?>;
var g_configured_sips=<?lua box.js(g_num.configured_sips)?>;
var g_has_Fixedline=<?lua box.js(tostring(config.CAPI_TE or config.CAPI_POTS)) ?>;
var g_max_sip_accounts=<?lua box.js(fon_numbers.get_max_sip_accounts()) ?>;
var g_is_provider_ui=<?lua
box.js(tostring(isp.show_1und1_select()))
?>;
function cbStart(id,xhr)
{
ajaxUpdateHtml("","/assis/assi_fon_nums.lua?useajax=1&action=get_state&sip_id="+g_sip,"<?lua box.js(box.glob.sid) ?>",1000,cbState);
jxl.setDisabled("uiContinue",true);
jxl.setDisabled("uiApply",true);
jxl.setDisabled("uiBack",true);
return 0;
}
function cbState(id,xhr)
{
if ((!g_sipOnly && g_step!=6) || (g_sipOnly && g_step!=3))
{
return 0;
}
var state=xhr.responseText;
var msg=g_StateMsg[state];
var image=g_PicturePath_Failed;
var timeout=0
switch (state)
{
case "8":
{
image=g_PicturePath_Wait;
timeout=10000;
break;
}
case "9":
{
image=g_PicturePath_Success;
}
default:
{
jxl.show("uiApply");
jxl.setDisabled("uiCancel",true);
jxl.setDisabled("uiContinue",false);
jxl.setDisabled("uiApply",false);
jxl.setDisabled("uiBack",false);
jxl.setValue("uiCurStep","-1");
break;
}
}
jxl.changeImage("uiImage",image);
if (msg && msg!="")
{
jxl.setText("uiView_TestState",msg);
}
return timeout;
}
function check_input()
{
var valfunc = ajaxValidation({directCall:true});
return valfunc("continue");
}
function AssiWithPstn()
{
var show_summary=false;
var show_apply=false;
var show_continue=true;
jxl.setHtml("contentTitle","<h2>{?829:850?}</h2>");
jxl.display("uiPage_ConnectType",false);
if (g_step==1)
{
if (g_configured_nums==0 && g_has_Fixedline )
{
jxl.disableNode("uiPage_ConnectType",false);
jxl.display("uiPage_ConnectType",true);
}
else
{
g_step++;
}
}
jxl.display("uiPage_PstnOrInet",g_step==2);
if (g_step==2)
{
g_laststep=5;
g_PstnType="unconfigured";
//jxl.display("uiCancel",true);
jxl.setDisabled("uiContinue",false);
}
if (g_step==3 && (g_PstnType=="isdn" || g_PstnType=="pots" || g_PstnType=="unconfigured"))
{
g_step++;
g_PstnType="pots";
jxl.setChecked("uiIsdnSel",false);
jxl.setChecked("uiPotsSel",true);
}
jxl.display("uiPage_ChoosePstnType",g_step==3 && (g_PstnType=="isdn" || g_PstnType=="pots" || g_PstnType=="unconfigured"));
if (g_step==3 )
{
if (g_PstnType=="isdn" || g_PstnType=="pots" || g_PstnType=="unconfigured")
{
g_PstnType="unconfigured";
jxl.setHtml("contentTitle","<h2>{?829:6073?}</h2>");
}
else
{
g_step=4;
}
}
if (g_step==5 && !check_input())
{
g_step--;
}
jxl.display("uiPage_Isdn",g_step==4 && g_PstnType=="isdn");
jxl.display("uiPage_Pots",g_step==4 && g_PstnType=="pots");
jxl.display("uiPage_Inet",g_step==4 && g_PstnType=="inet");
if (g_step==4)
{
var title="{?829:548?}";
switch (g_PstnType)
{
case "isdn":
case "pots":
{
break;
}
case "inet":
{
if (g_TXT_CHANGE)
title="{?829:705?}";
else
title="{?829:467?}";
var curProvider="";
if (g_ProviderId != "")
{
curProvider = g_ProviderId;
}
else
{
if (g_is_provider_ui)
{
curProvider=jxl.getValue("uiSipProviderUI");
if (curProvider=="other_non_ui")
{
curProvider=jxl.getValue("uiSipProvider");
}
}
else
{
curProvider=jxl.getValue("uiSipProvider");
}
if (!curProvider || curProvider=="")
{
curProvider="other";
}
}
showDisplay(g_ProviderList, curProvider, g_is_provider_ui);
setFonData(g_ProviderList[curProvider],true)
break;
}
}
jxl.setHtml("contentTitle","<h2>"+title+"</h2>");
}
jxl.display("uiPage_Summary",false);
if (g_step==5)
{
switch (g_PstnType)
{
case "isdn":
case "pots":
{
show_apply=true;
show_continue=false;
jxl.setValue("uiCurStep",5);
collect_PSTN_data("uiSummary");
break;
}
case "inet":
{
if (g_TXT_CHANGE)
jxl.setHtml("contentTitle","<h2>{?829:731?}</h2>");
else
jxl.setHtml("contentTitle","<h2>{?829:8289?}</h2>");
collect_data("uiSummary");
jxl.setValue("uiCurStep",6);
if (jxl.getEnabled("uiOnlyInet") && jxl.getChecked("uiOnlyInet"))
{
jxl.setValue("uiCurStep",3);
}
show_apply=true;
show_continue=false;
break;
}
}
jxl.display("uiPstnSave",g_PstnType!="inet");
jxl.display("uiPstnNumbers",g_PstnType!="inet");
jxl.display("uiInetNumbers",g_PstnType=="inet");
jxl.display("uiTestpossible",g_PstnType=="inet");
jxl.display("uiPage_Summary",true);
}
jxl.display("uiPage_InetTest",false);
if (g_step==6)
{
if (g_TXT_CHANGE)
jxl.setHtml("contentTitle","<h2>{?829:550?}</h2>");
else
jxl.setHtml("contentTitle","<h2>{?829:100?}</h2>");
collect_data("uiTestSummary");
show_apply=true;
show_continue=false;
ajaxUpdateHtml("","/assis/assi_fon_nums.lua?useajax=1&action=start&sip_id="+g_sip,"<?lua box.js(box.glob.sid) ?>",1,cbStart);
jxl.setValue("uiIsNew","0");
jxl.display("uiPage_InetTest",true);
}
var showBack=! ((g_step==1 && (g_configured_nums==0 && g_has_Fixedline ) || g_step==2 && !(g_configured_nums==0 && g_has_Fixedline )))
jxl.display("uiBack",showBack);
jxl.display("uiContinue",show_continue);
jxl.display("uiApply",show_apply);
}
function AssiPstnOnly()
{
var show_summary=false;
var show_apply=false;
var show_continue=true;
jxl.setHtml("contentTitle","<h2>{?829:663?}</h2>");
if (g_step==1 && (g_PstnType=="isdn" || g_PstnType=="pots" || g_PstnType=="unconfigured"))
{
g_step++;
g_PstnType="pots";
jxl.setChecked("uiIsdnSel",false);
jxl.setChecked("uiPotsSel",true);
}
jxl.display("uiPage_ChoosePstnType",g_step==1 && (g_PstnType=="isdn" || g_PstnType=="pots" || g_PstnType=="unconfigured"));
if (g_step==1 )
{
if (g_PstnType=="isdn" || g_PstnType=="pots" || g_PstnType=="unconfigured")
{
g_PstnType="unconfigured";
jxl.setHtml("contentTitle","<h2>{?829:463?}</h2>");
}
}
jxl.display("uiPage_Isdn",g_step==2 && g_PstnType=="isdn");
jxl.display("uiPage_Pots",g_step==2 && g_PstnType=="pots");
jxl.display("uiPage_Inet",false);
if (g_step==2)
{
var title="{?829:854?}";
switch (g_PstnType)
{
case "isdn":
case "pots":
{
break;
}
}
jxl.setHtml("contentTitle","<h2>"+title+"</h2>");
}
jxl.display("uiPage_Summary",false);
if (g_step==3)
{
switch (g_PstnType)
{
case "isdn":
case "pots":
{
show_apply=true;
show_continue=false;
jxl.setValue("uiCurStep",3);
collect_PSTN_data("uiSummary");
break;
}
}
jxl.display("uiPstnSave",g_PstnType!="inet");
jxl.display("uiPstnNumbers",g_PstnType!="inet");
jxl.display("uiInetNumbers",g_PstnType=="inet");
jxl.display("uiTestpossible",g_PstnType=="inet");
jxl.display("uiPage_Summary",true);
}
jxl.display("uiBack",g_step!=1);
jxl.display("uiContinue",show_continue);
jxl.display("uiApply",show_apply);
}
function AssiSipOnly()
{
if (g_PstnType!="inet")
{
jxl.display("uiPage_PstnOrInet",false);
jxl.display("uiPage_ChoosePstnType",false);
jxl.display("uiPage_Isdn",false);
jxl.display("uiPage_Pots",false);
}
if (g_step==2 && !check_input())
{
g_step--;
}
g_PstnType="inet";
jxl.display("uiPage_Inet",g_step==1);
if (g_step==1)
{
jxl.enable("uiSipActive");
var title=""
if (g_TXT_CHANGE)
title="{?829:610?}";
else
title="{?829:711?}";
jxl.setHtml("contentTitle","<h2>"+title+"</h2>");
}
var show_summary=false;
var show_apply=false;
var show_continue=true;
jxl.display("uiPage_Summary",false);
if (g_step==2)
{
if (g_TXT_CHANGE)
jxl.setHtml("contentTitle","<h2>{?829:128?}</h2>");
else
jxl.setHtml("contentTitle","<h2>{?829:769?}</h2>");
collect_data("uiSummary");
jxl.display("uiPstnSave",g_PstnType!="inet");
jxl.display("uiPstnNumbers",g_PstnType!="inet");
jxl.display("uiInetNumbers",g_PstnType=="inet");
jxl.display("uiTestpossible",g_PstnType=="inet");
jxl.display("uiPage_Summary",true);
jxl.setValue("uiCurStep",3);
jxl.setChecked("uiInet",true);
show_apply=true;
show_continue=false;
}
jxl.display("uiPage_InetTest",false);
if (g_step==3)
{
if (g_TXT_CHANGE)
jxl.setHtml("contentTitle","<h2>{?829:524?}</h2>");
else
jxl.setHtml("contentTitle","<h2>{?829:928?}</h2>");
collect_data("uiTestSummary");
show_apply=true;
show_continue=false;
ajaxUpdateHtml("","/assis/assi_fon_nums.lua?useajax=1&action=start&sip_id="+g_sip,"<?lua box.js(box.glob.sid) ?>",1,cbStart);
jxl.setValue("uiIsNew","0");
jxl.display("uiPage_InetTest",true);
}
jxl.display("uiBack",g_step!=1);
jxl.display("uiContinue",show_continue);
jxl.display("uiApply",show_apply);
}
function collect_PSTN_data(id)
{
var count_nums=0;
var strTable=[];
strTable.push('<table id="uiSumTable" class="zebra">');
strTable.push(' <tr>');
strTable.push(' <td class="c1 number"><span>{?829:19?}</span></td>');
if (g_PstnType=="pots")
{
strTable.push(' <td class="c2">'+jxl.getValue("uiPots")+'</td>');
strTable.push(' </tr>');
}
else
{
var firstline=false;
var num=jxl.getValue("uiIsdn"+1);
if (num!="")
{
strTable.push(' <td class="c2">'+num+'</td>');
strTable.push(' </tr>');
firstline=true;
count_nums++;
}
for (i=2;i<=10;i++)
{
num=jxl.getValue("uiIsdn"+i);
if (num!="")
{
if (firstline)
{
strTable.push(' <tr>');
strTable.push(' <td class="c1 number"><span>&nbsp;</span></td>');
}
strTable.push(' <td class="c2">'+num+'</td>');
strTable.push(' </tr>');
firstline=true;
count_nums++;
}
}
}
strTable.push('</table>');
var newTable=strTable.join("\n")
if (g_PstnType=="pots" || (g_PstnType=="isdn" && count_nums<=1))
{
newTable=newTable.replace("zebra","zebra_reverse");
}
jxl.setHtml(id,newTable);
if (g_PstnType=="inet" || (g_PstnType=="isdn" && count_nums>1))
{
zebra();
}
}
function collect_data(id)
{
var cur_provider="";
if (g_is_provider_ui)
{
cur_provider=jxl.getValue("uiSipProviderUI");
if (cur_provider=="other_non_ui")
cur_provider=jxl.getValue("uiSipProvider");
}
else
cur_provider=jxl.getValue("uiSipProvider");
if (!g_ProviderList[cur_provider])
cur_provider="other";
provider=g_ProviderList[cur_provider].name;
var all_nums="";
if (isTrunkActivated(g_ProviderList) )
{
countmax=jxl.getValue("countTrunk");
var nums=[];
if (jxl.getValue("uiSerialNumber") != "")
{
var data = jxl.getValue("uiSerialNumber") + jxl.getValue("uiCentralPhoneExtension");
nums.push(data);
}
for(i = 1; i <= countmax; i++)
{
var data = jxl.getValue("uiNumberInput1_trunk_"+i);
nums.push(data);
}
all_nums=nums.join(",<br>");
}
else
{
var num=jxl.getValue("uiNumberInput1_1")+g_ProviderList[cur_provider].userInterface.uiNumberMiddleSpan+jxl.getValue("uiNumberInput2_1");
num=num.replace(g_ProviderList[cur_provider].userInterface.uiNumberFirstSpan,"");
all_nums=g_ProviderList[cur_provider].userInterface.uiNumberFirstSpan+num;
}
var strTable=[];
strTable.push('<table id="uiSumTable" class="zebra">');
strTable.push(' <tr>');
strTable.push(' <td class="c1 provider"><span>{?829:630?}</span></td>');
strTable.push(' <td class="c2">'+provider+'</td>');
strTable.push(' </tr>');
if (jxl.getValue("SeparatedNumbers")!=0)
{
strTable.push(' <tr>');
strTable.push(' <td class="c1 number">');
strTable.push(' <span>'+g_ProviderList[cur_provider].userInterface.uiNumberLabel+'</span>');
strTable.push(' </td>');
strTable.push(' <td class="c2">'+all_nums+'</td>');
strTable.push(' </tr>');
}
if (g_ProviderList[cur_provider].display["ShowUsername"])
{
strTable.push(' <tr>');
strTable.push(' <td class="c1" username><span>'+g_ProviderList[cur_provider].userInterface.uiLabelUsername+'</span></td>');
var usr = "";
usr=jxl.getValue("uiUsername");
usr=usr.replace(g_ProviderList[cur_provider].userInterface.uiUserprefix,"");
strTable.push(' <td class="c2">'+g_ProviderList[cur_provider].userInterface.uiUserprefix+usr+'</td>');
strTable.push(' </tr>');
}
if (g_ProviderList[cur_provider].display["ShowRegistrar"])
{
strTable.push(' <tr>');
strTable.push(' <td class="c1 registrar"><span>{?829:174?}</span></td>');
strTable.push(' <td class="c2">'+jxl.getValue("uiRegistrar")+'</td>');
strTable.push(' </tr>');
}
if (g_ProviderList[cur_provider].display.ShowProxy)
{
strTable.push(' <tr>');
strTable.push(' <td class="c1 proxy"><span>{?829:793?}</span></td>');
strTable.push(' <td class="c2">'+jxl.getValue("uiOutboundproxy")+'</td>');
strTable.push(' </tr>');
}
if (g_ProviderList[cur_provider].display["ShowStun"])
{
strTable.push(' <tr>');
strTable.push(' <td class="c1 stun"><span>{?829:10?}</span></td>');
strTable.push(' <td class="c2">'+jxl.getValue("uiStunserver")+'</td>');
strTable.push(' </tr>');
}
strTable.push('</table>');
jxl.setHtml(id,strTable.join("\n"));
zebra();
}
function CheckWithPstn(step)
{
var ret;
switch (step)
{
case 1:
{
g_PstnType="unconfigured";
if (jxl.getChecked("uiOnlyInet"))
{
g_step++;
g_PstnType="inet";
jxl.setChecked("uiInet",true);
}
else if (jxl.getChecked("uiWithPstn"))
g_PstnType="unconfigured";
break;
}
case 2:
{
if (jxl.getChecked("uiInet"))
g_PstnType="inet";
else if (jxl.getChecked("uiPstn"))
g_PstnType="unconfigured";
else
{
alert("{?829:837?}");
return false;
}
break;
}
case 3:
{
g_PstnType="unconfigured";
if (jxl.getChecked("uiPotsSel"))
g_PstnType="pots";
if (jxl.getChecked("uiIsdnSel"))
g_PstnType="isdn";
if (g_PstnType=="unconfigured")
{
alert("{?829:692?}");
return false;
}
break;
}
case 4:
{
break;
}
case 5:
{
break;
}
case 6:
{
break;
}
}
if (g_configured_sips>=g_max_sip_accounts && g_PstnType=="inet")
{
if (g_TXT_CHANGE)
alert("{?829:133?}");
else
alert("{?829:307?}");
return false;
}
return true;
}
function CheckPstnOnly(step)
{
var ret;
switch (step)
{
case 1:
{
g_PstnType="unconfigured";
if (jxl.getChecked("uiPotsSel"))
g_PstnType="pots";
if (jxl.getChecked("uiIsdnSel"))
g_PstnType="isdn";
if (g_PstnType=="unconfigured")
{
alert("{?829:252?}");
return false;
}
break;
}
}
return true;
}
function CheckSipOnly(step)
{
var ret;
switch (step)
{
case 1:
{
g_PstnType="inet";
break;
}
case 2:
{
break;
}
case 3:
{
break;
}
}
if (g_configured_sips>=g_max_sip_accounts && g_PstnType=="inet")
{
if (g_TXT_CHANGE)
alert("{?829:297?}");
else
alert("{?829:469?}");
return false;
}
return true;
}
function uiDoOnMainFormSubmit()
{
return true;
}
function OnCancel()
{
openServiceCenter("<?lua write_popup() ?>");
return false;
}
function OnStepBackward()
{
if ((g_sipOnly && g_step==3)&& g_PstnType=="inet")
{
jxl.setDisabled("uiCancel",false);
jxl.enable("uiSipActive");
g_step=2;
}
if ((!g_sipOnly && g_step==6) && g_PstnType=="inet")
{
jxl.setDisabled("uiCancel",false);
jxl.enable("uiSipActive");
g_step=4;
}
if ((!g_sipOnly && g_step==4)&& g_PstnType=="inet")
{
if (g_configured_nums==0 && g_has_Fixedline && jxl.getChecked("uiWithPstn"))
g_step=3;
else
g_step=2;
}
g_step--;
if (((g_step==3 && !g_onlyPstn) || (g_step==1 && g_onlyPstn))&& g_has_Fixedline)
{
g_step--;
}
if (g_step<1)
g_step=1;
control_areas();
return false;
}
function OnStepForward()
{
if (!check_areas(g_step))
{
return false;
}
g_step++;
control_areas();
return false;
}
function init()
{
var is_provider_ui=<?lua
local is_provider_ui=false
box.js(tostring(isp.show_1und1_select()))
?>;
var cur_provider="other";
if (is_provider_ui)
cur_provider="1und1";
if (g_step!=1 && g_ProviderId!="")
{
cur_provider=g_ProviderId;
}
showDisplay(g_ProviderList, cur_provider, is_provider_ui);
setFonData(g_Fondata, false);
control_areas();
gAvaibleSipCount = <?lua box.out(g_num.available_sip_accounts)?>;
return true;
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="MainForm" method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div>
<div id="uiPage_PstnOrInet" style="display:none">
<p>{?829:209?}</p>
<p>{?829:497?}</p>
<h2>{?829:16?}</h2>
<div class="formular">
<input type="radio" id="uiInet" name="choose_pstn_or_inet" value="inet" <?lua write_checked("inet")?>><label for="uiInet">{?829:459?}</label><br>
<input type="radio" id="uiPstn" name="choose_pstn_or_inet" value="pstn" <?lua write_checked("pstn")?>><label for="uiPstn">{?829:300?}</label>
</div>
</div>
<div id="uiPage_ChoosePstnType" style="display:none">
<p>{?829:789?}</p>
<div class="formular">
<input type="radio" id="uiPotsSel" name="choose_pots_or_isdn" value="pots" checked><label for="uiPotsSel">{?829:113?}</label><br>
<input type="radio" id="uiIsdnSel" name="choose_pots_or_isdn" value="isdn"><label for="uiIsdnSel">{?829:669?}</label>
</div>
</div>
<div id="uiPage_Pots" style="display:none">
<p>{?829:226?}</p>
<div class="formular">
<label for="uiPots">{?829:81?}</label><input type="text" id="uiPots" name="pots_num" maxlength="20" value="<?lua box.html(fon_numbers.get_pots_number())?>">
</div>
</div>
<div id="uiPage_Isdn" style="display:none">
<p>{?829:690?}</p>
<div class="formular close">
<div class="inputs">
<?lua
g_msn=fon_numbers.get_msn()
for i=1,5 do
local idx=tostring(i)
local num_elem=fon_numbers.find_elem_in_list_by_telcfgid(g_msn,i-1)
local num=""
if num_elem then
num=num_elem.number
end
box.out(general.sprintf([[<label for="uiIsdn%1">%2.</label><input type="text" id="uiIsdn%3" name="isdn%4" maxlength="20" value="%5"><br>]],idx,idx,idx,idx,box.tohtml(num)))
end
?>
</div>
<div class="inputs">
<?lua
for i=6,10 do
local idx=tostring(i)
local num=(g_msn.numbers[i] and g_msn.numbers[i].number) or ""
box.out(general.sprintf([[<label for="uiIsdn%1">%2.</label><input type="text" id="uiIsdn%3" name="isdn%4" maxlength="20" value="%5"><br>]],idx,idx,idx,idx,box.tohtml(num)))
end
?>
</div>
<div class="clear_float"></div>
</div>
</div>
<div id="uiPage_ConnectType" style="display:none;">
<p>{?829:212?}</p>
<div class="formular">
<?lua
if general.is_atamode() then
box.out([[
<p><input type="radio" name="pstn_type" id="uiOnlyInet" value="only_inet" checked disabled><label for="uiOnlyInet">{?829:335?}</label></p>
<p class="form_radio_explain">{?829:529?}</p>
]])
else
box.out([[
<p><input type="radio" name="pstn_type" id="uiOnlyInet" value="only_inet" checked disabled><label for="uiOnlyInet">{?829:683?}</label></p>
<p class="form_radio_explain">{?829:787?}</p>
]])
end
if (config.CAPI_TE or config.CAPI_POTS) then
if general.is_atamode() then
box.out([[
<p><input type="radio" name="pstn_type" id="uiWithPstn" value="with_pstn" disabled><label for="uiWithPstn">{?829:310?}</label></p>
<p class="form_radio_explain">{?829:356?}</p>
]])
else
box.out([[
<p ><input type="radio" name="pstn_type" id="uiWithPstn" value="with_pstn" disabled><label for="uiWithPstn">{?829:719?}</label></p>
<p class="form_radio_explain">{?829:657?}</p>
]])
end
end
?>
</div>
</div>
<div id="uiPage_Inet" style="display:none;">
<p>{?829:8102?}</p>
<?lua
data_noir = [[fon_num/sip_edit_normal.lua]]
?>
<?include data_noir?>
</div>
<div id="uiPage_Summary" style="display:none;">
<p id="uiPstnNumbers">{?829:409?}</p>
<p id="uiInetNumbers">{?829:618?}</p>
<div id="uiSummary" class="formular">
</div>
<div>
<span id="uiPstnSave" style="display:none">{?829:511?}</span>
<span id="uiTestpossible" style="display:none">
<?lua
if TXT_CHANGE then
box.html([[{?829:132?}]])
else
box.html([[{?829:560?}]])
end
?>
</span>
</div>
</div>
<div id="uiPage_InetTest" style="display:none;">
<p>{?829:178?}</p>
<div id="uiTestSummary" class="formular">
</div>
<p>{?829:8884?}</p>
<p class="waitimg"><img id="uiImage" src="/css/default/images/wait.gif"></p>
<p id="uiView_TestState" >&nbsp;</p>
</div>
<?lua
if (g_errmsg and g_errmsg~="") then
box.out(g_errmsg)
end
?>
</div>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="page_mode" value="<?lua box.html(page_mode) ?>">
<input type="hidden" name="pagemaster" value="<?lua box.html(pagemaster) ?>">
<input type="hidden" name="isnew" id="uiIsNew" value="1">
<input type="hidden" name="uid" id="uiUid" value="<?lua box.html(g_num.fondata[1].uid)?>">
<input type="hidden" name="separatednumbers" id="SeparatedNumbers" value="0">
<input type="hidden" name="isusername" id="IsUsername" value="0">
<input type="hidden" name="isregistrar" id="IsRegistrar" value="0">
<input type="hidden" name="counttrunk" id="countTrunk" value="0">
<input type="hidden" name="trunk_active" id="uiTrunkActive" value="0">
<input type="hidden" name="step" id="uiCurStep" value="1">
<input type="hidden" name="sip_activ" id="uiSipActive" value="1" disabled>
<input type="hidden" name="msn_visible" id="uiIsMsnVisible" value="0">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
<input type="hidden" name="configure" id="uiFirst" value="<?lua box.html(g_configure)?>">
<?lua if g_first_wizard then
box.out([[<input type="hidden" name="first_wizard" value="">]])
end
?>
<button type="submit" name="back" onclick="return OnStepBackward();" style="display:none;" id="uiBack">{?829:455?}</button>
<button type="submit" name="continue" onclick="return OnStepForward();" style="display:none;" id="uiContinue">{?txtNext?}</button>
<button type="submit" name="apply" style="display:none;" id="uiApply">{?txtNext?}</button>
<button type="submit" name="cancel" id="uiCancel" onclick="OnCancel()">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
