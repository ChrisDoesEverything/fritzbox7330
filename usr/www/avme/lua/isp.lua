--[[Access denied<?lua
    box.end_page()
?>?>]]
--de-first -begin  
require"lualib"
require"utf8"
require"general"
require"textdb"
require"html"
require"bit"
require"config"
local table_insert,table_concat=table.insert,table.concat
isp={}
local list={}
local index={}
local excluded={}
local super_index,super_list={},{}
local other={
default=config.LTE and'other_lte'or'other',
name=TXT([[{?7127:550?}]]),
possible_ids={'other','other_lte'}
}
local oma={
{id='oma_lan',name=TXT([[{?7127:461?}]])},
{id='oma_wlan',name=TXT([[{?7127:148?}]])}
}
local maxlistlevel=1
function isp.convert(realid)
return((realid or""):gsub("[^%w]","_"))
end
function isp.value(id)
local p=list[id]
if p and p.realid then
return p.realid
end
return id
end
isp.activeprovider=func.const(isp.convert(box.query("providerlist:settings/activeprovider")))
isp.activename=func.const(box.query("providerlist:settings/activename"))
local function get_displayId(id)
local p=list[id]
return p and p.displayId or""
end
function isp.exists(id)
return list[id]
end
function isp.unconfigured()
local p=isp.activeprovider()
if p~='other'then
return false
end
if box.query("box:settings/opmode")=='opmode_modem'then
return true
end
return box.query("connection0:settings/username")==""
and box.query("connection0:settings/password")==""
and box.query("connection0:settings/type")=="bridge"
and box.query("box:settings/ata_mode")~="1"
end
function isp.html_name(name,provider,subprovider)
if name=='subprovider'then subprovider=nil end
return table_concat({name,provider,subprovider},":")
end
local function html_id(name)
return"ui"..name:at(1):upper()..name:sub(2)
end
html_id=func.cached(html_id)
function isp.html_id(name,value)
local id=html_id(name)
if value then id=id.."::"..value end
return id
end
function isp.read_post_var(name,provider,subprovider)
if name=='provider'then
local p=box.post.provider
if p=='more'then p=box.post.provider2 end
return p
else
local result=box.post[isp.html_name(name,provider,subprovider)]
if result==nil then
result=box.post[isp.html_name(name,provider)]
end
return result
end
end
local function merge_ipvars(vars)
local names={
"router_ipaddr","router_netmask","router_gateway","router_dns1","router_dns2",
"client_ipaddr","client_netmask","client_gateway","client_dns1","client_dns2",
"noauthdsl_ipaddr","noauthdsl_netmask","noauthdsl_gateway","noauthdsl_dns1","noauthdsl_dns2"
}
local tmp
for i,name in ipairs(names)do
tmp=array.build(4,function(i)return tonumber(vars[name..(i-1)])end)
if#tmp>0 then
vars[name]=table_concat(tmp,".")
end
end
end
local post_vars
function isp.read_all_post_vars()
if post_vars then
return post_vars
end
local p=isp.read_post_var('provider')
local subp=isp.read_post_var('subprovider',p)
post_vars={}
local stripped_name
if p then
for i,name in ipairs(general.sorted_by_i(box.post))do
if(not name:find(":")or name:find(":"..p))then
stripped_name=name:gsub(":"..p,"")
if subp then
stripped_name=stripped_name:gsub(":"..subp,"")
end
post_vars[stripped_name]=box.post[name]
end
end
end
post_vars.provider=p
post_vars.provider2=nil
merge_ipvars(post_vars)
if post_vars.mac0 then
local tmp=array.build(6,function(i)return post_vars['mac'..(i-1)]end)
post_vars.mac=table_concat(tmp,":")
end
return post_vars
end
local function get_initial_provider()
if isp.unconfigured()then
if#index==1 then
return index[1]
else
return'tochoose'
end
else
local p=isp.activeprovider()
if p=='other'and isp.activename()~=""then
p='other_named'
end
if excluded[p]then
return'tochoose'
end
local gf=isp.guiflag()
if p=="cebit13_dsl"and gf.lteprovider and gf.lteprovider~=""then
return gf.lteprovider
end
return p
end
end
isp.initial_provider=function()
return get_initial_provider()
end
function isp.initial_medium(provider)
local result=isp.medium_defaults(provider)
if provider==isp.initial_provider()then
local check_guiflag=isp.is_other(provider)or isp.is_dsl(provider)
local gf=isp.guiflag()
if check_guiflag and gf and gf.medium then
result=gf.medium
else
local opmode=box.query("box:settings/opmode")
if opmode:find("opmode_eth_")==1 then
result='extern'
end
end
end
if post_vars and post_vars.provider==provider then
result=post_vars.medium or result
end
return result
end
function isp.initial_optype(provider)
local result='router'
if provider==isp.initial_provider()then
if box.query("box:settings/opmode")=='opmode_eth_ipclient'then
result='client'
end
end
if post_vars and post_vars.provider==provider then
result=post_vars.optype or result
end
return result
end
function isp.initial_prevention(provider)
local result=isp.prevention_defaults(provider)
if provider==isp.initial_provider()then
result.Enabled=box.query("connection0:settings/ProviderDisconnectPrevention/Enabled")
if result.Enabled=="1"then
result.Hour=box.query("connection0:settings/ProviderDisconnectPrevention/Hour")
end
end
if post_vars and post_vars.provider==provider then
if post_vars.useprevention then
result.Enabled="1"
result.Hour=post_vars.prevention or result.Hour
end
end
return result
end
function isp.initial_connmode(provider)
local result=isp.connmode_defaults(provider)
if provider==isp.initial_provider()then
result.mode=box.query("connection0:settings/mode")
if result.mode=="on_demand"then
result.idle=box.query("connection0:settings/idle")
end
end
if post_vars and post_vars.provider==provider then
result.mode=post_vars.connmode or result.mode
result.idle=post_vars.idle or result.idle
end
return result
end
function isp.initial_speed(provider)
local result=isp.speed_defaults(provider)
if provider==isp.initial_provider()then
result.ManualDSLSpeed=box.query("box:settings/ManualDSLSpeed")
if result.ManualDSLSpeed=="1"then
result.DSLSpeedUpstream=box.query("box:settings/DSLSpeedUpstream")
result.DSLSpeedDownstream=box.query("box:settings/DSLSpeedDownstream")
end
end
if post_vars and post_vars.provider==provider then
if post_vars.upstream or post_vars.downstream then
result.ManualDSLSpeed="1"
end
result.DSLSpeedUpstream=post_vars.upstream or result.DSLSpeedUpstream
result.DSLSpeedDownstream=post_vars.downstream or result.DSLSpeedDownstream
end
return result
end
function isp.initial_vlan(provider)
local result=isp.vlan_defaults(provider)
if provider==isp.initial_provider()then
result.vlanencap=box.query("connection0:settings/vlanencap")
if result.vlanencap~="vlanencap_none"then
result.vlanid=box.query("connection0:settings/vlanid")
end
end
if post_vars and post_vars.provider==provider then
if post_vars.exists_usevlan then
if post_vars.usevlan and post_vars.vlanid then
result.vlanencap="vlanencap_fixed_prio"
result.vlanid=post_vars.vlanid
else
result.vlanencap="vlanencap_none"
end
end
end
return result
end
function isp.initial_atm(provider)
local result=isp.atm_defaults(provider)
if provider==isp.initial_provider()then
result.autodetect=box.query("sar:settings/autodetect")
result.encapsulation=box.query("sar:settings/encapsulation")
result.VCI=box.query("sar:settings/VCI")
result.VPI=box.query("sar:settings/VPI")
end
if post_vars and post_vars.provider==provider then
result.autodetect=post_vars.autodetect or result.autodetect
result.VPI=post_vars.vpi or result.VPI
result.VCI=post_vars.vci or result.VCI
result.encapsulation=post_vars.encap or result.encapsulation
end
return result
end
function isp.initial_ipsetting(provider,which)
local result={}
result[which.."_dhcp"]="1"
result[which.."_hostname"]=box.query("box:settings/dhcpc_hostname")
if provider==isp.initial_provider()then
local is_client=isp.initial_optype(provider)=='client'
if which=='router'then
if not is_client then
result.router_dhcp=box.query("box:settings/dslencap_ether/use_dhcp","1")
end
result.router_ipaddr=box.query("box:settings/dslencap_ether/ipaddr")
result.router_netmask=box.query("box:settings/dslencap_ether/netmask")
result.router_gateway=box.query("box:settings/dslencap_ether/gateway")
result.router_dns1=box.query("box:settings/dslencap_ether/dns1")
result.router_dns2=box.query("box:settings/dslencap_ether/dns2")
elseif which=='client'then
if is_client then
result.client_dhcp=box.query("interfaces:settings/lan0/dhcpclient","1")
end
result.client_ipaddr=box.query("interfaces:settings/lan0/ipaddr")
result.client_netmask=box.query("interfaces:settings/lan0/netmask")
result.client_gateway=box.query("box:settings/gateway")
result.client_dns1=box.query("box:settings/dns0")
result.client_dns2=box.query("box:settings/dns1")
elseif which=='noauthdsl'then
if not is_client then
result.noauthdsl_dhcp=box.query("box:settings/dslencap_ether/use_dhcp","1")
end
result.noauthdsl_ipaddr=box.query("box:settings/dslencap_ether/ipaddr")
result.noauthdsl_netmask=box.query("box:settings/dslencap_ether/netmask")
result.noauthdsl_gateway=box.query("box:settings/dslencap_ether/gateway")
result.noauthdsl_dns1=box.query("box:settings/dslencap_ether/dns1")
result.noauthdsl_dns2=box.query("box:settings/dslencap_ether/dns2")
end
end
if post_vars and post_vars.provider==provider then
for i,name in ipairs{"_hostname","_dhcp","_ipaddr","_netmask","_gateway","_dns1","_dns2"}do
name=which..name
result[name]=post_vars[name]or result[name]
end
end
return result
end
function isp.initial_classes(override_provider)
local p=isp.initial_provider()
if post_vars and post_vars.provider then
p=post_vars.provider
end
local classes={"isp_"..(override_provider or p)}
table_insert(classes,isp.initial_medium(p))
table_insert(classes,isp.initial_optype(p))
table_insert(classes,"super_"..get_displayId(p))
return classes
end
function isp.providername(id)
id=id or isp.activeprovider()
local p=list[id]
return p and p.providername or""
end
local renamed={vodafone='arcor',upc='inode'}
function isp.is(id_tocheck,id)
id=id or isp.activeprovider()
return id:find(id_tocheck,1,true)==1
or renamed[id_tocheck]==id
end
local is_other=func.cached(
function(id)return id:find('other',1,true)==1 end
)
function isp.is_other(id)
id=id or isp.activeprovider()
return is_other(id)
end
function isp.is_oma(id)
id=id or isp.activeprovider()
return id:find('oma_',1,true)==1
end
function isp.is_ui(id)
id=id or isp.activeprovider()
return id=='1und1'or id=='gmx'
end
function isp.is_vodafone_bytr069(id)
id=id or isp.activeprovider()
return id:find('vodafone_bytr069',1,true)==1
end
local function split_guiflag(str)
local result={}
for i,s in ipairs(str:split(";"))do
local key,value=unpack(s:split("="))
if key and#key>0 then
result[key]=value or""
end
end
return result
end
function isp.guiflag()
return split_guiflag(box.query("providerlist:settings/guiflag"))
end
function isp.characteristics(id)
local p=list[id]
return p and p.characteristic or{}
end
function isp.characteristic(id,webvar,value)
local p=list[id]
local ch=p and p.characteristic or{}
if value then
return ch[webvar]==value
else
return ch[webvar]
end
end
function isp.opmode(id)
id=id or isp.activeprovider()
return isp.characteristic(id,"box:settings/opmode")
end
local auth_opmodes=array.truth{
'opmode_standard','opmode_pppoe','opmode_pppoa','opmode_pppoa_llc','opmode_eth_pppoe'
}
function isp.auth_needed(id)
return isp.characteristic(id,"connection0:settings/username")
or isp.characteristic(id,"connection0:settings/password")
end
function isp.auth_defaults(id)
local auth={}
local ch=list[id]and list[id].characteristic or{}
auth.username=ch["connection0:settings/username"]
auth.pwd=ch["connection0:settings/password"]
if isp.is("xs4all",id)then
if auth.username==""then
auth.username=string.format(
[[FB%s@xs4all.nl]],
(config.PRODUKT_NAME or""):match("(%d%d%d%d)")or""
)
auth.pwd=[[xs4all]]
end
end
return auth
end
function isp.initial_auth(id)
if isp.is_other(id)then
return auth_opmodes[box.query("box:settings/opmode")]
end
return true
end
function isp.dont_clear_auth(id)
return isp.is_vodafone_bytr069(id)and id==isp.activeprovider()
end
function isp.medium_defaults(id)
local result='dsl'
if isp.over_lan1(id)then
result='extern'
end
if isp.is_cable(id)then
result='cable'
elseif isp.is_extern(id)then
result='extern'
end
return result
end
function isp.atm_needed(id)
return false
end
function isp.atm_defaults(id)
local atm={}
local ch=list[id]and list[id].characteristic or{}
atm.autodetect=ch["sar:settings/autodetect"]
atm.VCI=ch["sar:settings/VCI"]
atm.VPI=ch["sar:settings/VPI"]
atm.encapsulation=ch["sar:settings/encapsulation"]
return atm
end
function isp.speed_needed(id)
local ch=list[id]and list[id].characteristic or{}
return ch["box:settings/ManualDSLSpeed"]
or ch["box:settings/DSLSpeedUpstream"]
or ch["box:settings/DSLSpeedDownstream"]
end
function isp.speed_defaults(id)
local speed={}
local ch=list[id]and list[id].characteristic or{}
speed.ManualDSLSpeed=ch["box:settings/ManualDSLSpeed"]
speed.DSLSpeedUpstream=ch["box:settings/DSLSpeedUpstream"]
speed.DSLSpeedDownstream=ch["box:settings/DSLSpeedDownstream"]
if isp.is_other(id)then
speed.DSLSpeedUpstream="2000"
speed.DSLSpeedDownstream="32000"
end
return speed
end
function isp.prevention_needed(id)
local ch=list[id]and list[id].characteristic or{}
return ch["connection0:settings/ProviderDisconnectPrevention/Enabled"]
or ch["connection0:settings/ProviderDisconnectPrevention/Hour"]
end
function isp.prevention_defaults(id)
local prevention={}
local ch=list[id]and list[id].characteristic or{}
prevention.Enabled=ch["connection0:settings/ProviderDisconnectPrevention/Enabled"]
prevention.Hour=ch["connection0:settings/ProviderDisconnectPrevention/Hour"]
return prevention
end
function isp.connmode_needed(id)
local ch=list[id]and list[id].characteristic or{}
return ch["connection0:settings/mode"]
or ch["connection0:settings/idle"]
end
function isp.connmode_defaults(id)
local connmode={}
local ch=list[id]and list[id].characteristic or{}
connmode.mode=ch["connection0:settings/mode"]
connmode.idle=ch["connection0:settings/idle"]or"300"
return connmode
end
function isp.vlan_needed(id)
local ch=list[id]and list[id].characteristic or{}
return ch["connection0:settings/vlanencap"]
or ch["connection0:settings/vlanid"]
end
function isp.vlan_defaults(id)
local vlan={}
local ch=list[id]and list[id].characteristic or{}
vlan.vlanencap=ch["connection0:settings/vlanencap"]
vlan.vlanid=ch["connection0:settings/vlanid"]
if not vlan.vlanencap or#vlan.vlanencap==0 then
vlan.vlanencap="vlanencap_none"
end
return vlan
end
function isp.ipsetting_needed(id)
return false
end
function isp.mac_needed(id)
return config.isp_mac_needed and isp.is_other(id)
end
function isp.initial_mac(id)
local result=""
if id==isp.initial_provider()then
result=box.query("env:settings/macdsl")
end
return result
end
function isp.wlanscan_needed(id)
return id=='oma_wlan'
end
function isp.initial_wlanscan(id)
local result={}
if id==isp.initial_provider()then
if box.query("wlan:settings/bridge_mode")=="bridge-ata"then
result.stassid=box.query("wlan:settings/STA_ssid")
result.stamac=box.query("wlan:settings/STA_mac_master")
result.pskvalue=box.query("wlan:settings/STA_pskvalue")
result.staenc=box.query("wlan:settings/STA_encryption")
end
end
return result
end
function isp.over_lan1(id)
local ch=isp.characteristic(id,"box:settings/opmode")or""
return ch:find("opmode_eth_")==1
end
local medium_translate={
'Undefined','ADSL','VDSL','LTE','Cable','ATA','ATA_CABLE'
}
local function convert_medium(medium)
medium=bit.tobits(medium)
local result={}
for i,b in ipairs(medium)do
if b==1 then
table_insert(result,medium_translate[i]or tostring(i))
end
end
return array.truth(result)
end
function isp.medium(id)
id=id or isp.activeprovider()
return list[id]and list[id].medium
end
function isp.is_dsl(id)
if isp.is_other(id)then
return false
end
local m=isp.medium(id)
if m and m.Undefined then
return not isp.over_lan1(id)
end
return m and(m.Undefined or m.ADSL or m.VDSL)
end
function isp.is_cable(id)
local m=isp.medium(id)
return m and(m.Cable or m.ATA_CABLE)
end
function isp.is_extern(id)
local m=isp.medium(id)
return m and m.ATA and not m.ATA_CABLE
end
function isp.exclude_providers(fn)
excluded,index=array.filter(index,fn)
excluded=array.truth(excluded)
super_index=array.filter(super_index,function(id)return not excluded[id]end)
for s,p in pairs(super_list)do
for i=#p,1,-1 do
if excluded[p[i].id]then
table.remove(p,i)
end
end
end
isp.initial_provider=func.const(get_initial_provider())
end
function isp.is_excluded(id)
id=id or isp.activeprovider()
return excluded[id]
end
function isp.providers()
local i=0
local n=#index
local id
return function()
i=i+1
id=index[i]
if i<=n then return id,list[id]end
end
end
function isp.provider_ids()
return index
end
function isp.apn(id)
local val=isp.characteristic(id,"lted:settings/hw_info/ue/apn")
if val==""then return nil end
return val or""
end
function isp.count()
return#index
end
function isp.get_superproviders()
return super_index
end
function isp.is_real_super(id)
local s=super_list[id or""]
return s and#s>1
end
function isp.show_1und1_select()
return config.oem=='1und1'and(isp.unconfigured()or isp.is_ui())
end
local function split_characteristic(str)
str=str:gsub("connection0:pppoe:","connection0:")
local result={}
for i,s in ipairs(str:split(";"))do
local key,value=unpack(s:split("="))
if key and#key>0 then
result[key]=value or""
end
end
return result
end
local function read_characteristic(node)
local var=string.format("providerlist:settings/%s/characteristic",node)
return split_characteristic(box.query(var))
end
local function read_medium(node)
local var=string.format("providerlist:settings/%s/medium",node)
return convert_medium(box.query(var))
end
local function read_displayId2name()
local value=box.query("providerlist:settings/displayId2name")
value=string.split(value,";")
local result={}
for i,str in ipairs(value)do
local s=str:split("#")
result[s[1]]=s[2]
end
return setmetatable(result,{
__index=function(self,param)return isp.providername(param)end
})
end
local function read_super_list()
local displayId2name=read_displayId2name()
super_index,super_list={},{}
for i,id in ipairs(index)do
local idx=get_displayId(id)
if idx==""then idx=id end
if not super_list[idx]then
super_list[idx]={}
super_list[idx].listlevel=list[id].listlevel
table_insert(super_index,idx)
end
super_list[idx].txt=displayId2name[idx]
table_insert(super_list[idx],{
id=id,txt=displayId2name[id]
})
end
end
function isp.get_super_list()
return super_list or{}
end
local function read_list()
index,list={},{}
local tmp_list=general.listquery(
"providerlist:settings/providerlist/list(Id,providername,listlevel,displayId"
..")"
)
for i,p in ipairs(tmp_list)do
p.realid=p.Id
p.Id=isp.convert(p.Id)
p.listlevel=1+(tonumber(p.listlevel)or 0)
maxlistlevel=math.max(maxlistlevel,p.listlevel)
if not other.id and array.any(other.possible_ids,func.eq(p.Id))then
other.id=p.Id
end
table_insert(index,p.Id)
p=general.lazytable(p,read_characteristic,{characteristic={p._node}})
p=general.lazytable(p,read_medium,{medium={p._node}})
list[p.Id]=p
end
if not other.id then
other.id=other.default
list[other.id]={
realid=other.id,
Id=other.id,
listlevel=1,
characteristic={["box:settings/opmode"]="opmode_standard"}
}
table_insert(index,other.id)
end
if other.id and list[other.id]and isp.activeprovider()==other.id and isp.activename()~=""then
list.other_named=table.clone(list[other.id])
list.other_named.providername=isp.activename()
list.other_named.listlevel=1
list.other_named.characteristic=list[other.id].characteristic
list.other_named.medium=list[other.id].medium
table_insert(index,'other_named')
end
if other.id and list[other.id]then
list[other.id].providername=other.name
end
for i,item in ipairs(oma)do
if list[item.id]then
list[item.id].providername=item.name or""
end
end
end
local function sort_1und1_super_list(addoptions)
local tmp=nil
local sorted={{},{}}
local sep={}
sorted[1],sorted[2]=array.filter(super_index,isp.is_ui)
table_insert(sorted[1],'more')
tmp,sorted[2]=array.filter(sorted[2],isp.is_other)
sep,sorted[2]=array.filter(sorted[2],isp.is_oma)
utf8.sort(sorted[2],function(id)return super_list[id].txt end)
if other.id then
table_insert(sorted[2],other.id)
end
for i,opt in ipairs(addoptions)do
table_insert(sep,opt.id)
end
if#sep>0 then
table_insert(sep,1,"")
end
sorted[2]=array.cat(sorted[2],sep)
if#sorted[1]>0 then
table_insert(sorted[1],1,'tochoose')
end
if#sorted[2]>0 then
table_insert(sorted[2],1,'tochoose2')
end
return sorted
end
local function sort_super_list(addoptions)
local sorted={{},{}}
local sep={}
for i,id in ipairs(super_index)do
if not isp.is_other(id)then
if isp.is_oma(id)then
table_insert(sep,id)
else
table_insert(sorted[super_list[id].listlevel],id)
end
end
end
if list.other_named then
table_insert(sorted[1],1,'other_named')
end
utf8.sort(sorted[2],function(id)return super_list[id].txt end)
if#sorted[2]==0 then
utf8.sort(sorted[1],function(id)return super_list[id].txt end)
end
for i,opt in ipairs(addoptions)do
table_insert(sep,opt.id)
end
if#sep>0 then
table_insert(sep,1,"")
end
local other_listlevel=1
if other.id then
other_listlevel=list[other.id].listlevel
if#sorted[2]==0 then
other_listlevel=1
end
end
if#sorted[2]>0 then
table_insert(sorted[1],'more')
end
if other.id then
table_insert(sorted[other_listlevel],other.id)
end
sorted[1]=array.cat(sorted[1],sep)
if#sorted[1]>0 then
table_insert(sorted[1],1,'tochoose')
end
if#sorted[2]>0 then
table_insert(sorted[2],1,'tochoose2')
end
return sorted
end
function isp.write_provider_select(html_id,html_name,curr_provider)
curr_provider=curr_provider or isp.initial_provider()
local sel=html.select{id=html_id,name=html_name}
local option
for id in isp.providers()do
option=html.option{value=id,isp.providername(id)}
option.selected=curr_provider==id
sel.add(option)
end
sel.write()
end
function isp.write_radios(params)
params.id=params.id or"uiProvider"
params.name=params.name or"provider"
local addoptions=params.addoptions or{}
local explain=params.explain or func.const(nil)
local curr_provider=params.curr_provider or isp.initial_provider()
local curr_super=get_displayId(curr_provider)
if curr_super==""then
curr_super=curr_provider
end
local cnt=isp.count()+#addoptions
if cnt<2 then
html.input{type='hidden',id=params.id,name=params.name,value=curr_provider}.write()
return
end
local sorted=table.clone(index)
table_insert(sorted,1,"tochoose2")
table_insert(sorted,1,"tochoose")
for i,opt in ipairs(addoptions)do
table_insert(sorted,opt.id)
end
local names={}
names[""]=string.rep("-",55)
names.tochoose=TXT([[{?7127:836?}]])
names.tochoose2=names.tochoose
for i,opt in ipairs(addoptions)do
names[opt.id]=opt.name
end
local i,selected=array.find(sorted,func.eq(curr_provider))
selected=selected or'tochoose'
local name=params.name
local radio_id=params.id
for i,id in ipairs(sorted)do
local html_id=radio_id..":"..id
local super_id=get_displayId(id)
local hide=false
if super_id==""then
super_id=id
hide=true
end
hide=hide or#super_list[super_id]<2
local checked=selected==id
if hide then
html.div{style="display:none;",
html.input{type="radio",name="provider",value=id,id=html_id,checked=checked}
}.write()
else
html.div{class="formular super_"..super_id,
html.input{type="radio",name="provider",value=id,id=html_id,checked=checked},
html.label{['for']=html_id,names[id]or isp.providername(id)},
explain(id)
}.write()
end
end
end
function isp.write_super_select(params)
params.id=params.id or"uiSuperprovider"
params.name=params.name or"superprovider"
params.label=params.label or""
local addoptions=params.addoptions or{}
local curr_provider=params.curr_provider or isp.initial_provider()
local curr_super=get_displayId(curr_provider)
if curr_super==""then
curr_super=curr_provider
end
local cnt=#super_index+#addoptions
if cnt<2 then
return
end
local sorted={}
if isp.show_1und1_select()then
sorted=sort_1und1_super_list(addoptions)
else
sorted=sort_super_list(addoptions)
end
if#sorted>1 and#sorted[2]==0 then
table.remove(sorted,2)
end
local names={}
names[""]=string.rep("-",55)
names.tochoose=TXT([[{?7127:198?}]])
names.tochoose2=names.tochoose
names.more=TXT([[{?7127:155?}]])
for i,opt in ipairs(addoptions)do
names[opt.id]=opt.name
end
local i,selected1,selected2
i,selected1=array.find(sorted[1],func.eq(curr_super))
i,selected2=array.find(sorted[2],func.eq(curr_super))
selected1=selected1 or'more'
selected2=selected2 or'tochoose2'
local sel={}
for i=1,#sorted do
local second=i>1
sel[i]=html.select()
sel[i].id=second and params.id..tostring(i)or params.id
sel[i].name=second and params.name..tostring(i)or params.name
if params.disabled then
sel[i].disabled=true
sel[i].style="cursor: wait;"
end
local classes={}
if second then
table_insert(classes,"secondselect")
if selected1~='more'then
table_insert(classes,"invisible")
end
end
if#classes>0 then
sel[i].class=table_concat(classes," ")
end
local option
local selected=second and selected2 or selected1
for j,id in ipairs(sorted[i])do
option=html.option{value=id,names[id]or super_list[id].txt}
option.disabled=id==""
option.selected=selected==id
sel[i].add(option)
end
end
if params.label then
html.label{['for']=sel[1].id,params.label}.write()
end
sel[1].write()
if sel[2]then
html.br().write()
if params.label then
html.label{['for']=sel[2].id}.write()
end
sel[2].write()
end
end
read_list()
read_super_list()
