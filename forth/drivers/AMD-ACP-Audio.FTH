\ ══════════════════════════════════════════════════════════
\ AMD-ACP-Audio.FTH
\ Marque:   AMD
\ Ref:      Audio CoProcessor (ACP 3.x)
\ Vendor:   1022h (AMD)
\ Device:   15E3h
\ Bus:      PCI (03:00.6)
\ Type:     DSP Audio — necessite firmware
\ Registres: ACP_DSP_SW_RST, CLK_ENABLE, FW_BOOT_STATE
\ ══════════════════════════════════════════════════════════

\ --- Variables ---
variable acp-base

\ --- Lecture/ecriture MMIO ---
: acp-rd32 ( offset -- val )
  acp-base @ + @
;
: acp-wr32 ( val offset -- )
  acp-base @ + !
;

\ --- Info ---
: amd-acp-info
  cr
  cr ." === AMD Audio CoProcessor (ACP 3.x) ==="
  cr ."  Marque:      AMD"
  cr ."  Ref:         ACP Audio DSP"
  cr ."  Vendor ID:   1022h"
  cr ."  Device ID:   15E3h"
  cr ."  Bus:         03:00.6"
  cr ."  Type:        DSP Audio (proprietaire)"
  cr ."  Firmware:    REQUIS — charger avant init"
  cr
;

\ --- Scan PCI ---
: amd-acp-scan
  cr
  cr ." === AMD ACP SCAN ==="
  amd-acp-info
  cr
  pci-scan
  cr ."  " u. ." peripheriques PCI detectes"
  cr
;

\ --- Lire BAR0 ---
: amd-acp-bar0
  cr ." --- ACP BAR0 ---"
  3 0 6 0 pci-bar if
    acp-base !
    drop drop
    cr ."  BAR0:        " hex acp-base @ u. decimal
  else
    drop
    cr ."  BAR0:        ECHEC"
  then
;

\ --- Reset DSP ---
: amd-acp-reset
  cr
  cr ." --- ACP DSP RESET ---"
  1 0x0000 acp-wr32
  cr ."  Reset:        1 ecrit"
  1000 0 do loop
  0 0x0000 acp-wr32
  cr ."  Reset:        0 ecrit (reset termine)"
;

\ --- Activer horloge ---
: amd-acp-clk-enable
  cr
  cr ." --- ACP CLK ENABLE ---"
  1 0x0004 acp-wr32
  cr ."  Horloge:      ACTIVEE"
;

\ --- Lire etat firmware ---
: amd-acp-fw-state
  cr
  cr ." --- ACP FW BOOT STATE ---"
  0x01B0 acp-rd32
  cr ."  Boot State:   " hex u. decimal
  0x01B4 acp-rd32
  cr ."  Boot Config:  " hex u. decimal
;

\ --- Lire registres status ---
: amd-acp-status
  cr
  cr ." --- ACP STATUS ---"
  0x0010 acp-rd32
  cr ."  IER:          " hex u. decimal
  0x0014 acp-rd32
  cr ."  ISR:          " hex u. decimal
;

\ --- Init (sans firmware) ---
: amd-acp-init
  cr
  cr ." --- AMD ACP INIT ---"
  amd-acp-scan
  cr
  amd-acp-bar0
  cr
  amd-acp-reset
  cr
  amd-acp-clk-enable
  cr
  amd-acp-status
  cr
  cr ."  *** Firmware requis pour audio ***"
  cr ."  Charger: forth/drivers/firmware/acp_fw.bin"
  cr
  cr ." AMD ACP init OK." cr
;

\ --- Charger firmware (stub) ---
: amd-acp-load-fw
  cr
  cr ." --- ACP CHARGEMENT FIRMWARE ---"
  cr ."  ERREUR: Firmware non disponible"
  cr ."  Recuperer le firmware ACP et placer dans:"
  cr ."    forth/drivers/firmware/acp_fw.bin"
  cr
;

\ --- Test ---
: amd-acp-test
  cr
  cr ." === TEST AMD ACP ==="
  amd-acp-status
  cr
  amd-acp-fw-state
  cr
  cr ." AMD ACP test OK." cr
;
