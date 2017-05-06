--[[Access denied<?lua
    box.end_page()
?>?>]]
require"js"
local g_email_data={
einsundeins={
name="1&1 DSL",
pattern={
[[^.*@online%.de$]],
[[^.*@onlinehome%.de$]],
[[^.*@sofort%-start%.de$]],
[[^.*@sofortstart%.de$]],
[[^.*@go4more%.de$]],
[[^.*@sofortsurf%.de$]],
[[^.*@sofort%-surf%.de$]]
},
poll=10,sslonly=false,
pop3srv="pop.1und1.de",pop3user="complete",pop3ssl=true,pop3port="995",
smtpsrv="smtp.1und1.de",smtpuser="complete",smtpssl=true,smtpport="587"
},
gmx={
name="GMX",
pattern={
[[^.*@gmx%..*$]]
},
poll=17,sslonly=false,
pop3srv="pop.gmx.net",pop3user="complete",pop3ssl=true,pop3port="995",
smtpsrv="mail.gmx.net",smtpuser="complete",smtpssl=true,smtpport="587"
},
web={
name="WEB.DE",
pattern={
[[^.*@web%.de$]],
[[^.*@email%.de$]]
},
poll=17,sslonly=false,
pop3srv="pop3.web.de",pop3user="user",pop3ssl=true,pop3port="995",
smtpsrv="smtp.web.de",smtpuser="user",smtpssl=true,smtpport="587"
},
tonline={
name="T-Online",
pattern={
[[^.*@t%-online%.de$]]
},
poll=10,sslonly=false,
pop3srv="securepop.t-online.de",pop3user="complete",pop3ssl=true,pop3port="995",
smtpsrv="securesmtp.t-online.de",smtpuser="complete",smtpssl=true,smtpport="587"
},
freenet={
name="Freenet",
pattern={
[[^.*@freenet%.de$]]
},
poll=17,sslonly=false,
pop3srv="mx.freenet.de",pop3user="complete",pop3ssl=true,pop3port="995",
smtpsrv="mx.freenet.de",smtpuser="complete",smtpssl=true,smtpport="587"
},
kdg={
name="Kabel Deutschland",
pattern={
[[^.*@kabelmail%.de*$]],
[[^.*@kabelmail%.net$]],
[[^.*@kabelsurfer%.com$]],
[[^.*@kabelsurfer%.de$]],
[[^.*@kdwelt%.de$]],
[[^.*@mail-buero%.de$]],
[[^.*@maksimo%.de$]],
[[^.*@oberchef%.de$]],
[[^.*@superkabel%.de$]],
[[^.*@supersein%.de$]]
},
poll=15,sslonly=false,
pop3srv="pop3.kabelmail.de",pop3user="complete",pop3ssl=false,
smtpsrv="smtp.kabelmail.de",smtpuser="complete",smtpssl=true
},
google={
name="Google",
pattern={
[[^.*@googlemail%.com$]],
[[^.*@gmail%.com$]]
},
poll=10,sslonly=true,
pop3srv="pop.googlemail.com",pop3user="user",pop3ssl=true,pop3port="995",
smtpsrv="smtp.googlemail.com",smtpuser="user",smtpssl=true,smtpport="587"
},
internode={
name="Internode",
pattern={
[[^.*@internode%.on%.net$]]
},
poll=10,sslonly=false,
pop3srv="mail.internode.on.net",pop3user="user",pop3ssl=true,
smtpsrv="mail.internode.on.net",smtpuser="user",smtpssl=true
},
default={
name="",
pattern={
[[^x$]]
},
poll=1,sslonly=false,
pop3srv="",pop3user="",pop3ssl=true,
smtpsrv="",smtpuser="",smtpssl=true
}
}
email_data={}
function email_data.get_default_port(which,ssl)
if which=="pop3"then
return ssl and"995"or"110"
elseif which=="smtp"then
return ssl and"465"or"25"
end
end
function email_data.split_server(value)
value=(value or""):split(":")
return value[1],value[2]
end
function email_data.get_edata()
local tab={}
if config.oem=="1und1"and false then
tab["einsundeins"]=g_email_data["einsundeins"]
tab["gmx"]=g_email_data["gmx"]
tab["web"]=g_email_data["web"]
tab["default"]=g_email_data["default"]
elseif config.country=="061"then
tab["internode"]=g_email_data["internode"]
tab["default"]=g_email_data["default"]
else
tab=g_email_data
end
for name,provider in pairs(tab)do
provider.pop3port=provider.pop3port or email_data.get_default_port("pop3",provider.pop3ssl)
provider.smtpport=provider.smtpport or email_data.get_default_port("smtp",provider.smtpssl)
end
return tab
end
function email_data.find_by_name(tab,name)
for i,elem in ipairs(tab)do
if(elem.name==name)then
return elem
end
end
return nil
end
function email_data.is_tonline_account(username)
for i,p in ipairs(g_email_data["tonline"].pattern)do
if string.find(username,p)then
return true
end
end
return false
end
function email_data.sort_array()
local results={}
local k={}
for a,o in pairs(g_email_data)do
if(a~="default"and email_data.find_by_name(result,o.name)==nil)then
table.insert(results,{name=o.name,value=a})
end
end
utf8.sort(results,function(item)return item.name end)
table.insert(results,{name=g_email_data.default.name,value="default"})
return results
end
function email_data.get_edata_entry_by_addr(addr)
local edata=email_data.get_edata()
local default={}
for n,v in pairs(edata)do
if n~="default"then
for i,p in ipairs(v.pattern)do
if string.find(addr,p)then
return v
end
end
end
end
return edata["default"]
end
function email_data.get_pattern_str_for_js(pattern_tab)
str=""
local pat=""
for n,v in pairs(pattern_tab)do
if str~=""then
str=str..[[|]]
end
pat=(v:sub(1)):gsub('%%%.','\\.')
pat=pat:gsub('%%%-','-')
str=str..pat
end
return[[/]]..str..[[/i]]
end
function email_data.get_table_as_js_array(tab)
local str=""
for n,v in pairs(tab)do
if str==""then
str=[[{]]
else
str=str..[[, ]]
end
str=str..[[ "]]..n..[[" : ]]
if n=="pattern"and type(v)=="table"then
str=str..email_data.get_pattern_str_for_js(v)
elseif type(v)=="table"then
str=str..email_data.get_table_as_js_array(v)
elseif type(v)=="string"then
str=str..[["]]..v..[[" ]]
else
str=str..tostring(v)
end
end
if str==""then
str=[[{]]
end
return str..[[}]]
end
function email_data.get_edata_as_js_arraystr()
local tab=email_data.get_edata()
local str=email_data.get_table_as_js_array(tab)
if str==""then
str=[[{}]]
end
return str
end
function email_data.write_edata_to_js()
box.out(email_data.get_edata_as_js_arraystr())
end
function email_data.get_default_ports_js()
return js.table{
pop3=email_data.get_default_port('pop3'),
pop3ssl=email_data.get_default_port('pop3',true),
smtp=email_data.get_default_port('smtp'),
smtpssl=email_data.get_default_port('smtp',true)
}
end
function email_data.write_default_ports_js()
box.out(email_data.get_default_ports_js())
end
return email_data
