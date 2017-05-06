#! /bin/sh
trap "" SIGHUP

TEST_SERVER=$TFTP_SERVER
LOOP_COUNT="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120" 

for i in ${LOOP_COUNT}; do
    echo "PTEST: finalize: getting finalize.tar from server ${TEST_SERVER} ($i)" > /dev/console 
    tftp -g -r finalize.tar -l /var/finalize.tar ${TEST_SERVER}
    if [ -s /var/finalize.tar ]; then
        tar xf /var/finalize.tar -C /var
        if [ -f /var/finalize.sh ]; then
            chmod +x /var/finalize.sh
            case `uname -r` in
                2.4*)
                    exec /var/finalize.sh ${TEST_SERVER}
                    ;;
                2.6*)
                    /var/finalize.sh ${TEST_SERVER} 1> /dev/console 2> /dev/console
                    exit 0
                    ;;
                *)      
                    echo "PTEST: finalize: unknown kernel version `uname -r`" > /dev/console 
                    ;;
            esac
        fi
    fi
    sleep 2
done

