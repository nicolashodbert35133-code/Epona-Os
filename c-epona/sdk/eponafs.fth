\ ==============================================================================
\ c-epona/sdk/eponafs.fth - Framework Stockage & Fichiers C-Épona
\ ==============================================================================

INCLUDE c-epona/oof.fth

CLASS: File
    INT-FIELD: File.Handle
    INT-FIELD: File.Size
    PTR-FIELD: File.Path

: FILE-OPEN ( mode-flags path-addr obj -- flag )
    >R
    R@ File.Path !
    \ Binding vers le VFS Forth d'Epona OS (FILE-OPEN-NAT)
    R@ File.Path @ SWAP FILE-OPEN-NAT R@ File.Handle !
    R@ File.Handle @ 0<>
    RDROP
;

: FILE-READ ( buffer-addr max-bytes obj -- bytes-read )
    >R
    SWAP R@ File.Handle @ FILE-READ-NAT
    RDROP
;

: FILE-WRITE ( buffer-addr bytes-count obj -- bytes-written )
    >R
    SWAP R@ File.Handle @ FILE-WRITE-NAT
    RDROP
;

: FILE-CLOSE ( obj -- )
    >R
    R@ File.Handle @ DUP 0<> IF FILE-CLOSE-NAT THEN
    0 R@ File.Handle !
    RDROP
;
