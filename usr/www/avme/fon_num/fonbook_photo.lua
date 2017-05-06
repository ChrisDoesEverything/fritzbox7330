<?lua
g_page_type = "all"
g_page_title = [[{?3089:756?}]]
g_page_help = "hilfe_fon_telefonbuch_foto.html"
g_menu_active_page = "/fon_num/fonbook_list.lua"
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require"http"
require"html"
require"js"
require"fon_book"
g_back_to_page = http.get_back_to_page( "/fon_num/fonbook_list.lua" )
local function set_local_tabs(entry, cfg)
local params = table.concat({
"uid=" .. (entry.uid or "new"),
"back_to_page=" .. g_back_to_page
}, "&")
g_local_tabs = {{
page = "/fon_num/fonbook_entry.lua",
text = [[{?3089:520?}]],
param = params
}, {
page = "/fon_num/fonbook_photo.lua",
text = [[{?3089:626?}]],
param = params
}
}
end
local function read_entry()
local entry = {name = "", numbers = {}, emails = {}}
local uid = tonumber(box.get.uid or box.post.uid)
if uid then
entry = fon_book.read_entry_by_uid(uid)
end
entry.numbers = entry.numbers or {}
entry.emails = entry.emails or {}
return entry
end
local function create_cfg(entry)
local cfg = {}
if not entry.uid then
cfg.noentry = true
else
cfg.uid = entry.uid
end
if entry.image and entry.image ~= "" then
local image = entry.image:gsub([[^file:///]], [[/]])
cfg.imageurl = [[/lua/photo.lua?photo=]]..image..[[&sid=]]..box.glob.sid
end
return cfg
end
local entry = read_entry()
local cfg = create_cfg(entry)
if box.post.cancel then
http.redirect(g_back_to_page)
end
if box.post.delete then
entry.image = nil
cfg.error = fon_book.write_entry(entry)
entry = read_entry()
cfg = create_cfg(entry)
end
if box.post.upload then
local bookid = tostring(fon_book.get_book_id())
local entryidx = tostring(cfg.uid)
local url = href.get("/fon_num/photo_upload.lua",
http.url_param("bookid", bookid),
http.url_param("phototype", "0"),
http.url_param("entryid", entryidx),
http.url_param("back_to_page", g_back_to_page)
)
http.redirect(url)
end
set_local_tabs(entry, cfg)
function write_hidden_values()
html.input{type="hidden", name="uid", value=entry.uid or ""}.write()
end
function write_explain()
local txt = [[{?3089:39?}]]
if cfg.noentry then
txt = [[{?3089:929?}]]
end
html.p{txt}.write()
end
function write_photo()
if not cfg.noentry then
if cfg.imageurl then
html.div{class="formular photocontainer", id="uiPhoto",
html.span{class="photo",
html.img{src=cfg.imageurl, class="hideif_notloadable"},
html.span{class="hideif_loadable",
[[{?3089:984?}]]
}
},
html.span{class="photoedit",
html.button{type="submit", id="uiUpload", name="upload", class="icon",
html.img{src="/css/default/images/bearbeiten.gif"}
},
html.span{[[{?3089:578?}]]},
html.br{},
html.button{type="submit", id="uiDelete", name="delete", class="icon",
html.img{src="/css/default/images/loeschen.gif"}
},
html.span{[[{?3089:741?}]]}
}
}.write()
else
html.div{class="formular photocontainer", id="uiPhoto",
html.span{class="photo",
html.span{[[{?3089:778?}]]}
},
html.span{class="photoedit",
html.button{type="submit", id="uiUpload", name="upload", class="icon",
html.img{src="/css/default/images/bearbeiten.gif"}
},
html.span{[[{?3089:373?}]]}
}
}.write()
end
end
end
function write_hints()
local showusb = true
if config.NAND and not config.RAMDISK then
if box.query("ctlusb:settings/internalflash_enabled") == "1" then
showusb = false
end
end
local headtxt = [[{?txtHinweis?}]]
if showusb then
headtxt = [[{?3089:433?}]]
end
html.br{}.write()
html.strong{headtxt}.write()
local ul = html.ul{class="hintlist"}
if showusb then
ul.add(html.li{
[[{?3089:787?}]]
})
end
ul.add(html.li{
[[{?3089:795?}]]
})
ul.write()
end
function write_cfg_js()
box.out(js.table(cfg or {}));
end
function write_cookie_js()
box.js(box.glob.script, [[?uid=]], entry.uid, [[&back_to_page=]], g_back_to_page)
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.loadable .hideif_loadable,
.notloadable .hideif_notloadable {
display: none;
}
div.photocontainer span {
display: inline-block;
vertical-align: top;
}
div.photocontainer span.photo {
width: 160px;
height: 160px;
background-color: #ffffff;
border: solid 1px;
text-align: center;
}
span.photo img {
max-width: 160px;
max-height: 160px;
}
span.photo span {
margin: 35% 10%;
}
div.photocontainer span.photoedit {
margin-left: 18px;
}
div.photocontainer span.photoedit button,
div.photocontainer span.photoedit span {
vertical-align: middle;
}
div.photocontainer span.photoedit br {
margin-bottom: 10px;
}
div.photocontainer span.photoedit span {
padding-left: 8px;
}
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/cookie.js"></script>
<script type="text/javascript">
var gCfg = <?lua write_cfg_js() ?>;
(function() {
if (gCfg.imageurl) {
var tstImage = new Image();
tstImage.onload = function(){
gCfg.picLoadable = true;
};
tstImage.onerror = function(){
gCfg.picLoadable = false;
};
tstImage.src = gCfg.imageurl;
}
})();
function checkPicLoadable() {
if (gCfg.imageurl) {
if (typeof gCfg.picLoadable == 'undefined') {
setTimeout(checkPicLoadable, 100);
}
else {
jxl.addClass("uiPhoto", gCfg.picLoadable ? "loadable" : "notloadable");
}
}
}
function initEventHandler() {
jxl.addEventHandler("uiUpload", "click", function(evt){
var str = "<?lua write_cookie_js() ?>";
storeCookie("backtopage", str, 1);
});
jxl.addEventHandler("uiDelete", "click", function(evt){
if (!confirm("{?3089:894?}")) {
return jxl.cancelEvent(evt);
}
});
}
ready.onReady(checkPicLoadable);
ready.onReady(initEventHandler);
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.out(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<?lua write_explain() ?>
<?lua write_photo() ?>
<?lua write_hints() ?>
<?lua write_hidden_values() ?>
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="sid" value="<?lua box.out(box.glob.sid) ?>">
<div id="btn_form_foot">
<button type="submit" name="cancel">{?txtOK?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
