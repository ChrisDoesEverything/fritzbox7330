--[[Access denied<?lua
    box.end_page()
?>?>?>?>]]
local _={}
if not gl then gl={}end
if not gl.var then gl.var={}end
if not gl.bib then gl.bib={}end
gl.bib.lualib=require("lualib")
gl.bib.http=require("http")
gl.bib.log=require("log")
function _.auto_security_zone()
if string.find(box.glob.path,"nas",1,true)then
return"nas"
elseif string.find(box.glob.path,"myfritz",1,true)then
return"myfritz"
else
return"box"
end
end
_.security_obj={box={"BoxAdmin"},nas={"NAS"},myfritz={"NAS","Phone","HomeAuto"},all={}}
function _.init_sid_check()
if g_check_sid_zone and _.security_obj[g_check_sid_zone]then
gl.security_zone=g_check_sid_zone
else
gl.security_zone=_.auto_security_zone()
end
gl.from_internet=box.frominternet()
gl.username=(not gl.from_internet and box.query("boxusers:settings/last_homenetwork_username"))or""
if pg then
if pg.shareID and pg.shareID~=""then gl.shareID=pg.shareID end
if pg.user and pg.user~=""then gl.username=pg.user end
if pg.username and pg.username~=""then gl.username=pg.username end
if pg.response and pg.response~=""then gl.response=pg.response end
gl.logout=pg.logout~=nil
else
if box.get.shareID and box.get.shareID~=""then gl.shareID=box.get.shareID end
if box.post.shareID and box.post.shareID~=""then gl.shareID=box.post.shareID end
if box.get.user and box.get.user~=""then gl.username=box.get.user end
if box.get.username and box.get.username~=""then gl.username=box.get.username end
if box.post.username and box.post.username~=""then gl.username=box.post.username end
if box.get.response and box.get.response~=""then gl.response=box.get.response end
if box.post.response and box.post.response~=""then gl.response=box.post.response end
gl.logout=box.get.logout~=nil or box.post.logout~=nil
end
_.check_sid()
end
function _.check_sid()
gl.c_mode=(not gl.from_internet and box.query("boxusers:settings/compatibility_mode")=="1")or false
local skip_local_auth=(not gl.from_internet and box.query("boxusers:settings/skip_auth_from_homenetwork")=="1")or false
local password_set=false
if gl.c_mode or skip_local_auth then
if gl.c_mode then
password_set=box.query("security:settings/password")=="****"
end
gl.username=""
if not gl.response and not password_set then
gl.response=""
end
end
gl.login_errors={}
gl.login_errors_cnt=0
gl.skipauth_sidchanged=false
gl.logged_in,gl.userrights=_.logged_in(_.security_obj[gl.security_zone],gl.username,gl.response,gl.logout)
if gl.logged_in then
gl.username=box.query("rights:status/username")
gl.int_userid=tonumber(box.query("rights:status/userid"))or 0
gl.userid=box.query("rights:status/boxuser_UID")
if gl.int_userid==101 then
gl.show_logout=false
elseif gl.int_userid==100 and not password_set then
gl.show_logout=false
elseif gl.c_mode and not password_set and gl.username=="ftpuser"then
gl.show_logout=false
elseif gl.int_userid>109 and gl.int_userid<200 then
gl.show_logout=false
else
gl.show_logout=true
end
if skip_local_auth and box.glob.sid~=box.glob.inputsid then
gl.skipauth_sidchanged=true
end
gl.block_time=0
if g_check_sid_cb and type(g_check_sid_cb)=="function"then
g_check_sid_cb()
end
else
gl.show_logout=false
gl.false_username=box.query("rights:status/username",false)
if(gl.false_username and(gl.false_username=="<none>"or#gl.false_username<1))or gl.c_mode then
gl.false_username=false
end
gl.login_reason=tonumber(box.query("security:status/loginreason/"..box.glob.clientipaddress.."/"..box.glob.inputsid))or 0
gl.int_userid=0
gl.userid=""
gl.block_time=tonumber(box.query("security:status/login_blocked/"..gl.security_zone))or 128
if gl.response then
gl.login_errors.wrong_password=""
gl.login_errors_cnt=gl.login_errors_cnt+1
end
if g_check_sid_cb and type(g_check_sid_cb)=="function"then
g_check_sid_cb()
else
if box.get.xhr or(box.post.xhr and box.post.validate)then
require("http")
http.forbidden()
elseif box.post.xhr then
box.end_page()
else
require("http")
http.authorization_required()
end
end
end
end
function _.logged_in(security_obj_tab,username,response,logout)
local no_access,rights_tab=_.check_rights(security_obj_tab)
if no_access then
if username and type(username)=="string"and
response and type(response)=="string"and
security_obj_tab and type(security_obj_tab)=="table"then
box.login_user(username,response,security_obj_tab,gl.security_zone)
end
no_access,rights_tab=_.check_rights(security_obj_tab)
return(not no_access),rights_tab
else
if logout then
box.logout()
end
return(not logout),rights_tab
end
end
function _.check_rights(security_obj_tab)
local rights_tab={}
local no_access=true
if not security_obj_tab then return no_access,rights_tab end
if next(security_obj_tab)then
for i,obj in ipairs(security_obj_tab)do
rights_tab[obj]=tonumber(box.query("rights:status/"..obj))or 0
no_access=no_access and rights_tab[obj]==0
end
else
local rights_str=box.query("rights:status/objects")
if#rights_str>0 then
no_access=false
local rights_split_tab=string.split(rights_str,"|")
for cnt=1,#rights_split_tab,2 do
rights_tab[rights_split_tab[cnt]]=tonumber(rights_split_tab[cnt+1])or 1
end
end
end
return no_access,rights_tab
end
_.init_sid_check()
