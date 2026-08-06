\ TESTS/net_adv.fth - Reseau avance §5.8 : serveur TCP (1300-1301, 1306,
\ 1310, 1312), sockets UDP (1302-1305), hostname (1320-1321),
\ http:headers (1331), net:mac! (1350), net:gateway@ (1351),
\ net:dhcp-lease (1352).
\ Valeurs attendues en commentaire. Mot : test-net-adv (auto-execute).
\ Conventions : AUCUN appel reseau bloquant (pas de net:ping, net:dns,
\ net:http-get, net:http-post, net:tcp-connect, net:dhcp) - resultats
\ deterministes sans carte reseau. net:accept fait une attente bornee
\ (~100 ms) sur un listener vide puis retourne -1 0 0.

\ ---------- Tests ----------
: test-net-adv
  \ --- net:gateway@ ( -- a b c d ) : 0.0.0.0 par defaut ---
  net:gateway@ . . . .              \ 0 0 0 0

  \ --- net:dhcp-lease ( -- s ) : pas de bail -> 0 ---
  net:dhcp-lease .                  \ 0

  \ --- net:hostname ( buf -- len ) : "epona" par defaut ---
  here 64 0 fill
  here net:hostname dup . constant HN1
  HN1 5 = .                         \ -1 : "epona" (5 octets)
  here c@ .                         \ 0x65 ('e')

  \ --- net:hostname! ( addr len -- ) + relecture ---
  here 0x74 0 c!  here 0x65 1 c!  here 0x73 2 c!  here 0x74 3 c!
  here 4 net:hostname!
  here net:hostname dup . constant HN2
  HN2 4 = .                         \ -1 : "test" (4 octets)
  here c@ .                         \ 0x74 ('t')
  here 0x65 0 c!  here 0x70 1 c!  here 0x6F 2 c!  here 0x6E 3 c!
  here 0x61 4 c!
  here 5 net:hostname!              \ restaure "epona"

  \ --- net:mac! ( lo hi -- ) : aucune verification possible, pas de crash ---
  0x00000012 0x3456 net:mac!

  \ --- net:socket ( type -- sock|-1 ) : 0=UDP, 1=TCP, 2=RAW ---
  0 net:socket dup . constant U0
  U0 0>= .                          \ -1 : socket UDP cree
  1 net:socket .                    \ -1 : TCP non supporte
  2 net:socket .                    \ -1 : RAW non supporte

  \ --- net:bind ( sock port -- ok? ) ---
  U0 5000 net:bind .                \ -1 : bind libre
  U0 5000 net:bind .                \ 0  : port deja pris
  9999 5001 net:bind .              \ 0  : socket invalide

  \ --- net:recv-from ( sock buf max -- n ip port ) : vide -> 0 0 0 ---
  U0 here 128 net:recv-from . . .   \ 0 0 0

  \ --- net:send-to ( sock buf len ip port -- ok? ) ---
  U0 here 0 0 5002 net:send-to .    \ 0  : longueur nulle
  9999 here 4 0 5002 net:send-to .  \ 0  : socket invalide

  \ --- net:listen ( port backlog -- sock|-1 ) ---
  8080 5 net:listen dup . constant LS1
  LS1 0>= .                         \ -1 : listener cree

  \ --- net:sock-status ( sock -- state ) : 1 = listen ---
  LS1 net:sock-status .             \ 1
  9999 net:sock-status .            \ 0  : socket invalide

  \ --- net:accept ( sock -- sock2|-1 ip port ) : aucun client -> -1 0 0 ---
  LS1 net:accept . . .              \ -1 0 0

  \ --- net:tcp-send-async ( sock addr len -- ) : pas de crash ---
  LS1 here 4 net:tcp-send-async     \ listener : pas de donnees envoyees
  9999 here 4 net:tcp-send-async    \ socket invalide

  \ --- net:close-reset ( sock -- ) : listener -> early return, pas de crash ---
  LS1 net:close-reset
  LS1 net:close-reset               \ double close
  9999 net:close-reset              \ invalide

  \ --- http:headers ( addr len -- ) : vide par defaut, pas de crash ---
  here 0 http:headers
  here 0x58 0 c!  here 0x2D 1 c!  here 0x54 2 c!  here 0x65 3 c!
  here 0x73 4 c!  here 0x74 5 c!  here 0x3A 6 c!  here 0x20 7 c!
  here 0x31 8 c!
  here 9 http:headers               \ "X-Test: 1"
  here 0 http:headers

  \ --- http-post : pas de test (requiert reseau), aucun appel ici ---
;
test-net-adv
