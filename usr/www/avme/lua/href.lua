--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall)
require"config"
require"textdb"
require"http"
local sid_param
if config.SESSIONID and box.glob.sid then
sid_param = "sid=" .. box.glob.sid
end
function get_paramtable(page, params)
table.insert(params, 1, sid_param)
if #params > 0 then
return page .. "?" .. table.concat(params, "&")
end
return page
end
function get(page, ...)
local params = {...}
return get_paramtable(page,params)
end
function write(page, ...)
box.out(get(page, ...))
end
local real_help_page = setmetatable({}, {
__index = function(self, page)
if g_page_type == "wizard" or page:find("/assis/") == 1 then
return "hilfe_assistenten.html"
else
return "hilfe_startseite.html"
end
end
})
real_help_page["/home/home.lua"] = "hilfe_status.html"
real_help_page["/menus/sitemap.lua"] = "hilfe_sitemap.html"
real_help_page["/menus/programs.lua"] = "hilfe_programme.html"
function help_main(...)
local help_page = real_help_page[box.glob.script]
if g_page_help and "string" == type(g_page_help) then
help_page = g_page_help
end
return get("/help/help.lua", 'helppage=' .. help_page, ...)
end
function help_get(page, ...)
return get("/help/help.lua", 'helppage=' .. page, ...)
end
function help_write(page, ...)
box.out(help_get(page, ...))
end
function help_btn(pagename, string_only)
local str =
[[<button type="button" class="hidden_help" style="display:none;" id="uiHelpBtn"]]
.. [[ onclick="help.popup(']]..help_get(pagename, 'hide=yes')..[[')">]]
.. box.tohtml(TXT([[{?txtHelp?}]]))
.. [[</button>]]
if string_only then
return str
else
box.out(str)
end
return ""
end
function default_submit(name)
name = name or "apply"
box.out(
[[<input type="submit" value=""]]
.. [[ style="position:absolute;top:-9999px;left:-9999px;"]]
.. [[ name="]] .. name .. [[">]]
)
end
function get_zone_link_pur(target_zone, page)
if not page then
page = ""
end
if box.glob.host == "myfritz.box" or box.glob.host == "fritz.nas" then
local prefix = "http"
if box.glob.secure then
prefix = "https"
end
local host = "fritz."..target_zone
if target_zone == "myfritz" then
host = target_zone..".box"
end
return prefix.."://"..host..page
end
if target_zone=="box" then
if page == "" then
target_zone="/"
else
target_zone=""
end
else
target_zone="/"..target_zone
end
return target_zone..page
end
function get_zone_link(target_zone, page, ...)
local link=get_zone_link_pur(target_zone, page)
if target_zone == 'box' then
if not page or #page == 0 then
if (not string.find(link,"/",#link)) then
link=link.."/"
end
link=link..[[home/home.lua]]
end
end
link = link..[[?sid=]]..box.tohtml(box.glob.sid)
for i, p in ipairs({...}) do
link = link .. "&" .. p
end
return link
end
