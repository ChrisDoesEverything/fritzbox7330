--[[Access denied<?lua
box.end_page()
?>?>?>]]
module(...,package.seeall);
require("config")
local status_name={
["HTTP/1.0"]={
[302]="Moved Temporarily",
[303]="See Other",
[307]="Temporary Redirect"
},
["HTTP/1.1"]={
[303]="See Other",
[307]="Temporary Redirect"
}
}
header={
user_agent=os.getenv("HTTP_USER_AGENT")or"",
cookie=os.getenv("HTTP_COOKIE")or"",
language=os.getenv("HTTP_ACCEPT_LANGUAGE")or"",
method=os.getenv("REQUEST_METHOD")or"GET"
}
function redirect(page,code)
code=code or 303
local loc=page or""
loc=loc:gsub("%c","")
local proto="HTTP/1.0"
local ps3=string.match(header.user_agent,"PLAYSTATION 3")
local is_online_help=loc:find(config.ONLINEHELP_URL,1,true)==1
if not is_online_help then
if gl and gl.logged_in and not string.find(page,"%?sid=")and not string.find(page,"&sid=")then
if string.find(loc,"?")then
loc=loc.."&"
else
loc=loc.."?"
end
loc=loc.."sid="..box.glob.sid
end
end
if loc:find("/",1,true)~=1 and not is_online_help then
loc="/"..loc
end
if string.sub(loc,1,5)~="http:"and string.sub(loc,1,6)~="https:"then
local prefix="http"
if box.glob.secure then
prefix="https"
end
loc=prefix.."://"..box.glob.host..loc
end
box.header(
proto.." "..tostring(code).." "..status_name[proto][code].."\n"..
"Content-Length: 0\n"..
"Location: "..loc.."\n"..
"\n"
)
box.end_page()
end
function redirect_from_https(page,code)
local str=[[<!DOCTYPE html>
<html>
<head>
<title></title>
<meta http-equiv="REFRESH" content="0;url=]]..page..[[">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
</HEAD>
<BODY>
</BODY>
</HTML>]]
box.out(str)
box.end_page()
end
function forbidden()
local header=box.glob.server_protocol.." 403 Forbidden\n"
header=header.."Content-Length: 0\n\n"
box.header(header)
box.end_page()
end
function authorization_required()
box.header("Content-Type: application/json; charset=utf-8;\nExpires: -1\n\n")
box.out([[
{"AuthorizationRequired": "1"}
]])
box.end_page()
end
function url_encode(str)
str=string.gsub(str,"([^%w%-_%.~ ])",
function(c)
return string.format("%%%02X",string.byte(c))
end)
str=string.gsub(str," ","+")
return str
end
function url_param(name,value)
return url_encode(name).."="..url_encode(value or"")
end
function get_back_to_page(default_site)
local back_to_page=box.get.back_to_page or box.post.back_to_page or""
if""==back_to_page then
if"string"~=type(default_site)then
default_site="/home/home.lua"
end
back_to_page=default_site
end
return back_to_page
end
function get_user_agent()
return header.user_agent
end
