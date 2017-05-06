<?lua
dofile("../templates/global_lua.lua")
require"config"
require"http"
require"href"
local url = href.get("/assis/home.lua")
if config.LTE then
url = href.get("/assis/internet_lte.lua", http.url_param("wiztype", "first"))
elseif config.DSL or config.VDSL then
url = href.get("/assis/internet_dsl.lua", http.url_param("wiztype", "first"))
end
http.redirect(url)
?>
