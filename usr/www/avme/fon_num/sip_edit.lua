<?lua
g_page_type = "all"
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require("config")
require("http")
require("href")
require("general")
require("js")
require("tr069")
require("cmtable")
require("newval")
g_page_title = box.tohtml([[{?2792:94?}]])
g_menu_active_page = "/fon_num/fon_num_list.lua"
g_page_help = "hilfe_fon_internet.html"
g_back_to_page = http.get_back_to_page( "/fon_num/fon_num_list.lua" )
if box.post.btn_cancel then
http.redirect(href.get(g_back_to_page))
end
if box.post.fonNumMode == "asall" or box.get.fonNumMode == "asall" or
box.post.fonNumMode == "asint" or box.get.fonNumMode == "asint" then
g_page_type = "wizard"
end
g_uid = ""
if box.get.uid then
g_uid = box.get.uid
else
g_uid = box.post.uid
end
if g_uid == "" then
http.redirect(href.get(g_back_to_page))
end
g_num = {}
g_num.fondata = {}
g_num.is_expert = general.is_expert()
g_num.uid = g_uid
TXT_CHANGE = config.oem == 'kdg' and config.DOCSIS
ONLY_SIP_NAME = false
require("sip_providerlist")
require("fon_numbers")
require("fon_numbers_html")
g_num.new = false
if g_num.uid == "new" then
g_num.new = true
end
if g_num.new then
g_num['fondata'] = sip_providerlist.get_startdata()
else
if not fon_numbers.getdata(g_num.uid,g_num) then
http.redirect(href.get(g_back_to_page))
end
end
ONLY_SIP_NAME = fon_numbers.check_sip_nums_read_only() or config.oem == 'kdg'
if (not ONLY_SIP_NAME) then
if (g_num.fondata[1]) then
ONLY_SIP_NAME=g_num.fondata[1].dataValues.details.gui_readonly == "1"
end
end
g_num.available_sip_accounts = fon_numbers.get_available_sip_accounts()
if config.LTE then
g_num.lte = sip_providerlist.get_LTEInfos()
end
if config.T38 then
g_num.t38_support_enabled = box.query("sipextra:settings/sip/t38_support_enabled")
end
g_num = fon_numbers_html.get_area_for_num(g_num)
g_provider_list = sip_providerlist.get_providerlist()
function read_from_post()
g_num={}
g_num.fondata = {}
g_num.is_expert = general.is_expert()
g_num.new=false
g_num.uid=box.post.uid
if not fon_numbers.getdata(g_num.uid,g_num) then
http.redirect(href.get(g_back_to_page))
end
g_num.available_sip_accounts = fon_numbers.get_available_sip_accounts()
end
if next(box.post) then
if box.post.validate == "btn_save" then
local valresult, answer = newval.validate(fon_numbers_html.val_prog)
box.out(js.table(answer))
box.end_page()
elseif box.post.btn_save then
if newval.validate(fon_numbers_html.val_prog) == newval.ret.ok then
local errcode, errmsg= fon_numbers_html.save_sip_data()
if errcode==0 then
http.redirect(href.get(g_back_to_page))
else
read_from_post()
if (errcode>0) then
g_errormsg=general.create_error_div(errcode,errmsg)
end
end
end
end
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<link rel="stylesheet" type="text/css" href="/css/default/trunk.css">
<?include "templates/page_head.html" ?>
<form id="MainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<?lua
data_noir = [[fon_num/sip_edit_normal.lua]]
if ONLY_SIP_NAME then
data_noir = [[fon_num/sip_edit_no_change.lua]]
end
if g_errormsg ~= nil then
box.html("<div>")
box.out(g_errormsg)
box.html("</div>")
end
?>
<?include data_noir?>
<div id="btn_form_foot">
<input type="hidden" name="uid" value="<?lua box.html(g_num.uid)?>">
<input type="hidden" name="separatednumbers" id="SeparatedNumbers" value="0">
<input type="hidden" name="isusername" id="IsUsername" value="0">
<input type="hidden" name="isregistrar" id="IsRegistrar" value="0">
<input type="hidden" name="counttrunk" id="countTrunk" value="0">
<input type="hidden" name="trunk_active" id="uiTrunkActive" value="0">
<input type="hidden" name="msn_visible" id="uiIsMsnVisible" value="0">
<?lua
fon_numbers_html.isNew()
?>
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page)?>">
<button type="submit" name="btn_save" id="btnSave" onclick="alert_kdg()">{?txtOK?}</button>
<button type="submit" name="btn_cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript" src="/js/sip.js"></script>
<script type="text/javascript">
var g_ProviderList = <?lua box.out(js.table(sip_providerlist.get_providerlist())) ?>;
var g_fondata = <?lua box.out(js.table(g_num.fondata)) ?>;
var gAvailableSipAccounts = <?lua box.out(g_num.available_sip_accounts)?>;
var g_ONLY_SIP_NAME = <?lua box.js(tostring(ONLY_SIP_NAME))?>;
function alert_kdg()
{
if (!g_ONLY_SIP_NAME)
{
return
}
if ((<?lua box.out(tostring(tr069.provisioned_by_kdg())) ?>) && (jxl.getValue("uiRegistrar").search("kabelphone.de") != -1))
{
if (<?lua box.out(tostring(TXT_CHANGE))?>)
{
alert("{?2792:961?}");
}
else
{
alert("{?2792:174?}");
}
}
}
function init()
{
var is_provider_ui=<?lua
box.js(tostring(isp.show_1und1_select()))
?>;
showDisplay(g_ProviderList, g_fondata[0].provider_id, is_provider_ui);
showUserInterface(g_ProviderList, g_fondata[0].provider_id);
setFonData(g_fondata, false);
var is_ui_provider_active=<?lua box.js(tostring(isp.is_ui(g_num.fondata[1].provider_id)))?>;
if (is_provider_ui)
{
jxl.display("uiOtherProvider",!(is_ui_provider_active));
}
setSafeProvider(g_fondata[0].provider_id,is_provider_ui);
DeactivateAll(jxl.getChecked("uiSipActiv"));
jxl.setChecked("uiTcomActiv",jxl.getValue("uiUsername") != "anonymous@t-online.de");
if (jxl.getValue("uiUsername") == "anonymous@t-online.de")
{
onUserInputActivated(false);
}
else
{
onUserInputActivated(true);
}
onViewMSN();
}
gAvaibleSipCount = <?lua box.out(g_num.available_sip_accounts)?>;
ready.onReady(ajaxValidation({
applyNames: "btn_save"
}));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
