#! /bin/sh

LOCAL_DOWNLOAD_NAME="/var/tmp/dect_org_ringtone"
MAX_DOWNLOAD_SIZE=1000
CONVERSION_RETURN_OK="ok"
CONVERSION_RETURN_ERROR_OFFLINE="error offline"
CONVERSION_RETURN_ERROR_NO_FILE="error no file"
CONVERSION_RETURN_ERROR_FORMAT="error format"
CONVERSION_RETURN_ERROR_UNKNOWN="error unknown"
CONVERSION_RETURN_ERROR_NO_DISK="error no disk"
CONVERSION_RETURN_ERROR_WRITE_FAILED="error write"
in="$1"
out="$2"
pp_number="$3"
out_type="$4"
dir=

############################################################
# Rueckgabewert: bei ok zusaetzlich mit Zielverzeichnis
#
do_exit () {
    if [ -e "${LOCAL_DOWNLOAD_NAME}" ] ; then
        rm -f "${LOCAL_DOWNLOAD_NAME}"
    fi
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
if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ] ; then
    # echo "dect_ringtone_conversion {in-url} {out-filename} {handset-number} {out_type}"
    do_exit "$CONVERSION_RETURN_ERROR_UNKNOWN"
fi

if [ -e "${LOCAL_DOWNLOAD_NAME}" ] ; then
    rm -f "${LOCAL_DOWNLOAD_NAME}"
    if [ $? -gt 0 ] ; then
        do_exit "$CONVERSION_RETURN_ERROR_UNKNOWN"
    fi
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
    if [ ! -d "$dir/FRITZ/fonring/$pp_number" ]; then 
        mkdir -p "$dir/FRITZ/fonring/$pp_number"
    fi
    if [ -d "$dir/FRITZ/fonring/$pp_number" ]; then
        dir="$dir/FRITZ/fonring/$pp_number"
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
            if [ ! -d "$i/FRITZ/fonring/$pp_number" ]; then 
                mkdir -p "$i/FRITZ/fonring/$pp_number"
            fi
            if [ -d "$i/FRITZ/fonring/$pp_number" ]; then
                dir="$i/FRITZ/fonring/$pp_number"
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
# Holen des Klingeltons
#
if [ ${in:0:7} == "file://" ]; then
cat "${in:7}" | dd bs=1024 count=240 of="$dir/${out}"
#cat "${in:7}" | dd bs=1024 count="${MAX_DOWNLOAD_SIZE}" of="${LOCAL_DOWNLOAD_NAME}"
else
wget "${in}" -O - | dd bs=1024 count="${MAX_DOWNLOAD_SIZE}" of="${LOCAL_DOWNLOAD_NAME}"
fi
if [ $? -ne 0 ] ; then
    do_exit "$CONVERSION_RETURN_ERROR_OFFLINE"
fi
if [ ${in:0:7} == "file://" ]; then
if [ ! -s "$dir/${out}" ] ; then
    do_exit "$CONVERSION_RETURN_ERROR_NO_FILE"
fi
else
if [ ! -s "${LOCAL_DOWNLOAD_NAME}" ] ; then
    do_exit "$CONVERSION_RETURN_ERROR_OFFLINE"
fi
fi

############################################################
# Konvertieren des Klingeltons (nur bei externen Toenen)
#
if [ ${in:0:7} != "file://" ]; then
ffmpegconv -i "${LOCAL_DOWNLOAD_NAME}" -o "$dir/${out}" +n --type $out_type --limit 240 > /dev/null
if [ $? -ne 0 ] ; then
    do_exit "$CONVERSION_RETURN_ERROR_FORMAT"
fi
if [ ! -s "$dir/${out}" ] ; then
    do_exit "$CONVERSION_RETURN_ERROR_FORMAT"
fi
fi

############################################################
# fertig
#
do_exit "$CONVERSION_RETURN_OK"
