<?lua
--[[
Datei Name: assi_telefon_start.lua
Datei Beschreibung: FRITZ!Box Telefoniegeräte einrichten
]]
dofile("../templates/global_lua.lua")
require("capiterm")
require("http")
require("fon_nr_config")
require("general")
require("string_op")
require("html_check")
require("assi_control")
g_page_type="wizard"
g_CapitermEnabled = "F"
g_CapitermInfo = assi_control.TraceStart(g_CapitermEnabled, box.glob.script)
g_Alert = {}
g_Box = { WhoAmI = box.glob.script,
StartPage = "/assis/home.lua",
WorkAs = "Assi",
DeviceTyp = "",
TechTyp = "",
EditTab = "",
CurrSide = "",
PageTitle = "{?737:441?}",
Back2Page = "/assis/assi_fondevices_list.lua",
PageTitleParam = ""
}
g_Const = { AbCount = config.AB_COUNT,
FaxModemCount = 3,
TamMaxCount = 5,
DectCount = 6,
IpCount = 10,
NtHotDialListEntry = 8,
MaxNotationLen = 31
}
g_SideOptionList = {
["Fon"] = "/assis/assi_telefon.lua",
["IntFax"] = "/assis/assi_fax_intern.lua",
["Fax"] = "/assis/assi_fax_extern.lua",
["IntTam"] = "/assis/assi_tam_intern.lua",
["Tam"] = "/assis/assi_tam_extern.lua",
["Isdn"] = "/assis/assi_isdn_telefonanlage.lua",
["Door"] = "/assis/assi_doorline.lua"
}
g_Txt = { FaxGeraet = [[{?g_txt_FaxGeraet?}]],
Zurueck = [[{?g_txt_Zurueck?}]],
Weiter = [[{?g_txt_Weiter?}]],
IPPhone = [[{?g_txt_IPPhone?}]],
Abbrechen = [[{?g_txt_Abbrechen?}]],
Meldung1 = [[{?737:590?}]]
}
if next(box.post) then
if box.post.continue then
fon_nr_config.SkipToNumberConfig('/assis/home.lua')
end
end
function GetIpPhoneNameSuffixNr(IpPhoneNames)
local IpPhone = g_Txt.IPPhone .. " "
for Minimum = 1, g_Const.IpCount - 1, 1 do
local Used = false
for Index = 1, #IpPhoneNames, 1 do
if IpPhoneNames[Index] == (IpPhone .. Minimum) then
Used = true
break
end
end
if not Used then
return tostring(Minimum)
end
end
return ""
end
function LoadFromBox()
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@LoadFromBox")
if g_CapitermEnabled == "T" then
capiterm.txt_nl("LoadFromBox", g_CapitermInfo)
end
local RefreshFirst = fon_nr_config.Query("telcfg:settings/Foncontrol", CapitermInfo)
for Index = 1, config.AB_COUNT, 1 do
SetBoxAnalogPortVariable(Index, "Name", "Name")
SetBoxAnalogPortVariable(Index, "Fax", "Fax")
SetBoxAnalogPortVariable(Index, "GroupCall", "GroupCall")
SetBoxAnalogPortVariable(Index, "AllIncomingCalls", "AllIncomingCalls")
SetBoxAnalogPortVariable(Index, "OutgoingNr", "MSN0")
end
g_Box.Oem = fon_nr_config.Query("env:status/OEM", CapitermInfo)
g_Box.FreeNtHotDialIndex = -1
if config.CAPI_NT then
local already_configuered=0
for Index = 1, g_Const.NtHotDialListEntry, 1 do
g_Box["Isdn" .. Index .. "Number"] = fon_nr_config.Query("telcfg:settings/NTHotDialList/Number" .. Index, CapitermInfo)
g_Box["Isdn" .. Index .. "Name"] = fon_nr_config.Query("telcfg:settings/NTHotDialList/Name" .. Index, CapitermInfo)
g_Box["Isdn" .. Index .. "Type"] = fon_nr_config.Query("telcfg:settings/NTHotDialList/Type" .. Index, CapitermInfo)
if string.lower(g_Box["Isdn"..Index.."Type"]) == "fax" then
already_configuered=already_configuered+1
end
if fon_nr_config.Query("telcfg:settings/NTHotDialList/Number" .. Index, CapitermInfo) == "" then
if g_Box.FreeNtHotDialIndex == -1 then
g_Box.FreeNtHotDialIndex = Index
end
end
end
for Index = 0, g_Const.FaxModemCount - 1, 1 do
g_Box["FaxModem" .. Index .. "Number"] = fon_nr_config.Query("telcfg:settings/FaxModem" .. Index .. "/Number", CapitermInfo)
end
g_Box.FaxModemListSelector=""
if already_configuered < g_Const.FaxModemCount then
g_Box.FaxModemListSelector=assi_control.GetFreeFaxModemListSelector("")
end
end
if(config.FAX2MAIL) then
g_Box.FaxMailActive = fon_nr_config.Query("telcfg:settings/FaxMailActive", CapitermInfo)
end
if config.DECT then
g_Box.FreeDectPort = nil
for Index = 0, g_Const.DectCount - 1, 1 do
if fon_nr_config.Query("dect:settings/Handset" .. Index .. "/Subscribed", CapitermInfo) == "0" then
g_Box.FreeDectPort = Index + 1
break
end
end
end
if config.FON_IPPHONE then
local IpPhoneNames = {}
for Index = 0, g_Const.IpCount - 1, 1 do
table.insert( IpPhoneNames,
fon_nr_config.Query("telcfg:settings/VoipExtension" .. Index .. "/Name", CapitermInfo)
)
if (fon_nr_config.Query("telcfg:settings/VoipExtension" .. Index .. "/enabled", CapitermInfo) ~= "1")
and (g_Box.FreeIpPhoneTsvIndex == nil or g_Box.FreeIpPhoneTsvIndex == -1)
then
g_Box.FreeIpPhoneTsvIndex = Index
end
if ( fon_nr_config.Query("voipextension:settings/extension" .. Index .. "/enabled", CapitermInfo)
~= "1"
) and (g_Box.FreeIpPhoneVseIndex == nil)
then
g_Box.FreeIpPhoneVseIndex = Index
end
end
g_Box.IpPhoneNameSuffixNr = GetIpPhoneNameSuffixNr(IpPhoneNames)
end
g_Box.UseUsbStick = fon_nr_config.Query("tam:settings/UseStick", CapitermInfo)
g_Box.TamCnt = 0
if (config.TAM_MODE ~= nil) and (tostring(config.TAM_MODE) > "0") then
for Index = 0, g_Const.TamMaxCount - 1, 1 do
if fon_nr_config.Query("tam:settings/TAM" .. Index .. "/Display", CapitermInfo) == "1" then
g_Box.TamCnt = g_Box.TamCnt + 1
end
end
end
g_Box.InternalMemEnabled = fon_nr_config.Query("ctlusb:settings/internalflash_enabled", CapitermInfo)
end
function IsInternalTamAvail()
if (config.TAM_MODE ~= nil) and (tostring(config.TAM_MODE) > "0") then
if g_Box.TamCnt == 5 then
return false
end
return true
else
return false
end
end
function InternFaxFrei ()
if g_Box.FaxMailActive ~= "" then
return false
end
return true
end
function IsInternalFaxAvail()
if( config.FAX2MAIL) then
return InternFaxFrei()
else
return false
end
end
function IsFaxExternAvail()
if config.CAPI_NT then
if g_Box.FaxModemListSelector ~= "" and g_Box.FreeNtHotDialIndex ~= -1 then
return true
end
end
return false
end
function IsAnalogPortAvail()
for Index = 1, g_Const.AbCount, 1 do
local HtmlPort = tostring(Index - 1)
PortName = g_Box["AnalogPort" .. Index .. "Name"]
if (PortName == "") or assi_control.UpdateDefaultExtension(HtmlPort) then
return true
end
end
return false
end
function IsFonDeviceAvail()
if (IsAnalogPortAvail()) then
return true
end
if config.FON_IPPHONE then
if g_Box.FreeIpPhoneTsvIndex ~= nil and g_Box.FreeIpPhoneTsvIndex ~= -1 then
return true
end
end
if config.CAPI_NT then
if g_Box.FreeNtHotDialIndex ~= -1 then
return true
end
end
if config.DECT then
if g_Box.FreeDectPort~=nil then
return true
end
end
return false
end
function IsISDNTKDeviceAvail()
if config.CAPI_NT then
for Index = 1, g_Const.NtHotDialListEntry, 1 do
local Type = g_Box["Isdn" .. Index .. "Type"]
local Number = g_Box["Isdn" .. Index .. "Number"]
if Type == "Isdn" and Number~="" then
return false
end
end
return true
end
return false
end
function SetBoxAnalogPortVariable(Index, Target, Source)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@SetBoxAnalogPortVariable")
g_Box["AnalogPort" .. Index .. Target] = fon_nr_config.Query("telcfg:settings/MSN/Port" .. Index - 1 .. "/" .. Source, CapitermInfo)
end
function HandleSubmitBack()
if box.post.Submit_Back ~= nil then
capiterm.txt_nl("HandleSubmitBack")
assi_control.HandleDefaultSubmitAbort(g_Box.Back2Page)
return true
end
return false
end
function HandleSubmitAbort()
if box.post.cancel ~= nil then
assi_control.HandleDefaultSubmitAbort(g_Box.StartPage)
end
end
function HandleSubmitNext()
if box.post.Submit_Next ~= nil then
capiterm.var("New_DeviceTyp",box.post.New_DeviceTyp)
local params = {}
table.insert(params,'assicall=1')
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_SideOptionList[box.post.New_DeviceTyp] or g_SideOptionList[0],params))
return true
end
return false
end
function HtmlJavaScript()
box.out("<script type='text/javascript'>")
box.out( "function Cb_Start()\n")
box.out( "{\n")
box.out( "//jxl.display('Id_NotationArea', jxl.getValue('Id_Port') != 20);\n")
box.out( "}\n")
box.out( "ready.onReady(Cb_Start);\n")
box.out( "function Cb_Ok()\n")
box.out( "{\n")
box.out( "return true;\n")
box.out( "}\n")
box.out( "function Cb_Submit()\n")
box.out( "{\n")
box.out( "if (! Cb_Ok())\n")
box.out( "{\n")
box.out( "return false;\n")
box.out( "}\n")
box.out( "return true;\n")
box.out( "}\n")
box.out("</script>")
end
function SwitchToNextSide()
if g_CapitermEnabled == "T" then
capiterm.txt_nl("SwitchToNextSide", g_CapitermInfo)
end
HandleSubmitAbort()
g_Alert.Side = ""
if HandleSubmitBack() then
return
end
if HandleSubmitNext() then
return
end
end
function Htm2Box(Text)
html_check.tobox(Text)
end
function HTMLStartFon()
capiterm.var("box.post",box.post)
capiterm.var("box.get",box.get)
HtmlJavaScript()
box.out("<div id='Seite" .. g_Box.CurrSide .. "'>")
box.out( "<div class='formular' id='Id_DataArea'>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNoPort", g_Alert.NoPort)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_NoMoreIsdn", g_Alert.NoMoreIsdn)
box.out( "<p class='mb20'>")
box.out( [[{?737:697?}]])
box.out( "</p>")
if (config.CAPI_NT or config.AB_COUNT >= 1 or config.FON_IPPHONE or config.DECT) then
if IsFonDeviceAvail() then
box.out( "<h4>")
box.out( [[{?737:560?}]])
box.out( "</h4>")
end
box.out( "<p>")
local txt_head= [[{?737:389?}]]
local txt_devices=""
local show=false
if (config.CAPI_NT and config.AB_COUNT >= 1) then
show=true
txt_devices= [[{?737:971?}]]
else
if (config.AB_COUNT >= 1) then
show=true
txt_devices= [[{?737:917?}]]
else
if (config.DECT) then
txt_devices= [[{?737:559?}]]
else
txt_devices= [[{?737:920?}]]
end
end
end
if (show) then
box.out(txt_head)
box.out(txt_devices)
end
end
box.out( "</p>")
if IsFonDeviceAvail() then
box.out( "<p>")
assi_control.InputField( "InputLabel", "radio", "DeviceTyp", "++Fon",
[[{?737:321?}]],
nil, nil, "Fon", string_op.txt_checked(g_Box.TechTyp == "" and (g_Box.DeviceTyp == "Fon" or g_Box.DeviceTyp == "")),
"", "")
box.out( "</p>")
end
if IsAnalogPortAvail() then
box.out( "<p>")
assi_control.InputField( "InputLabel", "radio", "DeviceTyp", "++Tam",
[[{?gTAM?}]],
nil, nil, "Tam", string_op.txt_checked(g_Box.TechTyp == "" and (g_Box.DeviceTyp == "Tam")),
"", "")
box.out( "</p>")
end
if IsISDNTKDeviceAvail() then
box.out( "<p>")
assi_control.InputField( "InputLabel", "radio", "DeviceTyp", "++Isdn",
[[{?737:24?}]],
nil, nil, "Isdn", string_op.txt_checked(g_Box.TechTyp == "" and (g_Box.DeviceTyp == "Isdn")),
"", "")
box.out( "</p>")
end
if IsAnalogPortAvail() or IsFaxExternAvail() then
box.out( "<p>")
assi_control.InputField( "InputLabel", "radio", "DeviceTyp", "++Fax",
[[{?737:565?}]],
nil, nil, "Fax", string_op.txt_checked(g_Box.TechTyp == "" and (g_Box.DeviceTyp == "Fax")),
"", "")
box.out( "</p>")
end
if IsAnalogPortAvail() then
box.out( "<p>")
assi_control.InputField( "InputLabel", "radio", "DeviceTyp", "++Door",
[[{?737:594?}]],
nil, nil, "Door", string_op.txt_checked(g_Box.TechTyp == "" and (g_Box.DeviceTyp == "Door")),
"", "")
box.out( "</p>")
end
if IsInternalTamAvail() or IsInternalFaxAvail() then
box.out( "<h4>")
box.out( [[{?737:158?}]])
box.out( "</h4>")
if config.FAX2MAIL and (config.TAM_MODE ~= nil) and (tostring(config.TAM_MODE) > "0") then
box.out( "<p class='mb10'>")
box.out( [[{?737:174?}]])
box.out( "</p>")
else
if config.FAX2MAIL then
box.out( "<p class='mb10'>")
box.out( [[{?737:637?}]])
box.out( "</p>")
else
if (config.TAM_MODE ~= nil) and (tostring(config.TAM_MODE) > "0") then
box.out( "<p class='mb10'>")
box.out( [[{?737:160?}]])
box.out( "</p>")
end
end
end
if IsInternalTamAvail() then
box.out( "<p>")
assi_control.InputField( "InputLabel", "radio", "DeviceTyp", "++IntTam",
[[{?737:963?}]],
nil, nil, "IntTam", string_op.txt_checked(g_Box.TechTyp == "INTERN" and g_Box.DeviceTyp == "Tam"),
"", "")
box.out( "</p>")
end
if IsInternalFaxAvail() then
box.out( "<p>")
assi_control.InputField( "InputLabel", "radio", "DeviceTyp", "++IntFax",
[[{?737:47?}]],
nil, nil, "IntFax", string_op.txt_checked(g_Box.TechTyp == "INTERN" and g_Box.DeviceTyp == "Fax"),
"", "")
box.out( "</p>")
end
end
box.out( "</div>")
box.out("</div>")
if box.post["HTMLConfigAssiTyp"] then
Htm2Box( "<input type='hidden' name='HTMLConfigAssiTyp' value='" .. box.post["HTMLConfigAssiTyp"] .. "'>")
elseif box.get["HTMLConfigAssiTyp"] then
Htm2Box( "<input type='hidden' name='HTMLConfigAssiTyp' value='" .. box.get["HTMLConfigAssiTyp"] .. "'>")
end
if box.post["FonAssiFromPage"] then
Htm2Box( "<input type='hidden' name='FonAssiFromPage' value='" .. box.post["FonAssiFromPage"] .. "'>")
elseif box.get["FonAssiFromPage"] then
Htm2Box( "<input type='hidden' name='FonAssiFromPage' value='" .. box.get["FonAssiFromPage"] .. "'>")
end
assi_control.AddHiddenSID()
assi_control.AddOtherHiddenInputs()
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, " onclick='return Cb_Submit();'", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
SwitchToNextSide()
g_page_title = general.sprintf(g_Box.PageTitle, g_Box.PageTitleParam)
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<link rel="stylesheet" type="text/css" href="/css/default/fon_nr_config.css">
<?include "templates/page_head.html" ?>
<?lua
box.out([[<script type="text/javascript" src="/js/wizard.js?lang=]], config.language, [["></script>]])
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
fon_nr_config.InitFromBox("Fon","ANALOG","T")
if (fon_nr_config.NoNumbersExist()) then
box.out([[<form method='POST' action=']] .. box.tohtml(box.glob.script) .. [[' name="main_redirect">]])
box.out([[<div class='formular'>
<p>
{?737:260?}
</p>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="]]..box.tohtml(box.glob.sid)..[[">
<button type="submit" name="continue" >{?g_txt_Weiter?}</button>
</div>
]])
box.out("</form>")
else
LoadFromBox()
fon_nr_config.InitFromBox(g_Box.DeviceTyp, g_Box.TechTyp, true)
box.out("<form method='POST' action='" .. box.tohtml(box.glob.script) .. "'>")
HTMLStartFon()
box.out("</form>")
end
html_check.debug()
?>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
