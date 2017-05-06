--[[Access denied<?lua
    box.end_page()
?>?>?>]]
module(...,package.seeall);
require("general")
require("textdb")
require"lualib"
local g_wdaystr={
[[{?7663:269?}]],
[[{?7663:476?}]],
[[{?7663:435?}]],
[[{?7663:118?}]],
[[{?7663:184?}]],
[[{?7663:19?}]],
[[{?7663:532?}]],
[[{?7663:302?}]]
}
local monthstr={
[[{?7663:868?}]],
[[{?7663:864?}]],
[[{?7663:450?}]],
[[{?7663:817?}]],
[[{?7663:246?}]],
[[{?7663:643?}]],
[[{?7663:797?}]],
[[{?7663:135?}]],
[[{?7663:697?}]],
[[{?7663:761?}]],
[[{?7663:580?}]],
[[{?7663:334?}]]
}
function get_wday_str(idx)
if(idx>0 and idx<9)then
return g_wdaystr[idx]
end
return""
end
function get_current_timestr()
local now=os.date("*t")
return general.sprintf(
TXT([[{?7663:854?}]]),
TXT(g_wdaystr[now.wday]),now.day,TXT(monthstr[now.month]),now.year,
string.format("%02d",now.hour),string.format("%02d",now.min),string.format("%02d",now.sec)
)
end
function get_current_date()
local now=os.date("*t")
return general.sprintf(TXT([[{?7663:530?}]],tostring(now.day),tostring(now.month),tostring(now.year)))
end
function get_current_datestr()
local now=os.date("*t")
return general.sprintf(
TXT([[{?7663:469?}]]),
TXT(g_wdaystr[now.wday]),now.day,TXT(monthstr[now.month]),now.year)
end
local function sec2dhms(seconds)
seconds=tonumber(seconds)or 0
local minutes=math.floor(seconds/60)
seconds=seconds%60
local hours=math.floor(minutes/60)
minutes=minutes%60
local days=math.floor(hours/24)
hours=hours%24
return days,hours,minutes,seconds
end
function duration_str(seconds)
local t={sec2dhms(seconds)}
t=array.map(t,func.partial(string.format,"%02d"))
return table.concat(t,":")
end
function get_leading_zero(n_value)
if(tonumber(n_value)<10)then
return(tostring("0")..tostring(n_value))
end
return tostring(n_value)
end
