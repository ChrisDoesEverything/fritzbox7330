--[[Access denied<?lua
box.end_page()
?>?>?>]]
require"config"
require"dump"
log={}
local enabled=1
function log.enable()enabled=enabled+1 end
function log.disable()enabled=enabled-1 end
local no_logging=false
function log.no_output()
no_logging=true
end
local queries={}
local mqueries={}
local _query=box.query
box.query=function(str,default)
local result=_query(str)
if enabled>0 then queries[str]=tostring(result)end
if default==nil then default=""end
return result or default
end
local _multiquery=box.multiquery
box.multiquery=function(str)
local result=_multiquery(str)or{}
if enabled>0 then mqueries[str]=table.clone(result)end
return result
end
local function split_querystr(str)
local s1=str:match("(.*)%(.*%)")
local s2=str:match(".*%((.*)%)")
local s3={}
if s2 then
s3=s2:split(",")
while s3[1]and tonumber(s3[1])do table.remove(s3,1)end
s3=array.cat({"_node"},s3)
end
return s1,s3
end
local function m2l()
local result={}
for k,v in pairs(mqueries)do
result[k]={}
local s,names=split_querystr(k)
names=names or{}
for k1,v1 in ipairs(v)do
local t={}
for i=1,#v1 do
t[names[i]or i]=v1[i]
end
table.insert(result[k],t)
end
end
return result
end
local function convert2html(obj)
local t=type(obj)
if t=='number'or t=='boolean'then
return obj
elseif t=='string'then
return box.tohtml(obj)
elseif t=='table'then
local result={}
for key,value in pairs(obj)do
result[convert2html(key)]=convert2html(value)
end
return result
end
end
function log.output(options)
if no_logging then
return
end
options=options or{}
if dbg then dbg.timestart("log")end
box.out("\n",[[<div id="logqueries" style="clear:both; display:none;">]])
if not options.only_errors then
box.out("\n",[[<pre>]])
box.out("\n",[[script = ]])
box.html(box.glob.script)
box.out("\n",[[GET = ]],dumptable(convert2html(box.get)))
box.out("\n",[[POST = ]],dumptable(convert2html(box.post)))
box.out("\n",[[QUERIES = ]],dumptable(convert2html(queries)))
box.out("\n",[[MQUERIES = ]],dumptable(convert2html(m2l(mqueries))))
box.out("\n",[[CONFIG = ]],dumptable(convert2html(config)))
box.out("\n",[[</pre>]])
end
if box.get_errors then
box.out(box.get_errors())
end
box.out("\n",[[</div>]])
if dbg then dbg.timestop("log")end
end
return log
