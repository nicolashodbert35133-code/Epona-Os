\ Realtek RTL8821CE WiFi 802.11ac + Bluetooth
\ VID: 10EC  DID: C821/C822/C82F
\ Firmware: firmware/rtw8821c_fw.bin (136 KB)
\ Placez ce fichier dans forth/drivers/

: realtek-rtl8821ce-info ( -- )
  cr
  ." === Realtek RTL8821CE WiFi ===" cr
  ." Chipset:  RTL8821CE 802.11ac + BT" cr
  ." Vendor:   10EC" cr
  ." Device:   C821 (WiFi)" cr
  net:info
;

: realtek-rtl8821ce-firmware ( -- ok? )
  cr
  ." Chargement firmware rtw8821c_fw.bin..." cr
  net:firmware
;

: realtek-rtl8821ce-scan ( -- )
  cr
  ." Scan Realtek RTL8821CE..." cr
  net:init
  net:status
  net:mac
;

: realtek-rtl8821ce-config ( -- )
  cr
  ." Configuration WiFi RTL8821CE..." cr
  net:init
  net:dhcp
  net:info
  net:status
;

: realtek-rtl8821ce-ping ( -- )
  ." Ping passerelle via RTL8821CE..." cr
  net:ping
;

: realtek-rtl8821ce-init ( -- )
  cr
  ." === Init Realtek RTL8821CE ===" cr
  ." 1. Firmware..." cr
  realtek-rtl8821ce-firmware
  if
    ." 2. Init carte..." cr
    net:init
    ." 3. MAC:" cr
    net:mac
    ." 4. Status:" cr
    net:status
    cr
    ." RTL8821CE pret." cr
  else
    ." ECHEC: firmware non charge." cr
    ." Verifiez firmware/rtw8821c_fw.bin sur la cle USB." cr
  then
;
