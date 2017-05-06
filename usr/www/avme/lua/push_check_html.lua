--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall)
--[[
Datei Name: push_check_html.lua
Datei Beschreibung: Bereitstellung für Statusanzeige des Push Service Tests
]]
require("textdb")
require"href"
g_statemsg = {
TXT([[{?1680:836?}]]),
TXT([[{?1680:454?}]]),
TXT([[{?1680:752?}]]),
TXT([[{?1680:619?}]]),
TXT([[{?1680:55?}]]),
TXT([[{?1680:445?}]]),
TXT([[{?1680:387?}]]),
TXT([[{?1680:514?}]]),
TXT([[{?1680:577?}]]),
TXT([[{?1680:125?}]]),
TXT([[{?1680:753?}]]),
TXT([[{?1680:520?}]]),
TXT([[{?1680:433?}]]),
TXT([[{?1680:898?}]]),
TXT([[{?1680:492?}]])
}
function get_javascripts()
box.out('var g_queryVars = {\n')
box.out( 'state: { query: "emailnotify:settings/LastMailerStatus" }\n')
box.out('};\n')
box.out('function cbWait()\n')
box.out('{\n')
box.out( 'var state = parseInt(g_queryVars.state.value, 10);\n')
box.out( 'if (state == 2)\n')
box.out( 'return false;\n')
box.out( 'var img = jxl.get("uiStateImg");\n')
box.out( 'if (state == 0)\n')
box.out( 'img.src = "/css/default/images/finished_ok_green.gif";\n')
box.out( 'else\n')
box.out( 'img.src = "/css/default/images/finished_error.gif";\n')
box.out( 'switch(state) {\n')
for i,str in ipairs(g_statemsg) do
box.out('case '..tostring(i-1)..':jxl.setHtml("state", "')
box.js(str)
box.out('");\n')
box.out('break;\n')
end
box.out( 'default:')
box.out( 'jxl.setHtml("state", "' .. box.tojs(TXT([[{?1680:434?}]])) .. '");')
box.out( 'break;')
box.out( '}')
box.out( 'jxl.show("btn_form_foot");')
box.out( 'return true;')
box.out('}')
box.out('function init()')
box.out('{')
-- der Button ist nur für Javascript-lose gedacht
box.out( 'jxl.hide("uiRefresh");')
box.out( 'jxl.hide("btn_form_foot");')
box.out( 'ajaxWait(g_queryVars, "' .. box.tojs(box.glob.sid) .. '", 3000, cbWait);')
box.out('}')
box.out('ready.onReady(init);')
end
function get_html(refreshname, backname, callback, helppage)
local state = tonumber(box.query("emailnotify:settings/LastMailerStatus")) or 2
box.out('<p>' .. TXT([[{?1680:814?}]]) .. '</p>')
box.out('<p class="waitimg"><img src="/css/default/images/')
if state == 0 then
box.out("finished_ok_green.gif")
elseif state == 2 then
box.out("wait.gif")
else
box.out("finished_error.gif")
end
box.out('" alt="' .. TXT([[{?1680:967?}]]) .. '" id="uiStateImg"></p>')
box.out('<p id="state">')
box.html( g_statemsg[state+1])
box.out('</p>')
box.out('<form method="GET" action="/system/push_check.lua">')
box.out( '<input type="hidden" name="sid" value="' .. box.tohtml(box.glob.sid) .. '">')
if callback ~= nil then
callback()
end
box.out( '<div id="btn_form_foot">')
box.out( '<button type="submit" name="'..refreshname..'" id="uiRefresh">' .. TXT([[{?txtRefresh?}]]) .. '</button>')
box.out( '<button type="submit" name="'..backname..'">' .. TXT([[{?txtBack?}]]) .. '</button>')
if helppage and "string" == type(helppage) then
g_page_help = helppage
end
box.out( '</div>')
box.out('</form>')
end
