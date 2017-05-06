--[[Access denied<?lua
    box.end_page()
?>?>]]
module(...,package.seeall);
require("libluaxml")
require("textdb")
local confs={}
local function get_next_moment(m,tp,day,idx,point,action)
idx=idx+1
while idx>#m[day]do
if action==1 then
table.insert(tp[day],{["start"]=point,["stop"]="2400"})
end
point="0000"
idx=1
day=day+1
if day>7 then
day=1
end
end
return day,idx,point
end
local function moments_to_timeplan(m)
local timeplan={{},{},{},{},{},{},{}}
local start_day=nil
local start_idx=nil
for day=1,7 do
for idx,moment in ipairs(m[day])do
if moment.action==1 then
start_day=day
start_idx=idx
break
end
end
if start_day~=nil then break end
end
if start_day==nil then
return timeplan
end
local action=1
local day,idx,point=get_next_moment(m,timeplan,start_day,start_idx,m[start_day][start_idx].time,action)
while day~=start_day or idx~=start_idx do
if m[day][idx].action~=action then
if action==1 then
table.insert(timeplan[day],{["start"]=point,["stop"]=m[day][idx].time})
end
point=m[day][idx].time
action=1-action
end
day,idx,point=get_next_moment(m,timeplan,day,idx,point,action)
end
if#timeplan[1]>1 and timeplan[1][#timeplan[1]].start=="0000"then
table.insert(timeplan[1],1,timeplan[1][#timeplan[1]])
table.remove(timeplan[1])
end
return timeplan
end
local function insert_moment(t,time,action)
for idx,moment in ipairs(t)do
if time<moment.time then
table.insert(t,idx,{["time"]=time,["action"]=tonumber(action)})
return
end
end
table.insert(t,{["time"]=time,["action"]=tonumber(action)})
end
local function xml_to_timeplan(rule)
local moments={{},{},{},{},{},{},{}}
for _,item in ipairs(rule.children)do
if not item.attrs.enabled or item.attrs.enabled~="0"then
local daybits=tonumber(item.attrs.day)
for day=1,7 do
if math.floor(daybits/2^(day-1))%2==1 then
if item.attrs.time=="0000"and item.attrs.action=="0"then
if day>1 then
insert_moment(moments[day-1],"2400","0")
else
insert_moment(moments[7],"2400","0")
end
else
insert_moment(moments[day],item.attrs.time,item.attrs.action)
end
end
end
end
end
return moments_to_timeplan(moments)
end
local function get_legend(legend)
local str=""
if legend and legend.active and legend.inactive then
str=string.format([[
      <div class="legend">
        <div id="legend_active">%s</div>
        <div id="legend_inactive">%s</div>
      </div>
    ]],box.tohtml(legend.active),box.tohtml(legend.inactive))
end
return str
end
function get_html(id,legend)
return[[
  <div class="timer_container" id="]]..id..[[">
    <div class="upperHourscale">
      <span>0</span>
      <span>2</span>
      <span>4</span>
      <span>6</span>
      <span>8</span>
      <span>10</span>
      <span>12</span>
      <span>14</span>
      <span>16</span>
      <span>18</span>
      <span>20</span>
      <span>22</span>
      <span>24</span>
    </div>
    <div class="dayscale">
      <div>]]..TXT([[{?182:844?}]])..[[</div>
      <div>]]..TXT([[{?182:329?}]])..[[</div>
      <div>]]..TXT([[{?182:886?}]])..[[</div>
      <div>]]..TXT([[{?182:228?}]])..[[</div>
      <div>]]..TXT([[{?182:499?}]])..[[</div>
      <div class="weekend">]]..TXT([[{?182:772?}]])..[[</div>
      <div class="weekend">]]..TXT([[{?182:371?}]])..[[</div>
    </div>
    <div class="week" id="]]..id..[[Week" unselectable="on">
      <div class="day" id="]]..id..[[Monday"></div>
      <div class="day" id="]]..id..[[Tuesday"></div>
      <div class="day" id="]]..id..[[Wednesday"></div>
      <div class="day" id="]]..id..[[Thursday"></div>
      <div class="day" id="]]..id..[[Friday"></div>
      <div class="day" id="]]..id..[[Saturday"></div>
      <div class="day lastday" id="]]..id..[[Sunday"></div>
    </div>
    <div class="hourscale">
      <span>0</span>
      <span>2</span>
      <span>4</span>
      <span>6</span>
      <span>8</span>
      <span>10</span>
      <span>12</span>
      <span>14</span>
      <span>16</span>
      <span>18</span>
      <span>20</span>
      <span>22</span>
      <span>24</span>
    </div>
  ]]
..get_legend(legend)
..[[
  <div class="msg_box hide" id="]]..id..[[MsgBox">]]..TXT([[{?182:16?}]])..[[</div>
  </div>
  ]]
end
function write_html(id,legend)
box.out(get_html(id,legend))
end
function get_data_js(id,rule)
if not confs[id]then confs[id]={}end
local str="["
local tp=confs[id].timeplan
if rule and confs[id].timeplan then
tp=confs[id].timeplan[rule]
end
for day=1,7 do
str=str.."["
if tp then
for idx,p in ipairs(tp[day])do
if idx>1 then str=str..","end
local start_hour=tostring(tonumber(string.sub(p.start,1,-3)))
local start_minute=tostring(tonumber(string.sub(p.start,-2)))
local end_hour=tostring(tonumber(string.sub(p.stop,1,-3)))
local end_minute=tostring(tonumber(string.sub(p.stop,-2)))
str=str.."new Period(new Moment("..
tostring(day-1)..","..start_hour..","..start_minute..
"), new Moment("..
tostring(day-1)..","..end_hour..","..end_minute.."))"
end
end
str=str.."]"
if day<7 then str=str..","end
end
str=str.."]"
return str
end
function write_data_js(id,rule)
box.out(get_data_js(id,rule))
end
function read_tam(id,tam_idx)
if not confs[id]then confs[id]={}end
confs[id].enabled=false
local cnt=tonumber(box.query("timer:settings/TamTimerXML/count"))
if cnt and cnt>0 then
local xmlstr=box.query("timer:settings/TamTimerXML"..tostring(tam_idx))
local root=xml.parse(xmlstr);
if next(root)and root[1].attrs then
if root[1].attrs.enabled=="1"then
confs[id].enabled=true
end
confs[id].timeroot=root;
confs[id].timeplan=xml_to_timeplan(root[1])
end
end
end
function is_tam_timeplan_enabled(id)
if not confs[id]then confs[id]={}end
return confs[id].enabled
end
function has_tam_timeplan(id)
if not confs[id]then confs[id]={}end
return confs[id].timeplan~=nil
end
function read_wlan(id)
if not confs[id]then confs[id]={}end
confs[id].enabled=false
confs[id].daily=true
local cnt=tonumber(box.query("timer:settings/WLANTimerXML/count"))
if cnt and cnt>0 then
for rule=1,cnt do
local xmlstr=box.query("timer:settings/WLANTimerXML"..tostring(rule-1))
local root=xml.parse(xmlstr);
if next(root)and root[1].attrs then
if root[1].attrs.id=="1"then
if root[1].attrs.enabled=="1"then
confs[id].daily=false
confs[id].enabled=true
end
confs[id].timeroot=root;
confs[id].timeplan=xml_to_timeplan(root[1])
end
if root[1].attrs.id=="0"then
confs[id].dailyroot=root;
if root[1].attrs.enabled=="1"then
confs[id].daily=true
confs[id].enabled=true
end
for _,child in ipairs(root[1].children)do
if child.attrs then
if child.attrs.action=="1"then
confs[id].daily_start=child.attrs.time
else
confs[id].daily_end=child.attrs.time
end
end
end
end
end
end
end
end
function get_wlan_daily_xml(id,enabled)
if not confs[id]then confs[id]={}end
local xmlsrc=[[<rule id="0" enabled="]]
if enabled then xmlsrc=xmlsrc.."1"else xmlsrc=xmlsrc.."0"end
xmlsrc=xmlsrc..[[">]]
if enabled then
xmlsrc=xmlsrc..[[<item enabled="1" time="]]..string.format("%02d",box.post.start_hour)..string.format("%02d",box.post.start_minute)..[[" action="0" day="127" onetime="0"/>]]
xmlsrc=xmlsrc..[[<item enabled="1" time="]]..string.format("%02d",box.post.end_hour)..string.format("%02d",box.post.end_minute)..[[" action="1" day="127" onetime="0"/>]]
elseif confs[id].dailyroot and confs[id].dailyroot[1]then
for _,c in ipairs(confs[id].dailyroot[1].children)do
xmlsrc=xmlsrc.."<"..c.name
for name,value in pairs(c.attrs)do
xmlsrc=xmlsrc..[[ ]]..name..[[="]]..value..[["]]
end
xmlsrc=xmlsrc.."/>"
end
end
xmlsrc=xmlsrc..[[</rule>]]
return xmlsrc
end
function get_timeplan_xml(id,index,enabled)
if not confs[id]then confs[id]={}end
local xmlstr=[[<rule id="]]..tostring(index)..[[" enabled="]]
if enabled then xmlstr=xmlstr..[[1]]else xmlstr=xmlstr..[[0]]end
xmlstr=xmlstr..[[">]]
if enabled then
for name,value in pairs(box.post)do
if string.sub(name,1,11)=="timer_item_"and string.sub(name,-2)~="_i"then
local time,action,days=string.match(value,"(%d*);(%d*);(%d*)")
if time=="2400"then
time="0000"
days=tonumber(days)*2
if days>127 then
days=(days+1)%128
end
end
xmlstr=xmlstr..[[<item time="]]..tostring(time)..[[" action="]]..tostring(action)..[[" day="]]..tostring(days)..[["/>]]
end
end
elseif confs[id].timeroot and confs[id].timeroot[1]then
for _,c in ipairs(confs[id].timeroot[1].children)do
xmlstr=xmlstr..[[<]]..c.name
for name,value in pairs(c.attrs)do
xmlstr=xmlstr..[[ ]]..name..[[="]]..value..[["]]
end
xmlstr=xmlstr..[[/>]]
end
end
return xmlstr..[[</rule>]]
end
function get_wlan_timeplan_xml(id,enabled)
return get_timeplan_xml(id,1,enabled)
end
function get_tam_timeplan_xml(id,tam_idx,enabled)
return get_timeplan_xml(id,tam_idx,enabled)
end
function daily_mode(id)
if not confs[id]then confs[id]={}end
return confs[id].daily
end
function daily_start(id)
if not confs[id]then confs[id]={}end
return confs[id].daily_start or""
end
function daily_end(id)
if not confs[id]then confs[id]={}end
return confs[id].daily_end or""
end
function active(id)
if not confs[id]then confs[id]={}end
return confs[id].enabled
end
function has_wlan_timeplan(id)
if not confs[id]then confs[id]={}end
return confs[id].timeplan~=nil
end
function read_kids(id)
if not confs[id]then confs[id]={}end
confs[id].timeplan={}
confs[id].timeroot={}
confs[id].timerid={}
local cnt=tonumber(box.query("timer:settings/KidsTimerXML/count"))
if cnt and cnt>0 then
for rule=1,cnt do
local xmlstr=box.query("timer:settings/KidsTimerXML"..tostring(rule-1))
local root=xml.parse(xmlstr)
confs[id].timeplan[tonumber(root[1].attrs.id)]=xml_to_timeplan(root[1])
confs[id].timeroot[tonumber(root[1].attrs.id)]=root[1]
confs[id].timerid[tonumber(root[1].attrs.id)]=rule-1
end
end
end
function now_allowed(id,ruleid)
if not confs[id]then confs[id]={}end
if not confs[id].timeplan then confs[id].timeplan={}end
local tp=confs[id].timeplan[ruleid]
if tp then
local now=os.date("*t")
now.wday=((now.wday+5)%7)+1
local nowhhmm=tonumber(string.format("%02d",now.hour)..string.format("%02d",now.min))
for _,p in ipairs(tp[now.wday])do
if tonumber(p.start)<=nowhhmm then
if nowhhmm<=tonumber(p.stop)then
return true
end
else
return false
end
end
end
return false
end
function entire_day(id,ruleid,wday)
if not confs[id]then confs[id]={}end
if not confs[id].timeplan then confs[id].timeplan={}end
local tp=confs[id].timeplan[ruleid]
if tp then
wday=tonumber(wday)
if not wday then
local now=os.date("*t")
wday=((now.wday+5)%7)+1
end
return#tp[wday]==1 and tp[wday][1].start=="0000"and tp[wday][1].stop=="2400"
end
return false
end
function allowed_day(id,ruleid,wday)
if not confs[id]then confs[id]={}end
if not confs[id].timeplan then confs[id].timeplan={}end
local tp=confs[id].timeplan[ruleid]
if tp then
wday=tonumber(wday)
if not wday then
local now=os.date("*t")
wday=((now.wday+5)%7)+1
end
if#tp[wday]==0 then
return"never"
elseif#tp[wday]==1 and tp[wday][1].start=="0000"and tp[wday][1].stop=="2400"then
return"unlimited"
else
return"limited"
end
end
return""
end
function max_allowed_today(id,ruleid)
if not confs[id]then confs[id]={}end
if not confs[id].timeplan then confs[id].timeplan={}end
local tp=confs[id].timeplan[ruleid]
local result=0
if tp then
local now=os.date("*t")
local wday=((now.wday+5)%7)+1
for idx,p in ipairs(tp[wday])do
local start_hour=tonumber(string.sub(p.start,1,-3))
local start_minute=tonumber(string.sub(p.start,-2))
local start=start_hour*60+start_minute
local end_hour=tonumber(string.sub(p.stop,1,-3))
local end_minute=tonumber(string.sub(p.stop,-2))
local stop=end_hour*60+end_minute
result=result+(stop-start)
end
end
return result*60
end
function get_next_ruleid(id)
if not confs[id]then confs[id]={}end
if not confs[id].timeroot then confs[id].timeroot={}end
local i=1
while confs[id].timeroot[i]do i=i+1 end
return i
end
function get_timerid(id,ruleid)
if not confs[id]then confs[id]={}end
if not confs[id].timerid then confs[id].timerid={}end
return confs[id].timerid[ruleid];
end
function get_kids_xml(id,ruleid)
local xmlsrc=[[<rule id="]]..tostring(ruleid)..[[" enabled="1">]]
for name,value in pairs(box.post)do
if string.sub(name,1,11)=="timer_item_"and string.sub(name,-2)~="_i"then
local time,action,days=string.match(value,"(%d*);(%d*);(%d*)")
if time=="2400"then
time="0000"
days=tonumber(days)*2
if days>127 then
days=(days+1)%128
end
end
xmlsrc=xmlsrc..[[<item time="]]..tostring(time)..[[" action="]]..tostring(action)..[[" day="]]..tostring(days)..[["/>]]
end
end
xmlsrc=xmlsrc..[[</rule>]]
return xmlsrc
end
