--[[Access denied<?lua
    box.end_page()
?>?>]]
require"general"
require"html"
require"textdb"
pushservice={}
do
pushservice.available={}
pushservice.available.account=config.MAILER or config.MAILER2
if pushservice.available.account then
pushservice.available.info=true
require"menu"
pushservice.available.fwupdate=menu.check_page("system","update.lua")
pushservice.available.cfgexport=config.STOREUSRCFG
pushservice.available.tam=config.TAM_MODE and config.TAM_MODE>0
pushservice.available.fax=config.FAX2MAIL
pushservice.available.calls=config.FON
pushservice.available.smarthome=config.HOME_AUTO
pushservice.available.connectmail=not config.GUI_IS_REPEATER
if pushservice.available.smarthome then
require"libaha"
require"ha_func_lib"
end
pushservice.available.wlan_guest=config.WLAN_GUEST
pushservice.available.pwdlost=true
end
end
function pushservice.get_data(which)
local data
if pushservice.available[which]then
data=pushservice[which]
end
return data
end
pushservice.account=general.lazytable({},box.query,{
enabled={"emailnotify:settings/enabled"},
From={"emailnotify:settings/From"},
passwd={"emailnotify:settings/passwd"},
accountname={"emailnotify:settings/accountname"},
SMTPServer={"emailnotify:settings/SMTPServer"},
starttls={"emailnotify:settings/starttls"}
})
pushservice.info=general.lazytable({},box.query,{
infoenabled={"emailnotify:settings/infoenabled"},
To={"emailnotify:settings/To"},
interval={"emailnotify:settings/interval"},
show_fonstat={"emailnotify:settings/show_fonstat"},
show_kidsstat={"emailnotify:settings/show_kidsstat"},
show_onlinecntstat={"emailnotify:settings/show_onlinecntstat"},
show_eventlist={"emailnotify:settings/show_eventlist"},
dsl_detail={"emailnotify:settings/dsl_detail"}
})
pushservice.fwupdate=general.lazytable({},box.query,{
fwupdatehint_enabled={"emailnotify:settings/fwupdatehint_enabled"},
fwupdatehint_To={"emailnotify:settings/fwupdatehint_To"}
})
pushservice.cfgexport=general.lazytable({},box.query,{
configexport_enabled={"emailnotify:settings/configexport_enabled"},
configexport_To={"emailnotify:settings/configexport_To"},
configexport_passwd={"emailnotify:settings/configexport_passwd"}
})
pushservice.connectmail=general.lazytable({},box.query,{
enable_connect_mail={"emailnotify:settings/enable_connect_mail"},
connect_mail_To={"emailnotify:settings/connect_mail_To"}
})
pushservice.fax=general.lazytable({},box.query,{
FaxMailActive={"telcfg:settings/FaxMailActive"},
FaxMailAddress={"telcfg:settings/FaxMailAddress"}
})
pushservice.calls=general.lazytable({},general.listquery,{
list={"telcfg:settings/NotifyEmail/list(Active,MSN,Address)"}
})
local function read_tam(...)
require"fon_devices"
return fon_devices.read_tam(...)
end
pushservice.tam=general.lazytable({},read_tam,{
list={true,true}
})
function pushservice.smarthome_possible(device)
local funcmask=tonumber(device.FunctionBitMask)or 0
return ha_func_lib.is_outlet(funcmask)
and ha_func_lib.has_energy_monitor(funcmask)
and not ha_func_lib.is_network_device(device.ID)
end
local function read_smarthome_pushmailcfg(device_id)
local result={}
if device_id then
result=aha.GetPushMailConfig(device_id)or{}
end
return result
end
local function read_smarthome_list()
if not pushservice.available.smarthome then
return{}
end
local list=aha.GetDeviceList()or{}
list=array.filter(list,pushservice.smarthome_possible)
for i,dev in ipairs(list)do
dev=general.lazytable(dev,read_smarthome_pushmailcfg,{
pushmailcfg={dev.ID}
})
end
return list
end
pushservice.smarthome=general.lazytable({},read_smarthome_list,{
list={}
})
pushservice.wlan_guest=general.lazytable({},box.query,{
wlangueststatus_enabled={"emailnotify:settings/wlangueststatus_enabled"},
wlangueststatus_counter={"emailnotify:settings/wlangueststatus_counter"},
wlangueststatus_To={"emailnotify:settings/wlangueststatus_To"}
})
pushservice.pwdlost=general.lazytable({},box.query,{
reset_pwd_enabled={"emailnotify:settings/reset_pwd_enabled"}
})
function pushservice.smarthome_get_device(device_id)
local result={}
device_id=tonumber(device_id)
if device_id then
result=aha.GetDevice(device_id)or{}
result.pushmailcfg=read_smarthome_pushmailcfg(result.ID)
end
return result
end
function pushservice.account_configured()
local data=pushservice.account
return data.From~=""and data.SMTPServer~=""
end
function pushservice.info_active()
local data=pushservice.info
return data.infoenabled=="1"
end
function pushservice.fax_active()
local data=pushservice.fax
return(tonumber(data.FaxMailActive)or 0)%2==1
end
function pushservice.calls_any_number_active()
local idx=array.find(pushservice.calls.list,function(c)
return c.MSN~=""and(tonumber(c.Active)or 0)>0
end,2)
return idx~=nil
end
function pushservice.calls_active()
local list=pushservice.calls.list or{}
if#list>0 and((tonumber(list[1].Active)or 0)>0)then
return true
end
return pushservice.calls_any_number_active()
end
function pushservice.calls_numberlist()
require"fon_numbers"
local pushlist=pushservice.calls.list
local all_nums=fon_numbers.get_all_numbers()
local numstr,numidx
local free_pushidx=array.find(pushlist,func.eq("","MSN"),2)
local done={}
pushlist.count=0
for i,number in ipairs(all_nums.numbers)do
numstr=tostring(number.msnnum)
if not done[numstr]and numstr~=""then
pushlist.count=pushlist.count+1
numidx=array.find(pushlist,func.eq(numstr,"MSN"))
if not numidx and free_pushidx then
pushlist[free_pushidx].MSN=numstr
pushlist[free_pushidx].new=true
free_pushidx=array.find(pushlist,func.eq("","MSN"),free_pushidx+1)
end
end
done[numstr]=true
end
return pushlist or{count=0}
end
function pushservice.calls_get_call(msn)
msn=msn or""
local pushlist=pushservice.calls.list
local idx=array.find(pushlist,func.eq(msn,"MSN"),2)
if not idx and msn~=""then
idx=array.find(pushlist,func.eq("","MSN"),2)
end
if idx then
if msn~=""then
pushlist[idx].MSN=msn
pushlist[idx].new=true
end
pushlist[idx].idx=idx
return pushlist[idx]
end
return{}
end
function pushservice.calls_delete(msn,saveset)
saveset=saveset or{}
if not msn or msn==""then
return saveset
end
require"cmtable"
local pushlist=pushservice.calls.list
local idx=array.find(pushlist,func.eq(msn,"MSN"),2)
if idx then
local webvar="telcfg:settings/NotifyEmail"..(idx-1)
cmtable.add_var(saveset,webvar.."/Active","0")
cmtable.add_var(saveset,webvar.."/Address","")
cmtable.add_var(saveset,webvar.."/MSN","")
end
return saveset
end
function pushservice.tam_active()
local data=pushservice.tam
return array.any(data.list,function(t)
return t.pushmail_active=="1"or t.pushmail_active=="2"
end)
end
function pushservice.smarthome_get_cfg(device)
device=device or{}
local result={}
if device.ID then
result=aha.GetPushMailConfig(device.ID)or{}
end
return result
end
function pushservice.smarthome_active()
local data=pushservice.smarthome
local p
for i,dev in ipairs(data.list)do
p=pushservice.smarthome_get_cfg(dev)
if p.activ==1 then
return true
end
end
return false
end
function pushservice.default_mailto(mailto)
if not mailto or mailto==""then
local str=pushservice.account.From
local name,addr=string.match(str or"",[[^"(.*)"%s*<(.*)>$]])
mailto=addr or str
end
return mailto
end
function pushservice.display_mailto(mailto)
return(string.gsub(mailto or"",",",", "))
end
function pushservice.gethtml_enabled(data)
data=data or{}
local name,id="enabled","uiEnabled"
return html.fragment(
html.input{
type="checkbox",name=name,id=id,checked=data[name]
},
html.label{['for']=id,TXT([[{?638:255?}]])}
)
end
function pushservice.gethtml_mailto(data)
data=data or{}
local name=data.html_name or"mailto"
local id="ui"..name:at(1):upper()..name:sub(2)
return html.div{class="formular widetext",
html.label{['for']=id,TXT([[{?638:1?}]])},
html.input{type="text",name=name,id=id,value=data[name]}
}
end
local function get_radio_btns(options)
local name=options.name
local values=options.values or{}
if not name or#values==0 then
return
end
local txt=options.txt or{}
local checked_value=options.checked_value or values[1]
local id="ui"..name:at(1):upper()..name:sub(2)
local class="formular"
if options.add_class then
class=class.." "..options.add_class
end
local container=html.fragment()
for i,value in ipairs(values)do
local curr_id=id..":"..value
container.add(html.div{class=class,
html.input{
type="radio",name=name,value=value,id=curr_id,checked=value==checked_value
},
html.label{['for']=curr_id,txt[i]or tostring(value)}
})
end
return container
end
local function gethtml_smarthome_inputs(data)
data=data or{}
local div1=html.div{class="formular"}
div1.add(html.p{
TXT([[{?851:553?}]])
})
div1.add(html.div{class="formular",
html.input{
type="checkbox",name="TriggerSwitchChange",id="uiTriggerSwitchChange",
checked=data.TriggerSwitchChange
},
html.label{['for']="uiTriggerSwitchChange",
TXT([[{?851:721?}]])
}
})
div1.add(html.div{class="formular",
html.input{type="checkbox",name="periodic",id="uiPeriodic",checked=data.periodic},
html.label{['for']="uiPeriodic",
TXT([[{?851:970?}]])
},
get_radio_btns{name="interval",add_class="enableif_periodic",
values={"daily","weekly","monthly"},
checked_value=data.interval,
txt={
TXT([[{?851:757?}]]),
TXT([[{?851:100?}]]),
TXT([[{?851:290?}]])
}
}
})
local div2=html.div{class="formular"}
div2.add(html.p{
TXT([[{?851:628?}]])
})
div2.add(
get_radio_btns{name="ShowEnergyStat",
values={"24h","week","month","year"},
checked_value=data.ShowEnergyStat,
txt={
TXT([[{?851:108?}]]),
TXT([[{?851:671?}]]),
TXT([[{?851:322?}]]),
TXT([[{?851:320?}]])
}
}
)
return html.fragment(div1,div2)
end
local smarthome_explain=[[{?851:819?}]]
function pushservice.smarthome_write_explain()
html.p{TXT(smarthome_explain)}.write()
end
function pushservice.smarthome_writehtml(options)
options=options or{}
if not(options.data or options.pushmailcfg)then
return
end
local data=options.data or pushservice.read_data_smarthome(options.pushmailcfg)
pushservice.gethtml_enabled(data).write()
html.div{class="enableif_enabled",
gethtml_smarthome_inputs(data),
pushservice.gethtml_mailto(data)
}.write()
end
function pushservice.read_data_smarthome(pushmailcfg)
local data={}
pushmailcfg=pushmailcfg or{}
data.enabled=pushmailcfg.activ==1
data.TriggerSwitchChange=pushmailcfg.TriggerSwitchChange==1
data.interval="daily"
data.periodic=pushmailcfg.interval~=0
if pushmailcfg.interval==44640 then
data.interval="monthly"
elseif pushmailcfg.interval==10080 then
data.interval="weekly"
elseif pushmailcfg.interval==1440 then
data.interval="daily"
end
data.ShowEnergyStat="24h"
if pushmailcfg.ShowEnergyStatYear==1 then
data.ShowEnergyStat="year"
elseif pushmailcfg.ShowEnergyStatMonth==1 then
data.ShowEnergyStat="month"
elseif pushmailcfg.ShowEnergyStatWeek==1 then
data.ShowEnergyStat="week"
elseif pushmailcfg.ShowEnergyStat24h==1 then
data.ShowEnergyStat="24h"
end
data.mailto=pushservice.default_mailto(pushmailcfg.email)
return data
end
function pushservice.save_data_smarthome(pushmailcfg)
pushmailcfg=pushmailcfg or{}
pushmailcfg.activ=box.post.enabled and 1 or 0
if box.post.enabled then
pushmailcfg.TriggerSwitchChange=box.post.TriggerSwitchChange and 1 or 0
if box.post.periodic then
if box.post.interval=="monthly"then
pushmailcfg.interval=44640
elseif box.post.interval=="weekly"then
pushmailcfg.interval=10080
else
pushmailcfg.interval=1440
end
else
pushmailcfg.interval=0
end
pushmailcfg.ShowEnergyStatYear=box.post.ShowEnergyStat=="year"and 1 or 0
pushmailcfg.ShowEnergyStatMonth=box.post.ShowEnergyStat=="month"and 1 or 0
pushmailcfg.ShowEnergyStatWeek=box.post.ShowEnergyStat=="week"and 1 or 0
pushmailcfg.ShowEnergyStat24h=box.post.ShowEnergyStat=="24h"and 1 or 0
pushmailcfg.ShowEnergyStatHour=0
pushmailcfg.ShowEnergyStat10Min=0
pushmailcfg.email=general.clear_whitespace(box.post.mailto)
end
aha.SetPushMailConfig(pushmailcfg.ID,pushmailcfg)
return 0
end
function pushservice.save_default_smarthome(pushmailcfg)
pushmailcfg.activ=1
if pushmailcfg.interval==0 then
pushmailcfg.interval=1440
end
if pushmailcfg.ShowEnergyStatYear==0
and pushmailcfg.ShowEnergyStatMonth==0
and pushmailcfg.ShowEnergyStatWeek==0 then
pushmailcfg.ShowEnergyStat24h=1
end
pushmailcfg.ShowEnergyStatHour=0
pushmailcfg.ShowEnergyStat10Min=0
if pushmailcfg.email==""then
pushmailcfg.email=pushservice.default_mailto()
end
aha.SetPushMailConfig(pushmailcfg.ID,pushmailcfg)
end
function pushservice.smarthome_validation()
require"newval"
pushservice.mailto_validation()
newval.msg.period={
[newval.ret.wrong]=TXT([[{?851:834?}]])
}
if newval.checked("enabled")then
newval.least_one_checked("TriggerSwitchChange","periodic","period")
end
end
function pushservice.mailto_validation()
require"newval"
newval.msg.email={
[newval.ret.empty]=TXT([[{?851:254?}]]),
[newval.ret.format]=TXT([[{?851:344?}]])
}
if newval.checked("enabled")then
newval.email_list("mailto","email")
end
end
function pushservice.account_validation()
require"newval"
local noemail=TXT([[{?851:601?}]])
newval.msg.email={
[newval.ret.notfound]=noemail,
[newval.ret.empty]=noemail,
[newval.ret.format]=TXT([[{?851:310?}]])
}
local noserver=TXT([[{?851:332?}]])
newval.msg.server={
[newval.ret.notfound]=noserver,
[newval.ret.empty]=noserver,
[newval.ret.format]=TXT([[{?851:699?}]])
}
newval.email("email","email")
newval.server("server","server")
end
function pushservice.save_first_defaults(saveset,mailto)
require"cmtable"
mailto=pushservice.default_mailto(mailto)
if pushservice.available.calls then
local webvar=[[telcfg:settings/NotifyEmail/]]
cmtable.add_var(saveset,webvar.."Active","1")
cmtable.add_var(saveset,webvar.."MSN","")
cmtable.add_var(saveset,webvar.."Address",mailto)
end
if pushservice.available.fwupdate then
cmtable.add_var(saveset,"emailnotify:settings/fwupdatehint_enabled","1")
cmtable.add_var(saveset,"emailnotify:settings/fwupdatehint_To",mailto)
end
if pushservice.available.tam then
local webvar
for i,tam in ipairs(pushservice.tam.list)do
webvar=string.format([[tam:settings/TAM%d]],i-1)
cmtable.add_var(saveset,webvar.."/PushmailActive","1")
cmtable.add_var(saveset,webvar.."/MailAddress",mailto)
end
end
if pushservice.available.fax then
local active=tonumber(pushservice.fax.FaxMailActive)
if active then
cmtable.add_var(saveset,"telcfg:settings/FaxMailActive",tostring(active+1))
cmtable.add_var(saveset,"telcfg:settings/FaxMailAddress",mailto)
end
end
end
function pushservice.clear_account()
box.set_config{{
name="emailnotify:settings/enabled",value="0"
},{
name="emailnotify:settings/From",value=""
},{
name="emailnotify:settings/passwd",value=""
},{
name="emailnotify:settings/accountname",value=""
},{
name="emailnotify:settings/SMTPServer",value=""
},{
name="emailnotify:settings/starttls",value="0"
}
}
end
