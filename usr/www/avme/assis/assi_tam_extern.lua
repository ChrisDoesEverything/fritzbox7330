<?lua
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
g_OptionTable = {}
g_Alert = {}
g_Box = { WhoAmI = box.glob.script,
FinishPage = "/assis/assi_fondevices_list.lua",
WorkAs = "Assi",
DeviceTyp = "Tam",
TechTyp = "EXTERN",
EditTab = "Übersicht",
EditDeviceNo = "",
CurrSide = "AssiTamExternConnecting",
PageTitle = "",
PageTitleParam = ""
}
g_BoxRefresh = { { Token = "Back2Page", WorkAs = {"Assi"},
Control = "nil", Init = "/assis/assi_telefon_start.lua"
},
{ Token = "StartPage", WorkAs = {"Assi"},
Control = "nil", Init = "/assis/home.lua"
},
{ Token = "Port", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "Oem", WorkAs = {"Assi"},
Control = "nil", Init = ""
},
{ Token = "Notation", WorkAs = {"Assi"},
Control = "New", Init = ""
}
}
g_Const = { AbCount = config.AB_COUNT,
MaxNotationLen = 31
}
g_SideList = {AssiAbExtern = {"AssiTamExternConnecting", "AssiTamExternIncoming", "AssiTamExternSummary"}}
g_SideHeader = { { Id = {"AssiTamExternConnecting"},
Head = [[{?g_txt_TamGeraetAnschliessen?}]]
},
{ Id = {"AssiTamExternIncoming"},
Head = [[{?g_txt_TamGeraetIncoming?}]]
},
{ Id = {"AssiTamExternSummary"},
Head = [[{?g_txt_TamGeraetSummary?}]]
}
}
g_Txt = { NoNotation = [[{?6123:566?}]],
NotationMaxXChar = [[{?g_txt_NotationMaxXChar?}]],
AufforderungEingabeNotation = [[{?6123:308?}]],
NoPort = [[{?6123:745?}]],
Telefoniegeraet = [[{?g_txt_Telefoniegeraet?}]],
TkAnlage = [[{?g_txt_TkAnlage?}]],
TkAnlageForbidden = [[{?6123:984?}]]
.. "\n"
.. [[{?6123:447?}]]
.. "\n"
.. [[{?6123:344?}]],
belegt = [[{?6123:791?}]],
FonNAnalog = [[{?g_txt_FonNAnalog?}]],
AbGeraet = [[{?g_txt_AbGeraet?}]],
Zurueck = [[{?g_txt_Zurueck?}]],
Weiter = [[{?g_txt_Weiter?}]],
Uebernehmen = [[{?g_txt_Uebernehmen?}]],
Abbrechen = [[{?g_txt_Abbrechen?}]]
}
function SetBoxAnalogPortVariable(Index, Target, Source)
g_Box["AnalogPort" .. Index .. Target]= box.query("telcfg:settings/MSN/Port" .. Index - 1 .. "/" .. Source)
end
function LoadFromBox(BoxVariablen)
if g_CapitermEnabled == "T" then
capiterm.txt_nl("LoadFromBox", g_CapitermInfo)
end
assi_control.InitWithDefaults(BoxVariablen)
for Index = 1, g_Const.AbCount, 1 do
SetBoxAnalogPortVariable(Index, "Name", "Name")
SetBoxAnalogPortVariable(Index, "Fax", "Fax")
SetBoxAnalogPortVariable(Index, "GroupCall", "GroupCall")
SetBoxAnalogPortVariable(Index, "AllIncomingCalls", "AllIncomingCalls")
SetBoxAnalogPortVariable(Index, "OutgoingNr", "MSN0")
end
g_Box.Oem = box.query("env:status/OEM")
g_OptionTable = assi_control.PrepareOptionList(false, "Tam", g_Txt.AbGeraet, "")
end
function CheckSide1()
if g_Box.Port == "42" then
g_Alert.NoPort = g_Txt.NoPort
g_Alert.Side = "AssiTamExternConnecting"
end
if g_Box.Notation == "" then
g_Alert.NoNotation = g_Txt.NoNotation
g_Alert.Side = "AssiTamExternConnecting"
end
if utf8.len(g_Box.Notation) > g_Const.MaxNotationLen then
g_Alert.NotationLen = general.sprintf(g_Txt.NotationMaxXChar, g_Const.MaxNotationLen)
g_Alert.Side = "AssiTamExternConnecting"
end
if g_Box.Notation == g_Txt.TkAnlage then
g_Alert.ReservedNotation = g_Txt.TkAnlageForbidden
g_Alert.Side = "AssiTamExternConnecting"
end
end
function HandleSubmitSave()
if box.post.Submit_Save ~= nil then
if g_CapitermEnabled == "T" then
capiterm.txt_nl("HandleSubmitSave", g_CapitermInfo)
end
local Table = {}
assi_control.ResetAnlogPorts(Table)
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. g_Box.Port .. "/Name", g_Box.Notation)
fon_nr_config.Table2BoxAdd( Table, "telcfg:settings/MSN/Port" .. g_Box.Port .. "/AllIncomingCalls",
string_op.bool_to_value(fon_nr_config.NrInfo().PrevValues.ConnectToAll == "T", "1", "0")
)
fon_nr_config.ValuesToTable( Table, "telcfg:settings/MSN/Port" .. g_Box.Port .. "/MSN", "", nil, nil, "UseName",
"NoSaveOutgoing"
)
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. g_Box.Port .. "/GroupCall", "0")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. g_Box.Port .. "/Fax", "0")
fon_nr_config.Table2BoxSend(Table, "telcfg:settings/MSN/Port" .. g_Box.Port .. "/CallWaitingProt", "0")
local FinishPage = assi_control.GetDefaultFinishPage(g_Box.FinishPage)
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(FinishPage,params))
end
end
function HandleSubmitBack()
if box.post.Submit_Back ~= nil then
if g_Box.CurrSide == g_SideList.AssiAbExtern[1] then
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_Box.Back2Page or g_Box.StartPage,params))
else
assi_control.SetNewPage(g_SideList.AssiAbExtern, -1)
end
return true
end
return false
end
function HandleSubmitNext()
if box.post.Submit_Next ~= nil then
if g_Box.CurrSide == "AssiTamExternIncoming" then
if fon_nr_config.MessageOnInvalidClicks("NoTamIntern", "ShowMessage", "NoCheckOutgoingNr", "ConnectAllExist") then
return true
end
end
assi_control.SetNewPage(g_SideList.AssiAbExtern, 1)
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
g_Alert.Side = ""
CheckSide1()
fon_nr_config.SaveButton("NoFaxWeiche", "NoRemoveOutEqIn", "AddFestnetz")
if (g_Box.CurrSide == "AssiTamExternConnecting") and (g_Box.Port ~= "42") then
g_Box["Option" .. g_Box.Port .. "Notation"] = g_Box.Notation
end
if HandleSubmitBack() then
return
end
if g_Alert.Side ~= "" then
assi_control.SetAbsPageInfo(g_Alert.Side)
return
end
if HandleSubmitNext() then
return
end
HandleSubmitSave()
end
function Reloaded()
g_OptionTable = assi_control.PrepareOptionList(true, "Tam", g_Txt.AbGeraet, "")
fon_nr_config.HiddenValuesFromBox(g_Box.CurrSide == "AssiTamExternIncoming")
SwitchToNextSide()
end
assi_control.Main("C2A=F", g_SideList.AssiAbExtern[1], false)
assi_control.DebugAll()
function Htm2Box(Text)
html_check.tobox(Text)
end
function Multiside_AssiTamExternConnecting()
Htm2Box( "<script type='text/javascript'>")
box.out( "var gPort = " .. g_Box.Port .. ";\n")
box.out( "function Cb_ChangePort(NewPort)\n")
box.out( "{\n")
box.out( "jxl.display('Id_AlertNoPort', NewPort == '42');\n")
box.out( "jxl.setValue('Id_Old_Option' + gPort + 'Notation', jxl.getValue('Id_Notation'));\n")
box.out( "gPort = NewPort;\n")
box.out( "jxl.setValue('Id_Notation', jxl.getValue('Id_Old_Option' + gPort + 'Notation'));\n")
box.out( "Cb_Notation(jxl.getValue('Id_Notation'));\n")
box.out( "}\n")
box.out( "function Cb_Submit()\n")
box.out( "{\n")
box.out( "var NoPort = jxl.getChecked('Id_Port42');\n")
box.out( "var Notation = jxl.getValue('Id_Notation');\n")
fon_nr_config.BoxAlert("NoPort", g_Txt.NoPort)
fon_nr_config.BoxAlert("Notation == ''", g_Txt.NoNotation)
fon_nr_config.BoxAlert( "Notation.length > " .. g_Const.MaxNotationLen,
general.sprintf(g_Txt.NotationMaxXChar, g_Const.MaxNotationLen)
)
fon_nr_config.BoxAlert("Notation == '" .. g_Txt.TkAnlage .. "'", g_Txt.TkAnlageForbidden)
box.out( "return true;\n")
box.out( "}\n")
box.out( "function Cb_Notation(Value)\n")
box.out( "{\n")
box.out( "jxl.display('Id_AlertNoNotation', Value == '');\n")
box.out( "jxl.display('Id_AlertNotationLen', Value.length > " .. g_Const.MaxNotationLen .. ");\n")
box.out( "jxl.display('Id_AlertReservedNotation', Value == '" .. g_Txt.TkAnlage .. "');\n")
box.out( "}\n")
Htm2Box( "</script>")
Htm2Box( "<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<ol>")
Htm2Box( "<li>")
Htm2Box( [[{?6123:492?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?6123:216?}]])
Htm2Box( "</li>")
local Notation = g_Box.Notation
Htm2Box( "<div>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNoPort", g_Alert.NoPort)
local defaultcheck = 0
for _, Curr in pairs(g_OptionTable) do
if Curr.IsFree and (g_Box.Port == Curr.Port) then
defaultcheck = 1
end
end
local firstCheck = 1
for LfNr, Curr in pairs(g_OptionTable) do
local check
if defaultcheck == 1 then
if Curr.IsFree and (g_Box.Port == Curr.Port) then
Notation = g_Box["Option" .. Curr.Port .. "Notation"]
end
check = Curr.IsFree and (g_Box.Port == Curr.Port)
else
if Curr.IsFree then
check = (LfNr==firstCheck)
else
check = false
firstCheck = firstCheck + 1
end
if check then
Notation = g_Box["Option" .. Curr.Port .. "Notation"]
end
end
local CurrName = Curr.Name
local moreinfo = string_op.txt_checked(check)
local moreinfolabel = ""
if not Curr.IsFree then
CurrName = CurrName .. " - " .. g_Txt.belegt
moreinfo = moreinfo .. " disabled"
moreinfolabel = "class='disabled'"
end
moreinfo = moreinfo .. " onclick='Cb_ChangePort(value)'"
box.out( "<p>")
assi_control.InputField( "InputLabel", "radio", "Port", "++"..Curr.Port,
CurrName,
nil, nil, Curr.Port, moreinfo,
"", moreinfolabel)
box.out( "</p>")
end
Htm2Box( "</div>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( g_Txt.AufforderungEingabeNotation)
Htm2Box( "</li>")
Htm2Box( "<div>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNoNotation", g_Alert.NoNotation)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNotationLen", g_Alert.NotationLen)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertReservedNotation", g_Alert.ReservedNotation)
assi_control.InputField( "Input", "text", "Notation", nil,
[[{?6123:524?}]], g_Const.MaxNotationLen,
g_Const.MaxNotationLen, Notation, "", "Cb_Notation(value)", ""
)
Htm2Box( "</div>")
Htm2Box( "</ol>")
Htm2Box( "</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, " onclick='return Cb_Submit();'", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiTamExternIncoming()
Htm2Box( "<script type='text/javascript'>")
box.out( "function Cb_Submit()\n")
box.out( "{\n")
box.out( "if (jxl.getChecked('Id_" .. fon_nr_config.g_Id_ToogleBoxIsConnectToAll .. "'))\n")
box.out( "{\n")
box.out( "jxl.hide('Id_ConnectAllOrUserArea');\n")
box.out( "jxl.hide('Id_IncomingNrTable');\n")
box.out( "jxl.hide('Id_BtnBack');\n")
box.out( "jxl.hide('Id_BtnNext');\n")
box.out( "jxl.hide('Id_BtnAbort');\n")
box.out( "jxl.show('Id_Waiting');\n")
box.out( "fon_nr_config_EnableAllIncomingNr();\n")
box.out( "}\n")
box.out( "return true;\n")
box.out( "}\n")
Htm2Box( "</script>")
Htm2Box( "<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<div id='Id_ConnectAllOrUserArea'>")
Htm2Box( "<p>")
Htm2Box( [[{?6123:302?}]])
Htm2Box( "</p>")
fon_nr_config.BoxOutHtmlCode_Connect2UserOrAll("ClassRadioButton", "")
fon_nr_config.BoxOutErrorLines("ClassAlert", {})
Htm2Box( "</div>")
Htm2Box( "<table class='ClassNumberSelectListTable' id='Id_IncomingNrTable'>")
fon_nr_config.BoxOutHtmlCode_IncomingNr( "AssiIn",
fon_nr_config.NrInfo().PrevValues.OutgoingNr,
"CheckBoxen", "CheckClicked", "DefNrClassIds", "Label",
'fon_nr_config_OnClickNr("", id)', 0
)
Htm2Box( "</table>")
Htm2Box( "<div id='Id_Waiting' " .. string_op.txt_style_display_none(true) .. ">")
Htm2Box( [[{?6123:403?}]])
Htm2Box( "</div>")
Htm2Box( "</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, " onclick='return Cb_Submit();'", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiTamExternSummary()
Htm2Box( "<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?6123:190?}]])
Htm2Box( "</p>")
Htm2Box( "<table class='ClassSummaryListTable zebra'>")
assi_control.SummaryTableLine(1, g_Txt.Telefoniegeraet, g_Txt.AbGeraet, "")
assi_control.SummaryTableLine(2, [[{?6123:434?}]], g_Box.Notation, "")
assi_control.SummaryTableLine( 1, [[{?6123:770?}]],
assi_control.GetPortName(g_Box.Port), ""
)
assi_control.SummaryTableLine( 2, [[{?6123:294?}]],
"", "InCall"
)
Htm2Box( "</table>")
Htm2Box( "<p>")
Htm2Box( [[{?g_txt_ZumSpeichernUebernehmenKlicken?}]])
Htm2Box( "</p>")
Htm2Box( "</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Save", g_Txt.Uebernehmen, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
g_page_title = general.sprintf(g_Box.PageTitle, g_Box.PageTitleParam)
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<link rel="stylesheet" type="text/css" href="/css/default/fon_nr_config.css">
<?include "templates/page_head.html" ?>
<?lua
box.out([[<script type="text/javascript" src="/js/wizard.js?lang=]], config.language, [["></script>]])
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
Htm2Box("<form method='POST' action='" .. box.glob.script .. "'>")
assi_control.LoadHtmlSide()
assi_control.AddHiddenSID()
assi_control.HiddenValues(g_Box.CurrSide)
assi_control.AddOtherHiddenInputs()
Htm2Box("</form>")
fon_nr_config.JavaScriptCb_NrHandling(g_Box.CurrSide == "AssiTamExternIncoming", false, true, g_Box.WorkAs,true)
html_check.debug()
?>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
