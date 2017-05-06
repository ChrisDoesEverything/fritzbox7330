--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
_select = function ( szName, szId, t_select_values, selected_value, t_select_texts, szValResult)
local l_szRet = [[<select name="]]..szName..[[" id="]]..szId..[[" ]]
if ((szValResult ~= nil) and (szValResult ~=[[]] )) then
l_szRet = l_szRet..szValResult
end
l_szRet = l_szRet..[[ >]]
if #t_select_values > 0 then
for i = 1, #t_select_values do
if ( t_select_texts ~= nil) then
l_szRet = l_szRet..[[<option value="]]..box.tohtml(t_select_values[i])..[[" ]]
if ( t_select_values[i] == selected_value) then
l_szRet = l_szRet..[[ selected ]]
end
l_szRet = l_szRet..[[>]]..box.tohtml(t_select_texts[i])
else
l_szRet = l_szRet..[[<option value="]]..box.tohtml(t_select_values[i][1])..[[" ]]
if ( t_select_values[i][1] == selected_value) then
l_szRet = l_szRet..[[ selected ]]
end
l_szRet = l_szRet..[[>]]..box.tohtml(t_select_values[i][2])
end
l_szRet = l_szRet..[[</option>]]
end
end
l_szRet = l_szRet..[[</select>]]
return l_szRet
end
_select_plus = function ( szName, szId, t_select_values, selected_value, t_select_texts, sz_Style, szValResult)
local l_szRet = [[<select name="]]..szName..[[" id="]]..szId..[[" ]]
if ((szValResult ~= nil) and (szValResult ~=[[]] )) then
l_szRet = l_szRet..szValResult
end
if ((sz_Style ~= nil) and ( sz_Style ~= [[]]) ) then
l_szRet = l_szRet..[[ style="]]..sz_Style..[[" ]]
end
l_szRet = l_szRet..[[ >]]
if #t_select_values > 0 then
for i = 1, #t_select_values do
if ( t_select_texts ~= nil) then
l_szRet = l_szRet..[[<option value="]]..box.tohtml(t_select_values[i])..[[" ]]
if ( t_select_values[i] == selected_value) then
l_szRet = l_szRet..[[ selected ]]
end
l_szRet = l_szRet..[[>]]..box.tohtml(t_select_texts[i])
else
l_szRet = l_szRet..[[<option value="]]..box.tohtml(t_select_values[i][1])..[[" ]]
if ( t_select_values[i][1] == selected_value) then
l_szRet = l_szRet..[[ selected ]]
end
l_szRet = l_szRet..[[>]]..box.tohtml(t_select_values[i][2])
end
l_szRet = l_szRet..[[</option>]]
end
end
l_szRet = l_szRet..[[</select>]]
return l_szRet
end
_input = function ( szType, szName, szId, szValue, szSize, szMaxLength, szValResult)
local l_szRet = [[<input type="]]..tostring( szType)..[[" ]]
l_szRet = l_szRet..[[name="]]..tostring( szName)..[[" ]]
l_szRet = l_szRet..[[size="]]..tostring( szSize)..[[" ]]
l_szRet = l_szRet..[[maxlength="]]..tostring( szMaxLength)..[[" ]]
l_szRet = l_szRet..[[id="]]..tostring( szId)..[[" ]]
l_szRet = l_szRet..[[value="]]..box.tohtml(tostring( szValue))..[[" ]]
if ((szValResult ~= nil) and (szValResult ~="")) then
l_szRet = l_szRet..szValResult..[[ ]]
end
l_szRet = l_szRet..[[ >]]
return l_szRet
end
_input_plus = function ( szType, szName, szId, szValue, szSize, szMaxLength, szFunc, szValResult)
local l_szRet = [[<input type="]]..tostring( szType)..[[" ]]
l_szRet = l_szRet..[[name="]]..tostring( szName)..[[" ]]
l_szRet = l_szRet..[[size="]]..tostring( szSize)..[[" ]]
l_szRet = l_szRet..[[maxlength="]]..tostring( szMaxLength)..[[" ]]
l_szRet = l_szRet..[[id="]]..tostring( szId)..[[" ]]
l_szRet = l_szRet..[[value="]]..box.tohtml(tostring( szValue))..[[" ]]
l_szRet = l_szRet..[[ ]]..tostring( szFunc)..[[ ]]
if ((szValResult ~= nil) and (szValResult ~="")) then
l_szRet = l_szRet..szValResult..[[ ]]
end
l_szRet = l_szRet..[[ >]]
return l_szRet
end
_input_plusplus = function ( szType, szName, szId, szValue, szSize, szMaxLength, szStyle, szFunc, szValResult)
local l_szRet = [[<input type="]]..tostring( szType)..[[" ]]
l_szRet = l_szRet..[[name="]]..tostring( szName)..[[" ]]
l_szRet = l_szRet..[[style="]]..tostring( szStyle)..[[" ]]
l_szRet = l_szRet..[[size="]]..tostring( szSize)..[[" ]]
l_szRet = l_szRet..[[maxlength="]]..tostring( szMaxLength)..[[" ]]
l_szRet = l_szRet..[[id="]]..tostring( szId)..[[" ]]
l_szRet = l_szRet..[[value="]]..box.tohtml(tostring( szValue))..[[" ]]
l_szRet = l_szRet..[[ ]]..tostring( szFunc)..[[ ]]
if ((szValResult ~= nil) and (szValResult ~="")) then
l_szRet = l_szRet..szValResult..[[ ]]
end
l_szRet = l_szRet..[[ >]]
return l_szRet
end
_input_new = function ( szType, szName, szId, szValue, szMaxLength, szClass, szStyle, szFunc)
local l_szRet = [[<input type="]]..tostring( szType)..[[" ]]
l_szRet = l_szRet..[[name="]]..tostring( szName)..[[" ]]
l_szRet = l_szRet..[[class="]]..tostring( szClass)..[[" ]]
l_szRet = l_szRet..[[style="]]..tostring( szStyle)..[[" ]]
l_szRet = l_szRet..[[maxlength="]]..tostring( szMaxLength)..[[" ]]
l_szRet = l_szRet..[[id="]]..tostring( szId)..[[" ]]
l_szRet = l_szRet..[[value="]]..box.tohtml(tostring( szValue))..[[" ]]
l_szRet = l_szRet..[[ ]]..tostring( szFunc)..[[ ]]
if ((szValResult ~= nil) and (szValResult ~="")) then
l_szRet = l_szRet..szValResult..[[ ]]
end
l_szRet = l_szRet..[[ >]]
return l_szRet
end
_textarea = function ( szName, szId, szValue, szRows, szCols, szValResult)
local l_szRet = [[<textarea ]]
l_szRet = l_szRet..[[name="]]..tostring( szName)..[[" ]]
l_szRet = l_szRet..[[rows="]]..tostring( szRows)..[[" ]]
l_szRet = l_szRet..[[cols="]]..tostring( szCols)..[[" ]]
l_szRet = l_szRet..[[id="]]..tostring( szId)..[[" ]]
if ((szValResult ~= nil) and (szValResult ~="")) then
l_szRet = l_szRet..szValResult..[[ ]]
end
l_szRet = l_szRet..[[ >]]
if ((szValue ~= nil) and (szValue ~="")) then
l_szRet = l_szRet..box.tohtml(szValue)..[[ ]]
end
l_szRet = l_szRet..[[</textarea>]]
return l_szRet
end
_checkbox = function ( szName, szId, szValue, bChecked, szFunction, szValResult)
local l_szRet = [[<input type="checkbox" ]]
l_szRet = l_szRet..[[name="]]..tostring( szName)..[[" ]]
l_szRet = l_szRet..[[value="]]..box.tohtml(tostring( szValue))..[[" ]]
l_szRet = l_szRet..[[id="]]..tostring( szId)..[[" ]]
if ( szFunction ~=nil ) then
l_szRet = l_szRet..[[ ]]..szFunction..[[ ]]
end
if ( bChecked ) then
l_szRet = l_szRet..[[ checked="checked" ]]
end
if ((szValResult ~= nil) and (szValResult ~="")) then
l_szRet = l_szRet..szValResult..[[ ]]
end
l_szRet = l_szRet..[[ >]]
return l_szRet
end
_radio = function ( szName, szId, szValue, bChecked, szFunction)
local l_szRet = [[<input type="radio" ]]
l_szRet = l_szRet..[[name="]]..tostring( szName)..[[" ]]
l_szRet = l_szRet..[[value="]]..box.tohtml(tostring( szValue))..[[" ]]
l_szRet = l_szRet..[[id="]]..tostring( szId)..[[" ]]
if ( szFunction ~=nil ) then
l_szRet = l_szRet..[[ ]]..szFunction..[[ ]]
end
if ( bChecked == true) then
l_szRet = l_szRet..[[ checked="checked" ]]
end
l_szRet = l_szRet..[[ >]]
return l_szRet
end
_radio_plus = function ( szName, szId, szValue, bChecked, szStyle, szFunction)
local l_szRet = [[<input type="radio" ]]
l_szRet = l_szRet..[[name="]]..tostring( szName)..[[" ]]
l_szRet = l_szRet..[[value="]]..box.tohtml(tostring( szValue))..[[" ]]
l_szRet = l_szRet..[[id="]]..tostring( szId)..[[" ]]
if ( szFunction ~=nil ) then
l_szRet = l_szRet..[[ ]]..szFunction..[[ ]]
end
if (szStyle ~= "") then
l_szRet = l_szRet..[[ style="]]..szStyle..[[" ]]
end
if ( bChecked ) then
l_szRet = l_szRet..[[ checked="checked" ]]
end
l_szRet = l_szRet..[[ >]]
return l_szRet
end
_label = function ( szForId, szId, szText, szStyle, szClass)
local l_szRet = [[<label ]]
if ( szClass ~=nil ) then
l_szRet = l_szRet..[[class="]]..szClass..[[" ]]
end
if ( szStyle ~=nil ) then
l_szRet = l_szRet..[[style="]]..szStyle..[[" ]]
end
l_szRet = l_szRet..[[for="]]..tostring( szForId)..[[" ]]
l_szRet = l_szRet..[[id="]]..tostring( szId)..[[" ]]
l_szRet = l_szRet..[[>]]..box.tohtml(tostring( szText))..[[</label>]]
return l_szRet
end
_span = function ( szText, bTitle, bNoBreak)
local l_szRet = ""
if bNoBreak then
l_szRet = [[<nobr>]]
end
l_szRet = l_szRet..[[<span ]]
if bTitle then
l_szRet = l_szRet..[[title="]]..box.tohtml(szText)..[[" ]]
end
l_szRet = l_szRet..[[>]]..box.tohtml(szText)..[[</span>]]
if bNoBreak then
l_szRet = l_szRet..[[</nobr>]]
end
return l_szRet
end
_span_plus = function ( szID, szText, bTitle, bNoBreak)
local l_szRet = ""
if bNoBreak then
l_szRet = [[<nobr>]]
end
l_szRet = l_szRet..[[<span id="]]..szID..[[" ]]
if bTitle then
l_szRet = l_szRet..[[title="]]..box.tohtml(szText)..[["]]
end
l_szRet = l_szRet..[[>]]..box.tohtml(szText)..[[</span>]]
if bNoBreak then
l_szRet = l_szRet..[[</nobr>]]
end
return l_szRet
end
_span_plusplus = function ( szID, szText, bTitle, bNoBreak, szClass, szStyle)
local l_szRet = ""
if bNoBreak then
l_szRet = [[<nobr>]]
end
l_szRet = l_szRet..[[<span id="]]..szID..[[" ]]
if bTitle then
l_szRet = l_szRet..[[title="]]..box.tohtml(szText)..[[" ]]
end
if ( szClass ~= nil) then
l_szRet = l_szRet..[[class="]]..box.tohtml(szClass)..[[" ]]
end
if ( szStyle ~= nil) then
l_szRet = l_szRet..[[class="]]..box.tohtml(szStyle)..[[" ]]
end
l_szRet = l_szRet..[[>]]..box.tohtml(szText)..[[</span>]]
if bNoBreak then
l_szRet = l_szRet..[[</nobr>]]
end
return l_szRet
end
_image = function ( szID, szUrl, szTitle, szAlternative, szStyle, bNoBreak)
local l_szRet = ""
if bNoBreak then
l_szRet = [[<nobr>]]
end
l_szRet = l_szRet..[[<img id="]]..szID..[[" ]]
l_szRet = l_szRet..[[src="]]..szUrl..[[" ]]
if (szTitle ~= "" ) then
l_szRet = l_szRet..[[ title="]]..szTitle..[["]]
end
if (szAlternative ~= "") then
l_szRet = l_szRet..[[ alt="]]..szAlternative..[["]]
end
if (szStyle ~= "") then
l_szRet = l_szRet..[[ style="]]..szStyle..[["]]
end
l_szRet = l_szRet..[[>]]
if bNoBreak then
l_szRet = l_szRet..[[</nobr>]]
end
return l_szRet
end
_canvas = function ( szID, szWidth, szHeight, szClass, szStyle)
local l_szRet = ""
if bNoBreak then
l_szRet = [[<nobr>]]
end
l_szRet = l_szRet..[[<canvas id="]]..szID..[[" ]]
l_szRet = l_szRet..[[width="]]..szWidth..[[" ]]
l_szRet = l_szRet..[[height="]]..szHeight..[[" ]]
if (szClass ~= "" ) then
l_szRet = l_szRet..[[ class="]]..szClass..[["]]
end
if (szStyle ~= "") then
l_szRet = l_szRet..[[ style="]]..szStyle..[["]]
end
l_szRet = l_szRet..TXT([[>{?888:881?}</canvas>]])
return l_szRet
end
find_elem_of = function( t_content, value, sub_elem)
if ( #t_content > 0 ) then
for i=1, #t_content do
if ( sub_elem == nil) then
if ( t_content[i] == value) then
return i
end
else
if ( t_content[i][sub_elem] == value) then
return i
end
end
end
end
return (-1)
end
