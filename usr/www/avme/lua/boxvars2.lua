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
-- ***********************************************************************************************
--
-- local l_DebugStr = [[ boxvars2.lua >> Debugging runs ...]]
-- dbg.cprint( l_DebugStr)
local function create_var_names(_obj)
local nPos = string.find( _obj.sz_query, ":")
local sz_tmp1 = box.tohtml(string.sub( _obj.sz_query, 1, nPos-1))
nPos = string.find( _obj.sz_query, "/", nPos+1)
local sz_tmp2 = string.sub( _obj.sz_query, nPos+1)
sz_tmp2 = string.gsub( sz_tmp2, "/", "_")
_obj.sz_var_name = box.tohtml(string.lower( sz_tmp1.."_"..sz_tmp2))
_obj.sz_var_name_js = box.tohtml("uiView_"..sz_tmp1.."_"..sz_tmp2)
-- local l_DebugStr = [[ boxvars2.lua >> create_var_names() ]]
-- dbg.cprint( l_DebugStr)
end
-- ***********************************************************************************************
--
-- ***********************************************************************************************
--
c_boxvars = { sz_query = "", sz_value = "", sz_var_name = "", sz_var_name_js = "", n_count = 0}
function c_boxvars:init( obj)
obj = obj or {}
setmetatable( obj, self)
self.__index = self
self.n_count = self.n_count + 1
if ( obj.sz_query ~= "") then
obj.sz_value = box.query( obj.sz_query)
create_var_names( obj)
end
-- local l_DebugStr = [[ boxvars2.lua >> cbv:init() ]]
-- dbg.cprint( l_DebugStr)
return obj
end
-- ***********************************************************************************************
--
function c_boxvars:var_exist()
return ( box.post[self.sz_var_name] ~= nil)
end
-- ***********************************************************************************************
--
function c_boxvars:get_query_str()
return tostring( self.sz_query)
end
-- ***********************************************************************************************
--
function c_boxvars:get_var_name()
return tostring( self.sz_var_name)
end
-- ***********************************************************************************************
--
function c_boxvars:get_var_name_js()
return tostring( self.sz_var_name_js)
end
-- ***********************************************************************************************
--
function c_boxvars:get_val_names(_sz_extension)
if ( _sz_extension == nil) then
_sz_extension = [[]]
end
return tostring( (self.sz_var_name_js)..(_sz_extension)..[[/]]..( self.sz_var_name)..(_sz_extension))
end
-- ***********************************************************************************************
--
function c_boxvars:get_value()
return tostring( self.sz_value)
end
-- ***********************************************************************************************
--
function c_boxvars:set_value( _value)
self.sz_value = _value
end
-- ***********************************************************************************************
--
function c_boxvars:update_value()
if ( box.post[self.sz_var_name] ~= nil) then
self.sz_value = box.post[self.sz_var_name]
else
self.sz_value = ""
end
end
-- ***********************************************************************************************
--
function c_boxvars:set_checked( _compare_value)
local szRet =""
if ( self.sz_value == _compare_value) then
szRet = [[ checked ]]
end
return szRet
end
-- ***********************************************************************************************
--
function c_boxvars:save_value( _t_save_set, _value)
if ( _value == nil) then
_value = box.post[self.sz_var_name]
end
cmtable.add_var( _t_save_set, self.sz_query, _value)
self.sz_value = _value
end
-- ***********************************************************************************************
--
function c_boxvars:save_check_value( _t_save_set, _setvalue, _unsetvalue)
_setvalue = _setvalue or "1"
_unsetvalue = _unsetvalue or "0"
cmtable.save_checkbox( _t_save_set, self.sz_query, self.sz_var_name, _setvalue, _unsetvalue)
if (box.post[self.sz_var_name]) then
self.sz_value = _setvalue
else
self.sz_value = _unsetvalue
end
end
-- ***********************************************************************************************
-- ***********************************************************************************************
-- ***********************************************************************************************
