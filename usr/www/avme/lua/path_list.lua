--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall)
local wu = require('libwebusb')
wu_init_fail = wu.WebUsb_Init("<full-access>", false)
--gibt die Verzeichnistiefe an welche am anfang dargestellt werden soll.
initdepth = 1
function lsdirwu(dir)
local list = {}
local count = 0
local nameidx = 1
local s_type = 1
local res, fail = wu.WebUsb_Browse("<full-access>", dir, "type:directory", 1, 0, "")
if not fail then
for idx, line in ipairs(res) do
if idx==1 then
-- the first line denotes the "table header". lets see which column holds the filename.
for iidx, head in ipairs(line) do
if head == "filename" then
nameidx = iidx
elseif head == "storagetype" then
s_type = iidx
end
end
else
-- strange: root-dir: data starts at index 2, other: data starts at index 3
if ((dir == "/") or (idx > 2)) then
if line[nameidx]:len() > 0 then
count = count + 1
list[count] = {}
list[count].name = line[nameidx];
list[count].storagetype = line[s_type]
end
end
end
end
end
return list
end
function listSubDirs(depth, formatprefix, idprefix, dirprefix, basedir, withWebdav)
local count = 0
local subcount = 0
local tmpstr = ""
local idstr
local dirlist = lsdirwu(dirprefix)
local str = ""
--ausgabe der eventuell neuen sid
--box.out([[<script type="text/javascript">gVarSid="]]..box.glob.sid..[[";</script>]])
for idx,dir in ipairs(dirlist) do
if withWebdav or dir.storagetype ~= "webdav" then
if count==0 then
if depth < initdepth then
str = str..formatprefix.."<ul>"
else
str = str..formatprefix..[[<ul style="display:none;">]]
end
formatprefix = formatprefix .. " " .." "
end
count = count + 1
if depth < initdepth then
if dir.storagetype == "usb" then
str = str..formatprefix..[[<li class="disk">]]
else
str = str..formatprefix..[[<li class="directory">]]
end
else
str = str..formatprefix..[[<li class="incomplete">]]
end
if idprefix:len() == 0 then
idstr = "folder_" .. tostring(count)
else
idstr = idprefix .. "_" .. count
end
str = str..[[<input type="radio" name="dir" id="]]..idstr..[[" value="]]
str = str..box.tohtml(dirprefix..dir.name)
str = str..[[" onclick="enableOk()"> <label for="]]..idstr..[[">]]
str = str..box.tohtml(dir.name)
str = str..[[</label>]]
if depth < initdepth then
subcount, tmpstr = listSubDirs(depth+1, formatprefix.." ".." ", idstr, dirprefix..dir.name.."/", basedir..dir.name.."/")
if subcount > 0 then str = str..tmpstr end
else
subcount = 0
end
str = str..[[</li>]]
count = count + subcount
end
end
if count > 0 then
formatprefix = formatprefix:sub(0, formatprefix:len()-2)
str = str..formatprefix..[[</ul>]]
end
return count, str
end
