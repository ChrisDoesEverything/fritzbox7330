/*
*/
var convert = convert || (function() {
var lib = {};
var g_units = new Array( "Byte", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB");
lib.XtoY = function(fileSize, unitOfFileSize, convertToUnit, prezision, binaer, withUnitString)
{
var oldUnitIndex = getIndexOfUnit(unitOfFileSize);
var newUnitIndex = getIndexOfUnit(convertToUnit);
};
lib.humanReadable = function(fileSize, unitOfFileSize, precision, binaer, withUnitString)
{
var unitCount = 0;
var divisor = (binaer) ? 1024 : 1000 ;
var unitDelta = 0;
var newUnitStr = unitOfFileSize;
var newFileSize = 0;
if (fileSize < 0) fileSize=0;
if (precision < 0) precision=0;
var tmp = fileSize;
var realPrecision = precision;
if (tmp >= divisor)
{
do {
unitDelta++;
tmp = tmp/divisor;
} while(tmp >= divisor);
}
if (binaer && tmp > 999)
{
unitDelta++;
tmp = tmp/divisor;
}
if ( (newUnitStr = getNewUnitString(unitOfFileSize, unitDelta)).toLowerCase() == "byte" )
precision = 0;
newFileSize = tmp;
if ((realPrecision = getRealPrecision(newFileSize, precision)) < 1)
newFileSize = Math.floor(newFileSize);
else
newFileSize = newFileSize.toPrecision(realPrecision);
newFileSize = newFileSize.toString().replace(".",",")
if (withUnitString)
return newFileSize + " " + newUnitStr;
else
return newFileSize;
};
function getIndexOfUnit(unit)
{
for (i=0; i < g_units.length; i++)
if (g_units[i].toLowerCase() == unit.toLowerCase())
return i;
}
function getNewUnitString(oldUnit, unitDelta)
{
var newIndex = -1;
for (i=0; i < g_units.length; i++)
if (g_units[i].toLowerCase() == oldUnit.toLowerCase() && (i+unitDelta) <= g_units.length)
{
newIndex = i + unitDelta;
break;
}
if (newIndex != -1)
return g_units[newIndex]
else
return ""
}
function getRealPrecision(num, precision)
{
var precisionPlus = 1;
if (Math.floor(num) == 0) return precision;
while((num=(num/10)) >= 1) precisionPlus++;
return precision+precisionPlus;
}
return lib;
})();
