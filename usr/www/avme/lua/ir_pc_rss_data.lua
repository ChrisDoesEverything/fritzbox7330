--[[Access denied<?lua
box.end_page()
?>]]
--- ein Modul welches die Providerabhängigen InternetRadio, Podcast und Rss Feed Daten beherbergt.
-- @name edat
module(..., package.seeall)
require("config")
require("textdb")
--All telefone wenn telefone gleich 10
local all_phone = 1023
local default_poll = 1200 -- gleich 20 Minuten
local g_data = {
--internetradio
{ name = [[Deutschlandfunk]], url = [[http://www.dradio.de/streaming/dlf.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Dradio Kultur]], url = [[http://www.dradio.de/streaming/dkultur.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Dradio Wissen]], url = [[http://www.dradio.de/streaming/dradiowissen.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Eins Live Diggi]], url = [[http://www.wdr.de/wdrlive/media/einslivedigi.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Radio Fritz]], url = [[http://www.fritz.de/live.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[radioeins]], url = [[http://www.radioeins.de/live.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Sputnik Livestream]], url = [[http://www.sputnik.de/m3u/live.hi.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Swissgroove]], url = [[http://www.swissgroove.ch/listen.php]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Bayern 1]], url = [[http://streams.br-online.de/bayern1_2.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Bremen 1]], url = [[http://httpmedia.radiobremen.de/bremeneins.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[HR3]], url = [[http://metafiles.gl-systemhaus.de/hr/hr3_2.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[NDR2]], url = [[http://www.ndr.de/resources/metadaten/audio/m3u/ndr2.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[SWR 3]], url = [[http://mp3-live.swr3.de/swr3_s.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Jazzradio]], url = [[http://www.jazzradio.net/docs/stream/jazzradio.pls]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Funkhaus Europa]], url = [[http://www.wdr.de/wdrlive/media/fhe.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[RadyoSunet]], url = [[ http://www.wdr.de/wdrlive/media/koelnradyosunet.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Bermana Kurdi]], url = [[http://www.wdr.de/wdrlive/media/funkhauseuropa_kurdisch.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[CH Swissgroove]], url = [[http://www.swissgroove.ch/listen.php]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[GB Absolute Radio]], url = [[http://network.absoluteradio.co.uk/core/audio/mp3/live.pls?service=vrbb]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[BEL Studio Brussel]], url = [[http://mp3.streampower.be/stubru-high]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[LUX RTL Letzebuerg]], url = [[http://radio.rtl.lu/mp3.pls]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[Austria Hitradio OE 3]], url = [[http://mp3stream7.apasf.apa.at:8000/]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[IT Radio 101]], url = [[http://players.creacast.com/creacast/r101/playlist.pls]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[die neue welle]], url = [[http://www.die-neue-welle.de/dnw_128.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
{ name = [[AlternativeFM]], url = [[http://www.alternativefm.de/afm_128.m3u]], poll = 0, bitmap = all_phone, type = "ir" },
--podcast
{ name = [[Bayern 3 - Kino Kompakt]], url = [[http://www.br-online.de/podcast/kino-kompakt/cast.xml]], poll = default_poll, bitmap = all_phone, type = "pc" },
{ name = [[radioeins - Die besten Interviews]], url = [[http://www.radioeins.de/rss.xml?beitrag_143640]], poll = default_poll, bitmap = all_phone, type = "pc" },
{ name = [[Radio Fritz - Fritz Info Multimedia]], url = [[http://www.fritz.de/podcast.xml?60_85317]], poll = default_poll, bitmap = all_phone, type = "pc" },
{ name = [[Tagesschau]], url = [[http://www.tagesschau.de/export/podcast/tagesschau/#]], poll = default_poll, bitmap = all_phone, type = "pc" },
{ name = [[WDR 5 - Der satirische Wochenrückblick von Peter Zudeick]], url = [[http://podcast.wdr.de/radio/wochenrueck.xml]], poll = default_poll, bitmap = all_phone, type = "pc" },
--rss
{ name = [[AVM.de]], url = [[http://www.avm.de/de/Extern/RSS/rss.xml]], poll = default_poll, bitmap = all_phone, type = "rss" },
{ name = [[Heute um 20:15 Uhr im TV]], url = [[http://www.tvspielfilm.de/tv-programm/rss/heute2015.xml]], poll = default_poll, bitmap = all_phone, type = "rss" },
{ name = [[Kino.de - Movienews]], url = [[http://www.kino.de/rss.php4?typ=movienews]], poll = default_poll, bitmap = all_phone, type = "rss" },
{ name = [[Spiegel.de - Panorama]], url = [[http://www.spiegel.de/panorama/index.rss]], poll = default_poll, bitmap = all_phone, type = "rss" },
{ name = [[Sport1 - News]], url = [[http://www.sport1.de/de_1/startseite/rss.xml]], poll = default_poll, bitmap = all_phone, type = "rss" },
{ name = [[Tagesschau.de]], url = [[http://www.tagesschau.de/xml/rss2]], poll = default_poll, bitmap = all_phone, type = "rss" },
{ name = [[Wetter.com]], url = [[http://wetter.com/wetter_rss/wetter.xml]], poll = default_poll, bitmap = all_phone, type = "rss" },
{ name = [[ZDNet.de]], url = [[http://www.zdnet.de/feeds/news/xml/rss_h5.xml.htm]], poll = default_poll, bitmap = all_phone, type = "rss" },
--new ir pc rss
{ name = TXT([[{?1846:346?}]]), url = [[]], poll = 0, bitmap = 0, type = "ir" },
{ name = TXT([[{?1846:667?}]]), url = [[]], poll = default_poll, bitmap = 0, type = "pc" },
{ name = TXT([[{?1846:485?}]]), url = [[]], poll = default_poll, bitmap = 0, type = "rss" }
}
--Holen aller EMail Daten für weitere Verarbeitung in Lua
function get_data(type)
local tab = {}
local cnt = 0
--oem abhängig aufbereitung
if config.no_ir_pc_rss_samples then
--Es werden nur alle 1und1 web.de und gmx daten zurückgegeben
for i,v in ipairs(g_data) do
if not(type) or type=="" or type=="all" then
if v.url == "" then
cnt = cnt + 1
tab[cnt] = v
end
else
if v.url == "" and v.type == type then
cnt = cnt + 1
tab[cnt] = v
end
end
end
else
if not(type) or type=="" or type=="all" then
tab = g_data
else
for i,v in ipairs(g_data) do
if v.type == type then
cnt = cnt + 1
tab[cnt] = v
end
end
end
end
return tab
end
function get_ir_data()
return get_data("ir")
end
function get_pc_data()
return get_data("pc")
end
function get_rss_data()
return get_data("rss")
end
function get_table_as_js_array(tab)
local str = ""
for i,v in ipairs(tab) do
if str=="" then
str = [[{]]
else
--es ist schon was da dann noch ein Komma ran um das nächste element schreiben zu können
str = str..[[, ]]
end
--index oder name übernehmen
str = str..[[ "]]..i..[[" : ]]
--und dann den Wert (Value)
if type(v) == "table" then
str = str..get_table_as_js_array(v)
elseif type(v) == "string" then
str = str..[["]]..v..[[" ]]
else
str = str..tostring(v)
end
end
if str == "" then
str = [[{]]
end
return str..[[}]]
end
function get_data_as_js_arraystr(type)
local tab = get_data(type)
local str = get_table_as_js_array(tab)
if str=="" then
str = [[{}]]
end
return str
end
--Diese Funktion wird aus dem Javascript aufgerufen um die Daten in ein JS Array zu Speichern
function write_data_to_js(type)
box.out(get_data_as_js_arraystr(type))
end
