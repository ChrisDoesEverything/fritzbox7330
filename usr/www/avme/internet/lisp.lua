<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_internet_lisp.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("general")
if next(box.post) and box.post.btn_save then
local ctlmgr_save={}
cmtable.save_checkbox(ctlmgr_save, "lisp:settings/enabled" , "activate_lisp")
if box.post.activate_lisp then
cmtable.add_var(ctlmgr_save, "lisp:settings/description" , box.post.lisp_provider)
cmtable.add_var(ctlmgr_save, "lisp:settings/passwd" , box.post.lisp_password)
cmtable.add_var(ctlmgr_save, "lisp:settings/ms" , box.post.map_server)
cmtable.add_var(ctlmgr_save, "lisp:settings/mr" , box.post.map_resolver)
cmtable.add_var(ctlmgr_save, "lisp:settings/pxtr" , box.post.proxy_tunnel_router)
cmtable.add_var(ctlmgr_save, "lisp:settings/eids" , box.post.eids)
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr = general.create_error_div(err,msg)
box.out(criterr)
end
end
g_ctlmgr = {}
g_ctlmgr.lisp_enabled = box.query("lisp:settings/enabled") == "1"
g_ctlmgr.lisp_provider = box.query("lisp:settings/description")
g_ctlmgr.lisp_password = box.query("lisp:settings/passwd")
g_ctlmgr.map_server = box.query("lisp:settings/ms")
g_ctlmgr.map_resolver = box.query("lisp:settings/mr")
g_ctlmgr.proxy_tunnel_router = box.query("lisp:settings/pxtr")
g_ctlmgr.eids = box.query("lisp:settings/eids")
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
{?259:718?}
</p>
<hr>
<div class="formular">
<input type="checkbox" id="uiViewActivateLisp" name="activate_lisp" onclick="onLispActiv()" <?lua if g_ctlmgr.lisp_enabled then box.out('checked') end ?>>
<label for="uiViewActivateLisp">{?259:12?}</label>
<div id="lisp_box" class="formular">
<label for="uiViewLispProvider">{?259:979?}</label>
<input type="text" id="uiViewLispProvider" size="63" name="lisp_provider" value="<?lua box.html(g_ctlmgr.lisp_provider) ?>">
<br>
<label for="uiViewLispPassword">{?259:94?}</label>
<input type="text" id="uiViewLispPassword" size="63" name="lisp_password" value="<?lua box.html(g_ctlmgr.lisp_password) ?>">
<br>
<label for="uiViewMapServer">{?259:522?}</label>
<input type="text" id="uiViewMapServer" size="63" name="map_server" value="<?lua box.html(g_ctlmgr.map_server) ?>">
<br>
<label for="uiViewMapResolver">{?259:731?}</label>
<input type="text" id="uiViewMapResolver" size="63" name="map_resolver" value="<?lua box.html(g_ctlmgr.map_resolver) ?>">
<br>
<label for="uiViewProxyTunnelRouter">{?259:980?}Proxy Tunnel Router (PxTR):</label>
<input type="text" id="uiViewProxyTunnelRouter" size="63" name="proxy_tunnel_router" value="<?lua box.html(g_ctlmgr.proxy_tunnel_router) ?>">
<br>
<label for="uiViewEids">{?259:824?}</label>
<input type="text" id="uiViewEids" size="63" name="eids" value="<?lua box.html(g_ctlmgr.eids) ?>">
</div>
</div>
<div id="btn_form_foot">
<button type="submit" name="btn_save" id="btnSave">{?txtApply?}</button>
<button type="submit" name="btn_cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript">
function onLispActiv()
{
jxl.disableNode("lisp_box", !jxl.getChecked("uiViewActivateLisp"));
}
function init()
{
onLispActiv();
}
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
