--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require("capiterm")
require("general")
g_HtmlFormat = true
g_HtmlPraefix = ""
g_HtmlCheckResult = {}
g_CapittermPostfix = ".::80:::lua/html_check.lua"
function RemoveElem(Search, Original)
local Index
local Token
local UpperSearch = Search:upper()
for Index, Token in pairs(g_HtmlCheckResult) do
if Token:upper() == UpperSearch then
table.remove(g_HtmlCheckResult, Index)
g_HtmlPraefix = g_HtmlPraefix:sub(1, -3)
return true
end
end
capiterm.var("Fehlerhaft", Original, g_CapittermPostfix .. " --- ErrorCheck!")
return false
end
function CheckHtml(Text)
SingleToken = {"INPUT", "BR", "HR", "LINK", "IMG"}
local Original = Text
local FirstChar = Text:sub(1, 1)
local Next
if FirstChar ~= "<" then
if FirstChar == " " then
table.insert(g_HtmlCheckResult, Text .. " Space am Anfang")
return g_HtmlPraefix
end
return " " .. g_HtmlPraefix
end
if Text:sub(-1) ~= ">" then
table.insert(g_HtmlCheckResult, Text .. " Klammer(>) fehlt")
return g_HtmlPraefix
end
local Position = Text:find(" ")
if Position ~= nil then
Text = Text:sub(2, Position - 1)
else
Text = Text:sub(2, -2)
end
local UpperText = Text:upper()
for Next = 1, #SingleToken, 1 do
if UpperText == SingleToken[Next] then
return g_HtmlPraefix .. " "
end
end
if Text:sub(1, 1) == "/" then
if RemoveElem(Text:sub(2), Original) then
return g_HtmlPraefix .. " "
end
else
table.insert(g_HtmlCheckResult, Text)
g_HtmlPraefix = g_HtmlPraefix .. " "
end
return g_HtmlPraefix
end
function tobox(Text)
if string.len(Text) == 0 then
return
end
local Praefix = CheckHtml(Text)
if g_HtmlFormat == false then
Praefix = ""
end
local FirstChar = Text:sub(1, 1)
if (Text:sub(1, 2) == "<!") or ((FirstChar ~= "<") and (FirstChar ~= "&")) then
box.html(Praefix .. Text)
box.out("\n")
return
end
box.out(Praefix .. Text .. "\n")
end
function debug()
capiterm.var("Zu oft angegebene Tags Tags", g_HtmlCheckResult)
if string.len(g_HtmlPraefix) > 0 then
capiterm.var("Auto-Indent", g_HtmlPraefix)
end
end
