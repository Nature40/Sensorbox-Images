#!/usr/bin/env bash

ID=`cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2`

IP1=$((16#${ID:8:2}))
IP2=$((16#${ID:10:2}))
IP3=$((16#${ID:12:2}))
IP4=$((16#${ID:14:2}))

echo "Generating adhoc config..." 1>&2
echo "Address: $IP" 1>&2

cat <<EOF
auto wlan0
iface wlan0 inet manual
    wireless-channel 1
    wireless-essid nature40-sensorboxes-adhoc
    wireless-mode ad-hoc
    # pre-select cell-id (faster connections)
    wireless-ap 90:43:ef:e0:be:e2
    post-up ifconfig \$IFACE 169.254.$IP3.$IP4/16
    post-up ifconfig \$IFACE:0 169.254.0.1/16
    post-up   iptables --table nat --append POSTROUTING --out-interface \$IFACE --jump MASQUERADE
    post-down iptables --table nat --delete POSTROUTING --out-interface \$IFACE --jump MASQUERADE

auto bat0
iface bat0 inet static
    hwaddress ether ${ID:4:2}:${ID:6:2}:${ID:8:2}:${ID:10:2}:${ID:12:2}:${ID:14:2}
    # decrease mtu to cope with batman overhead / raspi zero w limitations
    mtu 1468
    pre-up /usr/sbin/batctl if add wlan0
    address 10.254.$IP3.$IP4
    netmask 255.255.0.0
    post-up   iptables --table nat --append POSTROUTING --out-interface \$IFACE --jump MASQUERADE
    post-down iptables --table nat --delete POSTROUTING --out-interface \$IFACE --jump MASQUERADE
EOF

echo "Done." 1>&2
