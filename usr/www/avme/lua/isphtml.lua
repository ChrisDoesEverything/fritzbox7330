--[[Access denied<?lua
    box.end_page()
?>?>]]
-- de-first -begin  
require"isp"
require"authform"
require"general"
require"cmtable"
require"newval"
require"textdb"
isphtml={}
local table_insert,table_concat=table.insert,table.concat
local txt={}
local template={}
local function fill_template(template_str,params)
template_str=template_str or""
params=params or{}
return(template_str:gsub("%$([a-zA-Z%d_]+)%$",function(m)return params[m]or""end))
end
local medium_values={"dsl","cable","extern"}
txt.medium={
heading=[[{?158:520?}]],
explain=[[{?158:34?}]],
dsl=[[{?158:69?}]],
dsl_explain=[[{?158:194?}]],
cable=[[{?158:350?}]],
cable_explain=[[{?158:49?}]],
extern=[[{?158:118?}]],
extern_explain=[[{?158:770?}]]
}
function isphtml.get_medium(provider,options)
options=options or{}
local name=isp.html_name("medium",provider)
local div=html.div{class="showif_"..provider}
if not options.noheading then
div.add(
html.hr{},
html.h4{TXT(txt.medium.heading)}
)
end
div.add(html.p{TXT(txt.medium.explain)})
local subdiv=html.div{class="formular"}
local initial=isp.initial_medium(provider)
if options["exclude_"..initial]then
initial=isp.medium_defaults(provider)
end
local id,inp
for i,value in ipairs(medium_values)do
if not options["exclude_"..value]then
id=isp.html_id(name,value)
inp=html.input{type="radio",name=name,value=value,id=id}
inp.checked=initial==value
subdiv.add(
inp,
html.label{['for']=id,TXT(txt.medium[value])},
html.p{class="form_checkbox_explain",TXT(txt.medium[value.."_explain"])}
)
end
end
div.add(subdiv)
return div
end
local optype_values={'router','client'}
txt.optype={
heading=[[{?158:310?}]],
explain=[[{?158:552?}]],
router=[[{?158:892?}]],
client=[[{?158:267?}]],
explain_router=[[{?158:196?}]],
explain_client=[[{?158:744?}]]
}
function isphtml.get_optype(provider)
local initial=isp.initial_optype(provider)
local name=isp.html_name("optype",provider)
local div=html.div{
class="hideif_dsl hideif_cable showif_"..provider,
html.hr(),
html.h4{TXT(txt.optype.heading)},
html.p{TXT(txt.optype.explain)}
}
local subdiv=html.div{class="formular"}
local id,inp
for i,value in ipairs(optype_values)do
id=isp.html_id(name,value)
inp=html.input{type="radio",name=name,value=value,id=id}
inp.checked=initial==value
subdiv.add(html.div{
inp,
html.label{['for']=id,TXT(txt.optype[value])},
html.p{class="form_checkbox_explain",TXT(txt.optype["explain_"..value])}
})
end
div.add(subdiv)
return div
end
txt.auth=general.lazytable({},TXT,{
heading={[[{?158:38?}]]}
})
function isphtml.get_auth(provider,options)
options=options or{}
provider=provider or isp.initial_provider()
if options.force_display or isp.is_other(provider)or isp.auth_needed(provider)then
local div=html.div{
id="uiAuth:"..provider,class="hideif_cable hideif_client showif_"..provider
}
if not options.noheading then
div.add(
html.hr{},
html.h4{txt.auth.heading}
)
end
div.add(authform.get_html(provider,options))
return div
end
end
local provider_radio_explain_txt={
qsc={
[[{?158:963?}]],
[[{?158:763?}]]
},
qsc_dsl={
[[{?158:260?}]],
[[{?158:877?}]]
},
qsc_adsl={
[[{?158:469?}]],
[[{?158:880?}]]
}
}
function isphtml.get_provider_radio_explain(provider)
local txts=provider_radio_explain_txt[provider]
if txts then
local p=html.p{class="form_checkbox_explain"}
p.add(TXT(txts[1]))
for i=2,#txts do
p.add(html.br(),TXT(txts[i]))
end
return p
end
end
function isphtml.get_provider_explain(provider)
local container
if isp.is_oma(provider)then
container=html.fragment(
html.p{TXT([[{?158:312?}]])},
html.strong{TXT([[{?158:4042?}]])}
)
local ul=html.ul{class="hintlist"}
if provider=='oma_lan'then
ul.add(
html.li{TXT([[{?158:781?}]])}
)
end
ul.add(
html.li{TXT([[{?158:981?}]])}
)
if general.boxip_isdefault()then
ul.add(
html.li{TXT([[{?158:117?}]])}
)
end
container.add(ul)
elseif isp.is_cable(provider)then
container=html.fragment(
html.p{TXT([[{?158:761?}]])},
html.strong{TXT([[{?txtHinweis?}]])},
html.p{TXT([[{?158:4677?}]])}
)
end
return container
end
txt.prevention=[[{?158:193?}]]
local function buildtemplate_prevention()
local provider=[[$provider$]]
local selected=[[$selected%d$]]
local checked=[[$checked$]]
local div=html.div()
if not general.is_expert()then
div.style="display:none;"
else
div.class="formular enableif_"..isp.html_name("connmode",provider).."::lcp"
end
local name=isp.html_name("useprevention",provider)
local id=isp.html_id(name)
local checkbox=html.input{type="checkbox",name=name,id=id}
checkbox[checked]=true
name=isp.html_name("prevention",provider)
id=isp.html_id(name)
local sel=html.select{name=name,class="numbers inner enableif_"..checkbox.name}
local option
for i=0,23 do
option=html.option{value=tostring(i),i.." - "..(i+1)}
option[selected:format(i)]=true
sel.add(option)
end
local html_str=checkbox.get()
..[[ &nbsp;<label for="]]..checkbox.id..[[">]]
..general.sprintf(box.tohtml(TXT(txt.prevention)),[[</label>]]..sel.get(true))
div.add(html.raw(html_str))
return div.get()
end
template=general.lazytable(template,buildtemplate_prevention,{prevention={}})
local function getparams_prevention(provider)
if isp.prevention_needed(provider)then
local initial=isp.initial_prevention(provider)
local p={}
if initial.Enabled=="1"then
p.checked="checked"
end
p["selected"..initial.Hour]="selected"
return p
end
end
local function filltemplate_prevention(provider)
local params=getparams_prevention(provider)
if params then
params.provider=provider
return fill_template(template.prevention,params)
end
return""
end
txt.idle=[[{?158:176?}]]
local function buildtemplate_idle()
local provider=[[$provider$]]
local value=[[$value$]]
local div=html.div{
class="formular enableif_"..isp.html_name("connmode",provider).."::on_demand"
}
local name=isp.html_name("idle",provider)
local id=isp.html_id(name)
local inp=html.input{
type="text",name=name,id=id,size="3",maxlength="3",class="numbers inner",
value=value
}
div.add(html.raw(general.sprintf(box.tohtml(TXT(txt.idle)),inp.get(true))))
return div.get()
end
template=general.lazytable(template,buildtemplate_idle,{idle={}})
local function getparams_idle(provider)
local initial=isp.initial_connmode(provider)
return{
value=initial.idle or""
}
end
local function filltemplate_idle(provider)
local params=getparams_idle(provider)
if params then
params.provider=provider
return fill_template(template.idle,params)
end
return""
end
local connmode_values={"lcp","on_demand"}
txt.connmode={
heading=[[{?158:5?}]],
lcp=[[{?158:32?}]],
on_demand=[[{?158:204?}]]
}
local function buildtemplate_connmode()
local provider=[[$provider$]]
local checked=[[$checked%s$]]
local name=isp.html_name("connmode",provider)
local div=html.div{
class="hideif_cable hideif_client hideif_noauth showif_"..provider,
html.h5{TXT(txt.connmode.heading)}
}
local subform={
lcp=html.raw([[$TEMPLATE_PREVENTION$]]),
on_demand=html.raw([[$TEMPLATE_IDLE$]])
}
local id
for i,value in ipairs(connmode_values)do
id=isp.html_id(name,value)
local subdiv=html.div{class="formular"}
subdiv.add(
html.input{
type="radio",name=name,value=value,id=id,
[checked:format(value)]=true
},
html.label{['for']=id,TXT(txt.connmode[value])}
)
subdiv.add(subform[value])
div.add(subdiv)
end
return div.get()
end
template=general.lazytable(template,buildtemplate_connmode,{connmode={}})
local function getparams_connmode(provider)
if isp.is_other(provider)or isp.connmode_needed(provider)then
local initial=isp.initial_connmode(provider)
return{
["checked"..(initial.mode or"")]="checked"
}
end
end
local function filltemplate_connmode(provider)
local params=getparams_connmode(provider)
if params then
local tmp=template.connmode or""
tmp=tmp:gsub([[%$TEMPLATE_IDLE%$]],filltemplate_idle(provider))
tmp=tmp:gsub([[%$TEMPLATE_PREVENTION%$]],filltemplate_prevention(provider))
params.provider=provider
return fill_template(tmp,params)
end
return""
end
function isphtml.get_connmode(provider)
return html.raw(filltemplate_connmode(provider))
end
txt.speed=general.lazytable({},TXT,{
heading={[[{?158:161?}]]},
explain={[[{?158:315?}]]},
upstream={[[{?158:993?}]]},
downstream={[[{?158:236?}]]},
kbitsec={[[{?158:458?}]]}
})
local function buildtemplate_speed_dslspecial()
local provider=[[$provider$]]
local upstream=[[$upstream$]]
local downstream=[[$downstream$]]
local div=html.div()
div.class="formular showif_"..provider
local us_name=isp.html_name("upstream",provider)
local ds_name=isp.html_name("downstream",provider)
local us_id=isp.html_id(us_name)
local ds_id=isp.html_id(ds_name)
local us_inp=html.input{
type="text",name=us_name,id=us_id,maxlength="6",class="numbers",
value=upstream
}
local ds_inp=html.input{
type="text",name=ds_name,id=ds_id,maxlength="6",class="numbers",
value=downstream
}
div.add(html.h5{txt.speed.heading})
div.add(
html.p{txt.speed.explain},
html.div{class="formular",
html.label{['for']=us_id,txt.speed.upstream},
us_inp,
html.span{class="postfix",txt.speed.kbitsec}
},
html.div{class="formular",
html.label{['for']=ds_id,txt.speed.downstream},
ds_inp,
html.span{class="postfix",txt.speed.kbitsec}
}
)
return div.get()
end
template=general.lazytable(template,buildtemplate_speed_dslspecial,{speed_dslspecial={}})
local function buildtemplate_speed()
local provider=[[$provider$]]
local upstream=[[$upstream$]]
local downstream=[[$downstream$]]
local noheading_style=[[$noheading_style$]]
local div=html.div()
div.class="formular hideif_dsl showif_"..provider
local us_name=isp.html_name("upstream",provider)
local ds_name=isp.html_name("downstream",provider)
local us_id=isp.html_id(us_name)
local ds_id=isp.html_id(ds_name)
local us_inp=html.input{
type="text",name=us_name,id=us_id,maxlength="6",class="numbers",
value=upstream
}
local ds_inp=html.input{
type="text",name=ds_name,id=ds_id,maxlength="6",class="numbers",
value=downstream
}
div.add(html.h5{style=noheading_style,txt.speed.heading})
div.add(
html.p{txt.speed.explain},
html.div{class="formular",
html.label{['for']=us_id,txt.speed.upstream},
us_inp,
html.span{class="postfix",txt.speed.kbitsec}
},
html.div{class="formular",
html.label{['for']=ds_id,txt.speed.downstream},
ds_inp,
html.span{class="postfix",txt.speed.kbitsec}
}
)
return div.get()
end
template=general.lazytable(template,buildtemplate_speed,{speed={}})
local function getparams_speed_dslspecial(provider)
if isp.is_dsl(provider)then
local initial=isp.initial_speed(provider)
return{
upstream=initial.DSLSpeedUpstream,
downstream=initial.DSLSpeedDownstream
}
end
end
function isphtml.getparams_speed(provider)
if isp.is_other(provider)or isp.speed_needed(provider)then
local initial=isp.initial_speed(provider)
local params={}
params.upstream=initial.DSLSpeedUpstream
params.downstream=initial.DSLSpeedDownstream
return params
end
end
local function filltemplate_speed_dslspecial(provider,options)
options=options or{}
local params=getparams_speed_dslspecial(provider)
if params then
params.provider=provider
return fill_template(template.speed_dslspecial,params)
end
return""
end
local function filltemplate_speed(provider,options)
options=options or{}
if isp.is_other(provider)or isp.speed_needed(provider)then
local params=isphtml.getparams_speed(provider)
if params then
params.provider=provider
if options.noheading then
params.noheading_style=[[display:none;]]
end
return fill_template(template.speed,params)
end
end
return""
end
function isphtml.gettemplate_speed()
return{str=template.speed}
end
function isphtml.get_speed(provider,options)
return html.raw(filltemplate_speed(provider,options))
end
txt.dsl_medium={
heading=[[{?158:657?}]],
dsl_label=[[{?158:615?}]],
dsl_explain=[[{?158:522?}]],
extern_label=[[{?158:215?}]],
extern_explain=[[{?158:66?}]]
}
local function buildtemplate_dsl_medium_speed()
local provider=[[$provider$]]
local checked=[[$checked%s$]]
local name=isp.html_name("medium",provider)
local ids={
dsl=isp.html_id(name,'dsl'),
extern=isp.html_id(name,'extern')
}
local style=not general.is_expert()and"display:none;"or nil
return html.div{id=isp.html_id(name),class="showif_"..provider,style=style,
html.h5{TXT(txt.dsl_medium.heading)},
html.div{class="formular",
html.input{
type="radio",name=name,value="dsl",id=ids.dsl,
[checked:format('dsl')]=true
},
html.label{['for']=ids.dsl,TXT(txt.dsl_medium.dsl_label)},
html.p{class="form_checkbox_explain",TXT(txt.dsl_medium.dsl_explain)},
html.input{
type="radio",name=name,value="extern",id=ids.extern,
[checked:format('extern')]=true
},
html.label{['for']=ids.extern,TXT(txt.dsl_medium.extern_label)},
html.p{class="form_checkbox_explain",TXT(txt.dsl_medium.extern_explain)},
html.div{class="enableif_"..name.."::extern",[[$TEMPLATE_SPEED_DSLSPECIAL$]]}
}
}.get()
end
template=general.lazytable(template,buildtemplate_dsl_medium_speed,{dsl_medium_speed={}})
local function getparams_dsl_medium_speed(provider)
if isp.is_dsl(provider)then
local initial=isp.initial_medium(provider)
return{
["checked"..(initial or"")]="checked"
}
end
end
local function filltemplate_dsl_medium_speed(provider)
local params=getparams_dsl_medium_speed(provider)
if params then
local tmp=template.dsl_medium_speed or""
tmp=tmp:gsub([[%$TEMPLATE_SPEED_DSLSPECIAL%$]],filltemplate_speed_dslspecial(provider,{dslspecial=true}))
params.provider=provider
return fill_template(tmp,params)
end
return""
end
function isphtml.get_dsl_medium_speed(provider)
return html.raw(filltemplate_dsl_medium_speed(provider))
end
txt.vlan={
heading=[[{?158:31?}]],
explain=[[{?158:992?}]],
use=[[{?158:339?}]],
vlanid=[[{?158:33?}]]
}
local function buildtemplate_vlan()
local provider=[[$provider$]]
local checked=[[$checked$]]
local value=[[$value$]]
local name=isp.html_name("usevlan",provider)
local div=html.div{class="hideif_cable hideif_client showif_"..provider,
html.h5{TXT(txt.vlan.heading)},html.p{TXT(txt.vlan.explain)}
}
local subdiv=html.div{class="formular"}
local id=isp.html_id(name)
subdiv.add(html.input{type="hidden",name="exists_"..name})
subdiv.add(html.input{
type="checkbox",name=name,id=id,[checked]=true
})
subdiv.add(html.label{['for']=id,TXT(txt.vlan.use)})
local subdiv2=html.div{class="formular enableif_"..name}
name=isp.html_name("vlanid",provider)
id=isp.html_id(name)
subdiv2.add(html.label{['for']=id,TXT(txt.vlan.vlanid)})
local inp=html.input{
type="text",name=name,id=id,maxlength="4",class="numbers",value=value
}
subdiv2.add(inp)
subdiv.add(subdiv2)
div.add(subdiv)
return div.get()
end
template=general.lazytable(template,buildtemplate_vlan,{vlan={}})
local function getparams_vlan(provider)
if isp.is_other(provider)or isp.vlan_needed(provider)then
local initial=isp.initial_vlan(provider)
local p={}
if initial.vlanencap~="vlanencap_none"then
p.checked="checked"
end
p.value=initial.vlanid or""
return p
end
end
local function filltemplate_vlan(provider)
local params=getparams_vlan(provider)
if params then
params.provider=provider
return fill_template(template.vlan or"",params)
end
return""
end
function isphtml.get_vlan(provider)
return html.raw(filltemplate_vlan(provider))
end
txt.atm=general.lazytable({},TXT,{
dslencap_pppoe={[[{?158:791?}]]},
dslencap_pppoa_llc={[[{?158:926?}]]},
dslencap_pppoa={[[{?158:972?}]]},
dslencap_ether={[[{?158:463?}]]},
dslencap_ipnlpid={[[{?158:540?}]]},
dslencap_ipsnap={[[{?158:19?}]]},
dslencap_ipraw={[[{?158:826?}]]}
})
function isphtml.get_encaps_txt(opmode_value)
if opmode_value then
if opmode_value=='opmode_standard'then
return txt.atm.dslencap_pppoe
end
return txt.atm[opmode_value:gsub("opmode_","dslencap_")]
end
end
local function gethtml_atm_encap(provider,initial,noauthdsl)
if noauthdsl then
local name=isp.html_name("noauthdsl_encap",provider)
local values={"dslencap_ether","dslencap_ipnlpid","dslencap_ipsnap","dslencap_ipraw"}
local initial_encaps=initial.encapsulation
if not array.find(values,func.eq(initial.encapsulation))then
initial_encaps="dslencap_ether"
end
local div=html.div{
class="formular",
id="uiBlock_noauthdslencap:"..provider
}
local id
for i,value in ipairs(values)do
id=isp.html_id(name,value)
div.add(html.input{
type="radio",name=name,value=value,id=id,
checked=initial_encaps==value
})
div.add(html.label{['for']=id,txt.atm[value]})
if value=="dslencap_ether"then
local subdiv=html.div{class="formular enableif_"..name.."::"..value}
local d_name=isp.html_name("noauthdsl_dhcp",provider)
local d_id=isp.html_id(d_name)
subdiv.add(html.input{
type="checkbox",name=d_name,id=d_id,
checked=initial["noauthdsl_dhcp"]=="1"
})
subdiv.add(html.label{['for']=d_id,txt.ipsetting.auto})
local h_name=isp.html_name("noauthdsl_hostname",provider)
local h_id=isp.html_id(h_name)
local div_id=isp.html_id("block_"..h_name)
subdiv.add(
html.div{id=div_id,
html.label{['for']=h_id,txt.ipsetting.hostname},
html.input{
type="text",name=h_name,id=h_id,size="32",maxlength="63",
value=initial["noauthdsl_hostname"]or""
}
}
)
div.add(subdiv)
end
div.add(html.br())
end
return div
else
local name=isp.html_name("encap",provider)
local values={"dslencap_pppoe","dslencap_pppoa_llc","dslencap_pppoa"}
local initial_encaps=initial.encapsulation
if not array.find(values,func.eq(initial.encapsulation))then
initial_encaps="dslencap_pppoe"
end
local div=html.div{class="formular"}
local id
for i,value in ipairs(values)do
id=isp.html_id(name,value)
div.add(html.input{
type="radio",name=name,value=value,id=id,
checked=initial_encaps==value
})
div.add(html.label{['for']=id,txt.atm[value]})
div.add(html.br())
end
return div
end
end
txt.atm=general.lazytable(txt.atm,TXT,{
vpi={[[{?158:853?}]]},
vci={[[{?158:84?}]]},
encap={[[{?158:492?}]]}
})
local function gethtml_atm_vpivci(provider,add_class,initial)
local noauthdsl=add_class==""
local div=html.div{class="formular "..add_class}
local name=isp.html_name("vpi",provider)
if noauthdsl then
name=isp.html_name("noauthdsl_vpi",provider)
end
local id=isp.html_id(name)
div.add(html.label{['for']=id,txt.atm.vpi})
local inp=html.input{
type="text",name=name,id=id,maxlength="3",class="numbers",
value=initial.VPI or""
}
div.add(inp)
div.add(html.br())
name=isp.html_name("vci",provider)
if noauthdsl then
name=isp.html_name("noauthdsl_vci",provider)
end
id=isp.html_id(name)
div.add(html.label{['for']=id,txt.atm.vci})
inp=html.input{
type="text",name=name,id=id,maxlength="5",class="numbers",
value=initial.VCI or""
}
div.add(inp)
div.add(html.br())
div.add(html.p{txt.atm.encap})
if noauthdsl then
initial=table.extend(initial,isp.initial_ipsetting(provider,'noauthdsl'))
end
div.add(gethtml_atm_encap(provider,initial,noauthdsl))
if noauthdsl then
div.add(isphtml.get_ipsetting(provider,'noauthdsl'))
end
return div
end
txt.atm=general.lazytable(txt.atm,TXT,{
heading={[[{?158:239?}]]},
["1"]={[[{?158:505?}]]},
["0"]={[[{?158:842?}]]}
})
function isphtml.get_atm(provider)
local initial=isp.initial_atm(provider)
local container=html.fragment()
local div=html.div{
class="hideif_cable hideif_extern hideif_noauth showif_"..provider,
html.h5{txt.atm.heading}
}
local name=isp.html_name("autodetect",provider)
local subdiv=html.div{class="formular"}
local value="1"
local id=isp.html_id(name,value)
subdiv.add(html.input{
type="radio",name=name,value=value,id=id,
checked=initial.autodetect==value
})
subdiv.add(html.label{['for']=id,txt.atm[value]})
subdiv.add(html.br())
value="0"
id=isp.html_id(name,value)
subdiv.add(html.input{
type="radio",name=name,value=value,id=id,
checked=initial.autodetect==value
})
subdiv.add(html.label{['for']=id,txt.atm[value]})
subdiv.add(
gethtml_atm_vpivci(provider,"enableif_"..name.."::0",initial)
)
div.add(subdiv)
container.add(div)
container.add(
html.div{
class="hideif_cable hideif_extern hideif_auth showif_"..provider,
html.h5{txt.atm.heading},
html.div{gethtml_atm_vpivci(provider,"",initial)}
}
)
return container
end
local ip_names={"ipaddr","netmask","gateway","dns1","dns2"}
txt.ipsetting=general.lazytable({},TXT,{
ipaddr={[[{?158:709?}]]},
netmask={[[{?158:52?}]]},
gateway={[[{?158:244?}]]},
dns1={[[{?158:480?}]]},
dns2={[[{?158:362?}]]}
})
local ip_template=[[
  <div id="$id$" class="group">
    <label for="$id$0">$label$</label>
    <input type="text" name="$name$0" autocomplete="off" id="$id$0" value="$value1$" maxlength="3" size="3"> .
    <input type="text" name="$name$1" autocomplete="off" id="$id$1" value="$value2$" maxlength="3" size="3"> .
    <input type="text" name="$name$2" autocomplete="off" id="$id$2" value="$value3$" maxlength="3" size="3"> .
    <input type="text" name="$name$3" autocomplete="off" id="$id$3" value="$value4$" maxlength="3" size="3">
  </div>
]]
local function gethtml_ip_group(provider,which,initial)
local names=array.map(ip_names,function(n)return which.."_"..n end)
local name,id
local result={}
local params={}
for i,iname in ipairs(names)do
params={}
params.label=txt.ipsetting[ip_names[i]]
params.name=isp.html_name(iname,provider)
params.id=isp.html_id(params.name)
initial_value=(initial[names[i]]or"..."):split(".")
for i=1,4 do
params["value"..i]=initial_value[i]or""
end
table_insert(result,fill_template(ip_template,params))
end
return html.raw(table_concat(result,"\n"))
end
txt.ipsetting=general.lazytable(txt.ipsetting,TXT,{
heading={[[{?158:796?}]]},
auto={[[{?158:724?}]]},
manually={[[{?158:187?}]]},
hostname={[[{?158:361?}]]}
})
function isphtml.get_ipsetting(provider,which)
which=which or'router'
local class="hideif_auth showif_"..provider
if which=='noauthdsl'then
class=class.." hideif_client"
elseif which=='router'then
class=class.." hideif_dsl hideif_client"
else
class=class.." hideif_dsl hideif_router"
end
local initial=isp.initial_ipsetting(provider,which)
local div=html.div{class=class}
if which=='noauthdsl'then
div.id=isp.html_id(isp.html_name("block_noauthdsl_ips",provider))
end
if which~='noauthdsl'then
div.add(html.h5{txt.ipsetting.heading})
end
local subdiv=html.div{class="formular"}
local base_name,name,value,id
if which~='noauthdsl'then
base_name=which.."_dhcp"
name=isp.html_name(base_name,provider)
value="1"
id=isp.html_id(name,value)
subdiv.add(html.input{
type="radio",name=name,value=value,id=id,
checked=initial[base_name]==value
})
subdiv.add(html.label{['for']=id,txt.ipsetting.auto})
local h_base_name=which.."_hostname"
local h_name=isp.html_name(h_base_name,provider)
local h_id=isp.html_id(h_name)
subdiv.add(
html.div{class="formular enableif_"..name.."::1",
html.label{['for']=h_id,txt.ipsetting.hostname},
html.input{
type="text",name=h_name,id=h_id,size="32",maxlength="63",value=initial[h_base_name]or""
}
}
)
div.add(subdiv)
subdiv=html.div{class="formular"}
value="0"
id=isp.html_id(name,value)
subdiv.add(html.input{
type="radio",name=name,value=value,id=id,
checked=initial[base_name]==value
})
subdiv.add(html.label{['for']=id,txt.ipsetting.manually})
end
local class="formular"
if which~='noauthdsl'then
class=class.." enableif_"..name.."::0"
end
subdiv.add(
html.div{class=class,gethtml_ip_group(provider,which,initial)}
)
div.add(subdiv)
return div
end
txt.mac=general.lazytable({},TXT,{
heading={[[{?158:283?}]]},
explain={[[{?158:728?}]]},
label={[[{?158:7960?}]]}
})
function isphtml.get_mac(provider)
if isp.mac_needed(provider)then
local initial=(isp.initial_mac(provider)or""):split(":")
local div=html.div{class="showif_"..provider.." hideif_dsl hideif_auth hideif_client"}
div.add(html.h5{txt.mac.heading})
div.add(html.p{txt.mac.explain})
local name=isp.html_name('mac',provider)
local id=isp.html_id(name)
local subdiv=html.div{class="formular",id=id}
subdiv.add(html.label{['for']=id.."0",txt.mac.label})
local name_i,id_i
for i=0,5 do
name_i=name..tostring(i)
id_i=id..tostring(i)
subdiv.add(html.input{
type="text",size="2",maxlength="2",id=id_i,name=name_i,autocomplete="off",
value=initial[i+1]or""
})
if i<5 then subdiv.add([[ :]])end
end
div.add(subdiv)
return div
end
end
local function buildtemplate_connection_ex()
local provider=[[$provider$]]
local div=html.div{class="formular showif_"..provider}
local onclick=[[onConnectionExClicked('%s');return false;]]
div.add(
html.a{class="textlink",href=" ",onclick=onclick:format(provider),
TXT([[{?158:298?}]]),
html.img{id="uiConnectionExLink:"..provider,src="/css/default/images/link_open.gif",height="12"}
},
html.div{id="uiConnectionEx:"..provider,style="display:none;",
html.raw([[$TEMPLATE_CONNMODE$]]),
html.raw([[$TEMPLATE_DSL_MEDIUM_SPEED$]]),
html.raw([[$TEMPLATE_VLAN$]])
}
)
return div.get()
end
template=general.lazytable(template,buildtemplate_connection_ex,{connection_ex={}})
function isphtml.getparams_connection_ex(provider)
if isp.is_dsl(provider)or isp.prevention_needed(provider)or isp.vlan_needed(provider)then
local p={}
p.TEMPLATE_CONNMODE=getparams_connmode(provider)
if p.TEMPLATE_CONNMODE then
local initial=isp.initial_connmode(provider)
p.TEMPLATE_CONNMODE.TEMPLATE_IDLE=getparams_idle(provider)
p.TEMPLATE_CONNMODE.TEMPLATE_PREVENTION=getparams_prevention(provider)
end
p.TEMPLATE_DSL_MEDIUM_SPEED=getparams_dsl_medium_speed(provider)
if p.TEMPLATE_DSL_MEDIUM_SPEED then
p.TEMPLATE_DSL_MEDIUM_SPEED.TEMPLATE_SPEED_DSLSPECIAL=getparams_speed_dslspecial(provider)
end
p.TEMPLATE_VLAN=getparams_vlan(provider)
return p
end
end
function isphtml.gettemplate_connection_ex()
local t={}
t.str=template.connection_ex
t.sub={
TEMPLATE_CONNMODE={
str=template.connmode,
sub={
TEMPLATE_PREVENTION={str=template.prevention},
TEMPLATE_IDLE={str=template.idle}
}
},
TEMPLATE_DSL_MEDIUM_SPEED={
str=template.dsl_medium_speed,
sub={
TEMPLATE_SPEED_DSLSPECIAL={str=template.speed_dslspecial}
}
},
TEMPLATE_VLAN={str=template.vlan}
}
return t
end
local function buildtemplate_connection_head()
local provider=[[$provider$]]
local div=html.div{id="uiConnectionHead:"..provider,class="showif_"..provider}
div.add(html.hr{})
div.add(html.h4{
TXT([[{?158:733?}]])
})
div.add(html.p{
TXT([[{?158:163?}]])
})
return div.get()
end
template=general.lazytable(template,buildtemplate_connection_head,{connection_head={}})
function isphtml.getparams_connection_head(provider)
if isp.is_other(provider)
or isp.is_dsl(provider)
or isp.prevention_needed(provider)
or isp.speed_needed(provider)
or isp.vlan_needed(provider)then
return{}
end
end
local function filltemplate_connection_head(provider)
local params=isphtml.getparams_connection_head(provider)
if params then
params.provider=provider
return fill_template(template.connection_head,params)
end
return""
end
function isphtml.gettemplate_connection_head()
return{str=template.connection_head}
end
function isphtml.get_connection_head(provider)
return html.raw(filltemplate_connection_head(provider))
end
function isphtml.get_wlanscan(provider,options)
if not isp.wlanscan_needed(provider)then return end
options=options or{}
local scan_div=html.div{class="showif_"..provider}
if not options.noheading then
scan_div.add(html.hr())
scan_div.add(html.h4{
TXT([[{?158:82?}]])
})
end
scan_div.add(html.p{
TXT([[{?158:373?}]])
})
scan_div.add(html.p{
TXT([[{?158:700?}]])
})
if not general.wlan_active()then
scan_div.add(html.strong{TXT([[{?txtHinweis?}]])})
local str=general.sprintf(
box.tohtml(TXT(
[[{?158:706?}]]
)),
html.a{href=href.get("/wlan/wlan_settings.lua"),
TXT([[{?158:107?}]])
}.get('nonewline')
)
scan_div.add(html.p{html.raw(str)})
elseif not general.wlan_active('2,4')then
scan_div.add(html.strong{TXT([[{?txtHinweis?}]])})
local str=general.sprintf(
box.tohtml(TXT(
[[{?158:792?}]]
)),
html.a{href=href.get("/wlan/wlan_settings.lua"),
TXT([[{?158:149?}]])
}.get('nonewline')
)
scan_div.add(html.p{html.raw(str)})
else
require"wlanscan"
local id="uiWlanListDiv"
local subdiv=html.div{id=id}
local vars=options.vars or{}
local opts={
show_scan=options.show_scan or not vars.stamac,
stamac=vars.stamac
}
subdiv.add(html.div{id="uiWlanCurList",html.raw(wlanscan.gethtml(opts))})
subdiv.add(
html.div{class="rightBtn",
html.p{
html.button{
type="button",id="uiIdRenewList",name="refresh_list",
onclick="OnDoRefresh('"..box.tojs(tostring(box.glob.sid)).."');",
TXT([[{?158:282?}]])
}
}
}
)
subdiv.add(
html.div{id="uiInfo",
html.strong{TXT([[{?txtHinweis?}]])},
html.p{
TXT([[{?158:434?}]])
}
}
)
scan_div.add(subdiv)
end
return scan_div
end
function isphtml.get_wlansecurity(provider,options)
if not isp.wlanscan_needed(provider)then return end
if not general.wlan_active()then return end
if not general.wlan_active('2.4')then return end
options=options or{}
local wpa_div,ssid_div
local initial=isp.initial_wlanscan(provider)
wpa_div=html.div{class="showif_"..provider}
if not options.noheading then
wpa_div.add(html.hr())
wpa_div.add(html.h4{TXT([[{?158:865?}]])})
end
wpa_div.add(
html.p{TXT([[{?158:264?}]])}
)
local name=isp.html_name('pskvalue',provider)
local id=isp.html_id(name)
local subdiv=html.div{class="formular"}
subdiv.add(html.label{['for']=id,TXT([[{?158:669?}]])})
local vars=options.vars or{}
local pskvalue=vars.pskvalue or initial.pskvalue or""
subdiv.add(
html.input{
type="text",size="40",maxlength="63",name=name,id=id,
onkeyup="OnChangeInput(this.value,'uiDezKeyWpa')",value=pskvalue
}
)
subdiv.add(
html.div{class="form_input_note cnt_char",id="uiCountKeyWpa",
html.span{id="uiDezKeyWpa",tostring(#pskvalue)..[[ ]]},
TXT([[{?gNumOfChars?}]])
}
)
for i,n in ipairs({'stamac','stassid','staenc'})do
name=isp.html_name(n,provider)
id=isp.html_id(name)
subdiv.add(html.input{type="hidden",name=name,id=id,value=vars[n]or initial[n]or""})
end
wpa_div.add(subdiv)
ssid_div=html.div{class="showif_"..provider,id="uiSsid",style="display:none;"}
ssid_div.add(
html.p{TXT([[{?158:627?}]])}
)
local name=isp.html_name('hiddenssid',provider)
local id=isp.html_id(name)
local subdiv=html.div{class="formular"}
subdiv.add(html.label{["for"]=id,
TXT([[{?158:644?}]])
})
subdiv.add(html.input{
type="text",size="33",maxlength="32",id=id,name=name,value=initial.stassid or"",disabled=true
})
ssid_div.add(subdiv)
return html.fragment(wpa_div,ssid_div)
end
function isphtml.save_wlanscan(saveset,vars)
if vars.provider=='oma_wlan'then
cmtable.add_var(saveset,"wlan:settings/bridge_mode","bridge-ata")
local ssid_toset=vars.stassid or""
if#ssid_toset==0 then
ssid_toset=vars.hiddenssid
end
require("net_devices")
if ssid_toset~=net_devices.get_notfound()then
cmtable.add_var(saveset,"wlan:settings/STA_ssid",ssid_toset)
cmtable.add_var(saveset,"wlan:settings/STA_encryption",vars.staenc)
end
cmtable.add_var(saveset,"wlan:settings/STA_mac_master",vars.stamac)
cmtable.add_var(saveset,"wlan:settings/STA_pskvalue",vars.pskvalue)
elseif box.query("wlan:settings/bridge_mode")=="bridge-ata"then
cmtable.add_var(saveset,"wlan:settings/bridge_mode","bridge-none")
end
end
local function save_congstar_specials(saveset,vars,user,pwd)
if isp.is("congstar_vdsl",vars.provider)then
if not user:lower():match("^vdsl/")then
local voipuser=user:gsub("@congstar%.de$","@tel.congstar.de")
cmtable.add_var(saveset,"connection_voip:settings/username",voipuser)
cmtable.add_var(saveset,"connection_voip:settings/password",pwd)
end
elseif isp.is("congstar",vars.provider)then
if user:match("^ip/")or user:match("^dsl/")then
cmtable.add_var(saveset,"connection_voip:settings/use_seperate_vcc","0")
else
local voipuser=user:gsub("@congstar%.de$","@tel.congstar.de")
cmtable.add_var(saveset,"connection_voip:settings/username",voipuser)
cmtable.add_var(saveset,"connection_voip:settings/password",pwd)
cmtable.add_var(saveset,"connection_voip:settings/use_seperate_vcc","1")
cmtable.add_var(saveset,"connection_voip:settings/encapsulation","dslencap_pppoe")
cmtable.add_var(saveset,"connection_voip:settings/VPI","1")
cmtable.add_var(saveset,"connection_voip:settings/VCI","35")
end
end
end
function isphtml.save_auth(saveset,vars)
local user,pwd
if isp.is_other(vars.provider)and vars.medium=='cable'then
user,pwd="",""
else
user,pwd=authform.read_user_pass(vars.provider)
end
local def=isp.auth_defaults(vars.provider)
if not user and not pwd then
user=def.username
pwd=def.pwd
end
if vars.provider~=isp.initial_provider()and pwd=="****"then
local pre_pwd=def.pwd
if pre_pwd and#pre_pwd>0 then
pwd=pre_pwd
end
end
if(user and pwd)or not isp.dont_clear_auth(vars.provider)then
cmtable.add_var(saveset,"connection0:settings/username",user or"")
cmtable.add_var(saveset,"connection0:settings/password",pwd or"")
end
save_congstar_specials(saveset,vars,user or"",pwd or"")
end
function isphtml.save_connmode(saveset,vars)
if vars.connmode then
cmtable.add_var(saveset,"connection0:settings/mode",vars.connmode)
if vars.idle then
cmtable.add_var(saveset,"connection0:settings/idle",vars.idle)
end
if vars.useprevention then
cmtable.add_var(saveset,"connection0:settings/ProviderDisconnectPrevention/Enabled","1")
if vars.prevention then
cmtable.add_var(saveset,"connection0:settings/ProviderDisconnectPrevention/Hour",vars.prevention)
end
elseif isp.prevention_needed(vars.provider)then
cmtable.add_var(saveset,"connection0:settings/ProviderDisconnectPrevention/Enabled","0")
end
end
end
function isphtml.save_speed(saveset,vars)
if isp.is_other(vars.provider)or isp.speed_needed(vars.provider)or isp.is_dsl(vars.provider)then
if vars.medium~='dsl'then
if vars.upstream or vars.downstream then
cmtable.add_var(saveset,"box:settings/ManualDSLSpeed","1")
else
cmtable.add_var(saveset,"box:settings/ManualDSLSpeed","0")
end
if vars.upstream then
cmtable.add_var(saveset,"box:settings/DSLSpeedUpstream",vars.upstream)
end
if vars.downstream then
cmtable.add_var(saveset,"box:settings/DSLSpeedDownstream",vars.downstream)
end
else
cmtable.add_var(saveset,"box:settings/ManualDSLSpeed","0")
end
end
end
function isphtml.save_vlan(saveset,vars)
if isp.is_other(vars.provider)or isp.vlan_needed(vars.provider)then
if vars.medium~='cable'and vars.optype~='client'then
if vars.exists_usevlan then
if vars.usevlan and vars.vlanid then
cmtable.add_var(saveset,"connection0:settings/vlanencap","vlanencap_fixed_prio")
cmtable.add_var(saveset,"connection0:settings/vlanid",vars.vlanid)
else
cmtable.add_var(saveset,"connection0:settings/vlanencap","vlanencap_none")
end
end
end
end
end
function isphtml.save_atm(saveset,vars)
if vars.medium=='dsl'and vars.subprovider=='noauth'then
if vars.noauthdsl_vpi then
cmtable.add_var(saveset,"sar:settings/VPI",vars.noauthdsl_vpi)
end
if vars.noauthdsl_vci then
cmtable.add_var(saveset,"sar:settings/VCI",vars.noauthdsl_vci)
end
elseif vars.autodetect then
if vars.autodetect~="1"then
if vars.vpi then
cmtable.add_var(saveset,"sar:settings/VPI",vars.vpi)
end
if vars.vci then
cmtable.add_var(saveset,"sar:settings/VCI",vars.vci)
end
end
end
end
function isphtml.save_ipsetting(saveset,vars)
if vars.medium=='dsl'and vars.subprovider=='noauth'then
if vars.noauthdsl_encap=='dslencap_ether'and vars.noauthdsl_dhcp then
cmtable.add_var(saveset,"box:settings/dslencap_ether/use_dhcp","1")
cmtable.add_var(saveset,"box:settings/dhcpc_hostname",vars.noauthdsl_hostname or"")
else
cmtable.add_var(saveset,"box:settings/dslencap_ether/use_dhcp","0")
cmtable.add_var(saveset,"box:settings/dslencap_ether/ipaddr",vars.noauthdsl_ipaddr)
cmtable.add_var(saveset,"box:settings/dslencap_ether/netmask",vars.noauthdsl_netmask)
cmtable.add_var(saveset,"box:settings/dslencap_ether/gateway",vars.noauthdsl_gateway)
cmtable.add_var(saveset,"box:settings/dslencap_ether/dns1",vars.noauthdsl_dns1)
cmtable.add_var(saveset,"box:settings/dslencap_ether/dns2",vars.noauthdsl_dns2 or"")
end
elseif vars.optype=='router'or vars.medium=='cable'then
if vars.router_dhcp=="1"then
cmtable.add_var(saveset,"box:settings/dslencap_ether/use_dhcp","1")
cmtable.add_var(saveset,"box:settings/dhcpc_hostname",vars.router_hostname or"")
elseif vars.router_dhcp=="0"then
cmtable.add_var(saveset,"box:settings/dslencap_ether/use_dhcp","0")
cmtable.add_var(saveset,"box:settings/dslencap_ether/ipaddr",vars.router_ipaddr)
cmtable.add_var(saveset,"box:settings/dslencap_ether/netmask",vars.router_netmask)
cmtable.add_var(saveset,"box:settings/dslencap_ether/gateway",vars.router_gateway)
cmtable.add_var(saveset,"box:settings/dslencap_ether/dns1",vars.router_dns1)
cmtable.add_var(saveset,"box:settings/dslencap_ether/dns2",vars.router_dns2 or"")
end
elseif vars.optype=='client'then
if vars.client_dhcp=="1"then
cmtable.add_var(saveset,"interfaces:settings/lan0/dhcpclient","1")
cmtable.add_var(saveset,"box:settings/dhcpclient/use_static_dns","0")
cmtable.add_var(saveset,"box:settings/dhcpc_hostname",vars.client_hostname or"")
elseif vars.client_dhcp=="0"then
cmtable.add_var(saveset,"interfaces:settings/lan0/dhcpclient","0")
cmtable.add_var(saveset,"box:settings/dhcpclient/use_static_dns","1")
cmtable.add_var(saveset,"interfaces:settings/lan0/ipaddr",vars.client_ipaddr)
cmtable.add_var(saveset,"interfaces:settings/lan0/netmask",vars.client_netmask)
cmtable.add_var(saveset,"box:settings/gateway",vars.client_gateway)
cmtable.add_var(saveset,"box:settings/dns0",vars.client_dns1)
cmtable.add_var(saveset,"box:settings/dns1",vars.client_dns2 or"")
end
end
end
function isphtml.save_oma_ipsetting(saveset,vars)
if isp.is_oma(vars.provider)and general.boxip_isdefault()then
cmtable.add_var(saveset,"interfaces:settings/lan0/ipaddr","192.168.188.1")
cmtable.add_var(saveset,"interfaces:settings/lan0/netmask","255.255.255.0")
cmtable.add_var(saveset,"interfaces:settings/lan0/dhcpserver","1")
cmtable.add_var(saveset,"interfaces:settings/lan0/dhcpstart","192.168.188.20")
cmtable.add_var(saveset,"interfaces:settings/lan0/dhcpend","192.168.188.200")
end
end
function isphtml.save_mac(saveset,vars)
if vars.mac and#vars.mac>0 then
cmtable.add_var(saveset,"env:settings/macdsl",vars.mac)
end
end
function isphtml.save_provider(saveset,vars)
if isp.is_other(vars.provider)then
cmtable.add_var(saveset,"providerlist:settings/activeprovider",'other')
if'other_named'~=vars.provider then
cmtable.add_var(saveset,"providerlist:settings/activename",vars.activename)
end
else
local real_provider=isp.value(vars.provider)
cmtable.add_var(saveset,"providerlist:settings/activeprovider",real_provider)
cmtable.add_var(saveset,"providerlist:settings/activename","")
end
end
local function retrieve_opmode(vars)
local curr_opmode=box.query("box:settings/opmode")
local opmode
if isp.is_other(vars.provider)then
if vars.medium=='dsl'then
if vars.subprovider=='auth'then
if vars.autodetect=="1"then
opmode='opmode_standard'
elseif vars.encap then
opmode=vars.encap:gsub("dslencap_","opmode_")
end
elseif vars.subprovider=='noauth'and vars.noauthdsl_encap then
opmode=vars.noauthdsl_encap:gsub("dslencap_","opmode_")
end
elseif vars.medium=='cable'then
opmode='opmode_eth_ip'
else
if vars.optype=='router'then
if vars.subprovider=='auth'then
opmode='opmode_eth_pppoe'
else
opmode='opmode_eth_ip'
end
else
opmode='opmode_eth_ipclient'
end
end
opmode=opmode or isp.opmode(vars.provider)
elseif isp.is_dsl(vars.provider)then
if vars.medium=='extern'then
opmode='opmode_eth_pppoe'
elseif vars.medium=='dsl'then
if vars.provider~=isp.initial_provider()or curr_opmode=='opmode_eth_pppoe'or curr_opmode=='opmode_modem'then
opmode=isp.opmode(vars.provider)
end
end
end
if vars.provider~=isp.initial_provider()or curr_opmode=='opmode_modem'then
opmode=opmode or isp.opmode(vars.provider)
end
return opmode
end
function isphtml.save_opmode(saveset,vars)
local opmode=retrieve_opmode(vars)
if opmode then
cmtable.add_var(saveset,"box:settings/opmode",opmode)
end
return opmode or box.query("box:settings/opmode")
end
function isphtml.save_guiflag(saveset,vars)
local keys={'medium'}
local str={}
for i,k in ipairs(keys)do
if vars[k]then
table_insert(str,tostring(k).."="..tostring(vars[k]))
end
end
cmtable.add_var(saveset,"providerlist:settings/guiflag",table_concat(str,";"))
end
function isphtml.save_specials(saveset,vars)
if isp.is("o2",vars.provider)then
if vars.subprovider=='withoutpin'then
local voipuser=box.query("connection_voip:settings/username")
local domain
if isp.is("o2")then
domain=voipuser:match(".*(@.*)")
end
domain=domain or[[@voice.o2online.de]]
cmtable.add_var(saveset,"sar:settings/VPI","1")
cmtable.add_var(saveset,"sar:settings/VCI","32")
cmtable.add_var(saveset,"sar:settings/autodetect","0")
cmtable.add_var(saveset,"connection_voip:settings/use_seperate_vcc","1")
cmtable.add_var(saveset,"connection_voip:settings/VPI","1")
cmtable.add_var(saveset,"connection_voip:settings/VCI","35")
cmtable.add_var(saveset,"connection_voip:settings/username","o2"..domain)
cmtable.add_var(saveset,"connection_voip:settings/password","Freeway")
elseif vars.subprovider=='withpin'then
cmtable.add_var(saveset,"connection_voip:settings/use_seperate_vcc","0")
cmtable.add_var(saveset,"sar:settings/autodetect","1")
cmtable.add_var(saveset,"connection_voip:settings/username","")
cmtable.add_var(saveset,"connection_voip:settings/password","")
end
end
end
function isphtml.disable_guest(saveset,vars)
if config.WLAN_GUEST and box.query("wlan:settings/guest_ap_enabled")=="1"then
if vars.optype=='client'or isp.is('oma_wlan',vars.provider)then
cmtable.add_var(saveset,"wlan:settings/guest_ap_enabled","0")
cmtable.add_var(saveset,"wlan:settings/guest_pskvalue","")
cmtable.add_var(saveset,"wlan:settings/guest_encryption","4")
end
end
if config.GUI_LAN_GUEST then
if box.query("box:settings/ethernet_guest_enabled")=="1"then
local wan=isp.is_other(vars.provider)or isp.is_dsl(vars.provider)
wan=wan and vars.medium~='dsl'
if wan or isp.is_oma(vars.provider)then
cmtable.add_var(saveset,"box:settings/ethernet_guest_enabled","0")
end
end
end
end
function isphtml.disable_umtsfallback(saveset,vars)
if config.USB_GSM and umts.backup_enable=="1"then
if isp.is_oma(vars.provider)
or isp.is_cable(vars.provider)
or isp.over_lan1(vars.provider)
or isp.is_other(vars.provider)and vars.medium~='dsl'
or isp.is_dsl(vars.provider)and vars.medium~='dsl'then
cmtable.add_var(saveset,"umts:settings/backup_enable","0")
end
end
end
local function create_val_param_func(provider,subprovider)
return function(name)
return isp.html_name(name,provider,subprovider)
end
end
local valtxt={}
valtxt=general.lazytable(valtxt,TXT,{
noprovider={[[{?158:2?}]]}
})
function isphtml.noprovider_validation()
newval.msg.noprovider={
[newval.ret.wrong]=valtxt.noprovider
}
if newval.radio_check("provider","tochoose")then
newval.const_error("superprovider","wrong","noprovider")
end
if newval.radio_check("provider","tochoose2")then
newval.const_error("superprovider2","wrong","noprovider")
end
end
function isphtml.wlanscan_validation(provider)
if isp.is('oma_wlan',provider)then
if not general.wlan_active('2,4')then
newval.msg.no24wlan={
[newval.ret.wrong]=TXT[[{?158:428?}]]
}
newval.const_error("provider","wrong","no24wlan")
end
newval.msg.stamac={
[newval.ret.empty]=TXT[[{?158:837?}]]
}
local val_param=create_val_param_func(provider)
newval.not_empty(val_param('stamac'),"stamac")
end
end
function isphtml.wlansecurity_validation(provider)
if isp.is('oma_wlan',provider)then
newval.msg.wpa_key_error_txt={
[newval.ret.empty]=TXT[[{?158:359?}]],
[newval.ret.toolong]=TXT[[{?158:137?}]],
[newval.ret.tooshort]=TXT[[{?158:417?}]],
[newval.ret.outofrange]=TXT[[{?158:573?}]],
[newval.ret.leadchar]=TXT[[{?158:919?}]],
[newval.ret.endchar]=TXT[[{?158:4945?}]]
}
newval.msg.ssid_error_txt={
[newval.ret.empty]=TXT[[{?158:753?}]],
[newval.ret.leadchar]=TXT[[{?158:16?}]],
[newval.ret.endchar]=TXT[[{?158:341?}]]
}
local val_param=create_val_param_func(provider)
local params={
pskvalue=val_param('pskvalue'),
stassid=val_param('stassid'),
hiddenssid=val_param('hiddenssid')
}
newval.not_empty(params.pskvalue,"wpa_key_error_txt")
newval.length(params.pskvalue,8,63,"wpa_key_error_txt")
newval.char_range(params.pskvalue,32,126,"wpa_key_error_txt")
newval.no_lead_char(params.pskvalue,32,"wpa_key_error_txt")
newval.no_end_char(params.pskvalue,32,"wpa_key_error_txt")
if newval.value_empty(params.stassid)then
newval.not_empty(params.hiddenssid,"ssid_error_txt")
newval.no_lead_char(params.hiddenssid,32,"ssid_error_txt")
newval.no_end_char(params.hiddenssid,32,"ssid_error_txt")
end
end
end
valtxt=general.lazytable(valtxt,TXT,{
connmode={[[{?158:650?}]]}
})
function isphtml.connmode_validation(provider)
if isp.is_other(provider)or isp.is_dsl(provider)or isp.connmode_needed(provider)then
local val_param=create_val_param_func(provider)
newval.msg.idle={
[newval.ret.outofrange]=valtxt.connmode
}
local params={
connmode=val_param('connmode'),
idle=val_param('idle')
}
local do_validate=true
if isp.is_other(provider)or isp.is_dsl(provider)then
do_validate=newval.radio_check(val_param('medium'),"dsl")
end
if do_validate then
if newval.radio_check(params.connmode,"on_demand")then
newval.char_range_regex(params.idle,"anynonwhitespace","idle")
newval.char_range_regex(params.idle,"decimals","idle")
newval.num_range(params.idle,30,900,"idle")
end
end
end
end
valtxt=general.lazytable(valtxt,TXT,{
vlan={[[{?158:5962?}]]}
})
function isphtml.vlan_validation(provider)
if isp.is_other(provider)or isp.vlan_needed(provider)then
local vlan_err=valtxt.vlan
newval.msg.vlan={
[newval.ret.empty]=vlan_err,
[newval.ret.outofrange]=vlan_err,
[newval.ret.format]=vlan_err
}
local val_param=create_val_param_func(provider)
local params={
medium=val_param('medium'),
usevlan=val_param('usevlan'),
vlanid=val_param('vlanid')
}
if newval.radio_check(params.medium,"dsl")then
if newval.checked(params.usevlan)then
newval.num_range(params.vlanid,1,4096,"vlan")
end
end
end
end
valtxt=general.lazytable(valtxt,TXT,{
vpi={[[{?158:279?}]]},
vci={[[{?158:4173?}]]}
})
function isphtml.atm_validation(provider)
if isp.is_other(provider)then
local vpi_err=valtxt.vpi
local vci_err=valtxt.vci
newval.msg.vpi={
[newval.ret.empty]=vpi_err,
[newval.ret.outofrange]=vpi_err,
[newval.ret.format]=vpi_err
}
newval.msg.vci={
[newval.ret.empty]=vci_err,
[newval.ret.outofrange]=vci_err,
[newval.ret.format]=vci_err
}
local val_param=create_val_param_func(provider)
local params={
medium=val_param('medium'),
subprovider=val_param('subprovider'),
autodetect=val_param('autodetect'),
vpi=val_param('vpi'),
vci=val_param('vci'),
noauthdsl_vpi=val_param('noauthdsl_vpi'),
noauthdsl_vci=val_param('noauthdsl_vci')
}
if newval.radio_check(params.medium,"dsl")then
if newval.radio_check(params.subprovider,"auth")then
if newval.radio_check(params.autodetect,"0")then
newval.num_range(params.vpi,0,255,"vpi")
newval.num_range(params.vci,32,255,"vci")
end
end
if newval.radio_check(params.subprovider,"noauth")then
newval.num_range(params.noauthdsl_vpi,0,255,"vpi")
newval.num_range(params.noauthdsl_vci,32,255,"vci")
end
end
end
end
valtxt=general.lazytable(valtxt,TXT,{
ip_gateway={[[{?158:7087?}]]},
ip_dns={[[{?158:786?}]]},
ip_allzero={[[{?158:14?}]]},
ip_empty={[[{?158:1074?}]]},
ip_format={[[{?158:476?}]]},
ip_outofrange={[[{?158:64?}]]},
ip_nomask={[[{?158:452?}]]},
ip_outofnet={[[{?158:907?}]]},
ip_thenet={[[{?158:9454?}]]},
ip_broadcast={[[{?158:302?}]]},
ip_reservednet={[[{?158:72?}]]},
hostname={[[{?158:5662?}]]}
})
function isphtml.ipsetting_validation(provider)
if isp.is_other(provider)then
newval.msg.ip_gateway={
[newval.ret.notdifferent]=valtxt.ip_gateway
}
newval.msg.ip_dns={
[newval.ret.notdifferent]=valtxt.ip_dns
}
newval.msg.ip={
[newval.ret.allzero]=valtxt.ip_allzero,
[newval.ret.empty]=valtxt.ip_empty,
[newval.ret.format]=valtxt.ip_format,
[newval.ret.outofrange]=valtxt.ip_outofrange,
[newval.ret.nomask]=valtxt.ip_nomask,
[newval.ret.outofnet]=valtxt.ip_outofnet,
[newval.ret.thenet]=valtxt.ip_thenet,
[newval.ret.broadcast]=valtxt.ip_broadcast,
[newval.ret.reservednet]=valtxt.ip_reservednet
}
newval.msg.hostname={
[newval.ret.outofrange]=valtxt.hostname
}
local val_param=create_val_param_func(provider)
local params={
medium=val_param('medium'),
router_dhcp=val_param('router_dhcp'),
router_hostname=val_param('router_hostname'),
router_ipaddr=val_param('router_ipaddr'),
router_netmask=val_param('router_netmask'),
router_gateway=val_param('router_gateway'),
router_dns1=val_param('router_dns1'),
router_dns2=val_param('router_dns2'),
optype=val_param('optype'),
subprovider=val_param('subprovider'),
client_dhcp=val_param('client_dhcp'),
client_hostname=val_param('client_hostname'),
client_ipaddr=val_param('client_ipaddr'),
client_netmask=val_param('client_netmask'),
client_gateway=val_param('client_gateway'),
client_dns1=val_param('client_dns1'),
client_dns2=val_param('client_dns2'),
encap=val_param('encap'),
noauthdsl_encap=val_param('noauthdsl_encap'),
noauthdsl_dhcp=val_param('noauthdsl_dhcp'),
noauthdsl_hostname=val_param('noauthdsl_hostname'),
noauthdsl_ipaddr=val_param('noauthdsl_ipaddr'),
noauthdsl_netmask=val_param('noauthdsl_netmask'),
noauthdsl_gateway=val_param('noauthdsl_gateway'),
noauthdsl_dns1=val_param('noauthdsl_dns1'),
noauthdsl_dns2=val_param('noauthdsl_dns2')
}
if newval.radio_check(params.medium,"cable")then
if newval.radio_check(params.router_dhcp,"1")then
newval.allowed_devicename(params.router_hostname,"hostname","hostname")
end
if newval.radio_check(params.router_dhcp,"0")then
newval.ipv4(params.router_ipaddr,{zero_not_allowed=true},"ip")
newval.netmask(params.router_netmask,"ip")
newval.ipv4(params.router_gateway,{zero_not_allowed=true},"ip")
newval.ipv4(params.router_dns1,{zero_not_allowed=true},"ip")
newval.ipv4(params.router_dns2,{empty_allowed=true},"ip")
newval.check_reserved_net(params.router_ipaddr,params.router_netmask,params.router_gateway,"ip")
newval.not_equal_ip(params.router_ipaddr,params.router_gateway,"ip_gateway")
newval.not_equal_ip(params.router_ipaddr,params.router_dns1,"ip_dns")
newval.not_equal_ip(params.router_ipaddr,params.router_dns2,"ip_dns")
end
end
if newval.radio_check(params.medium,"extern")then
if newval.radio_check(params.optype,"router")then
if newval.radio_check(params.subprovider,"noauth")then
if newval.radio_check(params.router_dhcp,"1")then
newval.allowed_devicename(params.router_hostname,"hostname","hostname")
end
if newval.radio_check(params.router_dhcp,"0")then
newval.ipv4(params.router_ipaddr,{zero_not_allowed=true},"ip")
newval.netmask(params.router_netmask,"ip")
newval.ipv4(params.router_gateway,{zero_not_allowed=true},"ip")
newval.ipv4(params.router_dns1,{zero_not_allowed=true},"ip")
newval.ipv4(params.router_dns2,{empty_allowed=true},"ip")
newval.check_reserved_net(params.router_ipaddr,params.router_netmask,params.router_gateway,"ip")
newval.not_equal_ip(params.router_ipaddr,params.router_gateway,"ip_gateway")
newval.not_equal_ip(params.router_ipaddr,params.router_dns1,"ip_dns")
newval.not_equal_ip(params.router_ipaddr,params.router_dns2,"ip_dns")
end
end
end
if newval.radio_check(params.optype,"client")then
if newval.radio_check(params.client_dhcp,"1")then
newval.allowed_devicename(params.client_hostname,"hostname","hostname")
end
if newval.radio_check(params.client_dhcp,"0")then
newval.ipv4(params.client_ipaddr,{zero_not_allowed=true},"ip")
newval.netmask(params.client_netmask,"ip")
newval.ipv4(params.client_gateway,{zero_not_allowed=true},"ip")
newval.ipv4(params.client_dns1,{zero_not_allowed=true},"ip")
newval.ipv4(params.client_dns2,{empty_allowed=true},"ip")
newval.check_reserved_net(params.client_ipaddr,params.client_netmask,params.client_gateway,"ip")
end
end
end
if newval.radio_check(params.medium,"dsl")then
if newval.radio_check(params.subprovider,"noauth")then
if newval.radio_check(params.noauthdsl_encap,"dslencap_ether")then
if newval.checked(params.noauthdsl_dhcp)then
newval.allowed_devicename(params.noauthdsl_hostname,"hostname","hostname")
else
newval.ipv4(params.noauthdsl_ipaddr,{zero_not_allowed=true},"ip")
newval.netmask(params.noauthdsl_netmask,"ip")
newval.ipv4(params.noauthdsl_gateway,{zero_not_allowed=true},"ip")
newval.ipv4(params.noauthdsl_dns1,{zero_not_allowed=true},"ip")
newval.ipv4(params.noauthdsl_dns2,{empty_allowed=true},"ip")
newval.check_reserved_net(params.noauthdsl_ipaddr,params.noauthdsl_netmask,params.noauthdsl_gateway,"ip")
newval.not_equal_ip(params.noauthdsl_ipaddr,params.noauthdsl_gateway,"ip_gateway")
newval.not_equal_ip(params.noauthdsl_ipaddr,params.noauthdsl_dns1,"ip_dns")
newval.not_equal_ip(params.noauthdsl_ipaddr,params.noauthdsl_dns2,"ip_dns")
end
else
newval.ipv4(params.noauthdsl_ipaddr,{zero_not_allowed=true},"ip")
newval.netmask(params.noauthdsl_netmask,"ip")
newval.ipv4(params.noauthdsl_gateway,{zero_not_allowed=true},"ip")
newval.ipv4(params.noauthdsl_dns1,{zero_not_allowed=true},"ip")
newval.ipv4(params.noauthdsl_dns2,{empty_allowed=true},"ip")
newval.check_reserved_net(params.noauthdsl_ipaddr,params.noauthdsl_netmask,params.noauthdsl_gateway,"ip")
newval.not_equal_ip(params.noauthdsl_ipaddr,params.noauthdsl_gateway,"ip_gateway")
newval.not_equal_ip(params.noauthdsl_ipaddr,params.noauthdsl_dns1,"ip_dns")
newval.not_equal_ip(params.noauthdsl_ipaddr,params.noauthdsl_dns2,"ip_dns")
end
end
end
end
end
valtxt=general.lazytable(valtxt,TXT,{
mac_empty={[[{?158:209?}]]},
mac_format={[[{?158:61?}]]},
mac_group={[[{?158:235?}]]}
})
function isphtml.mac_validation(provider)
if isp.mac_needed(provider)then
newval.msg.mac={
[newval.ret.empty]=valtxt.mac_empty,
[newval.ret.format]=valtxt.mac_format,
[newval.ret.group]=valtxt.mac_group
}
local val_param=create_val_param_func(provider)
local params={
medium=val_param('medium'),
mac=val_param('mac'),
subprovider=val_param('subprovider'),
optype=val_param('optype')
}
if newval.radio_check(params.medium,"cable")then
if newval.values_not_all_empty(params.mac,6)then
newval.mac(params.mac,"mac")
end
end
if newval.radio_check(params.medium,"extern")then
if newval.radio_check(params.subprovider,"noauth")then
if newval.radio_check(params.optype,"router")then
if newval.values_not_all_empty(params.mac,6)then
newval.mac(params.mac,"mac")
end
end
end
end
end
end
valtxt=general.lazytable(valtxt,TXT,{
us={[[{?158:481?}]]},
ds={[[{?158:7532?}]]}
})
function isphtml.speed_validation(provider)
if isp.is_other(provider)or isp.is_dsl(provider)or isp.speed_needed(provider)then
local us_err=valtxt.us
local ds_err=valtxt.ds
newval.msg.us={
[newval.ret.empty]=us_err,
[newval.ret.outofrange]=us_err,
[newval.ret.format]=us_err
}
newval.msg.ds={
[newval.ret.empty]=ds_err,
[newval.ret.outofrange]=ds_err,
[newval.ret.format]=ds_err
}
local val_param=create_val_param_func(provider)
local params={
medium_extern=val_param('medium','extern'),
upstream=val_param('upstream'),
downstream=val_param('downstream'),
medium_cable=val_param('medium','cable')
}
if isp.is_dsl(provider)then
if newval.radio_check(params.medium_extern,"extern")then
newval.char_range_regex(params.upstream,"anynonwhitespace","us")
newval.char_range_regex(params.upstream,"decimals","us")
newval.char_range_regex(params.downstream,"anynonwhitespace","ds")
newval.char_range_regex(params.downstream,"decimals","ds")
end
elseif isp.is_other(provider)then
if newval.radio_check(params.medium_cable,"cable")then
newval.char_range_regex(params.upstream,"anynonwhitespace","us")
newval.char_range_regex(params.upstream,"decimals","us")
newval.char_range_regex(params.downstream,"anynonwhitespace","ds")
newval.char_range_regex(params.downstream,"decimals","ds")
end
if newval.radio_check(params.medium_extern,"extern")then
newval.char_range_regex(params.upstream,"anynonwhitespace","us")
newval.char_range_regex(params.upstream,"decimals","us")
newval.char_range_regex(params.downstream,"anynonwhitespace","ds")
newval.char_range_regex(params.downstream,"decimals","ds")
end
else
newval.char_range_regex(params.upstream,"anynonwhitespace","us")
newval.char_range_regex(params.upstream,"decimals","us")
newval.char_range_regex(params.downstream,"anynonwhitespace","ds")
newval.char_range_regex(params.downstream,"decimals","ds")
end
end
end
function isphtml.wan_confirm_txt()
local restnet={}
if config.WLAN then
table_insert(restnet,TXT[[{?txtWlan?}]])
end
local lan_mode
for i=1,config.ETH_COUNT-1 do
lan_mode=tonumber(box.query("eth"..i..":settings/mode"))or 0
if lan_mode>0 then
table_insert(restnet,[[LAN ]]..(i+1))
end
end
local str=general.sprintf(
TXT[[{?158:270?}]],
config.ETH_COUNT>1 and[[LAN 1]]or[[LAN]]
)
str=str.."\\n\\n"
str=str..TXT[[{?158:155?}]]
str=str.."\\n"
str=str..general.sprintf(
TXT[[{?158:759?}]],
table_concat(restnet,[[, ]])
)
return str
end
function isphtml.ipclient_confirm_txt()
local str=[[{?158:7422?}]]
str=str.."\\n"
str=str..[[{?158:623?}]]
str=str.."\\n"
str=str..[[{?158:448?}]]
return TXT(str)
end
