\ ============================================================
\ DRIVER_PCI.FTH — Pilote Bus PCI
\ ============================================================
\ Scanne le bus PCI et affiche les peripheriques detectes.
\ Fournit des mots pour acceder a la configuration PCI.
\ ============================================================

cr ." [PCI] Chargement pilote PCI..." cr

variable pci-count   0 pci-count !

: pci-liste ( -- )
    cr ." === Peripheriques PCI ===" cr
    pci-scan pci-count !
    pci-count @ 0= if
        ." (aucun)" cr exit
    then
    pci-count @ 0 do
        i pci-dev
        >r >r >r >r >r >r >r
        dup >r
        ."  " i .
        ."  V" hex r> . decimal
        ." D" hex . decimal
        ."  class=0x" hex . ." s" . decimal
        r> r> r> r> r> r> r>
        drop drop drop
        cr
    loop
;

: pci-bar-info ( bus dev func bar -- addr size flag )
    pci-bar
;

: pci-config-lire ( bus dev func offset -- val )
    pci@
;

: pci-config-ecrire ( val bus dev func offset -- )
    pci!
;

: pci-enable-dma ( bus dev func -- )
    2>r 2>r
    4 pci@
    0x04 or
    2r> 2r>
    4 pci!
;

sys:register pci

cr ." [PCI] Pilote charge. Mots :" cr
."   pci-liste         ( -- )        scanner + afficher" cr
."   pci-bar-info      ( b d f bar -- a s f ) lire BAR" cr
."   pci-config-lire   ( b d f off -- v ) lire registre" cr
."   pci-config-ecrire ( v b d f off -- ) ecrire registre" cr
."   pci-enable-dma    ( b d f -- )  activer DMA" cr
cr
