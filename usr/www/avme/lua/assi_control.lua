--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall)
require("capiterm")
require("http")
require("string_op")
require("fon_nr_config")
require("utf8")
require"general"
function SetCapitermInfo(CapitermEnabled, FileName)
return {Insert = ".", Length = 80, Text = "<-" .. FileName, Enabled = CapitermEnabled}
end
function TraceStart(CapitermEnabled, FileName)
SetCapitermInfo(CapitermEnabled, FileName)
if CapitermEnabled == "T" then
capiterm.nl(5)
end
return CapitermInfo
end
function InitWithDefaults(BoxVariablen)
if (not box.get["HTMLConfigAssiTyp"] and not box.post["HTMLConfigAssiTyp"]) then
require"http"
http.redirect(g_Box.Back2Page or g_Box.StartPage or [[/assis/assi_fondevices_list.lua]])
return ""
end
local StartToken
local StopToken
for Index = 1, #BoxVariablen, 1 do
if string_op.in_list(g_Box.WorkAs, BoxVariablen[Index].WorkAs) then
if BoxVariablen[Index].Init ~= nil then
if (g_Box.Port~=nil and g_Box.Port~="") and (BoxVariablen[Index].Token) == "Port" then
else
g_Box[BoxVariablen[Index].Token]=BoxVariablen[Index].Init
end
end
end
end
end
function GetPortTyp(Port)
Port = tostring(Port)
if (Port >= "0") and (Port <= "2") then
return "ANALOG"
elseif (Port >= "620") and (Port <= "629") then
return "IPPHONE"
elseif Port == "20" then
return "DECT"
elseif Port == "50" then
return "ISDN"
end
return ""
end
function GetPortName(Port)
for _, Curr in pairs(g_OptionTable) do
if Curr.IsFree then
local Selected = ""
if Curr.Port == Port then
return Curr.Name
end
end
end
return ""
end
function ResetAnlogPorts(Table)
for Index = 0, g_Const.AbCount - 1, 1 do
PortIndex = Index + 1
local AnalogPortName = g_Box["AnalogPort" .. PortIndex .. "Name"]
if (Index ~= tonumber(g_Box.Port)) and (AnalogPortName == "") then
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/AllIncomingCalls", "0")
for Msn = 0, fon_nr_config.NrInfo().MaxSelectedCount - 1, 1 do
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/MSN" .. Msn, "")
end
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/Name", "")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/Fax", "0")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/GroupCall", "1")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/OutDialing", "1")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/CLIR", "0")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/CLIP", "2")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/BusyOnBusy", "1")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/CallWaitingProt", "1")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/NoRingWithNightSetting", "1")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/RingAllowed", "1")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/NoRingTime", "")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/COLR", "0")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/MWI_Voice", "0")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/MWI_Fax", "0")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/MWI_Mail", "0")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port" .. Index .. "/MWI_Once", "0")
end
end
end
function UpdateDefaultExtension(PortNr)
local Name = g_Box["AnalogPort" .. PortNr .. "Name"]
local Fax = g_Box["AnalogPort" .. PortNr .. "Fax"]
local GroupCall = g_Box["AnalogPort" .. PortNr .. "GroupCall"]
local AllIncomingCalls = g_Box["AnalogPort" .. PortNr .. "AllIncomingCalls"]
local OutgoingNr = g_Box["AnalogPort" .. PortNr .. "OutgoingNr"]
return (PortName == ("Fon " .. (tonumber(PortNr) + 1))) and (Fax ~= "1") and (GroupCall ~= "0")
and (AllIncomingCalls == "1") and ((OutgoingNr == "SIP0") or (OutgoingNr == ""))
end
function AddOption(Table, Port, Name, Notation, IsPostLoad, IsFree)
if g_Box.Port == "" then
g_Box.Port = Port
end
local DictName = "Option" .. Port .. "Notation"
if IsPostLoad then
Notation = box.post["Old_" .. DictName]
end
local BoxVariable = {Token = DictName, WorkAs = {"Assi"}, Control = "nil", Init = Notation}
table.insert(Table, {Port = Port, Name = Name, IsFree = IsFree})
if IsFree then
table.insert(g_BoxRefresh, BoxVariable)
InitWithDefaults({BoxVariable})
end
end
function PrepareOptionList(IsPostLoad, Typ, GeraetName, ShowName)
local Table = {}
local PortName = ""
for Index = 1, g_Const.AbCount, 1 do
local HtmlPort = tostring(Index - 1)
PortName = g_Box["AnalogPort" .. Index.. "Name"]
if (PortName == "") or UpdateDefaultExtension(HtmlPort) or (g_Box.WorkAs ~= "Assi") then
AddOption(Table, HtmlPort, general.sprintf(g_Txt.FonNAnalog, Index), GeraetName, IsPostLoad,true)
else
AddOption(Table, HtmlPort, general.sprintf(g_Txt.FonNAnalog, Index), GeraetName, IsPostLoad,false)
end
end
if Typ ~= "Tam" and Typ ~= "Door" then
if config.CAPI_NT then
if g_Box.WorkAs == "Assi" then
if (g_Box.FreeNtHotDialIndex and g_Box.FreeNtHotDialIndex > 0) and (g_Box.FaxModemListSelector ~= "") then
AddOption(Table, "50", ShowName, GeraetName .. " " .. g_Box.FreeNtHotDialIndex, IsPostLoad,true)
else
AddOption(Table, "50", ShowName, GeraetName .. " " .. g_Box.FreeNtHotDialIndex, IsPostLoad,false)
end
else
AddOption(Table, "50", ShowName, GeraetName, IsPostLoad,true)
end
end
end
if Typ == "Fon" then
if config.DECT then
if g_Box.FreeDectPort ~= -1 then
AddOption(Table, "20", g_Txt.Dect, g_Txt.Mobilteil .. " " .. g_Box.FreeDectPort, IsPostLoad,true)
else
AddOption(Table, "20", g_Txt.Dect, g_Txt.Mobilteil, IsPostLoad,false)
end
end
if config.FON_IPPHONE then
if g_Box.WorkAs == "Assi" then
if g_Box.FreeIpPhoneTsvIndex==nil then
g_Box.FreeIpPhoneTsvIndex = -1
end
if g_Box.FreeIpPhoneTsvIndex ~= -1 then
AddOption( Table, tostring(620 + g_Box.FreeIpPhoneTsvIndex), g_Txt.LanWLanIpPhone,
g_Txt.IPPhone .. " " .. g_Box.IpPhoneNameSuffixNr, IsPostLoad, true
)
else
AddOption( Table, tostring(620 + g_Box.FreeIpPhoneTsvIndex), g_Txt.LanWLanIpPhone,
g_Txt.IPPhone .. " " .. g_Box.IpPhoneNameSuffixNr, IsPostLoad, false
)
end
else
for Index = 1, g_Const.IpCount, 1 do
AddOption(Table, tostring(620 + Index), g_Txt.LanWLanIpPhone, g_Txt.IPPhone, IsPostLoad, true)
end
end
end
end
if Typ == "Door" then
end
return Table
end
function GetFreeFaxModemListSelector(Number)
if config.CAPI_NT then
for Index = 0, g_Const.FaxModemCount - 1, 1 do
if g_Box["FaxModem" .. Index .. "Number"] == Number then
return "FaxModem" .. Index
end
end
end
return ""
end
function AddBoxVariablen(Typ)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@AddBoxVariablen")
for Index = 1, g_Const.AbCount, 1 do
table.insert(g_BoxRefresh, {Token = "AnalogPort" .. Index .. "Name", WorkAs = {"Assi"}, Control = "nil", Init = ""})
table.insert(g_BoxRefresh, {Token = "AnalogPort" .. Index .. "Fax", WorkAs = {"Assi"}, Control = "nil", Init = ""})
table.insert( g_BoxRefresh,
{Token = "AnalogPort" .. Index .. "GroupCall", WorkAs = {"Assi"}, Control = "nil", Init = ""}
)
table.insert( g_BoxRefresh,
{Token = "AnalogPort" .. Index .. "AllIncomingCalls", WorkAs = {"Assi"}, Control = "nil", Init = ""}
)
table.insert( g_BoxRefresh,
{Token = "AnalogPort" .. Index .. "OutgoingNr", WorkAs = {"Assi"}, Control = "nil", Init = ""}
)
end
if Typ == "Fax" then
for Index = 0, g_Const.FaxModemCount - 1, 1 do
table.insert( g_BoxRefresh, { Token = "FaxModem" .. Index .. "Number", WorkAs = {"Assi"}, Control = "nil",
Init = fon_nr_config.Query( "telcfg:settings/FaxModem" .. Index .. "/Number",
CapitermInfo
)
}
)
end
end
if config.CAPI_NT and (Typ == "Fon") and (g_Box.WorkAs == "Assi") then
for Index = 0, g_Const.FaxModemCount - 1, 1 do
g_Box["FaxModem" .. Index .. "Number"] = fon_nr_config.Query("telcfg:settings/FaxModem" .. Index .. "/Number", CapitermInfo)
end
g_Box.FaxModemListSelector=""
if (g_Box.FaxModem0Number=="" or g_Box.FaxModem1Number=="" or g_Box.FaxModem2Number=="") then
g_Box.FaxModemListSelector = GetFreeFaxModemListSelector("")
end
end
if (Typ == "Fon") and (g_Box.WorkAs ~= "Assi") and (g_Box.TechTyp == "DECT") then
local RefreshFirst = fon_nr_config.Query("telcfg:settings/Phonebook/Books/Refresh", CapitermInfo)
for LfNr, Value in ipairs(box.multiquery("telcfg:settings/Phonebook/Books/Id/list") or {}) do
table.insert( g_BoxRefresh,
{Token = "FonbookNameLfNr" .. LfNr, WorkAs = {"Edit", "Wizard"}, Control = "nil", Init = ""}
)
table.insert( g_BoxRefresh,
{Token = "FonbookNameValue" .. LfNr, WorkAs = {"Edit", "Wizard"}, Control = "nil", Init = ""}
)
end
if (g_Box.WorkAs ~= "Assi") and (g_Box.TechTyp == "DECT") then
for Index = 1, #fon_nr_config.g_NrInfo.All, 1 do
table.insert( g_BoxRefresh,
{Token = "RingToneIncoming" .. Index, WorkAs = {"Edit", "Wizard"}, Control = "New", Init = ""}
)
end
end
end
end
function SetAbsPageInfo(CurrSide)
g_Box.CurrSide = CurrSide
g_Box.PageTitle = ""
for Index = 1, #g_SideHeader, 1 do
for Id = 1, #g_SideHeader[Index].Id, 1 do
if g_SideHeader[Index].Id[Id] == CurrSide then
g_Box.PageTitle = g_SideHeader[Index].Head
break
end
end
end
end
function SetNewPage(SideList, Direction)
local SideIndex = 1
for Index = 1, #SideList, 1 do
if SideList[Index] == g_Box.CurrSide then
SideIndex = Index + Direction
break
end
end
if (SideIndex >= 1) and (SideIndex <= #SideList) then
g_Box.CurrSide = SideList[SideIndex]
end
SetAbsPageInfo(g_Box.CurrSide)
end
function TraceStruktur(Header, ShowAll, Struktur, Praefix, Postfix)
if g_CapitermEnabled == "T" then
capiterm.txt_nl(Header, g_CapitermInfo)
for Name, Value in capiterm.sort_table_by_keys(Struktur, nil) do
if ShowAll or (Name:sub(-2) ~= "_i") then
capiterm.spc_var(3, Praefix .. Name .. Postfix, Value, g_CapitermInfo)
end
end
end
end
function CheckboxValue(NewVar, SideList)
if string.find("-" .. SideList .. "-", "-" .. g_Box.CurrSide .. "-", 1, true) ~= nil and NewVar == nil then
return "off"
end
return NewVar
end
function SolveHistory(OldVar, NewVar)
if NewVar ~= nil then
return NewVar
end
if OldVar ~= nil then
return OldVar
end
return "-NIL-"
end
function LoadHtmlSide()
local LoadSide = g_Box.CurrSide
if g_SideMapping ~= nil then
local MappedSide = g_SideMapping[g_Box.CurrSide]
if MappedSide ~= nil then
LoadSide = MappedSide
end
end
_G["Multiside_" .. LoadSide]()
end
function LoadFromPost(BoxVariablen)
local OldVar = ""
local NewVar = ""
if g_CapitermEnabled == "T" then
capiterm.txt_nl("LoadFromPost", g_CapitermInfo)
end
if box.post.New_CurrSide ~= nil then
SetAbsPageInfo(box.post.New_CurrSide)
end
for Index = 1, #BoxVariablen, 1 do
if string_op.in_list(g_Box.WorkAs, BoxVariablen[Index].WorkAs) then
OldVar = box.post["Old_" .. BoxVariablen[Index].Token]
if (box.post[BoxVariablen[Index].Token]) then
NewVar = box.post[BoxVariablen[Index].Token]
else
NewVar = box.post["New_" .. BoxVariablen[Index].Token]
end
if BoxVariablen[Index].Control == "nil" then
NewVar = nil
elseif BoxVariablen[Index].Control:sub(1,2) == "SL" then
NewVar = assi_control.CheckboxValue( NewVar , BoxVariablen[Index].Control:sub(3))
end
g_Box[BoxVariablen[Index].Token] = assi_control.SolveHistory(OldVar, NewVar)
if type(BoxVariablen[Index].Init) == "number" then
g_Box[BoxVariablen[Index].Token] = tonumber(g_Box[BoxVariablen[Index].Token])
end
end
end
end
function CreateButton(Name, Text, MoreInfo, Rahmen)
if string.find(Rahmen, "S") ~= nil then
box.out([[<div id='btn_form_foot'>]])
end
local Class = ""
if string.find(Name, "@") == 1 then
Class = [[ class='ClassPushButtonFett']]
Name = string.sub(Name, 2)
end
--box.out([[<input type='submit' name='Submit_]]..box.tohtml(Name)..[[' id='Id_Btn]]..box.tohtml(Name)..[[' value=']]..box.tohtml(Text)..[[']]..Class..box.tohtml(MoreInfo)..[[>]])
if Name == "cancel" then
box.out([[<button type="submit" name=']]..box.tohtml(Name)..[[' id='Id_Btn]]..box.tohtml(Name)..[[' ]]..Class..box.tohtml(MoreInfo)..[[>]]..box.tohtml(Text)..[[</button>]])
else
box.out([[<button type="submit" name='Submit_]]..box.tohtml(Name)..[[' id='Id_Btn]]..box.tohtml(Name)..[[' ]]..Class..box.tohtml(MoreInfo)..[[>]]..box.tohtml(Text)..[[</button>]])
end
if string.find(Rahmen, "E") ~= nil then
box.out([[</div>]])
end
end
function AddHiddenSID()
Htm2Box("<input type='hidden' name='sid' value='" .. box.glob.sid .. "'>")
end
function AddOtherHiddenInputs()
if config.oem == '1und1' then
local tr069popupurl = box.post.popup_url or box.get.popup_url or ""
if #tr069popupurl > 0 then
Htm2Box([[<input type="hidden" name="popup_url" value="]] .. box.tohtml(tr069popupurl) .. [[">]])
end
end
end
function InsertOtherGetValues(params)
if config.oem == '1und1' then
local tr069popupurl = box.post.popup_url or box.get.popup_url or ""
if #tr069popupurl > 0 then
table.insert(params, http.url_param("popup_url", tr069popupurl))
end
end
end
function CreateTab(Highlight, Text, MoreInfo, Rahmen)
if g_Box.WorkAs ~= "Edit" then
return
end
if string.find(Rahmen, "S") ~= nil then
Htm2Box("<ul class='tabs'>")
end
local Class = ""
if Highlight then
Class =" class='active'"
end
Htm2Box("<li" .. Class .. ">")
Htm2Box("<a href='" .. g_Box.WhoAmI .. "'".. MoreInfo ..">")
Htm2Box(Text)
Htm2Box("</a>")
Htm2Box("</li>")
if string.find(Rahmen, "E") ~= nil then
Htm2Box("</ul>")
end
end
function InsertFromPage(params)
if (box.post['FonAssiFromPage'] ~= nil) then
table.insert(params,'FonAssiFromPage='..box.post['FonAssiFromPage'])
elseif(box.get['FonAssiFromPage'] ~= nil) then
table.insert(params,'FonAssiFromPage='..box.get['FonAssiFromPage'])
end
if (box.post['HTMLConfigAssiTyp'] ~= nil) then
table.insert(params,'HTMLConfigAssiTyp='..box.post['HTMLConfigAssiTyp'])
elseif(box.get['HTMLConfigAssiTyp'] ~= nil) then
table.insert(params,'HTMLConfigAssiTyp='..box.get['HTMLConfigAssiTyp'])
end
if (box.post['assicall'] ~= nil) then
table.insert(params,'assicall='..box.post['assicall'])
elseif(box.get['assicall'] ~= nil) then
table.insert(params,'assicall='..box.get['assicall'])
end
InsertOtherGetValues(params)
end
function HiddenValues(CurrSide)
if (g_Box.WorkAs ~= "Assi") and (g_Box.TechTyp == "DECT") then
for Index = 1, #fon_nr_config.g_NrInfo.All, 1 do
g_Box["RingToneIncoming" .. Index] = fon_nr_config.g_NrInfo.All[Index].RingTone
end
end
Htm2Box("<div>")
Htm2Box( "<input type='hidden' name='New_CurrSide' value='" .. box.tohtml(CurrSide) .. "'>")
Htm2Box( "<input type='hidden' name='Old_WhoAmI' value='" .. box.tohtml(g_Box.WhoAmI) .. "'>")
if box.post["HTMLConfigAssiTyp"] then
Htm2Box( "<input type='hidden' name='HTMLConfigAssiTyp' value='" .. box.tohtml(box.post["HTMLConfigAssiTyp"]) .. "'>")
elseif box.get["HTMLConfigAssiTyp"] then
Htm2Box( "<input type='hidden' name='HTMLConfigAssiTyp' value='" .. box.tohtml(box.get["HTMLConfigAssiTyp"]) .. "'>")
end
if box.post["FonAssiFromPage"] then
Htm2Box( "<input type='hidden' name='FonAssiFromPage' value='" .. box.tohtml(box.post["FonAssiFromPage"]) .. "'>")
elseif box.get["FonAssiFromPage"] then
Htm2Box( "<input type='hidden' name='FonAssiFromPage' value='" .. box.tohtml(box.get["FonAssiFromPage"]) .. "'>")
end
if box.post["assicall"] then
Htm2Box( "<input type='hidden' name='assicall' value='" .. box.tohtml(box.post["assicall"]) .. "'>")
elseif box.get["assicall"] then
Htm2Box( "<input type='hidden' name='assicall' value='" .. box.tohtml(box.get["assicall"]) .. "'>")
end
if g_Box.WorkAs == "Edit" then
Htm2Box( "<input type='hidden' name='Submit_Tab' id='Id_Submit_Tab' value=''"
.. string_op.txt_disabled(true) .. ">"
)
end
for Index = 1, #g_BoxRefresh, 1 do
if string_op.in_list(g_Box.WorkAs, g_BoxRefresh[Index].WorkAs) then
local Value = g_Box[g_BoxRefresh[Index].Token]
local Name = g_BoxRefresh[Index].Token
Htm2Box( "<input type='hidden' name='Old_" .. Name .. "' Id='Id_Old_" .. Name .. "' value=\"" .. box.tohtml(Value)
.. "\">"
)
end
end
fon_nr_config.BoxOutHiddenValues()
Htm2Box("</div>")
end
function SummaryTableLine(LineTyp, Left, Right, Quelle)
Htm2Box("<tr class='ClassSummaryTableLine" .. LineTyp .. "'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( Left)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
if Quelle == "In" then
fon_nr_config.BoxOutHtmlCode_SummaryIncomingNr("AssiIn", "ClassSummaryTableColRight" .. LineTyp,"F")
elseif Quelle == "InCall" then
fon_nr_config.BoxOutHtmlCode_SummaryIncomingNr("AssiIn", "ClassSummaryTableColRight" .. LineTyp,"T")
elseif Quelle == "Out" then
fon_nr_config.BoxOutHtmlCode_SummaryOutgoingNr("AssiOut", "ClassSummaryTableColRight" .. LineTyp,"F")
else
Htm2Box(Right)
end
Htm2Box( "</td>")
Htm2Box("</tr>")
end
function InputField(Job, Typ, Name, Id, LabelText, Size, MaxLength, Value, MoreInfo, Callback, MoreInfoLabel, InputNamePrefix, Autocomplete)
if Id == nil then
Id = Name
end
if string.sub(Id, 1, 2) == "++" then
Id = Name .. string.sub(Id, 3)
end
local InputNamePrefixOverride = "New_"
if InputNamePrefix ~= nil and InputNamePrefix ~= "" then
InputNamePrefixOverride = InputNamePrefix
end
if string_op.in_list(Job, {"LabelInput", "Label"}) then
Htm2Box("<label for='Id_" .. Id .. "' " .. MoreInfoLabel .. " >")
Htm2Box( box.tohtml(LabelText))
Htm2Box("</label>")
end
if Job ~= "Label" then
local DimensionText = ""
if Size ~= nil then
DimensionText = " size='%2%Number%' maxlength='%3%Number%'"
end
if Callback ~= "" then
Callback = " onchange='" .. Callback .. "'"
end
local ValueText = ""
if Value ~= nil then
ValueText = " value='%1%String%'"
end
local complete=""
if Autocomplete then
complete="Autocomplete="..Autocomplete
end
Htm2Box( general.sprintf( "<input type='" .. Typ .. "' name='" .. InputNamePrefixOverride .. Name .. "' id='Id_" .. Id .. "'"
.. DimensionText .. ValueText .. MoreInfo .. Callback ..complete..">",
box.tohtml(Value), Size, MaxLength
)
)
end
if Job == "InputLabel" then
Htm2Box("<label for='Id_" .. Id .. "' " .. MoreInfoLabel .. ">")
Htm2Box( box.tohtml(LabelText))
Htm2Box("</label>")
end
end
function ChangeBack2Page()
g_Box.Back2Page = http.get_back_to_page([[assis/home.lua]])
end
function AjaxKlingeltest(Ring, DectFoncontrolName, Tone, DialNr)
if g_CapitermEnabled == "T" then
capiterm.var( "Ajax: Klingeltest",
{{Ring = Ring}, {DectFoncontrolName = DectFoncontrolName}, {Tone = Tone}, {DialNr = DialNr}},
g_CapitermInfo
)
end
local Table = {}
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/Foncontrol/" .. DectFoncontrolName .. "/IntRingTone", Tone)
if Ring == "1" then
TelefonRingTestDect(Table, DectFoncontrolName)
else
TelefonHangUp(Table)
end
end
function SetWorkAs()
if box.get.ajaxring ~= nil then
AjaxKlingeltest(box.get.ajaxring, box.get.dect, box.get.tone, box.get.dialnr)
box.out("</body></html>")
box.end_page()
end
if box.get.wizard ~= nil then
g_Box.WorkAs = "Wizard"
return
end
if box.get.edit ~= nil then
g_Box.WorkAs = "Edit"
end
end
function GetEnvire(StartSide)
g_Box.EditDeviceNo = box.get.dev_no
if g_Box.WorkAs == "Wizard" then
if box.get.wizard ~= "var" then
g_Box.TechTyp = box.get.wizard
end
g_Box.EditTab = "WizardFonStart" .. g_Box.TechTyp
return g_Box.EditTab
end
if box.get.edit == "var" then
g_Box.TechTyp = box.post.Old_Edit
g_Box.EditTab = StartSide
return StartSide
end
g_Box.TechTyp = box.get.edit
g_Box.EditTab = box.get.tab
if g_Box.EditTab == nil then
g_Box.EditTab = "WizardFonStart" .. g_Box.TechTyp
end
StartSide = g_Box.EditTab
return StartSide
end
function DebugAll()
fon_nr_config.Debug()
TraceStruktur("Variablen:", true, g_Box, "g_Box.", "")
TraceStruktur("Alerts:", true, g_Alert, "g_Alert.", "")
end
function FirstLoaded(StartSide, InitTam)
if g_CapitermEnabled == "T" then
capiterm.txt_nl("FirstLoad", g_CapitermInfo)
end
LoadFromBox(g_BoxRefresh)
SetAbsPageInfo(StartSide)
if InitTam then
fon_nr_config.InitTamFromBox(g_Box.TamNr)
end
if g_Box.WorkAs == "Edit" then
g_Box.Edit = g_Box.TechTyp
end
if (g_Box.WorkAs == "Wizard") and (g_Box.EditDeviceNo ~= "nil") then
g_Box.Port = g_Box.EditDeviceNo
end
end
function FirstLoadOrReloaded(StartSide, InitTam)
local IsFirst = (box.post.Old_WhoAmI == nil)
or (box.post.WhoAmI ~= nil) and (box.post.WhoAmI ~= box.glob.script)
if IsFirst then
if g_CapitermEnabled == "T" then
capiterm.var("Fremdseitenaufruf via Submit-Button", {box.post.Old_WhoAmI, box.post.WhoAmI, 0}, g_CapitermInfo)
end
assi_control.FirstLoaded(StartSide, InitTam)
if (box.post.Submit_Goto ~= nil and box.post.Submit_Goto ~= "") or (box.get.Submit_Goto ~= nil and box.get.Submit_Goto ~= "") then
g_OptionTable = assi_control.PrepareOptionList(true, "Fon", g_Txt.Telefon, g_Txt.FonS0IsdnTelefon)
if g_Box.FreeDectPort ~= -1 and g_Box.Port == "" and ( box.get.Submit_Goto==AssiFonDectConStart or box.post.Submit_Goto==AssiFonDectConStart) then
g_Box.Port = 20
end
fon_nr_config.SetTyp(g_Box.DeviceTyp, assi_control.GetPortTyp(g_Box.Port))
if(g_Box.Port == 20) then
g_Box.Notation = g_Box.Option20Notation
if(g_Box.Notation==nil) then
g_Box.Notation = g_Txt.Mobilteil
end
end
SwitchToNextSide()
end
return
end
assi_control.LoadFromPost(g_BoxRefresh)
Reloaded()
end
function Main(HasConnectToAllOrUser, StartSide, InitTam)
SetWorkAs()
if g_Box.WorkAs ~= "Assi" then
StartSide = GetEnvire(StartSide)
if g_CapitermEnabled == "T" then
capiterm.txt_nl("Main:Change to " .. g_Box.WorkAs .. "-Mode " .. StartSide, g_CapitermInfo)
end
if fon_nr_config.GetVarianteValues(g_Box.DeviceTyp, g_Box.TechTyp) == nil then
if g_CapitermEnabled == "T" then
capiterm.var("Main:Invalid Edit-Mode-TechTyp", g_Box.TechTyp, g_CapitermInfo)
capiterm.spc_var(2, "box.get", box.get, g_CapitermInfo)
capiterm.spc_var(4, "box.post", box.post, g_CapitermInfo)
end
http.redirect(g_Box.Back2Page or g_Box.StartPage)
return
end
end
fon_nr_config.InitFromBox(g_Box.DeviceTyp, g_Box.TechTyp, HasConnectToAllOrUser)
local DeviceTech = g_Box.DeviceTyp .. g_Box.TechTyp
if DeviceTech == "FaxANALOG" then
for Index = 1, config.AB_COUNT, 1 do
AddBoxVariablen(g_Box.DeviceTyp)
end
end
if (g_Box.DeviceTyp == "Fon") or (DeviceTech == "TamEXTERN") then
AddBoxVariablen(g_Box.DeviceTyp)
end
if next(box.post) or next(box.get) then
if(box.post.CurrSide ~= nil) then
StartSide = box.post.CurrSide
end
if(box.get.CurrSide ~= nil) then
StartSide = box.get.CurrSide
end
if(box.post.DeviceTyp ~= nil) then
g_Box.DeviceTyp = box.post.DeviceTyp
end
if(box.get.DeviceTyp ~= nil) then
g_Box.DeviceTyp = box.get.DeviceTyp
end
if(box.post.TechTyp ~= nil) then
g_Box.TechTyp = box.post.TechTyp
end
if(box.get.TechTyp ~= nil) then
g_Box.TechTyp = box.get.TechTyp
end
if g_Box.TechTyp == "DECT" then
g_Box.Port = 20
end
FirstLoadOrReloaded(StartSide, InitTam)
else
FirstLoaded(StartSide, InitTam)
end
ChangeBack2Page()
end
function GetFonAssiFromPage()
if (box.post['FonAssiFromPage'] ~= nil) then
return box.post['FonAssiFromPage']
elseif(box.get['FonAssiFromPage'] ~= nil) then
return box.get['FonAssiFromPage']
end
return ""
end
function GetDefaultFinishPage(default)
capiterm.var("GetDefaultFinishPage",g_Box['FonAssiFromPage'])
local FonAssiFromPageValue = GetFonAssiFromPage()
if (FonAssiFromPageValue== "fonstartmenu") then
return '/fon_devices/fondevices_list.lua'
elseif(FonAssiFromPageValue== "fonerweitert") then
return '/fon_devices/fondevices_list.lua'
elseif (FonAssiFromPageValue== "dect_list") then
return '/dect/dect_list.lua'
elseif (FonAssiFromPageValue== "decthandset") then
return '/dect/dect_list.lua'
elseif (FonAssiFromPageValue== "dectsettings") then
return '/dect/dect_settings.lua'
elseif(FonAssiFromPageValue== "fax_option") then
return '/fon_devices/fax_option.lua'
elseif(FonAssiFromPageValue== "fax_send") then
return '/fon_devices/fax_send.lua'
elseif(FonAssiFromPageValue== "tam_list") then
return '/fon_devices/tam_list.lua'
elseif(FonAssiFromPageValue== "home") then
return '/home/home.lua'
else
return default
end
end
function HandleDefaultSubmitAbort(default)
local params = {}
InsertFromPage(params)
local FonAssiFromPageValue = GetFonAssiFromPage()
if (FonAssiFromPageValue== "dect_list") then
http.redirect(href.get_paramtable('/dect/dect_list.lua',params))
elseif (FonAssiFromPageValue== "decthandset") then
http.redirect(href.get_paramtable('/dect/dect_list.lua',params))
elseif (FonAssiFromPageValue== "dectsettings") then
http.redirect(href.get_paramtable('/dect/dect_settings.lua',params))
elseif (FonAssiFromPageValue== "fonstartmenu") then
http.redirect(href.get_paramtable('/fon_devices/fondevices_list.lua',params))
elseif(FonAssiFromPageValue== "fonerweitert") then
http.redirect(href.get_paramtable('/fon_devices/fondevices_list.lua',params))
elseif(FonAssiFromPageValue== "fax_send") then
http.redirect(href.get_paramtable('/fon_devices/fax_send.lua',params))
elseif(FonAssiFromPageValue== "fax_option") then
http.redirect(href.get_paramtable('/fon_devices/fax_option.lua',params))
elseif(FonAssiFromPageValue== "tam_list") then
http.redirect(href.get_paramtable('/fon_devices/tam_list.lua',params))
else
http.redirect(href.get_paramtable(default,params))
end
end
function SetCtlmgrVars(post)
if post ~= nil then
local typ_of_value = type(post)
if typ_of_value == "table" then
local NameTable = {}
local Name
local Value
for Name, Value in pairs(post) do
if ( (string.find(Name, ":settings") ~= nil) or (string.find(Name, ":command") ~= nil) ) and string.find(Name, "_i", -3) == nil then
table.insert(NameTable, Name)
end
end
if #NameTable > 0 then
table.sort(NameTable,function(a,b) return post[a .. "_i"] < post[b .. "_i"] end)
local SetTable = {}
for Index = 1, #NameTable, 1 do
table.insert(SetTable, { name = NameTable[Index], value = post[NameTable[Index]]})
end
capiterm.var("SetTable:",SetTable)
box.set_config(SetTable)
end
end
end
end
