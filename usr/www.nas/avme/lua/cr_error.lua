--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
if not gl or not gl.logged_in then
box.end_page()
end
function check_cr_error(file)
--Achtung ein %0d = Carrige Return kann bei Internen Speicher Fehlern auftreten um muss aus der path und filename raus.
if file.filename then
file.filename = string.gsub(file.filename, "\n", "")
file.filename = string.gsub(file.filename, "\r", "")
end
if file.path then
file.path = string.gsub(file.path, "\n", "")
file.path = string.gsub(file.path, "\r", "")
end
return file
end
