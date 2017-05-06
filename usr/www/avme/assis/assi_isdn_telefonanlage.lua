<?lua
dofile("../templates/global_lua.lua")
require("capiterm")
require("http")
require("fon_nr_config")
require("html_check")
require("assi_control")
require("general")
g_page_type="wizard"
g_CapitermEnabled = "F"
g_CapitermInfo = assi_control.TraceStart(g_CapitermEnabled, box.glob.script)
g_OptionTable = {}
g_Alert = {}
g_Box = { WhoAmI = box.glob.script,
FinishPage = "/assis/assi_fondevices_list.lua",
WorkAs = "Assi",
DeviceTyp = "Isdn",
TechTyp = "ISDN",
EditTab = "Übersicht",
EditDeviceNo = "",
CurrSide = "AssiIsdnTeleDevEinrichten",
PageTitle = "",
PageTitleParam = ""
}
g_BoxRefresh = { { Token = "Back2Page", WorkAs = {"Assi"},
Control = "nil", Init = "/assis/assi_telefon_start.lua"
},
{ Token = "StartPage", WorkAs = {"Assi"},
Control = "nil", Init = "/assis/home.lua"
},
{ Token = "FreeNtHotDialIndex", WorkAs = {"Assi"},
Control = "nil", Init = 0
},
{ Token = "NtDefault", WorkAs = {"Assi"},
Control = "nil", Init = ""
}
}
g_Const = {NtHotDialListEntry = 8}
g_SideList = {AssiIsdnTeleAnlage = {"AssiIsdnTeleDevEinrichten", "AssiIsdnTeleDevSummary"}}
g_SideHeader = { { Id = {"AssiIsdnTeleDevEinrichten"},
Head = [[{?g_txt_IsdnTeleanlageEinrichten?}]]
},
{ Id = {"AssiIsdnTeleDevSummary"},
Head = [[{?g_txt_ISDNGeraetSummary?}]]
}
}
g_Txt = { FonS0Isdn = [[{?g_txt_FonS0Isdn?}]],
TkAnlage = [[{?g_txt_TkAnlage?}]],
Zurueck = [[{?g_txt_Zurueck?}]],
Weiter = [[{?g_txt_Weiter?}]],
Uebernehmen = [[{?g_txt_Uebernehmen?}]],
Abbrechen = [[{?g_txt_Abbrechen?}]]
}
function LoadFromBox(BoxVariablen)
if g_CapitermEnabled == "T" then
capiterm.txt_nl("LoadFromBox", g_CapitermInfo)
end
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@LoadFromBox")
assi_control.InitWithDefaults(BoxVariablen)
g_Box.NtDefault = fon_nr_config.Query( "telcfg:settings/MSN/NTDefault", g_CapitermInfo)
if config.CAPI_NT then
for Index = 1, g_Const.NtHotDialListEntry, 1 do
if fon_nr_config.Query("telcfg:settings/NTHotDialList/Number" .. Index, CapitermInfo) == "" then
g_Box.FreeNtHotDialIndex = Index
break
end
end
end
end
function HandleSubmitSave()
if box.post.Submit_Save == nil then
return
end
if g_CapitermEnabled == "T" then
capiterm.txt_nl("HandleSubmitSave", g_CapitermInfo)
end
local Table = {}
local IsdnNumber = "5" .. g_Box.FreeNtHotDialIndex
if g_Box.NtDefault == "" then
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/NTDefault", IsdnNumber)
end
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/NTHotDialList/Type" .. g_Box.FreeNtHotDialIndex, "Isdn")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/NTHotDialList/Number" .. g_Box.FreeNtHotDialIndex, IsdnNumber)
fon_nr_config.Table2BoxSend(Table, "telcfg:settings/NTHotDialList/Name" .. g_Box.FreeNtHotDialIndex, g_Txt.TkAnlage)
local FinishPage = assi_control.GetDefaultFinishPage(g_Box.FinishPage)
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(FinishPage,params))
end
function HandleSubmitBack()
if box.post.Submit_Back ~= nil then
if g_Box.CurrSide == g_SideList.AssiIsdnTeleAnlage[1] then
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_Box.Back2Page or g_Box.StartPage,params))
else
assi_control.SetNewPage(g_SideList.AssiIsdnTeleAnlage, -1)
end
return true
end
return false
end
function HandleSubmitNext()
if box.post.Submit_Next ~= nil then
assi_control.SetNewPage(g_SideList.AssiIsdnTeleAnlage, 1)
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
function Reloaded()
fon_nr_config.HiddenValuesFromBox(false)
SwitchToNextSide()
end
assi_control.Main("F", g_SideList.AssiIsdnTeleAnlage[1], false)
assi_control.DebugAll()
function Htm2Box(Text)
html_check.tobox(Text)
end
function Multiside_AssiIsdnTeleDevEinrichten()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?268:596?}]])
Htm2Box( "</p>")
Htm2Box( "<ol>")
Htm2Box( "<li>")
Htm2Box( [[{?268:441?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?268:456?}]])
Htm2Box( "</li>")
Htm2Box( "</ol>")
Htm2Box( "<div>")
Htm2Box( "<table class='ClassNumberListTable zebra'>")
fon_nr_config.BoxOutHtmlCode_HeaderIncomingNr( "DefNrClassIds",
[[{?g_txt_Rufnummer?}]],
"ClassSummaryTableColRight1"
)
fon_nr_config.BoxOutHtmlCode_IncomingNr( "AssiIn", "", "NoCheckBoxen", "CheckClicked",
"DefNrClassIds", "Label", "", 2
)
Htm2Box( "</table>")
Htm2Box( "</div>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiIsdnTeleDevSummary()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?268:709?}]])
Htm2Box( "</p>")
Htm2Box( "<table class='ClassSummaryListTable zebra'>")
assi_control.SummaryTableLine( 1, [[{?g_txt_Telefoniegeraet?}]],
g_Txt.TkAnlage, ""
)
assi_control.SummaryTableLine( 2, [[{?268:697?}]], g_Txt.FonS0Isdn,
""
)
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
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<link rel="stylesheet" type="text/css" href="/css/default/fon_nr_config.css">
<?include "templates/page_head.html" ?>
<?lua
box.out([[<script type="text/javascript" src="/js/wizard.js?lang=]], config.language, [["></script>]])
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
Htm2Box("<form method='POST' action='" .. box.glob.script .. "'>")
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
