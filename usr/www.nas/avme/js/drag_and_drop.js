if ( window.FileReader )
{
window.addEventListener( 'load', function()
{
window.addEventListener( 'dragover', showNotDropable, false );
window.addEventListener( 'dragenter', showNotDropable, false );
registerDropZone( "page_middle_box" );
}, false );
}
function preventDefaultDrop( evt )
{
if ( evt && evt.stopPropagation )
{
evt.stopPropagation();
}
if ( evt && evt.preventDefault )
{
evt.preventDefault();
}
}
function showNotDropable( evt )
{
preventDefaultDrop( evt );
evt.dataTransfer.dropEffect = evt.dataTransfer.effectAllowed = "none";
return false;
}
function showDropable( evt )
{
preventDefaultDrop( evt );
evt.dataTransfer.dropEffect = evt.dataTransfer.effectAllowed = "copy";
return false;
}
function catchDrop( evt )
{
preventDefaultDrop( evt );
if ( evt && evt.dataTransfer && evt.dataTransfer.files && 0 < evt.dataTransfer.files.length )
{
onUploadClick( evt, evt.dataTransfer );
}
return false;
}
function registerDropZone( idOrElement )
{
var dropZone = jxl.get( idOrElement );
if ( dropZone )
{
dropZone.addEventListener( 'dragover', showDropable, false );
dropZone.addEventListener( 'dragenter', showDropable, false );
dropZone.addEventListener( 'drop', catchDrop, false );
}
}
