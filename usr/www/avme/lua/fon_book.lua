--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall)
require("general")
require("http")
require("cmtable")
require("config")
require"href"
require"textdb"
local lib_fon_book = require("libphonebooklua")
_M = table.extend(_M, lib_fon_book)
function addnum_link(number, numbername, back_to_page)
number = number or ""
back_to_page = back_to_page or box.glob.script
if number == "" then
return href.get(
"/fon_num/fonbook_entry.lua",
http.url_param("uid", "new"),
http.url_param("back_to_page", back_to_page)
)
else
return href.get(
"/fon_num/fonbook_addnum.lua",
http.url_param("number", number),
http.url_param("numbername", numbername or ""),
http.url_param("back_to_page", back_to_page)
)
end
end
function booktype(book_id)
book_id = tonumber(book_id) or lib_fon_book.get_book_id()
if book_id == 0 then return 'standard'
elseif book_id < 240 then return 'userdefined'
elseif book_id < 255 then return 'online'
elseif book_id == 255 then return 'intern'
elseif book_id == 256 then return 'temporary'
else return 'unknown'
end
end
function bookprovider(book_id)
book_id = tonumber(book_id) or lib_fon_book.get_book_id()
local provider=""
if book_id >= 240 and book_id<255 then
read_online_book()
local online_elem=find_item(g_Onlinebook,"id",book_id)
if (online_elem) then
provider=get_provider_by_serviceid(online_elem.serviceid)
end
end
return provider
end
function bookname(book_id)
book_id = tonumber(book_id) or lib_fon_book.get_book_id()
local i, book = array.find(lib_fon_book.get_book_list(), func.eq(book_id, "id"))
return book and book.name
end
function gui_type(real_type)
local gui_types = {
home = 'home',
private = 'home',
mobile = 'mobile',
work = 'work',
business = 'work',
fax_work = 'fax_work',
fax_home = 'fax_work',
intern = 'intern',
other = 'other'
}
return gui_types[real_type] or 'other'
end
local gui_type_display = {
home = {
short = [[{?595:803?}]],
long = [[{?595:245?}]]
},
mobile = {
short = [[{?595:457?}]],
long = [[{?595:751?}]]
},
work = {
short = [[{?595:972?}]],
long =[[{?595:923?}]]
},
fax_work = {
short = [[{?595:377?}]],
long =[[{?595:656?}]]
},
intern = {
short = [[{?595:194?}]],
long =[[{?595:238?}]]
},
other = {
short = [[{?595:995?}]],
long =[[{?595:878?}]]
}
}
function type_display(real_type)
return TXT(gui_type_display[gui_type(real_type)].long)
end
function type_shortdisplay(real_type)
return TXT(gui_type_display[gui_type(real_type)].short)
end
local g_OntelProvider = {}
g_OntelProvider["1u1"] = {
url= "https://uas2.uilogin.de/login",
serviceId= "coms.homenet.1und1",
defaultPbName= "1&1"
}
g_OntelProvider["web"] = {
url= "https://uas2.uilogin.de/login",
serviceId= "coms.homenet.webde",
defaultPbName= "WEB.DE"
}
g_OntelProvider["gmx"] = {
url= "https://uas2.uilogin.de/login",
serviceId= "coms.homenet.gmxde",
defaultPbName= "GMX"
}
g_OntelProvider["google"] = {
url= "https://www.google.com/accounts/ClientLogin",
serviceId= "cp",
defaultPbName= "Google"
}
g_OntelProvider["kdg"] = {
url= "https://api.xworks.net/accounts/ClientLogin",
serviceId= "kdg",
defaultPbName= "Kabelmail"
}
function get_provider_by_id(id)
if (config.ONLINEPB) then
return g_OntelProvider[id]
end
return nil
end
function get_provider_by_serviceid(serviceId)
if (config.ONLINEPB) then
for key,p in pairs(g_OntelProvider) do
if (tostring(p.serviceId) == tostring(serviceId)) then
return key,p;
end
end
end
return nil,nil;
end
g_Onlinebook={}
function is_online(uid)
return tonumber(uid)>=240 and tonumber(uid)<255
end
function is_standard (uid)
return uid=="0"
end
function is_userdefined(uid)
return tonumber(uid)>=1 and tonumber(uid)<239
end
function is_internal(uid)
return uid=="255"
end
function is_temporary (uid)
return uid=="256"
end
function find_item(tab,key,val)
for i,elem in ipairs(tab) do
if tostring(elem[key]) == tostring(val) then
return elem, i
end
end
return nil, 0
end
function read_online_book()
--OnlineTelbook
if #g_Onlinebook < 1 then
g_Onlinebook = general.listquery("ontel:settings/ontel/list("
.. "enabled,id,username,password,serviceid,url,pbname,lastconnect,status,revision"
.. ",usercode_verification_pending,usercode,verification_url,rtok"
.. ")"
)
end
return g_Onlinebook
end
function find_book_by_id(tab,uid)
local elem=find_item(tab,"id",uid)
if elem and is_online(elem.id) then
read_online_book()
local online_elem=find_item(g_Onlinebook,"id",elem.id)
elem=table.extend(elem,online_elem)
end
return elem
end
function find_book_by_name(tab,name,uid)
uid = tonumber(uid)
local res=nil
for i,elem in ipairs(tab) do
if elem.name == name and uid and uid~=elem.id then
res=elem
break;
end
end
if res and is_online(res.id) then
read_online_book()
local online_elem=find_item(g_Onlinebook,"id",res.id)
res=table.extend(res,online_elem)
end
return res
end
function get_online_book_associative()
local online_book_associative = {}
for i,elem in ipairs(g_Onlinebook) do
local index = tonumber(elem.id)
if index then
online_book_associative[index] = elem
end
end
return online_book_associative
end
function Ontel_get_next_free_idx()
if (#g_Onlinebook==0) then
read_online_book()
end
local online_book_associative = get_online_book_associative()
local new_idx=#g_Onlinebook
local new_uid=239
for i = 240, 254, 1 do
new_uid=i
local elem = online_book_associative[new_uid]
if not elem then
return new_uid,new_idx
end
if (elem and elem.enabled=="0") then
return new_uid,new_idx
end
end
new_uid=new_uid+1
if (new_uid>=255) then
return -1
end
return new_uid,new_idx
end
function Ontel_idx()
return #g_Onlinebook
end
--new
function delete_fonbook(id)
return lib_fon_book.delete_book(id)
end
--new
function set_akt_fonbook(id)
return lib_fon_book.select_book(id)
end
--new
function get_akt_fonbook_id()
return lib_fon_book.get_book_id()
end
--new
function get_fonbooks()
return lib_fon_book.get_book_list()
end
--new
function get_akt_fonbook()
local akt_book_id = get_akt_fonbook_id()
for i, book in ipairs(get_fonbooks()) do
if akt_book_id == book.id then
return book
end
end
return {}
end
--new
function read_fonbook(with_internal_book, max_entries, sort_by)
return lib_fon_book.read_book(with_internal_book, max_entries, lib_fon_book["sort_by_"..sort_by])
end
--new
function delete_entry(uid)
return lib_fon_book.delete_entry_by_uid(uid)
end
--new
function create_fonbook(name, copy_from_id)
return lib_fon_book.create_book(name, copy_from_id)
end
function find_entry_by_num(pb, find_num)
for i,elem in ipairs(pb) do
if elem.numbers then
for x,num in ipairs(elem.numbers) do
if num.number==find_num then
return elem
end
end
end
end
return nil
end
function get_name_by_num(pb,find_num)
local elem=find_entry_by_num(pb,find_num)
if elem then
return elem.name
end
return find_num
end
