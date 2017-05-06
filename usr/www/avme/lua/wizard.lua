--[[Access denied<?lua
    box.end_page()
?>?>]]
-- de-first -begin
require"textdb"
require"href"
require"html"
require"http"
wizard={}
function wizard.leave()
http.redirect(href.get("/assis/home.lua"))
end
function wizard.write_class()
box.out(" "..wizard.curr)
end
function wizard.write_css()
local dlg=wizard.dialogs
local selectors={}
for i=1,#dlg do
if dlg[i]~=wizard.curr then
table.insert(selectors,"#"..dlg[i])
end
end
box.out("\n",
table.concat(selectors,",\n"),
" {\n display: none;\n}"
)
end
function wizard.write_hidden_params()
html.input{type="hidden",name="prevdlg",value=wizard.curr or""}.write()
if wizard.wiztype then
html.input{type="hidden",name="wiztype",value=wizard.wiztype}.write()
end
end
local btntext={}
function wizard.override_btntext(name,txt)
btntext[name]=txt
end
local btn_disabled={}
function wizard.disable_button(name)
btn_disabled[name]=true
end
wizard.noconfirm_oncancel=false
function wizard.write_buttons()
if wizard[wizard.curr].backward()then
html.button{type="submit",name="backward",id="uiBackward",disabled=btn_disabled.backward,
btntext.backward or TXT([[{?txtBack?}]])
}.write()
end
if wizard[wizard.curr].forward()then
html.button{type="submit",name="forward",id="uiForward",class="fwd_btn",disabled=btn_disabled.forward,
btntext.forward or TXT([[{?txtNextGreaterThan?}]])
}.write()
end
if not wizard.nocancel then
html.button{type="submit",name="cancel",id="uiCancel",disabled=btn_disabled.cancel,
class=wizard.noconfirm_oncancel and"nocancel"or nil,
btntext.cancel or TXT([[{?txtCancel?}]])
}.write()
end
end
function wizard.write_1und1_logo(hide)
if config.oem=="1und1"and not hide then
html.div{class="logo_1und1"}.write()
end
end
function wizard.write_1und1_logo_css(hide)
if config.oem=="1und1"and not hide then
local selectors={}
for i,dlg in ipairs(wizard.dialogs)do
table.insert(selectors,"#"..dlg)
end
box.out("\n")
box.out(table.concat(selectors,",\n"))
box.out("{\n",[[padding-right: 90px;]],"\n}")
end
end
