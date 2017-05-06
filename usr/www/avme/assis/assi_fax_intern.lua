<?lua
dofile("../templates/global_lua.lua")
require("capiterm")
require("http")
require("fon_nr_config")
require("general")
require("html_check")
require("string_op")
require("push_check_html")
require("assi_control")
require("val")
require("fon_devices_html")
require("pushservice")
require("cmtable")
require("email_data")
g_data ={}
g_val = {
prog = [[
]]
}
g_val.prog = g_val.prog..fon_devices_html.get_email_config_validation()
local err_msg_empty=TXT([[{?804:71?}]])
val.msg.err_email_addr= {
[val.ret.empty]=err_msg_empty,
[val.ret.format] = TXT([[{?804:821?}]])
}
g_page_type="wizard"
g_CapitermEnabled = "F"
g_CapitermInfo = assi_control.TraceStart(g_CapitermEnabled, box.glob.script)
g_Alert = {}
g_Box = { WhoAmI = box.glob.script,
FinishPage = "/assis/assi_fondevices_list.lua",
WorkAs = "Assi",
DeviceTyp = "Fax",
TechTyp = "INTERN",
EditTab = "Übersicht",
EditDeviceNo = "",
CurrSide = "AssiFaxInternStartSide",
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
{ Token = "IsUsbStorage", WorkAs = {"Assi"},
Control = "nil", Init = "0"
},
{ Token = "IsTamMode", WorkAs = {"Assi"},
Control = "nil", Init = "0"
},
{ Token = "InternalMemEnabled", WorkAs = {"Assi"},
Control = "nil", Init = "0"
},
{ Token = "UsbDiskCount", WorkAs = {"Assi"},
Control = "nil", Init = "0"
},
{ Token = "UsbDiskName", WorkAs = {"Assi"},
Control = "nil", Init = ""
},
{ Token = "Oem", WorkAs = {"Assi"},
Control = "nil", Init = ""
},
{ Token = "IsMailerConfigured", WorkAs = {"Assi"},
Control = "nil", Init = "0"
},
{ Token = "FaxMailActiveMode", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "FaxMailCheckbox", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "FaxKennung", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "ActivateEMail", WorkAs = {"Assi"},
Control = "SLAssiFaxInternStartSide", Init = "off"
},
{ Token = "EMailAdr", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "EMailShowUserData", WorkAs = {"Assi"},
Control = "SLAssiFaxInternPushMail", Init = "on"
},
{ Token = "username", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "email", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "server", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "port", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "use_ssl", WorkAs = {"Assi"},
Control = "SLAssiFaxInternPushMail", Init = "off"
},
{ Token = "pass", WorkAs = {"Assi"},
Control = "New", Init = ""
},
{ Token = "FaxSwitch", WorkAs = {"Assi"},
Control = "SLAssiFaxInternIncoming", Init = "off"
}
}
g_Const = { MaxFaxKennungLen = 20,
MaxEMailAdrLen = 127,
MaxEMailSenderNameLen = 40,
MaxEMailUserNameLen = 40,
MaxEMailSenderAdrLen = 80,
MaxEMailSMTPServerLen = 40,
MaxEMailAolPasswordLen = 16,
SizeEMailAdrLen = 40,
SizeSide4FieldLen = 53,
EMailPasswordLen = 64,
MinEMailAolPasswordLen = 6
}
g_SideList = { AssiFaxIntern = { "AssiFaxInternStartSide", "AssiFaxInternIncoming", "AssiFaxInternSummary",
"AssiFaxInternPushMail", "AssiFaxInternMailTest"
}
}
g_SideHeader = { { Id = { "AssiFaxInternStartSide", "AssiFaxInternIncoming", "AssiFaxInternSummary",
"AssiFaxInternPushMail"
},
Head = [[{?g_txt_EinstellungFuerFaxEmpfang?}]]
},
{ Id = {"AssiFaxInternMailTest"},
Head = [[{?g_txt_PushServiceStatus?}]]
}
}
g_ServerProvider = { { Server = "smtp.1und1.de", Provider = "1&1 DSL", Ignore = "",
ShowSmtp = "F", ShowTextOnly = "T", ShowCheckBox = "F",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:257?}]]
},
{ Server = "smtp.de.aol.com:587", Provider = "AOL", Ignore = "1und1",
ShowSmtp = "F", ShowTextOnly = "T", ShowCheckBox = "F",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:459?}]]
},
{ Server = "mail.arcor.de", Provider = "Arcor" , Ignore = "1und1",
ShowSmtp = "F", ShowTextOnly = "T", ShowCheckBox = "F",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:481?}]]
},
{ Server = "smtp.pop.debitel.de", Provider = "debitel", Ignore = "1und1",
ShowSmtp = "F", ShowTextOnly = "T", ShowCheckBox = "F",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:197?}]]
},
{ Server = "mx.freenet.de", Provider = "Freenet", Ignore = "1und1",
ShowSmtp = "F", ShowTextOnly = "T", ShowCheckBox = "F",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:407?}]]
},
{ Server = "mail.gmx.de", Provider = "GMX", Ignore = "",
ShowSmtp = "F", ShowTextOnly = "T", ShowCheckBox = "F",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:516?}]]
},
{ Server = "mx.qsc.de", Provider = "QSC", Ignore = "1und1",
ShowSmtp = "F", ShowTextOnly = "T", ShowCheckBox = "F",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:347?}]]
},
{ Server = "smtp.rtl.um.mediaways.net", Provider = "RTL", Ignore = "1und1",
ShowSmtp = "F", ShowTextOnly = "T", ShowCheckBox = "F",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:529?}]]
},
{ Server = "mailto.t-online.de", Provider = "T-Online",Ignore = "1und1",
ShowSmtp = "F", ShowTextOnly = "F", ShowCheckBox = "F",
OnChangeSetChecked = "F", ShowDataArea = "F", Name = [[{?804:174?}]]
},
{ Server = "smtp.web.de", Provider = "WEB.DE", Ignore = "",
ShowSmtp = "F", ShowTextOnly = "T", ShowCheckBox = "F",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:139?}]]
},
{ Server = "smtp.mail.yahoo.de", Provider = "Yahoo", Ignore = "1und1",
ShowSmtp = "F", ShowTextOnly = "T", ShowCheckBox = "F",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:767?}]]
},
{ Server = "", Provider = "Sonst", Ignore = "",
ShowSmtp = "T", ShowTextOnly = "F", ShowCheckBox = "T",
OnChangeSetChecked = "T", ShowDataArea = "T", Name = [[{?804:772?}]]
}
}
g_Txt = { FritzBox = [[{?g_txt_FritzBox?}]],
FaxKennungMaxXChar = [[{?g_txt_FaxKennungMaxXChar?}]],
AutomaticFaxForNr = [[{?804:225?}]],
EMailAdrMaxXChar = [[{?g_txt_EMailAdrMaxXChar?}]],
MaxXChar = [[{?g_txt_MaxXZeichen?}]],
Zurueck = [[{?g_txt_Zurueck?}]],
Weiter = [[{?g_txt_Weiter?}]],
Uebernehmen = [[{?g_txt_Uebernehmen?}]],
Abbrechen = [[{?g_txt_Abbrechen?}]],
NichtAblegen = [[{?804:858?}]],
InternAblegen = [[{?804:765?}]],
EMailAddress = [[{?804:173?}]],
EMailBenuterName = [[{?804:106?}]],
AolPasswort = [[{?804:854?}]],
Kennwort = [[{?g_txt_Kennwort?}]],
AufDemUsbSpeicherAblegen = [[{?g_txt_AufDemUsbSpeicherAblegen?}]],
SenderAddressMissing = [[{?804:725?}]],
ServerMissing = [[{?804:309?}]],
AolKennwortMin = [[{?804:596?}]],
AolKennwortMax = [[{?804:555?}]],
InvalAolKennwort = [[{?804:35?}]],
KennwortZuLang = [[{?804:4390?}]],
NumberMandatory = [[{?g_txt_NumberMandatory?}]],
EMailAdrEmpty = [[{?804:550?}]],
EmailAdrFormat = [[{?804:818?}]],
FaxSwitchAndPots = [[{?804:965?}]],
FaxNoUsb = { NoInternal = [[{?804:547?}]],
Internal = [[{?804:220?}]]
},
FaxAuraAn = { NoInternal = [[{?804:5752?}]],
Internal = [[{?804:574?}]]
},
FaxTarget = { NoInternal = [[{?804:504?}]],
Internal = [[{?804:8036?}]]
},
NeinJa = {off = [[{?g_txt_Nein?}]], on = [[{?g_txt_Ja?}]]}
}
g_errmsg = ""
function is_valid_email(EMailAdr)
local is_valid_adr=false
if (EMailAdr) then
is_valid_adr=(string.find(EMailAdr, val.pr.email.pat))
end
return is_valid_adr
end
function is_valid_email_list(EMailAdr)
if (EMailAdr) then
EMailAdr=string.gsub(EMailAdr," ","")
local t=string_op.split2table(EMailAdr,",",0)
for i,adr in ipairs(t) do
if not is_valid_email(adr) then
return false
end
end
return true
end
return false
end
function EMailValuesFromPpp(NameAdr)
local Name
local Address
if NameAdr == "" then
return "", "", "Sonst"
end
Name, Address = string.match(NameAdr, '(.*)(@de.aol.com)$')
if Name ~= nil then
return Name, Name .. "@aol.com", "AOL"
end
Name, Address = string.match(NameAdr, '(.*)(@t%-online.de)$')
if Name ~= nil then
local Table = string_op.split2table(Name, "#", 2)
if #Table == 3 then
return "", Table[2] .. "-" .. Table[3] .. "@t-online.de", "TOnline"
end
if #Table == 2 then
return "", string.sub(Table[1], 13) .. "-" .. Table[2] .. "@t-online.de", "TOnline"
end
return "", string.sub(NameAdr, 13, 24) .. "-" .. string.sub(Name, 25) .. "@t-online.de", "TOnline"
end
Name, Address = string.match(NameAdr, '^1und1/(.*)(@online.de)$')
if Name ~= nil then
Name = Name .. "@online.de"
return Name, Name, "1u1"
end
if string.find(NameAdr, 'GMX/') == 1 then
return "", NameAdr, "GMX"
end
return "", "", "Sonst"
end
function GetProviderBySMTPServer(SMTPServer, EMailProvider)
for Index = 1, #g_ServerProvider, 1 do
if (SMTPServer == g_ServerProvider[Index].Server) and (g_Box.Oem ~= g_ServerProvider[Index].Ignore) then
return g_ServerProvider[Index].Provider
end
end
return EMailProvider
end
function GetSMTPServerByProvider(Provider)
for Index = 1, #g_ServerProvider, 1 do
if (Provider == g_ServerProvider[Index].Provider) and (g_Box.Oem ~= g_ServerProvider[Index].Ignore) then
return g_ServerProvider[Index].Server
end
end
return ""
end
function LoadFromBox(BoxVariablen)
if g_CapitermEnabled == "T" then
capiterm.txt_nl("LoadFromBox", g_CapitermInfo)
end
local CapitermInfo = assi_control.SetCapitermInfo(g_CapitermEnabled, box.glob.script .. "@LoadFromBox")
local Index
assi_control.InitWithDefaults(BoxVariablen)
if config.TAM and config.TAM_MODE then
g_Box.IsTamMode = "1"
end
g_Box.Oem = fon_nr_config.Query("env:status/OEM", CapitermInfo)
g_Box.Aura4Storage="0"
if box.query("aura:settings/enabled")=="1" then
g_Box.Aura4Storage = fon_nr_config.Query("aura:settings/aura4storage", CapitermInfo)
end
if config.USB_STORAGE and (config.USB_HOST or config.USB_HOST_AVM or config.USB_HOST_TI) then
g_Box.IsUsbStorage = "1"
end
g_Box.InternalMemEnabled = fon_nr_config.Query("ctlusb:settings/internalflash_enabled", CapitermInfo)
g_Box.FaxMailActiveMode = fon_nr_config.Query("telcfg:settings/FaxMailActive", CapitermInfo)
if ((g_Box.InternalMemEnabled == "1") and string_op.in_list(g_Box.FaxMailActiveMode, {"1", "3", "5"}))
or ((g_Box.InternalMemEnabled ~= "1") and string_op.in_list(g_Box.FaxMailActiveMode, {"1", "3"}))
or ((g_Box.InternalMemEnabled ~= "1") and (g_Box.IsUsbStorage ~= "1")) then
g_Box.ActivateEMail = "on"
end
if g_Box.InternalMemEnabled == "1" then
if string_op.in_list(g_Box.FaxMailActiveMode, {"4", "5"}) then
g_Box.FaxMailCheckbox = "Intern"
elseif string_op.in_list(g_Box.FaxMailActiveMode, {"2", "3"}) or (g_Box.UsbDiskCount ~= "0") then
g_Box.FaxMailCheckbox = "Usb"
else
g_Box.FaxMailCheckbox = "None"
end
elseif string_op.in_list(g_Box.FaxMailActiveMode, {"2", "3"}) then
g_Box.FaxMailCheckbox = "Usb"
end
g_Box.FaxKennung = fon_nr_config.Query("telcfg:settings/FaxKennung", CapitermInfo)
if fon_nr_config.Query("telcfg:settings/FaxSwitch", CapitermInfo) == "1" then
g_Box.FaxSwitch = "on"
end
if g_Box.IsUsbStorage == "1" then
g_Box.UsbDiskCount = tostring(fon_nr_config.Query("ctlusb:settings/storage-part/count", CapitermInfo))
if (g_Box.UsbDiskCount == nil) then
g_Box.UsbDiskCount = "0"
end
g_Box.UsbDiskName = fon_nr_config.Query("ctlusb:settings/storage-part0", CapitermInfo)
end
g_Box.EMailAdr = fon_nr_config.Query("telcfg:settings/FaxMailAddress", CapitermInfo)
if g_Box.EMailAdr == "" then
g_Box.EMailAdr = fon_nr_config.Query("emailnotify:settings/To", CapitermInfo)
if g_Box.EMailAdr == "" and g_Box.Oem=="1und1" then
local ppUser = fon_nr_config.Query("connection0:settings/username", CapitermInf)
g_Box.EMailAdr = EMailValuesFromPpp(ppUser)
end
end
g_Box.IsMailerConfigured = pushservice.account_configured() and "1" or "0"
g_Box.username = fon_nr_config.Query("emailnotify:settings/accountname", CapitermInfo)
g_Box.use_ssl = fon_nr_config.Query("emailnotify:settings/starttls", CapitermInfo)
g_Box.server, g_Box.port = email_data.split_server(fon_nr_config.Query("emailnotify:settings/SMTPServer", CapitermInfo))
g_Box.port = g_Box.port or email_data.get_default_port("smtp", g_Box.use_ssl == "1")
g_Box.email, g_Box.fboxname = fon_devices_html.extract_addr_name(fon_nr_config.Query("emailnotify:settings/From", CapitermInfo))
g_Box.pass = fon_nr_config.Query("emailnotify:settings/passwd", CapitermInfo)
end
function CheckSide1()
if not string_op.in_list(g_Box.CurrSide, {"AssiFaxInternStartSide", "AssiFaxInternSummary"}) then
return
end
if utf8.len(g_Box.FaxKennung) > g_Const.MaxFaxKennungLen then
g_Alert.FaxKennungLen = general.sprintf(g_Txt.MaxXChar, g_Const.MaxFaxKennungLen)
g_Alert.Side = "AssiFaxInternStartSide"
end
if utf8.len(g_Box.EMailAdr) > g_Const.MaxEMailAdrLen then
g_Alert.EMailAdrLen = general.sprintf(g_Txt.MaxXChar, g_Const.MaxEMailAdrLen)
g_Alert.Side = "AssiFaxInternStartSide"
end
if (g_Box.ActivateEMail == "off") and (g_Box.FaxMailCheckbox == "None") then
g_Alert.FaxTarget = string_op.bool_to_value( g_Box.InternalMemEnabled == "1", g_Txt.FaxTarget.Internal,
g_Txt.FaxTarget.NoInternal
)
g_Alert.Side = "AssiFaxInternStartSide"
end
require("val")
if (g_Box.ActivateEMail == "on") and (not is_valid_email_list(g_Box.EMailAdr)) then
if (g_Box.EMailAdr=="") then
g_Alert.EMailAdr = g_Txt.EMailAdrEmpty
else
g_Alert.EMailAdr = g_Txt.EmailAdrFormat
end
if g_Box.InternalMemEnabled == "1" then
g_Alert.Side = "AssiFaxInternStartSide"
elseif g_Box.IsUsbStorage == "1" then
g_Alert.Side = "AssiFaxInternStartSide"
end
end
end
function GetMailActivMode()
if g_Box.InternalMemEnabled == "1" then
if (g_Box.ActivateEMail == "on") and (g_Box.FaxMailCheckbox == "Intern") then
return "5"
elseif (g_Box.ActivateEMail == "off") and (g_Box.FaxMailCheckbox == "Intern") then
return "4"
elseif (g_Box.ActivateEMail == "on") and (g_Box.FaxMailCheckbox == "Usb") then
return "3"
elseif (g_Box.ActivateEMail == "off") and (g_Box.FaxMailCheckbox == "Usb") then
return "2"
elseif (g_Box.ActivateEMail == "on") and (g_Box.FaxMailCheckbox == "None") then
return "1"
end
return "0"
end
if g_Box.IsUsbStorage ~= "1" then
return "1"
end
if (g_Box.ActivateEMail == "on") and (g_Box.FaxMailCheckbox == "Usb") then
return "3"
elseif (g_Box.ActivateEMail == "off") and (g_Box.FaxMailCheckbox == "Usb") then
return "2"
elseif (g_Box.ActivateEMail == "on") and (g_Box.FaxMailCheckbox ~= "Usb") then
return "1"
end
return "0"
end
function CheckSide2()
if not string_op.in_list(g_Box.CurrSide, {"AssiFaxInternIncoming", "AssiFaxInternSummary"}) then
return
end
if (g_Box.IsTamMode == "0") and (fon_nr_config.NrInfo().UsePstn ~= "1") then
if fon_nr_config.GetCountSelected() < 1 then
g_Alert.NumberMandatory = g_Txt.NumberMandatory
g_Alert.Side = "AssiFaxInternIncoming"
end
end
if (g_Box.FaxSwitch == "on") and (fon_nr_config.PotsElement().IsClicked == "on") then
g_Alert.FaxSwitchAndPots = g_Txt.FaxSwitchAndPots
g_Alert.Side = "AssiFaxInternIncoming"
end
if fon_nr_config.GetCountSelected() == 0 and ((fon_nr_config.PotsElement().Nr == "" and g_Box.IsTamMode ~= "0" and not config.GUI_NEW_FAX) or (fon_nr_config.PotsElement().Nr ~= "")) then
g_Box.FaxSwitch="on"
end
end
function IsAtSipname(Name)
return is_valid_email(Name) == nil
end
function CheckSide4()
if not string_op.in_list(g_Box.CurrSide, {"AssiFaxInternPushMail", "AssiFaxInternSummary"}) then
return
end
if (g_Box.ActivateEMail == "off") or (g_Box.IsMailerConfigured ~= "0") then
return
end
end
function PushValuesToBox(Table)
if g_CapitermEnabled == "T" then
capiterm.txt_nl("PushValuesToBox", g_CapitermInfo)
end
if (box.post["Old_pass"]~=nil) then
box.post["username"]=box.post["Old_username"]
box.post["email"]=box.post["Old_email"]
box.post["server"]=box.post["Old_server"]
box.post["port"]=box.post["Old_port"]
box.post["use_ssl"]=box.post["Old_use_ssl"]
box.post["pass"]=box.post["Old_pass"]
box.post["emailto"]=g_Box.EMailAdr
end
if ((g_Box.IsTamMode ~= 0) or (config.FAX2MAIL == true)) and box.post["pass"]~=nil then
fon_devices_html.save_email_config(Table,g_data)
end
end
function HandleSubmitSave()
if box.post.Submit_Save ~= nil then
if g_CapitermEnabled == "T" then
capiterm.txt_nl("HandleSubmitSave", g_CapitermInfo)
end
local Table = {}
fon_nr_config.ValuesToTable(Table, "telcfg:settings/FaxMSN", "", nil, nil, "NoUseName", "NoSaveOutgoing")
PushValuesToBox(Table)
if string_op.in_list(g_Box.FaxMailActiveMode, {"1", "3", "5"}) then
fon_nr_config.ValuesToTable( Table, "telcfg:settings/FaxMailAddress", "", nil, g_Box.EMailAdr, "NoUseName",
"NoSaveOutgoing",true
)
end
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/FaxMailActive", g_Box.FaxMailActiveMode)
fon_nr_config.Table2BoxAdd(Table, "telcfg:settings/FaxKennung", g_Box.FaxKennung)
fon_nr_config.Table2BoxSend(Table, "telcfg:settings/FaxSwitch", string_op.on_off_to_value(g_Box.FaxSwitch, "1", "0"))
local FinishPage = assi_control.GetDefaultFinishPage(g_Box.FinishPage)
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(FinishPage,params))
end
end
function HandleSubmitTest()
if box.post.test ~= nil then
local Table = {}
PushValuesToBox(Table)
local err, msg = box.set_config(Table)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
assi_control.SetAbsPageInfo("AssiFaxInternMailTest")
end
end
function HandleSubmitBack()
if box.post.Submit_Back ~= nil then
if g_Box.CurrSide == g_SideList.AssiFaxIntern[1] then
local params = {}
assi_control.InsertFromPage(params)
http.redirect(href.get_paramtable(g_Box.Back2Page or g_Box.StartPage,params))
elseif g_Box.CurrSide == "AssiFaxInternPushMail" then
assi_control.SetAbsPageInfo("AssiFaxInternStartSide")
elseif (g_Box.CurrSide == "AssiFaxInternIncoming") and (g_Box.ActivateEMail == "on")
and (g_Box.IsMailerConfigured == "0")
then
assi_control.SetAbsPageInfo("AssiFaxInternPushMail")
else
assi_control.SetNewPage(g_SideList.AssiFaxIntern, -1)
end
return true
end
return false
end
function HandleSubmitNext()
if box.post.Submit_Next ~= nil then
if (g_Box.CurrSide == "AssiFaxInternStartSide") and (g_Box.ActivateEMail == "on") and (g_Box.IsMailerConfigured == "0") then
assi_control.SetAbsPageInfo("AssiFaxInternPushMail")
elseif g_Box.CurrSide == "AssiFaxInternIncoming" then
if fon_nr_config.MessageOnInvalidClicks("NoTamIntern", "ShowMessage", "NoCheckOutgoingNr", "NoConnectAllExist") then
return true
end
assi_control.SetNewPage(g_SideList.AssiFaxIntern, 1)
elseif (g_Box.CurrSide == "AssiFaxInternPushMail") then
assi_control.SetAbsPageInfo("AssiFaxInternIncoming")
else
assi_control.SetNewPage(g_SideList.AssiFaxIntern, 1)
end
return true
end
return false
end
function HandleSubmitTestReady()
if box.post.Submit_TestReady then
assi_control.SetAbsPageInfo("AssiFaxInternPushMail")
return true
end
return false
end
function HandleSubmitRefresh()
if box.post.Submit_Refresh then
end
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
g_Box.FaxMailActiveMode = GetMailActivMode()
fon_nr_config.SaveButton("FaxWeiche", "", "AddFestnetz")
CheckSide2()
CheckSide4()
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
HandleSubmitTest()
HandleSubmitRefresh()
HandleSubmitTestReady()
HandleSubmitSave()
end
function Reloaded()
fon_nr_config.HiddenValuesFromBox(g_Box.CurrSide == "AssiFaxInternIncoming")
SwitchToNextSide()
end
assi_control.Main("F", g_SideList.AssiFaxIntern[1], false)
assi_control.DebugAll()
function Htm2Box(Text)
html_check.tobox(Text)
end
function FaxUsbDiskPath()
if g_Box.IsUsbStorage == "1" then
if (g_Box.UsbDiskCount == nil) or (g_Box.UsbDiskCount == "") or (tonumber(g_Box.UsbDiskCount) == nil or tonumber(g_Box.UsbDiskCount) < 1) then
Htm2Box("<div>")
if g_Box.Aura4Storage ~= nil and g_Box.Aura4Storage == "1" then
Htm2Box( string_op.bool_to_value( g_Box.InternalMemEnabled == "1", g_Txt.FaxAuraAn.Internal,
g_Txt.FaxAuraAn.NoInternal
)
)
else
Htm2Box( string_op.bool_to_value( g_Box.InternalMemEnabled == "1", g_Txt.FaxNoUsb.Internal,
g_Txt.FaxNoUsb.NoInternal
)
)
end
Htm2Box("</div>")
return
end
Htm2Box("<div>")
Htm2Box( [[{?g_txt_FritzFaxBox?}]])
Htm2Box("</div>")
end
end
function Cb_HiddenValues4PushService()
Htm2Box( "</div>")
assi_control.HiddenValues(g_Box.CurrSide)
end
function Multiside_AssiFaxInternStartSide()
Htm2Box("<script type='text/javascript'>")
box.out( "function Cb_Refresh()\n")
box.out( "{\n")
box.out( "DisabledEMail = ! jxl.getChecked('Id_ActivateEMail');\n")
box.out( "jxl.display('Id_AlertFaxTarget', DisabledEMail && jxl.getChecked('Id_FaxMailCheckboxNone'));\n")
box.out( "jxl.setDisabled('Id_EMailAdr', DisabledEMail);\n")
box.out( "jxl.display('Id_AlertEMailAdr', ! DisabledEMail);\n")
box.out( "}\n")
box.out(" function Cb_Submit()\n")
box.out(" {\n")
box.out( "var FaxKennung = jxl.getValue('Id_FaxKennung');\n")
fon_nr_config.BoxAlert("FaxKennung.length > " .. g_Const.MaxFaxKennungLen,
general.sprintf(g_Txt.FaxKennungMaxXChar, g_Const.MaxFaxKennungLen)
)
box.out( "var EMailAdr = jxl.getValue('Id_EMailAdr');\n")
fon_nr_config.BoxAlert( "jxl.getChecked('Id_ActivateEMail') && (EMailAdr.length > "
.. g_Const.MaxEMailAdrLen .. ")",
general.sprintf(g_Txt.EMailAdrMaxXChar, g_Const.MaxEMailAdrLen)
)
box.out( "if (jxl.getChecked('Id_ActivateEMail') && (EMailAdr == ''))\n")
box.out( "{\n")
if g_Box.InternalMemEnabled == "1" then
fon_nr_config.BoxAlert(nil, g_Txt.EMailAdrEmpty)
elseif g_Box.IsUsbStorage == "1" then
fon_nr_config.BoxAlert(nil, g_Txt.EMailAdrEmpty)
end
box.out( "}\n")
fon_nr_config.BoxAlert( "(jxl.getChecked('Id_ActivateEMail') == false) && jxl.getChecked('Id_FaxMailCheckboxNone')",
string_op.bool_to_value( g_Box.InternalMemEnabled == "1",
g_Txt.FaxTarget.Internal, g_Txt.FaxTarget.NoInternal
)
)
box.out( "return true;\n")
box.out(" }\n")
box.out( "ready.onReady(Cb_Refresh);\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?804:514?}]])
Htm2Box( "</p>")
Htm2Box( "<div>")
assi_control.InputField( "LabelInput", "text", "FaxKennung", nil,
[[{?g_txt_FaxKennung?}]],
g_Const.MaxFaxKennungLen, g_Const.MaxFaxKennungLen, g_Box.FaxKennung, "",
"", ""
)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertFaxKennungLen", g_Alert.FaxKennungLen)
Htm2Box( "</div>")
Htm2Box( "<p>")
if g_Box.InternalMemEnabled == "1" then
Htm2Box( [[{?804:608?}]])
else
if g_Box.IsUsbStorage == "1" then
Htm2Box([[{?804:970?}]])
else
Htm2Box([[{?804:141?}]])
end
end
Htm2Box( "</p>")
Htm2Box( "<div>")
local is_disabled=[[]]
if (g_Box.InternalMemEnabled ~= "1" and g_Box.IsUsbStorage ~= "1") then
is_disabled=string_op.txt_disabled(true)
end
assi_control.InputField( "InputLabel", "checkbox", "ActivateEMail", nil,
[[{?804:447?}]], nil, nil,
nil, string_op.txt_checked(g_Box.ActivateEMail == "on")..is_disabled, "Cb_Refresh()", ""
)
Htm2Box( "</div>")
Htm2Box( "<div>")
Htm2Box( "<div>")
assi_control.InputField( "LabelInput", "text", "EMailAdr", nil,
[[{?804:367?}]],
g_Const.SizeEMailAdrLen, g_Const.MaxEMailAdrLen, g_Box.EMailAdr, "", "", ""
)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertEMailAdrLen", g_Alert.EMailAdrLen)
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertEMailAdr", g_Alert.EMailAdr)
Htm2Box( "</div>")
Htm2Box( "</div>")
if g_Box.InternalMemEnabled == "1" or g_Box.IsUsbStorage == "1" then
Htm2Box("<div>")
Htm2Box( "<p>")
Htm2Box( [[{?804:27?}]])
Htm2Box( "</p>")
Htm2Box( "<div>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertFaxTarget", g_Alert.FaxTarget)
Htm2Box( "<p>")
assi_control.InputField( "InputLabel", "radio", "FaxMailCheckbox", "++None",
g_Txt.NichtAblegen, nil, nil, "None",
string_op.txt_checked(g_Box.FaxMailCheckbox == "None"),
"Cb_Refresh()", ""
)
Htm2Box( "</p>")
if config.NAND then
Htm2Box( "<p>")
assi_control.InputField( "InputLabel", "radio", "FaxMailCheckbox", "++Intern",
g_Txt.InternAblegen, nil, nil, "Intern",
string_op.txt_checked(g_Box.FaxMailCheckbox == "Intern"),
"Cb_Refresh()", ""
)
end
Htm2Box( "</p>")
local SetEnabled = string_op.in_list(g_Box.FaxMailActiveMode, {"2", "3"})
or (g_Box.UsbDiskCount ~= "0")
Htm2Box("<p>")
local label_class = ""
if not SetEnabled then
label_class = [[ class="disabled"]]
end
assi_control.InputField( "InputLabel", "radio", "FaxMailCheckbox", "++Usb",
g_Txt.AufDemUsbSpeicherAblegen, nil, nil, "Usb",
string_op.txt_disabled(not SetEnabled)
.. string_op.txt_checked(g_Box.FaxMailCheckbox == "Usb"),
"Cb_Refresh()", label_class
)
Htm2Box("</p>")
FaxUsbDiskPath()
Htm2Box( "</div>")
Htm2Box("</div>")
else
Htm2Box("<div>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_AlertFaxTarget", g_Alert.FaxTarget)
if (g_Box.IsUsbStorage == "1") and (g_Box.UsbDiskCount ~= "0") then
assi_control.InputField( "InputLabel", "checkbox", "FaxMailCheckbox", nil,
g_Txt.AufDemUsbSpeicherAblegen, nil, nil, "Usb",
string_op.txt_checked(g_Box.FaxMailCheckbox == "Usb"), "", ""
)
end
FaxUsbDiskPath()
Htm2Box("</div>")
end
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, " onclick='return Cb_Submit();'", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiFaxInternIncoming()
Htm2Box("<script type='text/javascript'>")
box.out( "function Cb_Refresh()\n")
box.out( "{\n")
if config.FAXSUPPORT then
SipIndex = fon_nr_config.GetIndexByNr("Sip", fon_nr_config.PotsElement().Nr)
box.out("if (jxl.getChecked('Id_FaxSwitch'))\n")
box.out("{\n")
local HakenPraefix = fon_nr_config.GetHakenPraefix()
box.out( "jxl.disable('" .. HakenPraefix .. "Pots0');\n")
box.out( "jxl.setChecked('" .. HakenPraefix .. "Pots0', false);\n")
if SipIndex ~= -1 then
box.out( "jxl.disable('" .. HakenPraefix .. "Sip"
.. fon_nr_config.NrInfo().All[SipIndex].LfNr .. "');\n"
)
box.out( "jxl.setChecked('" .. HakenPraefix .. "Sip"
.. fon_nr_config.NrInfo().All[SipIndex].LfNr .. "', false);\n"
)
end
box.out( "return;\n")
box.out("}\n")
box.out("jxl.enable('" .. HakenPraefix .. "Pots0');\n")
if SipIndex ~= -1 then
box.out( "jxl.enable('" .. HakenPraefix .. "Sip" .. fon_nr_config.NrInfo().All[SipIndex].LfNr
.. "');\n"
)
end
end
box.out( "}\n")
box.out( "ready.onReady(Cb_Refresh);\n")
Htm2Box("</script>")
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
if fon_nr_config.PotsElement().Nr == "" then
Htm2Box("<div id='Id_FaxSwitchNoPots'>")
if config.GUI_NEW_FAX then
Htm2Box( [[{?804:797?}]])
else
Htm2Box( [[{?804:119?}]])
end
if g_Box.IsTamMode ~= "0" and not config.GUI_NEW_FAX then
Htm2Box("<p>")
Htm2Box([[{?804:597?}]])
Htm2Box("</p>")
end
Htm2Box("</div>")
else
Htm2Box("<div id='Id_FaxSwitchPots'>")
if config.FAXSUPPORT then
Htm2Box( "<p>")
Htm2Box( [[{?804:576?}]])
Htm2Box( "</p>")
Htm2Box( "<p>")
assi_control.InputField( "InputLabel", "checkbox", "FaxSwitch", nil,
general.sprintf( g_Txt.AutomaticFaxForNr,
fon_nr_config.PotsElement().Nr
), nil, nil, nil,
string_op.txt_checked(g_Box.FaxSwitch == "on"),
"Cb_Refresh()", ""
)
Htm2Box( "</p>")
end
Htm2Box( "<p>")
Htm2Box( [[{?804:47?}]])
Htm2Box( "</p>")
Htm2Box( "<p>")
if config.GUI_NEW_FAX then
Htm2Box( [[{?804:562?}]])
else
Htm2Box( [[{?804:189?}]])
end
Htm2Box( "</p>")
Htm2Box("</div>")
end
fon_nr_config.BoxOutErrorLines("ClassAlert", {Id_AlertNumberMandatory = g_Alert.NumberMandatory})
Htm2Box( "<table class='ClassNumberSelectListTable'>")
local OutgoingNr = ""
fon_nr_config.BoxOutHtmlCode_IncomingNr( "AssiIn", OutgoingNr, "CheckBoxen", "CheckClicked",
"DefNrClassIds", "Label", 'fon_nr_config_OnClickNr("", id)',
0
)
Htm2Box( "</table>")
fon_nr_config.BoxOutErrorLine("ClassAlert", "Id_FaxSwitchAndPots", g_Alert.FaxSwitchAndPots)
Htm2Box("</div>")
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, "", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
end
function Multiside_AssiFaxInternSummary()
Htm2Box("<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
Htm2Box( "<p>")
Htm2Box( [[{?804:261?}]])
Htm2Box( "</p>")
Htm2Box( "<table class='ClassSummaryListTable zebra'>")
Htm2Box( "<tr class='ClassSummaryTableLine1'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( [[{?g_txt_Telefoniegeraet?}]])
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
Htm2Box( [[{?804:790?}]])
Htm2Box( "</td>")
Htm2Box( "</tr>")
Htm2Box( "<tr class='ClassSummaryTableLine2'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( [[{?g_txt_FaxKennung?}]])
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
Htm2Box(g_Box.FaxKennung)
Htm2Box( "</td>")
Htm2Box( "</tr>")
Htm2Box( "<tr class='ClassSummaryTableLine1'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( [[{?804:617?}]])
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
Htm2Box(g_Txt.NeinJa[g_Box.ActivateEMail])
Htm2Box( "</td>")
Htm2Box( "</tr>")
if g_Box.InternalMemEnabled == "1" or g_Box.IsUsbStorage == "1" then
Htm2Box( "<tr class='ClassSummaryTableLine2'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( [[{?804:592?}]])
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
if g_Box.FaxMailCheckbox == "None" then
Htm2Box(g_Txt.NichtAblegen)
elseif g_Box.FaxMailCheckbox == "Intern" and config.NAND then
Htm2Box(g_Txt.InternAblegen)
elseif g_Box.FaxMailCheckbox == "Usb" then
Htm2Box(g_Txt.AufDemUsbSpeicherAblegen)
end
Htm2Box( "</td>")
Htm2Box( "</tr>")
end
Htm2Box( "<tr class='ClassSummaryTableLine1'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( [[{?g_txt_NrForIncomingFax?}]])
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
fon_nr_config.BoxOutHtmlCode_SummaryIncomingNr("AssiIn", "ClassSummaryTableColRight1")
Htm2Box( "</td>")
Htm2Box( "</tr>")
if config.FAXSUPPORT then
Htm2Box("<tr class='ClassSummaryTableLine2'>")
Htm2Box( "<td class='ClassSummaryTableLeft'>")
Htm2Box( [[{?804:228?}]])
Htm2Box( "</td>")
Htm2Box( "<td class='ClassSummaryTableRight'>")
Htm2Box(g_Txt.NeinJa[g_Box.FaxSwitch])
Htm2Box( "</td>")
Htm2Box("</tr>")
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
function Multiside_AssiFaxInternPushMail()
--if fon_devices_html.is_mailer_configured() then
-- return
--end
g_data.email, g_data.fboxname = fon_devices_html.extract_addr_name(box.query("emailnotify:settings/From"))
g_data.last_mail = g_data.email
g_data.pass = box.query("emailnotify:settings/passwd")
g_data.user = box.query("emailnotify:settings/accountname")
g_data.pppuser = box.query("connection0:settings/username")
g_data.is_tonline = email_data.is_tonline_account(box.query("connection0:settings/username"))
local ssl = box.query("emailnotify:settings/starttls") == "1"
g_data.use_ssl = ssl and "checked" or ""
g_data.server, g_data.port = email_data.split_server(box.query("emailnotify:settings/SMTPServer"))
g_data.port = g_data.port or email_data.get_default_port("smtp", ssl)
if g_Box.pass and g_Box.pass~="" and g_Box.pass~="****" then
g_data.pass=g_Box.pass
end
if g_Box.EMailAdr and g_Box.EMailAdr~="" then
g_data.email=g_Box.EMailAdr
local t=string_op.split2table(g_Box.EMailAdr,",",0)
if t and t[1]~="" then
g_data.email=t[1]
end
end
if g_Box.username and g_Box.username~="" then
g_data.user=g_Box.username
end
if g_Box.server and g_Box.server~="" then
g_data.server=g_Box.server
end
if g_Box.port and g_Box.port~="" then
g_data.port=g_Box.port
end
if g_Box.use_ssl and g_Box.use_ssl~="" then
ssl=g_Box.use_ssl=="on"
end
g_data.use_ssl=""
if (ssl) then
g_data.use_ssl ="checked"
end
box.out([[<script type="text/javascript" src="/js/validate.js"></script>]])
box.out(fon_devices_html.get_email_config_js_include())
box.out([[<script type="text/javascript">
var g_testclicked=false;]])
val.write_js_error_strings()
box.out(fon_devices_html.get_email_config_js(g_data))
box.out([[
function Cb_Submit()
{
]])
val.write_js_checks(g_val)
box.out([[
if (g_testclicked)
return true;
if (jxl.get("uiViewEmailConfig"))
{
return check();
}
return true;
}
function Cb_Abort()
{
return true;
}
function uiDoOnActivateChecked()
{
}
</script>
]])
box.out(fon_devices_html.get_email_config_html(g_data))
assi_control.CreateButton("Back", g_Txt.Zurueck, "", "S")
assi_control.CreateButton("@Next", g_Txt.Weiter, " onclick='g_testclicked=false;'", "")
assi_control.CreateButton("cancel", g_Txt.Abbrechen, "", "E")
box.out([[
<script type="text/javascript">
init_email();
ready.onReady(val.init(Cb_Submit, "Submit_Next", "main_form" ));
</script>
]])
end
function Multiside_AssiFaxInternMailTest()
Htm2Box("<link rel='stylesheet' type='text/css' href='/css/default/static.css'>")
Htm2Box("<script type='text/javascript' src='/js/ajax.js'>")
Htm2Box("</script>")
Htm2Box("<script type='text/javascript'>")
push_check_html.get_javascripts()
Htm2Box("</script>")
Htm2Box( "<div id='Seite" .. g_Box.CurrSide .. "' class='formular'>")
push_check_html.get_html( "Submit_Refresh", "Submit_TestReady", Cb_HiddenValues4PushService,
"hilfe_faxmail_test.html"
)
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
Htm2Box([[<form id="main_form" method='POST' action=']] .. box.glob.script .. "'>")
assi_control.LoadHtmlSide()
assi_control.AddHiddenSID()
assi_control.HiddenValues(g_Box.CurrSide)
assi_control.AddOtherHiddenInputs()
if ((g_Box.InternalMemEnabled ~= "1") and (g_Box.IsUsbStorage ~= "1")) then
box.out([[<input type="hidden" name="New_ActivateEMail" value="on">]])
end
Htm2Box("</form>")
fon_nr_config.JavaScriptCb_NrHandling(g_Box.CurrSide == "AssiFaxInternIncoming", false, false, g_Box.WorkAs,false)
html_check.debug()
?>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
