--[[Access denied<?lua
    box.end_page()
?>?>]]
require"general"
require"lualib"
if config.TIMERCONTROL then
require"timer"
else
return
end
require"textdb"
require"cmtable"
require"html"
filter={}
local data=general.lazytable({},general.listquery,{
profiles={"filter_profile:settings/profile/list("
.."UID,name,comment,timeprofile_id,ruleset_id,internet_ruleset_id"
..",ruleset_id_without_timeprofile,filter_https_also"
..",bpjm_filter_enabled,blacklist_enabled,whitelist_enabled"
..",share_budget,budget_time_monday,budget_time_tuesday,budget_time_wednesday"
..",budget_time_thursday,budget_time_friday,budget_time_saturday,budget_time_sunday"
..",disallow_guest"
..")"
},
users={"user:settings/user/list("
.."UID,type,name,comment,filter_profile_UID,hostname"
..",today_time,this_month_time,deleted"
..")"
},
landevices={"landevice:settings/landevice/list("
.."name,ip,UID,guest,user_UIDs"
..")"
},
autousers={"autouser:status/autouser/list("
.."type,name,hostname"
..")"
}
})
local timer_idx="kisi"
timer.read_kids(timer_idx)
local fixed_profiles={
filtprof1={
name=TXT([[{?929:856?}]]),
editable=true,
budget_possible=false
},
filtprof2={
name=TXT([[{?929:449?}]]),
editable=true,
budget_possible=false
},
filtprof3={
name=TXT([[{?929:556?}]]),
editable=false,
budget_possible=false
},
filtprof4={
name=TXT([[{?929:235?}]]),
editable=false,
budget_possible=false
}
}
local fixed_uids={
standard="filtprof1",
guest="filtprof2",
unlimited="filtprof3",
never="filtprof4"
}
function filter.fixed_profile_uid(which)
return fixed_uids[which or""]
end
function filter.is_fixed(profile)
return fixed_profiles[profile.UID]~=nil
end
function filter.budget_possible(profile)
local fixed=fixed_profiles[profile.UID]
return not fixed or fixed.budget_possible
end
function filter.editable(profile)
local fixed=fixed_profiles[profile.UID]
return not fixed or fixed.editable
end
function filter.profile_name(profile)
local fixed=fixed_profiles[profile.UID]
return fixed and fixed.name or profile.name or""
end
function filter.fixed_profile_name(fixed_uid)
local fixed=fixed_profiles[fixed_uid]
return fixed and fixed.name or""
end
local function sorted_fixed_uids()
local uids=table.keys(fixed_profiles)
table.sort(uids)
return uids
end
function filter.sort_profiles()
require"utf8"
utf8.sort(data.profiles,func.get("name"))
local fixed_uids=sorted_fixed_uids()
local idx
for i=#fixed_uids,1,-1 do
idx=array.find(data.profiles,func.eq(fixed_uids[i],"UID"))
if idx and idx>1 then
table.insert(data.profiles,1,table.remove(data.profiles,idx))
end
end
end
function filter.profilelist()
return data.profiles
end
function filter.refresh_data()
for key in pairs(data)do
data[key]=nil
end
end
function filter.get_profile(uid)
local i,p=array.find(data.profiles,func.eq(uid,"UID"))
return p or{}
end
function filter.get_profile_template(uid)
uid="filtprof3"
local p=table.clone(filter.get_profile(uid))
p.UID=nil
p._node=nil
p.name=""
return p
end
local daystr={"monday","tuesday","wednesday","thursday","friday","saturday","sunday"}
local today=((os.date("*t").wday+5)%7)+1
function filter.get_budget(profile)
local result={}
local value
for i,day in ipairs(daystr)do
value=tonumber(profile["budget_time_"..day])or 0
if value==0 then value=86400 end
table.insert(result,{
value=value,
day=day,
hours=tostring(math.floor(value/3600)),
minutes=string.format("%02d",math.floor((value%3600)/60))
})
end
return result
end
function filter.get_budget_today(profile)
if filter.budget_possible(profile)then
local value=tonumber(profile["budget_time_"..daystr[today]])or 0
if value==0 then value=86400 end
return value
end
return 86400
end
function filter.budget_restriction(profile)
if filter.budget_possible(profile)then
for i,budget in ipairs(filter.get_budget(profile))do
if budget.value<86400 then
return true
end
end
end
return false
end
function filter.budget_restriction_today(profile)
if filter.budget_possible(profile)then
return filter.get_budget_today(profile)<86400
end
return false
end
function filter.time_allowed(profile)
local id=tonumber(profile.timeprofile_id)or 0
local limited=false
if id==0 then
if profile.ruleset_id_without_timeprofile=="1"then
return"never"
end
else
local never=true
for day=1,7 do
local x=timer.allowed_day(timer_idx,id,day)
if x~="unlimited"then
limited=true
end
if x~="never"then
never=false
end
end
if never then return"never"end
end
if limited then return"limited"end
return"unlimited"
end
function filter.time_allowed_now(profile)
local id=tonumber(profile.timeprofile_id)or 0
if id==0 then
return profile.ruleset_id_without_timeprofile=="0"
else
return timer.now_allowed(timer_idx,id)
end
end
function filter.time_allowed_today(profile)
local id=tonumber(profile.timeprofile_id)or 0
if id==0 then
return profile.ruleset_id_without_timeprofile=="0"
else
return timer.entire_day(timer_idx,id)
end
end
function filter.max_time_allowed_today(profile)
local id=tonumber(profile.timeprofile_id)or 0
if id==0 then
return profile.ruleset_id_without_timeprofile=="0"and 86400 or 0
else
return timer.max_allowed_today(timer_idx,id)
end
end
function filter.timeprofile_unique(profile)
local timeprofile_id=tonumber(profile.timeprofile_id)or 0
local uid=profile.uid
if timeprofile_id~=0 then
timeprofile_id=tostring(timeprofile_id)
for i,p in ipairs(data.profiles)do
if p.UID~=uid and timeprofile_id==p.timeprofile_id then
return false
end
end
return true
end
return false
end
function filter.used_names(ignore_uid)
local result={}
if ignore_uid==""then ignore_uid=nil end
for i,p in ipairs(data.profiles)do
if ignore_uid~=p.UID then
local tmp=filter.profile_name(p)
if#tmp>0 then result[tmp:lower()]=true end
end
end
return result
end
function filter.any_filterlist(profile)
return profile.whitelist_enabled=="1"
or profile.blacklist_enabled=="1"
or profile.bpjm_filter_enabled=="1"
end
function filter.get_ruleset_id(profile)
local id=tonumber(profile.internet_ruleset_id)or 0
if id>1 then
return tostring(id)
end
end
function filter.get_ruleset_node(id)
local list=general.listquery("internet_ruleset:settings/internet_ruleset/list(id)")
for i,rule in ipairs(list)do
if rule.id==id then
return rule._node
end
end
end
function filter.create_ruleset_id_node()
local list=general.listquery("internet_ruleset:settings/internet_ruleset/list(id)")
table.sort(list,function(item1,item2)
local n1=tonumber(item1.id)
if not n1 then return true end
local n2=tonumber(item2.id)
if not n2 then return false end
return n1<n2
end
)
local id=2
for i,rule in ipairs(list)do
if rule.id==tostring(id)then
id=id+1
end
end
local node=box.query("internet_ruleset:settings/internet_ruleset/newid")
return id,node
end
local ruleset_nodes={}
for i,rule in ipairs(general.listquery("internet_ruleset:settings/internet_ruleset/list(id)"))do
ruleset_nodes[rule.id]=rule._node
end
local netapps=general.listquery("netapp:settings/profile/list(name,profile_id)")
function filter.netapplist(profile)
local ruleset_node=ruleset_nodes[profile.internet_ruleset_id]
local appids={}
if ruleset_node then
appids=general.listquery("internet_ruleset:settings/"..ruleset_node.."/filter_list/entry/list(name)")
appids=array.map(appids,func.get("name"))
appids=array.truth(appids)
end
local apps=array.filter(netapps,function(app)return appids[app.profile_id]end)
return array.map(apps,func.get("name"))
end
function filter.any_netapp(profile)
local result=false
local ruleset_node=ruleset_nodes[profile.internet_ruleset_id]
if ruleset_node then
local cnt=box.query("internet_ruleset:settings/"..ruleset_node.."/filter_list/entry/count")
cnt=tonumber(cnt)or 0
result=cnt>0
end
return result
end
local str_empty=[[ — ]]
local filterlist_txt=general.lazytable({},TXT,{
white={[[{?929:862?}]]},
black={[[{?929:989?}]]},
bpjm={[[{?929:520?}]]}
})
function filter.display_filterlist(profile)
local str={}
if profile.whitelist_enabled=="1"then
table.insert(str,filterlist_txt.white)
end
if profile.blacklist_enabled=="1"then
table.insert(str,filterlist_txt.black)
end
if profile.bpjm_filter_enabled=="1"then
table.insert(str,filterlist_txt.bpjm)
end
str=table.concat(str,", ")
if#str==0 then str=str_empty end
return str
end
local share_budget_txt=general.lazytable({},TXT,{
["1"]={[[{?929:143?}]]},
["0"]={[[{?929:956?}]]}
})
function filter.display_share_budget(profile)
if not filter.budget_possible(profile)then
return str_empty
end
return share_budget_txt[profile.share_budget]
end
function filter.display_apps(profile)
local apps=filter.netapplist(profile)
if#apps==0 then
return str_empty
end
local container=html.fragment()
for i,str in ipairs(apps)do
if i<#apps then str=str..", "end
container.add(html.span{str})
end
return container
end
local time_txt=general.lazytable({},TXT,{
never={[[{?929:403?}]]},
limited={[[{?929:513?}]]},
unlimited={[[{?929:773?}]]}
})
function filter.display_time_restriction(profile)
local allowed=filter.time_allowed(profile)
if allowed=="unlimited"and filter.budget_restriction(profile)then
allowed="limited"
end
return time_txt[allowed]or""
end
local user_type={
ip_user="1",
pc_user="2",
default_user="3",
guest_user="4"
}
function filter.is_user_type(user,value)
user=user or{}
if value then
return user.type==value or user.type==user_type[value]
end
return false
end
function filter.user_type_value(type_name)
return user_type[type_name or""]or""
end
function filter.read_userlist()
local list={ip_user={},pc_user={},default_user={}}
local ip_idx={}
for i,user in ipairs(data.users)do
if user.type==user_type.ip_user then
table.insert(list.ip_user,user)
ip_idx[user.name]=#list.ip_user
elseif user.type==user_type.pc_user then
table.insert(list.pc_user,user)
elseif user.type==user_type.guest_user then
list.guest_user=user
elseif user.type==user_type.default_user then
list.default_user=user
end
end
for i,device in ipairs(data.landevices)do
if device.guest~="1"and device.ip~=""then
local idx=ip_idx[device.ip]
if idx then
list.ip_user[idx].hostname=device.name
else
table.insert(list.ip_user,{
landevice=device.UID,
name=device.ip,
hostname=device.name,
type=user_type.ip_user
})
end
end
end
for i,autouser in ipairs(data.autousers)do
table.insert(list.pc_user,{
autouser=autouser._node,
name=autouser.name,
type=autouser.type
})
end
return list
end
local function get_users_by_profile(profile_id)
local list=filter.read_userlist()
local result=array.filter(list.pc_user,func.eq(profile_id,"filter_profile_UID"))
result=array.cat(result,
array.filter(list.ip_user,func.eq(profile_id,"filter_profile_UID"))
)
return result
end
function filter.list_by_profile(profile_id)
profile_id=profile_id or""
local list={}
if profile_id=='standard'or profile_id==fixed_uids.standard then
for i,device in ipairs(data.landevices)do
if device.guest~="1"and device.user_UIDs==""then
table.insert(list,device)
end
end
elseif profile_id=='guest'or profile_id==fixed_uids.guest then
for i,device in ipairs(data.landevices)do
if device.guest=="1"then
table.insert(list,device)
end
end
elseif profile_id==""then
for i,autouser in ipairs(data.autousers)do
table.insert(list,autouser)
end
else
local users=get_users_by_profile(profile_id)
for i,user in ipairs(users)do
if profile_id==user.filter_profile_UID then
table.insert(list,user)
end
end
end
return list
end
function filter.get_displayname(user)
user=user or{}
if user.hostname and user.hostname~=""then
return user.hostname
end
return user.name or""
end
function filter.gethtml_list_by_profile(profile)
local uid=profile.UID
local result=html.fragment()
result.add(html.hr{})
result.add(html.h4{id="uiUserlistAnchor",
TXT([[{?929:28?}]])
})
local list={}
local p,tbl
if uid then
list=filter.list_by_profile(uid)
if#list>0 then
p=html.p{
TXT([[{?929:302?}]])
}
tbl=html.table{class="zebra"}
utf8.sort(list,func.get("name",""))
for i,user in ipairs(list)do
tbl.add(html.tr{html.td{filter.get_displayname(user)}})
end
end
end
if not uid or#list==0 then
p=html.p{
TXT([[{?929:504?}]])
}
end
result.add(
html.div{class="formular",p,tbl}
)
if uid~=filter.fixed_profile_uid('guest')then
result.add(html.div{class="formular",
html.strong{
TXT([[{?txtHinweis?}]])
},
html.p{
TXT([[{?929:702?}]])
}
})
end
return result
end
function filter.get_user_profile(user)
if not user.autouser then
local uid=user.filter_profile_UID
if user.landevice then
uid=filter.fixed_profile_uid("standard")
end
if user.type==user_type.guest_user then
uid=filter.fixed_profile_uid('guest')
end
return filter.get_profile(uid)
end
end
local autouser_profile_name=[[{?929:44?}]]
function filter.get_profile_display(user)
if user.autouser then
return TXT(autouser_profile_name)
end
local p=filter.get_user_profile(user)
return filter.profile_name(p)
end
function filter.profile_select(user,attributes)
user=user or{}
attributes=attributes or{}
if user.type~=user_type.guest_user then
attributes.name=attributes.name or"profile"
local sel=html.select(attributes)
local exclude=array.truth{
filter.fixed_profile_uid('guest')
}
filter.sort_profiles()
local curr=filter.get_user_profile(user)or{UID=""}
for i,p in ipairs(data.profiles)do
if not exclude[p.UID]then
sel.add(html.option{
value=p.UID,
selected=curr.UID==p.UID,
filter.profile_name(p)
})
end
end
if user.type==user_type.pc_user then
sel.add(html.option{
value="",
selected=curr.UID=="",
TXT(autouser_profile_name)
})
end
return sel
end
end
local user_time_txt=general.lazytable({},TXT,{
unlimited={[[{?929:999?}]]},
limited={[[{?929:515?}]]},
notallowed={[[{?929:684?}]]}
})
function filter.get_allowed(user)
if user.autouser then
return""
end
local p=filter.get_user_profile(user)
local time_unlimited=filter.time_allowed_today(p)
local budget_unlimited=not filter.budget_restriction_today(p)
if time_unlimited and budget_unlimited then
if filter.any_filterlist(p)or filter.any_netapp(p)then
return user_time_txt.limited
else
return user_time_txt.unlimited
end
end
local now_allowed=filter.time_allowed_now(p)
local budget=filter.get_budget_today(p)
local used=tonumber(user.today_time)or 0
if now_allowed and used<budget then
return user_time_txt.limited
else
return user_time_txt.notallowed
end
end
local function sec2hhmm(s)
return string.format(
"%02d:%02d",
math.floor(s/3600),
math.floor((s%3600)/60)
)
end
function filter.get_online_time(user)
if user.autouser then
return""
end
local p=filter.get_user_profile(user)
local time_unlimited=filter.time_allowed_today(p)
local budget_unlimited=not filter.budget_restriction(p)
if not budget_unlimited then
budget_unlimited=not filter.budget_restriction_today(p)
end
if time_unlimited and budget_unlimited then
return TXT([[{?929:447?}]])
end
local now_allowed=filter.time_allowed_now(p)
local budget=filter.get_budget_today(p)
local max_time=filter.max_time_allowed_today(p)
local used=tonumber(user.today_time)or 0
local max_usable=math.min(budget,max_time)
local usedstr=general.sprintf(
TXT([[{?929:538?}]]),
sec2hhmm(used),sec2hhmm(max_usable)
)
local used_percent=math.round(used*100/max_usable,2)
if not now_allowed or used>=max_usable then
usedstr=TXT([[{?929:537?}]])
used_percent=100
end
used_percent=math.min(100,used_percent)
return html.span{title=usedstr,
html.span{style="width:"..tostring(used_percent).."%;"}
}
end
function filter.any_restriction(user)
if not user or user.autouser then
return false
end
local p=filter.get_user_profile(user)
if filter.time_allowed(p)~="unlimited"then
return true
end
if filter.budget_restriction(p)then
return true
end
if filter.any_filterlist(p)then
return true
end
if filter.any_netapp(p)then
return true
end
return false
end
local newid
local function get_newid()
if not newid then
newid=box.query("user:settings/user/newid")
else
local id=tonumber(newid:gsub("user","")or-1)+1
newid=string.format("user%d",id)
end
return newid
end
local function get_user_webvar(user,do_not_create)
if not(user.landevice or user.autouser)then
if user.webvar then
return user.webvar
end
if user.UID then
return string.format("user:settings/user[%s]",user.UID)
end
end
if not do_not_create then
return string.format("user:settings/%s",get_newid())
end
end
local function create_user(saveset,user)
local webvar=get_user_webvar(user)
if not(user.landevice or user.autouser)then
return webvar
end
cmtable.add_var(saveset,webvar.."/name",user.name or"")
cmtable.add_var(saveset,webvar.."/type",user.type or"")
return webvar
end
local function delete_user(saveset,user)
if not(user.landevice or user.autouser)then
local webvar=get_user_webvar(user,true)
if webvar then
webvar=string.gsub(webvar,"settings","command")
cmtable.add_var(saveset,webvar,"delete")
end
end
end
local function do_delete(user,profile_uid)
if user.type==user_type.ip_user then
return profile_uid==filter.fixed_profile_uid('standard')
elseif user.type==user_type.pc_user then
return profile_uid==""
end
return false
end
local function profile_changed(user,profile_uid)
local result=true
if not user.filter_profile_UID then
if user.landevice then
result=profile_uid~=filter.fixed_profile_uid('standard')
elseif user.autouser then
result=profile_uid~=""and profile_uid~=nil
end
else
result=profile_uid~=user.filter_profile_UID
end
return result
end
function filter.save_profiles(saveset,delset,savelist)
for i,item in ipairs(savelist or{})do
if item.user and item.profile_uid then
if profile_changed(item.user,item.profile_uid)then
if do_delete(item.user,item.profile_uid)then
delete_user(delset,item.user)
else
local webvar=create_user(saveset,item.user)
cmtable.add_var(saveset,webvar.."/filter_profile_UID",item.profile_uid)
end
end
end
end
end
function filter.save_profile(saveset,user,profile_uid)
filter.save_profiles(saveset,saveset,{{user=user,profile_uid=profile_uid}})
end
