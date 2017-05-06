<?lua
dofile("../templates/global_lua.lua")
require("capiterm")
require("http")
require("fon_nr_config")
require("general")
require("string_op")
require("html_check")
require("assi_control")
require("fon_book")
require("js")
g_page_type="wizard"
g_CapitermEnabled = "F"
g_CapitermInfo = assi_control.TraceStart(g_CapitermEnabled, box.glob.script)
g_OptionTable = {}
g_Alert = {}
g_Box = { WhoAmI = box.glob.script,
ExpertMode = fon_nr_config.Query("box:settings/expertmode/activated", g_CapitermInfo),
OpMode = box.query("box:settings/opmode"),
InterfaceIp = box.query("interfaces:settings/lan0/ipaddr"),
FinishPage = "/assis/assi_fondevices_list.lua",
WorkAs = "Assi",
DeviceTyp = "Fon",
TechTyp = "ANALOG",
EditTab = "",
EditDeviceNo = "",
CurrSide = "AssiFonConnecting",
RefreshPressed = "F",
PageTitle = "",
PageTitleParam = ""
}
g_BoxRefresh = { { Token = "Back2Page", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "nil", Init = "/assis/assi_telefon_start.lua"
},
{ Token = "StartPage", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "nil", Init = "/assis/home.lua"
},
{ Token = "Port", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "FreeNtHotDialIndex", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "nil", Init = -1
},
{ Token = "FreeDectPort", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "nil", Init = -1
},
{ Token = "IpPhoneNameSuffixNr", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "nil", Init = ""
},
{ Token = "FreeIpPhoneVseIndex", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "nil", Init = -1
},
{ Token = "FreeIpPhoneTsvIndex", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "nil", Init = -1
},
{ Token = "IpPassword", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "FonTestRepeated", WorkAs = {"Assi"},
Control = "nil", Init = "F"
},
{ Token = "InternalMemEnabled", WorkAs = {"Edit", "Wizard"},
Control = "nil", Init = "0"
},
{ Token = "DectSubscriptionState", WorkAs = {"Assi"},
Control = "nil", Init = "1"
},
{ Token = "DectRepeaterCount", WorkAs = {"Assi"},
Control = "nil", Init = "0"
},
{ Token = "DectHandsetToken", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "nil", Init = "Handset0"
},
{ Token = "DectHandsetCodecs", WorkAs = {"Edit", "Wizard"},
Control = "nil", Init = ""
},
{ Token = "DectManufacturer", WorkAs = {"Edit", "Wizard"},
Control = "nil", Init = ""
},
{ Token = "DectFoncontrolName", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "nil", Init = "0"
},
{ Token = "Notation", WorkAs = {"Assi", "Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "Edit", WorkAs = {"Edit"},
Control = "nil", Init = ""
},
{ Token = "NightMode", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "Default"
},
{ Token = "NightRingMode", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "Klingeln"
},
{ Token = "NightTimeControlEnabled", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "F"
},
{ Token = "NightTimeControlRingBlocked", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "F"
},
{ Token = "NightRingException", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "7Day"
},
{ Token = "NightRingTime", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "NightRingTimeEndHour", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "00"
},
{ Token = "NightRingTimeEndMinute", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "00"
},
{ Token = "NightRingTimeStartHour", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "00"
},
{ Token = "NightRingTimeStartMinute", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "00"
},
{ Token = "AnalogClir", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleANALOG", Init = "off"
},
{ Token = "Clip", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleANALOG", Init = "off"
},
{ Token = "ClipMode", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "Advanced"
},
{ Token = "AnalogAnklopfen", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleANALOG", Init = "off"
},
{ Token = "AnklopfenTyp", WorkAs = {"Edit", "Wizard"},
Control = "nil", Init = "Fon"
},
{ Token = "AnalogBusyOnBusy", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleANALOG", Init = "on"
},
{ Token = "Colr", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleANALOG", Init = "off"
},
{ Token = "Mwi", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleANALOG", Init = "off"
},
{ Token = "MwiMode", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = "Immer"
},
{ Token = "MwiVoice", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleANALOG", Init = "off"
},
{ Token = "MwiFax", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleANALOG", Init = "off"
},
{ Token = "MwiMail", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleANALOG", Init = "off"
},
{ Token = "FonbookSelectedLfNr", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "FonbookCount", WorkAs = {"Edit", "Wizard"},
Control = "nil", Init = ""
},
{ Token = "FonbookCountStoredInfos", WorkAs = {"Edit", "Wizard"},
Control = "nil", Init = ""
},
{ Token = "CountTamActivated", WorkAs = {"Edit", "Wizard"},
Control = "nil", Init = "0"
},
{ Token = "DectClir", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleDECT", Init = "off"
},
{ Token = "DectIsMtF", WorkAs = {"Edit", "Wizard"},
Control = "nil", Init = "F"
},
{ Token = "DectRingToneIntern", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "DectRingToneAlarm", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "DectRingToneVip", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "DectTamMonitorBitmap", WorkAs = {"Edit", "Wizard"},
Control = "nil", Init = ""
},
{ Token = "DectMonitorTam", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleDECT", Init = ""
},
{ Token = "DectVanity", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleDECT", Init = ""
},
{ Token = "DectBusyDelayed", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleDECT", Init = ""
},
{ Token = "DectEqualizeLow", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "DectEqualizeMedium", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "DectEqualizeHigh", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "DectHdOption", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = ""
},
{ Token = "DectAnklopfen", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleDECT", Init = "off"
},
{ Token = "DectBusyOnBusy", WorkAs = {"Edit", "Wizard"},
Control = "SLWizardFonMerkmaleDECT", Init = "on"
},
{ Token = "DectImagePath", WorkAs = {"Edit", "Wizard"},
Control = "New", Init = ""
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
g_SideMapping = { AssiFonMsnTest = "AssiFonConTest",
AssiFonDectOutgoing = "AssiFonOutgoing",
AssiFonDectIncoming = "AssiFonIncoming",
AssiFonIsdnSummary = "AssiFonSummary",
AssiFonDectSummary = "AssiFonSummary",
WizardFonStartIPPHONE = "WizardFonStartANALOG",
WizardFonStartDECT = "WizardFonStartANALOG",
WizardFonKlingelsperreDECT = "WizardFonKlingelsperreANALOG"
}
g_SideList = { AssiFonAnalog = { "AssiFonConnecting", "AssiFonConTest", "AssiFonOutgoing", "AssiFonIncoming",
"AssiFonSummary", "AssiFonCheckPort"
},
AssiFonIsdn = { "AssiFonConnecting", "AssiFonOutgoing", "AssiFonIsdnIncoming",
"AssiFonMsnTest", "AssiFonIsdnSummary", "AssiFonCheckMsnOnIsdn"
},
AssiFonDect = { "AssiFonConnecting", "AssiFonDectConStart", "AssiFonDectConnect", "AssiFonDectTest",
"AssiFonDectName", "AssiFonDectOutgoing", "AssiFonDectIncoming", "AssiFonDectSummary",
"AssiFonDectCheckPort"
},
AssiFonIpPhone = { "AssiFonConnecting", "AssiFonIpOption", "AssiFonOutgoing", "AssiFonIncoming",
"AssiFonSummary"
},
WizardFonAnalog = {"WizardFonStartANALOG", "WizardFonKlingelsperreANALOG", "WizardFonMerkmaleANALOG"},
WizardFonIsdn = {"WizardFonStartISDN", "WizardFonS0ISDN", "WizardFonKlingelsperreISDN"},
WizardFonDect = { "WizardFonStartDECT", "WizardFonKlingeltoeneDECT", "WizardFonKlingelsperreDECT",
"WizardFonMerkmaleDECT"
},
WizardFonIpPhone = {"WizardFonStartIPPHONE", "WizardFonAnmeldedatenIPPHONE"},
CheckPortAndNotation = { "AssiFonConnecting", "AssiFonSummary", "AssiFonIsdnSummary",
"AssiFonDectSummary"
},
CheckDectNotation = { "AssiFonDectName", "AssiFonSummary", "WizardFonStartANALOG",
"WizardFonStartIPPHONE", "WizardFonStartDECT"
},
CheckOutgoing = { "AssiFonOutgoing", "AssiFonSummary", "WizardFonStartANALOG", "WizardFonStartDECT",
"WizardFonStartIPPHONE"
},
CheckIpPhonePassword = {"AssiFonIpOption", "AssiFonSummary", "WizardFonAnmeldedatenIPPHONE"},
GoBackToStartPage = { "AssiFonConnecting", "WizardFonStartANALOG", "WizardFonStartDECT",
"WizardFonStartIPPHONE", "WizardFonStartISDN"
},
GoBackTwoSides = {"AssiFonOutgoing", "AssiFonIsdnSummary"},
GoForwardToRingTest = {"AssiFonConnecting", "AssiFonIsdnIncoming"},
GoForwardChangeOutgoingNr = {"AssiFonOutgoing", "AssiFonDectOutgoing"},
HasIncomingNr = { "AssiFonIncoming", "AssiFonDectIncoming", "WizardFonStartANALOG",
"WizardFonStartDECT", "WizardFonStartIPPHONE"
},
EditHasNotation = { "WizardFonStartANALOG", "WizardFonStartDECT", "WizardFonStartIPPHONE",
"WizardFonStartISDN"
},
EditHasConnectToAll = { "WizardFonStartANALOG", "WizardFonStartDECT", "WizardFonStartIPPHONE",
"WizardFonStartISDN"
},
EditGenerateJsHideDataArea = { "WizardFonStartANALOG", "WizardFonKlingelsperreANALOG",
"WizardFonMerkmaleANALOG", "WizardFonStartDECT",
"WizardFonStartIPPHONE", "WizardFonStartISDN",
"WizardFonMerkmaleDECT"
}
}
g_SideHeader = { { Id = {"AssiFonConnecting"},
Head = [[{?g_txt_TelefonConnecting?}]]
},
{ Id = {"AssiFonConTest"},
Head = [[{?g_txt_TelefonConnectTest?}]]
},
{ Id = {"AssiFonOutgoing"},
Head = [[{?g_txt_TelefonOutgoing?}]]
},
{ Id = {"AssiFonIncoming"},
Head = [[{?g_txt_TelefonIncoming?}]]
},
{ Id = {"AssiFonSummary", "AssiFonIsdnSummary"},
Head = [[{?g_txt_TelefonSummary?}]]
},
{ Id = {"AssiFonMsnTest"},
Head = [[{?g_txt_TelefonMsnTest?}]]
},
{ Id = {"AssiFonDectConStart"},
Head = [[{?g_txt_TelefonDectConnectStart?}]]
},
{ Id = {"AssiFonDectConnect"},
Head = [[{?g_txt_TelefonDectConnect?}]]
},
{ Id = {"AssiFonDectTest"},
Head = [[{?g_txt_TelefonDectTest?}]]
},
{ Id = {"AssiFonDectName"},
Head = [[{?g_txt_TelefonDectName?}]]
},
{ Id = {"AssiFonDectOutgoing"},
Head = [[{?g_txt_TelefonDectOutgoing?}]]
},
{ Id = {"AssiFonDectIncoming"},
Head = [[{?g_txt_TelefonDectIncoming?}]]
},
{ Id = {"AssiFonDectSummary"},
Head = [[{?g_txt_TelefonSummary?}]]
},
{ Id = {"AssiFonIpOption"},
Head = [[{?g_txt_TelefonIpOption?}]]
},
{ Id = {"AssiFonIsdnIncoming"},
Head = [[{?g_txt_ISDNTelefonIncoming?}]]
},
{ Id = {"AssiFonCheckPort", "AssiFonDectCheckPort"},
Head = [[{?g_txt_CheckPort?}]]
},
{ Id = {"AssiFonCheckMsnOnIsdn"},
Head = [[{?g_txt_CheckMsnOnIsdn?}]]
},
{ Id = {"WizardFonStartANALOG", "WizardFonKlingelsperreANALOG", "WizardFonMerkmaleANALOG"},
Head = [[{?9108:164?}]]
},
{ Id = { "WizardFonStartDECT", "WizardFonKlingeltoeneDECT", "WizardFonKlingelsperreDECT",
"WizardFonMerkmaleDECT"
},
Head = [[{?9108:520?}]]
},
{ Id = {"WizardFonStartIPPHONE", "WizardFonAnmeldedatenIPPHONE"},
Head = [[{?9108:22?}]]
},
{ Id = {"WizardFonStartISDN", "WizardFonS0ISDN", "WizardFonKlingelsperreISDN"},
Head = [[{?9108:571?}]]
},
{ Id = {"WizardFonMerkmaleImageLoadDECT"},
Head = [[{?9108:345?}]]
}
}
g_DectState = { { Gif= "finished_ok_green.gif",
Text = [[{?9108:15?}]]
},
{ Gif= "wait.gif",
Text = [[{?9108:357?}]]
},
{ Gif= "finished_error.gif",
Text = [[{?9108:89?}]]
}
,{ Gif= "finished_ok_green.gif",
Text = [[{?9108:543?}]]
}
}
g_Txt = { LeererDectFonName = [[{?9108:87?}]],
LeeresKennwort = [[{?9108:563?}]],
SeeDokuTelefon = [[{?g_txt_SeeDokuTelefon?}]],
AufforderungEingabeNotation = [[{?9108:414?}]],
KennwortEingeben = [[{?9108:66?}]],
ErneutTesten = [[{?9108:306?}]],
AssiErneutStarten = [[{?9108:100?}]],
NoMoreIsdn = [[{?9108:451?}]],
NoNotation = [[{?9108:746?}]],
DoubleNotation = [[{?9108:399?}]],
NotationMaxXChar = [[{?g_txt_NotationMaxXChar?}]],
NoPort = [[{?9108:786?}]],
TkAnlage = [[{?g_txt_TkAnlage?}]],
TkAnlageForbidden = [[{?9108:385?}]]
.. "\n"
.. [[{?9108:310?}]]
.. "\n"
.. [[{?9108:316?}]],
Klingelton = [[{?9108:149?}]],
FonS0IsdnTelefon = [[{?g_txt_FonS0IsdnTelefon?}]],
FonS0IsdnTelefonName = [[{?g_txt_FonS0IsdnTelefonNAME?}]],
RufnummerEndgeraet = [[{?9108:396?}]],
FonS0 = [[{?9108:692?}]],
KingelspeereFonS0 = [[{?9108:939?}]],
Telefon = [[{?g_txt_Telefon?}]],
Telefonbuch = [[{?g_txt_Telefonbuch?}]],
DectSchnurlosTele = [[{?9108:334?}]],
Mobilteil = [[{?g_txt_Mobilteil?}]],
LanWLanIpPhone = [[{?g_txt_LanWLanIpPhone?}]],
LanWLanIpPhoneName = [[{?g_txt_LanWLanIpPhoneName?}]],
IPPhone = [[{?g_txt_IPPhone?}]],
Zurueck = [[{?g_txt_Zurueck?}]],
Weiter = [[{?g_txt_Weiter?}]],
Uebernehmen = [[{?g_txt_Uebernehmen?}]],
Abbrechen = [[{?g_txt_Abbrechen?}]],
Aktualisieren = [[{?g_txt_Aktualisieren?}]],
Ja = [[{?g_txt_Ja?}]],
Nein = [[{?g_txt_Nein?}]],
Ok = [[{?g_txt_Ok?}]],
Hilfe = [[{?g_txt_Hilfe?}]],
Rufnummer = [[{?g_txt_Rufnummer?}]],
Telefoniegeraet = [[{?g_txt_Telefoniegeraet?}]],
Klingelsperre = [[{?g_txt_Klingelsperre?}]],
Klingeltoene = [[{?g_txt_Klingeltoene?}]],
MerkmaleTeleGeraet = [[{?g_txt_MerkmaleTeleGeraet?}]],
Dect = [[{?9108:324?}]],
FonNAnalog = [[{?9108:171?}]],
Anmeldedaten = [[{?9108:7852?}]],
BitteWarten = [[{?9108:335?}]],
InvalidHour = [[{?9108:676?}]],
InvalidMinute = [[{?9108:885?}]],
BezeichnungDP = [[{?9108:119?}]],
belegt= [[{?9108:104?}]],
ClirActivation = [[{?9108:7539?}]]
.. "\n\n"
.. [[{?9108:516?}]],
ClirOhneFestnetz = [[{?9108:1805?}]]
.. "\n\n"
.. [[{?9108:987?}]]
}
g_DectHdOptionTable = { {Value = "0", Name = [[{?9108:787?}]]},
{Value = "1", Name = [[{?9108:970?}]]},
{Value = "2", Name = [[{?9108:236?}]]}
}
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
if g_Box.WorkAs ~= "Assi" then
return
end
for Index = 1, g_Const.AbCount, 1 do
SetBoxAnalogPortVariable(Index, "Name", "Name")
SetBoxAnalogPortVariable(Index, "Fax", "Fax")
SetBoxAnalogPortVariable(Index, "GroupCall", "GroupCall")
SetBoxAnalogPortVariable(Index, "AllIncomingCalls", "AllIncomingCalls")
SetBoxAnalogPortVariable(Index, "OutgoingNr", "MSN0")
end
if config.CAPI_NT then
for Index = 1, g_Const.NtHotDialListEntry, 1 do
if fon_nr_config.Query("telcfg:settings/NTHotDialList/Number" .. Index, CapitermInfo) == "" then
g_Box.FreeNtHotDialIndex = Index
break
end
end
end
if config.DECT then
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
and (g_Box.FreeIpPhoneTsvIndex == -1)
then
g_Box.FreeIpPhoneTsvIndex = Index
end
if ( fon_nr_config.Query("voipextension:settings/extension" .. Index .. "/enabled", CapitermInfo)
~= "1"
) and (g_Box.FreeIpPhoneVseIndex == -1)
then
g_Box.FreeIpPhoneVseIndex = Index
end
end
g_Box.IpPhoneNameSuffixNr = GetIpPhoneNameSuffixNr(IpPhoneNames)
end
g_OptionTable = assi_control.PrepareOptionList(false, "Fon", g_Txt.Telefon, g_Txt.FonS0IsdnTelefon)
end
function AddToSideNr(Direction)
local PortTyp = assi_control.GetPortTyp(g_Box.Port)
local SideList = ""
if g_Box.WorkAs == "Wizard" then
if config.CAPI_NT and PortTyp == "ISDN" then
SideList = g_SideList.WizardFonIsdn
elseif PortTyp == "DECT" then
SideList = g_SideList.WizardFonDect
elseif PortTyp == "IPPHONE" then
SideList = g_SideList.WizardFonIpPhone
else
SideList = g_SideList.WizardFonAnalog
end
else
if config.CAPI_NT and PortTyp == "ISDN" then
SideList = g_SideList.AssiFonIsdn
elseif PortTyp == "DECT" then
SideList = g_SideList.AssiFonDect
elseif PortTyp == "IPPHONE" then
SideList = g_SideList.AssiFonIpPhone
else
SideList = g_SideList.AssiFonAnalog
end
end
assi_control.SetNewPage(SideList, Direction)
end
function CheckSidePortAndNotation()
if not string_op.in_list(g_Box.CurrSide, g_SideList.CheckPortAndNotation) then
return
end
if g_Box.Port == "42" then
g_Alert.NoPort = g_Txt.NoPort
g_Alert.Side = "AssiFonConnecting"
end
if (g_Box.Port == "50") and (g_Box.FreeNtHotDialIndex == 0) then
g_Alert.NoMoreIsdn = g_Txt.NoMoreIsdn
g_Box.Port = "42"
g_Alert.Side = "AssiFonConnecting"
end
if assi_control.GetPortTyp(g_Box.Port) ~= "DECT" then
if g_Box.Notation == "" then
g_Alert.NoNotation = g_Txt.NoNotation
g_Alert.Side = "AssiFonConnecting"
end
if utf8.len(g_Box.Notation) > g_Const.MaxNotationLen then
g_Alert.NotationLen = general.sprintf(g_Txt.NotationMaxXChar, g_Const.MaxNotationLen)
g_Alert.Side = "AssiFonConnecting"
end
if g_Box.Notation == g_Txt.TkAnlage then
g_Alert.ReservedNotation = g_Txt.TkAnlageForbidden
g_Alert.Side = "AssiFonConnecting"
end
end
end
function CheckSideDectNotation()
if (assi_control.GetPortTyp(g_Box.Port) ~= "DECT")
or (not string_op.in_list(g_Box.CurrSide, g_SideList.CheckDectNotation))
then
return
end
if g_Box.Notation == "" then
g_Alert.NoNotation = g_Txt.LeererDectFonName
g_Alert.Side = string_op.bool_to_value(g_Box.CurrSide == "AssiFonSummary", "AssiFonDectName", g_Box.CurrSide)
end
if utf8.len(g_Box.Notation) > g_Const.MaxDectNotationLen then
g_Alert.NotationLen = general.sprintf(g_Txt.NotationMaxXChar, g_Const.MaxDectNotationLen)
g_Alert.Side = string_op.bool_to_value(g_Box.CurrSide == "AssiFonSummary", "AssiFonDectName", g_Box.CurrSide)
end
end
function CheckSideOutgoing()
if (assi_control.GetPortTyp(g_Box.Port) ~= "ISDN")
or (not string_op.in_list(g_Box.CurrSide, g_SideList.CheckOutgoing))
then
return
end
local OutgoingNr = fon_nr_config.GetRealNumber(fon_nr_config.NrInfo().PrevValues.OutgoingNr, false)
if assi_control.GetFreeFaxModemListSelector(OutgoingNr) ~= "" then
g_Alert.UpsOutgoingNr = "?OutgoingNr?"
g_Alert.Side = "AssiFonOutgoing"
end
end
function CheckSideEinstellungIpPhone()
if (assi_control.GetPortTyp(g_Box.Port) ~= "IPPHONE")
or (not string_op.in_list(g_Box.CurrSide, g_SideList.CheckIpPhonePassword))
then
return
end
if g_Box.IpPassword == "" then
g_Alert.IpPhonePasswordEmpty = g_Txt.LeeresKennwort
g_Alert.Side = "AssiFonIpOption"
end
if g_Box.IpPassword == "****" then
g_Alert.IpPhonePasswordStars = g_Txt.KennwortEingeben
g_Alert.Side = "AssiFonIpOption"
end
end
function CheckSideKlingelsperre()
if (g_Box.CurrSide ~= "WizardFonKlingelsperreANALOG") or (g_Box.NightMode == "Default") then
return
end
CheckTimeValue(g_Box.NightRingTimeStartHour, 23)
CheckTimeValue(g_Box.NightRingTimeStartMinute, 59)
CheckTimeValue(g_Box.NightRingTimeEndHour, 23)
CheckTimeValue(g_Box.NightRingTimeEndMinute, 59)
end
function TelefonHangUp(Table)
g_Box.RefreshPressed = "T"
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/DialPort", g_Const.RingTestDialPortIsdn)
fon_nr_config.Table2BoxSend(Table, "telcfg:command/Hangup", "")
end
function TelefonRingTest(IsdnMsnTest)
local DestPort = "**" .. g_Box.Port + 1
if config.CAPI_NT and assi_control.GetPortTyp(g_Box.Port) == "ISDN" then
if IsdnMsnTest then
DestPort = "**5*" .. fon_nr_config.GetRealNumber(fon_nr_config.NrInfo().PrevValues.OutgoingNr) .. "#"
else
DestPort = "**" .. g_Box.Port
end
end
if g_CapitermEnabled == "T" then
capiterm.txt_nl( "FonRingTest: Ringtest Port " .. g_Const.RingTestDialPortIsdn .. " -> Port " .. DestPort,
g_CapitermInfo
)
end
local Table = {}
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/DialPort", g_Const.RingTestDialPortIsdn)
fon_nr_config.Table2BoxSend(Table, "telcfg:command/Dial", DestPort)
end
function TelefonRingTestDect(Table, DectFoncontrolName)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@TelefonRingTestDect")
local Port = fon_nr_config.Query("telcfg:settings/Foncontrol/" .. DectFoncontrolName .. "/Intern", CapitermInfo)
if Port == "" then
Port = "50"
end
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/DialPort", g_Const.RingTestDialPortIsdn)
fon_nr_config.Table2BoxSend(Table, "telcfg:command/Dial", "**" .. Port)
end
function DectSubcription(OnOff)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@DectSubcription")
if g_CapitermEnabled == "T" then
capiterm.var("DectSubcription: OnOff", OnOff, g_CapitermInfo)
end
if(OnOff=="1") then
g_Box.DectRepeaterCount = 0
local RepeaterTable = fon_nr_config.MultiQuery("dect:settings/Repeater/list(RFPI)", CapitermInfo)
for LfNr, Value in ipairs(RepeaterTable) do
if Value[2] ~= nil and (Value[2] == "err" or Value[2] == "er" or Value[2] == "") then
g_Box.DectRepeaterCount = -1
break
end
if Value[2] ~= nil and Value[2] ~= "" and Value[2] ~= "er" then
g_Box.DectRepeaterCount = g_Box.DectRepeaterCount + 1
end
end
end
fon_nr_config.Table2BoxSend({}, "dect:command/StartSubscription", OnOff)
local subState = fon_nr_config.Query("dect:settings/SubscriptionState", CapitermInfo)
local newULEs = fon_nr_config.Query("dect:settings/NewULEs", CapitermInfo)
if newULEs ~= "0" then
subState = "2"
end
g_Box.DectSubscriptionState = subState
end
function CheckTimeValue(Value, Maximum)
local Number = tonumber(Value)
if (Number == nil) or (Number < 0) or (Number > Maximum) then
if Maximum == 23 then
g_Alert.InvalidHour = g_Txt.InvalidHour
else
g_Alert.InvalidMinute = g_Txt.InvalidMinute
end
g_Alert.Side = "WizardFonKlingelsperreANALOG"
return true
end
return false
end
function TwoChar(Value)
if string.len(Value) == 1 then
return "0" .. Value
end
return Value
end
function HandleSubmitSaveEditKlingelsperre(Table, DestAdr)
local CapitermInfo = assi_control.SetCapitermInfo( g_CapitermEnabled,
box.glob.script .. "@HandleSubmitSaveEditKlingelsperre"
)
if g_Box.NightMode == "Default" then
fon_nr_config.Table2BoxAdd(Table, DestAdr .. "/NoRingWithNightSetting", "1")
local Times = ""
if (g_Box.NightTimeControlEnabled == "1") and (g_Box.NightTimeControlRingBlocked == "1") then
local OffTime = fon_nr_config.Query("box:settings/night_time_control_off_time", CapitermInfo)
local OnTime = fon_nr_config.Query("box:settings/night_time_control_on_time", CapitermInfo)
OffTime = string.gsub(Time, ":", "")
OnTime = string.gsub(Time, ":", "")
Times = OffTime .. OnTime
if string.len(Times) ~= 8 then
Times = ""
end
end
fon_nr_config.Table2BoxAdd(Table, DestAdr .. "/RingAllowed", "1")
fon_nr_config.Table2BoxAdd(Table, DestAdr .. "/NoRingTime", Times)
return
end
fon_nr_config.Table2BoxAdd(Table, DestAdr .. "/NoRingWithNightSetting", "0")
local RingAllowed = "1"
if g_Box.NightRingMode == "Klingeln" then
if g_Box.NightRingException == "MoFr" then
RingAllowed = "5"
elseif g_Box.NightRingException == "SaSo" then
RingAllowed = "4"
end
else
if g_Box.NightRingException == "MoFr" then
RingAllowed = "3"
elseif g_Box.NightRingException == "SaSo" then
RingAllowed = "2"
end
end
fon_nr_config.Table2BoxAdd(Table, DestAdr .. "/RingAllowed", RingAllowed)
local RingTime = TwoChar(g_Box.NightRingTimeStartHour) .. TwoChar(g_Box.NightRingTimeStartMinute)
.. TwoChar(g_Box.NightRingTimeEndHour) .. TwoChar(g_Box.NightRingTimeEndMinute)
if RingTime == "00000000" then
RingTime = ""
end
fon_nr_config.Table2BoxAdd(Table, DestAdr .. "/NoRingTime", RingTime)
end
function HandleSubmitSaveEditMerkmaleDect(Table, TelCfgSettingsFoncontrolUserNPraefix)
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsFoncontrolUserNPraefix .. "/CLIR",
string_op.bool_to_value(g_Box.DectClir == "on", "1", "0")
)
if g_Box.DectManufacturer == "AVM" then
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsFoncontrolUserNPraefix .. "/PBSearchStyle",
string_op.bool_to_value(g_Box.DectVanity == "on", "0", "1")
)
end
local BitMap = 0
if g_Box.DectMonitorTam == "on" then
for BitNr = 0, fon_nr_config.g_NrInfo.TamMaxCount - 1, 1 do
BitMap = bit.set(BitMap, BitNr)
end
end
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/TAMMonitorBitmap", BitMap)
if config.DECT_MONI then
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/LowGain", g_Box.DectEqualizeLow)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/MidGain", g_Box.DectEqualizeMedium)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/HighGain", g_Box.DectEqualizeHigh)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/WidebandEnable", g_Box.DectHdOption)
end
if config.DECT_PICTURED and (g_Box.DectIsMtF == "T") then
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/ImagePath", g_Box.DectImagePath)
end
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsFoncontrolUserNPraefix .. "/CallWaitingProt",
string_op.bool_to_value(g_Box.DectAnklopfen == "on", "0", "1")
)
fon_nr_config.Table2BoxAdd( Table, "telcfg:settings/MSN/Port3/BusyOnBusy",
string_op.bool_to_value(g_Box.DectBusyOnBusy == "on", "1", "0")
)
fon_nr_config.Table2BoxAdd( Table, "telcfg:settings/MSN/Port3/CallWaitingProt",
string_op.bool_to_value(g_Box.DectBusyDelayed == "on", "0", "1")
)
end
function HandleSubmitSaveEditMerkmaleAnalog(Table, TelCfgSettingsMsnPort)
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsMsnPort .. "/CLIR",
string_op.bool_to_value(g_Box.AnalogClir == "on", "1", "0")
)
local ClipMode = "0"
if g_Box.Clip == "on" then
ClipMode = string_op.bool_to_value((g_Box.ClipMode == "Simple") or (g_Const.AbCount < 2), "2", "1")
end
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsMsnPort .. "/CLIP", ClipMode)
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsMsnPort .. "/BusyOnBusy",
string_op.bool_to_value(g_Box.AnalogBusyOnBusy == "on", "1", "0")
)
if fon_nr_config.NrInfo().UsePstn == "1" then
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsMsnPort .. "/COLR",
string_op.bool_to_value(g_Box.Colr == "on", "1", "0")
)
end
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsMsnPort .. "/MWI_Once",
string_op.bool_to_value(g_Box.MwiMode == "Einmal", "1", "0")
)
local MwiVoice = "0"
local MwiFax = "0"
local MwiMail = "0"
if g_Box.Mwi then
MwiVoice = string_op.bool_to_value(g_Box.Mwi == "on", "1", "0")
MwiFax = string_op.bool_to_value(g_Box.MwiFax == "on", "1", "0")
MwiMail = string_op.bool_to_value(g_Box.MwiMail == "on", "1", "0")
end
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsMsnPort .. "/MWI_Voice", MwiVoice)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsMsnPort .. "/MWI_Fax", MwiFax)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsMsnPort .. "/MWI_Mail", MwiMail)
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsMsnPort .. "/CallWaitingProt",
string_op.bool_to_value(g_Box.AnalogAnklopfen == "on", "0", "1")
)
end
function HandleSubmitSave()
if box.post.Submit_Save == nil then
return
end
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@HandleSubmitSave")
if g_CapitermEnabled == "T" then
capiterm.txt_nl("HandleSubmitSave", g_CapitermInfo)
end
local Table = {}
local PortTyp = assi_control.GetPortTyp(g_Box.Port)
local ConnectToAll = string_op.bool_to_value(fon_nr_config.NrInfo().PrevValues.ConnectToAll == "T", "1", "0")
if g_Box.WorkAs ~= "Assi" then
if string_op.in_list(g_Box.CurrSide, g_SideList.HasIncomingNr) then
if fon_nr_config.MessageOnInvalidClicks("NoTamIntern", "ShowMessage", "CheckOutgoingNr", "ConnectAllExist") then
return
end
end
end
if PortTyp == "ANALOG" then
local TelCfgSettingsMsnPort = "telcfg:settings/MSN/Port" .. g_Box.Port
if g_Box.WorkAs == "Assi" then
--assi_control.ResetAnlogPorts(Table)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsMsnPort .. "/CallWaitingProt", "1")
else
HandleSubmitSaveEditKlingelsperre(Table, TelCfgSettingsMsnPort)
HandleSubmitSaveEditMerkmaleAnalog(Table, TelCfgSettingsMsnPort)
end
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsMsnPort .. "/GroupCall", "1")
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsMsnPort .. "/Fax", "0")
fon_nr_config.ValuesToTable(Table, TelCfgSettingsMsnPort .. "/MSN", "", nil, nil, "UseName", "SaveOutgoing")
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsMsnPort .. "/AllIncomingCalls", ConnectToAll)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsMsnPort .. "/Name", g_Box.Notation)
elseif PortTyp == "DECT" then
local TelCfgSettingsFoncontrolUserNPraefix = "telcfg:settings/Foncontrol/" .. g_Box.DectFoncontrolName
if g_Box.WorkAs == "Assi" then
--assi_control.ResetAnlogPorts(Table)
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsFoncontrolUserNPraefix .. "/Phonebook",
--fon_nr_config.Query("telcfg:settings/Phonebook/Id", CapitermInfo)
tostring(fon_book.get_book_id() or "")
)
if fon_nr_config.Query("box:settings/night_time_control_ring_blocked", CapitermInfo) == "1" then
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/NoRingWithNightSetting", "1")
local Time = fon_nr_config.Query("box:settings/night_time_control_off_time", CapitermInfo)
.. fon_nr_config.Query("box:settings/night_time_control_on_time", CapitermInfo)
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsFoncontrolUserNPraefix .. "/NoRingTime",
string.gsub(Time, ":", "")
)
end
else
HandleSubmitSaveEditMerkmaleDect(Table, TelCfgSettingsFoncontrolUserNPraefix)
HandleSubmitSaveEditKlingelsperre(Table, TelCfgSettingsFoncontrolUserNPraefix)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/Phonebook", g_Box.FonbookSelectedLfNr)
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsFoncontrolUserNPraefix .. "/IntRingTone",
g_Box.DectRingToneIntern
)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/VIPRingTone", g_Box.DectRingToneVip)
for Index = 0, g_Const.MaxAlarmRingTone - 1, 1 do
fon_nr_config.Table2BoxAdd( Table, TelCfgSettingsFoncontrolUserNPraefix .. "/AlarmRingTone" .. Index,
g_Box.DectRingToneAlarm
)
end
end
fon_nr_config.ValuesToTable( Table, TelCfgSettingsFoncontrolUserNPraefix .. "/MSN", "/Number", "/RingTone", nil,
"NoUseName", "SaveOutgoing"
)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/Type", "0")
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/RingOnAllMSNs", ConnectToAll)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsFoncontrolUserNPraefix .. "/Name", g_Box.Notation)
elseif PortTyp == "IPPHONE" then
if g_Box.FreeIpPhoneTsvIndex and g_Box.FreeIpPhoneTsvIndex>-1 then
local TelCfgSettingsVoipExtentionPraefix = "telcfg:settings/VoipExtension" .. g_Box.FreeIpPhoneTsvIndex
local VoipextensionSettingsExtensionPraefix = "voipextension:settings/extension" .. g_Box.FreeIpPhoneVseIndex
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsVoipExtentionPraefix .. "/RingOnAllMSNs", ConnectToAll)
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsVoipExtentionPraefix .. "/enabled", "1")
fon_nr_config.Table2BoxAdd(Table, TelCfgSettingsVoipExtentionPraefix .. "/Name", g_Box.Notation)
fon_nr_config.ValuesToTable( Table, TelCfgSettingsVoipExtentionPraefix .. "/Number", "", nil, nil, "NoUseName",
"SaveOutgoing"
)
fon_nr_config.Table2BoxAdd(Table, VoipextensionSettingsExtensionPraefix .. "/enabled", "1")
fon_nr_config.Table2BoxAdd(Table, VoipextensionSettingsExtensionPraefix .. "/username", g_Box.Port)
fon_nr_config.Table2BoxAdd(Table, VoipextensionSettingsExtensionPraefix .. "/passwd", g_Box.IpPassword)
fon_nr_config.Table2BoxAdd(Table, VoipextensionSettingsExtensionPraefix .. "/extension_number", g_Box.Port)
end
else
local OutgoingNr = fon_nr_config.GetRealNumber(fon_nr_config.NrInfo().PrevValues.OutgoingNr, false)
if fon_nr_config.Query("box:settings/night_time_control_ring_blocked", CapitermInfo) == "1" then
local Time = fon_nr_config.Query("box:settings/night_time_control_off_time", CapitermInfo)..fon_nr_config.Query("box:settings/night_time_control_on_time", CapitermInfo)
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port3/RingAllowed", "1")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/Port3/NoRingTime", string.gsub(Time, ":", ""))
end
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/NTHotDialList/Type" .. g_Box.FreeNtHotDialIndex, "Fon")
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/NTHotDialList/Number" .. g_Box.FreeNtHotDialIndex, OutgoingNr)
local CurrentNTDefault = fon_nr_config.Query("telcfg:settings/MSN/NTDefault", CapitermInfo)
if (CurrentNTDefault == nil) or (CurrentNTDefault == "") then
local NTDefaultOutgoingNr = fon_nr_config.GetRealNumber(fon_nr_config.NrInfo().PrevValues.OutgoingNr, true)
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/MSN/NTDefault", NTDefaultOutgoingNr)
end
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/NTHotDialList/Name" .. g_Box.FreeNtHotDialIndex, g_Box.Notation)
end
if g_Box.WorkAs == "Assi" then
assi_control.ResetAnlogPorts(Table)
end
fon_nr_config.Table2BoxShow(Table, "Table2BoxSend")
box.set_config(Table)
local FinishPage = assi_control.GetDefaultFinishPage(g_Box.FinishPage)
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(FinishPage,params))
end
function HandleSubmitBack()
if box.post.Submit_Back ~= nil then
local FonAssiFromPage = assi_control.GetFonAssiFromPage()
if string_op.in_list(g_Box.CurrSide, g_SideList.GoBackToStartPage) then
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_Box.Back2Page or g_Box.StartPage,params))
return true
elseif string_op.in_list(g_Box.CurrSide, g_SideList.GoBackTwoSides) and
(not ("AssiFonOutgoing" == g_Box.CurrSide and string_op.in_list(assi_control.GetPortTyp(g_Box.Port), {"ISDN"})) ) then
AddToSideNr(-2)
return true
elseif g_Box.CurrSide == "AssiFonDectConnect" then
DectSubcription("0")
elseif g_Box.CurrSide == "AssiFonDectConStart" and (FonAssiFromPage == "dect_list" or FonAssiFromPage == "decthandset" or FonAssiFromPage == "dectsettings") then
assi_control.HandleDefaultSubmitAbort(g_Box.StartPage)
elseif g_Box.CurrSide == "AssiFonCheckMsnOnIsdn" then
assi_control.SetAbsPageInfo("AssiFonIsdnIncoming")
return true
end
AddToSideNr(-1)
return true
end
return false
end
function HandleSubmitGoto()
if box.post.Submit_Goto ~= nil or box.get.Submit_Goto ~= nil then
capiterm.var("HandleSubmitGoto",box.post.Submit_Goto)
if g_Box.CurrSide == "AssiFonDectConStart" then
DectSubcription("1")
end
AddToSideNr(1)
return true
end
return false
end
function HandleSubmitNext()
if box.post.Submit_Tab ~= nil then
if string_op.in_list(g_Box.CurrSide, g_SideList.HasIncomingNr) then
if fon_nr_config.MessageOnInvalidClicks("NoTamIntern", "ShowMessage", "CheckOutgoingNr", "ConnectAllExist") then
return true
end
end
assi_control.SetAbsPageInfo(box.post.Submit_Tab)
return true
end
if box.post.Submit_Next ~= nil then
if string_op.in_list(g_Box.CurrSide, g_SideList.GoForwardToRingTest) then
if string_op.in_list(assi_control.GetPortTyp(g_Box.Port), {"ANALOG"}) then
TelefonRingTest(false)
elseif (g_Box.CurrSide == "AssiFonIsdnIncoming") and (string_op.in_list(assi_control.GetPortTyp(g_Box.Port), {"ISDN"})) then
TelefonRingTest(true)
end
elseif g_Box.CurrSide == "AssiFonDectConStart" then
DectSubcription("1")
elseif g_Box.CurrSide == "AssiFonDectConnect" then
DectSubcription("0")
if g_Box.DectSubscriptionState ~= "0" then
AddToSideNr(-1)
return true
end
TelefonRingTestDect({}, g_Box.DectFoncontrolName)
elseif string_op.in_list(g_Box.CurrSide, g_SideList.GoForwardChangeOutgoingNr)
and (fon_nr_config.NrInfo().PrevValues.OutgoingNr ~= "")
then
if g_CapitermEnabled == "T" then
capiterm.var("HandleSubmitNext: SetClickedByNr", fon_nr_config.NrInfo().PrevValues.OutgoingNr, g_CapitermInfo)
end
fon_nr_config.SetClickedByNr(fon_nr_config.NrInfo().PrevValues.OutgoingNr)
elseif string_op.in_list(g_Box.CurrSide, g_SideList.HasIncomingNr) then
if fon_nr_config.MessageOnInvalidClicks("NoTamIntern", "ShowMessage", "CheckOutgoingNr", "ConnectAllExist") then
return true
end
end
AddToSideNr(1)
return true
end
return false
end
function HandleSubmitYes()
if box.post.Submit_Yes ~= nil then
TelefonHangUp({})
AddToSideNr(1)
end
end
function HandleSubmitNo()
if box.post.Submit_No ~= nil then
TelefonHangUp({})
if g_Box.CurrSide == "AssiFonConTest" then
assi_control.SetAbsPageInfo("AssiFonCheckPort")
elseif g_Box.CurrSide == "AssiFonDectTest" then
assi_control.SetAbsPageInfo("AssiFonDectCheckPort")
else
assi_control.SetAbsPageInfo("AssiFonCheckMsnOnIsdn")
end
end
end
function HandleSubmitOtherPort()
if box.post.Submit_OtherPort then
g_Box.FonTestRepeated = "F"
assi_control.SetAbsPageInfo("AssiFonConnecting")
end
end
function HandleSubmitToFonTest()
if box.post.Submit_ToFonTest then
g_Box.FonTestRepeated = "T"
TelefonRingTest(g_Box.CurrSide == "AssiFonCheckMsnOnIsdn")
if g_Box.CurrSide == "AssiFonCheckPort" then
assi_control.SetAbsPageInfo("AssiFonConTest")
else
assi_control.SetAbsPageInfo("AssiFonMsnTest")
end
end
end
function HandleSubmitToDectTest()
if box.post.Submit_ToDectTest then
g_Box.FonTestRepeated = "T"
TelefonRingTestDect({}, g_Box.DectFoncontrolName)
assi_control.SetAbsPageInfo("AssiFonDectTest")
end
end
function HandleSubmitRefresh()
if box.post.Submit_Refresh ~= nil then
g_Box.RefreshPressed = "T"
end
end
function HandleSubmitAbort()
if box.post.cancel ~= nil then
if g_Box.CurrSide == "AssiFonDectConnect" then
DectSubcription("0")
end
assi_control.HandleDefaultSubmitAbort(g_Box.StartPage)
end
end
function SwitchToNextSide()
capiterm.txt_nl("SwitchToNextSide")
if g_CapitermEnabled == "T" then
capiterm.txt_nl("SwitchToNextSide", g_CapitermInfo)
end
HandleSubmitAbort()
g_Alert.Side = ""
CheckSidePortAndNotation()
CheckSideDectNotation()
fon_nr_config.SaveButton("NoFaxWeiche", "NoRemoveOutEqIn", "AddFestnetz")
CheckSideEinstellungIpPhone()
CheckSideOutgoing()
CheckSideKlingelsperre()
if (g_Box.CurrSide == "AssiFonConnecting") and (g_Box.Port ~= "42") then
g_Box["Option" .. g_Box.Port .. "Notation"] = g_Box.Notation
end
if HandleSubmitBack() then
return
end
if g_Alert.Side ~= "" then
assi_control.SetAbsPageInfo(g_Alert.Side)
return
end
if HandleSubmitGoto() then
return
end
if HandleSubmitNext() then
return
end
HandleSubmitRefresh()
HandleSubmitYes()
HandleSubmitNo()
HandleSubmitOtherPort()
HandleSubmitToFonTest()
HandleSubmitToDectTest()
HandleSubmitSave()
end
function RefreshDectFromBox()
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@RefreshDectFromBox")
if g_Box.CurrSide == "AssiFonDectConnect" then
g_Box.DectSubscriptionState = fon_nr_config.Query("dect:settings/SubscriptionState", CapitermInfo)
local newULEs = fon_nr_config.Query("dect:settings/NewULEs", CapitermInfo)
if newULEs ~= "0" then
g_Box.DectSubscriptionState = "2"
end
if g_Box.DectSubscriptionState ~= "0" then
return
end
local NewDectListe = fon_nr_config.Query("dect:settings/NewHandsets", CapitermInfo)
NewDectListe = bit.issetlist(tonumber(NewDectListe))
if not NewDectListe or not NewDectListe[1] then
NewDectListe[1] = 0
end
g_Box.DectHandsetToken = "Handset" .. NewDectListe[1]
local UserInFonControl = fon_nr_config.Query("dect:settings/" .. g_Box.DectHandsetToken .."/User", CapitermInfo)
local RefreshFirst = fon_nr_config.Query("telcfg:settings/Foncontrol", CapitermInfo)
Table = fon_nr_config.MultiQuery("telcfg:settings/Foncontrol/User/list(Id)", CapitermInfo)
g_Box.DectFoncontrolName = ""
for LfNr, Value in ipairs(Table) do
if Value[2] == UserInFonControl then
g_Box.DectFoncontrolName = Value[1]
return
end
end
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_Box.Back2Page or g_Box.StartPage,params))
elseif g_Box.CurrSide == "AssiFonDectName" then
fon_nr_config.Table2BoxSend( {}, "telcfg:settings/Foncontrol/" .. g_Box.DectFoncontrolName .. "/Name",
g_Box.Notation
)
end
end
function Reloaded()
capiterm.txt_nl("Reloaded");
capiterm.var("g_Box",g_Box);
RefreshDectFromBox()
g_OptionTable = assi_control.PrepareOptionList(true, "Fon", g_Txt.Telefon, g_Txt.FonS0IsdnTelefon)
fon_nr_config.SetTyp(g_Box.DeviceTyp, assi_control.GetPortTyp(g_Box.Port))
fon_nr_config.HiddenValuesFromBox(string_op.in_list(g_Box.CurrSide, g_SideList.HasIncomingNr))
if (g_Box.WorkAs ~= "Assi") and (g_Box.TechTyp == "DECT") then
for Index = 1, #fon_nr_config.g_NrInfo.All, 1 do
fon_nr_config.SetRingtone(Index, g_Box["RingToneIncoming" .. Index])
end
end
SwitchToNextSide()
end
function SetRingTime(StartHour, StartMinute, EndHour, EndMinute)
g_Box.NightRingTimeStartHour = StartHour
g_Box.NightRingTimeStartMinute = StartMinute
g_Box.NightRingTimeEndHour = EndHour
g_Box.NightRingTimeEndMinute = EndMinute
end
function LadeKlingesperreDect(TelCfgSettingsFoncontrolUserNPraefix)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@LadeKlingesperreDect")
g_Box.DectRingToneIntern = fon_nr_config.Query(TelCfgSettingsFoncontrolUserNPraefix .. "/IntRingTone", CapitermInfo)
g_Box.DectRingToneVip = fon_nr_config.Query(TelCfgSettingsFoncontrolUserNPraefix .. "/VIPRingTone", CapitermInfo)
g_Box.DectRingToneAlarm = fon_nr_config.Query(TelCfgSettingsFoncontrolUserNPraefix .. "/AlarmRingTone0", CapitermInfo)
end
function LadeKlingesperre(SourceAdr)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@LadeKlingesperre")
g_Box.NightMode = fon_nr_config.Query(SourceAdr .. "/NoRingWithNightSetting", CapitermInfo)
g_Box.NightMode = string_op.bool_to_value(g_Box.NightMode == "1", "Default", "UserDef")
g_Box.NightTimeControlEnabled = fon_nr_config.Query("box:settings/night_time_control_enabled", CapitermInfo)
g_Box.NightTimeControlRingBlocked = fon_nr_config.Query( "box:settings/night_time_control_ring_blocked",
CapitermInfo
)
local RingTime = fon_nr_config.Query(SourceAdr .. "/NoRingTime", CapitermInfo)
local RingAllowed = fon_nr_config.Query(SourceAdr .. "/RingAllowed", CapitermInfo)
if string.len(RingTime) == 8 then
SetRingTime( string.sub(RingTime, 1, 2), string.sub(RingTime, 3, 4), string.sub(RingTime, 5, 6),
string.sub(RingTime, 7, 8)
)
else
SetRingTime("00", "00", "00", "00")
end
if RingAllowed == "0" then
SetRingTime("00", "00", "23", "59")
end
if g_Box.ExpertMode == "0" then
if string_op.in_list(RingAllowed, {"2", "3"}) then
SetRingTime("00", "00", "00", "00")
end
g_Box.NightRingMode = "Klingeln"
g_Box.NightRingException = string_op.bool_to_value( RingAllowed == "4", "SaSo",
RingAllowed == "5", "MoFr", "7Day"
)
else
if string_op.in_list(RingAllowed, {"2", "3"}) then
SetRingTime( g_Box.NightRingTimeEndHour, g_Box.NightRingTimeEndMinute, g_Box.NightRingTimeStartHour,
g_Box.NightRingTimeStartMinute
)
end
g_Box.NightRingMode = string_op.bool_to_value(string_op.in_list(RingAllowed, {"2", "3"}), "Gesperrt", "Klingeln")
g_Box.NightRingException = string_op.bool_to_value( string_op.in_list(RingAllowed, {"0", "1"}), "7Day",
string_op.bool_to_value( string_op.in_list( RingAllowed,
{"2", "4"}
), "SaSo", "MoFr"
)
)
end
end
function LadeMerkmaleDect(TelCfgSettingsFoncontrolUserNPraefix)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@LadeMerkmaleDect")
g_Box.DectClir = string_op.bool_to_value( fon_nr_config.Query( TelCfgSettingsFoncontrolUserNPraefix .. "/CLIR",
CapitermInfo
) == "0", "off", "on"
)
if g_Box.DectManufacturer == "AVM" then
g_Box.DectVanity = string_op.bool_to_value( fon_nr_config.Query( TelCfgSettingsFoncontrolUserNPraefix
.. "/PBSearchStyle" , CapitermInfo
) == "0", "on", "off"
)
end
g_Box.DectTamMonitorBitmap = fon_nr_config.Query( TelCfgSettingsFoncontrolUserNPraefix .. "/TAMMonitorBitmap",
CapitermInfo
)
g_Box.DectMonitorTam = string_op.bool_to_value(g_Box.DectTamMonitorBitmap ~= "0", "on", "off")
g_Box.CountTamActivated = 0
for Index = 0, fon_nr_config.g_NrInfo.TamMaxCount - 1, 1 do
if fon_nr_config.Query("tam:settings/TAM" .. Index .. "/Display", CapitermInfo) ~= "1" then
g_Box.CountTamActivated = g_Box.CountTamActivated + 1
end
end
if config.DECT_MONI then
g_Box.DectEqualizeLow = fon_nr_config.Query(TelCfgSettingsFoncontrolUserNPraefix .. "/LowGain", CapitermInfo)
g_Box.DectEqualizeMedium = fon_nr_config.Query(TelCfgSettingsFoncontrolUserNPraefix .. "/MidGain", CapitermInfo)
g_Box.DectEqualizeHigh = fon_nr_config.Query(TelCfgSettingsFoncontrolUserNPraefix .. "/HighGain", CapitermInfo)
g_Box.DectHdOption = fon_nr_config.Query(TelCfgSettingsFoncontrolUserNPraefix .. "/WidebandEnable", CapitermInfo)
end
g_Box.DectAnklopfen = string_op.bool_to_value( fon_nr_config.Query( TelCfgSettingsFoncontrolUserNPraefix
.. "/CallWaitingProt", CapitermInfo
) == "0", "on", "off"
)
g_Box.DectBusyOnBusy = string_op.bool_to_value( fon_nr_config.Query( "telcfg:settings/MSN/Port3/BusyOnBusy",
CapitermInfo
) == "1", "on", "off"
)
g_Box.DectBusyDelayed = string_op.bool_to_value( fon_nr_config.Query( "telcfg:settings/MSN/Port3/CallWaitingProt",
CapitermInfo
) == "0",
"on", "off"
)
end
function LadeMerkmaleAnalog(TelCfgSettingsMsnPort)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@LadeMerkmaleAnalog")
g_Box.AnalogClir = string_op.bool_to_value( fon_nr_config.Query(TelCfgSettingsMsnPort .. "/CLIR", CapitermInfo)
== "0", "off", "on"
)
g_Box.Clip = fon_nr_config.Query(TelCfgSettingsMsnPort .. "/CLIP", CapitermInfo)
g_Box.ClipMode = string_op.bool_to_value(g_Box.Clip == "2", "Simple", "Advanced")
g_Box.Clip = string_op.bool_to_value(string_op.in_list(g_Box.Clip, {"1", "2"}), "on", "off")
g_Box.AnalogAnklopfen = string_op.bool_to_value( fon_nr_config.Query( TelCfgSettingsMsnPort .. "/CallWaitingProt",
CapitermInfo
) == "0", "on", "off"
)
if g_Const.AbCount > 1 then
if fon_nr_config.Query(TelCfgSettingsMsnPort .. "/Fax", CapitermInfo) == "1" then
g_Box.AnklopfenTyp = "Fax"
g_Box.AnalogAnklopfen = "off"
else
if fon_nr_config.Query(TelCfgSettingsMsnPort .. "/GroupCall", CapitermInfo) == "0" then
g_Box.AnklopfenTyp = "Tam"
g_Box.AnalogAnklopfen = "on"
end
end
end
g_Box.AnalogBusyOnBusy = string_op.bool_to_value( fon_nr_config.Query( TelCfgSettingsMsnPort .. "/BusyOnBusy",
CapitermInfo
) == "1", "on", "off"
)
if fon_nr_config.NrInfo().UsePstn == "1" then
g_Box.Colr = string_op.bool_to_value( fon_nr_config.Query(TelCfgSettingsMsnPort .. "/COLR", CapitermInfo) == "0",
"off", "on"
)
end
g_Box.MwiMode = string_op.bool_to_value( fon_nr_config.Query(TelCfgSettingsMsnPort .. "/MWI_Once", CapitermInfo)
== "1", "Einmal", "Immer"
)
g_Box.MwiVoice = string_op.bool_to_value( fon_nr_config.Query(TelCfgSettingsMsnPort .. "/MWI_Voice", CapitermInfo)
== "0", "off", "on"
)
g_Box.MwiFax = string_op.bool_to_value( fon_nr_config.Query(TelCfgSettingsMsnPort .. "/MWI_Fax", CapitermInfo)
== "0", "off", "on"
)
g_Box.MwiMail = string_op.bool_to_value( fon_nr_config.Query(TelCfgSettingsMsnPort .. "/MWI_Mail", CapitermInfo)
== "0", "off", "on"
)
g_Box.Mwi = string_op.bool_to_value( (g_Box.MwiMail == "on") or (g_Box.MwiFax == "on") or (g_Box.MwiVoice == "on"),
"on", "off"
)
end
function FirstLoadEdit()
if (g_Box.WorkAs == "Assi") or (box.get.dev_no == nil) then
return
end
if g_CapitermEnabled == "T" then
capiterm.txt_nl("FirstLoadEdit", g_CapitermInfo)
end
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@FirstLoadEdit")
if g_Box.TechTyp == "DECT" then
g_Box.Port = 20
g_Box.DectFoncontrolName = g_Box.EditDeviceNo
local RefreshFirst = fon_nr_config.Query("telcfg:settings/Foncontrol", CapitermInfo)
RefreshFirst = fon_nr_config.Query("telcfg:settings/Phonebook/Books/Refresh", CapitermInfo)
g_Box.FonbookCount = fon_nr_config.Query("telcfg:settings/Phonebook/Books/Id/count", CapitermInfo)
g_Box.FonbookCountStoredInfos = 0
g_Box.FonbookSelectedLfNr = ""
local TelCfgSettingsFoncontrolUserNPraefix = "telcfg:settings/Foncontrol/" .. g_Box.DectFoncontrolName
local FonbookId = fon_nr_config.Query(TelCfgSettingsFoncontrolUserNPraefix .. "/Phonebook", CapitermInfo)
for LfNr, Value in ipairs(fon_nr_config.MultiQuery( "telcfg:settings/Phonebook/Books/Id/list", CapitermInfo))
do
g_Box.FonbookCountStoredInfos = g_Box.FonbookCountStoredInfos + 1
if FonbookId == Value[2] then
g_Box.FonbookSelectedLfNr = LfNr
end
g_Box["FonbookNameLfNr" .. LfNr] = LfNr
g_Box["FonbookNameValue" .. LfNr] = fon_nr_config.Query("telcfg:settings/Phonebook/Books/Name" .. Value[2], CapitermInfo)
end
g_Box.InternalMemEnabled = fon_nr_config.Query("ctlusb:settings/internalflash_enabled", CapitermInfo)
g_Box.Notation = fon_nr_config.Query(TelCfgSettingsFoncontrolUserNPraefix .. "/Name", CapitermInfo)
LadeKlingesperre(TelCfgSettingsFoncontrolUserNPraefix)
LadeKlingesperreDect(TelCfgSettingsFoncontrolUserNPraefix)
LadeMerkmaleDect(TelCfgSettingsFoncontrolUserNPraefix)
fon_nr_config.SetSelectedNumbers( "SaveOutgoing", TelCfgSettingsFoncontrolUserNPraefix .. "/MSN", "/Number",
"/RingTone", TelCfgSettingsFoncontrolUserNPraefix .. "/RingOnAllMSNs", "IsNumber"
)
g_Box.DectHandsetToken = ""
local UserIdInFonControl = fon_nr_config.Query(TelCfgSettingsFoncontrolUserNPraefix .. "/Id", CapitermInfo)
local Table = fon_nr_config.MultiQuery("dect:settings/Handset/list(User,Manufacturer,Model,Codecs)", CapitermInfo)
for LfNr, Value in ipairs(Table) do
if Value[2] == UserIdInFonControl then
g_Box.DectHandsetToken = Value[1]
g_Box.DectManufacturer = Value[3]
g_Box.DectHandsetCodecs = Value[5]
if (g_Box.DectManufacturer == "AVM") and (Value[4] == "0x03") then
g_Box.DectIsMtF = "T"
if config.DECT_PICTURED then
g_Box.DectImagePath = fon_nr_config.Query( TelCfgSettingsFoncontrolUserNPraefix .. "/ImagePath",
CapitermInfo
)
end
end
return
end
end
if g_CapitermEnabled == "T" then
capiterm.var("FirstLoadEdit: Unbekanntes Dect-Fon", g_Box.EditDeviceNo, g_CapitermInfo)
end
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_Box.Back2Page or g_Box.StartPage,params))
return
end
if g_Box.TechTyp == "ANALOG" then
if (g_Box.EditDeviceNo ~= nil) and (g_Box.EditDeviceNo ~= "") then
g_Box.Port = g_Box.EditDeviceNo
end
local TelCfgSettingsMsnPort = "telcfg:settings/MSN/Port" .. g_Box.Port
g_Box.Notation = fon_nr_config.Query(TelCfgSettingsMsnPort .. "/Name", CapitermInfo)
LadeKlingesperre(TelCfgSettingsMsnPort)
LadeMerkmaleAnalog(TelCfgSettingsMsnPort)
fon_nr_config.SetSelectedNumbers( "SaveOutgoing", TelCfgSettingsMsnPort .. "/MSN", "", nil,
TelCfgSettingsMsnPort .. "/AllIncomingCalls", "IsName"
)
end
end
function LoadEditTitle()
g_Box.PageTitleParam = g_Box.Notation
end
assi_control.Main("C2A=T", g_SideList.AssiFonAnalog[1], false)
FirstLoadEdit()
LoadEditTitle()
assi_control.DebugAll()
function Htm2Box(Text)
html_check.tobox(Text)
end
function HtmlRingToneLine(IdName, Current, Number)
local Toene = { {Id = "0", Name = [[{?9108:697?}]]},
{Id = "1", Name = [[{?9108:761?}]]},
{Id = "2", Name = [[{?9108:17?}]]},
{Id = "3", Name = g_Txt.Klingelton .. " 3"},
{Id = "4", Name = g_Txt.Klingelton .. " 4"},
{Id = "5", Name = g_Txt.Klingelton .. " 5"},
{Id = "6", Name = g_Txt.Klingelton .. " 6"},
{Id = "7", Name = g_Txt.Klingelton .. " 7"},
{Id = "8", Name = g_Txt.Klingelton .. " 8"},
{Id = "16", Name = [[{?9108:768?}]]}
}
IdName = "RingTone" .. IdName
Htm2Box("<tr>")
Htm2Box("<td class='ClassEditKlingeltoeneLeft'>")
if Number == nil then
Htm2Box( general.sprintf( "<input type='button' value='"
.. [[{?9108:263?}]]
.. "' onclick='Cb_Testen()'>"
)
)
else
Htm2Box(Number)
end
Htm2Box("</td>")
Htm2Box("<td class='ClassEditKlingeltoeneRight'>")
Htm2Box( "<select name='New_" .. IdName .. "' id='Id_" .. IdName .. "'>")
for Tone = 1, #Toene, 1 do
Htm2Box( "<option value='" .. Toene[Tone].Id .. "'"
.. string_op.txt_selected(Toene[Tone].Id == Current) ..">"
)
Htm2Box( Toene[Tone].Name)
Htm2Box( "</option>")
end
Htm2Box( "</select>")
Htm2Box("</td>")
Htm2Box("</tr>")
end
function HtmlAjaxRingTest(OnOff, JsFunction, Tone)
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@HtmlAjaxRingTest")
box.out( "ajaxGet('" .. box.tojs(box.glob.script) .. "?ajaxring=" .. OnOff .. "&sid=" .. box.tojs(box.glob.sid) .. "&dect="
.. box.tojs(g_Box.DectFoncontrolName) .. "&tone=' + " .. Tone .. " + '&dialnr="
.. fon_nr_config.Query("telcfg:settings/Foncontrol/" .. g_Box.DectFoncontrolName .. "/Intern", CapitermInfo)
.. "', " .. JsFunction .. ");\n"
)
end
function get_namelist()
require("fon_devices")
all_devices = fon_devices.get_all_fon_devices()
local namelist = {}
for i,elem in ipairs(all_devices) do
table.insert(namelist,elem.name)
end
return namelist
end
function HtmlJavaScriptForEditOrWork()
if g_Box.WorkAs == "Assi" then
return
end
Htm2Box("<script type='text/javascript'>")
box.out( "function Cb_Ok()\n")
box.out( "{\n")
if string_op.in_list(g_Box.CurrSide, g_SideList.EditGenerateJsHideDataArea) then
if string_op.in_list(g_Box.CurrSide, g_SideList.EditHasNotation) then
box.out("var Notation = jxl.getValue('Id_Notation');\n")
fon_nr_config.BoxAlert("Notation == ''", g_Txt.NoNotation)
box.out("var Namelist ="..js.table(get_namelist())..";\n")
fon_nr_config.BoxAlert("assi_telefon.find_Double_Notation(Notation, Namelist)", g_Txt.DoubleNotation)
fon_nr_config.BoxAlert( "Notation.length > " .. g_Const.MaxNotationLen,
general.sprintf(g_Txt.NotationMaxXChar, g_Const.MaxNotationLen)
)
fon_nr_config.BoxAlert("Notation == '" .. g_Txt.TkAnlage .. "'", g_Txt.TkAnlageForbidden)
end
if string_op.in_list(g_Box.CurrSide, g_SideList.EditHasConnectToAll) then
box.out("if (jxl.getChecked('Id_" .. fon_nr_config.g_Id_ToogleBoxIsConnectToAll .. "'))\n")
end
if g_Box.CurrSide == "WizardFonKlingelsperreANALOG" then
box.out("if (jxl.getChecked('Id_NightModeDefault'))\n")
end
if g_Box.CurrSide == "WizardFonMerkmaleANALOG" then
box.out("if ((! jxl.getChecked('Id_Mwi')) || (! jxl.getChecked('Id_Clip')))\n")
end
if g_Box.CurrSide == "WizardFonMerkmaleDECT" then
box.out("if (! jxl.getChecked('Id_DectBusyOnBusy'))\n")
end
box.out( "{\n")
box.out( "jxl.hide('Id_DataArea');\n")
box.out( "jxl.hide('Id_BtnBack');\n")
box.out( "jxl.hide('Id_BtnNext');\n")
box.out( "jxl.hide('Id_BtnSave');\n")
box.out( "jxl.hide('Id_BtnAbort');\n")
box.out( "jxl.hide('Id_BtnHelp');\n")
box.out( "jxl.show('Id_Waiting');\n")
if string_op.in_list(g_Box.CurrSide, g_SideList.EditHasConnectToAll) then
box.out("fon_nr_config_EnableAllIncomingNr();\n")
end
if g_Box.CurrSide == "WizardFonKlingelsperreANALOG" then
box.out("Cb_NightMode('UserDef');\n")
end
if g_Box.CurrSide == "WizardFonMerkmaleDECT" then
box.out("Cb_DisableDectBusyDelayed(false);\n")
end
box.out( "}\n")
end
box.out( "return true;\n")
box.out( "}\n")
box.out( "function Cb_Submit(Index)\n")
box.out( "{\n")
box.out( "var Name = [ \n")
if g_Box.TechTyp == "ANALOG" then
box.out("'WizardFonStartANALOG', 'WizardFonKlingelsperreANALOG', 'WizardFonMerkmaleANALOG'\n")
elseif g_Box.TechTyp == "DECT" then
box.out("'WizardFonStartDECT', 'WizardFonKlingeltoeneDECT', 'WizardFonKlingelsperreDECT', 'WizardFonMerkmaleDECT'")
elseif g_Box.TechTyp == "ISDN" then
box.out("'WizardFonStartISDN', 'WizardFonS0ISDN', 'WizardFonKlingelspeereISDN'")
else
box.out("'WizardFonStartIPPHONE', 'WizardFonAnmeldedatenIPPHONE'")
end
box.out( "];\n")
box.out( "if (! Cb_Ok())\n")
box.out( "{\n")
box.out( "return false;\n")
box.out( "}\n")
box.out( "jxl.setValue('Id_Submit_Tab', Name[Index]);\n")
box.out( "jxl.enable('Id_Submit_Tab');\n")
box.out( "jxl.submitForm('New_Form');\n")
box.out( "return false;\n")
box.out( "}\n")
Htm2Box("</script>")
end
function HtmlTabulatorForEditOrWork()
if g_Box.WorkAs == "Assi" then
return
end
if g_Box.TechTyp == "ANALOG" then
assi_control.CreateTab( g_Box.CurrSide == "WizardFonStartANALOG", g_Txt.Telefon,
" onclick='return Cb_Submit(0);'", "S"
)
assi_control.CreateTab( g_Box.CurrSide == "WizardFonKlingelsperreANALOG", g_Txt.Klingelsperre,
" onclick='return Cb_Submit(1);'", ""
)
assi_control.CreateTab( g_Box.CurrSide == "WizardFonMerkmaleANALOG", g_Txt.MerkmaleTeleGeraet,
" onclick='return Cb_Submit(2);'", "E"
)
return
end
if g_Box.TechTyp == "DECT" then
assi_control.CreateTab( g_Box.CurrSide == "WizardFonStartDECT", g_Txt.DectSchnurlosTele,
" onclick='return Cb_Submit(0);'", "S"
)
assi_control.CreateTab( g_Box.CurrSide == "WizardFonKlingeltoeneDECT", g_Txt.Klingeltoene,
" onclick='return Cb_Submit(1);'", ""
)
assi_control.CreateTab( g_Box.CurrSide == "WizardFonKlingelsperreDECT", g_Txt.Klingelsperre,
" onclick='return Cb_Submit(2);'", ""
)
assi_control.CreateTab( g_Box.CurrSide == "WizardFonMerkmaleDECT", g_Txt.MerkmaleTeleGeraet,
" onclick='return Cb_Submit(3);'", "E"
)
return
end
if g_Box.TechTyp == "ISDN" then
assi_control.CreateTab( g_Box.CurrSide == "WizardFonStartISDN", g_Txt.RufnummerEndgeraet,
" onclick='return Cb_Submit(0);'", "S"
)
assi_control.CreateTab(g_Box.CurrSide == "WizardFonS0ISDN", g_Txt.FonS0, " onclick='return Cb_Submit(1);'", "")
assi_control.CreateTab( g_Box.CurrSide == "WizardFonKlingelspeereISDN", g_Txt.KingelspeereFonS0,
" onclick='return Cb_Submit(2);'", "E"
)
return
end
assi_control.CreateTab( g_Box.CurrSide == "WizardFonStartIPPHONE", g_Txt.IPPhone,
" onclick='return Cb_Submit(0);'", "S"
)
assi_control.CreateTab( g_Box.CurrSide == "WizardFonAnmeldedatenIPPHONE", g_Txt.Anmeldedaten,
" onclick='return Cb_Submit(1);'", "E"
)
end
function Multiside_AssiFonConnecting()
Htm2Box("<script type='text/javascript'>")
box.out( "var gPort = " .. g_Box.Port .. ";\n")
box.out( "function Cb_Start()\n")
box.out( "{\n")
box.out( "jxl.display('Id_NotationArea', !jxl.getChecked('Id_Port20'));\n")
box.out( "}\n")
box.out( "function Cb_ChangePort(NewPort)\n")
box.out( "{\n")
box.out( "jxl.display('Id_NoMoreIsdn', false);\n")
box.out( "jxl.display('Id_AlertNoPort', NewPort == '42');\n")
box.out( "jxl.setValue('Id_Old_Option' + gPort + 'Notation', jxl.getValue('Id_Notation'));\n")
box.out( "gPort = NewPort;\n")
box.out( "jxl.setValue('Id_Notation', jxl.getValue('Id_Old_Option' + gPort + 'Notation'));\n")
box.out( "Cb_Start();\n")
box.out( "Cb_Notation(jxl.getValue('Id_Notation'));\n")
box.out( "}\n")
box.out( "function Cb_Submit()\n")
box.out( "{\n")
box.out( "var NoPort = jxl.getChecked('Id_Port42');\n")
box.out( "var Notation = jxl.getValue('Id_Notation');\n")
fon_nr_config.BoxAlert("NoPort", g_Txt.NoPort)
fon_nr_config.BoxAlert("Notation == ''", g_Txt.NoNotation)
box.out("var Namelist ="..js.table(get_namelist())..";\n")
fon_nr_config.BoxAlert("assi_telefon.find_Double_Notation(Notation, Namelist)", g_Txt.DoubleNotation)
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
box.out( "ready.onReady(Cb_Start);\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<ol>")
Htm2Box( "<li>")
if config.DECT and config.FON_IPPHONE then
Htm2Box( [[{?9108:367?}]])
elseif config.DECT then
Htm2Box( [[{?9108:497?}]])
else
Htm2Box( [[{?9108:173?}]])
end
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:836?}]])
Htm2Box( "</li>")
local Notation = g_Box.Notation
Htm2Box( "<div>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNoPort", g_Alert.NoPort)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_NoMoreIsdn", g_Alert.NoMoreIsdn)
local defaultcheck = 0
for _, Curr in pairs(g_OptionTable) do
if Curr.IsFree and (g_Box.Port == Curr.Port) then
defaultcheck = 1
end
end
local firstCheck = 1
for LfNr, Curr in pairs(g_OptionTable) do
if config.CAPI_NT or (not(config.CAPI_NT) and tostring(Curr.Port)~="50") then
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
end
Htm2Box( "</div>")
Htm2Box( "<br>")
Htm2Box( "<li id='Id_NotationArea'>")
Htm2Box( g_Txt.AufforderungEingabeNotation)
Htm2Box( "<div>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNoNotation", g_Alert.NoNotation)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNotationLen", g_Alert.NotationLen)
fon_nr_config.BoxOutErrorLine( "ClassAlert", "Id_AlertReservedNotation",
g_Alert.ReservedNotation
)
assi_control.InputField( "Input", "text", "Notation", nil, g_Txt.BezeichnungDP,
g_Const.MaxNotationLen + 2, g_Const.MaxNotationLen, Notation,
"", "Cb_Notation(value)", ""
)
Htm2Box( "</div>")
Htm2Box( "</li>")
Htm2Box( "</ol>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, " onclick='return Cb_Submit();'", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiFonConTest()
Htm2Box("<script type='text/javascript'>")
box.out( "function DoRing()\n")
box.out( "{\n")
box.out( "jxl.display('Id_CheckRunning', false);\n")
box.out( "jxl.display('Id_CheckRunningFinish', true);\n")
box.out( "jxl.display('Id_BtnYes', true);\n")
box.out( "jxl.display('Id_BtnNo', true);\n")
box.out( "}\n")
box.out( "function Cb_Start()\n")
box.out( "{\n")
box.out( "jxl.display('Id_BtnRefresh', false);\n")
box.out( "window.setTimeout('DoRing()', 4000);\n")
box.out( "}\n")
box.out( "ready.onReady(Cb_Start);\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<div Id='Id_CheckRunning'" .. string_op.txt_style_display_none(g_Box.RefreshPressed == "T") .. ">")
Htm2Box( "<p>")
if g_Box.CurrSide == "AssiFonConTest" then
Htm2Box([[{?9108:4?}]])
else
Htm2Box([[{?9108:1078?}]])
end
Htm2Box( "</p>")
Htm2Box( "<p class='ClassHintsCentered'>")
Htm2Box( [[{?9108:238?}]])
Htm2Box( "</p>")
Htm2Box( "</div>")
Htm2Box( "<div Id='Id_CheckRunningFinish'" .. string_op.txt_style_display_none(g_Box.RefreshPressed == "F") .. ">")
Htm2Box( "<p>")
if g_Box.CurrSide == "AssiFonConTest" then
Htm2Box([[{?9108:486?}]])
else
Htm2Box([[{?9108:827?}]])
end
Htm2Box( "</p>")
Htm2Box( "<p class='ClassHintsCentered'>")
Htm2Box( [[{?9108:347?}]])
Htm2Box( "</p>")
Htm2Box( "</div>")
Htm2Box("</div>")
assi_control.CreateButton( "Refresh", g_Txt.Aktualisieren,
string_op.txt_style_display_none(g_Box.RefreshPressed == "T"), "S"
)
assi_control.CreateButton("@Yes", g_Txt.Ja, string_op.txt_style_display_none(g_Box.RefreshPressed == "F"), "")
assi_control.CreateButton("No", g_Txt.Nein, string_op.txt_style_display_none(g_Box.RefreshPressed == "F"), "E")
end
function Multiside_AssiFonOutgoing()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:239?}]])
Htm2Box( "</p>")
Htm2Box( "<table class='ClassNumberSelectListTable'>")
local IgnoreListe = {}
if assi_control.GetPortTyp(g_Box.Port) == "ISDN" then
for Index = 0, g_Const.FaxModemCount - 1, 1 do
local Nr = g_Box["FaxModem" .. Index .. "Number"]
if Nr ~= "" then
table.insert(IgnoreListe, Nr)
end
end
end
fon_nr_config.BoxOutHtmlCode_GetOutgoingNrBox( "AssiOut", fon_nr_config.NrInfo().PrevValues.OutgoingNr,
"NoEmptyEntry", "NoWithCallback", "NoPotsToText",
IgnoreListe
)
Htm2Box( "</table>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiFonIncoming()
Htm2Box("<script type='text/javascript'>")
box.out("function Cb_Submit()\n")
box.out("{\n")
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
box.out("}\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<div id='Id_ConnectAllOrUserArea'>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:524?}]])
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
Htm2Box( g_Txt.BitteWarten)
Htm2Box( "</div>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, " onclick='return Cb_Submit();'", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function GetPortTypName(Port)
local Telefongeraet = g_Txt.Telefon
local port = assi_control.GetPortTyp(Port)
if port == "DECT" then
Telefongeraet = g_Txt.DectSchnurlosTele
elseif port == "IPPHONE" then
Telefongeraet = g_Txt.LanWLanIpPhoneName
elseif config.CAPI_NT and port == "ISDN" then
Telefongeraet = g_Txt.FonS0IsdnTelefonName
end
return Telefongeraet
end
function Multiside_AssiFonSummary()
local Telefongeraet = GetPortTypName(g_Box.Port)
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( general.sprintf([[{?9108:33?}]], Telefongeraet))
Htm2Box( "</p>")
Htm2Box( "<table class='ClassSummaryListTable zebra'>")
local nextLineTyp = 0
assi_control.SummaryTableLine((nextLineTyp % 2)+1, g_Txt.Telefoniegeraet, Telefongeraet, "")
nextLineTyp = nextLineTyp + 1
assi_control.SummaryTableLine((nextLineTyp % 2)+1, [[{?9108:941?}]], g_Box.Notation, "")
nextLineTyp = nextLineTyp + 1
if assi_control.GetPortTyp(g_Box.Port) == "IPPHONE" then
assi_control.SummaryTableLine( (nextLineTyp % 2)+1, [[{?9108:327?}]],
assi_control.GetPortName(g_Box.Port), ""
)
nextLineTyp = nextLineTyp + 1
elseif assi_control.GetPortTyp(g_Box.Port) == "DECT" then
assi_control.SummaryTableLine( (nextLineTyp % 2)+1, [[{?9108:929?}]],
assi_control.GetPortName(g_Box.Port), ""
)
nextLineTyp = nextLineTyp + 1
else
assi_control.SummaryTableLine( (nextLineTyp % 2)+1, [[{?9108:42?}]],
assi_control.GetPortName(g_Box.Port), ""
)
nextLineTyp = nextLineTyp + 1
end
assi_control.SummaryTableLine( (nextLineTyp % 2)+1,
[[{?9108:593?}]],
"", "Out"
)
nextLineTyp = nextLineTyp + 1
if (not config.CAPI_NT) or assi_control.GetPortTyp(g_Box.Port) ~= "ISDN" then
assi_control.SummaryTableLine( (nextLineTyp % 2)+1,
[[{?9108:589?}]],
"", "In"
)
nextLineTyp = nextLineTyp + 1
else
assi_control.SummaryTableLine( (nextLineTyp % 2)+1,
[[{?9108:382?}]],
[[{?9108:30?}]], ""
)
nextLineTyp = nextLineTyp + 1
end
Htm2Box( "</table>")
Htm2Box( "<p>")
Htm2Box( [[{?g_txt_ZumSpeichernUebernehmenKlicken?}]])
Htm2Box( "</p>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Save", g_Txt.Uebernehmen, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiFonDectConStart()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:331?}]])
Htm2Box( "</p>")
Htm2Box( "<ol>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:20?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
box.js( [[{?9108:971?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:370?}]])
Htm2Box( "</li>")
Htm2Box( "</ol>")
Htm2Box( "</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiFonDectConnect()
Htm2Box("<script type='text/javascript'>")
box.out( "var Text = [\n")
for Index = 1, #g_DectState, 1 do
box.out( [["]] .. box.tojs(g_DectState[Index].Text) .. [["]]
.. string_op.bool_to_value(Index ~= #g_DectState, ",", "") .. "\n"
)
end
box.out( "];\n")
box.out( "var Gif = [\n")
for Index = 1, #g_DectState, 1 do
box.out( [["/css/default/images/]] .. box.tojs(g_DectState[Index].Gif) .. [["]]
.. string_op.bool_to_value(Index ~= #g_DectState, ",", "") .. "\n"
)
end
box.out( "];\n")
box.out( "var Dect = {State : {query : 'dect:settings/SubscriptionState'}\n")
box.out( ",\n")
box.out( " NewULEs : {query : 'dect:settings/NewULEs'}\n")
box.out( ",\n")
box.out( " RepCount : {query : 'dect:settings/Repeater/count'},\n")
box.out( " HS0Subscribed : {query : 'dect:settings/Handset0/Subscribed'},\n")
box.out( " HS1Subscribed : {query : 'dect:settings/Handset1/Subscribed'},\n")
box.out( " HS2Subscribed : {query : 'dect:settings/Handset2/Subscribed'},\n")
box.out( " HS3Subscribed : {query : 'dect:settings/Handset3/Subscribed'},\n")
box.out( " HS4Subscribed : {query : 'dect:settings/Handset4/Subscribed'},\n")
box.out( " HS5Subscribed : {query : 'dect:settings/Handset5/Subscribed'},\n")
box.out( " Rep0RFPI : {query : 'dect:settings/Repeater0/RFPI'},\n")
box.out( " Rep1RFPI : {query : 'dect:settings/Repeater1/RFPI'},\n")
box.out( " Rep2RFPI : {query : 'dect:settings/Repeater2/RFPI'},\n")
box.out( " Rep3RFPI : {query : 'dect:settings/Repeater3/RFPI'},\n")
box.out( " Rep4RFPI : {query : 'dect:settings/Repeater4/RFPI'},\n")
box.out( " Rep5RFPI : {query : 'dect:settings/Repeater5/RFPI'}\n")
box.out( "};\n")
box.out( "function Cb_ChangeStateSuccess(State)\n")
box.out( "{\n")
box.out( "if (State == 3 && (!(Dect.HS0Subscribed.value == '1' || Dect.HS1Subscribed.value == '1' || Dect.HS2Subscribed.value == '1' || Dect.HS3Subscribed.value == '1' || Dect.HS4Subscribed.value == '1' || Dect.HS5Subscribed.value == '1' )) ){\n")
box.out( "State=2;}\n")
box.out( "jxl.changeImage('Id_StatusPic', Gif[State], Text[State]);\n")
box.out( "jxl.display('Id_DectConOk', State == 0);\n")
box.out( "jxl.display('Id_DectConOkRepeater', State == 3);\n")
box.out( "jxl.hide('Id_DectConRun');\n")
box.out( "jxl.display('Id_DectConFailed', State == 2);\n")
box.out( "jxl.hide('Id_StatusText');\n")
box.out( "jxl.enable('Id_BtnNext');\n")
box.out( "if (State == 0){ jxl.hide('Id_BtnBack');}\n")
box.out( "if (State == 3){ jxl.hide('Id_BtnNext');}\n")
box.out( "jxl.display('Id_BtnAbort',State == 3);\n")
box.out( "}\n")
box.out( "function Cb_Refresh(OnLoad)\n")
box.out( "{\n")
box.out( "if(undefined != Dect.NewULEs.value && Dect.NewULEs.value !='' && Dect.NewULEs.value != '0'){Dect.State.value = '2';}\n")
box.out( "var CurrentRepeaterCount = 0;\n")
box.out( "if(Dect.RepCount.value > 0){\n")
box.out( "if(Dect.Rep0RFPI.value != '' && Dect.Rep0RFPI.value != 'er' && Dect.Rep0RFPI.value != 'err') {CurrentRepeaterCount = CurrentRepeaterCount+1;}\n")
box.out( "if(Dect.Rep1RFPI.value != '' && Dect.Rep1RFPI.value != 'er' && Dect.Rep1RFPI.value != 'err') {CurrentRepeaterCount = CurrentRepeaterCount+1;}\n")
box.out( "if(Dect.Rep2RFPI.value != '' && Dect.Rep2RFPI.value != 'er' && Dect.Rep2RFPI.value != 'err') {CurrentRepeaterCount = CurrentRepeaterCount+1;}\n")
box.out( "if(Dect.Rep3RFPI.value != '' && Dect.Rep3RFPI.value != 'er' && Dect.Rep3RFPI.value != 'err') {CurrentRepeaterCount = CurrentRepeaterCount+1;}\n")
box.out( "if(Dect.Rep4RFPI.value != '' && Dect.Rep4RFPI.value != 'er' && Dect.Rep4RFPI.value != 'err') {CurrentRepeaterCount = CurrentRepeaterCount+1;}\n")
box.out( "if(Dect.Rep5RFPI.value != '' && Dect.Rep5RFPI.value != 'er' && Dect.Rep5RFPI.value != 'err') {CurrentRepeaterCount = CurrentRepeaterCount+1;}\n")
box.out( "}\n")
box.out( "switch (Dect.State.value)\n")
box.out( "{\n")
box.out( "case '0':\n")
box.out( "if (OnLoad)\n")
box.out( "{\n")
box.out( "window.setTimeout('Cb_ChangeStateSuccess(0)', 5000);\n")
box.out( "return true;\n")
box.out( "}\n")
box.out( "Cb_ChangeStateSuccess(0);\n")
box.out( "return true;\n")
box.out( "case '1':\n")
box.out( "jxl.changeImage('Id_StatusPic', Gif[1], Text[1]);\n")
box.out( "jxl.setHtml('Id_StatusText', Text[1]);\n")
-- box.out( "window.setTimeout('Cb_Refresh(false)', 10000);\n")
box.out( "return false;\n")
box.out( "case '2':\n")
box.out( " var StartDectRepeaterCount = parseInt('".. g_Box.DectRepeaterCount .."');\n")
box.out( "if(StartDectRepeaterCount != -1 && (StartDectRepeaterCount < CurrentRepeaterCount)){ \n")
box.out( "Cb_ChangeStateSuccess(3);\n")
box.out( "return true;\n")
box.out( "}else{\n")
box.out( "Cb_ChangeStateSuccess(2);\n")
box.out( "return true;\n")
box.out( "}\n")
box.out( "}\n")
box.out( "}\n")
box.out( "function Cb_Timeout()\n")
box.out( "{\n")
box.out( "return Cb_Refresh(false);\n")
box.out( "}\n")
box.out( "function Cb_Start()\n")
box.out( "{\n")
box.out( "jxl.display('Id_BtnRefresh', false);\n")
box.out( "Cb_Refresh(true);\n")
box.out( "ajaxWait(Dect, '" .. box.tojs(box.glob.sid) .. "', 5000, Cb_Timeout);")
box.out( "}\n")
box.out( "ready.onReady(Cb_Start);\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p id='Id_DectConOk'" .. string_op.txt_style_display_none(g_Box.DectSubscriptionState ~= "0") .. ">")
Htm2Box( g_DectState[1].Text)
Htm2Box( "</p>")
Htm2Box( "<p id='Id_DectConOkRepeater'" .. string_op.txt_style_display_none(true) .. ">")
Htm2Box( g_DectState[4].Text)
Htm2Box( "</p>")
Htm2Box( "<p id='Id_DectConRun'" .. string_op.txt_style_display_none(g_Box.DectSubscriptionState ~= "1") .. ">")
Htm2Box( [[{?9108:544?}]])
Htm2Box( "</p>")
Htm2Box( "<p id='Id_DectConFailed'" .. string_op.txt_style_display_none(g_Box.DectSubscriptionState ~= "2") .. ">")
Htm2Box( [[{?9108:532?}]])
Htm2Box( "</p>")
Htm2Box( "<div class='ClassDectHintsCentered'>")
Htm2Box( "<span id='Id_StatusText'>")
Htm2Box( g_DectState[tonumber(g_Box.DectSubscriptionState) + 1].Text)
Htm2Box( "</span>")
Htm2Box( "</div>")
Htm2Box( "<p class='waitimg'>")
Htm2Box( "<img name='Id_StatusPic' src='/css/default/images/"
.. g_DectState[tonumber(g_Box.DectSubscriptionState) + 1].Gif .. "' id='Id_StateImg' alt='"
.. [[{?9108:421?}]] .. "'>"
)
Htm2Box( "</p>")
Htm2Box("</div>")
assi_control.CreateButton( string_op.bool_to_value(g_Box.DectSubscriptionState == "1", "@", "") .. "Refresh",
g_Txt.Aktualisieren,
string_op.bool_to_value(g_Box.DectSubscriptionState ~= "1", " disabled", ""), "S"
)
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "")
assi_control.CreateButton( "@"..string_op.bool_to_value(g_Box.DectSubscriptionState ~= "1", "@", "") .. "Next",
g_Txt.Weiter,
string_op.bool_to_value(g_Box.DectSubscriptionState == "1", " disabled", ""), ""
)
assi_control.CreateButton("cancel", g_Txt.Weiter, string_op.txt_style_display_none(true), "E")
end
function Multiside_AssiFonDectTest()
Htm2Box("<script type='text/javascript'>")
box.out( "function DoRing()\n")
box.out( "{\n")
box.out( "jxl.display('Id_Wait', false);\n")
box.out( "jxl.display('Id_Ask', true);\n")
box.out( "jxl.display('Id_BtnYes', true);\n")
box.out( "jxl.display('Id_BtnNo', true);\n")
box.out( "}\n")
box.out( "function Cb_Start()\n")
box.out( "{\n")
box.out( "jxl.display('Id_BtnRefresh', false);\n")
box.out( "window.setTimeout('DoRing()', 4000);")
box.out( "}\n")
box.out( "ready.onReady(Cb_Start);\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<div id='Id_Wait'" .. string_op.txt_style_display_none(g_Box.RefreshPressed == "T") .. ">")
Htm2Box( "<p>")
Htm2Box( [[{?9108:888?}]])
Htm2Box( "</p>")
Htm2Box( "<p class='ClassHintsCentered'>")
Htm2Box( [[{?9108:694?}]])
Htm2Box( "</p>")
Htm2Box( "</div>")
Htm2Box( "<div id='Id_Ask'" .. string_op.txt_style_display_none(g_Box.RefreshPressed == "F") .. ">")
Htm2Box( "<p>")
Htm2Box( [[{?9108:273?}]])
Htm2Box( "</p>")
Htm2Box( "<p class='ClassHintsCentered'>")
Htm2Box( [[{?9108:824?}]])
Htm2Box( "</p>")
Htm2Box( "</div>")
Htm2Box("</div>")
assi_control.CreateButton( "@Refresh", g_Txt.Aktualisieren,
string_op.txt_style_display_none(g_Box.RefreshPressed == "T"), "S"
)
assi_control.CreateButton("@Yes", g_Txt.Ja, string_op.txt_style_display_none(g_Box.RefreshPressed == "F"), "")
assi_control.CreateButton("No", g_Txt.Nein, string_op.txt_style_display_none(g_Box.RefreshPressed == "F"), "E")
end
function Multiside_AssiFonDectName()
Htm2Box("<script type='text/javascript'>")
box.out( "function Cb_Notation(Notation)\n")
box.out( "{\n")
box.out( "jxl.display('Id_AlertNoNotation', Notation.length != 0);\n")
box.out( "jxl.display('Id_AlertNotationLen', Notation.length > " .. g_Const.MaxDectNotationLen .. ");\n")
box.out( "}\n")
box.out( "function Cb_Submit()\n")
box.out( "{\n")
box.out( "var Notation = jxl.getValue('Id_Notation');\n")
fon_nr_config.BoxAlert("Notation == ''", g_Txt.LeererDectFonName)
fon_nr_config.BoxAlert( "Notation.length > " .. g_Const.MaxDectNotationLen,
general.sprintf(g_Txt.NotationMaxXChar, g_Const.MaxDectNotationLen)
)
box.out( "return true;\n")
box.out( "}\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( g_Txt.AufforderungEingabeNotation)
Htm2Box( "</p>")
Htm2Box( "<div>")
assi_control.InputField( "Input", "text", "Notation", nil,
[[{?9108:569?}]], g_Const.MaxDectNotationLen + 2,
g_Const.MaxDectNotationLen, g_Box.Notation, "", "Cb_Notation(value)", ""
)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNoNotation", g_Alert.NoNotation)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNotationLen", g_Alert.NotationLen)
Htm2Box( "</div>")
Htm2Box("</div>")
assi_control.CreateButton("@Next", g_Txt.Weiter, " onclick='return Cb_Submit();'", "S")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, string_op.txt_disabled(true), "E")
end
function Multiside_AssiFonIpOption()
Htm2Box("<script type='text/javascript'>")
box.out( "function Cb_IpPassword(Password)\n")
box.out( "{\n")
box.out( "jxl.display('Id_AlertIpPhonePasswordEmpty', Password.length != 0);\n")
box.out( "jxl.display('Id_AlertIpPhonePasswordEmpty', Password != '****');\n")
box.out( "}\n")
box.out( "function Cb_Submit()\n")
box.out( "{\n")
box.out( "var Password = jxl.getValue('Id_IpPassword');\n")
fon_nr_config.BoxAlert("Password == ''", g_Txt.LeeresKennwort)
fon_nr_config.BoxAlert("Password == '****'", g_Txt.KennwortEingeben)
box.out( "return true;\n")
box.out( "}\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<ol>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:610?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:789?}]])
Htm2Box( "<br>")
Htm2Box( "<br>")
Htm2Box( "<div>")
Htm2Box( "<label>")
Htm2Box( [[{?9108:907?}]])
Htm2Box( "</label>")
if g_Box.OpMode == "opmode_eth_ipclient" then
Htm2Box( g_Box.InterfaceIp)
else
Htm2Box( [[{?9108:784?}]])
end
Htm2Box( "</div>")
Htm2Box( "<div>")
Htm2Box( "<label>")
Htm2Box( [[{?9108:222?}]])
Htm2Box( "</label>")
Htm2Box( g_Box.Port)
Htm2Box( "</div>")
Htm2Box( "<div>")
assi_control.InputField( "LabelInput", "text", "IpPassword", nil,
[[{?9108:482?}]], g_Const.MaxPasswordLen,
g_Const.MaxPasswordLen + 2, g_Box.IpPassword, "", "Cb_IpPassword(value)", ""
)
fon_nr_config.BoxOutErrorLine( "ClassAlert", "Id_AlertIpPhonePasswordEmpty",
g_Alert.IpPhonePasswordEmpty
)
fon_nr_config.BoxOutErrorLine( "ClassAlert", "Id_AlertIpPhonePasswordStars",
g_Alert.IpPhonePasswordStars
)
Htm2Box( "</div>")
Htm2Box( "</li>")
Htm2Box( "</ol>")
Htm2Box("</div>")
Htm2Box("<script type='text/javascript'>")
box.out( "function init()\n")
box.out( "{\n")
box.out( "createPasswordChecker('Id_IpPassword');\n")
box.out( "}\n")
box.out( "ready.onReady(init);\n")
Htm2Box("</script>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, " onclick='return Cb_Submit();'", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiFonIsdnIncoming()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:4058?}]])
Htm2Box( "<br>")
Htm2Box( [[{?9108:613?}]])
Htm2Box( "</p>")
Htm2Box( "<ol>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:153?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:574?}]])
Htm2Box( "<b>")
Htm2Box( fon_nr_config.GetRealNumber(fon_nr_config.NrInfo().PrevValues.OutgoingNr), false)
Htm2Box( "</b>")
Htm2Box( [[{?9108:61?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:77?}]])
Htm2Box( "</li>")
Htm2Box( "</ol>")
Htm2Box( "<div>")
Htm2Box( "<table class='ClassNumberListTable zebra'>")
fon_nr_config.BoxOutHtmlCode_HeaderIncomingNr( "DefNrClassIds", g_Txt.Rufnummer,
"ClassSummaryTableColRight1"
)
fon_nr_config.BoxOutHtmlCode_IncomingNr( "AssiIn",
fon_nr_config.NrInfo().PrevValues.OutgoingNr,
"NoCheckBoxen", "CheckClicked", "DefNrClassIds", "Label",
"", 2
)
Htm2Box( "</table>")
Htm2Box( "</div>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiFonCheckPort()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
if assi_control.GetPortTyp(g_Box.Port) == "IPPHONE" then
Htm2Box( "<p>")
Htm2Box( [[{?9108:1?}]])
Htm2Box( "</p>")
Htm2Box( "<ul>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:373?}]])
Htm2Box( "<b>")
Htm2Box( assi_control.GetPortName(g_Box.Port))
Htm2Box( "</b>")
Htm2Box( [[{?9108:120?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:459?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box([[{?9108:501?}]])
Htm2Box( "</li>")
Htm2Box("<br>")
Htm2Box("<li>")
Htm2Box( [[{?9108:835?}]])
Htm2Box("</li>")
else
Htm2Box( "<p>")
Htm2Box( [[{?9108:831?}]])
Htm2Box( "</p>")
Htm2Box( "<ul>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:675?}]])
Htm2Box( "<b>")
Htm2Box( assi_control.GetPortName(g_Box.Port))
Htm2Box( "</b>")
Htm2Box( [[{?9108:582?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:573?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
end
Htm2Box( "</ul>")
Htm2Box("</div>")
assi_control.CreateButton("OtherPort", g_Txt.Zurueck, "", "S")
if g_Box.FonTestRepeated == "F" then
assi_control.CreateButton("ToFonTest", g_Txt.ErneutTesten, "", "E")
else
assi_control.CreateButton("ToFonTest", g_Txt.ErneutTesten, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
end
function Multiside_AssiFonDectCheckPort()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:933?}]])
Htm2Box( "</p>")
Htm2Box( "<ol>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:647?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:217?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:570?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:542?}]])
Htm2Box( "</li>")
Htm2Box( "</ol>")
Htm2Box("</div>")
assi_control.CreateButton("OtherPort", g_Txt.Zurueck, "", "S")
if g_Box.FonTestRepeated == "F" then
assi_control.CreateButton("cancel", g_Txt.AssiErneutStarten, "", "")
assi_control.CreateButton("ToDectTest", g_Txt.ErneutTesten, "", "E")
else
assi_control.CreateButton("ToDectTest", g_Txt.ErneutTesten, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
end
function Multiside_AssiFonCheckMsnOnIsdn()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:226?}]])
Htm2Box( "</p>")
Htm2Box( "<ol>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:260?}]])
Htm2Box( "</li>")
Htm2Box( "<div class='ClassHints'>")
Htm2Box( g_Txt.SeeDokuTelefon)
Htm2Box( "</div>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:247?}]])
Htm2Box( "</li>")
Htm2Box( "<br>")
Htm2Box( "<li>")
Htm2Box( [[{?9108:951?}]])
Htm2Box( "</ol>")
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
if g_Box.FonTestRepeated == "F" then
assi_control.CreateButton("ToFonTest", g_Txt.ErneutTesten, "", "E")
else
assi_control.CreateButton("ToFonTest", g_Txt.ErneutTesten, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
end
function Multiside_WizardFonStartANALOG()
Htm2Box("<script type='text/javascript'>")
box.out( "function Cb_Notation(Value)\n")
box.out( "{\n")
box.out( "jxl.display('Id_AlertNoNotation', Value == '');\n")
box.out( "jxl.display('Id_AlertNotationLen', Value.length > " .. g_Const.MaxNotationLen .. ");\n")
box.out( "jxl.display('Id_AlertReservedNotation', Value == '" .. g_Txt.TkAnlage .. "');\n")
box.out( "}\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
if g_Box.CurrSide == "WizardFonStartANALOG" then
Htm2Box([[{?9108:325?}]])
elseif g_Box.CurrSide == "WizardFonStartDECT" then
Htm2Box([[{?9108:429?}]])
elseif g_Box.CurrSide ~= "WizardFonStartISDN" then
Htm2Box([[{?9108:362?}]])
end
Htm2Box( "</p>")
if g_Box.CurrSide == "WizardFonStartANALOG" then
Htm2Box("<p>")
Htm2Box( "<b>")
Htm2Box( general.sprintf( [[{?9108:488?}]],
"Fon " .. (g_Box.Port + 1)
)
)
Htm2Box( "</b>")
Htm2Box("</p>")
end
Htm2Box( "<div id='Id_DataArea'>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNoNotation", g_Alert.NoNotation)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNotationLen", g_Alert.NotationLen)
fon_nr_config.BoxOutErrorLine( "ClassAlert", "Id_AlertReservedNotation",
g_Alert.ReservedNotation
)
assi_control.InputField( "LabelInput", "text", "Notation", nil, g_Txt.BezeichnungDP,
g_Const.MaxNotationLen + 2, g_Const.MaxNotationLen, g_Box.Notation, "",
"Cb_Notation(value)", ""
)
if (g_Box.CurrSide == "WizardFonStartDECT") and config.FONBOOK2 and (g_Box.FonbookCount ~= 0) then
Htm2Box("<br>")
Htm2Box("<p>")
Htm2Box( "<label for='Id_FonbookSelectedLfNr'>")
Htm2Box( g_Txt.Telefonbuch)
Htm2Box( "</label>")
Htm2Box( "<select class='ClassEditFonbookField' name='New_FonbookSelectedLfNr' id='Id_FonbookSelectedLfNr'>")
for Index = 1, g_Box.FonbookCountStoredInfos, 1 do
local FonbookName = g_Box["FonbookNameValue" .. Index]
if FonbookName ~= "" then
local BookId = g_Box["FonbookNameLfNr" .. Index]
local Selected = string_op.txt_selected(BookId == g_Box.FonbookSelectedLfNr)
Htm2Box("<option value='" .. BookId .. "'" .. Selected ..">")
Htm2Box( string_op.bool_to_value(FonbookName ~= "", FonbookName, g_Txt.Telefonbuch))
Htm2Box("</option>")
end
end
Htm2Box( "</select>")
Htm2Box("</p>")
end
Htm2Box( "<p>")
Htm2Box( "<b>")
Htm2Box( [[{?9108:302?}]])
Htm2Box( "</b>")
Htm2Box( "</p>")
Htm2Box( "<table class='ClassNumberListTable' id='Id_OutgoingNrTable'>")
local IgnoreListe = {}
fon_nr_config.BoxOutHtmlCode_GetOutgoingNrBox( "EditOut",
fon_nr_config.NrInfo().PrevValues.OutgoingNr,
"EmptyEntry", "WithCallback", "NoPotsToText",
IgnoreListe
)
Htm2Box( "</table>")
Htm2Box( "<p>")
Htm2Box( "<b>")
Htm2Box( [[{?9108:6638?}]])
Htm2Box( "</b>")
Htm2Box( "</p>")
Htm2Box( "<div id='Id_ConnectAllOrUserArea'>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:995?}]])
Htm2Box( "</p>")
fon_nr_config.BoxOutHtmlCode_Connect2UserOrAll("ClassRadioButton", "")
fon_nr_config.BoxOutErrorLines("ClassAlert", {})
Htm2Box( "</div>")
Htm2Box( "<table class='ClassNumberListTable' id='Id_IncomingNrTable'>")
fon_nr_config.BoxOutHtmlCode_IncomingNr( "EditIn",
fon_nr_config.NrInfo().PrevValues.OutgoingNr,
"CheckBoxen", "CheckClicked", "DefNrClassIds", "Label",
'fon_nr_config_OnClickNr("", id)', 0
)
Htm2Box( "</table>")
Htm2Box( "</div>")
Htm2Box( "<div id='Id_Waiting' " .. string_op.txt_style_display_none(true) .. ">")
Htm2Box( g_Txt.BitteWarten)
Htm2Box( "</div>")
Htm2Box("</div>")
if g_Box.WorkAs == "Wizard" then
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("@Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "")
else
assi_control.CreateButton("@Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "S")
end
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "")
assi_control.CreateButton("Help", g_Txt.Hilfe, "", "E")
end
function Multiside_WizardFonKlingelsperreANALOG()
Htm2Box("<script type='text/javascript'>")
box.out( "function Cb_NightMode(Mode)\n")
box.out( "{\n")
box.out( "var Disable = Mode == 'Default';\n")
box.out( "jxl.setDisabled('Id_NightRingMode', Disable);\n")
box.out( "jxl.setDisabled('Id_NightRingModeKlingeln', Disable);\n")
box.out( "jxl.setDisabled('Id_NightRingModeGesperrt', Disable);\n")
box.out( "jxl.setDisabled('Id_NightRingException7Day', Disable);\n")
box.out( "jxl.setDisabled('Id_NightRingExceptionSaSo', Disable);\n")
box.out( "jxl.setDisabled('Id_NightRingExceptionMoFr', Disable);\n")
box.out( "jxl.setDisabled('Id_NightRingTimeStartHour', Disable);\n")
box.out( "jxl.setDisabled('Id_NightRingTimeStartMinute', Disable);\n")
box.out( "jxl.setDisabled('Id_NightRingTimeEndHour', Disable);\n")
box.out( "jxl.setDisabled('Id_NightRingTimeEndMinute', Disable);\n")
box.out( "}\n")
box.out( "function Cb_Start()\n")
box.out( "{\n")
box.out( "Cb_NightMode('" .. g_Box.NightMode .. "')\n")
box.out( "}\n")
box.out( "ready.onReady(Cb_Start);\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
box.out( [[{?9108:8407?}]])
Htm2Box( "</p>")
Htm2Box( "<div id='Id_DataArea'>")
assi_control.InputField( "InputLabel", "radio", "NightMode", "++Default",
[[{?9108:822?}]],
nil, nil, "Default", string_op.txt_checked(g_Box.NightMode == "Default"),
"Cb_NightMode(value)", ""
)
Htm2Box( "<br>")
assi_control.InputField( "InputLabel", "radio", "NightMode", "++ModeUserDef",
[[{?9108:762?}]], nil, nil,
"UserDef", string_op.txt_checked(g_Box.NightMode == "UserDef"),
"Cb_NightMode(value)", ""
)
if g_Box.ExpertMode == "1" then
Htm2Box("<div>")
assi_control.InputField( "InputLabel", "radio", "NightRingMode", "++Klingeln",
[[{?9108:841?}]], nil, nil,
"Klingeln",
string_op.txt_checked(g_Box.NightRingMode == "Klingeln"), "", ""
)
Htm2Box( "<br>")
assi_control.InputField( "InputLabel", "radio", "NightRingMode", "++Gesperrt",
[[{?9108:460?}]], nil,
nil, "Gesperrt",
string_op.txt_checked(g_Box.NightRingMode == "Gesperrt"), "", ""
)
Htm2Box( "<div>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:7586?}]])
Htm2Box( "</p>")
assi_control.InputField( "InputLabel", "radio", "NightRingException", "++7Day",
[[{?9108:123?}]], nil, nil, "7Day",
string_op.txt_checked(g_Box.NightRingException == "7Day"), "", ""
)
Htm2Box( "<br>")
assi_control.InputField( "InputLabel", "radio", "NightRingException", "++SaSo",
[[{?9108:596?}]], nil,
nil, "SaSo",
string_op.txt_checked(g_Box.NightRingException == "SaSo"), "", ""
)
Htm2Box( "<br>")
assi_control.InputField( "InputLabel", "radio", "NightRingException", "++MoFr",
[[{?9108:228?}]], nil,
nil, "MoFr",
string_op.txt_checked(g_Box.NightRingException == "MoFr"), "", ""
)
Htm2Box( "<br>")
Htm2Box( "<div>")
Htm2Box( [[{?9108:177?}]])
assi_control.InputField( "Input", "text", "NightRingTimeStartHour", nil, "",
g_Const.MaxHourMinuteLen, g_Const.MaxHourMinuteLen + 1,
g_Box.NightRingTimeStartHour, "", "", ""
)
Htm2Box( [[{?9108:735?}]])
assi_control.InputField( "Input", "text", "NightRingTimeStartMinute", nil, "",
g_Const.MaxHourMinuteLen, g_Const.MaxHourMinuteLen + 1,
g_Box.NightRingTimeStartMinute, "", "", ""
)
Htm2Box( [[{?9108:147?}]])
assi_control.InputField( "Input", "text", "NightRingTimeEndHour", nil, "",
g_Const.MaxHourMinuteLen, g_Const.MaxHourMinuteLen + 1,
g_Box.NightRingTimeEndHour, "", "", ""
)
Htm2Box( [[{?9108:960?}]])
assi_control.InputField( "Input", "text", "NightRingTimeEndMinute", nil, "",
g_Const.MaxHourMinuteLen, g_Const.MaxHourMinuteLen + 1,
g_Box.NightRingTimeEndMinute, "", "", ""
)
Htm2Box( "</div>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_InvalidHour", g_Alert.InvalidHour)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_InvalidMinute", g_Alert.InvalidMinute)
Htm2Box( "</div>")
Htm2Box("</div>")
end
Htm2Box( "<p>")
Htm2Box( "<b>")
box.out( [[{?9108:9491?}]])
Htm2Box( "</b>")
Htm2Box( "</p>")
Htm2Box( "<p>")
box.out( [[{?9108:954?}]])
Htm2Box( "</p>")
Htm2Box( "</div>")
Htm2Box( "<div id='Id_Waiting' " .. string_op.txt_style_display_none(true) .. ">")
Htm2Box( g_Txt.BitteWarten)
Htm2Box( "</div>")
Htm2Box("</div>")
if g_Box.WorkAs == "Wizard" then
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("@Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "")
else
assi_control.CreateButton("@Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "S")
end
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "")
assi_control.CreateButton("Help", g_Txt.Hilfe, "", "E")
end
function Multiside_WizardFonMerkmaleANALOG()
Htm2Box("<script type='text/javascript'>")
box.out( "function Cb_Clip()\n")
box.out( "{\n")
box.out( "var Disable = ! jxl.getChecked('Id_Clip');\n")
box.out( "jxl.setDisabled('Id_ClipModeAdvanced', Disable);\n")
box.out( "jxl.setDisabled('Id_ClipModeSimple', Disable);\n")
box.out( "}\n")
box.out( "function Cb_Mwi()\n")
box.out( "{\n")
box.out( "var Disable = ! jxl.getChecked('Id_Mwi');\n")
box.out( "jxl.setDisabled('Id_MwiModeEinmal', Disable);\n")
box.out( "jxl.setDisabled('Id_MwiModeImmer', Disable);\n")
box.out( "jxl.setDisabled('Id_MwiVoice', Disable);\n")
box.out( "jxl.setDisabled('Id_MwiMail', Disable);\n")
box.out( "jxl.setDisabled('Id_MwiFax', Disable);\n")
box.out( "}\n")
box.out( "function Cb_Clir()\n")
box.out( "{\n")
box.out( "var Checked = jxl.getChecked('Id_AnalogClir');\n")
if (not config.CAPI_TE) and (not config.CAPI_POTS) then
fon_nr_config.BoxAlert("Checked", g_Txt.ClirOhneFestnetz)
elseif fon_nr_config.NrInfo().UsePstn == "1" then
fon_nr_config.BoxAlert("Checked", g_Txt.ClirActivation)
else
fon_nr_config.BoxAlert("Checked", g_Txt.ClirOhneFestnetz)
end
box.out( "}\n")
box.out( "function Cb_Start()\n")
box.out( "{\n")
box.out( "Cb_Clip()\n")
box.out( "Cb_Mwi()\n")
box.out( "}\n")
box.out( "ready.onReady(Cb_Start);\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<div>")
Htm2Box( "<b>")
Htm2Box( [[{?9108:474?}]])
Htm2Box( "</b>")
Htm2Box( "</div>")
Htm2Box( "<table class='ClassEditMerkmaleTable' id='Id_DataArea'>")
Htm2Box( "<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "AnalogClir", nil, "", nil, nil, nil,
string_op.txt_checked(g_Box.AnalogClir == "on"), "Cb_Clir()", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "AnalogClir", nil,
[[{?9108:756?}]],
nil, nil, nil, "", "", ""
)
Htm2Box( "<br>")
Htm2Box( [[{?9108:41?}]])
Htm2Box( "</td>")
Htm2Box( "</tr>")
Htm2Box( "<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "Clip", nil, "", nil, nil, nil,
string_op.txt_checked(g_Box.Clip == "on"), "Cb_Clip()", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "Clip", nil,
[[{?9108:308?}]],
nil, nil, nil, "", "", ""
)
Htm2Box( "<br>")
Htm2Box( [[{?9108:823?}]])
Htm2Box( "<br>")
if g_Const.AbCount >= 1 then
assi_control.InputField( "InputLabel", "radio", "ClipMode", "++Advanced",
[[{?9108:85?}]], nil, nil,
"Advanced", string_op.txt_checked(g_Box.ClipMode == "Advanced"), "", ""
)
Htm2Box("<br>")
assi_control.InputField( "InputLabel", "radio", "ClipMode", "++Simple",
[[{?9108:298?}]], nil, nil,
"Simple", string_op.txt_checked(g_Box.ClipMode == "Simple"), "", ""
)
end
Htm2Box( "</td>")
Htm2Box( "</tr>")
Htm2Box( "<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "AnalogAnklopfen", nil, "", nil, nil, nil,
string_op.txt_disabled(g_Box.AnklopfenTyp ~= "Fon")
.. string_op.txt_checked(g_Box.AnalogAnklopfen == "on"), "", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "AnalogAnklopfen", nil,
[[{?9108:3992?}]], nil, nil, nil, "", "", ""
)
Htm2Box( "<br>")
Htm2Box( [[{?9108:32?}]])
Htm2Box( "<br>")
Htm2Box( "</td>")
Htm2Box( "</tr>")
if g_Const.AbCount >= 1 then
Htm2Box( "<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "AnalogBusyOnBusy", nil, "", nil,
nil, nil, string_op.txt_checked(g_Box.AnalogBusyOnBusy == "on"), "", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "AnalogBusyOnBusy", nil,
[[{?9108:34?}]],
nil, nil, nil, "", "", ""
)
Htm2Box( "<br>")
Htm2Box( [[{?9108:719?}]])
Htm2Box( "</td>")
Htm2Box( "</tr>")
end
if fon_nr_config.NrInfo().UsePstn == "1" then
Htm2Box( "<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "Colr", nil, "", nil, nil, nil,
string_op.txt_checked(g_Box.Colr == "on"), "", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "Colr", nil,
[[{?9108:83?}]],
nil, nil, nil, "", "", ""
)
Htm2Box( "<br>")
Htm2Box( [[{?9108:195?}]])
Htm2Box( "</td>")
Htm2Box( "</tr>")
end
Htm2Box( "<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "Mwi", nil, "", nil, nil, nil,
string_op.txt_checked(g_Box.Mwi == "on"), "Cb_Mwi()", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "Mwi", nil,
[[{?9108:813?}]],
nil, nil, nil, "", "", ""
)
Htm2Box( "<br>")
Htm2Box( [[{?9108:111?}]])
Htm2Box( "<br>")
Htm2Box( "<br>")
Htm2Box( [[{?9108:80?}]])
Htm2Box( "<div>")
assi_control.InputField( "InputLabel", "radio", "MwiMode", "++Einmal",
[[{?9108:301?}]],
nil, nil, "Einmal", string_op.txt_checked(g_Box.MwiMode == "Einmal"), "", ""
)
Htm2Box( "<br>")
assi_control.InputField( "InputLabel", "radio", "MwiMode", "++Immer",
[[{?9108:870?}]], nil, nil,
"Immer", string_op.txt_checked(g_Box.MwiMode == "Immer"), "", ""
)
Htm2Box( "</div>")
Htm2Box( [[{?9108:903?}]])
Htm2Box( "<div>")
assi_control.InputField( "InputLabel", "checkbox", "MwiVoice", nil,
[[{?9108:415?}]], nil, nil, nil,
string_op.txt_checked(g_Box.MwiVoice == "on"), "", ""
)
Htm2Box( "<br>")
assi_control.InputField( "InputLabel", "checkbox", "MwiMail", nil,
[[{?9108:712?}]], nil, nil, nil,
string_op.txt_checked(g_Box.MwiMail == "on"), "", ""
)
Htm2Box( "<br>")
assi_control.InputField( "InputLabel", "checkbox", "MwiFax", nil,
[[{?9108:715?}]], nil, nil, nil,
string_op.txt_checked(g_Box.MwiFax == "on"), "", ""
)
Htm2Box( "</div>")
Htm2Box( "</td>")
Htm2Box( "</tr>")
Htm2Box( "</table>")
Htm2Box( "<div id='Id_Waiting' " .. string_op.txt_style_display_none(true) .. ">")
Htm2Box( g_Txt.BitteWarten)
Htm2Box( "</div>")
Htm2Box("</div>")
if g_Box.WorkAs == "Wizard" then
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "")
else
assi_control.CreateButton("@Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "S")
end
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "")
assi_control.CreateButton("Help", g_Txt.Hilfe, "", "E")
end
function Multiside_WizardFonMerkmaleImageLoadDECT()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:179?}]])
Htm2Box( "</p>")
Htm2Box( "<p>")
assi_control.InputField("Input", "file", "DectImagePath", nil, "", 50, 2048, "", "", "", "")
Htm2Box( "</p>")
Htm2Box("</div>")
assi_control.CreateButton("Next", g_Txt.Uebernehmen, "", "S")
assi_control.CreateButton("Back", g_Txt.Abbrechen, "", "")
assi_control.CreateButton("Help", g_Txt.Hilfe, "", "E")
end
function Multiside_WizardFonMerkmaleDECT()
Htm2Box("<script type='text/javascript'>")
box.out( "function Cb_Clir()\n")
box.out( "{\n")
box.out( "var Checked = jxl.getChecked('Id_DectClir');\n")
if (not config.CAPI_TE) and (not config.CAPI_POTS) then
fon_nr_config.BoxAlert("Checked", g_Txt.ClirOhneFestnetz)
elseif fon_nr_config.NrInfo().UsePstn == "1" then
fon_nr_config.BoxAlert("Checked", g_Txt.ClirActivation)
else
fon_nr_config.BoxAlert("Checked", g_Txt.ClirOhneFestnetz)
end
box.out( "}\n")
box.out( "function Cb_DisableDectBusyDelayed(Disable)\n")
box.out( "{\n")
box.out( "jxl.setDisabled('Id_DectBusyDelayed', Disable);\n")
box.out( "}\n")
box.out( "function Cb_BusyOnBusy()\n")
box.out( "{\n")
box.out( "Cb_DisableDectBusyDelayed(! jxl.getChecked('Id_DectBusyOnBusy'));\n")
box.out( "}\n")
if config.DECT_PICTURED and (g_Box.DectIsMtF == "T") then
box.out("function Cb_PicJob(Next)\n")
box.out("{\n")
box.out( "var Name = ['WizardFonMerkmaleDECT', 'WizardFonMerkmaleImageLoadDECT'];\n")
box.out( "Cb_Ok();\n")
box.out( "jxl.setValue('Id_Submit_Tab', Name[Next]);\n")
box.out( "jxl.enable('Id_Submit_Tab');\n")
box.out( "jxl.submitForm('New_Form');\n")
box.out( "return false;\n")
box.out("}\n")
box.out("function Cb_PicDelete()\n")
box.out("{\n")
box.out( "if (confirm('" .. [[{?9108:846?}]] .. "'))\n")
box.out( "{\n")
box.out( "jxl.setValue('Id_Old_DectImagePath', '');\n")
box.out( "Cb_PicJob(0);\n")
box.out( "}\n")
box.out( "return false;\n")
box.out("}\n")
end
box.out( "ready.onReady(Cb_BusyOnBusy);\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<div>")
Htm2Box( "<b>")
Htm2Box( [[{?9108:820?}]])
Htm2Box( "</b>")
Htm2Box( "</div>")
Htm2Box( "<div id='Id_DataArea'>")
Htm2Box( "<table class='ClassEditMerkmaleTable'>")
if string_op.in_list(g_Box.DectManufacturer, {"AVM/Swissvoice", "AVM"})
and (g_Box.CountTamActivated ~= "0")
then
Htm2Box("<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "DectMonitorTam", nil, "", nil, nil, nil,
string_op.txt_checked(g_Box.DectMonitorTam == "on"), "", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "DectMonitorTam", nil,
[[{?9108:309?}]],
nil, nil, nil, "", "", ""
)
Htm2Box( "</td>")
Htm2Box("</tr>")
end
if g_Box.DectManufacturer == "AVM" then
Htm2Box("<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "DectVanity", nil, "", nil, nil, nil,
string_op.txt_checked(g_Box.DectVanity == "on"), "", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "DectVanity", nil,
[[{?9108:134?}]],
nil, nil, nil, "", "", ""
)
Htm2Box( "</td>")
Htm2Box("</tr>")
end
Htm2Box( "<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "DectClir", nil, "", nil, nil, nil,
string_op.txt_checked(g_Box.DectClir == "on"), "Cb_Clir()", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "DectClir", nil,
[[{?9108:641?}]],
nil, nil, nil, "", "", ""
)
Htm2Box( "<br>")
Htm2Box( [[{?9108:140?}]])
Htm2Box( "</td>")
Htm2Box( "</tr>")
Htm2Box( "<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "DectAnklopfen", nil, "", nil, nil, nil,
string_op.txt_checked(g_Box.DectAnklopfen == "on"), "", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "DectAnklopfen", nil,
[[{?9108:296?}]], nil, nil, nil, "", "", ""
)
Htm2Box( "<br>")
Htm2Box( [[{?9108:654?}]])
Htm2Box( "<br>")
Htm2Box( "</td>")
Htm2Box( "</tr>")
Htm2Box( "<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "DectBusyOnBusy", nil, "", nil, nil, nil,
string_op.txt_checked(g_Box.DectBusyOnBusy == "on"), "Cb_BusyOnBusy()", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "DectBusyOnBusy", nil,
[[{?9108:112?}]],
nil, nil, nil, "", "", ""
)
Htm2Box( "<br>")
Htm2Box( [[{?9108:946?}]])
if config.CAPI_NT then
Htm2Box( "<table class='ClassEditDectMerkmaleBusyDelayedTable'>")
Htm2Box( "<tr>")
Htm2Box( "<td class='ClassEditTableLeft'>")
assi_control.InputField( "Input", "checkbox", "DectBusyDelayed", nil, "", nil, nil,
nil, string_op.txt_checked(g_Box.DectBusyDelayed == "on"),
"", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditTableRight'>")
assi_control.InputField( "Label", "checkbox", "DectBusyDelayed", nil,
[[{?9108:1482?}]],
nil, nil, nil, "", "", ""
)
Htm2Box( "</td>")
Htm2Box( "</tr>")
Htm2Box("</table>")
end
Htm2Box( "</td>")
Htm2Box( "</tr>")
Htm2Box( "</table>")
if config.DECT_PICTURED and (g_Box.DectIsMtF == "T") then
Htm2Box("<hr>")
Htm2Box("<p>")
Htm2Box( "<b>")
Htm2Box( [[{?9108:837?}]])
Htm2Box( "</b>")
Htm2Box("</p>")
Htm2Box("<div>")
box.out( [[{?9108:817?}]])
Htm2Box( "<br>")
box.out( [[{?9108:1622?}]])
Htm2Box( "<br>")
local ButtonText = [[{?9108:629?}]]
Htm2Box("<div class='ClassEditDectMerkmaleImage'>")
if g_Box.DectImagePath == "" then
Htm2Box( "<span>")
Htm2Box( [[{?9108:679?}]])
Htm2Box( "</span>")
else
Htm2Box( "<img alt='" .. [[{?9108:921?}]]
.. "' src='/lua/photo.lua?photo=" .. g_Box.DectImagePath .. "&sid="
.. box.glob.sid .. "'>"
)
ButtonText = [[{?9108:8804?}]]
end
Htm2Box("</div>")
Htm2Box("<div class='ClassEditDectMerkmaleImageButton'>")
Htm2Box( "<button type='button' onclick='return Cb_PicJob(1)'>")
Htm2Box( "<img src='../html/de/images/bearbeiten.gif'>")
Htm2Box( "</button>")
Htm2Box( ButtonText)
Htm2Box("</div>")
if g_Box.DectImagePath ~= "" then
Htm2Box("<div class='ClassEditDectMerkmaleImageButton'>")
Htm2Box( "<button type='button' onclick='return Cb_PicDelete()'>")
Htm2Box( "<img src='../html/de/images/loeschen.gif'>")
Htm2Box( "</button>")
Htm2Box( [[{?9108:758?}]])
Htm2Box("</div>")
end
Htm2Box("<div class='clear_float'>")
Htm2Box("</div>")
if (not g_Box.InternalMemEnabled) and config.RAMDISK then
Htm2Box("<p>")
Htm2Box( [[{?9108:623?}]])
Htm2Box("</p>")
end
Htm2Box("</div>")
end
Htm2Box( "<hr>")
Htm2Box( "<p>")
Htm2Box( "<b>")
Htm2Box( [[{?9108:989?}]])
Htm2Box( "</b>")
Htm2Box( "</p>")
if config.DECT_MONI then
if (g_Box.ExpertMode == "1") and (string.find(g_Box.DectHandsetCodecs, "G.722") ~= nil) then
Htm2Box("<div>")
Htm2Box( "<select name='New_DectHdOption' id='Id_DectHdOption'>")
for _, Curr in pairs(g_DectHdOptionTable) do
local Selected = string_op.txt_selected(g_Box.DectHdOption == Curr.Value)
Htm2Box("<option value='" .. Curr.Value .. "'" .. Selected ..">")
Htm2Box( Curr.Name)
Htm2Box("</option>")
end
Htm2Box( "</select>")
Htm2Box("</div>")
Htm2Box("<hr>")
end
Htm2Box("<p>")
Htm2Box( "<b>")
Htm2Box( [[{?9108:8482?}]])
Htm2Box( "</b>")
Htm2Box("</p>")
Htm2Box("<div>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:847?}]])
Htm2Box( "</p>")
Htm2Box( "<table class='ClassEditMerkmaleTable' id='Id_DataArea'>")
Htm2Box("<tr>")
Htm2Box( "<td class='ClassEditDectMerkmaleEqualizerColumnTable'>")
Htm2Box("")
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditDectMerkmaleEqualizerColumnTable'>")
Htm2Box([[{?9108:1503?}]])
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditDectMerkmaleEqualizerColumnTable'>")
Htm2Box([[{?9108:964?}]])
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditDectMerkmaleEqualizerColumnTable'>")
Htm2Box([[{?9108:31?}]])
Htm2Box( "</td>")
Htm2Box("</tr>")
for Index = 18, -18, -6 do
Htm2Box("<tr>")
Htm2Box( "<td class='ClassEditDectMerkmaleEqualizerColumnTable'>")
if Index == 18 then
Htm2Box([[{?9108:54?}]])
elseif Index == 0 then
Htm2Box([[{?9108:269?}]])
elseif Index == -18 then
Htm2Box([[{?9108:121?}]])
end
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditDectMerkmaleEqualizerColumnTable'>")
assi_control.InputField( "Input", "radio", "DectEqualizeLow",
"DectEqualizeLow" .. Index, "", nil, nil,
tostring(Index),
string_op.txt_checked( g_Box.DectEqualizeLow
== tostring(Index)
), "", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditDectMerkmaleEqualizerColumnTable'>")
assi_control.InputField( "Input", "radio", "DectEqualizeMedium",
"DectEqualizeMedium" .. Index, "", nil, nil,
tostring(Index),
string_op.txt_checked( g_Box.DectEqualizeMedium
== tostring(Index)
), "", ""
)
Htm2Box( "</td>")
Htm2Box( "<td class='ClassEditDectMerkmaleEqualizerColumnTable'>")
assi_control.InputField( "Input", "radio", "DectEqualizeHigh",
"DectEqualizeHigh" .. Index, "", nil, nil,
tostring(Index),
string_op.txt_checked( g_Box.DectEqualizeHigh
== tostring(Index)
), "", ""
)
Htm2Box( "</td>")
Htm2Box("</tr>")
end
Htm2Box( "</table>")
Htm2Box("</div>")
end
Htm2Box( "</div>")
Htm2Box( "<div id='Id_Waiting' " .. string_op.txt_style_display_none(true) .. ">")
Htm2Box( g_Txt.BitteWarten)
Htm2Box( "</div>")
Htm2Box("</div>")
if g_Box.WorkAs == "Wizard" then
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "")
else
assi_control.CreateButton("@Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "S")
end
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "")
assi_control.CreateButton("Help", g_Txt.Hilfe, "", "E")
end
function Multiside_WizardFonStartISDN()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<div>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:944?}]])
Htm2Box( "51")
Htm2Box( "</p>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNoNotation", g_Alert.NoNotation)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertNotationLen", g_Alert.NotationLen)
fon_nr_config.BoxOutErrorLine( "ClassAlert", "Id_AlertReservedNotation",
g_Alert.ReservedNotation
)
Htm2Box( "<br>")
assi_control.InputField( "LabelInput", "text", "Notation", nil, g_Txt.BezeichnungDP,
g_Const.MaxNotationLen + 2, g_Const.MaxNotationLen, g_Box.Notation, "",
"Cb_Notation(value)", ""
)
Htm2Box( "<br>")
Htm2Box( "<table class='ClassNumberListTable' id='Id_OutgoingNrTable'>")
local IgnoreListe = {}
if config.CAPI_NT and assi_control.GetPortTyp(g_Box.Port) == "ISDN" then
for Index = 0, g_Const.FaxModemCount - 1, 1 do
local Nr = g_Box["FaxModem" .. Index .. "Number"]
if Nr ~= "" then
table.insert(IgnoreListe, Nr)
end
end
end
fon_nr_config.BoxOutHtmlCode_GetOutgoingNrBox( "EditOut",
fon_nr_config.NrInfo().PrevValues.OutgoingNr,
"EmptyEntry", "WithCallback", "NoPotsToText",
IgnoreListe
)
Htm2Box( "</table>")
Htm2Box( "</div>")
Htm2Box("</div>")
assi_control.CreateButton("Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "S")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "")
assi_control.CreateButton("Help", g_Txt.Hilfe, "", "E")
end
function Multiside_WizardFonKlingeltoeneDECT()
if config.DECT_MONI and (g_Box.WorkAs == "Edit") then
Htm2Box("<script type='text/javascript'>")
box.out( "function Cb_TestenRingOff()\n")
box.out( "{\n")
box.out( "}\n")
box.out( "function Cb_TestenRingIsRuning()\n")
box.out( "{\n")
box.out( "alert('" .. [[{?9108:351?}]] .. "');\n")
HtmlAjaxRingTest( "0", "Cb_TestenRingOff",
fon_nr_config.Query( "telcfg:settings/Foncontrol/" .. g_Box.DectFoncontrolName
.. "/IntRingTone", g_CapitermInfo
)
)
box.out( "}\n")
box.out( "function Cb_Testen()\n")
box.out( "{\n")
HtmlAjaxRingTest("1", "Cb_TestenRingIsRuning", "jxl.getValue('Id_RingToneTest')")
box.out( "}\n")
Htm2Box("</script>")
end
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<div>")
Htm2Box( "<p>")
Htm2Box( [[{?9108:449?}]])
Htm2Box( "</p>")
if config.DECT_MONI then
Htm2Box("<p>")
Htm2Box( "<b>")
Htm2Box( [[{?9108:808?}]])
Htm2Box( "</b>")
Htm2Box("</p>")
Htm2Box("<div>")
Htm2Box("<table class='ClassEditKlingeltoeneTable' id='Id_ToneTable'>")
for Index = 1, #fon_nr_config.g_NrInfo.All, 1 do
if fon_nr_config.g_NrInfo.All[Index].IsClicked == "on" then
HtmlRingToneLine( "Incoming" .. Index,
fon_nr_config.g_NrInfo.All[Index].RingTone,
g_Txt.Rufnummer .. " " .. fon_nr_config.g_NrInfo.All[Index].Nr
)
end
end
HtmlRingToneLine( "Intern", g_Box.DectRingToneIntern,
[[{?9108:297?}]]
)
HtmlRingToneLine( "Vip", g_Box.DectRingToneVip,
[[{?9108:684?}]]
)
HtmlRingToneLine( "Alarm", g_Box.DectRingToneAlarm,
[[{?9108:955?}]]
)
Htm2Box("</table>")
Htm2Box("</div>")
if g_Box.WorkAs == "Edit" then
Htm2Box("<p>")
Htm2Box( "<b>")
Htm2Box( [[{?9108:95?}]])
Htm2Box( "</b>")
Htm2Box("</p>")
Htm2Box("<div>")
Htm2Box( [[{?9108:495?}]])
Htm2Box("</div>")
Htm2Box("<div>")
Htm2Box("<table class='ClassEditKlingeltoeneTable' id='Id_ToneTest'>")
HtmlRingToneLine("Test", "0", nil)
Htm2Box("</table>")
Htm2Box("</div>")
end
end
Htm2Box( "</div>")
Htm2Box("</div>")
if g_Box.WorkAs == "Wizard" then
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "")
else
assi_control.CreateButton("Save", g_Txt.Ok, " onclick='return Cb_Ok();'", "S")
end
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "")
assi_control.CreateButton("Help", g_Txt.Hilfe, "", "E")
end
g_page_title = general.sprintf(g_Box.PageTitle, g_Box.PageTitleParam)
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<link rel="stylesheet" type="text/css" href="/css/default/fon_nr_config.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<script type="text/javascript" src="/js/ajax.js">
</script>
<?include "templates/page_head.html" ?>
<?lua
box.out([[<script type="text/javascript" src="/js/wizard.js?lang=]], config.language, [["></script>]])
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
box.out([[<script type="text/javascript" src="/js/assi_telefon.js"></script>]])
box.out([[<script type="text/javascript" src="/js/password_checker.js"></script>]])
capiterm.var("box.post",box.post)
capiterm.var("box.get",box.get)
--assi_control.SetCtlmgrVars(box.post)
local FormActionParam = string_op.bool_to_value( g_Box.WorkAs ~= "Assi",
"?" .. string.lower(g_Box.WorkAs) .. "=var", ""
)
Htm2Box("<form name='New_Form' method='POST' action='" .. box.glob.script .. FormActionParam .. "'>")
HtmlJavaScriptForEditOrWork()
if g_Box.CurrSide ~= "WizardFonMerkmaleImageLoadDECT" then
HtmlTabulatorForEditOrWork()
end
assi_control.LoadHtmlSide()
assi_control.AddHiddenSID()
assi_control.HiddenValues(g_Box.CurrSide)
assi_control.AddOtherHiddenInputs()
Htm2Box("</form>")
ShowJavaScriptThisSide = string_op.in_list(g_Box.CurrSide, g_SideList.HasIncomingNr)
fon_nr_config.JavaScriptCb_NrHandling(ShowJavaScriptThisSide, false, true, g_Box.WorkAs,false)
html_check.debug()
?>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
