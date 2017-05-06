--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
-- ***********************************************************************************************
-- Erläuterung:
--
-- ***********************************************************************************************
require("cmtable")
-- ***********************************************************************************************
--
-- öffentliche Schnittstelle
--
-- ***********************************************************************************************
local t_of_vars = {}
-- ***********************************************************************************************
--
-- ***********************************************************************************************
--
init = function( _t_init)
t_of_vars = {}
for i = 1, #_t_init do
l_box_value = box.query( _t_init[i])
if ( l_box_value == "er") then
l_box_value = ""
end
t_of_vars[i] = {
str = _t_init[i],
value = l_box_value,
name = "var_name_"..tostring(i),
}
end
end
-- ***********************************************************************************************
--
get_table = function()
return t_of_vars
end
-- ***********************************************************************************************
--
get_table_len = function ()
return #t_of_vars
end
-- ***********************************************************************************************
--
get_str = function( _index)
return ( t_of_vars[_index].str)
end
-- ***********************************************************************************************
--
get_value = function( _index)
return ( t_of_vars[_index].value)
end
-- ***********************************************************************************************
--
set_value = function( _index, _value)
t_of_vars[_index].value = _value
end
-- ***********************************************************************************************
--
save_value = function( _t_save_set, _index, _value)
if ( _value == nil) then
_value = box.post[get_name(_index)]
end
cmtable.add_var( _t_save_set, get_str( _index), _value)
set_value(_index, _value)
end
-- ***********************************************************************************************
--
save_check_value = function( _t_save_set, _index, _setvalue, _unsetvalue)
_setvalue = _setvalue or "1"
_unsetvalue = _unsetvalue or "0"
cmtable.save_checkbox( _t_save_set, get_str(_index), get_name(_index), _setvalue, _unsetvalue)
if (box.post[get_name(_index)]) then
set_value( _index, _setvalue)
else
set_value( _index, _unsetvalue)
end
end
-- ***********************************************************************************************
--
get_name = function( _index)
return ( t_of_vars[_index].name)
end
-- ***********************************************************************************************
--
set_name = function( _index)
box.out( [[name="]]..t_of_vars[_index].name..[["]])
end
-- ***********************************************************************************************
--
set_name_value = function( _index, _value)
local szOut = [[ name="]]..t_of_vars[_index].name..[["]]
if _value == nil then
szOut = szOut..[[ value="]]..box.tohtml(t_of_vars[_index].value)..[["]]
else
szOut = szOut..[[ value="]]..box.tohtml(_value)..[["]]
end
box.out( szOut)
end
-- ***********************************************************************************************
--
set_checked = function( _index, _to_compare)
local szRet =""
if ( t_of_vars[_index].value == _to_compare) then
szRet = [[ checked ]]
end
return szRet
end
-- ***********************************************************************************************
--
var_exist = function( _index)
return ( box.post[get_name(_index)] ~= nil)
end
-- ***********************************************************************************************
--
is_checked = function( _index, _to_compare)
return ( t_of_vars[_index].value == _to_compare)
end
-- ***********************************************************************************************
--
is_display = function( _index, _to_compare)
return ( t_of_vars[_index].value == _to_compare)
end
-- ***********************************************************************************************
--
show_content = function (isDebug)
l_htmt = [[
<!--
]]
l_htmt = l_htmt..[[|~~~~~| begin of box-vars of this page ~~~~~~~~~~]]
if isDebug then
l_htmt = l_htmt..[[|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
end
l_htmt = l_htmt..[[
|
]]
l_htmt = l_htmt..[[|~~~~~|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
if isDebug then
l_htmt = l_htmt..[[|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
end
l_htmt = l_htmt..[[
|
]]
box.out( l_htmt)
for i = 1, get_table_len() do
l_htmt = [[| ]]..string.format( "%03d",i)
if isDebug then
l_htmt = l_htmt..[[ | ]]..string.format("%-40s", tostring(get_str(i)))
end
l_htmt = l_htmt..[[ | ]]..string.format("%-41s", tostring(get_value(i)))
l_htmt = l_htmt..[[
|
]]
box.out( l_htmt)
end
l_htmt = [[|~~~~~|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
if isDebug then
l_htmt = l_htmt..[[|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
end
l_htmt = l_htmt..[[
|
]]
l_htmt = l_htmt..[[|~~~~~| end of box-vars of the page ~~~~~~~~~~~~~]]
if isDebug then
l_htmt = l_htmt..[[|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
end
l_htmt = l_htmt..[[
|
]]
l_htmt = l_htmt..[[
-->
]]
box.out( l_htmt)
end
-- ***********************************************************************************************
-- ***********************************************************************************************
-- ***********************************************************************************************
