--[[Access denied<?lua
    box.end_page()
?>?>]]
webuicookie={}
local fields={
{name="noPwdReminder",default="0"}
,{name="lteSetupDone",default="0"}
,{name="rep_routertype",default="1"}
,{name="action_allowed",default="--------"}
,{name="repeaterSetupDone",default="0"}
,{name="docsisSetupDone",default="2"}
}
local values={}
webuicookie.get=function(name)
if values[name]then
return values[name].value
end
return nil
end
webuicookie.set=function(name,value)
value=tostring(value)
if values[name]and#value==values[name].len then
values[name].value=value
return true
end
return false
end
webuicookie.reset=function(name)
if values[name]then
values[name].value=values[name].default
return true
end
return false
end
local function values_to_string()
local tmp_tab={}
for i,v in pairs(values)do
tmp_tab[v.order]=v.value
end
return table.concat(tmp_tab,"")
end
webuicookie.write=function()
box.out(values_to_string())
end
webuicookie.vars=function()
return"box:settings/webui_cookie",values_to_string()
end
webuicookie.check_action_allowed_by_time=function()
local akt_time=tonumber(string.pad(box.timestamp_ms(),-8,"0"))
local old_time=tonumber(webuicookie.get("action_allowed"))
return(akt_time and old_time and(akt_time-old_time)<10000)
end
webuicookie.create_action_allowed_time=function(delay)
delay=tonumber(delay)or 0
return string.pad(box.timestamp_ms()+delay,-8,"0")
end
webuicookie.set_action_allowed_time=function(delay)
webuicookie.set("action_allowed",webuicookie.create_action_allowed_time(delay))
end
local function init()
local values_str=box.query("box:settings/webui_cookie")
local pos=1
for i,field in ipairs(fields)do
local fieldlen=#field.default
local tmp=string.sub(values_str,pos,pos+(fieldlen-1))
values[field.name]={}
values[field.name].order=i
values[field.name].len=fieldlen
values[field.name].default=field.default
values[field.name].value=(#tmp==fieldlen)and tmp or field.default
pos=pos+fieldlen
end
end
init()
