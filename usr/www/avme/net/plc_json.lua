<?lua
package.path = "../lua/?.lua;../menus/?.lua;../help/?.lua;" .. (package.path or "")
require 'libluaplc'
box.post.xhr=""
require("check_sid")
if not gl or not gl.logged_in then
box.end_page()
end
local resp = nil
if (box.post and box.post.Cmd=="ListAdapters") then
require 'general'
local list=general.listquery("plc:settings/device/list(mac,isLocal,usr,status,remoteAdapters,couplingClass)")
local loc_elem=nil
local more_remote={}
local add_all=true
for i,elem in ipairs(list) do
if elem.remoteAdapters and elem.remoteAdapters~="" then
add_all=false
break
end
end
if add_all then
for i,elem in ipairs(list) do
table.insert(more_remote,elem.mac)
end
end
for i,elem in ipairs(list) do
if elem.status and elem.status ~= "" then
if string.sub( elem.status,1,6) == "ACTIVE" then
elem.active = true
else
elem.active = false
end
else
elem.active = false
end
elem.isLocal=elem.isLocal=="1"
if add_all then
elem.remoteAdapters=table.concat(more_remote,",")
end
end
resp={}
resp.Status="0"
resp.Adapters=list
else
resp = luaplc.execute(box.post)
end
if resp ~= nil then
if type(resp) == 'table' then
require "js"
box.out(js.table(resp))
else
box.out("{\"error\": \""..resp.."\"}")
end
end
?>
