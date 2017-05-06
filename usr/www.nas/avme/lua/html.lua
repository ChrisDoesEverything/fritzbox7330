--[[Access denied<?lua
    box.end_page()
?>?>?>]]
require"lualib"
local table_insert,table_concat=table.insert,table.concat
local pairs,ipairs,type,select=pairs,ipairs,type,select
local new_elem,raw,add_content,attr_types,nl,set_nl,end_tag_str,attr_str,tag_str,
write_elem,elem_str,standalone,boolean,add_attribute
html={}
html=setmetatable(html,{
__index=function(self,key,...)
self[key]=function(...)return new_elem(key,...)end
return self[key]
end
})
function html.raw(str)
return raw(str or"")
end
function html.fragment(...)
return new_elem(nil,{},...)
end
new_elem=function(tag,tbl,...)
local elem={}
local iface={}
iface.write=function(nonewline)write_elem(elem,nonewline)end
iface.get=function(nonewline)return elem_str(elem,nonewline)end
elem.tag=tag and tag:lower()
if not elem.tag or not standalone[elem.tag]then
elem.content={}
end
if elem.tag then
elem.attr={}
end
if elem.content then
iface.add=function(...)add_content(elem,...)end
for i=1,table.maxn(tbl or{})do
add_content(elem,tbl[i])
end
add_content(elem,...)
end
if elem.attr then
iface=setmetatable(iface,{
__newindex=function(self,x,y)add_attribute(elem,x,y)end,
__index=elem.attr
})
for name,value in pairs(tbl or{})do
add_attribute(elem,name,value)
end
end
return iface
end
raw=function(str)
local iface={}
iface.write=function()box.out(str)end
iface.get=function()return str end
return iface
end
add_content=function(elem,...)
for i=1,select('#',...)do
table_insert(elem.content,(select(i,...)))
end
end
attr_types=array.truth{'string','boolean','number','nil'}
add_attribute=function(elem,name,value)
if type(name)=='string'then
local t=type(value)
if attr_types[t]then
name=name:lower()
if boolean[name]and value==""then
value=true
end
elem.attr[name]=value
end
end
end
nl="\n"
set_nl=function(flag)
nl=flag and""or"\n"
end
local attr_fmt=[[%s="%s"]]
attr_str=function(elem)
local result={""}
for name,value in pairs(elem.attr or{})do
if value then
name=box.tohtml(name)
if type(value)~='boolean'then
value=box.tohtml(value)
table_insert(result,attr_fmt:format(name,value))
else
table_insert(result,name)
end
end
end
return table_concat(result," ")
end
local tag_fmt=[[%s<%s%s>]]
tag_str=function(elem)
if not elem.tag then return""end
return tag_fmt:format(nl,elem.tag,attr_str(elem))
end
local end_tag_fmt=[[%s</%s>]]
end_tag_str=function(elem)
if not elem.tag or standalone[elem.tag]then return""end
return end_tag_fmt:format(nl,elem.tag)
end
write_elem=function(elem,nonewline)
set_nl(nonewline)
box.out(tag_str(elem))
for i,content in ipairs(elem.content or{})do
local t=type(content)
if t=='string'or t=='number'then
box.html(content)
else
content.write(nonewline)
end
end
box.out(end_tag_str(elem))
end
elem_str=function(elem,nonewline)
set_nl(nonewline)
local str={}
table_insert(str,tag_str(elem))
for i,content in ipairs(elem.content or{})do
local t=type(content)
if t=='string'or t=='number'then
table_insert(str,box.tohtml(content))
else
table_insert(str,content.get(nonewline))
end
end
table_insert(str,end_tag_str(elem))
return table_concat(str)
end
standalone=array.truth{
'area','base','basefont','br','col','command','embed','frame',
'hr','img','input','isindex','keygen','link','meta','param',
'source','track','wbr'
}
boolean=array.truth{
'autobuffer','autofocus','autoplay','async',
'checked','compact','controls',
'declare','defaultmuted','defaultselected','defer','disabled','draggable',
'formnovalidate',
'hidden',
'indeterminate','ismap','itemscope',
'loop',
'multiple','muted',
'nohref','noresize','noshade','nowrap','novalidate',
'open',
'pubdate',
'readonly','required','reversed',
'scoped','seamless','selected','spellcheck',
'truespeed',
'visible'
}
return html