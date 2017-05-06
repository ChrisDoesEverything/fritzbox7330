--[[Access denied<?lua
    box.end_page()
?>?>?>?>]]
require"general"
boxusers={}
boxusers=general.lazytable(boxusers,general.listquery,{
list={
"boxusers:settings/user/list("
.."UID,id,enabled,is_myself,name,email,password,is_tr069_remote_access_user"
..",box_admin_rights,nas_rights,phone_rights,dial_rights,homeauto_rights,vpn_access"
..")"
},
login_list={
"boxusers:settings/user/list("
.."UID,id,enabled,name,email,password,is_tr069_remote_access_user"
..")"
}
})
boxusers=general.lazytable(boxusers,box.query,{
skip_auth_from_homenetwork={"boxusers:settings/skip_auth_from_homenetwork"},
compatibility_mode={"boxusers:settings/compatibility_mode"},
password={"security:settings/password"}
})
local function do_count_admins()
return#array.filter(boxusers.list,function(user)
return user.enabled=="1"and user.box_admin_rights~="0"
end)
end
boxusers=general.lazytable(boxusers,do_count_admins,{
count_admins={}
})
function boxusers.refresh_list()
boxusers.list=nil
boxusers.login_list=nil
boxusers.count_admins=nil
end
function boxusers.rights()
local rights={"box_admin_rights"}
if config.FON then
table.insert(rights,"phone_rights")
end
if boxusers.nasrights_possible()then
table.insert(rights,"nas_rights")
end
if config.HOME_AUTO then
table.insert(rights,"homeauto_rights")
end
if config.VPN then
table.insert(rights,"vpn_access")
end
return rights
end
function boxusers.is_myself(user)
return tonumber(user.is_myself)==1
end
function boxusers.create_user()
local user={
enabled="1",name="",email="",password=""
}
for i,right in ipairs(boxusers.rights())do
user[right]="0"
end
return user
end
function boxusers.used_names(ignore_uid)
local result={}
if ignore_uid==""then ignore_uid=nil end
for i,user in ipairs(boxusers.list)do
if ignore_uid~=user.UID then
if#user.name>0 then result[user.name:lower()]=true end
if#user.email>0 then result[user.email:lower()]=true end
end
end
return result
end
function boxusers.get_user_by_name(name)
local i,user=array.find(boxusers.list,func.eq(name,"name"))
return user
end
function boxusers.convert_right(hasright,frominternet)
if not hasright then return"0"end
return frominternet and"5"or"3"
end
function boxusers.frominternet(user)
local cnt_rights=0
for i,right in ipairs(boxusers.rights())do
if right~="vpn_access"then
right=tonumber(user[right])or 0
if right>0 then
cnt_rights=cnt_rights+1
if right<5 then
return false
end
end
end
end
return cnt_rights>0
end
function boxusers.auth_mode()
if boxusers.skip_auth_from_homenetwork=="1"then
return"skip"
elseif boxusers.compatibility_mode=="1"then
return"compat"
end
return"user"
end
function boxusers.any_admin()
return boxusers.count_admins>0
end
function boxusers.is_last_admin(user)
if boxusers.count_admins<=1 then
return user.enabled=="1"and user.box_admin_rights~="0"
end
end
function boxusers.show_pwreminder()
if boxusers.compatibility_mode=="1"and boxusers.password==""then
return true
elseif boxusers.skip_auth_from_homenetwork=="1"and#boxusers.login_list==0 then
return true
end
return false
end
function boxusers.any_admin_frominternet()
return#array.filter(boxusers.list,function(user)
return user.enabled=="1"and tonumber(user.box_admin_rights)>3 and boxusers.frominternet(user)and user.is_tr069_remote_access_user=="0"
end)>0
end
local function read_dirs()
return general.listquery(
"storagedirectories:settings/directory/list("
.."path,status"
..")"
)
end
local function read_access(dir)
return general.listquery(
"storagedirectories:settings/"..dir._node.."/access/entry/list("
.."username,boxusers_UID,access_from_local,access_from_internet"
..",write_access_from_local,write_access_from_internet"
..")"
)
end
function boxusers.nasrights_possible()
return config.FTP or config.SAMBA or config.NAS
end
function boxusers.get_storagedirs()
local dirs={}
if boxusers.nasrights_possible()then
dirs=read_dirs()
for i,dir in ipairs(dirs)do
dir.access=read_access(dir)
end
end
return dirs
end
function boxusers.get_access(user,dir,frominternet)
local postfix=frominternet and"internet"or"local"
local read_var="access_from_"..postfix
local write_var="write_access_from_"..postfix
local i,access=array.find(dir.access,func.eq(user.UID,"boxusers_UID"))
if i and access then
return{
read=access[read_var]=="1"or access[write_var]=="1",
write=access[write_var]=="1"
}
end
end
return boxusers
