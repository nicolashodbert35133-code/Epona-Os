\ Test disque AHCI + FAT32
\ Execute avec:  exec TEST-DISK.FTH  ou  sys:load TEST-DISK.FTH

cr ." === TEST DISQUE DUR ===" cr

\ Initialiser AHCI et monter FAT32
disk:init .
cr ." (1 = OK, 0 = echec)" cr

\ Lister la racine
cr ." --- Contenu de / ---" cr
disk:ls /

\ Lister un sous-dossier si present
cr ." --- Contenu de /EFI ---" cr
disk:ls /EFI

cr ." === FIN TEST DISQUE ===" cr
