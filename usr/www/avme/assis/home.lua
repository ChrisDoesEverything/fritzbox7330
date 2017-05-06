<?lua
g_page_type = "all"
g_page_title = [[{?209:585?}]]
dofile("../templates/global_lua.lua")
require"cmtable"
require"assi_control"
require"fon_nr_config"
require"general"
require"menu"
require"capiterm"
require"config"
g_CapitermEnabled = "F"
g_CapitermInfo = assi_control.TraceStart(g_CapitermEnabled, box.glob.script)
local order = {
'fondevices_list',
'fonnumbers',
'internet',
'diagnosis',
'security',
'repeater_connect',
'repeater_dvb',
'repeater_update',
'imexport',
'update',
'pushservice'
}
local wizards = {
fondevices_list = {
title = [[{?209:49?}]],
onclick = "",
href = "/assis/home.lua",
hrefparam = "assi=fondevices_list"
},
fonnumbers = {
title = [[{?209:570?}]],
onclick = "",
href = "/fon_num/fon_num_list.lua",
hrefparam = "fonNumMode=asall&back_to_page="..box.glob.script,
explain = [[{?209:234?}]]
},
internet = {
title = [[{?209:660?}]],
onclick = "",
href = "/assis/home.lua",
hrefparam = "assi=internet",
explain = [[{?209:108?}]]
},
diagnosis = {
title = [[{?209:220?}]],
onclick = "",
href = "/system/diagnosis.lua",
hrefparam = "",
explain = [[{?209:870?}]]
},
security = {
title = [[{?209:9228?}]],
onclick = "",
href = "/system/security.lua",
hrefparam = "",
explain = [[{?209:784?}]]
},
imexport = {
title = [[{?209:939?}]],
onclick = "",
href = "/assis/imexport.lua",
hrefparam = "back_to_page="..box.tohtml(box.glob.script),
explain = [[{?209:367?}]]
},
repeater_connect = {
title = [[{?209:609?}]],
onclick = "",
href = "/assis/home.lua",
hrefparam = "assi=repeater_connect",
explain = [[{?209:789?}]]
},
repeater_dvb = {
title = [[{?209:596?}]],
href = "/assis/rep_dvb.lua",
explain = [[{?209:240?}]]
},
repeater_update = {
title = [[{?209:24?}]],
onclick = "",
href = "/system/update.lua",
hrefparam = "start=1&check=1&back_to_page="..box.glob.script,
explain = [[{?209:917?}]]
},
update = {
title = [[{?209:265?}]],
onclick = "",
href = "/system/update.lua",
hrefparam = "start=1&check=1&back_to_page="..box.glob.script,
explain = [[{?209:300?}]]
},
pushservice = {
title = [[{?209:639?}]],
onclick = "",
href = "/assis/pushmail_account.lua",
hrefparam = "back_to_page="..box.glob.script,
explain = [[{?209:356?}]]
}
}
function get_link(linkTo,...)
return href.get(linkTo,...)
end
function FonConfig_SkipToNumberConfig(nextpage)
return fon_nr_config.SkipToNumberConfig(nextpage)
end
function DoFonLotse()
local HTMLConfigAssiTyp = "FonOnly"
if (fon_nr_config.NoNumbersExist()) then
FonConfig_SkipToNumberConfig('/assis/assi_fondevices_list.lua')
return
end
http.redirect(get_link('/assis/assi_fondevices_list.lua','HTMLConfigAssiTyp='..HTMLConfigAssiTyp))
end
function DoVoipFonLotse()
local filename = ""
local HTMLConfigAssiTyp = "VOIPFON"
if (config.CAPI_TE) or (config.CAPI_POTS) then
if config.TR069 then
if box.query("telcfg:settings/ShowPSTN") == "0" then
filename = "first_Start_Sip"
http.redirect(get_link('/first/'..filename..'.lua','HTMLConfigAssiTyp='..HTMLConfigAssiTyp))
return
end
end
http.redirect(get_link('/fon_config/fon_config_list.lua','HTMLConfigAssiTyp='..HTMLConfigAssiTyp))
else
if config.AB_COUNT >= 1 or config.FON_IPPHONE then
filename = "first_Start_Sip"
http.redirect(get_link('/first/'..filename..'.lua','HTMLConfigAssiTyp='..HTMLConfigAssiTyp))
end
end
end
function DoInternetLotse()
if config.LTE then
http.redirect(href.get("/assis/internet_lte.lua"))
end
if (config.oem=="1und1" or true) and config.USB_GSM then
if box.query("umts:settings/enabled") == '1' then
http.redirect(href.get('/assis/umts_query.lua'))
return
end
end
http.redirect(href.get("/assis/internet_dsl.lua"))
end
function DoDiagnosis()
http.redirect(href.get("/system/diagnosis.lua"))
end
function DoSecurity()
http.redirect(href.get("/system/security.lua"))
end
function DoRepLotse()
local params = {}
table.insert(params,'HTMLConfigAssiTyp=normal')
http.redirect(href.get_paramtable('/system/rep_mode.lua',params))
end
if box.get.assi ~= nil then
local v = box.get.assi
if v == "fondevices_list" then
fon_nr_config.InitFromBox("Fon","ANALOG","T")
capiterm.var("g_NrInfo",fon_nr_config.g_NrInfo)
capiterm.var("box.get.assi",box.get.assi)
DoFonLotse()
-- elseif v == "fonnumbers" then
-- fon_nr_config.InitFromBox("Fon","ANALOG","T")
-- capiterm.var("g_NrInfo",fon_nr_config.g_NrInfo)
-- capiterm.var("box.get.assi",box.get.assi)
-- DoVoipFonLotse()
elseif v == "internet" then
DoInternetLotse()
elseif v == "diagnosis" then
DoDiagnosis()
elseif v == "security" then
DoSecurity()
elseif v == "repeater_connect" then
DoRepLotse()
end
end
local sipreadonly = box.query("sipextra:settings/gui_readonly") == "1"
local fon_fixed_line = config.CAPI_TE or config.CAPI_POTS or config.AB_COUNT > 0 or config.FON_IPPHONE
wizards.fondevices_list.show = config.FON and fon_fixed_line
wizards.fonnumbers.show = config.FON and fon_fixed_line
if not(config.CAPI_TE) and not(config.CAPI_POTS) and sipreadonly then
wizards.fonnumbers.show = false
end
wizards.internet.show = not (config.ATA and config.ATA_FULL)
if config.DOCSIS then
wizards.internet.show = false
end
wizards.diagnosis.show = menu.check_page("system", "/system/diagnosis.lua")
wizards.security.show = menu.check_page("system", "/system/security.lua")
wizards.imexport.show = true
wizards.pushservice.show = config.MAILER or config.MAILER2
wizards.repeater_dvb.show = false
wizards.repeater_connect.show = false
wizards.repeater_update.show = false
wizards.imexport.show = true
wizards.update.show = menu.check_page("system", "/system/update.lua")
local fon = fon_fixed_line
local ab = config.AB_COUNT >= 1 or config.TAM_MODE > 0
local fax = config.AB_COUNT >= 1 or config.FAX2MAIL
local isdn = config.CAPI_NT
local dect = config.DECT2
if fon and ab and fax and isdn and dect then
wizards.fondevices_list.explain = [[{?209:286?}]]
elseif fon and ab and fax and isdn and not dect then
wizards.fondevices_list.explain = [[{?209:723?}]]
elseif fon and ab and fax and not isdn and dect then
wizards.fondevices_list.explain = [[{?209:739?}]]
elseif fon and ab and fax and not isdn and not dect then
wizards.fondevices_list.explain = [[{?209:290?}]]
elseif fon and not ab and not fax and not isdn and dect then
wizards.fondevices_list.explain = [[{?209:696?}]]
elseif fon and not ab and not fax and not isdn and not dect then
wizards.fondevices_list.explain = [[{?209:203?}]]
elseif not fon and not ab and fax and not isdn and not dect then
wizards.fondevices_list.explain = [[{?209:754?}]]
elseif fon and ab and not fax and not isdn and not dect then
wizards.fondevices_list.explain = [[{?209:577?}]]
else
wizards.fondevices_list.explain = [[{?209:273?}]]
end
local function sort_wizards()
local to_show = {}
for _, wizard_name in ipairs(order) do
if wizards[wizard_name].show then
table.insert(to_show, wizards[wizard_name])
end
end
local n = #to_show
local half = math.floor((n + 1)/2)
local result, right_idx = {}
for left_idx = 1, half do
table.insert(result, to_show[left_idx])
right_idx = half + left_idx
if right_idx <= n then
table.insert(result, to_show[right_idx])
end
end
return result
end
function write_wizards()
capiterm.txt_nl("InitFromBox", g_CapitermInfo)
fon_nr_config.InitFromBox("Fon", "ANALOG", "C2A=T")
capiterm.var("g_NrInfo",fon_nr_config.g_NrInfo)
if (fon_nr_config.NoNumbersExist()) then
wizards.fondevices_list.onclick="AlertNumber()"
end
local sorted = sort_wizards()
local is_left = false
for _, wizard in ipairs(sorted) do
if wizard.show then
is_left = not is_left
box.out([[<div class="]])
box.out(is_left and [[left]] or [[right]])
box.out([[">]])
box.out([[<p class="wizlink"><img src="/css/default/images/marker_fuer_2_menueebene.gif"><a href="]])
local params = {}
table.insert(params,wizard.hrefparam)
box.out(href.get_paramtable(wizard.href,params))
if wizard.onclick then
box.out([[" onclick="]], wizard.onclick)
end
if wizard.target then
box.out([[" target="]]..box.tohtml(wizard.target))
end
box.out([[">]])
box.html(wizard.title)
box.out([[</a></p>]])
box.out([[<p class="explain">]])
box.html(wizard.explain)
box.out([[</p>]])
box.out([[</div>]])
end
end
box.out("<div style=\"clear:both;\"></div>")
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/twocolumns.css">
<?include "templates/page_head.html" ?>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type='text/javascript'>
function AlertNumber()
{
alert("{?209:557?}");
}
</script>
<h3>{?209:620?}</h3>
<div id="uiWizards" class="twocolumns">
<?lua
write_wizards()
?>
</div>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
