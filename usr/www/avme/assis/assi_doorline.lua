<?lua
dofile("../templates/global_lua.lua")
require("capiterm")
require("http")
require("fon_nr_config")
require("html_check")
require("assi_control")
require("val")
require("general")
g_CapitermEnabled = "F"
g_CapitermInfo = assi_control.TraceStart(g_CapitermEnabled, box.glob.script)
g_OptionTable = {}
g_Alert = {}
g_Box = { WhoAmI = box.glob.script,
ExpertMode = fon_nr_config.Query("box:settings/expertmode/activated", g_CapitermInfo),
FinishPage = "/assis/assi_fondevices_list.lua",
WorkAs = "Assi",
DeviceTyp = "Fon",
TechTyp = "ANALOG",
EditTab = "Übersicht",
EditDeviceNo = "",
CurrSide = "WizardDoorlineInstallation",
PageTitle = "",
PageTitleParam = ""
}
g_BoxRefresh = { { Token = "Back2Page", WorkAs = {"Assi"},
Control = "nil", Init = "/assis/assi_telefon_start.lua"
},
{ Token = "StartPage", WorkAs = {"Assi"},
Control = "nil", Init = "/assis/home.lua"
},
{ Token = "FreeIpPhoneTsvIndex", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "nil", Init = -1
},
{ Token = "Port", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "Notation", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = "{?663:830?}"
},
{ Token = "Num_Org0", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = "11"
},
{ Token = "Num_Org1", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = "12"
},
{ Token = "Num_Org2", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = "13"
},
{ Token = "Num_Org3", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = "14"
},
{ Token = "Num_Rep0", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "Num_Rep1", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "Num_Rep2", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "Num_Rep3", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "Signal0", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = "9"
},
{ Token = "Signal1", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = "9"
},
{ Token = "Signal2", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = "9"
},
{ Token = "Signal3", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = "9"
}
}
g_Const = { AbCount = config.AB_COUNT,
DectCount = 6,
IpCount = 10,
NtHotDialListEntry = 8,
FaxModemCount = 3,
MaxNotationLen = 31,
MaxPasswordLen = 32,
MaxDectNotationLen = 19,
RingTestDialPortIsdn = "50",
MaxHourMinuteLen = 2,
MaxAlarmRingTone = 3
}
g_SideList = {WizardDoorline = {"WizardDoorlineInstallation", "WizardDoorlineSettings", "WizardDoorlineSummary"}}
g_SideHeader = { { Id = {"WizardDoorlineInstallation"},
Head = [[{?663:941?}]]
},
{ Id = {"WizardDoorlineSettings"},
Head = [[{?663:317?}]]
},
{ Id = {"WizardDoorlineSummary"},
Head = [[{?663:741?}]]
}
}
g_Txt = {
FonNAnalog = [[{?663:858?}]],
Zurueck = [[{?g_txt_Zurueck?}]],
Weiter = [[{?g_txt_Weiter?}]],
Uebernehmen = [[{?g_txt_Uebernehmen?}]],
Abbrechen = [[{?g_txt_Abbrechen?}]],
belegt= [[{?663:621?}]]
}
g_val = {
prog = [[
not_empty(Id_Notation/New_Notation, name_error)
]]
}
local name_err = [[{?663:724?}]]
val.msg.name_error = {
[val.ret.notfound] = name_err,
[val.ret.empty] = name_err
}
val.msg.num_err = {
[val.ret.notfound] = [[{?663:655?}]],
[val.ret.empty] = [[{?663:549?}]],
[val.ret.format] = [[{?663:329?}]]
}
function SetBoxAnalogPortVariable(Index, Target, Source)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@SetBoxAnalogPortVariable")
g_Box["AnalogPort" .. Index .. Target] = fon_nr_config.Query("telcfg:settings/MSN/Port" .. Index - 1 .. "/" .. Source, CapitermInfo)
end
function LoadFromBox(BoxVariablen)
if g_CapitermEnabled == "T" then
capiterm.txt_nl("LoadFromBox", g_CapitermInfo)
end
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@LoadFromBox")
assi_control.InitWithDefaults(BoxVariablen)
for Index = 1, g_Const.AbCount, 1 do
SetBoxAnalogPortVariable(Index, "Name", "Name")
SetBoxAnalogPortVariable(Index, "OutDialing", "OutDialing")
SetBoxAnalogPortVariable(Index, "DoorlineNumOriginal"..Index, "DoorlineNumOriginal"..Index)
SetBoxAnalogPortVariable(Index, "DoorlineNumReplace"..Index, "DoorlineNumReplace"..Index)
end
g_OptionTable = assi_control.PrepareOptionList(false, "Door", [[{?g_txt_Telefon?}]])
end
function HandleSubmitSave()
if box.post.Submit_Save == nil then
return
end
if g_CapitermEnabled == "T" then
capiterm.txt_nl("HandleSubmitSave", g_CapitermInfo)
end
local Table = {}
local port = g_Box.Port
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port"..port.."/OutDialing", "2")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port"..port.."/Name", g_Box.Notation)
for Index = 0, 3, 1 do
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port"..port.."/DoorlineNumOriginal"..Index, g_Box["Num_Org"..Index])
local rep = g_Box["Signal"..Index]
if g_Box["Signal"..Index] == "outNum" then
rep = g_Box["Num_Rep"..Index]
end
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port"..port.."/DoorlineNumReplace"..Index, rep)
end
fon_nr_config.Table2BoxShow(Table, "Table2BoxSend")
box.set_config(Table)
local FinishPage = assi_control.GetDefaultFinishPage(g_Box.FinishPage)
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(FinishPage, params))
end
function HandleSubmitBack()
if box.post.Submit_Back ~= nil then
if g_Box.CurrSide == g_SideList.WizardDoorline[1] then
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_Box.Back2Page or g_Box.StartPage,params))
else
assi_control.SetNewPage(g_SideList.WizardDoorline, -1)
end
return true
end
return false
end
function HandleSubmitNext()
if box.post.Submit_Next ~= nil then
assi_control.SetNewPage(g_SideList.WizardDoorline, 1)
return true
end
return false
end
function HandleSubmitAbort()
if box.post.cancel ~= nil then
assi_control.HandleDefaultSubmitAbort(g_Box.StartPage)
end
end
function SwitchToNextSide()
if g_CapitermEnabled == "T" then
capiterm.txt_nl("SwitchToNextSide", g_CapitermInfo)
end
HandleSubmitAbort()
if HandleSubmitBack() then
return
end
if HandleSubmitNext() then
return
end
HandleSubmitSave()
end
function setValidation()
g_val.prog = [[]]
if g_Box.CurrSide == "WizardDoorlineInstallation" then
g_val.prog = [[
not_empty(Id_Notation/New_Notation, name_error)
char_range_regex(Id_Notation/New_Notation, name_ex, name_error)
]]
end
if g_Box.CurrSide == "WizardDoorlineSettings" then
for i = 0, 3, 1 do
g_val.prog = g_val.prog..[[
is_num_in_enh(Id_Num_Org]]..i..[[/Num_Org]]..i..[[, num_err)
if __value_equal(id_Signal]]..i..[[/Signal]]..i..[[, outNum) then
is_num_in_enh(Id_Num_Rep]]..i..[[/Num_Rep]]..i..[[, num_err)
end
]]
end
end
end
function Reloaded()
g_OptionTable = assi_control.PrepareOptionList(true, "Door", [[{?g_txt_Telefon?}]])
fon_nr_config.HiddenValuesFromBox(false)
SwitchToNextSide()
setValidation()
end
assi_control.Main("F", g_SideList.WizardDoorline[1], false)
assi_control.DebugAll()
function Htm2Box(Text)
html_check.tobox(Text)
end
function Multiside_WizardDoorlineInstallation()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<ol>")
Htm2Box( "<li>")
Htm2Box( [[{?663:67?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?663:352?}]])
Htm2Box( "</li>")
Htm2Box( "<div>")
local notation = ""
local check = true
for _, Curr in pairs(g_OptionTable) do
notation = "Option"..Curr.Port.."Notation"
local CurrName = Curr.Name
local moreinfo = ""
local moreinfolabel = ""
if g_Box.Port == Curr.Port and Curr.IsFree then
check = true
moreinfo = string_op.txt_checked(true)
elseif not Curr.IsFree then
check = false
CurrName = CurrName .. " - " .. g_Txt.belegt
moreinfo = "disabled"
moreinfolabel = "class='disabled'"
elseif not check then
moreinfo = string_op.txt_checked(true)
end
Htm2Box( "<p>")
assi_control.InputField( "InputLabel", "radio", "Port", "++"..Curr.Port, CurrName, nil, nil, Curr.Port, moreinfo, "", moreinfolabel)
Htm2Box( "</p>")
end
Htm2Box( "</div>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?663:355?}]])
Htm2Box( "</li>")
Htm2Box( "<div>")
assi_control.InputField( "Input", "text", "Notation", nil, [[{?663:442?}]], 31 + 2, 31, g_Box.Notation, "", "", "")
Htm2Box( "</div>")
Htm2Box( "</ol>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_WizardDoorlineSettings()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?663:649?}]])
Htm2Box( "</p>")
Htm2Box( "<table class='zebra'>")
Htm2Box( "<tr>")
Htm2Box( '<th class="width">{?663:434?}</th>')
Htm2Box( '<th class="width">{?663:90?}</th>')
Htm2Box( "<th>{?663:531?}</th>")
Htm2Box( "</tr>")
require("fon_devices_html")
for i = 0, 3, 1 do
local rep = g_Box["Signal"..i]
if g_Box["Signal"..i] == "outNum" then
rep = g_Box["Num_Rep"..i]
end
box.out(fon_devices_html.get_doorline_bell(i, g_Box["Num_Org"..i], rep))
end
Htm2Box( "</table>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_WizardDoorlineSummary()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?663:68?}]])
Htm2Box( "</p>")
Htm2Box( "<table class='ClassSummaryListTable zebra'>")
assi_control.SummaryTableLine( 1, [[{?g_txt_Telefoniegeraet?}]], [[{?663:98?}]], "")
assi_control.SummaryTableLine( 1, [[{?663:234?}]], g_Box.Notation, "")
assi_control.SummaryTableLine( 2, [[{?663:40?}]], general.sprintf(g_Txt.FonNAnalog, tonumber(g_Box.Port) + 1), "")
Htm2Box( "</table>")
Htm2Box( "<p>")
Htm2Box( [[{?g_txt_ZumSpeichernUebernehmenKlicken?}]])
Htm2Box( "</p>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Save", g_Txt.Uebernehmen, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
g_page_title = general.sprintf(g_Box.PageTitle, g_Box.PageTitleParam)
g_page_type = string_op.bool_to_value(g_Box.WorkAs == "Assi", "no_menu", "")
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/fon_nr_config.css">
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<?lua
box.out([[<script type="text/javascript" src="/js/wizard.js?lang=]], config.language, [["></script>]])
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<script type="text/javascript">
<?lua
require("val")
val.write_js_error_strings()
?>
function uiDoOnMainFormSubmit()
{
<?lua
require("val")
val.write_js_checks(g_val)
?>
return true;
}
function onSignalChange(elem, replaceInput){
var value = jxl.getValue(elem);
if (value == "outNum"){
jxl.show(replaceInput);
}
else {
jxl.hide(replaceInput);
}
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "Submit_Back,Submit_Next", "uiMainForm"));
</script>
<style type="text/css">
table.span.label {
display: inline-block;
width: 120px;
}
.width {
width: 200px;
}
</style>
<?include "templates/page_head.html" ?>
<?lua
Htm2Box("<form id='uiMainForm' method='POST' action='" .. box.glob.script .. "'>")
capiterm.var("g_Box init2", g_Box.CurrSide, g_CapitermInfo)
assi_control.LoadHtmlSide()
assi_control.AddHiddenSID()
assi_control.HiddenValues(g_Box.CurrSide)
assi_control.AddOtherHiddenInputs()
Htm2Box("</form>")
html_check.debug()
?>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
