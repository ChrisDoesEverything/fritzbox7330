--[[Access denied<?lua
    box.end_page()
?>?>?>]]
require("config")
if config.WEBCM_INTERPRETER then
require("libluatextdb")
end
local id_pattern="{%?.-%?".."}"
local key_pattern="^{%?(.+)%?".."}$"
local function replace_id(id)
local key=string.match(id,key_pattern)
if key then
return textdb.get_text(key)or id
end
return id
end
function TXT(text)
text=text or""
if config.WEBCM_INTERPRETER then
return(string.gsub(text,id_pattern,replace_id))
end
return text
end
function SET_LANG(id)
if id and id~=""then
textdb.set_language(id)
end
end