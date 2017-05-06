<?lua
dofile("../templates/global_lua.lua")
require("capiterm")
require("http")
require("fon_nr_config")
require("general")
require("html_check")
require("assi_control")
require"config"
g_page_type="wizard"
g_SimulateTamLoadFail = "0"
g_CapitermEnabled = "F"
g_CapitermInfo = assi_control.TraceStart(g_CapitermEnabled, box.glob.script)
g_Alert = {}
g_Box = { WhoAmI = box.glob.script,
FinishPage = "/assis/assi_fondevices_list.lua",
WorkAs = "Assi",
DeviceTyp = "Tam",
TechTyp = "INTERN",
EditTab = "Übersicht",
EditDeviceNo = "",
CurrSide = "AssiTamInternEinrichten",
PageTitle = "",
PageTitleParam = ""
}
g_BoxRefresh = { { Token = "Back2Page", WorkAs = {"Assi"},
Control = "nil", Init = "/assis/assi_telefon_start.lua"
},
{ Token = "StartPage", WorkAs = {"Assi"},
Control = "nil", Init = "/assis/home.lua"
},
{ Token = "Aura4Storage", WorkAs = {"Assi"},
Control = "nil", Init = ""
},
{ Token = "TamLoadFailReason", WorkAs = {"Assi"},
Control = "nil", Init = ""
},
{ Token = "InfoLedReason", WorkAs = {"Assi"},
Control = "nil", Init = ""
},
{ Token = "OperationMode", WorkAs = {"Assi"},
Control = "New", Init = "1"
},
{ Token = "Delay", WorkAs = {"Assi"},
Control = "New", Init = "4"
},
{ Token = "RecordingLen", WorkAs = {"Assi"},
Control = "New", Init = "60"
},
{ Token = "TamNr", WorkAs = {"Assi"},
Control = "nil", Init = -1
},
{ Token = "TamName", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "UseUsbStick", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "UseUsbMem", WorkAs = {"Assi"},
Control = "SLAssiTamInternEinrichten", Init = "off"
}
}
g_Const = {MaxTamNameLen = 30}
g_SideList = {AssiAbIntern = {"AssiTamInternEinrichten", "AssiTamInternIncoming", "AssiTamInternSummary"}}
g_SideHeader = { { Id = {"AssiTamInternEinrichten"},
Head = [[{?1326:485?}]]
},
{ Id = {"AssiTamInternIncoming"},
Head = [[{?1326:973?}]]
},
{ Id = {"AssiTamInternSummary"},
Head = [[{?1326:775?}]]
}
}
g_Txt = { OperationMode = { [[{?1326:873?}]],
[[{?1326:738?}]]
},
AufforderungEingabeNotation = [[{?1326:6499?}]],
InfoAnzeigeViaLed = [[{?1326:883?}]],
Delay0 = [[{?g_txt_SofortAnnehmen?}]],
RecordingLen0 = [[{?g_txt_KeineZeitbegrenzung?}]],
Sekunden = [[{?g_txt_Sekunden?}]],
UseUsbMemOn = [[{?g_txt_Ja?}]],
UseUsbMemOff = [[{?g_txt_Nein?}]],
Anrufbeantworter = [[{?g_AB?}]],
MaxXChar=[[{?g_txt_MaxXZeichen?}]],
Zurueck = [[{?g_txt_Zurueck?}]],
Weiter = [[{?g_txt_Weiter?}]],
Uebernehmen = [[{?g_txt_Uebernehmen?}]],
Wiederholen = [[{?g_txt_Wiederholen?}]],
Abbrechen = [[{?g_txt_Abbrechen?}]],
Ansageverzoegerung = [[{?g_txt_Ansageverzoegerung?}]],
Aufnahmelaenge = [[{?g_txt_Aufnahmelaenge?}]],
Betriebsart = [[{?g_txt_Betriebsart?}]],
Bezeichnung = [[{?g_txt_Bezeichnung?}]],
FritzVoiceBox = [[{?g_txt_FritzVoiceBox?}]],
NrForIncomingCall = [[{?g_txt_NrForIncomingCall?}]],
Telefoniegeraet = [[{?g_txt_Telefoniegeraet?}]],
UsbMemMoreRecordingCapa = [[{?g_txt_UsbMemMoreRecordingCapa?}]]
}
function LoadFromBox(BoxVariablen)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@LoadFromBox")
assi_control.InitWithDefaults(BoxVariablen)
g_Box.Aura4Storage="0"
if box.query("aura:settings/enabled")=="1" then
g_Box.Aura4Storage = fon_nr_config.Query("aura:settings/aura4storage", CapitermInfo)
end
g_Box.TamLoadFailReason = fon_nr_config.Query("tam:settings/LoadFailReason", CapitermInfo)
require("bit")
g_Box.NoInternalMem = bit.isset(tonumber(fon_nr_config.Query("tam:settings/Status", CapitermInfo)) or 0, 2)
g_Box.InfoLedReason = fon_nr_config.Query("box:settings/infoled_reason", CapitermInfo)
g_Box.UseUsbStick = fon_nr_config.Query("tam:settings/UseStick", CapitermInfo)
for Index = 0, fon_nr_config.g_NrInfo.TamMaxCount - 1, 1 do
if fon_nr_config.Query("tam:settings/TAM" .. Index .. "/Display", CapitermInfo) ~= "1" then
g_Box.TamNr = Index
break
end
end
if g_Box.TamNr == -1 then
if g_CapitermEnabled == "T" then
capiterm.txt_nl("Abbruch, da zu viele AB eingerichtet sind", g_CapitermInfo)
end
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_Box.Back2Page or g_Box.StartPage,params))
end
g_Box.TamName = g_Txt.Anrufbeantworter
if (g_Box.TamNr~=0) then
g_Box.TamName =g_Box.TamName .. " " .. tostring(g_Box.TamNr + 1)
end
if g_Box.UseUsbStick == "" then
g_Box.UseUsbStick = "0"
end
if g_Box.UseUsbStick == "1" then
g_Box.UseUsbMem = "on"
end
if g_Box.TamLoadFailReason == "er" or g_Box.TamLoadFailReason == "2" then
g_Box.TamLoadFailReason = "0"
end
if g_Box.TamLoadFailReason == "255" then
g_Box.TamLoadFailReason = "1"
end
if g_SimulateTamLoadFail ~= "0" then
g_Box.TamLoadFailReason = g_SimulateTamLoadFail
end
end
function CheckSide1()
if not string_op.in_list(g_Box.CurrSide, {"AssiTamInternEinrichten", "AssiTamInternSummary"}) then
return
end
if utf8.len(g_Box.TamName) > g_Const.MaxTamNameLen then
g_Alert.TamNameLen = general.sprintf(g_Txt.MaxXChar, g_Const.MaxTamNameLen)
g_Alert.Side = "AssiTamInternEinrichten"
end
end
function HandleSubmitSave()
if box.post.Submit_Save ~= nil then
if g_CapitermEnabled == "T" then
capiterm.txt_nl("HandleSubmitSave", g_CapitermInfo)
end
local Table = fon_nr_config.TamValuesToTable()
if config.FON then
if (g_Box.InfoLedReason == "9") or (g_Box.InfoLedReason == "13") then
g_Box.InfoLedReason = "13"
else
g_Box.InfoLedReason = "11"
end
fon_nr_config.Table2BoxAdd(Table, "box:settings/infoled_reason", g_Box.InfoLedReason)
end
fon_nr_config.Table2BoxAdd(Table, "tam:settings/TAM" .. g_Box.TamNr .. "/Mode", g_Box.OperationMode)
fon_nr_config.Table2BoxAdd(Table, "tam:settings/TAM" .. g_Box.TamNr .. "/RingCount", g_Box.Delay)
fon_nr_config.Table2BoxAdd(Table, "tam:settings/TAM" .. g_Box.TamNr .. "/RecordLength", g_Box.RecordingLen)
fon_nr_config.Table2BoxAdd(Table, "tam:settings/TAM" .. g_Box.TamNr .. "/Name", g_Box.TamName)
fon_nr_config.Table2BoxAdd(Table, "tam:settings/TAM" .. g_Box.TamNr .. "/Active", "1")
fon_nr_config.Table2BoxAdd(Table, "tam:settings/TAM" .. g_Box.TamNr .. "/Display", "1")
fon_nr_config.Table2BoxAdd(Table, "tam:settings/TAM" .. g_Box.TamNr .. "/PushmailActive", "0")
fon_nr_config.Table2BoxAdd(Table, "tam:settings/TAM" .. g_Box.TamNr .. "/MailAddress", "")
fon_nr_config.Table2BoxAdd(Table, "tam:settings/TAM" .. g_Box.TamNr .. "/PIN", "0000")
local UseStick = "0"
if (g_Box.UseUsbMem == "on") or (g_Box.UseUsbStick == "1") then
UseStick = "1"
end
fon_nr_config.Table2BoxSend(Table, "tam:settings/UseStick", UseStick)
if config.TIMERCONTROL then
require ("fon_devices")
fon_devices.create_tam_empty_timeplans()
end
local FinishPage = assi_control.GetDefaultFinishPage(g_Box.FinishPage)
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(FinishPage,params))
end
end
function HandleSubmitBack()
if box.post.Submit_Back ~= nil then
if g_Box.CurrSide == g_SideList.AssiAbIntern[1] then
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_Box.Back2Page or g_Box.StartPage,params))
end
if g_Box.CurrSide == "AssiTamInternIncoming" then
if fon_nr_config.TamSaveButton(g_Box.TamNr, true) == false then
return true
end
end
assi_control.SetNewPage(g_SideList.AssiAbIntern, -1)
return true
end
return false
end
function HandleSubmitNext()
if box.post.Submit_Next ~= nil then
if g_Box.CurrSide == "AssiTamInternIncoming" then
if fon_nr_config.TamSaveButton(g_Box.TamNr, false) == false then
return true
end
end
assi_control.SetNewPage(g_SideList.AssiAbIntern, 1)
return true
end
return false
end
function HandleSubmitAbort()
if box.post.cancel ~= nil then
assi_control.HandleDefaultSubmitAbort(g_Box.StartPage)
end
end
function HandleSubmitRetry()
if box.post.Submit_Retry ~= nil then
fon_nr_config.Table2BoxSend({}, "tam:settings/UseStick", "1")
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_Box.WhoAmI,params))
end
end
function SwitchToNextSide()
HandleSubmitRetry()
HandleSubmitAbort()
g_Alert.Side = ""
CheckSide1()
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
fon_nr_config.InitTamFromBox(g_Box.TamNr)
fon_nr_config.HiddenValuesFromBox(g_Box.CurrSide == "AssiTamInternIncoming")
SwitchToNextSide()
end
assi_control.Main("F", g_SideList.AssiAbIntern[1], true)
assi_control.DebugAll()
function Htm2Box(Text)
html_check.tobox(Text)
end
function UseUsbMemory()
if g_Box.NoInternalMem then
Htm2Box("<input type='hidden' name='New_UseUsbMem' id='Id_UseUsbMem' value='on'>")
return
end
if g_Box.UseUsbStick ~= "2" then
return
end
local CheckedOrDisabled = ""
CheckedOrDisabled = string_op.txt_disabled(g_Box.UseUsbStick == "0")
if CheckedOrDisabled == "" then
CheckedOrDisabled = string_op.txt_checked(g_Box.UseUsbMem == "on")
end
Htm2Box("<br>")
Htm2Box("<input type='checkbox' name='New_UseUsbMem' id='Id_UseUsbMem'" .. CheckedOrDisabled .. ">")
Htm2Box(g_Txt.UsbMemMoreRecordingCapa)
Htm2Box("<div>")
Htm2Box( g_Txt.FritzVoiceBox)
Htm2Box("</div>")
end
function GetHtmlOptionList(CurrValue, Start, Ende, Step, Text0, TextN, Multiplikator, Minus)
for Index = Start, Ende, Step do
local Selected = ""
local Text = ""
if CurrValue == tostring(Index - Minus) then
Selected = " selected"
end
Htm2Box("<option value='" .. tostring(Index - Minus) .. "'" .. Selected .. ">")
if type(Text0) == "table" then
Htm2Box(Text0[Index])
else
if Index == Start then
Htm2Box(Text0)
else
Htm2Box(Index * Multiplikator .. " " .. TextN)
end
end
Htm2Box("</option>")
end
end
function Multiside_AssiTamInternEinrichten()
Htm2Box("<script type='text/javascript'>")
Htm2Box( "function Cb_OperationMode(Value)\n")
Htm2Box( "{\n")
Htm2Box( "jxl.setDisabled('Id_RecordingLen', jxl.getValue('Id_OperationMode') == '0');\n")
Htm2Box( "}\n")
box.out( "ready.onReady(Cb_OperationMode);\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular grid'>")
Htm2Box( "<ol>")
Htm2Box( "<li>")
Htm2Box( [[{?1326:65?}]])
Htm2Box( "</li>")
Htm2Box( "<div>")
Htm2Box( "<label for='Id_OperationMode'>")
Htm2Box( g_Txt.Betriebsart)
Htm2Box( "</label>")
Htm2Box( "<select name='New_OperationMode' id='Id_OperationMode' size='1' onchange=Cb_OperationMode(value)>")
GetHtmlOptionList(g_Box.OperationMode, 1, #g_Txt.OperationMode, 1, g_Txt.OperationMode, '', 0, 1)
Htm2Box( "</select>")
Htm2Box( "</div>")
Htm2Box( "<div>")
Htm2Box( "<label for='Id_Delay'>")
Htm2Box( g_Txt.Ansageverzoegerung)
Htm2Box( "</label>")
Htm2Box( "<select name='New_Delay' id='Id_Delay' size='1'>")
GetHtmlOptionList(g_Box.Delay, 0, 12, 1, g_Txt.Delay0, g_Txt.Sekunden, 5, 0)
Htm2Box( "</select>")
Htm2Box( "</div>")
Htm2Box( "<div>")
Htm2Box( "<label for='Id_RecordingLen'>")
Htm2Box( g_Txt.Aufnahmelaenge)
Htm2Box( "</label>")
Htm2Box( "<select name='New_RecordingLen' id='Id_RecordingLen' size='1'>")
GetHtmlOptionList(g_Box.RecordingLen, 0, 180, 60, g_Txt.RecordingLen0, g_Txt.Sekunden, 1, 0)
Htm2Box( "</select>")
Htm2Box( "<br>")
UseUsbMemory()
Htm2Box( "</div>")
if g_Box.Aura4Storage == "1" then
Htm2Box("<p>")
box.out( general.sprintf( [[{?1326:348?}]],
[[<a href="]]..href.get('/usb/usb_remote_settings.lua')..[[">]], "</a>"
)
)
Htm2Box("</p>")
end
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( g_Txt.AufforderungEingabeNotation)
Htm2Box( "</li>")
Htm2Box( "<div>")
assi_control.InputField( "Input", "text", "TamName", nil, g_Txt.Bezeichnung,
g_Const.MaxTamNameLen, g_Const.MaxTamNameLen, g_Box.TamName, "", "", ""
)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertTamNameLen", g_Alert.TamNameLen)
Htm2Box( "</div>")
Htm2Box( "</ol>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_TamLoadFailReason1()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. ".1' class='formular'>")
Htm2Box( [[{?1326:1208?}]])
Htm2Box("</div>")
assi_control.CreateButton("@Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_TamLoadFailReason(reason)
reason=tostring(reason)
--if reason=="1" then
Multiside_TamLoadFailReason1()
--end
end
function Multiside_NoInternalMem()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. ".2' class='formular'>")
Htm2Box( [[{?1326:624?}]])
Htm2Box( "<br>")
Htm2Box( "<br>")
if "0" == g_Box.UseUsbStick then
Htm2Box( [[{?1326:199?}]])
else
Htm2Box( [[{?1326:150?}]])
end
Htm2Box("<input type='hidden' name='New_UseUsbMem' id='Id_UseUsbMem' value='on'>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
if "0" == g_Box.UseUsbStick then
assi_control.CreateButton("@Retry", g_Txt.Wiederholen, "", "")
else
assi_control.CreateButton("@Retry", g_Txt.Weiter, "", "")
end
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiTamInternIncoming()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular grid'>")
Htm2Box( "<p>")
Htm2Box( [[{?1326:314?}]])
Htm2Box( "</p>")
fon_nr_config.BoxOutHtmlCode_Connect2UserOrAll("ClassRadioButton", "")
fon_nr_config.BoxOutErrorLines("ClassAlert", {})
Htm2Box( "<table class='ClassNumberSelectListTable'>")
fon_nr_config.BoxOutHtmlCode_IncomingNr( "AssiIn", "", "CheckBoxen", "CheckTam", "DefNrClassIds",
"Label", 'fon_nr_config_OnClickNr("", id)', 0
)
Htm2Box( "</table>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiTamInternSummary()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?1326:77?}]])
Htm2Box( "</p>")
Htm2Box( "<table class='ClassSummaryListTable zebra'>")
local line_number = 1
Htm2Box( "<tr class='ClassSummaryTableLine" .. line_number .. "'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( g_Txt.Telefoniegeraet)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
Htm2Box( [[{?1326:615?}]])
Htm2Box( "</td>")
Htm2Box( "</tr>")
line_number = (line_number % 2) + 1
Htm2Box( "<tr class='ClassSummaryTableLine" .. line_number .. "'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( g_Txt.Bezeichnung)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
Htm2Box(g_Box.TamName)
Htm2Box( "</td>")
Htm2Box( "</tr>")
line_number = (line_number % 2) + 1
Htm2Box( "<tr class='ClassSummaryTableLine" .. line_number .. "'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( g_Txt.Betriebsart)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
Htm2Box(g_Txt.OperationMode[tonumber(g_Box.OperationMode) + 1])
Htm2Box( "</td>")
Htm2Box( "</tr>")
line_number = (line_number % 2) + 1
Htm2Box( "<tr class='ClassSummaryTableLine" .. line_number .. "'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( g_Txt.Ansageverzoegerung)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
if g_Box.Delay == "0" then
Htm2Box(g_Txt.Delay0)
else
Htm2Box(g_Box.Delay * 5 .. " " .. g_Txt.Sekunden)
end
Htm2Box( "</td>")
Htm2Box( "</tr>")
if g_Box.OperationMode == "1" then
line_number = (line_number % 2) + 1
Htm2Box("<tr class='ClassSummaryTableLine" .. line_number .. "'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( g_Txt.Aufnahmelaenge)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
if g_Box.RecordingLen == "0" then
Htm2Box(g_Txt.RecordingLen0)
else
Htm2Box(g_Box.RecordingLen .. " " .. g_Txt.Sekunden)
end
Htm2Box( "</td>")
Htm2Box("</tr>")
end
if config.USB_STORAGE then
line_number = (line_number % 2) + 1
Htm2Box( "<tr class='ClassSummaryTableLine" .. line_number .. "'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( g_Txt.UsbMemMoreRecordingCapa)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
if (g_Box.UseUsbMem == "on") or (g_Box.UseUsbStick == "1") then
Htm2Box(g_Txt.UseUsbMemOn)
else
Htm2Box(g_Txt.UseUsbMemOff)
end
Htm2Box( "</td>")
Htm2Box( "</tr>")
end
line_number = (line_number % 2) + 1
Htm2Box( "<tr class='ClassSummaryTableLine" .. line_number .. "'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( g_Txt.NrForIncomingCall)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
fon_nr_config.BoxOutHtmlCode_SummaryIncomingNr("AssiIn", "ClassSummaryTableColRight1")
Htm2Box( "</td>")
Htm2Box( "</tr>")
Htm2Box( "</table>")
Htm2Box( "<p>")
Htm2Box( "<b>")
Htm2Box( [[{?1326:242?}]])
Htm2Box( "</b>")
Htm2Box( "</p>")
Htm2Box( "<ul>")
Htm2Box( "<li>")
box.out( general.sprintf([[{?1326:390?}]], [[**60]]..g_Box.TamNr))
Htm2Box( "</li>")
if config.FON then
Htm2Box( "<li>")
Htm2Box( g_Txt.InfoAnzeigeViaLed)
Htm2Box( "</li>")
end
Htm2Box( "</ul>")
Htm2Box( "<p>")
Htm2Box( [[{?g_txt_ZumSpeichernUebernehmenKlicken?}]])
Htm2Box( "</p>")
Htm2Box("</div>")
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
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
box.out([[<script type="text/javascript" src="/js/wizard.js?lang=]], config.language, [["></script>]])
Htm2Box("<form method='POST' action='" .. box.glob.script .. "'>")
if ((g_Box.UseUsbMem == "on" and g_Box.NoInternalMem) or not g_Box.NoInternalMem) and g_Box.TamLoadFailReason == "0" then
assi_control.LoadHtmlSide()
elseif g_Box.NoInternalMem then
Multiside_NoInternalMem()
else
Multiside_TamLoadFailReason(g_Box.TamLoadFailReason)
end
assi_control.AddHiddenSID()
assi_control.HiddenValues(g_Box.CurrSide)
assi_control.AddOtherHiddenInputs()
Htm2Box("</form>")
fon_nr_config.JavaScriptCb_NrHandling(g_Box.CurrSide == "AssiTamInternIncoming", true, true, g_Box.WorkAs,true)
html_check.debug()
?>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
