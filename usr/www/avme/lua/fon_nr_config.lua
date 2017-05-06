--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall)
require("capiterm")
require("bit")
require("general")
require("config")
require("string_op")
require("html_check")
require("textdb")
g_CapitermEnabled = "F"
g_CapitermSendBoxEnabled = "F"
g_txt_Festnetz = TXT([[{?g_txt_Festnetz?}]])
g_txt_Internet = TXT([[{?g_txt_Internet?}]])
g_txt_Mobilnetz = TXT([[{?g_txt_Mobilnetz?}]])
g_txt_GeklammertMobilnetz = TXT("(" .. g_txt_Mobilnetz .. ")")
g_txt_GeklammertFestnetz = TXT("(" .. g_txt_Festnetz .. ")")
g_txt_GeklammertInternet = TXT("(" .. g_txt_Internet .. ")")
g_txt_OutgoingNr = TXT([[{?607:298?}]])
g_txt_OutgoingNrKlammer = TXT("(" .. g_txt_OutgoingNr .. ")")
g_txt_EditAbort = TXT([[{?607:595?}]])
.. "\n"
.. TXT([[{?607:897?}]])
.. "\n"
.. TXT([[{?607:925?}]])
g_txt_ToMuchMsnsNoOutgoingNr = TXT([[{?607:405?}]])
.."\n"
.. TXT([[{?607:39?}]])
g_txt_ToMuchMsnsVariableNr = TXT([[{?607:149?}]])
.."\n"
.. TXT([[{?607:734?}]])
g_txt_ToMuchMsnsMaxOne = TXT([[{?607:470?}]])
.."\n"
.. TXT([[{?607:977?}]])
g_txt_TamToMuchMsnsGlobal = TXT([[{?607:559?}]])
.."\n"
.. TXT([[{?607:987?}]])
g_txt_NoNrConfigured = TXT([[{?607:114?}]])
g_txt_FaxWeiche = TXT([[{?607:216?}]])
g_txt_TamNoNr = TXT([[{?607:336?}]])
g_txt_AlleNr = TXT([[{?g_txt_AlleAnkommendenGespraeche?}]])
g_txt_KeineNr = TXT([[{?g_txt_KeineRufnummern?}]])
g_txt_AlleCallNr = TXT([[{?g_txt_AlleAnkommendenAnrufe?}]])
g_txt_KeineCallNr = TXT([[{?g_txt_KeineAnrufe?}]])
g_txt_ActOnAllNr = TXT([[{?607:335?}]])
g_txt_ActOnFollowNr = TXT([[{?607:486?}]])
g_Id_ChoiceBoxHakenPraefix = "IdCb_"
g_Id_ChoiceBoxConTypOutNrSpanPraefix = "Id_ConTypOutNr"
g_Id_ToogleBoxIsUserdefined = "ConnectToUser"
g_Id_ToogleBoxIsConnectToAll = "ConnectToAll"
g_Id_ChoiceBoxOutgoingNrBox = "OutgoingNr"
g_Trennsymbol = ";"
g_CapitermInfo = {Insert = ".", Length = 80, Text = "<-" .. box.glob.script, Enabled = g_CapitermEnabled}
g_CapitermSendBoxInfo = {Insert = ".", Length = 80, Text = "<-" .. box.glob.script, Enabled = g_CapitermSendBoxEnabled}
g_NrInfo = {
All = {},
PotsIndex = 0,
GsmIndex = 0,
ViewConnectToAllOrUser = "F",
CombinedTamMsnList = {},
TamMaxCount = 5,
TamOther = {
Bitmap = {},
CombinedBitmap = 0,
Count = 0
},
DeviceTyp = "",
TechTyp = "",
MaxSelectedCount = 10,
HtmlCodeGeneriert = false,
UsePstn = box.query("telcfg:settings/UsePSTN"),
Alert = {},
PrevValues = {
ConnectToAll = "F",
OutgoingNr = "",
IncomingNr = {}
}
}
g_VariantenTable = {
{DeviceTyp = "Fon" , TechTyp = "ANALOG", AssiOut = "C", AssiIn = "C", EditOut = "B", EditIn = "C"},
{DeviceTyp = "Fon" , TechTyp = "ISDN", AssiOut = "C", AssiIn = "C", EditOut = "C", EditIn = "EC"},
{DeviceTyp = "Fon", TechTyp = "ISDN", AssiOut = "C", AssiIn = "C", EditOut = "C", EditIn = "EC"},
{DeviceTyp = "Fon" , TechTyp = "DECT", AssiOut = "C", AssiIn = "C", EditOut = "C", EditIn = "C"},
{DeviceTyp = "Fon" , TechTyp = "IPPHONE", AssiOut = "C", AssiIn = "C", EditOut = "C", EditIn = "C"},
{DeviceTyp = "Tam" , TechTyp = "ANALOG", AssiOut = "", AssiIn = "C", EditOut = "", EditIn = "C"},
{DeviceTyp = "Isdn" , TechTyp = "ISDN", AssiOut = "", AssiIn = "C", EditOut = "B", EditIn = "C"},
{DeviceTyp = "Fax" , TechTyp = "ANALOG", AssiOut = "C", AssiIn = "C", EditOut = "B", EditIn = "C"},
{DeviceTyp = "Fax" , TechTyp = "ISDN", AssiOut = "C", AssiIn = "C", EditOut = "C", EditIn = "EC"},
{DeviceTyp = "Fax" , TechTyp = "INTERN", AssiOut = "", AssiIn = "D", EditOut = "", EditIn = "D"},
{DeviceTyp = "Tam" , TechTyp = "INTERN", AssiOut = "", AssiIn = "C", EditOut = "", EditIn = "C"}
}
function CollectNumber(LfNr, Name, Nr, Typ)
return { Nr = Nr,
Name = Name,
LfNr = LfNr,
IsClicked = "off",
OutNrShown = nil,
Typ = Typ,
TypLfNr = Typ .. LfNr,
HtmlCodeExist = false,
RingTone = "0"
}
end
function CollectVarianten(Table, DeviceTyp, TechTyp, AssiOut, AssiIn, EditOut, EditIn)
table.insert( Table, { DeviceTyp = DeviceTyp,
TechTyp = TechTyp,
AssiOut = AssiOut,
AssiIn = AssiIn,
EditOut = EditOut,
EditIn = EditIn
}
)
end
function QueryAnalyse(Address, Table, Typ, CapitermInfo)
if (g_CapitermSendBoxEnabled == "F") or (CapitermInfo == nil) then
return
end
capiterm.spc_var(1, Typ .. "Query(" .. Address .. ")", Table, CapitermInfo)
end
function Query(Address, CapitermInfo)
Result = box.query(Address)
QueryAnalyse(Address, Result, "", CapitermInfo)
return Result
end
function MultiQuery(Address, CapitermInfo)
Table = box.multiquery(Address) or {}
QueryAnalyse(Address, Table, "Multi", CapitermInfo)
return Table
end
function ListQuery(Address, CapitermInfo)
Table = general.listquery(Address)
QueryAnalyse(Address, Table, "List", CapitermInfo)
return Table
end
function SetTyp(DeviceTyp, TechTyp)
if g_CapitermEnabled == "T" then
capiterm.var("SetTyp", {{DeviceTyp = DeviceTyp}, {TechTyp = TechTyp}}, g_CapitermInfo)
end
g_NrInfo.DeviceTyp = DeviceTyp
g_NrInfo.TechTyp = TechTyp
end
function InitFromBox(DeviceTyp, TechTyp, HasConnectToAllOrUser)
if g_CapitermEnabled == "T" then
capiterm.txt_nl("InitFromBox", g_CapitermInfo)
end
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@InitFromBox")
SetTyp(DeviceTyp, TechTyp)
local Values = ListQuery("telcfg:settings/SIP/list(MSN)", CapitermInfo)
if Values ~= nil then
for Index, Token in ipairs(Values) do
table.insert(g_NrInfo.All, CollectNumber(tostring(Index - 1), Token._node, Token.MSN, "Sip"))
end
end
if g_NrInfo.UsePstn == "1" then
for Index = 1, g_NrInfo.MaxSelectedCount, 1 do
local BitNr = tostring(Index - 1)
local Msn = Query("telcfg:settings/MSN/MSN" .. BitNr, CapitermInfo)
table.insert(g_NrInfo.All, CollectNumber(BitNr, Msn, Msn, "Msn"))
end
table.insert(g_NrInfo.All, CollectNumber("0", "POTS", Query("telcfg:settings/MSN/POTS", CapitermInfo), "Pots"))
g_NrInfo.PotsIndex = #g_NrInfo.All
end
if config.USB_GSM ~= nil then
table.insert(g_NrInfo.All, CollectNumber("0", "SIP99", Query("telcfg:settings/Mobile/MSN", CapitermInfo), "Gsm"))
g_NrInfo.GsmIndex = #g_NrInfo.All
end
g_NrInfo.PrevValues.ConnectToAll = "F"
if HasConnectToAllOrUser ~= "F" then
g_NrInfo.ViewConnectToAllOrUser = "T"
if HasConnectToAllOrUser == "C2A=T" then
g_NrInfo.PrevValues.ConnectToAll = "T"
end
end
for Index = 1, g_NrInfo.MaxSelectedCount, 1 do
g_NrInfo.PrevValues.IncomingNr[Index] = ""
end
if g_CapitermEnabled == "T" then
capiterm.var("InitFromBox:g_NrInfo.PrevValues", g_NrInfo.PrevValues, g_CapitermInfo)
end
end
function GetCountSelected()
local Count = 0
for Index = 1, #g_NrInfo.All, 1 do
if g_NrInfo.All[Index].IsClicked == "on" then
Count = Count + 1
end
end
return Count
end
function SetClickedByNr(TypLfNr)
for Index = 1, #g_NrInfo.All, 1 do
if g_NrInfo.All[Index].TypLfNr == TypLfNr then
g_NrInfo.All[Index].IsClicked = "on"
if g_CapitermEnabled == "T" then
capiterm.var( "SetClickedByNr:g_NrInfo.All[" .. Index .. "].IsClicked", g_NrInfo.All[Index].IsClicked,
g_CapitermInfo
)
end
return
end
end
end
function InitTamFromBox(TamNr)
if g_CapitermEnabled == "T" then
capiterm.var("TamNr", TamNr, g_CapitermInfo)
end
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@InitTamFromBox")
if (config.TAM_MODE == nil) or (tostring(config.TAM_MODE) <= "0") then
if g_CapitermEnabled == "T" then
capiterm.var("Finish. See config.TAM_MODE=", config.TAM_MODE, g_CapitermInfo)
end
return
end
for Index = 0, g_NrInfo.TamMaxCount - 1, 1 do
g_NrInfo.TamOther.Bitmap[Index + 1] = tonumber(Query("tam:settings/TAM" .. Index .. "/MSNBitmap", CapitermInfo))
or 0
if Index ~= TamNr then
g_NrInfo.TamOther.CombinedBitmap = bit.maskor( g_NrInfo.TamOther.CombinedBitmap,
g_NrInfo.TamOther.Bitmap[Index + 1]
)
end
end
for Index = 1, g_NrInfo.MaxSelectedCount, 1 do
local BitNr = Index - 1
if bit.isset(g_NrInfo.TamOther.CombinedBitmap, BitNr) then
g_NrInfo.CombinedTamMsnList[Index] = Query("tam:settings/MSN" .. BitNr, CapitermInfo)
g_NrInfo.TamOther.Count = g_NrInfo.TamOther.Count + 1
else
g_NrInfo.CombinedTamMsnList[Index] = ""
end
if g_CapitermEnabled == "T" then
capiterm.var("g_NrInfo.CombinedTamMsnList[" .. Index .. "]", g_NrInfo.CombinedTamMsnList[Index], g_CapitermInfo)
end
end
if TamNr == 0 then
g_NrInfo.PrevValues.ConnectToAll = "T"
else
g_NrInfo.PrevValues.ConnectToAll = "F"
end
for Index = 1, g_NrInfo.MaxSelectedCount, 1 do
local BitNr = Index - 1
if bit.isset(g_NrInfo.TamOther.Bitmap[TamNr + 1], BitNr) then
g_NrInfo.PrevValues.IncomingNr[Index] = g_NrInfo.CombinedTamMsnList[Index]
if g_CapitermEnabled == "T" then
capiterm.var( "Bit=1:g_NrInfo.PrevValues.IncomingNr[" .. Index .. "]", g_NrInfo.PrevValues.IncomingNr[Index],
g_CapitermInfo
)
end
g_NrInfo.PrevValues.ConnectToAll = "F"
else
g_NrInfo.PrevValues.IncomingNr[Index] = ""
if g_CapitermEnabled == "T" then
capiterm.var( "Bit = 0:g_NrInfo.PrevValues.IncomingNr[" .. Index .. "]", g_NrInfo.PrevValues.IncomingNr[Index],
g_CapitermInfo
)
end
end
end
if TamNr == 0 then
g_NrInfo.ViewConnectToAllOrUser = "T"
else
g_NrInfo.ViewConnectToAllOrUser = "F"
end
if g_CapitermEnabled == "T" then
capiterm.var("g_NrInfo.PrevValues.ConnectToAll", g_NrInfo.PrevValues.ConnectToAll, g_CapitermInfo)
end
end
function ToBox(Text)
html_check.tobox(Text)
end
function GsmElement()
if config.USB_GSM then
return g_NrInfo.All[g_NrInfo.GsmIndex]
end
return CollectNumber("", "", "", "Gsm")
end
function PotsElement()
if g_NrInfo.UsePstn == "1" then
return g_NrInfo.All[g_NrInfo.PotsIndex]
end
return CollectNumber("", "", "", "Pots")
end
function GetVarianteValues(DeviceTyp, TechTyp)
for Index = 1, #g_VariantenTable, 1 do
if (g_VariantenTable[Index].DeviceTyp == DeviceTyp) and (g_VariantenTable[Index].TechTyp == TechTyp) then
return g_VariantenTable[Index]
end
end
return nil
end
function GetVariante(VarianteSource, EditInTypS0)
Variante = GetVarianteValues(g_NrInfo.DeviceTyp, g_NrInfo.TechTyp)
if Variante ~= nil then
if VarianteSource == "AssiOut" then
return Variante.AssiOut
end
if VarianteSource == "AssiIn" then
return Variante.AssiIn
end
if VarianteSource == "EditOut" then
return Variante.EditOut
end
if string.len(Variante.EditIn) == 2 then
if EditInTypS0 == "Out" then
return string.sub(Variante.EditIn, 2, 1)
end
return string.sub(Variante.EditIn, 1, 1)
end
return Variante.EditIn
end
return "-"
end
function GetClassIdList(ClassIds)
if ClassIds == "DefNrClassIds" then
return { Line = "ClassNumberList_Line",
ClickBox = "ClassNumberList_CheckBox",
Nr = "ClassNumberList_Nr",
ConnectTyp = "ClassNumberList_Connect",
Empty = "ClassNumberList_Empty"
}
end
return { Line = ClassIds[1],
ClickBox = ClassIds[2],
Nr = ClassIds[3],
ConnectTyp = ClassIds[4],
Empty = ClassIds[5]
}
end
function IsPotsSpecialModeBOrD(TypLfNr, NoMsnFound, Variante)
return (TypLfNr == "") and ((Variante == "B") or (Variante == "D")) and NoMsnFound
end
function FormatNrByVariant(Curr, Variante, SipEqualMsn, SipEqualPots)
if (Curr.TypLfNr == "") or (Variante == "") or (Curr.Nr == "") then
return nil
end
if Curr.TypLfNr == "Gsm0" then
return {Curr.TypLfNr, g_txt_GeklammertMobilnetz}
end
if Variante == "B" then
if g_NrInfo.UsePstn == "1" then
if SipEqualPots or SipEqualMsn then
if Curr.Typ == "Sip" then
return {Curr.TypLfNr, ""}
end
return {Curr.TypLfNr, g_txt_GeklammertFestnetz}
end
end
return {Curr.TypLfNr, ""}
end
if Variante == "C" then
if g_NrInfo.UsePstn == "1" then
if SipEqualPots or SipEqualMsn then
if Curr.Typ ~= "Sip" then
return nil
end
end
end
return {Curr.TypLfNr, ""}
end
if Variante == "D" then
if g_NrInfo.UsePstn == "1" then
if SipEqualPots then
if Curr.Typ == "Sip" then
return {Curr.TypLfNr, ""}
end
return {Curr.TypLfNr, g_txt_GeklammertFestnetz}
end
if SipEqualMsn then
if Curr.Typ ~= "Sip" then
return nil
end
end
end
return {Curr.TypLfNr, ""}
end
return {Curr.TypLfNr, ""}
end
function GetIndexByName(Typ, Name)
if Name ~= "" then
for Index = 1, #g_NrInfo.All, 1 do
if (g_NrInfo.All[Index].Name == Name) and ((Typ == "All") or (g_NrInfo.All[Index].Typ == Typ)) then
return Index
end
end
end
return -1
end
function GetIndexByNr(Typ, Nr)
if Nr ~= "" then
for Index = 1, #g_NrInfo.All, 1 do
if (g_NrInfo.All[Index].Nr == Nr) and ((Typ == "All") or (g_NrInfo.All[Index].Typ == Typ)) then
return Index
end
end
end
return -1
end
function GetIndexByTypLfNr(TypLfNr)
if TypLfNr ~= "" then
for Index = 1, #g_NrInfo.All, 1 do
if g_NrInfo.All[Index].TypLfNr == TypLfNr then
return Index
end
end
end
return -1
end
function GetNumberInfosForTyp(Curr, Variante, PotsSpecialModeBOrD)
if Curr.TypLfNr == "Gsm0" then
return FormatNrByVariant(Curr, Variante, false, false)
end
if g_NrInfo.UsePstn == "1" then
if Curr.Typ == "Msn" then
return FormatNrByVariant(Curr, Variante, GetIndexByNr("Sip", Curr.Nr) ~= -1, false)
end
if Curr.Typ == "Pots" then
if config.CAPI_POTS then
if PotsSpecialModeBOrD then
return FormatNrByVariant(Curr, Variante, false, false)
else
return FormatNrByVariant(Curr, Variante, false, GetIndexByNr("Sip", Curr.Nr) ~= -1)
end
end
return nil
end
end
if Curr.Nr == nil then
return nil
end
return FormatNrByVariant(Curr, Variante, GetIndexByNr("Msn", Curr.Nr) ~= -1, Curr.Nr == PotsElement().Nr)
end
function IsNumberInMsnListe(Curr, SpecialTests)
if SpecialTests == "CheckNothing" then
return "T"
end
if SpecialTests == "CheckClicked" then
if Curr.IsClicked == "on" then
return "T"
end
return "F"
end
local Nr = g_NrInfo.All[GetIndexByNr("All", Curr.Nr)].Nr
for Index = 1, g_NrInfo.MaxSelectedCount, 1 do
if g_NrInfo.CombinedTamMsnList[Index] == Nr then
Curr.OutNrShown = nil
return "U"
end
end
for Index = 1, #g_NrInfo.All, 1 do
if g_NrInfo.All[Index].TypLfNr == Curr.TypLfNr then
if g_NrInfo.All[Index].IsClicked == "on" then
return "T"
end
return "F"
end
end
return "F"
end
function GetHtmlCodeIncomingNr( Index, Curr, OutgoingNr, CountMsnFound, Variante,
WithCheckboxen, SpecialTests, ClassIdList, WithLabels, OnClickFunktion, Zebrastreifen
)
local IsOutgoingNr = false
local IsNrInList = false
local PotsSpecialModeBOrD = false
if g_NrInfo.UsePstn == "1" then
if Curr.Typ ~= "Pots" then
CountMsnFound = 0
end
PotsSpecialModeBOrD = IsPotsSpecialModeBOrD(PotsElement().Nr, (CountMsnFound == 0), Variante)
end
local HtmlCode = { ClickedSwitchText = "",
OutgoingText = "",
ConnectTypText = "",
ShowNr = ""
}
Curr.HtmlCodeExist = false
Curr.OutNrShown = GetNumberInfosForTyp(Curr, Variante, PotsSpecialModeBOrD)
if Curr.OutNrShown == nil then
return Curr, Zebrastreifen
end
local IsNrInList = IsNumberInMsnListe(Curr, SpecialTests)
if IsNrInList == "U" then
return Curr, Zebrastreifen
end
IsOutgoingNr = OutgoingNr == Curr.TypLfNr
if IsNrInList == "T" then
HtmlCode.ClickedSwitchText = string_op.txt_checked(true)
end
if IsOutgoingNr then
HtmlCode.OutgoingText = g_txt_OutgoingNrKlammer
end
if Curr.OutNrShown[2] ~= "" then
HtmlCode.ConnectTypText = Curr.OutNrShown[2]
end
HtmlCode.ShowNr = Curr.Nr
if (Curr.Typ == "Pots") and (HtmlCode.ShowNr == "POTS") then
HtmlCode.ShowNr = g_txt_Festnetz
end
local SpanCodeStart = "<span id='" .. g_Id_ChoiceBoxConTypOutNrSpanPraefix .. Curr.TypLfNr .. "'>"
local SpanCodeEnd = "</span>"
local LabelStart = ""
local LabelEnd = ""
local ConnectTypAndOutgoingText = string.gsub(HtmlCode.ConnectTypText .. HtmlCode.OutgoingText, "%)%(", ", ")
if WithCheckboxen then
if WithLabels then
LabelStart = "<label for='" .. g_Id_ChoiceBoxHakenPraefix .. Curr.TypLfNr .. "'>"
LabelEnd = "</label>"
end
if OnClickFunktion ~= "" then
OnClickFunktion = " onclick='return " .. OnClickFunktion .. "'"
end
end
Curr.HtmlCodeExist = true
local ClassLine = ClassIdList.Line
if Zebrastreifen ~= 0 then
ClassLine = "ClassSummaryTableColRight" .. Zebrastreifen
Zebrastreifen = Zebrastreifen + 1
if Zebrastreifen > 2 then
Zebrastreifen = 1
end
end
ToBox("<tr class='" .. ClassLine .. "' id='IdTr_" .. Curr.TypLfNr .. "'>")
if WithCheckboxen then
ToBox("<td class='" .. ClassIdList.ClickBox .. "'>")
ToBox( "<input type='checkbox' name='NewFnc_" .. Curr.TypLfNr .. "' "
.. "id='" .. g_Id_ChoiceBoxHakenPraefix .. Curr.TypLfNr .. "' "
.. OnClickFunktion .. HtmlCode.ClickedSwitchText .. ">"
)
ToBox("</td>")
end
ToBox( "<td class='" .. ClassIdList.Nr .. "'>")
ToBox( LabelStart)
ToBox( HtmlCode.ShowNr)
ToBox( LabelEnd)
ToBox( "</td>")
ToBox( "<td class='" .. ClassIdList.ConnectTyp .. "'>")
ToBox( LabelStart)
ToBox( SpanCodeStart)
ToBox( ConnectTypAndOutgoingText)
ToBox( SpanCodeEnd)
ToBox( LabelEnd)
ToBox( "</td>")
ToBox("</tr>")
return Curr, Zebrastreifen
end
function BoxOutHtmlCode_HeaderIncomingNr(ClassIds, Header, LineClass)
local ClassIdList = GetClassIdList(ClassIds)
if LineClass ~= "" then
LineClass = " class='" .. LineClass .. "'"
end
ToBox("<tr" .. LineClass .. ">")
ToBox( "<th class='" .. ClassIdList.Nr .. "'>")
ToBox( "<b>")
ToBox( Header)
ToBox( "</b>")
ToBox( "</th>")
ToBox( "<th class='" .. ClassIdList.ConnectTyp .. "'>")
ToBox( "</th>")
ToBox("</tr>")
end
function BoxOutHtmlCode_IncomingNr( VarianteSource, OutgoingNr, WithCheckboxen, SpecialTests, ClassIds, WithLabels,
OnClickFunktion, Zebrastreifen
)
local Variante = GetVariante(VarianteSource, "In")
if g_CapitermEnabled == "T" then
capiterm.var( "BoxOutHtmlCode_IncomingNr:Param",
{ {Variante = Variante}, {SpecialTests = SpecialTests}, {OutgoingNr = OutgoingNr},
{WithCheckboxen = WithCheckboxen}, {WithLabels = WithLabels}, {Zebrastreifen = Zebrastreifen}
}, g_CapitermInfo
)
end
local CountMsnFound = 0
local ClassIdList = GetClassIdList(ClassIds)
g_NrInfo.HtmlCodeGeneriert = false
for Index = 1, #g_NrInfo.All, 1 do
g_NrInfo.All[Index], Zebrastreifen = GetHtmlCodeIncomingNr( Index, g_NrInfo.All[Index], OutgoingNr,
CountMsnFound, Variante, WithCheckboxen == "CheckBoxen",
SpecialTests, ClassIdList, WithLabels == "Label",
OnClickFunktion, Zebrastreifen
)
g_NrInfo.HtmlCodeGeneriert = g_NrInfo.HtmlCodeGeneriert or g_NrInfo.All[Index].HtmlCodeExist
if (g_NrInfo.All[Index].Typ == "Msn") and (g_NrInfo.All[Index].OutNrShown ~= nil) then
CountMsnFound = CountMsnFound + 1
end
end
if g_NrInfo.HtmlCodeGeneriert then
return
end
ToBox("<tr>")
ToBox( "<td colspan=2 class='" .. ClassIdList.Empty .. "'>")
ToBox( g_txt_NoNrConfigured)
ToBox( "</td>")
ToBox("</tr>")
end
function GetHtmlCodeConnectToUserOrAll(Class, Style, Id, Klartext, IsClicked, Value)
if Style ~= "" then
Style = " style='" .. Style .. "'"
end
if Class ~= "" then
Class = " class='" .. Class .. "'"
end
ToBox("<p" .. Style .. ">")
ToBox( "<input" .. Class .. " type='radio' name='NewFnc_ConnectToAll' value='" .. Value .. "' id='" .. Id .. "'"
.. " onclick='fon_nr_config_OnChangeConnectMode()'" .. string_op.txt_checked(IsClicked) .. ">"
)
ToBox( "&nbsp;")
ToBox( "<label id='Label_" .. Id .. "' for='" .. Id .. "'>")
ToBox( Klartext)
ToBox( "</label>")
ToBox("</p>")
end
function BoxOutHtmlCode_Connect2UserOrAll(Class, Style)
if g_CapitermEnabled == "T" then
capiterm.txt_nl("BoxOutHtmlCode_Connect2UserOrAll", g_CapitermInfo)
end
if g_NrInfo.ViewConnectToAllOrUser == "F" then
return
end
local ClickToAll = (g_NrInfo.PrevValues.ConnectToAll == "T") and (g_NrInfo.Alert.Id_FncTamNoNr == nil)
GetHtmlCodeConnectToUserOrAll(Class, Style, "Id_" .. g_Id_ToogleBoxIsConnectToAll, g_txt_ActOnAllNr, ClickToAll, "T")
GetHtmlCodeConnectToUserOrAll( Class, Style, "Id_" .. g_Id_ToogleBoxIsUserdefined, g_txt_ActOnFollowNr,
not ClickToAll, "F"
)
end
function BoxOutErrorLine(Class, Id, Text)
if Text == nil then
return
end
Text = string.gsub(Text, "\n", "<br>")
if Class ~= "" then
Class = " class='" .. Class .. "'"
end
if Id ~= "" then
Id = " id='" .. Id .. "'"
end
ToBox("<p" .. Id .. Class .. ">")
box.out( Text)
ToBox("</p>")
end
function BoxOutErrorLines(Class, MoreInfo)
ToBox("<div class='formular'>")
BoxOutErrorLine(Class, "Id_FncToMuchMsnsMaxOne", g_NrInfo.Alert.Id_FncToMuchMsnsMaxOne)
BoxOutErrorLine(Class, "Id_FncToMuchMsnsNoOutgoingNr", g_NrInfo.Alert.Id_FncToMuchMsnsNoOutgoingNr)
BoxOutErrorLine(Class, "Id_FncToMuchMsnsVariableNr", g_NrInfo.Alert.Id_FncToMuchMsnsVariableNr)
BoxOutErrorLine(Class, "Id_FncTamNoNr", g_NrInfo.Alert.Id_FncTamNoNr)
BoxOutErrorLine(Class, "Id_FncTamToMuchMsnsGlobal", g_NrInfo.Alert.Id_FncTamToMuchMsnsGlobal)
for Id, Text in pairs(MoreInfo) do
if Text ~= "" then
BoxOutErrorLine(Class, Id, Text)
end
end
ToBox("</div>")
end
function BoxOutHiddenValues()
if (g_NrInfo.DeviceTyp == "Tam") and (g_NrInfo.TechTyp == "INTERN") then
for Index = 1, g_NrInfo.MaxSelectedCount, 1 do
ToBox( "<input type='hidden' name='OldFnc_CombinedTamMsnList" .. Index .. "' value='"
.. box.tohtml(g_NrInfo.CombinedTamMsnList[Index]) .. "'>"
)
end
end
ToBox("<input type='hidden' name='" .. "OldFnc_ConnectToAll' value='" .. box.tohtml(g_NrInfo.PrevValues.ConnectToAll) .. "'>")
ToBox("<input type='hidden' name='" .. "OldFnc_OutgoingNr' value='" .. box.tohtml(g_NrInfo.PrevValues.OutgoingNr) .. "'>")
for Index = 1, g_NrInfo.MaxSelectedCount, 1 do
ToBox( "<input type='hidden' name='" .. "OldFnc_IncomingNr" .. Index .. "' value='"
.. box.tohtml(g_NrInfo.PrevValues.IncomingNr[Index]) .. "'>"
)
end
end
function NrInfo()
return g_NrInfo
end
function GetHakenPraefix()
return g_Id_ChoiceBoxHakenPraefix
end
function Table2BoxShow(Table, Praefix)
if g_CapitermSendBoxEnabled == "T" then
capiterm.spc_var(3, Praefix .. ".set_config", Table, g_CapitermSendBoxInfo)
end
end
function Table2BoxAdd(Table, VarName, Value)
table.insert(Table, {name = VarName, value = Value})
end
function Table2BoxSend(Table, VarName, Value)
Table2BoxAdd(Table, VarName, Value)
Table2BoxShow(Table, "Table2BoxSend")
box.set_config(Table)
end
function GetRealNumber(TypLfNr, UseName)
if TypLfNr == "" then
return ""
end
local Curr = g_NrInfo.All[GetIndexByTypLfNr(TypLfNr)]
if UseName then
return Curr.Name
end
return Curr.Nr
end
function TamValuesToTable()
local Table = {}
local BitMap = 0
if (TamNr ~= 0) or (g_NrInfo.PrevValues.ConnectToAll == "F") then
for Index = 1, #g_NrInfo.PrevValues.IncomingNr, 1 do
if g_NrInfo.PrevValues.IncomingNr[Index] ~= "" then
for BitNr = 0, g_NrInfo.MaxSelectedCount - 1, 1 do
if bit.isclr(bit.maskor(g_NrInfo.TamOther.CombinedBitmap, BitMap), BitNr) then
BitMap = bit.set(BitMap, BitNr)
Table2BoxAdd( Table, "tam:settings/MSN" .. BitNr,
tostring(GetRealNumber( g_NrInfo.PrevValues.IncomingNr[Index], false))
)
break
end
end
end
end
end
Table2BoxAdd(Table, "tam:settings/TAM" .. g_Box.TamNr .. "/MSNBitmap", BitMap)
return Table
end
function ValuesToTable(Table, VarNamePraefix, VarNamePostfixNr, VarNamePostfixTone, Value, UseName, StoreOutgoingNr, SaveAtleastOnce)
if g_CapitermEnabled == "T" then
capiterm.var( "ValuesToTable: Param",
{ {VarNamePraefix = VarNamePraefix}, {VarNamePostfixNr = VarNamePostfixNr},
{VarNamePostfixTone = VarNamePostfixTone}, {Value = Value}, {UseName = UseName},
{StoreOutgoingNr = StoreOutgoingNr}
}, g_CapitermInfo
)
end
local OutEqIncoming = false
local CountIncoming = #g_NrInfo.PrevValues.IncomingNr
local Suffix = ""
local Result
local Next = 0
local ResettedContent=0
StoreOutgoingNr = StoreOutgoingNr == "SaveOutgoing"
UseName = UseName == "UseName"
if StoreOutgoingNr then
Next = 1
CountIncoming = CountIncoming - 1
end
for Index = 1, #g_NrInfo.PrevValues.IncomingNr, 1 do
StoreThis = true
if Value == nil then
Result = GetRealNumber(g_NrInfo.PrevValues.IncomingNr[Index], UseName)
if (g_NrInfo.PrevValues.IncomingNr[Index] == g_NrInfo.PrevValues.OutgoingNr) and StoreOutgoingNr then
OutEqIncoming = true
StoreThis = false
end
else
Result = Value
end
if (Value ~= nil) and (g_NrInfo.PrevValues.IncomingNr[Index] == "") then
Result = ""
ResettedContent=ResettedContent+1
end
if (Next <= CountIncoming) and StoreThis then
Table2BoxAdd(Table, VarNamePraefix .. Next .. VarNamePostfixNr, tostring(Result))
if (VarNamePostfixTone ~= nil) and (Result ~= "") then
local IndexNr = GetIndexByTypLfNr(g_NrInfo.PrevValues.IncomingNr[Index])
Table2BoxAdd( Table, VarNamePraefix .. Next .. VarNamePostfixTone,
string_op.bool_to_value(IndexNr ~= -1, g_NrInfo.All[IndexNr].RingTone , "")
)
end
Next = Next + 1
end
end
if SaveAtleastOnce and CountIncoming==ResettedContent then
Table2BoxAdd(Table, VarNamePraefix, tostring(Value))
end
if StoreOutgoingNr then
if OutEqIncoming == false then
Suffix = "#"
end
Table2BoxAdd( Table, VarNamePraefix .. "0" .. VarNamePostfixNr,
GetRealNumber(g_NrInfo.PrevValues.OutgoingNr, UseName) .. Suffix
)
if VarNamePostfixTone ~= nil then
local IndexNr = GetIndexByTypLfNr(g_NrInfo.PrevValues.OutgoingNr)
Table2BoxAdd( Table, VarNamePraefix .. "0" .. VarNamePostfixTone,
string_op.bool_to_value(IndexNr ~= -1, g_NrInfo.All[IndexNr].RingTone, "")
)
end
end
return Table
end
function HiddenValuesFromBox(HasClickFields)
if g_CapitermEnabled == "T" then
capiterm.var("HiddenValuesFromBox", HasClickFields, g_CapitermInfo)
end
g_NrInfo.PrevValues.ConnectToAll = loadstring("return box.post.OldFnc_" .. g_Id_ToogleBoxIsConnectToAll)()
local CurrConnectToAll = loadstring("return box.post.NewFnc_" .. g_Id_ToogleBoxIsConnectToAll)()
if CurrConnectToAll ~= nil then
g_NrInfo.PrevValues.ConnectToAll = CurrConnectToAll
end
for Index = 1, #g_NrInfo.PrevValues.IncomingNr, 1 do
g_NrInfo.CombinedTamMsnList[Index] = loadstring("return box.post.OldFnc_CombinedTamMsnList" .. Index)()
g_NrInfo.PrevValues.IncomingNr[Index] = loadstring("return box.post.OldFnc_IncomingNr" .. Index)()
end
g_NrInfo.PrevValues.OutgoingNr = loadstring("return box.post.OldFnc_" .. g_Id_ChoiceBoxOutgoingNrBox)()
local CurrOutgoingNr = loadstring("return box.post.NewFnc_" .. g_Id_ChoiceBoxOutgoingNrBox)()
if CurrOutgoingNr ~= nil then
g_NrInfo.PrevValues.OutgoingNr = CurrOutgoingNr
end
if g_CapitermEnabled == "T" then
capiterm.var("HiddenValuesFromBox:g_NrInfo.PrevValues", g_NrInfo.PrevValues, g_CapitermInfo)
end
if HasClickFields then
for Index = 1, #g_NrInfo.All, 1 do
if loadstring("return box.post.NewFnc_" .. g_NrInfo.All[Index].TypLfNr)() == nil then
g_NrInfo.All[Index].IsClicked = "off"
else
g_NrInfo.All[Index].IsClicked = "on"
end
if g_CapitermEnabled == "T" then
capiterm.var( "HiddenValuesFromBox:g_NrInfo.All[" .. Index .. "].IsClicked",
g_NrInfo.All[Index].IsClicked, g_CapitermInfo
)
end
end
else
for Index = 1, #g_NrInfo.PrevValues.IncomingNr, 1 do
if g_NrInfo.PrevValues.IncomingNr[Index] ~= "" then
if g_CapitermEnabled == "T" then
capiterm.var( "HiddenValuesFromBox RestoreByPrevValues: SetClickedByNr",
g_NrInfo.PrevValues.IncomingNr[Index], g_CapitermInfo
)
end
SetClickedByNr(g_NrInfo.PrevValues.IncomingNr[Index])
end
end
end
end
function MessageOnInvalidClicks(IsTamIntern, ShowMessage, CheckOutgoingNr, ConnectAllExist)
if g_CapitermEnabled == "T" then
capiterm.var( "MessageOnInvalidClicks",
{ {IsTamIntern = IsTamIntern}, {ShowMessage = ShowMessage}, {CheckOutgoingNr = CheckOutgoingNr},
{ConnectAllExist = ConnectAllExist}
}, g_CapitermInfo
)
end
local UsedByOther = 0
if IsTamIntern == "TamIntern" then
UsedByOther = g_NrInfo.TamOther.Count
end
if (ConnectAllExist == "ConnectAllExist") and (g_NrInfo.PrevValues.ConnectToAll == "T") then
return false
end
local OutgoingNrKorrektur = 0
if CheckOutgoingNr == "CheckOutgoingNr" then
if g_NrInfo.PrevValues.OutgoingNr == "" then
OutgoingNrKorrektur = 1
else
local Found = false
for Index = 1, #g_NrInfo.PrevValues.IncomingNr, 1 do
if g_NrInfo.PrevValues.OutgoingNr == g_NrInfo.PrevValues.IncomingNr[Index] then
Found = true
break
end
end
if not Found then
OutgoingNrKorrektur = 1
end
end
end
if (UsedByOther + GetCountSelected()) > (g_NrInfo.MaxSelectedCount - OutgoingNrKorrektur) then
if ShowMessage == "ShowMessage" then
if UsedByOther ~= 0 then
if UsedByOther == g_NrInfo.MaxSelectedCount then
g_NrInfo.Alert.Id_FncTamToMuchMsnsGlobal = g_txt_TamToMuchMsnsGlobal
elseif UsedByOther == (g_NrInfo.MaxSelectedCount - 1) then
g_NrInfo.Alert.Id_FncToMuchMsnsMaxOne = g_txt_ToMuchMsnsMaxOne
else
g_NrInfo.Alert.Id_FncToMuchMsnsVariableNr = general.sprintf( g_txt_ToMuchMsnsVariableNr,
g_NrInfo.MaxSelectedCount - UsedByOther
)
end
else
if OutgoingNrKorrektur > 0 then
g_NrInfo.Alert.Id_FncToMuchMsnsNoOutgoingNr = g_txt_ToMuchMsnsNoOutgoingNr
else
g_NrInfo.Alert.Id_FncToMuchMsnsVariableNr = general.sprintf( g_txt_ToMuchMsnsVariableNr,
g_NrInfo.MaxSelectedCount
)
end
end
end
return true
end
return false
end
function SummaryLine(Left, Right)
Htm2Box("<tr>")
Htm2Box( "<td class='ClassSummary_Nr'>")
Htm2Box( Left)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummary_Connect'>")
Htm2Box( Right)
Htm2Box( "</td>")
Htm2Box("</tr>")
end
function BoxOutHtmlCode_SummaryOutgoingNr(VarianteSource, TableClass)
capiterm.var("VarianteSource",VarianteSource)
local Variante = GetVariante(VarianteSource, "Out")
local Index = GetIndexByTypLfNr(g_NrInfo.PrevValues.OutgoingNr)
local OutNrShown
ToBox("<table class='".. TableClass .. "'>")
if (g_NrInfo.All[Index].TypLfNr == "Pots0") and (g_NrInfo.All[Index].Nr == "") then
OutNrShown = {g_txt_Festnetz, ""}
else
OutNrShown = GetNumberInfosForTyp(g_NrInfo.All[Index], Variante, false)
end
if (OutNrShown == nil) then
return
end
capiterm.var("OutNrShown",OutNrShown)
SummaryLine( string_op.trim_start_end_spaces(g_NrInfo.All[Index].Nr),
string_op.trim_start_end_spaces(OutNrShown[2]))
ToBox("</table>")
end
function BoxOutHtmlCode_SummaryIncomingNr(VarianteSource, TableClass,AlleCall)
local Variante = GetVariante(VarianteSource, "In")
local OutNrShown
local Found = false
ToBox("<table class='".. TableClass .. "'>")
if g_NrInfo.PrevValues.ConnectToAll == "F" then
for Index = 1, #g_NrInfo.All, 1 do
if g_NrInfo.All[Index].IsClicked == "on" then
Found = true
if (g_NrInfo.All[Index].TypLfNr == "Pots0") and (g_NrInfo.All[Index].Nr == "") then
OutNrShown = {g_txt_Festnetz, ""}
else
OutNrShown = GetNumberInfosForTyp(g_NrInfo.All[Index], Variante, false)
end
if (OutNrShown ~= nil) then
SummaryLine( string_op.trim_start_end_spaces(g_NrInfo.All[Index].Nr),
string_op.trim_start_end_spaces(OutNrShown[2])
)
end
end
end
end
if g_NrInfo.PrevValues.ConnectToAll == "T" then
ToBox("<tr>")
ToBox( "<td class='ClassNumberList_EmptyOrNothing'>")
if AlleCall == "T" then
ToBox( g_txt_AlleCallNr)
else
ToBox( g_txt_AlleNr)
end
ToBox( "</td>")
ToBox("</tr>")
elseif Found == false then
ToBox("<tr>")
ToBox( "<td class='ClassNumberList_EmptyOrNothing'>")
if AlleCall == "T" then
ToBox( g_txt_KeineCallNr)
else
ToBox( g_txt_KeineNr)
end
ToBox( "</td>")
ToBox("</tr>")
end
ToBox("</table>")
end
function TamSaveButton(TamNr, IgnoreTooMuchSelected)
if g_CapitermEnabled == "T" then
capiterm.var( "TamSaveButton:Param",
{{TamNr = TamNr}, {IgnoreTooMuchSelected = IgnoreTooMuchSelected}}, g_CapitermInfo
)
end
if g_NrInfo.ViewConnectToAllOrUser == "T" then
g_NrInfo.PrevValues.ConnectToAll = box.post.NewFnc_ConnectToAll
if g_CapitermEnabled == "T" then
capiterm.var( "TamSaveButton:g_NrInfo.PrevValues.ConnectToAll", g_NrInfo.PrevValues.ConnectToAll,
g_CapitermInfo
)
end
end
if TamNr == 0 then
if g_NrInfo.PrevValues.ConnectToAll == "T" then
for Index = 1, #g_NrInfo.All, 1 do
g_NrInfo.All[Index].IsClicked = "off"
if g_CapitermEnabled == "T" then
capiterm.var( "TamSaveButton:g_NrInfo.All[" .. Index .. "].IsClicked", g_NrInfo.All[Index].IsClicked,
g_CapitermInfo
)
end
end
return true
end
end
if IgnoreTooMuchSelected == false then
if MessageOnInvalidClicks("TamIntern", "ShowMessage", "NoCheckOutgoingNr", "NoConnectAllExist") then
return false
end
end
for Index = 1, g_NrInfo.MaxSelectedCount, 1 do
g_NrInfo.PrevValues.IncomingNr[Index] = ""
if g_CapitermEnabled == "T" then
capiterm.var( "TamSaveButton:g_NrInfo.PrevValues.IncomingNr[" .. Index .. "]",
g_NrInfo.PrevValues.IncomingNr[Index], g_CapitermInfo
)
end
end
local Next = 1
for Index = 1, #g_NrInfo.All, 1 do
if (Next <= g_NrInfo.MaxSelectedCount) and (g_NrInfo.All[Index].IsClicked == "on") then
g_NrInfo.PrevValues.IncomingNr[Next] = g_NrInfo.All[Index].TypLfNr
if g_CapitermEnabled == "T" then
capiterm.var( "TamSaveButton:g_NrInfo.PrevValues.IncomingNr[" .. Next .. "]",
g_NrInfo.PrevValues.IncomingNr[Next], g_CapitermInfo
)
end
Next = Next + 1
end
end
if IgnoreTooMuchSelected == true then
return true
end
if (TamNr == 0) and (GetCountSelected() == 0) then
g_NrInfo.Alert.Id_FncTamNoNr = g_txt_TamNoNr
return false
end
return true
end
function SaveHandler(Curr, StoreTo, FaxWeiche, RemoveOutgoingFromIncoming, AddFestnetz)
if Curr.IsClicked == "off" then
return StoreTo
end
local Store = Curr
if (config.FAX2MAIL == 1) and FaxWeiche and (Store.Nr == "**329") then
Store.OutNrShown[2] = g_txt_FaxWeiche
end
if (g_NrInfo.UsePstn == "1") and (Store.TypLfNr == "Pots0") then
if (Store.Nr == "") or AddFestnetz then
Store.OutNrShown = {g_txt_Festnetz, ""}
end
end
if (Store.TypLfNr ~= g_NrInfo.PrevValues.OutgoingNr) or (not RemoveOutgoingFromIncoming) then
if StoreTo <= g_NrInfo.MaxSelectedCount then
g_NrInfo.PrevValues.IncomingNr[StoreTo] = Store.TypLfNr
if g_CapitermEnabled == "T" then
capiterm.var( "SaveHandler:g_NrInfo.PrevValues.IncomingNr[" .. StoreTo .. "]",
g_NrInfo.PrevValues.IncomingNr[StoreTo], g_CapitermInfo
)
end
end
StoreTo = StoreTo + 1
end
return StoreTo
end
function SaveButton(FaxWeiche, RemoveOutgoingFromIncoming, AddFestnetz)
local StoreTo = 1
local ConnectToAll = "F"
if g_CapitermEnabled == "T" then
capiterm.var( "SaveButton:Param",
{ {FaxWeiche = FaxWeiche}, {RemoveOutgoingFromIncoming = RemoveOutgoingFromIncoming},
{AddFestnetz = AddFestnetz}
}, g_CapitermInfo
)
end
for Index = 1, g_NrInfo.MaxSelectedCount, 1 do
g_NrInfo.PrevValues.IncomingNr[Index] = ""
end
if g_CapitermEnabled == "T" then
capiterm.txt_nl( "SaveButton Clear First:g_NrInfo.PrevValues.IncomingNr[1.."
.. g_NrInfo.MaxSelectedCount .."]=EMPTY", g_CapitermInfo
)
end
for Index = 1, #g_NrInfo.All, 1 do
if g_CapitermEnabled == "T" then
capiterm.var("SaveButton g_NrInfo.All[" .. Index .. "].IsClicked", g_NrInfo.All[Index].IsClicked, g_CapitermInfo)
end
StoreTo = SaveHandler( g_NrInfo.All[Index], StoreTo, FaxWeiche == "FaxWeiche",
RemoveOutgoingFromIncoming == "RemoveOutEqIn", AddFestnetz == "AddFestnetz"
)
end
end
function FillOutNrOptionTable(Table, Curr, SelectTypLfNr, Shown, PotsToText)
if Shown ~= nil then
if (Shown[1] == "Pots0") and PotsToText then
Shown[1] = g_txt_Festnetz
else
Shown[1] = GetRealNumber(Shown[1], false)
end
if Shown[2] ~= "" then
Shown[2] = " " .. Shown[2]
end
table.insert(Table, {Value = Curr.TypLfNr, Text = Shown[1] .. Shown[2]})
return Curr.TypLfNr == SelectTypLfNr
end
return false
end
function BoxOutHtmlCode_GetOutgoingNrBox( VarianteSource, SelectTypLfNr, EmptyEntry, WithCallback, PotsToText,
IgnoreListe
)
if g_CapitermEnabled == "T" then
capiterm.var( "BoxOutHtmlCode_GetOutgoingNrBox:Param",
{ {VarianteSource = VarianteSource}, {SelectTypLfNr = SelectTypLfNr},
{EmptyEntry = EmptyEntry}, {WithCallback = WithCallback}, {PotsToText = PotsToText},
{IgnoreListe = IgnoreListe}
}, g_CapitermInfo
)
end
local OutNrShown
local Found = false
local Callback = ""
if WithCallback == "WithCallback" then
Callback = " onchange='fon_nr_config_OnChangeOutgoingNrEditSides()'"
end
SelectTypLfNr = string.gsub(SelectTypLfNr, "#", "")
local Variante = GetVariante(VarianteSource, "Out")
local Curr
local Table = {}
for Index = 1, #g_NrInfo.All, 1 do
if g_NrInfo.All[Index].Typ == "Sip" then
Curr = g_NrInfo.All[Index]
OutNrShown = FormatNrByVariant(Curr, Variante, GetIndexByNr("Msn", Curr.Nr) ~= -1, Curr.Nr == PotsElement().Nr)
if not string_op.in_list(g_NrInfo.All[Index].Nr, IgnoreListe) then
Found = FillOutNrOptionTable(Table, Curr, SelectTypLfNr, OutNrShown, PotsToText == "PotsToText") or Found
end
end
end
for Index = 1, #g_NrInfo.All, 1 do
if g_NrInfo.All[Index].Typ == "Msn" then
OutNrShown = FormatNrByVariant( g_NrInfo.All[Index], Variante, GetIndexByNr("Sip", g_NrInfo.All[Index].Nr) ~= -1,
false
)
Found = FillOutNrOptionTable(Table, g_NrInfo.All[Index], SelectTypLfNr, OutNrShown, PotsToText == "PotsToText")
or Found
end
end
OutNrShown = nil
Curr = PotsElement()
if config.CAPI_NT or config.CAPI_POTS then
OutNrShown = FormatNrByVariant(Curr, Variante, false, GetIndexByNr("Sip", Curr.Nr) ~= -1)
if IsPotsSpecialModeBOrD(Curr.Nr, #Table == 0, Variante) then
OutNrShown = {"Pots0", ""}
PotsToText = "PotsToText"
end
end
Found = FillOutNrOptionTable(Table, Curr, SelectTypLfNr, OutNrShown, PotsToText == "PotsToText") or Found
Curr = GsmElement()
Found = FillOutNrOptionTable( Table, Curr, SelectTypLfNr, FormatNrByVariant(Curr, Variante, false, false),
PotsToText == "PotsToText"
) or Found
if EmptyEntry == "EmptyEntry" then
table.insert(Table, {Value = "Empty0", Text = ""})
Found = Found or (SelectTypLfNr == "Empty0")
end
if VarianteSource == "AssiOut" then
Htm2Box("<div>")
for Index = 1, #Table, 1 do
box.out( "<p>")
assi_control.InputField( "InputLabel", "radio", g_Id_ChoiceBoxOutgoingNrBox, "++"..Index,
Table[Index].Text,
nil, nil, Table[Index].Value, string_op.txt_checked((Table[Index].Value == SelectTypLfNr) or ((not Found) and (Index == 1))),
"", "", "NewFnc_")
box.out( "</p>")
end
Htm2Box("</div>")
else
ToBox("<select name='NewFnc_" .. g_Id_ChoiceBoxOutgoingNrBox .."' id='Id_" .. g_Id_ChoiceBoxOutgoingNrBox .. "'"
.. Callback .. ">"
)
for Index = 1, #Table, 1 do
Htm2Box( "<option value='" .. box.tohtml(Table[Index].Value) .. "'"
.. string_op.txt_selected((Table[Index].Value == SelectTypLfNr) or ((not Found) and (Index == 1)))
.. ">"
)
Htm2Box( Table[Index].Text)
Htm2Box("</option>")
end
ToBox("</select>")
end
end
function GetIndexFromNameOrNumber(NameOrNumber, IsName)
local Index
NameOrNumber = string.gsub(NameOrNumber, "#", "")
if IsName then
Index = GetIndexByName("All", NameOrNumber)
else
Index = GetIndexByNr("All", NameOrNumber)
end
return Index
end
function SetRingtone(Index, Tone)
g_NrInfo.All[Index].RingTone = Tone
end
function SetSelectedNumbers(StoreOutgoingNr, StoredUnder, PostfixNr, PostfixTone, ConnectToAll, IsName)
if g_CapitermEnabled == "T" then
capiterm.var( "SetSelectedNumbers: Param",
{ {StoreOutgoingNr = StoreOutgoingNr}, {StoredUnder = StoredUnder}, {PostfixNr = PostfixNr},
{PostfixTone = PostfixTone}, {ConnectToAll = ConnectToAll}, {IsName = IsName}
}, g_CapitermInfo
)
end
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@SetSelectedNumbers")
IsName = IsName == "IsName"
g_NrInfo.PrevValues.ConnectToAll = "F"
StoreOutgoingNr = StoreOutgoingNr == "SaveOutgoing"
if ConnectToAll ~= nil then
if Query(ConnectToAll, CapitermInfo) == "1" then
g_NrInfo.PrevValues.ConnectToAll = "T"
end
end
for Index = 1, g_NrInfo.MaxSelectedCount, 1 do
g_NrInfo.PrevValues.IncomingNr[Index] = ""
end
local OutgoingNr = Query(StoredUnder .. "0" .. PostfixNr, CapitermInfo)
g_NrInfo.PrevValues.OutgoingNr = ""
if StoreOutgoingNr then
local NrIndex = GetIndexFromNameOrNumber(OutgoingNr, IsName)
if NrIndex ~= -1 then
g_NrInfo.PrevValues.OutgoingNr = g_NrInfo.All[NrIndex].TypLfNr
if PostfixTone ~= nil then
SetRingtone(NrIndex, Query(StoredUnder .. "0" .. PostfixTone, CapitermInfo))
end
end
end
local CopyFrom = 0
local Max = g_NrInfo.MaxSelectedCount
if string.find(OutgoingNr, "#") ~= nil then
CopyFrom = 1
Max = Max - 1
end
for Index = 1, Max, 1 do
local NrIndex = GetIndexFromNameOrNumber(Query(StoredUnder .. CopyFrom .. PostfixNr, CapitermInfo), IsName)
if NrIndex ~= -1 then
g_NrInfo.PrevValues.IncomingNr[Index] = g_NrInfo.All[NrIndex].TypLfNr
if g_CapitermEnabled == "T" then
capiterm.var("SetSelectedNumbers: SetClickedByNr", g_NrInfo.PrevValues.IncomingNr[Index], g_CapitermInfo)
end
SetClickedByNr(g_NrInfo.PrevValues.IncomingNr[Index])
if PostfixTone ~= nil then
SetRingtone(NrIndex, Query(StoredUnder .. CopyFrom .. PostfixTone, CapitermInfo))
end
end
CopyFrom = CopyFrom + 1
end
end
function JavaScriptsListeAppend(Text, New, IsFirst)
if IsFirst then
return Text .. "\n" .. New
end
return Text .. ",\n" .. New
end
function BoxJs(Text)
local Table = string_op.split2table(Text, '\n', 0)
for Index = 1, #Table, 1 do
box.js(Table[Index])
if Index < #Table then
box.out("\\n")
end
end
end
function BoxAlert(Condition, Text)
if Condition ~= nil then
box.out("if (" .. Condition .. ")\n")
end
box.out("{\n")
box.out( "alert('")
BoxJs( Text)
box.out( "');\n")
box.out( "return false;\n")
box.out("}\n")
end
function JavaScriptCb_NrHandling(ThisSide, IsTamIntern, HasConnectToAll, WorkAs, IsTam)
if ThisSide == false then
return
end
local Next = 0
ToBox("<script type='text/javascript'>")
local Text = "var gId = ["
for Index = 1, #g_NrInfo.All, 1 do
if g_NrInfo.All[Index].HtmlCodeExist then
Text = JavaScriptsListeAppend(Text, "'" .. g_NrInfo.All[Index].TypLfNr .. "'", Next == 0)
Next = Next + 1
end
end
local Maximum = g_NrInfo.MaxSelectedCount
if IsTamIntern then
Maximum = g_NrInfo.MaxSelectedCount - g_NrInfo.TamOther.Count
if Maximum < 0 then
Maximum = 0
end
end
box.out(Text .. "\n];\n")
box.out("var gCurrOut = jxl.getValue('Id_" .. g_Id_ChoiceBoxOutgoingNrBox .. "');\n")
box.out("var gCurrOutCheckValue = jxl.getChecked('" .. g_Id_ChoiceBoxHakenPraefix .. "' + gCurrOut);\n")
box.out("function fon_nr_config_OnClickNr(ExternId, Id)\n")
box.out("{\n")
box.out( "if (Id.replace('" .. g_Id_ChoiceBoxHakenPraefix .. "', '') == gCurrOut)\n")
box.out( "{\n")
box.out( "gCurrOutCheckValue = jxl.getChecked(Id);\n")
box.out( "}\n")
box.out( "var Count = 0;\n")
box.out( "for (var Index = 0; Index < gId.length; Index++)\n")
box.out( "{\n")
box.out( "if (jxl.getChecked('" .. g_Id_ChoiceBoxHakenPraefix .. "' + gId[Index]))\n")
box.out( "{\n")
box.out( "Count++;\n")
box.out( "}\n")
box.out( "}\n")
if not IsTam then
box.out( "if (gId.length==1 && Count==1) {")
box.out( " if (!confirm('") box.js(TXT([[{?607:467?}]])) box.out("')) return false;")
box.out( "}")
end
box.out( "if (ExternId != '')")
box.out( "{\n")
box.out( "jxl.display(ExternId, Count == 0);\n")
box.out( "}\n")
box.out( "jxl.display('Id_FncTamNoNr', Count == 0);\n")
box.out( "var Display = Count > " .. Maximum .. ";\n")
for Id, _ in pairs(g_NrInfo.Alert) do
if Id ~= "Id_FncTamNoNr" then
box.out("jxl.display('" .. Id .. "', Display);\n")
end
end
box.out(" return true;}\n")
if string_op.in_list(g_Box.WorkAs, {"Edit", "Wizard"}) then
box.out("function fon_nr_config_OnChangeOutgoingNrEditSides()\n")
box.out("{\n")
box.out( "var ConnectToAll = jxl.getChecked('Id_" .. g_Id_ToogleBoxIsConnectToAll .. "');\n")
box.out( "jxl.setChecked('" .. g_Id_ChoiceBoxHakenPraefix .. "' + gCurrOut, gCurrOutCheckValue);\n")
box.out( "for (var Index = 0; Index < gId.length; Index++)\n")
box.out( "{\n")
box.out( "var SpanId = '" .. g_Id_ChoiceBoxConTypOutNrSpanPraefix .. "' + gId[Index];\n")
box.out( "var HtmlText = jxl.getHtml(SpanId).replace(/\\n/, '').replace(/^\\s*/, '').replace(/\\s+$/, '');\n")
box.out( "if (HtmlText != '')\n")
box.out( "{\n")
box.out( "HtmlText = HtmlText.replace(', " .. g_txt_OutgoingNr .. ")', ')');\n")
box.out( "HtmlText = HtmlText.replace('" .. g_txt_OutgoingNrKlammer .. "', '');\n")
box.out( "jxl.setHtml(SpanId, HtmlText);\n")
box.out( "}\n")
box.out( "}\n")
box.out( "var CurrOut = jxl.getValue('Id_" .. g_Id_ChoiceBoxOutgoingNrBox .. "');\n")
box.out( "for (var Index = 0; Index < gId.length; Index++)\n")
box.out( "{\n")
box.out( "if (CurrOut == gId[Index])\n")
box.out( "{\n")
box.out( "gCurrOut = CurrOut;\n")
box.out( "gCurrOutCheckValue = jxl.getChecked('" .. g_Id_ChoiceBoxHakenPraefix .. "' + gCurrOut);\n")
box.out( "jxl.setChecked('" .. g_Id_ChoiceBoxHakenPraefix .. "' + gCurrOut, true);\n")
box.out( "var SpanId = '" .. g_Id_ChoiceBoxConTypOutNrSpanPraefix .. "' + gCurrOut;\n")
box.out( "var HtmlText = jxl.getHtml(SpanId).replace(/\\n/, '').replace(/^\\s*/, '').replace(/\\s+$/, '');\n")
box.out( "if (HtmlText == '')\n")
box.out( "{\n")
box.out( "jxl.setHtml(SpanId, '" .. g_txt_OutgoingNrKlammer .. "');\n")
box.out( "return;\n")
box.out( "}\n")
box.out( "jxl.setHtml(SpanId, HtmlText.replace(')', ', " .. g_txt_OutgoingNr .. ")'));\n")
box.out( "return;\n")
box.out( "}\n")
box.out( "}\n")
box.out("}\n")
end
if HasConnectToAll then
box.out("function fon_nr_config_OnChangeConnectMode()\n")
box.out("{\n")
box.out( "var DisableUserArea = jxl.getChecked('Id_" .. g_Id_ToogleBoxIsConnectToAll .. "');\n")
box.out( "for (var Index = 0; Index < gId.length; Index++)\n")
box.out( "{\n")
box.out( "jxl.setDisabled('" .. g_Id_ChoiceBoxHakenPraefix .. "' + gId[Index], DisableUserArea);\n")
box.out( "}\n")
box.out( "if (DisableUserArea)\n")
box.out( "{\n")
for Id, _ in pairs(g_NrInfo.Alert) do
box.out( "jxl.hide('" .. Id .. "');\n")
end
box.out( "}\n")
box.out("}\n")
box.out("function fon_nr_config_EnableAllIncomingNr()\n")
box.out("{\n")
box.out( "for (var Index = 0; Index < gId.length; Index++)\n")
box.out( "{\n")
box.out( "jxl.setDisabled('" .. g_Id_ChoiceBoxHakenPraefix .. "' + gId[Index], false);\n")
box.out( "}\n")
box.out("}\n")
end
if HasConnectToAll or string_op.in_list(g_Box.WorkAs, {"Edit", "Wizard"}) then
box.out("function fon_nr_config_OnReady()\n")
box.out("{\n")
if string_op.in_list(g_Box.WorkAs, {"Edit", "Wizard"}) then
box.out("fon_nr_config_OnChangeOutgoingNrEditSides()\n")
end
if HasConnectToAll then
box.out("fon_nr_config_OnChangeConnectMode()\n")
end
box.out("}\n")
box.out("ready.onReady(fon_nr_config_OnReady);\n")
end
ToBox("</script>")
end
function Debug()
end
function NoNumbersExist()
for Index = 1, #g_NrInfo.All, 1 do
if g_NrInfo.All[Index].Nr ~= "" then
return false
end
end
return true
end
function SkipToNumberConfig(nextpage)
require ("http")
require ("href")
local params = {}
table.insert(params,'back_to_page='..nextpage)
local pathname = "first"
local filename = ""
if (not config.CAPI_TE) and (not config.CAPI_POTS) then
http.redirect(href.get_paramtable('/assis/assi_fon_nums.lua',params))
return
else
if config.TR069 then
if box.query("telcfg:settings/ShowPSTN") == "0" then
http.redirect(href.get_paramtable('/assis/assi_fon_nums.lua',{"configure=inet"}))
end
end
http.redirect(href.get_paramtable('/assis/assi_fon_nums.lua',params))
end
end
