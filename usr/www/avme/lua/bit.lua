--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
function isset(mask, pos)
if (not mask) then return false end
return (math.floor(mask / (math.pow(2, pos))) % 2) == 1
end
function isclr(mask, pos)
return (math.floor(mask / (math.pow(2, pos))) % 2) == 0
end
function set(mask, pos)
return isset(mask, pos) and mask or (mask + math.pow(2, pos))
end
function clr(mask, pos)
return isclr(mask, pos) and mask or (mask - math.pow(2, pos))
end
function maskand(mask1, mask2)
local pos = 0
local result = 0
while mask2 ~= 0 do
if ((mask1 + mask2) % 2) == 0 then
result = set(result, pos)
end
mask1 = math.floor(mask1 / 2)
mask2 = math.floor(mask2 / 2)
pos = pos + 1
end
return result
end
function maskor(mask1, mask2)
local pos = 0
local result = 0
while (mask1 ~= 0) or (mask2 ~= 0) do
if ((mask1 % 2) + (mask2 % 2)) ~= 0 then
result = set(result, pos)
end
mask1 = math.floor(mask1 / 2)
mask2 = math.floor(mask2 / 2)
pos = pos + 1
end
return result
end
function issetlist(mask)
local pos = 0
local result = {}
while (mask ~= 0)do
if (mask % 2) ~= 0 then
table.insert(result, pos)
end
mask = math.floor(mask / 2)
pos = pos + 1
end
return result
end
function tobits(num, len)
num = math.floor(tonumber(num) or 0)
len = len or 32
local result = {}
if num == 0 then table.insert(result, 0) end
while num > 0 do
table.insert(result, num % 2)
num = math.floor(num / 2)
end
for i = #result + 1, len do
table.insert(result, 0)
end
return setmetatable(result, {
__tostring = function(self) return string.reverse(table.concat(self)) end
})
end
function tonum(bits)
return tonumber(table.concat(bits or {}):reverse(), 2) or 0
end
