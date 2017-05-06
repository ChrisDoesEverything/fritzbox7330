--[[Access denied<?lua
    box.end_page()
?>?>]]
-- de-first -begin  
require"isp"
require"textdb"
require"html"
require"newval"
require"general"
authform={}
local template={
user=[[
    <div class="formular">
      <label for="$id$">$label$</label>
      <span class="prefix">$prefix$</span>
      <input type="text" name="$name$" autocomplete="off" value="$value$" id="$id$" $maxlength$ class="$valclass$">
      <span class="postfix">$postfix$</span>
      $valmsg$
    </div>
  ]],
pwd=[[
    <div class="formular">
      <label for="$id$">$label$</label>
      <input type="text" name="$name$" autocomplete="off" value="$value$" id="$id$" $maxlength$ class="$valclass$">
      $valmsg$
    </div>
  ]],
subprovider=[[
    <div class="formular">
      <input type="radio" name="$name$" autocomplete="off" value="$value$" $checked$ id="$id$">
      <label for="$id$">$label$</label>
    </div>
  ]]
}
local function fill_template(template_str,params)
template_str=template_str or""
params=params or{}
return(template_str:gsub("%$([a-zA-Z%d_]+)%$",function(m)return params[m]or""end))
end
local data=setmetatable({},{
__index=function(self,param)return self.other.auth end
})
data.other={
subproviders={'auth','noauth'},
subprovider_class="hideif_dslstandard",
subprovider_head=TXT([[{?8598:541?}]]),
{name='subprovider',value='auth',label=TXT([[{?8598:400?}]]),template=template.subprovider},
{name='subprovider',value='noauth',label=TXT([[{?8598:63?}]]),template=template.subprovider},
auth={
{name='user',label=TXT([[{?txtUsername?}]]),template=template.user},
{name='pwd',label=TXT([[{?txtKennwort?}]]),template=template.pwd}
}
}
data.other_named=data.other
data['1und1']={
{name='user',label=[[Internetzugangs-Kennung]],prefix="1und1/",postfix="@online.de",template=template.user},
{name='pwd',label=[[Internetzugangs-Passwort]],template=template.pwd}
}
data.alice={
{name='user',label=[[Rufnummer des Festnetzanschlusses]],template=template.user},
{name='pwd',label=[[Passwort]],template=template.pwd}
}
data.congstar={
{name='user',label=[[Benutzername]],postfix="@congstar.de",template=template.user},
{name='pwd',label=[[Vertragspasswort]],template=template.pwd}
}
data.congstar_vdsl=data.congstar
data.ewetel={
{name='user',label=[[Benutzername]],template=template.user},
{name='pwd',label=[[Passwort]],template=template.pwd}
}
data.gmx={
{name='user',label=[[Internetzugangs-Kennung]],prefix="GMX/",postfix="@online.de",template=template.user},
{name='pwd',label=[[Internetzugangs-Passwort]],template=template.pwd}
}
data.mnet={
{name='user',label=[[Benutzername]],template=template.user},
{name='pwd',label=[[Passwort]],template=template.pwd}
}
data.netaachen={
{name='user',label=[[Benutzername]],postfix="@netaachen.de",template=template.user},
{name='pwd',label=[[Passwort]],template=template.pwd}
}
data.netcologne={
{name='user',label=[[Benutzername]],postfix="@netcologne.de",template=template.user},
{name='pwd',label=[[Passwort]],template=template.pwd}
}
data.nordcom={
{name='user',label=[[Benutzername]],template=template.user},
{name='pwd',label=[[Passwort]],template=template.pwd}
}
data.osnatel={
{name='user',label=[[Benutzername]],template=template.user},
{name='pwd',label=[[Passwort]],template=template.pwd}
}
data.teleos={
{name='user',label=[[Benutzername]],template=template.user},
{name='pwd',label=[[Passwort]],template=template.pwd}
}
data.telefonica={
{name='pin',label=[[15-stellige PIN]],maxlength=15,template=template.pwd}
}
data.telefonica_fttx=data.telefonica
data.telefonica_fttb=data.telefonica
data.o2={
subproviders={'withoutpin','withpin'},
{name='subprovider',value='withoutpin',label=[[Internetzugang ohne PIN]],template=template.subprovider},
{name='subprovider',value='withpin',label=[[Internetzugang mit PIN]],template=template.subprovider},
withpin={
{name='pin',label=[[15-stellige PIN]],maxlength=15,template=template.pwd}
}
}
data.o2_7270_native=data.o2
data.tonline={
subproviders={'home','business'},
{name='subprovider',value='home',label=isp.providername('tonline'),template=template.subprovider},
{name='subprovider',value='business',label=isp.providername('tonline')..[[ Business]],template=template.subprovider},
home={
{name='anschlusskennung',label=[[Anschlusskennung]],maxlength=12,template=template.user},
{name='tonlinenummer',label=[[Zugangsnummer]],maxlength=12,template=template.user},
{name='mitbenutzersuffix',label=[[Mitbenutzernummer]],maxlength=4,template=template.user},
{name='pwd',label=[[Persönliches Kennwort]],template=template.pwd}
},
business={
{name='user',label=[[Benutzerkennung]],postfix="@t-online-com.de",template=template.user},
{name='pwd',label=[[Persönliches Kennwort]],template=template.pwd}
}
}
local auth_explain=TXT([[{?8598:239?}]])
local function get_data(provider,subprovider)
local af=data[provider]
if subprovider then
af=af[subprovider]
end
return af
end
local function get_initial_subprovider(provider,username,password)
if provider=='tonline'then
if'tonline'==isp.initial_provider()then
return username:match(".+(@t%-online%-com%.de)")and'business'or'home'
else
return'home'
end
elseif isp.is("o2",provider)then
if isp.is("o2")then
return username:match("(o2@).+")and'withoutpin'or'withpin'
else
return'withoutpin'
end
elseif isp.is_other(provider)then
if provider==isp.initial_provider()then
if isp.initial_auth(provider)or
(username and#username>0 or password and password=="****")then
return'auth'
else
return'noauth'
end
else
return'auth'
end
end
end
local function get_tonline_values(username)
local result={}
local nums=(username or""):gsub(string.esc("@t-online.de").."$","")
nums=nums:split("#")
if#nums==3 then
result.anschlusskennung=nums[1]
result.tonlinenummer=nums[2]
result.mitbenutzersuffix=nums[3]
elseif#nums==2 then
result.anschlusskennung=nums[1]:sub(1,12)
result.tonlinenummer=nums[1]:sub(13)
result.mitbenutzersuffix=nums[2]
elseif#nums==1 then
result.anschlusskennung=nums[1]:sub(1,12)
result.tonlinenummer=nums[1]:sub(13,24)
result.mitbenutzersuffix=nums[1]:sub(25)
end
return result
end
local function get_initial_values(provider)
local values={}
local username,password,stars
if provider==isp.initial_provider()then
username=box.query("connection0:settings/username")
password=box.query("connection0:settings/password")
else
local def=isp.auth_defaults(provider)or{}
username=def.username
password=def.pwd
stars=password and#password>0
end
username=username or""
password=password or""
local af=data[provider]
values.subprovider=get_initial_subprovider(provider,username,password)
if isp.is("telefonica",provider)then
values.pin=password
elseif isp.is("o2",provider)then
if values.subprovider=='withpin'then
values.pin=password
end
elseif provider=='tonline'then
if values.subprovider=='home'then
values=table.update(values,get_tonline_values(username))
values.pwd=stars and"****"or password
elseif values.subprovider=='business'then
af=af.business
local idx=array.find(af,func.eq('user','name'))
if idx then
if af[idx].prefix then
username=username:gsub("^"..string.esc(af[idx].prefix),"")
end
if af[idx].postfix then
username=username:gsub(string.esc(af[idx].postfix).."$","")
end
values.user=username
end
if array.find(af,func.eq('pwd','name'))then
values.pwd=stars and"****"or password
end
end
else
if values.subprovider then
af=af[values.subprovider]
end
local idx=array.find(af,func.eq('user','name'))
if idx then
if af[idx].prefix then
username=username:gsub("^"..string.esc(af[idx].prefix),"")
end
if af[idx].postfix then
username=username:gsub(string.esc(af[idx].postfix).."$","")
end
values.user=username
end
if array.find(af,func.eq('pwd','name'))then
values.pwd=stars and"****"or password
end
end
return values
end
local function get_input_html(item,initial,provider,subprovider)
local params={}
params.name=isp.html_name(item.name,provider,subprovider)
params.id=isp.html_id(params.name,item.value)
params.label=item.label
params.prefix=item.prefix
params.postfix=item.postfix
if item.maxlength then
params.maxlength=[[maxlength="]]..item.maxlength..[["]]
end
local value=isp.read_post_var(item.name,provider,subprovider)
value=value or initial[item.name]
if item.value then
params.value=item.value
if item.value==value then
params.checked="checked"
end
else
params.value=value
end
return html.raw(fill_template(item.template,params))
end
function authform.get_html(provider,options)
options=options or{}
if options.force_display or isp.is_other(provider)or isp.auth_needed(provider)then
local initial=get_initial_values(provider)
local af=data[provider]
if options.initial_subprovider then
initial.subprovider=options.initial_subprovider
end
if options.subprovider then
initial.subprovider=options.subprovider
af=af[options.subprovider]
end
local result=html.fragment()
if not options.subprovider and af.subproviders then
if af.subprovider_head then
result.add(html.p{class=af.subprovider_class,af.subprovider_head})
end
for i,item in ipairs(af)do
local inp=get_input_html(item,initial,provider,item.value)
if af.subprovider_class then
result.add(html.div{class=af.subprovider_class,inp})
else
result.add(inp)
end
local sub_af=af[item.value]
if sub_af then
local subdiv=html.div{class="formular showif_"..item.value}
if not options.noexplain then
subdiv.add(html.div{class="formular",html.p{auth_explain}})
end
for j,subitem in ipairs(sub_af)do
subdiv.add(get_input_html(subitem,initial,provider,item.value))
end
result.add(subdiv)
end
end
else
result.add(html.p{auth_explain})
for i,item in ipairs(af or{})do
result.add(get_input_html(item,initial,provider,options.subprovider))
end
end
return result
end
end
function authform.write_html(provider)
authform.get_html(provider).write()
end
function authform.write_subprovider_css(provider)
local sub=data[provider].subproviders
if sub and#sub>1 then
local selectors={}
local fmt=[[.isp_%s.sub_%s .showif_%s .showif_%s]]
for i1,sub1 in ipairs(sub)do
for i2,sub2 in ipairs(sub)do
if sub1~=sub2 then
table.insert(selectors,
fmt:format(provider,sub1,provider,sub2)
)
end
end
end
box.out("\n",
table.concat(selectors,",\n"),
" {\n  display: none;\n}"
)
end
end
function authform.subprovider_radioname(provider)
local af=data[provider]
if af.subproviders then
return isp.html_name("subprovider",provider)
end
end
local function read_user_pass_tonline_home()
local anschlusskennung=isp.read_post_var('anschlusskennung','tonline','home')
local tonlinenummer=isp.read_post_var('tonlinenummer','tonline','home')
local mitbenutzersuffix=isp.read_post_var('mitbenutzersuffix','tonline','home')
if anschlusskennung and tonlinenummer and mitbenutzersuffix then
local username=table.concat(
{anschlusskennung,tonlinenummer,mitbenutzersuffix},"#"
)..[[@t-online.de]]
local password=isp.read_post_var('pwd','tonline','home')
return username,password
end
end
local function read_user_pass_telefonica(provider)
local tpin=isp.read_post_var('pin',provider)
if tpin and tpin~=""and tpin~="****"then
return tpin:sub(1,3)..[[/]]..tpin:sub(4,9)..[[@be-converged-data.com]],tpin:sub(10)
end
if tpin=="****"then
return box.query("connection0:settings/username"),tpin
end
end
local function read_user_pass_o2(provider,subprovider)
local domain
local username=box.query("connection0:settings/username")
if isp.is("o2")then
domain=username:match(".*(@.*)")
end
domain=domain or[[@dsl.o2online.de]]
if subprovider=='withpin'then
local o2pin=isp.read_post_var('pin',provider,'withpin')
if o2pin=="****"then
return username,o2pin
elseif o2pin and o2pin~=""then
return o2pin:sub(1,6)..domain,o2pin:sub(7)
end
elseif subprovider=='withoutpin'then
return[[o2]]..domain,[[Freeway]]
end
end
function authform.read_user_pass(provider)
local subprovider=isp.read_post_var('subprovider',provider)
if provider=='tonline'and subprovider=='home'then
return read_user_pass_tonline_home()
end
if isp.is("telefonica",provider)then
return read_user_pass_telefonica(provider)
end
if isp.is("o2",provider)then
return read_user_pass_o2(provider,subprovider)
end
local af=get_data(provider,subprovider)
local username,password
local i,item=array.find(af,func.eq('user','name'))
if item then
username=isp.read_post_var('user',provider,subprovider)
if username then
username=(item.prefix or"")..username..(item.postfix or"")
end
end
i,item=array.find(af,func.eq('pwd','name'))
if item then
password=isp.read_post_var('pwd',provider,subprovider)
end
return username,password
end
function authform.initial_subprovider()
local provider=isp.initial_provider()
local username=box.query("connection0:settings/username")
local password=box.query("connection0:settings/password")
return get_initial_subprovider(provider,username,password)
end
local errmsg=general.lazytable({},TXT,{
pwdreenter={[[{?8598:277?}]]},
empty={[[{?8598:127?}]]},
outofrange={[[{?8598:0?}]]}
})
local function get_label(af,inputname)
local i,item=array.find(af,func.eq(inputname,'name'))
return item and item.label
end
function authform.get_label_txt(inputname,provider,subprovider)
local af=get_data(provider,subprovider)
return get_label(af,inputname)
end
function authform.get_first_inputname(provider,subprovider)
local af=get_data(provider)
if af.subproviders then
if not subprovider or not af[subprovider]then
for i,subp in ipairs(af.subproviders)do
if af[subp]then
subprovider=subp
break
end
end
end
af=get_data(provider,subprovider)
end
local name=af and af[1].name
if name then
return isp.html_name(name,provider,subprovider)
end
return""
end
local function create_val_param_func(provider,subprovider)
return function(name)
return isp.html_name(name,provider,subprovider)
end
end
local function validation_default(provider)
local af=data[provider]
local str=provider.."_username"
local val_param=create_val_param_func(provider)
newval.msg[str]={
[newval.ret.empty]=general.sprintf(errmsg.empty,get_label(af,'user'))
}
newval.msg.pwdreenter={
[newval.ret.notdifferent]=errmsg.pwdreenter
}
newval.not_empty(val_param('user'),str)
if provider==isp.activeprovider()then
local initial=get_initial_values(provider)
if not newval.value_equal(val_param('user'),initial.user)then
newval.pwd_changed(val_param('pwd'),"pwdreenter")
end
end
end
local function validation_other(provider)
local af=data.other.auth
local str=provider.."_username"
local val_param=create_val_param_func(provider,'auth')
newval.msg[str]={
[newval.ret.empty]=general.sprintf(errmsg.empty,get_label(af,'user'))
}
newval.msg.pwdreenter={
[newval.ret.notdifferent]=errmsg.pwdreenter
}
local medium_elem=isp.html_name('medium',provider)
local optype_elem=isp.html_name('optype',provider)
local do_validate=newval.radio_check(medium_elem,"dsl")
if not do_validate then
do_validate=newval.radio_check(medium_elem,"extern")
and newval.radio_check(medium_optype,"router")
end
if do_validate then
do_validate=newval.radio_check(val_param('subprovider'),"auth")
end
if do_validate then
newval.not_empty(val_param('user'),str)
if provider==isp.initial_provider()then
local initial=get_initial_values(provider)
if initial.subprovider=='auth'then
if not newval.value_equal(val_param('user'),initial.user)then
newval.pwd_changed(val_param('pwd'),"pwdreenter")
end
end
end
end
end
local pin15_errmsg=TXT([[{?8598:734?}]])
local function validation_telefonica(provider)
newval.msg.tpin={
[newval.ret.tooshort]=pin15_errmsg,
[newval.ret.toolong]=pin15_errmsg
}
local val_param=create_val_param_func(provider)
if not newval.value_equal(val_param('pin'),"****")then
newval.length(val_param('pin'),15,15,"tpin")
end
end
local function validation_o2(provider)
local af=data.o2.withpin
newval.msg.o2pin={
[newval.ret.tooshort]=pin15_errmsg,
[newval.ret.toolong]=pin15_errmsg
}
local val_param=create_val_param_func(provider,'withpin')
if newval.radio_check(val_param('subprovider'),"withpin")then
if not newval.value_equal(val_param('pin'),"****")then
newval.length(val_param('pin'),15,15,"o2pin")
end
end
end
local function validation_tonline()
local af=data.tonline.home
newval.msg.anschlusskennung={
[newval.ret.empty]=general.sprintf(errmsg.empty,get_label(af,'anschlusskennung')),
[newval.ret.outofrange]=general.sprintf(errmsg.outofrange,get_label(af,'anschlusskennung'))
}
newval.msg.tonlinenummer={
[newval.ret.empty]=general.sprintf(errmsg.empty,get_label(af,'tonlinenummer')),
[newval.ret.outofrange]=general.sprintf(errmsg.outofrange,get_label(af,'tonlinenummer'))
}
newval.msg.mitbenutzersuffix={
[newval.ret.empty]=general.sprintf(errmsg.empty,get_label(af,'mitbenutzersuffix')),
[newval.ret.outofrange]=general.sprintf(errmsg.outofrange,get_label(af,'mitbenutzersuffix'))
}
af=data.tonline.business
local str="tonline_username"
newval.msg[str]={
[newval.ret.empty]=general.sprintf(errmsg.empty,get_label(af,'user'))
}
newval.msg.pwdreenter={
[newval.ret.notdifferent]=errmsg.pwdreenter
}
local val_param=create_val_param_func('tonline')
local val_param_home=create_val_param_func('tonline','home')
local val_param_business=create_val_param_func('tonline','business')
local param={
anschlusskennung=val_param_home('anschlusskennung'),
tonlinenummer=val_param_home('tonlinenummer'),
mitbenutzersuffix=val_param_home('mitbenutzersuffix'),
pwd_home=val_param_home('pwd'),
subprovider=val_param('subprovider'),
pwd=val_param_business('pwd'),
user=val_param_business('user'),
}
local initial=get_initial_values('tonline')
if newval.radio_check(param.subprovider,"home")then
newval.not_empty(param.anschlusskennung,"anschlusskennung")
newval.char_range_regex(param.anschlusskennung,"decimals","anschlusskennung")
newval.not_empty(param.tonlinenummer,"tonlinenummer")
newval.char_range_regex(param.tonlinenummer,"decimals","tonlinenummer")
newval.not_empty(param.mitbenutzersuffix,"mitbenutzersuffix")
newval.char_range_regex(param.mitbenutzersuffix,"decimals","mitbenutzersuffix")
if isp.activeprovider()=='tonline'then
if initial.subprovider=='home'then
if not newval.value_equal(param.anschlusskennung,initial.anschlusskennung)
or not newval.value_equal(param.tonlinenummer,initial.tonlinenummer)
or not newval.value_equal(param.mitbenutzersuffix,initial.mitbenutzersuffix)then
newval.pwd_changed(param.pwd_home,"pwdreenter")
end
else
newval.pwd_changed(param.pwd_home,"pwdreenter")
end
end
end
if newval.radio_check(param.subprovider,"business")then
newval.not_empty(param.user,str)
if isp.activeprovider()=='tonline'then
if initial.subprovider=='business'then
if not newval.value_equal(param.user,initial.user)then
newval.pwd_changed(param.pwd,"pwdreenter")
end
else
newval.pwd_changed(param.pwd,"pwdreenter")
end
end
end
end
function authform.validation(provider)
if isp.is("telefonica",provider)then
validation_telefonica(provider)
elseif isp.is("o2",provider)then
validation_o2(provider)
elseif provider=='tonline'then
validation_tonline()
elseif isp.is_other(provider)then
validation_other(provider)
elseif isp.auth_needed(provider)then
validation_default(provider)
end
end
