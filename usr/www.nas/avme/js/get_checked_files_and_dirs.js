function getCheckedFilesAndDirs()
{
var itemsToCheck = gCurItems[gCurNasDir];
if ( gSearch && 0 < gSearch.length )
{
itemsToCheck = gSearchItems;
}
if ( itemsToCheck && 0 < itemsToCheck.length )
{
var items = [];
for ( var idx in itemsToCheck )
{
if ( itemsToCheck[idx].marked && itemsToCheck[idx].showItem )
{
items[items.length] = itemsToCheck[idx];
}
}
return items;
}
return [];
}
function getCheckedFilesAndDirsCount()
{
return getCheckedFilesAndDirs().length;
}
function show_full_filename( dateiname, no_search )
{
if( no_search )
{
var box_elem = document.getElementById( "filename_detail_box_" + dateiname );
var elem = document.getElementById( "filename_detail_" + dateiname );
if ( null != box_elem && null != elem )
{
if ( elem.offsetWidth >= ( box_elem.offsetWidth - 5 ) )
{
elem.title = dateiname;
}
}
}
}
function selectAllFilesAndDirs( selectAll )
{
var is_checked = selectAll;
if ( "boolean" != typeof selectAll )
{
is_checked = document.getElementById( 'file_list_select_all' ).checked;
}
var curItems = gCurItems[gCurNasDir];
if ( gSearch && 0 < gSearch.length )
{
curItems = gSearchItems;
}
for ( var i in curItems )
{
if ( ".." != curItems[i].filename )
{
if ( "boolean" == typeof selectAll )
{
curItems[i].marked = is_checked;
}
else if ( curItems[i].showItem )
{
curItems[i].marked = is_checked;
}
if ( curItems[i].domItemlist && curItems[i].domItemlist.checkBox )
{
curItems[i].domItemlist.checkBox.checked = curItems[i].marked || false;
}
if ( curItems[i].domItemtile && curItems[i].domItemtile.checkBox )
{
curItems[i].domItemtile.checkBox.checked = curItems[i].marked || false;
}
}
}
if ( gSearch && 0 < gSearch.length )
{
gSearchItems = curItems;
}
else
{
gCurItems[gCurNasDir] = curItems;
}
checkEnableBtn();
}
