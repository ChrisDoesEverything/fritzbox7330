--[[Access denied<?lua
box.end_page()
?>]]
local dbg_emptyfunc = function() end
dbg = setmetatable({}, {
__index = function() return dbg_emptyfunc end
})
