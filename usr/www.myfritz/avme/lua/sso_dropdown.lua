--[[Access denied<?lua
    box.end_page()
?>?>?>?>]]
-- de-first -begin  
require"html"
require"textdb"
sso_dropdown={}
local data={
username=box.query("rights:status/username"),
own_email=box.query("boxusers:settings/own_email"),
own_password=box.query("boxusers:settings/own_password"),
compatibility_mode=box.query("boxusers:settings/compatibility_mode"),
skip_auth_from_homenetwork=box.query("boxusers:settings/skip_auth_from_homenetwork")
}
local links={}
local saveerr={}
function sso_dropdown.init(params)
params=params or{}
links.logout=params.logout_link
links.logout_onclick=params.logout_onclick
links.email=params.email_link
links.password=params.password_link
end
function sso_dropdown.write_head()
local username=data.username or""
if string.find(username,"@")==1 then
username=""
end
if username==""then
username=TXT([[{?1440:426?}]])
end
html.span{id="sso_dropdown",class="hidelist",username}.write()
end
function sso_dropdown.write_list()
local list=html.div{id="sso_dropdown_list",style="display:none;"}
if string.find(data.username or"","@")~=1 then
list.add(html.p{html.a{
id="ssoChangeEmailLink",href=links.email or" ",TXT([[{?1440:173?}]])
}})
end
list.add(html.p{html.a{
id="ssoChangePasswordLink",href=links.password or" ",TXT([[{?1440:663?}]])
}})
list.add(html.p{html.a{
id="ssoLogoutLink",href=links.logout or" ",onclick=links.logout_onclick or"",TXT([[{?1440:319?}]])
}})
list.write()
end
function sso_dropdown.get_data(which)
return data[which]or""
end
local function check_password()
if data.own_password~=""and box.post.own_password==""then
saveerr.code=-1
saveerr.msg=TXT([[{?1440:236?}]])
return false
end
return true
end
function sso_dropdown.save_values()
if box.post.apply then
local saveset={}
if box.post.own_email then
table.insert(saveset,{
name="boxusers:settings/own_email",value=box.post.own_email
})
elseif box.post.own_password then
if check_password()then
if box.post.own_password=="****"then
saveerr.code=0
return true
else
table.insert(saveset,{
name="boxusers:settings/own_password",value=box.post.own_password
})
end
else
return false
end
else
return true
end
saveerr.code,saveerr.msg=box.set_config(saveset)
return saveerr.code==0
end
return false
end
function sso_dropdown.write_saveerror()
local code=tonumber(saveerr.code)
if code and code~=0 then
local errmsg
if saveerr.msg and saveerr.msg~=""then
errmsg=TXT([[{?1440:320?} %s]]):format(saveerr.msg)
else
errmsg=TXT([[{?1440:205?} %d]]):format(code)
end
html.div{class="saveerr",
TXT([[{?1440:686?}]]),
html.p{errmsg}
}.write()
end
end
