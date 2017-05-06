--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall)
require"general"
require"textdb"
local items = {}
local current = {
page = box.glob.script, tab = box.get.tab or box.post.tab,
text = TXT([[{?gTxtFritzBox?}]])
}
function override_active_page(page, showtabs)
current.page = page
current.notabs = not showtabs
if showtabs then
items = {}
dofile("../menus/menu_data.lua")
end
end
local function build_page(tbl)
tbl = tbl or {}
return {
text = tbl.text, page = tbl.page, tab = tbl.tab, short = tbl.short
}
end
local function get_href(page, defaulttab)
if (not page) then
return ""
end
local tab
if not defaulttab and page.tab then tab = "tab=" .. page.tab end
return href.get(page.page, tab)
end
local function get_pages(item)
local tbl = item.pages or {}
local n = #tbl
local i = 0
return function()
i = i + 1
if i <= n then
return build_page{text=tbl[i].text, short=tbl[i].short, page=tbl[i].page, tab=tbl[i].tab}
end
end
end
local open_submenu
local function evaluate_show(tbl, p)
local result = tbl[p]
if result == nil then return true end
if type(result) == 'function' then
result = result()
tbl[p] = result
end
return result
end
local show_mt = {__call = evaluate_show}
exists_submenu = setmetatable({}, show_mt)
exists_page = setmetatable({}, show_mt)
show_submenu = setmetatable({}, show_mt)
show_page = setmetatable({}, show_mt)
local function is_currentpage(item)
local isfirst = true
for p in get_pages(item) do
if p.page == current.page then
if p.tab == current.tab then return true end
if isfirst and not current.tab then return true end
end
isfirst = false
end
return false
end
local function get_pageid(page)
local tab = ""
if page.tab then tab = "?tab=" .. page.tab end
return page.page .. tab
end
local function menu_items(submenu)
local i = 0
local t = items[submenu] or {}
local n = #t
return function()
i = i + 1
if i <= n then return t[i] end
end
end
local function find_first_shown(pages)
for _, p in ipairs(pages) do
if show_page(get_pageid(p)) then return p end
end
return nil
end
local function get_firstpage(item)
if item.pages then return find_first_shown(item.pages) end
if item.submenu then
if item.default and item.default() then
local def_page = item.default()
if show_page(def_page) then
for item2 in menu_items(item.submenu) do
if item2.page==def_page then
return item2
end
end
end
end
for item2 in menu_items(item.submenu) do
if item2.pages and #item2.pages > 0 then
local p = find_first_shown(item2.pages)
if p then return p end
end
end
end
return nil
end
local function does_exist(item)
if not item then return false end
if item.separator then return false end
local result = false
if item.submenu then
result = exists_submenu(item.submenu)
elseif item.pages and item.menu then
result = exists_submenu(item.menu)
if result then
result = #item.pages > 0
end
end
return result
end
local function do_show(item)
if not item then return false end
if item.separator then return false end
local result = false
if item.submenu then
result = show_submenu(item.submenu)
elseif item.pages and item.menu then
result = show_submenu(item.menu)
if result then
local p = get_firstpage(item)
if p then result = show_page(get_pageid(p))
else result = false
end
end
end
return result
end
function count_shown_pages(pages)
local result = 0
for i = 1, #pages do
if show_page(get_pageid(pages[i])) then result = result + 1 end
end
return result
end
local function is_active(item)
if is_currentpage(item) then return true end
return false
end
local function is_open(submenu)
if not submenu then return false end
for m in menu_items(submenu) do
if not m.submenu and is_active(m) then return true end
if m.submenu and is_open(m.submenu) then return true end
end
return false
end
local function is_last(m)
return m.menu=="main" and m.submenu=="system"
end
local function get_pagetype(item)
if item.page then
if item.tabs then return 'vartabs'
else return 'page'
end
end
if item.tabs then return 'pagetabs' end
return nil
end
local function add_pages(data_item)
local pagetype = get_pagetype(data_item)
local pages = {}
local p
if pagetype == 'page' then
--p = build_page(data_item.text, data_item.page)
p = build_page{text=data_item.text, short=data_item.short, page=data_item.page}
if exists_page(get_pageid(p)) then table.insert(pages, p) end
elseif pagetype == 'pagetabs' then
for _, t in ipairs(data_item.tabs) do
--p = build_page(t.text, t.page)
p = build_page{text=t.text, short=t.short, page=t.page}
if exists_page(get_pageid(p)) then table.insert(pages, p) end
end
elseif pagetype == 'vartabs' then
for _, t in ipairs(data_item.tabs) do
--p = build_page(t.text, data_item.page, t.tab)
p = build_page{text=t.text, short=t.short, page=data_item.page, tab=t.tab}
if exists_page(get_pageid(p)) then table.insert(pages, p) end
end
else
pages = nil
end
return pages
end
function add_item(item)
item.pages = add_pages(item)
if does_exist(item) then
if is_currentpage(item) then
current.text = item.text
current.short = item.short
current.item = item
end
local m = item.menu
items[m] = items[m] or {}
table.insert(items[m], item)
end
end
function get_page_title()
return TXT(current.text)
end
function write_menu(submenu)
submenu = submenu or "main"
box.out('\n<ul>')
for m in menu_items(submenu) do
if m.separator then box.out('<li class="separator"><div></div></li>')
elseif do_show(m) then
local is_submenu_open = m.submenu and is_open(m.submenu)
m.href = m.href or get_href(get_firstpage(m), true)
box.out('\n<li')
local class = ""
if is_active(m) then class = class .. " selected"
elseif is_submenu_open then
if (is_last(m)) then
class = class .. " selected submenu_last"
else
class = class .. " selected submenu"
end
end
if class ~= "" then box.out(' class="', class, '"') end
box.out('>')
box.out('<a href="', m.href, '"')
if m.target then box.out(' target="' .. m.target .. '"') end
box.out('>')
if m.short then
box.html(TXT(m.short))
else
box.html(TXT(m.text))
end
box.out('</a>')
if is_submenu_open then
write_menu(m.submenu)
end
box.out('</li>')
if m.explain then
box.out('<li class="explain">')
box.html(TXT(m.explain))
box.out('</li>')
end
end
end
box.out('\n</ul>')
end
local show_tabs = true
local function calc_half()
local mcnt = {}
local cnt_all = 0
for m in menu_items('main') do
if do_show(m) then
local count = 1
if m.submenu then
for p in menu_items(m.submenu) do
count = count + 1
if show_tabs then
for t in get_pages(p) do
count = count + 1
end
end
end
end
table.insert(mcnt, #mcnt+1, count)
cnt_all = cnt_all + count
end
end
cnt_all = cnt_all / 2
local h = 0
local i = 0
while h < cnt_all do
i = i + 1
h = h + mcnt[i]
end
return i
end
function write_sitemap()
local cnt, half = 0, calc_half()
local classname
for item in menu_items('main') do
cnt = cnt + 1
classname = cnt <= half and 'left' or 'right'
box.out('\n<div class="', classname , '">')
if do_show(item) then
item.href = get_href(get_firstpage(item), true)
box.out('\n<h3><a href="', item.href, '">')
box.html(TXT(item.text))
box.out('</a></h3>')
else
box.out('\n<h3>')
box.html(TXT(item.text) .. "*")
box.out('</h3>')
end
if item.submenu then
box.out('\n<dl>')
for item2 in menu_items(item.submenu) do
local show_it = do_show(item2)
if show_it then
box.out('\n<dt><a href="', get_href(get_firstpage(item2), true), '">')
box.html(TXT(item2.text))
box.out('</a></dt>')
else
box.out('\n<dt>')
box.html(TXT(item2.text) .. "*")
box.out('</dt>')
end
if item2.pages and #item2.pages > 1 then
for page in get_pages(item2) do
if show_it and show_page(get_pageid(page)) then
box.out('\n<dd><a href="', get_href(page), '">')
box.html(TXT(page.text))
box.out('</a></dd>')
else
box.out('\n<dd>')
box.html(TXT(page.text) .. "*")
box.out('</dd>')
end
end
end
end
box.out('</dl>')
end
box.out('</div>')
end
end
function write_tabs(options)
options = options or {}
if options.notabs then return end
if current.notabs then return end
local curr = current.item
if curr and curr.pages and count_shown_pages(curr.pages) > 1 then
box.out("<ul class=\"tabs\">\n")
local defaulttab = curr.pages[1].tab
if options.currtab then defaulttab = options.currtab end
for p in get_pages(curr) do
if show_page(get_pageid(p)) then
if current.page == p.page and (current.tab == p.tab or not current.tab and p.tab == defaulttab) then
box.out("<li class=\"active\">")
else
box.out("<li>")
end
local tab = p.tab and ("tab=" .. p.tab) or ""
box.out("<a href=\"" .. href.get(p.page, tab) .. "\">")
box.html(TXT(p.text))
box.out("</a></li>\n")
end
end
box.out("</ul><div class='clear_float'></div>\n")
end
end
function write_local_tabs(tabs_elems)
tabs_elems = tabs_elems or {}
if #tabs_elems > 1 then
box.out("<div class='clear_float'></div>\n")
box.out("<ul class=\"tabs\">\n")
for i = 1, #tabs_elems do
if tabs_elems[i].page == box.glob.script then
box.out("<li class=\"active\">")
else
box.out("<li>")
end
box.out("<a class=\"nocancel\" href=\"" .. href.get(tabs_elems[i].page, tabs_elems[i].param) .. "\">")
box.html(TXT(tabs_elems[i].text))
box.out("</a></li>\n")
end
box.out("</ul><div class='clear_float'></div>\n")
end
end
function add_param_to_local_tabs(tabs_elems, param)
if ( tabs_elems ~= nil) then
for i=1, #g_local_tabs do
g_local_tabs[i].param = param
end
end
end
function get_page(expertmode, page, tab)
override_expert = expertmode == "expertmode"
dofile("../menus/menu_show.lua")
for item in menu_items('main') do
if item.submenu then
for item2 in menu_items(item.submenu) do
for i, p in ipairs(item2.pages or {}) do
if p.page == page and (not tab or tab == p.tab) then
local result
if do_show(item2) then
if show_page(get_pageid(p)) then
result = p
else
result = get_firstpage(item2)
end
else
result = get_firstpage(item)
end
override_expert = nil
dofile("../menus/menu_show.lua")
return get_href(result)
end
end
end
end
end
override_expert = nil
dofile("../menus/menu_show.lua")
return get_href({page=page, tab=tab})
end
function check_page(submenu, page, tab)
local m = submenu or ""
if not page then
return exists_submenu(m) and show_submenu(m)
end
local p = get_pageid{page=page, tab=tab}
return exists_submenu(m) and show_submenu(m) and exists_page(p) and show_page(p)
end
function show_additional_menu(which)
local show_all = box.glob.script == "/home/home.lua"
if show_all and which == "livetv" then
return items.livetv[1] and items.livetv[1].href ~= "" and items.livetv[1].href ~= "non-emu"
end
return show_all or which == "wizards" and box.glob.script == "/assis/home.lua"
end
function init_all()
local dontlog = box.glob.script ~= "/menus/sitemap.lua"
if dontlog and log then log.disable() end
dofile("../menus/menu_show.lua")
dofile("../menus/menu_data.lua")
if dontlog and log then log.enable() end
end
init_all()
