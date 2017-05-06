<?lua
if not gl or not gl.logged_in then
box.end_page()
end
function get_sort_order_for_next_press()
local tmp=""
if gl.var.sort_order=="up" then
tmp="down"
else
tmp="up"
end
return tmp
end
function get_sort_order_icon()
local tmp=""
if gl.var.sort_order=="up" then
tmp="icon_sortierung_aufsteigend.png"
else
tmp="icon_sortierung_absteigend.png"
end
return tmp
end
function disable_btn_paste()
local clipboard = gl.clipboard
if clipboard then
clipboard = io.open(gl.clipboard, "r")
end
if clipboard==nil or not gl.write_rights then
return " disabled "
end
return ""
end
function get_title_for_button( button )
local tmp = ""
if gl.write_rights then
if button == "cut" then
tmp = "{?622:545?}"
elseif button == "paste" then
tmp = "{?622:677?}"
elseif button == "del" then
tmp = "{?622:851?}"
elseif button == "rename" then
tmp = "{?622:126?}"
elseif button == "new" then
tmp = "{?622:88?}"
elseif button == "upload" then
tmp = "{?622:271?}"
end
else
tmp = "{?622:366?}"
end
return box.tohtml(tmp)
end
no_menu = gl.var.site == "help"
box.out([[<!--Ausgabe des Menues -->]])
box.out([[<div id="sm_btn_box"><ul>]])
if not no_menu then
box.out([[<li class="divider"></li>]])
if not gl.filelink_mode then
box.out([[
<li>
<button id="sm_btn_upload" type="button" title="]]..get_title_for_button('upload')..[[" onclick="onUploadClick()" ]])
if not gl.write_rights or gl.var.site == "share" then box.out([[ disabled ]]) end
box.out([[>
</button>
<p>]]..box.tohtml("{?622:216?}")..[[</p>
</li>
]])
end
box.out([[
<li class="wider_gap">
<form id="sm_multidownload" method="post" action="/nas/cgi-bin/luacgi_notimeout">]]..
gl.bib.gpl.get_single_parameter_line_for_form( "sid", "" )..
gl.bib.gpl.get_single_parameter_line_for_form( "script", "/http_file_download.lua" )..
gl.bib.gpl.get_single_parameter_line_for_form( "cmd", "multidownload" )..
gl.bib.gpl.get_single_parameter_line_for_form( "cmd_files", "" )..
[[<button id="sm_btn_download" type="button" title="]]..box.tohtml("{?622:189?}")..[[" value="download" onclick="onDownloadClick(this.form)" disabled>
</button>
<p>]]..box.tohtml("{?622:199?}")..[[</p>
</form>
</li>]])
end
if not gl.filelink_mode and not no_menu then
box.out([[
<li class="divider"></li>
<li>
<button id="sm_btn_newdir" type="button" title="]]..get_title_for_button('new')..[[" onclick="createNewDir()"
]])
if not gl.write_rights or gl.var.site == "share" then box.out([[ disabled]]) end
box.out([[>
</button>
</li>
<li>
<button id="sm_btn_paste" type="button" title="]]..get_title_for_button('paste')..[[" onclick="pasteData()" ]]..disable_btn_paste()..[[>
</button>
</li>]])
end
if not gl.filelink_mode and not no_menu then
box.out([[
<li class="divider"></li>
<li>
<button id="sm_btn_cut" type="button" title="]]..get_title_for_button('cut')..[[" onclick="copyData()" disabled>
</button>
</li>
<li>
<button id="sm_btn_delete" type="button" title="]]..get_title_for_button('del')..[[" onclick="getFilesAndDirsToDelete()" disabled>
</button>
</li>
<li>
<button id="sm_btn_rename" type="button" title="]]..get_title_for_button('rename')..[[" onclick="renameFileOrDir()" disabled>
</button>
</li>
<li>
<button id="sm_btn_create_filelink" type="button" title="]]..box.tohtml([[{?622:245?}]])..[[" onclick="createFilelink()" disabled>
</button>
</li>]])
end
if not gl.filelink_mode then
if gl.var.site == "share" then
box.out([[
<li class="divider"></li>
<li>
<form id="sm_showFiles_form" method="post" action="/nas/index.lua">]]..
gl.bib.gpl.get_parameter_line_for_form({site=""})..
gl.bib.gpl.get_single_parameter_line_for_form("site", "files")..
[[<button id="sm_btn_filesList" type="button" title="]]..box.tohtml([[{?622:695?}]])..[[" value="showFiles" onclick="this.form.submit()">
</button>
<p>]]..box.tohtml(TXT([[{?622:641?}]]))..[[</p>
</form>
</li>]])
else
box.out([[
<li class="divider"></li>
<li>
<form id="sm_showShares_form" method="post" action="/nas/index.lua">]]..
gl.bib.gpl.get_parameter_line_for_form({site=""})..
gl.bib.gpl.get_single_parameter_line_for_form("site", "share")..
[[<button id="sm_btn_shareList" type="button" title="]]..box.tohtml([[{?622:670?}]])..[[" value="showShares" onclick="this.form.submit()">
</button>
<p>]]..box.tohtml(TXT([[{?917:8189?}]]))..[[</p>
</form>
</li>]])
end
end
if not no_menu then
local viewTxt = TXT([[{?622:268?}]])
local tile_view_txt = box.tohtml([[{?622:191?}]])
local list_view_txt = box.tohtml([[{?622:447?}]])
local disabled = ""
if "share" == gl.var.site then disabled = "disabled" end
box.out([[
<li class="divider"></li>
<li>
<button id="sm_btn_viewList" type="button" title="]], list_view_txt, [[" value="list" onclick="setView(this)" disabled></button>
<button id="sm_btn_viewTile" type="button" title="]], tile_view_txt, [[" value="tile" onclick="setView(this)" ]], disabled, [[></button>
<p>]], box.tohtml(viewTxt), [[</p>
</li>]])
end
box.out([[
<li class="divider"></li>
<li>
<button id="akt_focus" type="button" title="]]..box.tohtml(TXT([[{?622:693?}]]))..[[" onclick="refreshPage();">
</button>
</li>
</ul>]])
if no_menu or "share" == gl.var.site then
box.out([[
<div id="mm_search">
<div id="mm_searchbox">
<input type="image" class="mm_search_del" src="/nas/css/]]..box.tohtml(gl.var.style)..[[/images/transparent_placeholder.gif" alt="" disabled >
<div class="mm_search_word"></div>
<input type="image" class="mm_search_spyglass" src="/nas/css/]]..box.tohtml(gl.var.style)..[[/images/transparent_placeholder.gif" alt="" disabled >
</div>
</div>
]])
else
box.out([[
<div id="mm_search">
<div id="mm_searchbox">
<input type="image" id="mm_search_del" class="mm_search_del" onclick="del_search_word()" name="search_del" title="]]..box.tohtml(TXT([[{?917:496?}]]))..[[" src="/nas/css/]]..box.tohtml(gl.var.style)..[[/images/transparent_placeholder.gif" alt="" disabled >
<input type="text" id="mm_search_word" class="mm_search_word" oninput="checkSearchwordSet()" onchange="checkSearchwordSet()">
<input type="image" id="mm_search_spyglass" class="mm_search_spyglass" onclick="sendSearchWord()" title="]]..box.tohtml(TXT([[{?917:411?}]]))..[[" src="/nas/css/]]..box.tohtml(gl.var.style)..[[/images/transparent_placeholder.gif" alt="">
</div>
<p id="mm_searchhint" style="display:none;">]], box.tohtml(TXT([[{?622:767?}]])) , [[</p>
</div>
]])
end
box.out([[</div>]])
?>
<!--Nötige Javascript Funktionen -->
<script type="text/javascript" src="/nas/js/get_checked_files_and_dirs.js"></script>
<script type="text/javascript" src="/nas/js/sub_menue_buttons.js"></script>
<script type="text/javascript" src="/nas/js/file_upload.js"></script>
