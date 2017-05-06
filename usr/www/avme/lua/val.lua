--[[Access denied<?lua
    box.end_page()
?>?>]]
module(...,package.seeall);
require("utf8")
require("ip")
require("js")
require("dbg")
require"general"
local read_prog
local to_camel
local lua_validate
local lua_filter
local js_validate
local js_filter
local js_filter_end
ret={
ok="ok",
notfound="notfound",
empty="empty",
different="different",
notdifferent="notdifferent",
outofrange="outofrange",
wrong="wrong",
format="format",
missing="missing",
tooshort="tooshort",
toolong="toolong",
toomuch="toomuch",
group="group",
outofnet="outofnet",
thenet="thenet",
broadcast="broadcast",
thebox="thebox",
nomask="nomask",
unsized="unsized",
notempty="notempty",
zero="zero",
notzero="notzero",
allzero="allzero",
ewemeternet="ewemeternet",
leadchar="leadchar",
endchar="endchar",
reservednet="reservednet",
greaterthan="greaterthan",
equalerr="equalerr",
param="param"
}
msg={}
errors={}
function validate(v)
v.cb_validate=lua_validate
v.cb_filter=lua_filter
v.cb_filter_end=nil
return read_prog(v,1,true)
end
function ajax_validate(v)
local valresult=val.validate(g_val)
local answer={}
answer.ok=valresult==val.ret.ok
answer.validate=box.post.validate
if not answer.ok then
answer.alert=g_val.error_msg
answer.tomark=table.keys(g_val.error_names or{})
end
return valresult,answer
end
function write_js_checks_no_active(v)
v.cb_validate=js_validate
v.cb_filter=js_filter
v.cb_filter_end=js_filter_end
v.readall=true
read_prog(v,1,true)
end
function write_js_checks(v)
box.js("  if (val.active) val.active=false; else return true;\n")
write_js_checks_no_active(v)
end
function write_js_globals_for_ip_check()
if cb_get_boxip and type(cb_get_boxip)=="function"then
box.out([[var g_boxIp = "]]..cb_get_boxip()..[[";]])
else
box.out([[var g_boxIp = "]]..box.query('interfaces:settings/lan0/ipaddr')..[[";]])
end
if cb_get_netmask and type(cb_get_netmask)=="function"then
box.out([[var g_boxNetmask = "]]..cb_get_netmask()..[[";]])
else
box.out([[var g_boxNetmask = "]]..box.query('interfaces:settings/lan0/netmask')..[[";]])
end
end
function write_js_error_strings()
for check,msgs in pairs(val.msg)do
local name=to_camel("g_txt_"..check)
box.js("var "..name.." = new Array();\n")
for k,str in pairs(msgs)do
box.js(name.."[val."..k.."] = ")
box.out(js.quoted(str))
box.out(";\n")
end
end
end
function write_js_error_strings_ex()
for check,msgs in pairs(val.msg)do
local name=to_camel("g_txt_"..check)
box.js("var "..name.." = new Array();\n")
for k,str in pairs(msgs)do
box.js(name.."[val."..k.."] = ")
if type(str)=="table"then
box.out("jxl.sprintf(")
box.out(js.quoted(str[1]))
box.out([[,jxl.getText("]]..str[2]..[["));]])
else
box.out(js.quoted(str))
box.out(";\n")
end
end
end
end
function write_error_class(v,id,only_classname)
if not v then
return
end
if v.error_ids and v.error_ids[id]then
box.out(only_classname and" error"or[[ class="error"]])
end
end
function get_error_class(v,id)
if not v then
return
end
if v.error_ids and v.error_ids[id]then
return" error"
end
end
function write_html_msg(v,...)
if not v then
return
end
local classes=[[form_input_note ErrorMsg]]
if v.error_ids and next(v.error_ids)then
for _,id in ipairs{...}do
if type(id)=="string"and id=="cmd_vorn"then
classes=[[ErrorMsg]]
end
if(type(id)=="table")then
for i=1,#id do
local szID=id[i]
if v.error_ids[szID]then
box.out([[
              <p class="]]..classes..[[">]])
box.html(v.error_msg)
box.out("</p>\n")
return
end
end
else
if v.error_ids[id]then
box.out([[
            <p class="]]..classes..[[">]])
