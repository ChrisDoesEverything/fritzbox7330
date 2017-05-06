--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
if not gl or not gl.logged_in then
box.end_page()
end
--[[
Die in Lua initialisierten Werte können mit diesem Modul in JS überführt werden.
]]
function get_gl_as_js()
if gl and type(gl) == "table" then
--Wichtig: Die Bibliotheken müssen raus da man sonst die Box in einen instabilen Zustand bringen kann.
-- Die Sid muss rein damit ich die auch in js habe.
local rescue_bib = gl.bib
gl.bib = {}
gl.sid = box.tohtml(box.tojs(box.glob.sid))
local ret_str = [[var gl = {]]..js.object(gl)..[[};]]
gl.sid = nil
gl.bib = rescue_bib
return ret_str
end
return ""
end
function get_gl_as_js_with_script_tags()
local str = get_gl_as_js()
if str and str ~= "" then
return [[<script type="text/javascript">]]..str..[[</script>]]
end
return ""
end
function write_gl_as_js()
local str = get_gl_as_js()
if str and str ~= "" then
box.out(str)
end
end
function write_gl_as_js_with_script_tags()
local str = get_gl_as_js_with_script_tags()
if str and str ~= "" then
box.out(str)
end
end
