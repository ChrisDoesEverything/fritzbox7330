<?lua
package.path = "../?/?.lua;../lua/?.lua;../?.lua"
require("nas_init")
if not gl.logged_in then
box.out([[{"login":"failed"}]])
else
local tab, err = gl.bib.cw.call_webusb_func( "scan_info", gl.scan_detail )
if err == "" and tab then
box.out(gl.bib.js.table(tab))
else
box.out('{}')
end
end
?>
