\ ==============================================================================
\ c-epona/sdk/eponanet.fth - Framework Réseau Sockets & HTTP pour C-Épona
\ ==============================================================================

INCLUDE c-epona/oof.fth

CLASS: Socket
    INT-FIELD: Sock.Fd
    INT-FIELD: Sock.Port
    PTR-FIELD: Sock.Host

: SOCK-CONNECT ( port host-addr obj -- success-flag )
    >R
    R@ Sock.Host !
    R@ Sock.Port !
    \ Binding vers le stack réseau Forth TCP/IP (NET-SOCKET-CONNECT)
    R@ Sock.Host @ R@ Sock.Port @ NET-SOCKET-CONNECT R@ Sock.Fd !
    R@ Sock.Fd @ 0>=
    RDROP
;

: SOCK-SEND ( text-addr len obj -- bytes-sent )
    >R
    SWAP R@ Sock.Fd @ NET-SOCKET-SEND
    RDROP
;

: SOCK-RECV ( buf-addr max-len obj -- bytes-received )
    >R
    SWAP R@ Sock.Fd @ NET-SOCKET-RECV
    RDROP
;

: SOCK-CLOSE ( obj -- )
    >R
    R@ Sock.Fd @ DUP 0>= IF NET-SOCKET-CLOSE THEN
    -1 R@ Sock.Fd !
    RDROP
;
