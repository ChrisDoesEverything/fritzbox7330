<?lua
require"general"
function show_msn()
if config.oem == 'kdg' then
return [[<div id="ShowMSN" class="formular"><p>]]..box.tohtml(TXT([[{?7832:197?}]]))..[[</p>
<label id="labelMSN" for="uiMSN">]]..box.tohtml(TXT([[{?7832:921?}]]))..[[</label><input type="text" name="msn" id="uiMSN" value="]]..tostring(g_num.fondata[1].msnnum)..[["></div>]]
end
return ""
end
function show_sipname()
require("fon_numbers_html")
local str_out=[[<p id="uiNameExplainText">]]..fon_numbers_html.get_hint()..[[</p>]]
val = tostring(g_num.fondata[1].name or [[]])
str_out = str_out..[[<div class="formular"><label for="uiSipName_1">{?7832:43?}</label><input type="text" name="sipname_1" id="uiSipName_1" value="]]..val..[["></div>]]
return str_out
end
?>
<div>
<h4>
<?lua
if(TXT_CHANGE) then
box.html(general.sprintf([[{?7832:354?}]],g_num.fondata[1].number1 or [[]]))
else
box.html(general.sprintf([[{?7832:557?}]],g_num.fondata[1].number1 or [[]]))
end
?>
</h4>
<div>
<?lua
if g_num.is_expert then
box.out(show_sipname())
end
box.out(show_msn())
?>
</div>
</div>
