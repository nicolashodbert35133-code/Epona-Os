\ ══════════════════════════════════════════════════════════
\ PCIe-Standard.FTH
\ Ref:      Scanner le bus PCI du NicoHpGris
\ ┌──────────────────────────────────────────────────────┐
\ │ Bus  Device  Fonct  Description         Vendor:Dev   │
\ ├──────────────────────────────────────────────────────┤
\ │ 00   00.0    —      AMD Root Complex    1022:1631    │
\ │ 00   01.0    —      AMD GPP Bridge      1022:1632    │
\ │ 00   02.0    —      AMD GPP Bridge      1022:1632    │
\ │ 00   08.0    —      AMD Radeon Vega 7   1002:1638    │
\ │ 00   14.0    —      AMD SMBus           1022:15E4    │
\ │ 00   18.0    —      AMD Host Bridge     1022:1630    │
\ │ 01   xx.x    —      AMD USB 3.1 xHCI   1022:15E0    │
\ │ 02   00.0    —      WD SN770 NVMe       varies       │
\ │ 03   xx.x    —      AMD AHCI SATA       1022:7901    │
\ │ 04   00.0    —      Realtek RTL8168     10EC:8168    │
\ │ 05   00.x    —      Realtek ALC256      10EC:0256    │
\ │ 06   00.x    —      AMD I2C Controller  1022:15E4    │
\ └──────────────────────────────────────────────────────┘
\ Primitives: pci-scan, pci-dev, pci-bar, pci-name
\ ══════════════════════════════════════════════════════════

\ --- Tableau attendu ---
: pcie-nicohpgris-liste
  cr
  cr ." === TABLEAU PCI: NicoHpGris ==="
  cr
  cr ."  Bus  Device  Ref NIC          Vendor:Dev"
  cr ."  ──── ──────  ────────────────  ──────────"
  cr ."  00   00.0    AMD Root Complex  1022:1631"
  cr ."  00   01.0    AMD GPP Bridge    1022:1632"
  cr ."  00   02.0    AMD GPP Bridge    1022:1632"
  cr ."  00   08.0    AMD Radeon Vega 7 1002:1638"
  cr ."  00   14.0    AMD SMBus         1022:15E4"
  cr ."  00   18.0    AMD Host Bridge   1022:1630"
  cr
  cr ."  01   xx.x    AMD USB 3.1 xHCI  1022:15E0"
  cr ."  02   00.0    WD SN770 NVMe     varies"
  cr ."  03   xx.x    AMD AHCI SATA     1022:7901"
  cr ."  04   00.0    Realtek RTL8168   10EC:8168"
  cr ."  05   00.x    Realtek ALC256    10EC:0256"
  cr ."  06   00.x    AMD I2C           1022:15E4"
  cr
;

\ --- Scan live ---
: pcie-scan-live
  cr
  cr ." === PCI SCAN LIVE ==="
  cr
  pcie-nicohpgris-liste
  cr
  cr ."  Scan réel du bus PCI..."
  pci-scan
  cr
  cr ."  Détail par index:"
  32 0 do
    i pci-dev
    2 pick u. 0<> if
      cr ."    [" i u. ." ] Bus:" u. ." Dev:" u. ." Func:" u. ." VID:" hex u. decimal ."  DID:" hex u. decimal
    then
  loop
  cr
  cr ." PCI scan OK." cr
;

\ --- Init ---
: pcie-init
  cr
  cr ." --- PCI INIT ---"
  pcie-scan-live
  cr ." PCI init OK." cr
;
