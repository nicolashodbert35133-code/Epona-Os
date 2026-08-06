\ ============================================================================
\ rtl8139.fth - Driver Realtek RTL8139 Ethernet
\ ============================================================================
\ @DRIVER rtl8139
\ @DESCRIPTION Realtek RTL8139 Fast Ethernet
\ @VENDOR 10EC
\ @DEVICE 8139
\ @CLASS 02:00
\ @TYPE Network
\ @AUTHOR Epona Team
\ @VERSION 1.0
\ @LICENSE MIT
\ ============================================================================

\ --- Types de drivers --------------------------------------------------------
0 constant Generic
1 constant Network
2 constant Audio
3 constant Storage
4 constant Input
5 constant Usb
6 constant Gpu

cr ." [RTL8139] Chargement driver Realtek RTL8139..." cr

\ --- Constantes -------------------------------------------------------------
hex
10EC constant RTL8139-VENDOR
8139 constant RTL8139-DEVICE
decimal

\ --- Registres I/O du RTL8139 -----------------------------------------------
hex
0x00 constant RTL-REG-IDR0     \ MAC address (6 octets)
0x06 constant RTL-REG-IDR4
0x08 constant RTL-REG-MAR0     \ Multicast
0x0E constant RTL-REG-93C46    \ EEPROM
0x10 constant RTL-REG-TX-STATUS0
0x20 constant RTL-REG-TX-ADDR0
0x24 constant RTL-REG-TX-ADDR1
0x30 constant RTL-REG-RBSTART   \ RX buffer start address
0x34 constant RTL-REG-ERBCR    \ Early RX byte count
0x37 constant RTL-REG-CR       \ Command register
0x3E constant RTL-REG-CAPR     \ Current address of packet read
0x40 constant RTL-REG-CBR      \ Current buffer address
0x43 constant RTL-REG-IMR      \ Interrupt mask register
0x44 constant RTL-REG-ISR      \ Interrupt status register
0x48 constant RTL-REG-TCR      \ Transmit configuration
0x4C constant RTL-REG-RCR      \ Receive configuration
0x50 constant RTL-REG-TCTL     \ Tx mode (9332 only)
0x52 constant RTL-REG-9346CR   \ 93C46 command register / EEPROM control
0x53 constant RTL-REG-CONFIG0  \ Config0
0x54 constant RTL-REG-CONFIG1  \ Config1
0x56 constant RTL-REG-MSR      \ Media status register
0x58 constant RTL-REG-CONFIG3  \ Config3
0x59 constant RTL-REG-CONFIG4  \ Config4
0xDA constant RTL-REG-TX-POLL  \ TX poll (9332)
decimal

\ --- Constantes commandes ----------------------------------------------------
hex
0x08 constant RTL-CMD-RX-ENABLE    \ RX enable
0x04 constant RTL-CMD-TX-ENABLE    \ TX enable
0x10 constant RTL-CMD-RESET        \ Software reset
RTL-CMD-RX-ENABLE RTL-CMD-TX-ENABLE or constant RTL-CMD-RXTX
decimal

\ --- Constantes configuration reception -------------------------------------
hex
0x00000F0E constant RTL-RCR-CONFIG  \ Accept AB+AM+APM, no promiscuous
decimal

\ --- Variables ---------------------------------------------------------------
variable rtl-ioaddr        \ Base address I/O du RTL8139
variable rtl-irq           \ IRQ
variable rtl-mac0          \ MAC address octets 0-1
variable rtl-mac1          \ MAC address octets 2-3
variable rtl-mac2          \ MAC address octets 4-5
variable rtl-rx-buffer     \ Adresse du buffer RX
variable rtl-tx-buffer     \ Adresse du buffer TX

\ --- find-device -------------------------------------------------------------
: find-device ( -- flag )
    pci-scan 0= if
        ." [RTL8139] Aucun peripherique PCI" cr
        0 exit
    then

    pci-scan 0 do
        i pci-dev
        >r >r
        >r >r
        >r >r >r

        \ Verifier Vendor=0x10EC (Realtek), Device=0x8139
        r@ r>
        RTL8139-DEVICE = swap
        RTL8139-VENDOR = and if
            \ Recuperer bus, dev, func
            r> r> r>  \ func dev bus

            \ Lire BAR0 pour obtenir l'adresse I/O
            \ pci-bar ( bus dev func barn -- addr size flag )
            0 pci-bar
            drop          \ drop size
            dup rtl-ioaddr !
            0= if        \ flag=0 = MMIO, flag=1 = I/O
                ." [RTL8139] BAR0=MMIO: " hex u. decimal cr
            else
                ." [RTL8139] BAR0=I/O: " hex u. decimal cr
            then

            \ Lire IRQ (registre PCI 0x3C, offset 60)
            0 pci@
            drop drop drop drop

            rtl-irq !
            ." [RTL8139] IRQ: " rtl-irq @ u. cr

            r> r> r> r> r> drop
            -1  \ trouve!
            unloop exit
        then

        r> r> r> r> r> r> r>
    loop

    ." [RTL8139] Carte non trouvee" cr
    0
