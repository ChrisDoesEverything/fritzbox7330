--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall)
require"isp"
require"textdb"
require"html"
require"general"
require"config"
require"utf8"
require"country"
function create_provider(master_table, provider_table)
for key, value in pairs(master_table) do
if provider_table[key] == nil then
provider_table[key] = value
end
end
if not provider_table.userInterface then
provider_table.userInterface = {}
end
for key, value in pairs(master_table.userInterface) do
if provider_table.userInterface[key] == nil then
provider_table.userInterface[key] = value
end
end
if not provider_table.dataValues then
provider_table.dataValues = {}
end
for key, value in pairs(master_table.dataValues) do
if provider_table.dataValues[key] == nil then
provider_table.dataValues[key] = value
end
end
if not provider_table.dataValues.telcfg then
provider_table.dataValues.telcfg = {}
end
for key, value in pairs(master_table.dataValues.telcfg) do
if provider_table.dataValues.telcfg[key] == nil then
provider_table.dataValues.telcfg[key] = value
end
end
if not provider_table.dataValues.details then
provider_table.dataValues.details = {}
end
for key, value in pairs(master_table.dataValues.details) do
if provider_table.dataValues.details[key] == nil then
provider_table.dataValues.details[key] = value
end
end
return provider_table
end
function create_display(list_visibil_display)
returnlist = {}
local display_elements = {ShowProvider = false, ShowUsername = false, ShowSecondInput = false, ShowPassword = false, ShowRegistrar = false,
ShowProxy = false, ShowProxy = false, ShowStun = false, ShowExp = false, ShowEmergency = false, ShowSipAKN = false, ShowAlternatePrefix_USA = false,
ShowUseinternatcallingnumbe = false, ShowSuffixBlock = false, ShowPerformanceTip = false, ShowDtmf = false, ShowClir = false, ShowDditype = false,
ShowSipUri= false, ShowTrunk= false, ShowG726NACHRFC3551= false, ShowCCBS= false, ShowOverInternet= false, ShowOKZ= false, ShowSpit= false, ShowTComLinks= false, ShowTOnlineHint = false, ShowIp = false}
for keys, value in pairs(display_elements) do
if list_visibil_display[keys] then
if keys == "ShowOKZ" then
returnlist[keys] = country.is_okz_in_country(config.country)
else
returnlist[keys] = true
end
else
returnlist[keys] = false
end
end
return returnlist
end
function is_germany()
return (box.query("box:settings/country")=="049")
end
function is_international()
return config.sip_provider_international
end
function is_default()
if config.sip_provider_international and config.country ~= '049' then
return false
end
return true
end
function is_austria()
return config.country == '043' and config.sip_provider_international
end
function is_swiss()
return config.country == '041' and config.sip_provider_international
end
function is_spain()
return config.country == '034' and config.sip_provider_international
end
function is_netherlands()
return config.country == '031' and config.sip_provider_international
end
function is_luxembourg()
return config.country == '0352' and config.sip_provider_international
end
function is_kdg()
return config.oem == 'kdg'
end
function is_congstar()
return isp.is("congstar")
end
function is_beta()
if config.gu_type == 'beta' then
return true
end
return false
end
local str_1 = TXT([[{?3291:674?}]])
local str_2 = TXT([[{?3291:656?}]])
local str_3 = TXT([[{?3291:237?}]])
local str_4 = TXT([[{?3291:842?}]])
local str_5 = TXT([[{?3291:646?}]])
local str_6 = TXT([[{?3291:752?}]])
local str_7 = TXT([[{?3291:335?}]])
local str_8 = TXT([[{?3291:734?}]])
local str_9 = TXT([[{?3291:200?}]])
local str_10 = TXT([[{?3291:779?}]])
local str_11 = TXT([[{?3291:930?}]])
local str_12 = TXT([[{?3291:93?}]])
local str_13 = TXT([[{?3291:0?}]])
local str_14 = TXT([[{?3291:594?}]])
local str_15 = TXT([[{?3291:852?}]])
local str_16 = TXT([[{?3291:715?}]])
local str_17 = TXT([[{?3291:653?}]])
local str_18 = TXT([[{?3291:636?}]])
local str_19 = TXT([[{?3291:719?}]])
local str_20 = TXT([[{?3291:577?}]])
local str_21 = TXT([[{?3291:152?}]])
local str_22 = TXT([[{?3291:287?}]])
local str_23 = TXT([[{?3291:936?}]])
local str_24 = TXT([[{?3291:77?}]])
local str_25 = TXT([[{?3291:645?}]])
local str_26 = TXT([[{?3291:363?}]])
local str_27 = TXT([[{?3291:918?}]])
local str_28 = TXT([[{?3291:838?}]])
local data = setmetatable({}, {
__index = function(self, param) return self.other end
})
data.other = {
active = true,
name = TXT([[{?3291:130?}]]),
id = [[other]],
mode = "normal",
userInterface = {
uiNumberTitle1 = [[]],
uiNumberTitle2 = [[]],
uiNumberLabel = str_25,
uiNumberFirstSpan = [[]],
uiNumberMiddleSpan = [[]],
uiNumberFooder = [[]],
uiNumberTitle1_trunk = [[]],
uiNumberTitle2_trunk = [[]],
uiNumberLabel_trunk = str_25,
uiLabelUsername = str_26,
uiLabelPwd = str_27,
uiUserprefix = [[]]
},
dataValues = {
details = {
registrar = {[[]]},
outboundproxy = [[]],
stunserver = [[]],
dtmfcfg = [[0]],
clirtype = [[1]],
dditype = [[0]],
use_seperate_vcc = [[]],
VCI = [[]],
encapsulation = [[]],
multi_pdn = [[]],
apn1 = [[]],
ccbs_supported = [[0]],
g726_via_3551rfc = [[0]],
only_call_from_registrar = [[0]],
outboundproxy_without_route_header = [[0]],
read_p_asserted_identity_header = [[1]],
authname_needed = [[0]],
mwi_supported = [[1]],
use_internat_calling_numb = [[0]],
route_always_over_internet = config.LTE and [[1]] or [[1]],
clipnstype = [[0]],
protocolprefer = [[0]],
def_user = [[]],
username = [[]]
},
telcfg = {
AKN = [[1]],
EmergencyRule = [[1]],
RegistryType = [[other]],
UseLKZ = [[0]],
KeepOKZPrefix = [[1]],
KeepLKZPrefix = [[1]],
Suffix = [[]],
AlternatePrefix = [[]]
}
}
}
if country.is_okz_in_country(config.country) then
data.other.dataValues.telcfg.UseOKZ = [[1]]
else
data.other.dataValues.telcfg.UseOKZ = [[0]]
end
if config.sip_packetsize then
data.other.dataValues.details.tx_packetsize_in_ms = [[20]]
else
data.other.dataValues.details.tx_packetsize_in_ms = [[30]]
end
if general.is_assi() then
data.other.display = create_display(array.truth({'ShowProvider','ShowUsername','ShowPassword','ShowRegistrar', 'ShowOKZ','ShowProxy','ShowDtmf','ShowOverInternet','ShowNormalTip'}))
elseif (not general.inet_over_dsl()) then
data.other.display = create_display(array.truth({'ShowProvider','ShowUsername','ShowPassword','ShowRegistrar','ShowProxy','ShowSipUri','ShowEmergency','ShowSipAKN','ShowDtmf','ShowClir','ShowOverInternet','ShowExp','ShowAlternatePrefix_USA','ShowSuffixBlock','ShowG726NACHRFC3551','ShowCCBS','ShowIp','ShowDditype','ShowUseinternatcallingnumbe', 'ShowStun','ShowNormalTip', 'ShowPerformanceTip'}))
else
data.other.display = create_display(array.truth({'ShowProvider','ShowUsername','ShowPassword','ShowRegistrar','ShowProxy','ShowSipUri','ShowEmergency','ShowSipAKN','ShowDtmf','ShowClir','ShowOverInternet','ShowExp','ShowAlternatePrefix_USA','ShowSuffixBlock','ShowG726NACHRFC3551','ShowCCBS','ShowIp','ShowDditype','ShowUseinternatcallingnumbe', 'ShowNormalTip', 'ShowPerformanceTip'}))
end
data.directdialintrunk = {
name = TXT([[{?3291:998?}]]),
id = [[directdialintrunk]],
active = true,
mode = "directdialin",
userInterface = {
uiNumberLabel_trunk = str_28,
uiNumberLabel = str_28,
uiLabelUsername = str_26,
uiLabelPwd = str_27
},
dataValues = {
details = {
registrar = {[[]]}
}
},
display = create_display(array.truth({'ShowProvider','ShowDirectDialIn','ShowUsername','ShowPassword','ShowRegistrar','ShowProxy','ShowSipUri','ShowEmergency','ShowSipAKN','ShowDtmf','ShowClir','ShowOverInternet','ShowExp','ShowAlternatePrefix_USA','ShowSuffixBlock','ShowG726NACHRFC3551','ShowCCBS','ShowIp','ShowDditype','ShowUseinternatcallingnumbe', 'ShowStun','ShowNormalTip', 'ShowPerformanceTip'}))
}
data.directdialintrunk = create_provider(data.other, data.directdialintrunk)
data.sipnormaltrunk = {
name = TXT([[{?3291:441?}]]),
id = [[sipnormaltrunk]],
active = true,
mode = "differenttrunk",
userInterface = {
uiLabelUsername = str_26,
uiLabelPwd = str_27
},
dataValues = {
details = {
registrar = {[[]]}
}
},
display = create_display(array.truth({'ShowProvider','ShowUsername','ShowPassword','ShowRegistrar','ShowProxy','ShowSipUri','ShowEmergency','ShowSipAKN','ShowDtmf','ShowClir','ShowOverInternet','ShowExp','ShowAlternatePrefix_USA','ShowSuffixBlock','ShowG726NACHRFC3551','ShowCCBS','ShowIp','ShowDditype','ShowUseinternatcallingnumbe', 'ShowStun','ShowNormalTip', 'ShowPerformanceTip'}))
}
data.sipnormaltrunk = create_provider(data.other, data.sipnormaltrunk)
data["1und1"] = {
name = [[1&1 Internet]],
id = [[1und1]],
active = is_default(),
userInterface = {
uiNumberTitle1 = str_2,
uiNumberTitle2 = str_4,
uiNumberLabel = str_1,
uiLabelPwd = str_13
},
dataValues = {
details = {
registrar = {[[1und1.de]],[[sip.1und1.de]]},
stunserver = [[1und1.de]],
dtmfcfg = [[2]],
clirtype = [[1]],
ccbs_supported = [[1]],
route_always_over_internet = [[0]]
},
telcfg = {
RegistryType = [[1und1]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowSecondInput','ShowPassword','ShowIp','ShowOverInternet','SowPerformanceTip'}))
}
data["1und1"] = create_provider(data.other, data["1und1"])
data.a1 = {
name = [[A1 over IP]],
id = [[a1]],
active = is_austria(),
userInterface = {
uiNumberLabel = str_9,
uiLabelUsername = str_14,
uiLabelPwd = str_15
},
dataValues = {
details = {
registrar = {[[a1.net]]},
outboundproxy = [[sip.a1.net]],
dtmfcfg = [[3]]
}
},
display = create_display(array.truth({'ShowProvider','ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.a1= create_provider(data.other, data.a1)
data.congstar = {
name = [[congstar (tel2)]],
id = [[congstar]],
active = (is_congstar() or (is_international() and is_germany())),
userInterface = {
uiNumberLabel = str_1,
uiLabelUsername = str_16,
uiLabelPwd = str_17
},
dataValues = {
details = {
registrar = {[[tel2.congstar.de]]}
}
},
display = create_display(array.truth({'ShowProvider','ShowUsername','ShowExp','ShowPassword','ShowIp','ShowOverInternet','ShowSuffixBlock','ShowNormalTip', 'ShowPerformanceTip'}))
}
data.congstar = create_provider(data.other, data.congstar)
data.congstar2 = {
name = [[congstar (tel)]],
id = [[congstar2]],
active = (is_congstar() or (is_international() and is_germany())),
userInterface = {
uiNumberLabel = str_1,
uiLabelUsername = str_16,
uiLabelPwd = str_17
},
dataValues = {
details = {
registrar = {[[tel.congstar.de]]}
}
},
display = create_display(array.truth({'ShowProvider','ShowUsername','ShowExp','ShowPassword','ShowIp','ShowOverInternet','ShowSuffixBlock','ShowNormalTip', 'ShowPerformanceTip'}))
}
data.congstar2 = create_provider(data.other, data.congstar2)
data.dus = {
name = [[DUS.net]],
id = [[dus]],
active = is_default(),
userInterface = {
uiNumberLabel = str_3,
uiLabelUsername = str_18,
uiUserprefix = [[000387]]
},
dataValues = {
details = {
registrar = {[[proxy.dus.net]]},
stunserver = [[stun.dus.net:3478]],
dtmfcfg = [[2]]
}
},
display = create_display(array.truth({'ShowProvider','ShowUsername','ShowExp','ShowPassword','ShowIp','ShowOverInternet','ShowSuffixBlock','ShowG726NACHRFC3551','ShowNormalTip','ShowPerformanceTip'}))
}
data.dus = create_provider(data.other, data.dus)
data.gmx = {
name = [[GMX]],
id = [[gmx]],
active = is_default(),
userInterface = {
uiNumberTitle1 = str_2,
uiNumberTitle2 = str_4,
uiNumberLabel = str_1,
uiLabelPwd = str_13
},
dataValues = {
details = {
registrar = {[[gmx.de]],[[sip-gmx.net]]},
stunserver = [[gmx.net]],
dtmfcfg = [[2]],
clirtype = [[5]],
ccbs_supported = [[1]],
route_always_over_internet = [[0]]
},
telcfg = {
RegistryType = [[gmx]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowSecondInput','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.gmx = create_provider(data.other, data.gmx)
data.inode = {
name = [[Inode / UPC]],
id = [[inode]],
active = (is_austria()),
dataValues = {
details = {
registrar = {[[voip.inode.at]],[[osvoip.upc.at]]},
outboundproxy = [[voip.inode.at]]
}
},
userInterface = {
uiNumberLabel = str_25
},
display = create_display(array.truth({'ShowProvider','ShowUsername','ShowPassword','ShowOverInternet','ShowExp', 'ShowIp','ShowSuffixBlock','ShowPerformanceTip'}))
}
data.inode = create_provider(data.other, data.inode)
data.inodeisdn = table.clone(data.other)
data.inodeisdn = {
name = [[Inode (ISDN)]],
id = [[inodeisdn]],
active = (config.ISDN and config.ANNEX == 'A' and is_international() and is_austria()),
display = create_display(array.truth({'ShowProvider','ShowPassword','ShowRegistrar','ShowProxy','ShowSipUri','ShowEmergency','ShowSipAKN','ShowDtmf','ShowClir','ShowOverInternet','ShowExp','ShowAlternatePrefix_USA','ShowG726NACHRFC3551','ShowCCBS','ShowIp','ShowSuffixBlock','ShowNormalTip','ShowPerformanceTip'}))
}
data.inodeisdn = create_provider(data.other, data.inodeisdn)
data.kdg = {
name = [[Kabel Deutschland]],
id = [[kdg]],
active = (is_beta() or string.find(box.query("tr069:settings/url"),[[kabel-deutschland]],1,true) or (is_international() and is_germany())),
userInterface = {
uiNumberLabel = str_4,
},
dataValues = {
details = {
registrar = {[[kabelphone.de]]},
dtmfcfg = [[3]],
clirtype = [[4]],
mwi_supported = [[0]]
},
telcfg = {
EmergencyRule = [[0]],
AKN = [[0]]
}
},
display = create_display(array.truth({'ShowProvider','ShowRegistrar','ShowProxy','ShowPassword','ShowIp','ShowOverInternet', 'ShowPerformanceTip'}))
}
data.kdg = create_provider(data.other, data.kdg)
data.personal = {
name = [[Personal-VoIP]],
id = [[personal]],
active = is_default(),
userInterface = {
uiNumberLabel = str_4,
},
dataValues = {
details = {
registrar = {[[sip.personal-voip.de]]},
stunserver = [[stun.personal-voip.de]]
},
telcfg = {
EmergencyRule = [[0]],
AKN = [[0]]
}
},
display = create_display(array.truth({'ShowProvider','ShowPassword','ShowIp','ShowOverInternet','ShowExp','ShowSuffixBlock','ShowNormalTip','ShowPerformanceTip'}))
}
data.personal = create_provider(data.other, data.personal)
data.qsc = {
name = [[QSC / Q-DSL home]],
id = [[qsc]],
active = is_default(),
userInterface = {
uiNumberTitle1 = str_5,
uiNumberLabel = str_4,
uiNumberMiddleSpan = [[-]],
uiNumberFooder = str_6
},
dataValues = {
details = {
registrar = {[[sip.qsc.de]]},
dtmfcfg = [[2]]
},
telcfg = {
UseOKZ = [[1]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowSecondInput','ShowPassword','ShowIp','ShowOverInternet','ShowOKZ','ShowNormalTip','ShowPerformanceTip'}))
}
data.qsc = create_provider(data.other, data.qsc)
data.scarlet = {
name = [[Scarlet]],
id = [[scarlet]],
active = (is_international() and is_netherlands()),
ShowOKZEver = true,
dataValues = {
details = {
registrar = {[[scarlet-voice.nl]]}
}
},
userInterface = {
uiNumberLabel = str_25
},
display = create_display(array.truth({'ShowProvider','ShowPassword', 'ShowOverInternet', 'ShowExp','ShowIp','ShowPerformanceTip'}))
}
data.scarlet = create_provider(data.other, data.scarlet)
data.sipgate = {
name = [[sipgate]],
id = [[sipgate]],
active = is_default(),
userInterface = {
uiNumberLabel = str_7,
uiLabelUsername = str_22,
uiLabelPwd = str_23
},
dataValues = {
details = {
registrar = {[[sipgate.de]]},
stunserver = [[stun.sipgate.net:10000]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.sipgate = create_provider(data.other, data.sipgate)
data.sipgateteam = {
name = [[sipgate team]],
id = [[sipgateteam]],
active = is_default(),
userInterface = {
uiNumberLabel = str_7,
uiLabelUsername = str_22,
uiLabelPwd = str_23
},
dataValues = {
details = {
registrar = {[[sipgate.de]]},
outboundproxy = [[proxy.live.sipgate.de]],
stunserver = [[stun.sipgate.net:10000]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.sipgateteam = create_provider(data.other, data.sipgateteam)
data.sipkom = {
name = [[sipkom]],
id = [[sipkom]],
active = is_default(),
userInterface = {
uiNumberFirstSpan = [[49]],
uiLabelPwd = str_24
},
dataValues = {
details = {
registrar = {[[sipkom.com]]},
stunserver = [[stun.sipkom.com]],
dtmfcfg = [[2]],
g726_via_3551rfc = [[1]],
mwi_supported = [[0]],
authname_needed = [[1]]
},
telcfg = {
EmergencyRule = [[1]],
UseOKZ = [[1]],
UseLKZ = [[0]],
KeepOKZPrefix = [[1]],
KeepLKZPrefix = [[0]]
}
},
display = create_display(array.truth({'ShowProvider','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.sipkom = create_provider(data.other, data.sipkom)
data.solomo = {
name = [[solomo]],
id = [[solomo]],
active = is_default(),
dataValues = {
details = {
registrar = {[[voip.solomo.de]]}
},
telcfg = {
EmergencyRule = [[0]],
AKN = [[1]]
}
}
}
if (not general.inet_over_dsl) then
data.solomo.display = create_display(array.truth({'ShowProvider','ShowUsername','ShowExp','ShowPassword','ShowIp','ShowOverInternet', 'ShowStun','ShowPerformanceTip'}))
else
data.solomo.display = create_display(array.truth({'ShowProvider','ShowUsername','ShowExp','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
end
data.solomo = create_provider(data.other, data.solomo)
data.tonline = {
name = [[Telekom]],
id = [[tonline]],
active = is_default(),
userInterface = {
uiNumberTitle1 = str_2,
uiNumberTitle2 = str_4,
uiNumberLabel = str_8,
uiLabelUsername = str_19,
uiLabelPwd = str_20
},
dataValues = {
details = {
def_user = [[anonymous@t-online.de]],
registrar = {[[tel.t-online.de]]},
stunserver = [[stun.t-online.de]],
},
telcfg = {
KeepLKZPrefix = [[0]],
RegistryType = [[tonline]]
}
},
display = create_display(array.truth({'ShowProvider','ShowUsername', 'ShowSecondInput','ShowPassword','ShowIp','ShowTComLinks','ShowTOnlineHint', 'ShowTelecomTip'}))
}
data.tonline = create_provider(data.other, data.tonline)
data.unitymedia = {
name = [[Unitymedia]],
id = [[unitymedia]],
active = is_default(),
userInterface = {
uiNumberLabel = str_4
},
callnumberformat = false,
dataValues = {
details = {
registrar = {[[telefon.unitymedia.de]]},
dtmfcfg = [[3]],
clirtype = [[4]]
}
},
display = create_display(array.truth({'ShowProvider','ShowUsername','ShowExp','ShowPassword','ShowIp','ShowOverInternet','ShowRegistrar','ShowEmergency','ShowSipAKN','ShowOverInternet','ShowNormalTip', 'ShowPerformanceTip'}))
}
data.unitymedia = create_provider(data.other, data.unitymedia)
data.ventengo = {
name = [[Ventengo]],
id = [[ventengo]],
active = is_default(),
dataValues = {
details = {
registrar = {[[sip.ventengo.de]]},
stunserver = [[stun.ventengo.de]],
authname_needed = [[1]]
},
telcfg = {
AKN = [[0]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.ventengo = create_provider(data.other, data.ventengo)
data.arcor = {
name = [[Vodafone / Arcor]],
id = [[arcor]],
active = (not config.LTE and is_default()),
userInterface = {
uiNumberTitle1 = str_5,
uiNumberLabel = str_4,
uiNumberMiddleSpan = [[-]],
uiNumberFooder = str_6,
uiLabelPwd = str_21
},
dataValues = {
details = {
registrar = {[[arcor.de]]},
outboundproxy = [[sip.arcor.de]],
dtmfcfg = [[2]],
clirtype = [[4]]
}
}
}
if (not general.inet_over_dsl()) then
data.arcor.display = create_display(array.truth({'ShowProvider', 'ShowSecondInput','ShowPassword','ShowIp','ShowOverInternet', 'ShowStun','ShowPerformanceTip'}))
else
data.arcor.display = create_display(array.truth({'ShowProvider','ShowSecondInput','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
end
data.arcor = create_provider(data.other, data.arcor)
data.vodafone_lte = {
name = [[Vodafone]],
id = [[vodafone_lte]],
active = (config.LTE and not(is_international() and is_germany())),
userInterface = {
uiNumberTitle1 = str_5,
uiNumberLabel = str_4,
uiNumberMiddleSpan = [[-]],
uiNumberFooder = str_6,
uiLabelPwd = str_21
},
dataValues = {
details = {
clirtype = [[4]],
dtmfcfg = [[2]],
use_seperate_vcc = [[1]],
VCI = [[88]],
encapsulation = [[dslencap_ether]],
multi_pdn = [[1]],
apn1 = [[fixed.voice.vodafone.de]],
registrar = {[[arcor.de]]},
outboundproxy = [[sip.lte.arcor.de]],
route_always_over_internet = [[0]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowSecondInput','ShowPassword','ShowIp','ShowOverInternet','ShowOKZ','ShowPerformanceTip'}))
}
data.vodafone_lte = create_provider(data.other, data.vodafone_lte)
data.voztelecom = {
name = [[Voz Telecom]],
id = [[voztelecom]],
active = (is_international() and is_spain()),
dataValues = {
details = {
registrar = {[[voztele.com]]},
outboundproxy = [[nat-es-01.voztele.com:5062]],
dtmfcfg = [[1]],
clirtype = [[5]],
only_call_from_registrar = [[1]],
outboundproxy_without_route_header = [[1]]
}
},
display = create_display(array.truth({'ShowProvider','ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.voztelecom = create_provider(data.other, data.voztelecom)
data.xs4all = {
name = [[XS4ALL]],
id = [[xs4all]],
active = (is_international() and is_netherlands()),
userInterface = {
uiNumberLabel = str_25
},
dataValues = {
details = {
registrar = {[[sip.xs4all.nl]]}
}
},
display = create_display(array.truth({'ShowProvider','ShowPassword','ShowOverInternet','ShowExp','ShowIp','ShowPerformanceTip','ShowOKZ'}))
}
data.xs4all = create_provider(data.other, data.xs4all)
data.sipgatetrunking = {
name = [[sipgate trunking]],
id = [[sipgatetrunking]],
active = is_default(),
mode = [[differenttrunk]],
userInterface = {
uiLabelUsername = str_22,
uiLabelPwd = str_23,
},
dataValues = {
details = {
registrar = {[[sipconnect.sipgate.de]]},
stunserver = [[stun.sipgate.net:10000]],
dditype = [[4]],
use_internat_calling_numb = [[1]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.sipgatetrunking = create_provider(data.other, data.sipgatetrunking)
data.teleflash = {
name = [[TELEflash]],
id = [[teleflash]],
active = is_default(),
userInterface = {
uiLabelUsername = str_26,
uiLabelPwd = str_27
},
dataValues = {
details = {
registrar = {[[sip.teleflash.com]]},
outboundproxy = [[sip.teleflash.com]],
stunserver = [[stun.teleflash.com]],
authname_needed = [[1]],
clirtype = [[5]],
clipnstype = [[2]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.teleflash = create_provider(data.other, data.teleflash)
data.youcallus = {
name = [[you call us]],
id = [[youcallus]],
active = is_default(),
userInterface = {
uiLabelUsername = str_26,
uiLabelPwd = str_27
},
dataValues = {
details = {
registrar = {[[you-call.us]]},
outboundproxy = [[sip.you-call.us]],
stunserver = [[stun.teleflash.com]],
authname_needed = [[1]],
clirtype = [[5]],
clipnstype = [[2]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.youcallus = create_provider(data.other, data.youcallus)
data.binomium = {
name = [[binomium]],
id = [[binomium]],
active = is_default(),
userInterface = {
uiLabelUsername = str_26,
uiLabelPwd = str_27
},
dataValues = {
details = {
registrar = {[[binomium.com]]},
outboundproxy = [[sip.binomium.com]],
stunserver = [[stun.teleflash.com]],
authname_needed = [[1]],
clirtype = [[5]],
clipnstype = [[2]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.binomium = create_provider(data.other, data.binomium)
data.sipload = {
name = [[sipload]],
id = [[sipload]],
active = is_default(),
userInterface = {
uiLabelUsername = str_26,
uiLabelPwd = str_27
},
dataValues = {
details = {
registrar = {[[sip.sipload.com]]},
outboundproxy = [[sip.sipload.com]],
stunserver = [[stun1.sipload.com]],
dtmfcfg = [[2]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.sipload = create_provider(data.other, data.sipload)
data.easybell = {
name = [[easybell]],
id = [[easybell]],
active = is_default(),
userInterface = {
uiNumberFirstSpan = [[0049]],
uiLabelUsername = str_26,
uiLabelPwd = str_27
},
dataValues = {
details = {
registrar = {[[sip.easybell.de]]}
}
},
display = create_display(array.truth({'ShowProvider','ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.easybell = create_provider(data.other, data.easybell)
data.pandtluxfibre = {
name = [[POST LuxFibre]],
id = [[pandtluxfibre]],
active = is_luxembourg(),
userInterface = {
uiLabelUsername = str_26,
uiLabelPwd = str_27
},
dataValues = {
details = {
registrar = {[[voip.dt.ept.lu]]},
outboundproxy = [[voip.dt.ept.lu]],
mwi_supported = [[0]]
}
},
display = create_display(array.truth({'ShowProvider','ShowUsername','ShowPassword','ShowIp','ShowOverInternet','ShowPerformanceTip'}))
}
data.pandtluxfibre = create_provider(data.other, data.pandtluxfibre)
data.einfachVoIP = {
name = [[einfachVoIP]],
id = [[einfachVoIP]],
active = is_default(),
userInterface = {
uiNumberLabel = str_25,
uiLabelUsername = str_26,
uiLabelPwd = str_27
},
dataValues = {
details = {
registrar = {[[einfachVoIP.de]]}
},
telcfg = {
AKN = [[0]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowUsername' ,'ShowPassword','ShowIp'}))
}
data.einfachVoIP = create_provider(data.other, data.einfachVoIP)
data.qsccentraflex = table.clone(data.other)
data.qsccentraflex = {
name = [[QSC centraflex]],
id = [[qsccentraflex]],
active = is_default(),
userInterface = {
uiNumberLabel = str_25,
uiLabelUsername = str_26,
uiLabelPwd = str_27
},
dataValues = {
details = {
registrar = {[[voip3.bmcag.com]]},
dtmfcfg = [[2]],
read_p_asserted_identity_header = [[1]],
route_always_over_internet = [[1]]
}
},
display = create_display(array.truth({'ShowProvider', 'ShowUsername' ,'ShowPassword','ShowIp'}))
}
data.qsccentraflex = create_provider(data.other, data.qsccentraflex)
local g_init=false
-- tab["1und1"]
-- tab["o2"]
--
-- f="o2"
--
-- if tab[f] then
function findUnknownSipProviders(init_again)
if g_init and not init_again then
return
end
g_init=true
local unknownList = {}
for p, d in pairs(general.listquery("sip:settings/sip/list(providername,registrar,outboundproxy,webui_trunk_id)")) do
if d["registrar"] ~= "" then
if isUnknownProviderNotMultiple(unknownList, d["registrar"], d["webui_trunk_id"]~="") then
if not findProviderInProviderList(d["registrar"],d["outboundproxy"],d["webui_trunk_id"]~="") then
if d["providername"] ~= "" then
addUnknownSipProviders(unknownList,d["providername"], d["registrar"], d["outboundproxy"], d["webui_trunk_id"])
elseif d["registrar"] ~= "" then
if string.find(d["registrar"], "kabelphone.de", 1,true) then
addKabelDeutschland(d["registrar"])
else
addUnknownSipProvidersWithoutProvidername(unknownList,d["registrar"], d["outboundproxy"], d["webui_trunk_id"])
end
end
end
end
end
end
end
function isUnknownProviderNotMultiple(unknown_list, registrar, istrunking)
for a,b in pairs(unknown_list) do
if istrunking and b == registrar.."_trunk" then
return false
elseif b == registrar then
return false
end
end
return true
end
function findProviderInProviderList(registrar, outboundproxy, istrunking)
local reg_id=registrar
if (istrunking) then
reg_id=reg_id.."_trunk"
end
for p, d in pairs(data) do
if d.active then
if d.is_a_copy then
if d.id == reg_id then
return true
end
else
for u,l in pairs(d.dataValues.details.registrar) do
if l == registrar then
if (d.dataValues.details.outboundproxy==outboundproxy) or (d.dataValues.details.outboundproxy~="" and outboundproxy~="" and string.find(outboundproxy,d.dataValues.details.outboundproxy,1,true)) then
return true
end
end
end
end
end
end
return false
end
function get_mode(trunk_id)
local mode = "normal"
if string.len(trunk_id) > 0 then
if string.find(trunk_id,"direct") then
mode = "directdialin"
else
mode ="differenttrunk"
end
end
return mode
end
function addUnknownSipProviders(unknownList,providername, registrar, outboundproxy, webui_trunk_id)
local reg_id=box.tohtml(registrar)
if (webui_trunk_id~="") then
reg_id=reg_id.."_trunk"
end
if (webui_trunk_id~="") then
if string.find(webui_trunk_id,"direct",1,true) then
data[reg_id] = table.clone(data.directdialintrunk)
else
data[reg_id] = table.clone(data.sipnormaltrunk)
end
else
data[reg_id] = table.clone(data.other)
end
data[reg_id].name = providername
data[reg_id].dataValues.details.registrar[1] = registrar
data[reg_id].dataValues.details.outboundproxy = outboundproxy
data[reg_id].id = reg_id
data[reg_id].mode = get_mode(webui_trunk_id)
data[reg_id].is_a_copy = true
table.insert(unknownList, reg_id)
end
function addUnknownSipProvidersWithoutProvidername(unknownList,registrar, outboundproxy, webui_trunk_id)
local trunking=""
local reg_id=box.tohtml(registrar)
if (webui_trunk_id~="") then
trunking=" Trunking"
reg_id=reg_id.."_trunk"
end
if (webui_trunk_id~="") then
if string.find(webui_trunk_id,"direct",1,true) then
data[reg_id] = table.clone(data.directdialintrunk)
else
data[reg_id] = table.clone(data.sipnormaltrunk)
end
else
data[reg_id] = table.clone(data.other)
end
data[reg_id].name = registrar..trunking
if not data[reg_id].dataValues.details.registrar[1] then
data[reg_id].dataValues.details.registrar = {}
end
data[reg_id].dataValues.details.registrar[1] = registrar
data[reg_id].dataValues.details.outboundproxy = outboundproxy
data[reg_id].id = reg_id
data[reg_id].mode = get_mode(webui_trunk_id)
data[reg_id].is_a_copy = true
table.insert(unknownList, reg_id)
end
function addKabelDeutschland(registrar, item)
table.insert(data.kdg.dataValues.details.registrar, registrar)
data.kdg.active = true
end
findUnknownSipProviders()
function get_providerlist()
local out_data = {}
local keys = table.keys(data.other)
for p, d in pairs(data) do
if d.active then
out_data[p] = d
end
end
return out_data
end
function get_sorted_active_providers(trunk)
local results = {}
local k = {}
for a, o in pairs(data) do
if a ~= "other" and o.active ~= false then
if trunk and fon_numbers.is_trunkmode(o.mode) then
table.insert(results, {name = o.name, id = o.id})
else
if not trunk then
table.insert(results, {name = o.name, id = o.id})
end
end
end
end
utf8.sort(results, function(item) return item.name end)
table.insert(results, {name = data.other.name, id = data.other.id})
return results
end
function get_option(provider, trunk)
local str_option = [[]]
for j, z in pairs(get_sorted_active_providers(trunk)) do
local selected = [[]]
if provider == z.id then
selected = [[selected="selected"]]
end
str_option = str_option..[[<option value="]]..tostring(z.id)..[[" ]]..selected..[[ >]]..box.tohtml(z.name)..[[</option>]]
end
return str_option
end
function get_option_ui(provider, trunk)
local str_option = [[]]
local selected = [[]]
for j, z in pairs(get_sorted_active_providers(trunk)) do
if isp.is_ui(z.id) then
selected = [[]]
if provider == z.id then
selected = [[selected="selected"]]
end
str_option = str_option..[[<option value="]]..tostring(z.id)..[[" ]]..selected..[[ >]]..box.tohtml(z.name)..[[</option>]]
end
end
selected = [[]]
if (provider~="1und1" and provider~="gmx") then
selected = [[selected="selected"]]
end
str_option = str_option..[[<option value="other_non_ui" ]]..selected..[[ >]]..TXT([[{?3291:396?}]])..[[</option>]]
return str_option
end
function get_option_non_ui(provider, trunk)
local str_option = [[]]
for j, z in pairs(get_sorted_active_providers(trunk)) do
if not isp.is_ui(z.id) then
local selected = [[]]
if provider == z.id then
selected = [[selected="selected"]]
end
str_option = str_option..[[<option value="]]..tostring(z.id)..[[" ]]..selected..[[ >]]..box.tohtml(z.name)..[[</option>]]
end
end
return str_option
end
function get_LTEInfos()
local data = {}
data.use_seperate_vcc = box.query("connection_voip:settings/use_seperate_vcc")
data.VCI = box.query("connection_voip:settings/VCI")
data.encapsulation = box.query("connection_voip:settings/encapsulation")
data.multi_pdn = box.query("lted:settings/hw_info/ue/multi_pdn")
data.apn1 = box.query("lted:settings/hw_info/ue/apn1")
return data
end
-- -----------------------------------------------------------------------------
--ermitteln des SIP-Provider ID und Name anhand des registrar, providernamens und des outboundproxy
--kann der Provider nicht korrekt ermittelt werden, wird als fallback zuerst der providername
--und dann der registrar verwendet. Im absoluten nicht match wird ein leerer String zurückgegeben.
-- -----------------------------------------------------------------------------
function get_sip_provider(registrar, outboundproxy, providername,istrunking)
for a, o in pairs(data) do
if o.active then
for i = 1, #o.dataValues.details.registrar do
if o.dataValues.details.registrar[i] == registrar and fon_numbers.is_trunkmode(o.mode) == istrunking then
if (registrar=="sipgate.de") then
if (o.dataValues.details.outboundproxy == outboundproxy) then
return o.name
end
else
return o.name
end
end
end
end
end
if string.find(tostring(registrar), "kabelphone.de",1,true) then
return data.kdg.name
end
if providername and providername~="" then
return providername
end
if registrar and registrar~="" then
return registrar
end
return data.other.name
end
function get_sip_provider_id(registrar, outboundproxy,istrunking)
if not outboundproxy then
outboundproxy = ""
end
local best_match=nil
for a, o in pairs(data) do
if o.active then
for i = 1, #o.dataValues.details.registrar do
if o.dataValues.details.registrar[i] == registrar and fon_numbers.is_trunkmode(o.mode) == istrunking then
if string.len(outboundproxy) > 0 then
if o.dataValues.details.outboundproxy and o.dataValues.outboundproxy~="" and string.find(outboundproxy,o.dataValues.details.outboundproxy,1,true) then
return o.id
end
best_match=o.id
else
if not o.dataValues.details.outboundproxy or o.dataValues.details.outboundproxy=="" then
return o.id
end
best_match=o.id
end
end
end
end
end
if string.find(tostring(registrar), "kabelphone.de",1,true) then
return data.kdg.id
end
if (registrar~="") then
return registrar
end
return data.other.id
end
function get_userInterface_from_providerlist(provider)
local providerliste = get_providerlist()
return providerliste[provider].userInterface
end
function get_startdata()
startdata = {}
local id, telcfg_id = fon_numbers.new_SipNode()
local uid = "sip:"..tostring(id)
startdata[1] = {}
startdata[1].uid = uid
startdata[1].number = ""
startdata[1].name = ""
startdata[1].msnnum = ""
startdata[1].id = id
startdata[1].gui_readonly = false
startdata[1].telcfg_id = telcfg_id
startdata[1].provider = ""
startdata[1].provider_id = ""
startdata[1].active = true
startdata[1].registered = false
startdata[1].type = "sip"
startdata[1].trunk_id = ""
startdata[1].number1 = ""
startdata[1].number2 = ""
startdata[1].count_trunk = 1
startdata[1].dataValues = data.other.dataValues
startdata[1].dataValues.details.username = ""
startdata[1].dataValues.details.registrar = {}
startdata[1].dataValues.details.registrar[1] = ""
startdata[1].dataValues.details.password = ""
startdata[1].dataValues.details.gui_readonly = false
return startdata
end
function get_one_value_from_providerlist(value, provider, group)
if group and group ~= "" then
return data[provider][group][value]
end
return data[provider][value]
end