box.html(v.error_msg)
box.out("</p>\n")
return
end
end
end
end
end
function get_html_msg(v,...)
if not v then
return
end
local ret=""
if v.error_ids and next(v.error_ids)then
for _,id in ipairs{...}do
if v.error_ids[id]then
ret=[[<p class="form_input_note ErrorMsg">]]..box.tohtml(tostring(v.error_msg))..[[</p>]]
return ret
end
end
end
return ret
end
function get_html_msg_explain(v,...)
if not v then
return
end
local ret=""
if v.error_ids and next(v.error_ids)then
for _,id in ipairs{...}do
if v.error_ids[id]then
ret=[[<p class="form_input_explain ErrorMsg">]]..tostring(v.error_msg)..[[</p>]]
return ret
end
end
end
return ret
end
function get_attrs(v,id,clsstr)
if not v then
return
end
local ret=""
local className="error"
if clsstr then
className=className.." "..clsstr
end
if v.error_ids and v.error_ids[id]then
ret=[[ class="]]..className..[[" title="]]..tostring(v.error_msg)..[["]]
end
return ret
end
function write_attrs(v,id,clsstr)
box.out(get_attrs(v,id,clsstr))
end
function const_error(elems,errname)
if errname[1]and ret[errname[1]]then return ret[errname[1]]end
return ret.ok
end
function not_empty(elems)
if elems[1]==nil or elems[1].name==nil or box.post[elems[1].name]==nil then
return ret.notfound
elseif#box.post[elems[1].name]==0 then
return ret.empty
end
return ret.ok
end
function not_empty_or_absent(elems)
if elems[1]~=nil and elems[1].name~=nil and box.post[elems[1].name]~=nil and#box.post[elems[1].name]==0 then
return ret.empty
end
return ret.ok
end
function equal(elems)
if#elems<2 or box.post[elems[1].name]==nil then
return ret.notfound
end
if box.post[elems[1].name]~=box.post[elems[2].name]then
return ret.different
end
return ret.ok
end
function not_equals(elems,params)
if#elems<1 or box.post[elems[1].name]==nil or params==nil or#params<1 then
return ret.notfound
end
for index,value in ipairs(params)do
if(string.lower(value)==string.lower(box.post[elems[1].name]))then
return ret.equalerr
end
end
return ret.ok
end
function less_than(elems)
if#elems<2 or box.post[elems[1].name]==nil then
return ret.notfound
end
local value1=tonumber(box.post[elems[1].name])
local value2=tonumber(box.post[elems[2].name])
if(value1==nil or value2==nil)then
return ret.format
end
if value1==value2 then
return ret.equalerr
end
if value1>value2 then
return ret.greaterthan
end
return ret.ok
end
function not_equal_ip(elems)
if#elems<2 then
return ret.notfound
end
local ip1=ip.read_from_post(elems[1].name)
local ip2=ip.read_from_post(elems[2].name)
if ip1==ip2 then
return ret.notdifferent
end
return ret.ok
end
pr={
okz={pat=[[^0[2-9]%d*$]],reg=[[/^0[2-9]\d*$/]]},
anynonwhitespace={pat=[=[[^%s]]=],reg=[[/[^\s]/]]},
fonnum={pat=[[^%s*[%+]?[0-9%s/%-#\*]*$]],reg=[[/^\s*[\+]?[0-9#\*\s\/-]*$/]]},
fonnumex={pat=[[^%s*[%+]?[0-9%s/%-%(%)#\*]*$]],reg=[[/^\s*[\+]?[0-9#\*\s\/\(\)-]*$/]]},
sipnum={pat=[[^%s*[%+]?[%d%s/%-%(%)a-zA-Z]*$]],reg=[[/^\s*[\+]?[\d\s\/\(\)-a-z0-9]*$/i]]},
dectchar={pat=[[^[^%§]*$]],reg=[[/^[^\§]*$/i]]},
decimals={pat=[[^%d*$]],reg=[[/^\d*$/]]},
hexvalue={pat=[[^[a-fA-F0-9]*$]],reg=[[/^[a-f0-9]*$/i]]},
wepascii={pat=[[^[a-zA-Z0-9]*$]],reg=[[/^[a-z0-9]*$/i]]},
workgroupname={pat=[[^[a-zA-Z0-9%_%-]*$]],reg=[[/^[a-z0-9\_\-]*$/i]]},
nassharename={pat=[[^[a-zA-Z0-9%-%.]*$]],reg=[[/^[a-z0-9\-\.]*$/i]]},
fbname={pat=[[^[^%-][a-zA-Z0-9%-]*[^%-]$]],reg=[[/^[^\-][a-z0-9\-]*[^\-]$/i]]},
hostname={pat=[[^[^%-][a-zA-Z0-9%-]*[^%-]$]],reg=[[/^[^%-][a-z0-9\-]*[^%-]$/i]]},
name_ex={pat=[[^[äöüa-zA-Z0-9%-%(%)%s]*$]],reg=[[/^[äöüa-z0-9\-\(\)\s]*$/i]]},
pcname={pat=[[^[0-9]*[a-zA-Z%-]+[a-zA-Z0-9%-]*$]],reg=[[/^[0-9]*[a-z\-]+[a-z0-9\-]*$/i]]},
email={pat=[[^[%a%d%.%!%#%$%%%&%'%*%+%-%/%=%?%^%_%`%{%|%}%~]+@[%a%d%.%-]+%.%a%a%a?%a?%a?%a?$]],reg=[[/^[\w\.\!\#\$\%\&\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+@[\da-z\.\-]+\.[a-z]{2,6}$/i]]},
fqdn={pat=[[^[%a%d%.%-]+%.%a%a%a?%a?%a?%a?:?%d*$]],reg=[[/^[\da-z\.\-]+\.[a-z]{2,6}:?\d{0,5}$/i]]},
ipv4={pat=[[^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?$]],reg=[[/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/]]},
ipv4_port={pat=[[^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:?%d*$]],reg=[[/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:?\d{0,5}$/]]},
ipv6={pat=[[^%[?[%x:]+%]?:?%d*$]],reg=[[/^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/]]},
url={pat=[[^[a-zA-Z0-9%ß%ä%ö%ü%!%*%'%(%)%,%.%-%~%_%@%&%?%=%:%;%/%+%%%#%$]*$]],reg=[[/^[a-z0-9\ß\ä\ö\ü\!\*\'\(\)\,\.\-\~\_\@\&\?\=\:\;\/\+\%\#\$]*$/i]]},
dectpin={pat=[[^%d%d%d%d$]],reg=[[/^\d{4}$/]]},
boxusername={pat=[[^[a-zA-Z%-%._][a-zA-Z0-9%-%.%_ ]*$]],reg=[[/^[a-zA-Z\-\._][a-zA-Z0-9\-\.\_ ]*$/]]},
boxpassword={pat=[[^[a-zA-Z0-9 %!%"%#%$%%%&%'%(%)%*%+%,%-%.%/%:%;%<%=%>%?%@%[%\%]%^%_%`%{%|%}%~]*$]],reg=[[/^[a-zA-Z0-9 \!\"\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?@\[\\\]\^\_\`\{\|\}\~]*$/]]},
rdsstation={
pat=[[^[^%`%~%@%#%$%^%&%*%=%+%[%]%{%}%\%|%;%:%'%"%,%<%>%?%/]*$]],
reg=[[/[^\`\~@#$\^&\*=\+\[\]\{\}\\\|;:\'\",\<\>\?\/]/g]]
},
nlrradioname={
pat=[[^[0-9A-ZÄÖÜa-zäöü%!%#%"%%%&%'%[%]%(%)%*%+%,%-%.%/%:%;%<%=%>%?%@%`%~%_ ]*$]],
reg=[[/^[0-9A-ZÄÖÜa-zäöü\!#\"%&\'\[\]\(\)\*\+,\-\.\/:;<=>\?@`~_ ]*$/]]
}
}
function char_range_regex(elems,regex)
if not(regex[2])and pr[regex[1]]then
regex[1]=pr[regex[1]].pat or[[.*]]
end
local str=box.post[elems[1].name]
if str==nil then
return ret.notfound,-1
end
if not(string.find(str,regex[1]))then
return ret.outofrange,-1
end
return ret.ok,-1
end
function char_range(elems,range)
local min=tonumber(range[1])or 0
local max=tonumber(range[2])or 255
local str=box.post[elems[1].name]
if str==nil then
return ret.notfound,-1
end
for c=1,#str do
local code=str:byte(c)
if code<min or code>max then
return ret.outofrange,c
end
end
return ret.ok,-1
end
function f6rd_prefixlen(elems,params)
local masklen=box.post[elems[1].name]
local preflen=box.post[elems[2].name]
if(preflen+(32-masklen))>64 then
return ret.outofrange
end
return ret.ok
end
function num_range(elems,params)
local min=tonumber(params[1])or 0
local max=tonumber(params[2])or 65536
local sznumber=box.post[elems[1].name]
if sznumber==nil then
if(params[3]=="true")then
return ret.notfound
else
return ret.ok
end
end
if(#sznumber==0)then
if(params[3]=="true")then
return ret.empty
else
return ret.ok
end
end
local number=tonumber(sznumber)
if number==nil then
return ret.format
end
if number<min or number>max then
return ret.outofrange
end
return ret.ok
end
function max_num(elems,params)
local max=tonumber(params[1])or 65536
local sznumber=box.post[elems[1].name]
if sznumber==nil then
if(params[2]=="true")then
return ret.notfound
else
return ret.ok
end
end
if(#sznumber==0)then
if(params[2]=="true")then
return ret.empty
else
return ret.ok
end
end
local number=tonumber(sznumber)
if number==nil then
return ret.format
end
if number>max then
return ret.outofrange
end
return ret.ok
end
function min_num(elems,params)
local min=tonumber(params[1])or 0
local sznumber=box.post[elems[1].name]
if sznumber==nil then
if(params[2]=="true")then
return ret.notfound
else
return ret.ok
end
end
if(#sznumber==0)then
if(params[2]=="true")then
return ret.empty
else
return ret.ok
end
end
local number=tonumber(sznumber)
if number==nil then
return ret.format
end
if min>number then
return ret.outofrange
end
return ret.ok
end
function is_float(elems,params)
local sznumber=box.post[elems[1].name]
if sznumber==nil then
return ret.notfound
end
if(#box.post[elems[1].name]==0)then
return ret.empty
end
if(string.find(box.post[elems[1].name],"[a-fA-F-_;:'#+*~?<>]")~=nil)then
return ret.wrong
end
if(tonumber(params[1])==2)then
if((string.match(box.post[elems[1].name],"^%d?%d?%d?%.%d?%d?")==nil)and(string.match(box.post[elems[1].name],"^%d?%d?%d?%,%d?%d?")==nil))then
return ret.wrong
end
else
if(tonumber(params[1])==3)then
if((string.match(box.post[elems[1].name],"^%d?%d?%d?%.%d?%d?%d?")==nil)and(string.match(box.post[elems[1].name],"^%d?%d?%d?%,%d?%d?%d?")==nil))then
return ret.wrong
end
else
if((string.match(box.post[elems[1].name],"^%d?%d?%d?%.%d?%d?%d?%d?")==nil)and(string.match(box.post[elems[1].name],"^%d?%d?%d?%,%d?%d?%d?%d?")==nil))then
return ret.wrong
end
end
end
if(tonumber(box.post[elems[1].name])>tonumber(params[2]))then
return ret.outofrange
end
return ret.ok
end
function is_float_plus(elems,params,real_value)
local sznumber=box.post[elems[1].name]
if sznumber==nil then
return ret.notfound
end
if(#box.post[elems[1].name]==0)then
return ret.empty
end
sz_value=box.post[elems[1].name]
if(real_value~=nil)then
sz_value=tostring(real_value)
end
if(string.find(sz_value,"[a-fA-F_;:'#+*~?<>]")~=nil)then
return ret.wrong
end
if(tonumber(params[1])==2)then
if((string.match(sz_value,"^%d?%d?%d?%.%d?%d?")==nil)and(string.match(sz_value,"^%-%d?%d?%d?%.%d?%d?")==nil)and
(string.match(sz_value,"^%d?%d?%d?%,%d?%d?")==nil)and(string.match(sz_value,"^%-%d?%d?%d?%,%d?%d?")==nil))then
return ret.wrong
end
else
if(tonumber(params[1])==3)then
if((string.match(sz_value,"^%d?%d?%d?%.%d?%d?%d?")==nil)and(string.match(sz_value,"^%-%d?%d?%d?%.%d?%d?%d?")==nil)and
(string.match(sz_value,"^%d?%d?%d?%,%d?%d?%d?")==nil)and(string.match(sz_value,"^%-%d?%d?%d?%,%d?%d?%d?")==nil))then
return ret.wrong
end
else
if((string.match(sz_value,"^%d?%d?%d?")==nil)and(string.match(sz_value,"^%-%d?%d?%d?")==nil)and
(string.match(sz_value,"^%d?%d?%d?%.%d?%d?%d?%d?")==nil)and(string.match(sz_value,"^%-%d?%d?%d?%.%d?%d?%d?%d?")==nil)and
(string.match(sz_value,"^%d?%d?%d?%,%d?%d?%d?%d?")==nil)and(string.match(sz_value,"^%-%d?%d?%d?%,%d?%d?%d?%d?")==nil))then
return ret.wrong
end
end
end
local l_n_degree=tostring(sz_value)
local sz_degree,n_count=string.gsub(l_n_degree,[[,]],[[.]])
if(tonumber(sz_degree)>tonumber(params[2]))then
return ret.outofrange
end
return ret.ok
end
function is_valid_count_time(elems)
local n_hours=tonumber(box.post[elems[1].name])
local n_mins=tonumber(box.post[elems[2].name])
if((n_hours==0)and(n_mins==0))then
table.insert(marked,elems[1])
table.insert(marked,elems[2])
return ret.wrong
end
return ret.ok
end
function is_valid_date(elems)
local n_day=tonumber(box.post[elems[1].name])
local n_month=tonumber(box.post[elems[2].name])
local n_year=tonumber(box.post[elems[3].name])
return ret.ok
end
function is_valid_time(elems)
local n_hour=tonumber(box.post[elems[1].name])
local n_minutes=tonumber(box.post[elems[2].name])
return ret.ok
end
function least_one_checked(elems)
if((box.post[elems[1].name]==nil)and(box.post[elems[2].name]==nil))then
return ret.wrong
end
return ret.ok
end
function is_valid_degree(elems,param)
local n_degree=tonumber(box.post[elems[1].name])
local n_min=tonumber(box.post[elems[2].name])
local n_sec=tonumber(box.post[elems[3].name])
local to_compare=tonumber(param[1])
if(n_degree==to_compare)then
if(n_min==0)and(n_sec==0)then
return ret.ok
else
return ret.wrong
end
end
return ret.ok
end
function is_valid_float_degree(elems,param)
local n_value=box.post[elems[1].name]
n_result=string.find(n_value,'°')
if((n_result~=nil)and(tonumber(n_result)<tonumber(string.len(tostring(n_value))-1)))then
return ret.leadchar
end
real_value=nil
if(n_result~=nil)then
real_value=string.sub(n_value,1,(tonumber(n_result)-1))
end
res=is_float_plus(elems,param,real_value)
if(res~=ret.ok)then
return res
end
return ret.ok
end
function value_unallowalbe(elems,param)
local sz_value=tostring(box.post[elems[1].name])
local to_compare=tostring(param[1])
if(sz_degree==to_compare)then
return ret.wrong
end
return ret.ok
end
function fw_port_range(elems,params)
local res1=ret.ok
local res2=ret.ok
if(box.post[elems[1].name]==nil)or(#box.post[elems[1].name]==0)then
res1=ret.empty
end
if(box.post[elems[2].name]==nil)or(#box.post[elems[2].name]==0)then
res2=ret.empty
end
if(res1==ret.empty)and(res2==ret.ok)then
return ret.wrong
end
if(res1==ret.ok)and(res2==ret.empty)then
return ret.ok
end
if(res1==ret.empty)and(res2==ret.empty)then
if(params[1]=="true")then
return ret.missing
else
return ret.ok
end
end
local number1=tonumber(box.post[elems[1].name])
local number2=tonumber(box.post[elems[2].name])
if((number1~=nil)and(number2~=nil)and(number2<number1))then
return ret.outofrange
end
return ret.ok
end
function interface_id(elems)
local res=ret.ok
local l_t_elem_values={}
local l_marked={}
local function add_idx(t,idx)
local t_with_idx={}
t_with_idx.name=t.name..tostring(idx)
t_with_idx.id=t.id..tostring(idx-1)
return t_with_idx
end
for i=1,4 do
local l_name=elems[1].name..tostring(i)
local l_value=tostring(box.post[l_name])
table.insert(l_t_elem_values,l_value)
end
if(l_t_elem_values[1]=="")and(l_t_elem_values[2]=="")and
(l_t_elem_values[3]=="")and(l_t_elem_values[4]=="")then
for i=1,4 do
table.insert(l_marked,add_idx(elems[1],i))
end
return ret.empty,l_marked
end
local l_b_wrong=true
for i=1,4 do
if(not((l_t_elem_values[i]=="")or(tonumber(l_t_elem_values[i])==tonumber("0"))))then
l_b_wrong=false
end
end
if(l_b_wrong==true)then
for i=1,4 do
table.insert(l_marked,add_idx(elems[1],i))
end
return ret.wrong,l_marked
end
return ret.ok,l_marked
end
function native_prefix(elems)
res=not_empty(elems)
if res~=ret.ok then
return res
end
if(string.find(box.post[elems[1].name],"[^0-9a-fA-F:.]")~=nil)then
return ret.format
end
if((string.sub(box.post[elems[1].name],1,2)=="::")and(#box.post[elems[1].name]>2))then
return ret.wrong
end
return ret.ok
end
function native_interface_id(elems)
res=not_empty(elems)
if res~=ret.ok then
return res
end
if(string.find(box.post[elems[1].name],"[^0-9a-fA-F:.]")~=nil)then
return ret.format
end
if(string.sub(box.post[elems[1].name],1,2)~="::")then
return ret.missing
end
return ret.ok
end
function is_ipv6(ipv6)
if type(ipv6)~="string"or#ipv6==0 or string.find(ipv6,"[^:%x]")or
string.find(ipv6,"^:[^:]")or string.find(ipv6,"[^:]:$")or string.find(ipv6,":::")then
return false
end
local double_colon_count
ipv6,double_colon_count=string.gsub(ipv6,"::",":")
if double_colon_count>1 then return false end
ipv6=string.gsub(ipv6,"^:?",":")
local groups
ipv6,groups=string.gsub(ipv6,":%x%x?%x?%x?","")
return((double_colon_count==1 and groups<8)or(double_colon_count==0 and groups==8))
and(#ipv6==0 or(double_colon_count==1 and ipv6==":"))
end
function ipv6(elems)
local function count_pattern(sz_value,sz_to_search)
local pattern_count=0
local pattern_begin=0
local pattern_end
repeat
pattern_begin,pattern_end=string.find(sz_value,sz_to_search,pattern_begin)
if(pattern_end~=nil)then
pattern_count=pattern_count+1
end
pattern_begin=pattern_end
until((pattern_end==nil)or(pattern_end==#sz_value))
return pattern_count
end
res=not_empty(elems)
if res~=ret.ok then
return res
end
if not is_ipv6(tostring(box.post[elems[1].name]))then
return ret.format
end
if(count_pattern(tostring(box.post[elems[1].name]),"::")>1)then
return ret.toomuch
end
return ret.ok
end
function is_num_in(elems,params)
res=not_empty(elems)
if res~=ret.ok then
return res
end
if(string.find(box.post[elems[1].name],"[^0-9#]")~=nil)then
return ret.format
end
if(#params>0)then
for i=1,#params do
if(box.post[elems[1].name]==params[i])then
return ret.wrong
end
end
end
return ret.ok
end
function is_num_in_enh(elems,params)
res=not_empty(elems)
if res~=ret.ok then
return res
end
if(string.find(box.post[elems[1].name],"[^0-9#*]")~=nil)then
return ret.format
end
if(#params>0)then
for i=1,#params do
if(box.post[elems[1].name]==params[i])then
return ret.wrong
end
end
end
return ret.ok
end
function is_num_out(elems,params)
if box.post[elems[1].name]==nil then
return ret.notfound
end
if(string.find(box.post[elems[1].name],"[^0-9]")~=nil)then
return ret.format
end
if(#params>0)then
for i=1,#params do
if(box.post[elems[1].name]==params[i])then
return ret.wrong
end
end
end
return ret.ok
end
function length(elems,params)
local min=tonumber(params[1])or 0
local max=tonumber(params[2])or 255
if elems[1]==nil or elems[1].name==nil or box.post[elems[1].name]==nil then
return ret.notfound
end
local str=box.post[elems[1].name]
if(find_param(params,"empty_allowed")and#str==0)then
return ret.ok
end
if utf8.len(str)<min then
return ret.tooshort
end
if utf8.len(str)>max then
return ret.toolong
end
return ret.ok
end
function email(elems)
local res=ret.ok
res=not_empty(elems)
if res~=ret.ok then
return res
end
if string.match(box.post[elems[1].name],"^[%a%d%._%%%+%-]+@[%a%d%.%-]+%.%a%a%a?%a?%a?%a?$")==nil then
return ret.format
end
return ret.ok
end
function fonbook_emails(elems)
local name_prefix=elems[1].name
local id_prefix=elems[1].id
local postfix_pattern=string.esc(name_prefix).."(.+)"
local post_names=table.filter(box.post,
function(v,k)return type(v)~='number'and not k:find("_i",-2)end
)
local result=ret.ok
local curr_result
local marked={}
for name in pairs(post_names)do
local i,j,postfix=string.find(name,postfix_pattern)
if i==1 then
local elem={name=name,id=id_prefix..postfix}
if not_empty({elem})==ret.ok then
curr_result=email({elem})
if curr_result==ret.format then
table.insert(marked,elem)
result=ret.format
end
end
end
end
return result,marked
end
function email_list(elems)
local res=ret.ok
if elems[1]==nil or elems[1].name==nil or box.post[elems[1].name]==nil then
return ret.notfound
end
res=not_empty(elems)
if res~=ret.ok then
return res
end
for addr in string.gmatch(box.post[elems[1].name],"[^,%s]+")do
if string.match(addr,"^[%a%d%._%%%+%-]+@[%a%d%.%-]+%.%a%a%a?%a?%a?%a?$")==nil then
return ret.format
end
end
return ret.ok
end
function clock_time(elems)
local res=ret.ok
if#elems<2 or box.post[elems[1].name]==nil then
return ret.notfound
end
res=not_empty(elems)
if res~=ret.ok then
return res
end
nhours=tonumber(box.post[elems[1].name],10)
nminutes=tonumber(box.post[elems[2].name],10)
if((type(nhours)~="number")or(type(nminutes)~="number"))then
return ret.format
end
if(nhours<0)or(nhours>24)or(nminutes<0)or(nminutes>59)or(nhours==24 and nminutes>0)then
return ret.outofrange
end
return ret.ok
end
function clock_duration(elems)
local res=ret.ok
local marked={}
if#elems<2 then
return ret.notfound
end
local hstr=box.post[elems[1].name]
local mstr=box.post[elems[2].name]
if hstr==nil or mstr==nil then
return ret.notfound
end
if not string.find(hstr,"^[%d]*$")then
table.insert(marked,elems[1])
res=ret.format
end
if not string.find(mstr,"^[%d]*$")then
table.insert(marked,elems[2])
res=ret.format
end
if res==ret.ok then
local h=tonumber(hstr)or 0
local m=tonumber(mstr)or 0
if h<0 or h>24 then
table.insert(marked,elems[1])
res=ret.outofrange
end
if m<0 or m>59 then
table.insert(marked,elems[2])
res=ret.outofrange
end
if res==ret.ok and h==24 and m~=0 then
table.insert(marked,elems[1])
res=ret.outofrange
end
end
return res,marked
end
function server(elems)
local res=ret.ok
res=not_empty(elems)
if res~=ret.ok then
return res
end
local fqdn=(string.match(box.post[elems[1].name],"^[%a%d%.%-]+%.%a%a%a?%a?%a?%a?:?%d*$")~=nil)
local ipv4=(string.match(box.post[elems[1].name],"^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:?%d*$")~=nil)
local ipv6=(string.match(box.post[elems[1].name],"^%[?[%x:]+%]?:?%d*$")~=nil)
if fqdn or ipv4 or ipv6 then
return ret.ok
end
return ret.format
end
function mac(elems)
local res=ret.ok
local marked={}
for i=0,5 do
local name=elems[1].name..tostring(i)
if box.post[name]then
if box.post[name]~=""then
if not string.match(box.post[name],"^%x%x$")then
table.insert(marked,{["name"]=name,["id"]=elems[1].id..tostring(i)})
if res==ret.ok then res=ret.format end
elseif i==0 then
if tonumber(box.post[name],16)%2==1 then
table.insert(marked,{["name"]=name,["id"]=elems[1].id..tostring(i)})
if res==ret.ok then res=ret.group end
end
end
else
table.insert(marked,{["name"]=name,["id"]=elems[1].id..tostring(i)})
if res==ret.ok or res==ret.format then res=ret.empty end
end
else
table.insert(marked,{["name"]=name,["id"]=elems[1].id..tostring(i)})
res=ret.notfound
end
end
return res,marked
end
function find_param(params,str_to_find)
if(params==nil)then
return false
end
for i,k in ipairs(params)do
if(k==str_to_find)then
return true
end
end
return false
end
function ipv4(elems,params)
local res=ret.ok
local marked={}
local function add_idx(t,idx)
local t_with_idx={}
t_with_idx.name=t.name..tostring(idx)
t_with_idx.id=t.id..tostring(idx)
return t_with_idx
end
local function cb_ip(idx,byte)
if byte then
if byte~=""then
local num=tonumber(byte)
if not num then
table.insert(marked,add_idx(elems[1],idx))
if res==ret.ok then res=ret.format end
elseif num<0 or num>255 then
table.insert(marked,add_idx(elems[1],idx))
if res==ret.ok then res=ret.outofrange end
end
else
table.insert(marked,add_idx(elems[1],idx))
if res==ret.ok or res==ret.format or res==ret.outofrange then res=ret.empty end
end
else
table.insert(marked,add_idx(elems[1],idx))
res=ret.notfound
end
end
local function cb_ip_check_empty(idx,byte)
if byte then
if byte~=""then
res=ret.notempty
end
end
end
local function cb_ip_check_zero(idx,byte)
if byte then
if byte~="0"then
res=ret.notzero
else
table.insert(marked,add_idx(elems[1],idx))
end
end
end
if find_param(params,"zero_not_allowed")then
res=ret.zero
ip.read_from_post(elems[1].name,cb_ip_check_zero)
if(res==ret.zero)then
return ret.allzero,marked
end
marked={}
end
if(find_param(params,"empty_allowed"))then
res=ret.empty
ip.read_from_post(elems[1].name,cb_ip_check_empty)
if(res==ret.notempty)then
res=ret.ok
ip.read_from_post(elems[1].name,cb_ip)
else
res=ret.ok
end
else
res=ret.ok
ip.read_from_post(elems[1].name,cb_ip)
end
return res,marked
end
function not_all_empty(elems,params)
local res=ret.ok
if(params and params[1]~=0)then
for i=1,tonumber(params[1]),1 do
if box.post[elems[1].name..i]~=""then
return res;
end
end
res=ret.empty
else
if box.post[elems[1].name]==""then
res=ret.empty
end
end
return res
end
function not_all_checked(elems,params)
return not_empty(elems)
end
function no_lead_char(elems,params)
local res=ret.ok
if box.post[elems[1].name]:sub(1,1)==string.char(tonumber(params[1]))then
res=ret.leadchar
end
return res
end
function no_end_char(elems,params)
local res=ret.ok
local len=#box.post[elems[1].name]
if box.post[elems[1].name]:sub(len,len)==string.char(tonumber(params[1]))then
res=ret.endchar
end
return res
end
function box_client_ip(elems)
local res=ret.ok
local marked={}
res,marked=ipv4(elems)
if res~=ret.ok then
return res,marked
end
local boxip
local netmask
local opmode=box.query("box:settings/opmode")
if cb_get_boxip and type(cb_get_boxip)=="function"then
boxip=cb_get_boxip()
else
if opmode=="opmode_eth_ipclient"then
boxip=box.query("connection0:status/ip")
else
boxip=box.query("interfaces:settings/lan0/ipaddr")
end
end
if cb_get_netmask and type(cb_get_netmask)=="function"then
netmask=cb_get_netmask()
else
if opmode=="opmode_eth_ipclient"then
netmask=box.query("connection0:status/netmask")
else
netmask=box.query("interfaces:settings/lan0/netmask")
end
end
local clientip=ip.read_from_post(elems[1].name)
if clientip==boxip then
table.insert(marked,{["name"]=elems[1].name.."3",["id"]=elems[1].id.."3"})
return ret.thebox,marked
end
local net=ip.analyse_net(boxip,netmask)
if not ip.addr_in_net(net,clientip)then
for i=1,math.ceil(string.len(net.net)/8)do
local part=string.sub(net.net,(i-1)*8+1,i*8)
if string.sub(ip.byte2bitstr(box.post[elems[1].name..tostring(i-1)]),1,string.len(part))~=part then
table.insert(marked,{["name"]=elems[1].name..tostring(i-1),["id"]=elems[1].id..tostring(i-1)})
end
end
return ret.outofnet,marked
end
if ip.is_net_addr(net,clientip)then
table.insert(marked,{["name"]=elems[1].name.."3",["id"]=elems[1].id.."3"})
return ret.thenet,marked
end
if ip.is_broadcast(net,clientip)then
table.insert(marked,{["name"]=elems[1].name.."3",["id"]=elems[1].id.."3"})
return ret.broadcast,marked
end
return ret.ok,marked
end
function check_ip_net(elems)
local marked={}
local clientip=ip.read_from_post(elems[1].name)
local netmask=ip.read_from_post(elems[2].name)
local gateway=ip.read_from_post(elems[3].name)
local net=ip.analyse_net(clientip,netmask)
if ip.is_net_addr(net,clientip)then
table.insert(marked,{["name"]=elems[1].name.."3",["id"]=elems[1].id.."3"})
return ret.thenet,marked
end
if ip.is_broadcast(net,clientip)then
table.insert(marked,{["name"]=elems[1].name.."3",["id"]=elems[1].id.."3"})
return ret.broadcast,marked
end
if not ip.addr_in_net(net,gateway)then
for i=1,math.ceil(string.len(net.net)/8)do
local part=string.sub(net.net,(i-1)*8+1,i*8)
if string.sub(ip.byte2bitstr(box.post[elems[3].name..tostring(i-1)]),1,string.len(part))~=part then
table.insert(marked,{["name"]=elems[3].name..tostring(i-1),["id"]=elems[1].id..tostring(i-1)})
end
end
return ret.outofnet,marked
end
if ip.is_net_addr(net,gateway)then
table.insert(marked,{["name"]=elems[3].name.."3",["id"]=elems[3].id.."3"})
return ret.thenet,marked
end
if ip.is_broadcast(net,gateway)then
table.insert(marked,{["name"]=elems[3].name.."3",["id"]=elems[3].id.."3"})
return ret.broadcast,marked
end
return ret.ok,marked
end
function check_reserved_net(elems)
local marked={}
local clientip=ip.read_from_post(elems[1].name)
local reserved=ip.analyse_net("192.168.180.0","255.255.255.0")
if ip.addr_in_net(reserved,clientip)then
for i=0,2 do
table.insert(marked,{["name"]=elems[1].name..i,["id"]=elems[1].id..i})
end
return ret.reservednet,marked
end
return ret.ok,marked
end
function check_ewe_smartmeter_subnet(elems)
local marked={}
local clientip=ip.read_from_post(elems[1].name)
local ewe_smartmeter_net=ip.analyse_net("192.168.123.0","255.255.255.0")
if ip.addr_in_net(ewe_smartmeter_net,clientip)then
for i=0,2 do
table.insert(marked,{["name"]=elems[1].name..i,["id"]=elems[1].id..i})
end
return ret.ewemeternet,marked
end
return ret.ok,marked
end
function box_client_ip_range(elems)
local res=ret.ok
local marked={}
if#elems<2 then
return ret.notfound
end
res,marked=box_client_ip({elems[1]})
if res~=ret.ok then
return res,marked
end
res,marked=box_client_ip({elems[2]})
if res~=ret.ok then
return res,marked
end
local boxip
local netmask
if cb_get_boxip and type(cb_get_boxip)=="function"then
boxip=cb_get_boxip()
else
boxip=box.query("interfaces:settings/lan0/ipaddr")
end
if cb_get_netmask and type(cb_get_netmask)=="function"then
netmask=cb_get_netmask()
else
netmask=box.query("interfaces:settings/lan0/netmask")
end
local hostlen=string.len(string.match(ip.quad2bitstr(netmask),"0+"))
local str=ip.read_from_post(elems[1].name)
local start_host=tonumber(string.sub(ip.quad2bitstr(str),-hostlen),2)
str=ip.read_from_post(elems[2].name)
local end_host=tonumber(string.sub(ip.quad2bitstr(str),-hostlen),2)
local box_host=tonumber(string.sub(ip.quad2bitstr(boxip),-hostlen),2)
if end_host<start_host then
for i=4-math.ceil(hostlen/8),3 do
table.insert(marked,{["name"]=elems[2].name..tostring(i),["id"]=elems[2].id..tostring(i)})
end
return ret.unsized,marked
end
if start_host<=box_host and box_host<=end_host then
for i=4-math.ceil(hostlen/8),3 do
table.insert(marked,{["name"]=elems[1].name..tostring(i),["id"]=elems[1].id..tostring(i)})
end
return ret.thebox,marked
end
return ret.ok,marked
end
function netmask(elems)
local res=ret.ok
local marked={}
res,marked=ipv4(elems)
if res~=ret.ok then
return res,marked
end
local str=ip.read_from_post(elems[1].name)
local bitstr=ip.quad2bitstr(str)
if not string.match(bitstr,"^1")then
table.insert(marked,{["name"]=elems[1].name.."0",["id"]=elems[1].id.."0"})
return ret.nomask,marked
end
local badpos=string.find(bitstr,"01")
if badpos then
local byte=tostring(math.floor((badpos+1)/8))
table.insert(marked,{["name"]=elems[1].name..byte,["id"]=elems[1].id..byte})
return ret.nomask,marked
end
if not string.match(bitstr,"00$")then
table.insert(marked,{["name"]=elems[1].name.."3",["id"]=elems[1].id.."3"})
return ret.nomask,marked
end
return ret.ok,marked
end
function netmask_null(elems)
local res=ret.ok
local marked={}
if ip.read_from_post(elems[1].name)~="0.0.0.0"then
res,marked=netmask(elems)
end
return res,marked
end
function radio_set(elems,set)
local str=box.post[elems[1].name]
if str==nil then
return ret.notfound
end
for _,v in ipairs(set)do
if str==v then
return ret.ok
end
end
return ret.missing
end
function pwd_changed(elems)
local str=box.post[elems[1].name]
if str=="****"then
return ret.notdifferent
end
return ret.ok
end
function port_fw_ip_adr(elems)
if elems[1]==nil or elems[1].name==nil then
return ret.notfound
end
local str=box.post[elems[1].name]
if str==nil then
return ret.notfound
end
res=not_empty(elems)
if(res~=ret.ok)then
return res
end
local ipv4=(string.match(box.post[elems[1].name],"^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:?%d*$")~=nil)
if(not ipv4)then
local ipv6=(string.match(box.post[elems[1].name],"^%[?[%x:]+%]?:?%d*$")~=nil)
if(not ipv6)then
return ret.ok
else
return ret.format
end
else
require("lualib")
local t_ipv4_oktetts=box.post[elems[1].name]:split(".")
for i=1,#t_ipv4_oktetts do
local t_ipv4_oktettsAsNumber=tonumber(t_ipv4_oktetts[i])
if(t_ipv4_oktettsAsNumber==nil or t_ipv4_oktettsAsNumber<0 or t_ipv4_oktettsAsNumber>255)then
return ret.outofrange
end
end
if((tonumber(t_ipv4_oktetts[1])==0)and(tonumber(t_ipv4_oktetts[2])==0)and(tonumber(t_ipv4_oktetts[3])==0)and(tonumber(t_ipv4_oktetts[4])==0))then
return ret.allzero
end
return ret.ok
end
end
function port_fw_port_values(elems)
local l_marked={}
for i=1,3 do
local str=nil
if elems[i]~=nil and elems[i].name~=nil then
str=box.post[elems[i].name]
end
if str==nil then
return ret.notfound
end
if(i~=2)then
if#str==0 then
table.insert(l_marked,elems[i].name)
return ret.empty,l_marked
end
end
if not string.find(str,"[%d]+")then
table.insert(l_marked,elems[i].name)
return ret.format,l_marked
end
local elemAsNumber=tonumber(str)
if(elemAsNumber==nil or(elemAsNumber<0)or(elemAsNumber>65535))then
table.insert(l_marked,elems[i].name)
return ret.outofrange,l_marked
end
end
local elem1AsNumber=tonumber(box.post[elems[1].name])
local elem2AsNumber=tonumber(box.post[elems[2].name])
if(elem1AsNumber==nil or elem2AsNumber==nil or elem1AsNumber>elem2AsNumber)then
table.insert(l_marked,elems[1].name)
table.insert(l_marked,elems[2].name)
return ret.outofrange,l_marked
end
return ret.ok
end
function js_validate(v,name,elems,params,msgtab)
box.js("  if ((ret = val."..to_camel(name).."(")
for i,e in ipairs(elems)do
if i==1 then
box.out('"')
else
box.out(', "')
end
box.js(e.id)
box.out('"')
end
if params and next(params)then
if name=="char_range_regex"then
box.out(', ')
if pr[params[1]]and pr[params[1]].reg then
box.out(pr[params[1]].reg)
else
box.out(params[2])
end
box.out('')
else
for _,v in ipairs(params)do
box.out(', "')
box.js(v)
box.out('"')
end
end
end
box.out(")) != val.ok) {\n")
box.out('      val.markError(')
for i,e in ipairs(elems)do
if i>1 then box.out(',')end
box.out('"')
box.js(e.id)
box.out('"')
end
box.out(');\n')
if v.confirm then
box.out("      if (!confirm("..to_camel("g_txt_"..msgtab).."[ret])) {\n")
box.out("      return false;\n}\n    }\n")
else
box.out("      alert("..to_camel("g_txt_"..msgtab).."[ret]);\n")
box.out("      return false;\n    }\n")
end
return ret.ok
end
function js_filter(name,elems,params)
if name=="exists"then
box.out("  if (jxl.get(\"")
box.js(elems[1].id)
box.out("\")) {\n")
end
if name=="callfunc"then
local fn=to_camel(params[1])
box.out(" if (val.callFunc(\"")
box.js(elems[1].id)
box.out("\", \"")
box.js(fn)
box.out("\"")
if#params>1 then
box.out(", ")
box.out(js.array(array.slice(params,2)))
end
box.out(")) {\n")
end
if name=="checked"or name=="radio_check"then
box.out("  if (jxl.getChecked(\"")
box.js(elems[1].id)
box.out("\")) {\n")
end
if name=="not_checked"or name=="not_radio_check"then
box.out("  if (!jxl.getChecked(\"")
box.js(elems[1].id)
box.out("\")) {\n")
end
if name=="value_equal"then
box.out("  if (jxl.getValue(\"")
box.js(elems[1].id)
box.out("\")==\"")
box.js(params[1])
box.out("\") {\n")
end
if name=="value_not_equal"then
box.out("  if (jxl.getValue(\"")
box.js(elems[1].id)
box.out("\")!=\"")
box.js(params[1])
box.out("\") {\n")
end
if name=="value_empty"then
box.out("  if (jxl.getValue(\"")
box.js(elems[1].id)
box.out("\")==\"")
box.out("\") {\n")
end
if name=="value_not_empty"then
box.out("  if (jxl.getValue(\"")
box.js(elems[1].id)
box.out("\")!=\"")
box.out("\") {\n")
end
if name=="values_not_all_empty"then
local count=tonumber(params[1])or 0
if count==0 then
box.out("  if (false) {\n")
else
box.out("  if (")
for i=1,count do
if i>1 then
box.out("\n        || ")
end
box.out("jxl.getValue(\"")
box.js(elems[1].id..(i-1))
box.out("\")!=\"\"")
end
box.out(") {\n")
end
end
return true
end
function js_filter_end()
box.out("  }\n")
end
function lua_validate(v,name,elems,params,msgtab)
local res=ret.ok
local markonly=nil
if(name==nil or msgtab==nil or elems==nil)then
v.error_msg="0x3336974"
return ret.param
end
if type(val[name])=="function"then
res,markonly=val[name](elems,params)
res=res or ret.param
if res~=ret.ok then
v.error_msg=msg[msgtab][res]or"0x3336974"
if(not v.error_msg)then
v.error_msg=tostring(msgtab)..","..tostring(res)
end
local tab=elems
if markonly and type(markonly)=="table"and next(markonly)then
tab=markonly
end
for _,e in ipairs(tab)do
v.error_ids[e.id or""]=true
v.error_names[e.name or""]=true
end
end
end
return res
end
function lua_filter(name,elems,params)
if name=="exists"then
return box.post[elems[1].name]~=nil
end
if name=="callfunc"then
local fn=_G[params[1]]
if type(fn)~='function'then
error("Validation: lua_filter '"..params[1].."' is not a function.")
end
return fn(elems[1].name,unpack(array.slice(params,2)))
end
if name=="checked"then
return box.post[elems[1].name]~=nil
end
if name=="not_checked"then
return box.post[elems[1].name]==nil
end
if name=="radio_check"then
return box.post[elems[1].name]==params[1]
end
if name=="not_radio_check"then
return box.post[elems[1].name]~=params[1]
end
if name=="value_equal"then
return box.post[elems[1].name]==params[1]
end
if name=="value_not_equal"then
return box.post[elems[1].name]~=params[1]
end
if name=="value_empty"then
return(box.post[elems[1].name]==""or box.post[elems[1].name]==nil)
end
if name=="value_not_empty"then
return not(box.post[elems[1].name]==""or box.post[elems[1].name]==nil)
end
if name=="values_not_all_empty"then
local count=tonumber(params[1])or 0
for i=1,count do
if box.post[elems[1].name..(i-1)]~=""then
return true
end
end
return false
end
return true
end
local function parse_error(v,pos,msg)
dbg.error("Validation error at position",pos,":",msg)
pos=string.len(v.prog)+1
return pos
end
local function read_token(v,pos)
local token=""
local start
local stop
if pos>string.len(v.prog)then
return nil,pos
end
start=string.find(v.prog,"[%S]+",pos)
if start==nil then
return nil,pos
end
stop=string.find(v.prog,"[%s%(%),]",start)
if stop==nil then
stop=string.len(v.prog)
else
if stop~=start then
stop=stop-1
end
end
return string.sub(v.prog,start,stop),stop+1
end
local function expect_token(str,v,pos)
local token
token,pos=read_token(v,pos)
if token==nil or token~=str then
parse_error(v,pos,"missing '"..str.."', got '"..token.."' instead")
end
return pos
end
local function read_parameter_list(v,pos)
local elems={}
local params={}
pos=expect_token("(",v,pos)
token,pos=read_token(v,pos)
while token and token~=")"do
if token~=","then
if string.find(token,"/")then
local elem={}
for w in token:gmatch("[^/]+")do
if not elem.id then
elem.id=w
else
elem.name=w
end
end
table.insert(elems,elem)
else
table.insert(params,token)
end
end
token,pos=read_token(v,pos)
end
return pos,elems,params
end
local function read_valfn(name,v,pos,active)
local elems={}
local params={}
local msgtab=nil
local token
local res=ret.ok
pos,elems,params=read_parameter_list(v,pos)
msgtab=table.remove(params)
if not next(elems)then
pos=parse_error(v,pos,"missing element for "..name)
elseif msgtab==nil then
pos=parse_error(v,pos,"missing error-text table for "..name)
else
if active then
res=v.cb_validate(v,name,elems,params,msgtab)
end
end
if(res~=ret.ok)then
table.insert(errors,"Validation error: '"..tostring(res).."' function_name='"..tostring(name).."' elems="..tostring(elems[1].id).."/"..tostring(elems[1].name).."\n")
end
return res,pos
end
local function read_condition(v,pos,end_token)
local token
local act=true
local close_js=true
token,pos=read_token(v,pos)
while token~=end_token do
if string.sub(token,1,2)=="__"then
local name=token:sub(3)
local elems,params
pos,elems,params=read_parameter_list(v,pos)
act=v.cb_filter(name,elems,params)
else
if _G[token]and type(_G[token])=="function"then
pos=expect_token("(",v,pos)
pos=expect_token(")",v,pos)
act=_G[token]()
close_js=false
else
parse_error(v,pos,"unknown global function '"..token.."'")
end
end
token,pos=read_token(v,pos)
end
return act,pos,close_js
end
local function read_if(v,pos,active)
local act=false
local close
local res=ret.ok
act,pos,close=read_condition(v,pos,"then")
res,pos=read_prog(v,pos,act and active)
if close and v.cb_filter_end then
v.cb_filter_end()
end
return res,act,pos
end
function read_prog(v,pos,active)
local token
local act=true
local res=ret.ok
if v.error_ids==nil then
v.error_ids={}
end
v.error_names=v.error_names or{}
token,pos=read_token(v,pos)
while token and(v.readall or res==ret.ok)do
if token=="if"then
res,act,pos=read_if(v,pos,active)
elseif token=="end"then
break
else
res,pos=read_valfn(token,v,pos,active)
end
token,pos=read_token(v,pos)
end
return res,pos
end
function to_camel(str)
local camel=""
local cameled=false
for i=1,#str do
if cameled then
cameled=false
else
if str:sub(i,i)=="_"then
camel=camel..string.upper(str:sub(i+1,i+1))
cameled=true
else
camel=camel..str:sub(i,i)
end
end
end
return camel
end
