# luci-app-guestwifi

LuCI guest Wi-Fi manager for QWRT/OpenWrt-style Qualcomm QSDK routers.

This package was designed and tested on a tri-band QWRT device using Qualcomm `qcawificfg80211` wireless configuration:

- `wifi1`: 2.4 GHz
- `wifi2`: 5.2 GHz low band
- `wifi0`: 5.8 GHz high band

## Features

- Guest Wi-Fi on 2.4 GHz / 5.2 GHz / 5.8 GHz radios
- Unified SSID mode or per-band SSID mode
- WPA2-PSK AES, WPA/WPA2 mixed, or open network
- Dedicated guest network: `192.168.200.0/24`
- Dedicated DHCP pool
- Guest-to-WAN forwarding
- Guest-to-LAN isolation
- Client isolation support
- Guest client lease table in LuCI
- One-command cleanup mode

## Notes

This package intentionally does not include guest bandwidth limiting. On QSDK/NSS platforms, `tc` rules can be bypassed by hardware offload, making simple LuCI-side limits unreliable.

## Install From Source

Copy the package into an OpenWrt/QWRT build tree:

```sh
cp -r luci-app-guestwifi package/
make menuconfig
make package/luci-app-guestwifi/compile V=s
```

## Runtime Cleanup

```sh
/usr/bin/guestwifi-setup cleanup
```

This removes the guest network, DHCP, firewall rules, wireless VAPs, and `/etc/config/guestwifi`.