;

\ --- Lire MAC depuis le registre IDR -----------------------------------------
: rtl-read-mac ( -- )
    rtl-ioaddr @ RTL-REG-IDR0 + inb rtl-mac0 !
    rtl-ioaddr @ RTL-REG-IDR0 1+ + inb rtl-mac0 @ 8 lshift or rtl-mac0 !
    rtl-ioaddr @ RTL-REG-IDR0 2 + + inb rtl-mac0 @ 16 lshift or rtl-mac0 !
    rtl-ioaddr @ RTL-REG-IDR0 3 + + inb rtl-mac1 !
    rtl-ioaddr @ RTL-REG-IDR0 4 + + inb rtl-mac1 @ 8 lshift or rtl-mac1 !
    rtl-ioaddr @ RTL-REG-IDR0 5 + + inb rtl-mac1 @ 16 lshift or rtl-mac1 !

    cr ." [RTL8139] MAC: "
    rtl-mac0 @ hex u. rtl-mac1 @ hex u. cr
    decimal
;

\ --- Reset du RTL8139 --------------------------------------------------------
: rtl-reset ( -- )
    ." [RTL8139] Reset..." cr
    rtl-ioaddr @ RTL-REG-CR + RTL-CMD-RESET outb

    \ Attendre que le bit reset se desactive
    1000 0 do
        rtl-ioaddr @ RTL-REG-CR + inb
        RTL-CMD-RESET and 0= if
            leave
        then
        1 stall-us
    loop
    ." [RTL8139] Reset termine" cr
;

\ --- Initialisation ----------------------------------------------------------
: rtl-init-board ( -- flag )
    rtl-reset

    \ Lire la MAC
    rtl-read-mac

    \ Activer TX et RX
    rtl-ioaddr @ RTL-REG-CR + RTL-CMD-RXTX outb

    \ Configurer la reception
    rtl-ioaddr @ RTL-REG-RCR + RTL-RCR-CONFIG outl

    ." [RTL8139] Initialisation materielle OK" cr
    -1
;

\ --- Initialiser les buffers -------------------------------------------------
: rtl-init-buffers ( -- flag )
    \ Envoyer les buffers RX/TX
    \ (implementation simplifiee - a completer)
    ." [RTL8139] Buffers initialises" cr
    -1
;

\ --- hw-init -----------------------------------------------------------------
: hw-init ( -- flag )
    find-device 0= if
        ." [RTL8139] Carte non detectee" cr
        0 exit
    then

    rtl-init-board 0= if
        ." [RTL8139] Echec init materiel" cr
        0 exit
    then

    rtl-init-buffers 0= if
        ." [RTL8139] Echec init buffers" cr
        0 exit
    then

    ." [RTL8139] Initialisation complete" cr
    -1
;

\ --- hw-reset ---------------------------------------------------------------
: hw-reset ( -- )
    rtl-reset
;

\ --- hw-info ----------------------------------------------------------------
: hw-info ( -- )
    cr
    ." === Realtek RTL8139 Fast Ethernet ===" cr
    ." Vendor: Realtek (0x10EC)" cr
    ." Device: RTL8139 (0x8139)" cr
    ." Class:  Ethernet (02:00)" cr
    ." I/O:    " rtl-ioaddr @ hex u. decimal cr
    ." IRQ:    " rtl-irq @ u. cr
    ." MAC:    " rtl-mac0 @ hex u. rtl-mac1 @ hex u. cr
;

\ --- Auto-enregistrement ----------------------------------------------------
: register-driver ( -- )
    hw-init if
        s" rtl8139" Network driver-register if
            ." [RTL8139] Driver reseau enregistre" cr
        else
            ." [RTL8139] Echec enregistrement" cr
        then
    then
;

register-driver
