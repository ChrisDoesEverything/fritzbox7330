<?lua
package.path="../lua/?.lua"
require("check_sid")
box.header("Content-Type: text/xml \n\n")
?>
<?xml version="1.0" \?>
<?lua
require("textdb")
local wu = require('libwebusb')
wu_init_fail = wu.WebUsb_Init("<full-access>", false)
function lsdirwu(dir)
local list = {}
local count = 0
local nameidx = 1
local res, fail = wu.WebUsb_Browse("<full-access>", dir, "type:directory", 1, 0, "")
if not fail then
for idx, line in ipairs(res) do
if idx==1 then
-- the first line denotes the "table header". lets see which column holds the filename.
for iidx, head in ipairs(line) do
if head == "filename" then
nameidx = iidx
end
end
else
-- strange: root-dir: data starts at index 2, other: data starts at index 3
if ((dir == "/") or (idx > 2)) then
if line[nameidx]:len() > 0 then
count = count + 1
list[count] = line[nameidx]
end
end
end
end
end
return list
end
function lsdir(basedir)
local list = {}
local count = 0
local stdout = io.popen("ls -F '"..basedir.."' | grep '\/$'")
if stdout then
for dir in stdout:lines() do
count = count + 1
list[count] = dir:sub(0, dir:len()-1)
end
end
return list
end
function xml_escape(str)
str = string.gsub(str, "&", "&amp;")
str = string.gsub(str, "'", "&apos;")
str = string.gsub(str, "<", "&lt;")
str = string.gsub(str, ">", "&gt;")
str = string.gsub(str, '"', "&quot;")
return str
end
function listSubDirs(dirprefix)
local count = 0
--local list = lsdir(basedir)
local list = lsdirwu(dirprefix)
for idx,name in ipairs(list) do
box.out(" <dir><![CDATA[")
box.out(xml_escape(name))
box.out("]]></dir>\n")
count = count + 1
end
return count
end
box.out([[<subdirs base="]]..xml_escape(box.get.dir)..[[">]].."\n")
if gl.logged_in then
count = listSubDirs(box.get.dir)
else
box.out("<error>"..TXT([[{?2414:170?}]]).."</error>")
end
box.out("<count>"..tostring(count).."</count>")
?>
</subdirs>
