#!/bin/sh

trap "" SIGHUP

MEASUREMENT_CHANNEL=$1
MEASUREMENT_TIME=$2
MEASUREMENT_COUNT=$3
RESULT_FILE=/var/wlanlifetest.msg

VERSION='1.0 vr9'
#DURCHLAEUFE="ersterTest test2 test3 test4 test5 test6 test7 test8 test9 test10 test11 letzterTest"
DURCHLAEUFE="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130" 

# Zeit, wie lange zwischen einem neuen Versuch gewartet werden soll.
INTERVALL=1

TFTPServer=192.168.${VLAN_GROUP}.10

SUCCESS=0

echo "PTEST: start WLAN_LIFETEST.SH version [${VERSION}]" > /dev/console

# Test durchführen 
echo "PTEST: wlanlifetest: running (channel=$MEASUREMENT_CHANNEL, time=$MEASUREMENT_TIME, count=$MEASUREMENT_COUNT) ..." > /dev/console
/etc/init.d/rc.wlan lifetest $MEASUREMENT_CHANNEL  $MEASUREMENT_COUNT $MEASUREMENT_TIME $RESULT_FILE

# Sende Bereitschaftsmeldung
count=0
while ! tftp -p -l $RESULT_FILE -r wlanlifetest-${VLAN_GROUP}.msg $TFTPServer ; do
    echo "PTEST: wlanlifetest: sending results to host ..."
    count=$(($count + 1))
    if [ $count -gt 50 ] ; then 
        exit 1
    fi
    sleep 1
done
 
exit 0;        
