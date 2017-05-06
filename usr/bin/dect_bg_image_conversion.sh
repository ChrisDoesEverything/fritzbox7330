#! /bin/sh

############################################################
# unbedingte Vorinitialisierungen
#
CONVERSION_RETURN_OK="ok"
CONVERSION_RETURN_ERROR_FORMAT="error format"
CONVERSION_RETURN_ERROR_SIZE="error size"
CONVERSION_RETURN_ERROR_UNKNOWN="error unknown"
CONVERSION_RETURN_ERROR_NO_DISK="error no disk"
CONVERSION_RETURN_ERROR_WRITE_FAILED="error write"
in="$1"
out="$2"
pp_number="$3"
dir=
dimx=""
dimy=""
quali=70
sizex=480
sizey=506

############################################################
# Rueckgabewert: bei ok zusaetzlich mit Zielverzeichnis
#
do_exit () {
    if [ "$1" = "$CONVERSION_RETURN_OK" ] ; then
        echo -n ""$1:$dir""
    else
        echo -n ""$1""
    fi
    exit 0;
}

############################################################
# Vorabpruefungen
#
if [ -z "$1" -o -z "$2" -o -z "$3" ] ; then
    echo "dect_bg_image_conversion {in-url} {out-filename} {handset-number}"
    do_exit "$CONVERSION_RETURN_ERROR_UNKNOWN"
fi
if [ ! -r "${in}" ] ; then
    echo "missing ${in}"
    do_exit "$CONVERSION_RETURN_ERROR_UNKNOWN"
fi

############################################################
# beschreibbaren Flashspeicher finden
#

# Herauszufinden, ob /var/InternerSpeicher wirklich nutzbar ist ...
cd /var/InternerSpeicher 2>/dev/null
if [ "$?" -eq "0" ]; then
    while [ `realpath .` != "/" ]; do
        wo=`/bin/mount | grep "\`realpath .\` "`
        if [ "$?" -eq "0" ]; then
            wo=`echo $wo | grep -e '\(^/dev/loop\|^ramfs\)'`
            if [ -z "$wo" ] ; then
                nand=1
                # echo "$wo ist NAND" > /dev/console
            else
                # ... oder in der mikrigen NAS Ramdisk liegt (bei 7270)
                nand=0
                # echo "$wo kein NAND" > /dev/console
            fi
            break
        fi
        # echo "Abfrage fuer $wo gescheitert" > /dev/console
        cd ..
    done
    if [ `realpath .` == "/" ]; then
        # echo "nix gefunden" > /dev/console
        nand=0
    fi
else
    # echo "kein interner Speicher" > /dev/console
    nand=0
fi
if [ -d "/var/InternerSpeicher" ] && [ "$nand" == "1" ]; then
    dir="/var/InternerSpeicher"
    if [ ! -d "$dir/FRITZ/fonpix/$pp_number" ]; then 
        mkdir -p "$dir/FRITZ/fonpix/$pp_number"
    fi
    if [ -d "$dir/FRITZ/fonpix/$pp_number" ]; then
        dir="$dir/FRITZ/fonpix/$pp_number"
    fi
    # echo "InternerSpeicher found $dir" > /dev/console
else
    dirlist=`mount | grep '/dev/sd.*(rw' | sed -e 's/.*on \(.*\) type.*/\1/'`
    if [ -z "$dirlist" ]; then
        # echo "kein USB Speicher da" > /dev/console
        do_exit "$CONVERSION_RETURN_ERROR_NO_DISK"
    fi
    for i in $dirlist; do
        if [ -d "$i" ]; then
            if [ ! -d "$i/FRITZ/fonpix/$pp_number" ]; then 
                mkdir -p "$i/FRITZ/fonpix/$pp_number"
            fi
            if [ -d "$i/FRITZ/fonpix/$pp_number" ]; then
                dir="$i/FRITZ/fonpix/$pp_number"
                break
            fi
        fi
    done
fi
if [ -z "$dir" ]; then
    # echo "Kein schreibbares Speichermedium gefunden" > /dev/console
    do_exit "$CONVERSION_RETURN_ERROR_WRITE_FAILED"
fi


############################################################
# Konvertieren des Hintergrundbildes
#
#

#Groessenpruefungen
rdjpgoutput=`rdjpgcom -verbose "${in}"`
eval "`echo \"$rdjpgoutput\" | grep \"JPEG image is\" | sed \"s/.* \([0-9]*\)w \* \([0-9]*\)h, .*/dimx=\1;dimy=\2/\"`"
if [ "${dimx}" -le 0 -o "${dimy}" -le 0 ] ; then
    do_exit "$CONVERSION_RETURN_ERROR_FORMAT"
fi

if [ -z "`echo \"$rdjpgoutput\" | grep \"JPEG process: Baseline\"`" ] ; then
    let "temp = (dimx * dimy * 3 / 1024)"
    if [ "${temp}" -gt 2048 ] ; then
        do_exit "$CONVERSION_RETURN_ERROR_SIZE"
    fi
fi

# Berechnung der Werte für djpeg, pnmscale und pnmcut
let "temp = (sizex * dimy / dimx)"
if [ $temp -ge $sizey ] ; then
    pnmscmd="-xsize ${sizex} -ysize ${temp}"
    let "scale = (sizex * 8 / dimx) + 1"
    let "temp  = (temp - sizey) / 2"
    pnmccmd="-top ${temp}"
else
    let "temp  = (sizey * dimx) / dimy"
    pnmscmd="-ysize ${sizey} -xsize ${temp}"
    let "scale = (sizey * 8 / dimy) + 1"
    let "temp  = (temp - sizex) / 2"
    pnmccmd="-left ${temp}"
fi
if [ $scale -ge 5 ] ; then
    scale=""
else
    scale="-scale ${scale}/8"
fi

out="$dir/${out}"

# Skalieren, Beschneiden
djpeg ${scale} "${in}" | pnmscale ${pnmscmd} | pnmcut ${pnmccmd} -width ${sizex} -height ${sizey} | \
    cjpeg -quality ${quali} > "${out}"
if [ $? -ne 0 ] ; then
    rm -f "${out}"
    do_exit "$CONVERSION_RETURN_ERROR_FORMAT"
fi

# Fertig
do_exit "$CONVERSION_RETURN_OK"
