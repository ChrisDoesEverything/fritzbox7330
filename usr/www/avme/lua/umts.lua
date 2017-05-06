--[[Access denied<?lua
    box.end_page()
?>?>]]
require"general"
umts={}
local gsm=general.lazytable({},box.query,{
RSSI={"gsm:settings/RSSI"},
BER={"gsm:settings/BER"},
Manufacturer={"gsm:settings/Manufacturer"},
Model={"gsm:settings/Model"},
NetworkState={"gsm:settings/NetworkState"},
Operator={"gsm:settings/Operator"},
AcT={"gsm:settings/AcT"},
MaxUL={"gsm:settings/MaxUL"},
MaxDL={"gsm:settings/MaxDL"},
CurrentUL={"gsm:settings/CurrentUL"},
CurrentDL={"gsm:settings/CurrentDL"},
Established={"gsm:settings/Established"},
PIN_State={"gsm:settings/PIN_State"},
PIN={"gsm:settings/PIN"},
PUK={"gsm:settings/PUK"},
Trycount={"gsm:settings/Trycount"},
ModemPresent={"gsm:settings/ModemPresent"},
PinEmpty={"gsm:settings/PinEmpty"},
AllowRoaming={"gsm:settings/AllowRoaming"},
VoiceStatus={"gsm:settings/VoiceStatus"},
SubscriberNumber={"gsm:settings/SubscriberNumber"},
InHomeZone={"gsm:settings/InHomeZone"}
})
umts=gsm
umts=general.lazytable(umts,box.query,{
enabled={"umts:settings/enabled"},
name={"umts:settings/name"},
provider={"umts:settings/provider"},
number={"umts:settings/number"},
username={"umts:settings/username"},
password={"umts:settings/password"},
on_demand={"umts:settings/on_demand"},
idle={"umts:settings/idle"},
backup_enable={"umts:settings/backup_enable"},
backup_downtime={"umts:settings/backup_downtime"},
backup_reverttime={"umts:settings/backup_reverttime"}
})
umts=general.lazytable(umts,general.listquery,{
providers={"umts_provider:settings/provider/list(name,provider,number,username,password)"}
})
local _pinstates=setmetatable({
["0"]="nosim",
["1"]="simerror",
["2"]="pinneeded",
["3"]="pin2needed",
["4"]="pukneeded",
["5"]="puk2needed",
["6"]="pinready",
["7"]="other",
["8"]="pinchecking"
},{__index=function(self,key)return tostring(key)end
})
function umts.pinstate()return _pinstates[gsm.PIN_State]end
function umts.sim_ok()
local state=umts.pinstate()
return state~="nosim"and state~="simerror"
end
function umts.pin_needed(which)
local state=umts.pinstate()
if which=='PUK'then
return state=="pukneeded"or state=="puk2needed"
elseif which=='PIN'then
return state=="pinneeded"or state=="pin2needed"
end
return false
end
function umts.pin_ready()
return umts.pinstate()=="pinready"
end
local _networkstates=setmetatable({
["0"]="disabled",
["1"]="registered_home",
["2"]="searching",
["3"]="registration_denied",
["4"]="unknown",
["5"]="registered_roaming",
["6"]="limited_service"
},{__index=function(self,key)return tostring(key)end
})
function umts.networkstate()return _networkstates[gsm.NetworkState]end
function umts.registered(which)
which=which or""
local netstate=umts.networkstate()
return netstate:find("registered_"..which)==1
end
local _act_display={
["0"]=[[GPRS]],
["1"]=[[GPRS]],
["2"]=[[UMTS]],
["3"]=[[EDGE]],
["4"]=[[HSPA]],
["5"]=[[HSPA]],
["6"]=[[HSPA]],
["255"]=""
}
function umts.access_technology()return _act_display[gsm.AcT]end
function umts.is_1und1_modem()
if gsm.ModemPresent=="1"then
return(gsm.Manufacturer=="ZTE CORPORATION"and gsm.Model=="MF190V")
or(gsm.Manufacturer=="4G Systems GmbH & Co. KG"and gsm.Model=="XS Stick P14")
or(gsm.Manufacturer=="ZTE CORPORATION"and gsm.Model=="MF667")
or(gsm.Manufacturer=="4G Systems GmbH & Co. KG"and gsm.Model=="XS Stick W21S")
end
return false
end
function umts.is_voice_modem()
if gsm.ModemPresent=="1"then
local voice_status=tonumber(gsm.VoiceStatus)or 0
return voice_status>0
end
return false
end
function umts.providerlist()
local list=umts.providers
local result={}
for i,p in ipairs(list)do
result[p.name]=p
end
return result
end
return umts
