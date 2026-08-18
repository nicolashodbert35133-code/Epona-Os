\ TESTS/ipc_adv.fth - IPC avance : mutex (1804-1806), canaux (1807-1809),
\ signaux (1810-1813), process (1814-1815, 1817-1818), TLS (1819), FPU
\ (1820-1821), atomic:xchg (1824), cli/sti (1825-1826).
\ Valeurs attendues en commentaire. Mot : test-ipc-adv (auto-execute).
\ Conventions (cf. ipc.fth) : les appels bloquants bornes (mutex conteste,
\ canal plein/vide, waitpid sur processus vivant) ne sont PAS testes ici
\ (a tester manuellement, sinon pompage long).
\ ATTENTION : exit (1814) n'est pas appele dans ce fichier (il arrete la VM).

mem-info . . .                    \ total free used (informations)
vm:init dup . constant VM-OK

\ Constantes POSIX
1 constant PROT-READ
2 constant PROT-WRITE
4 constant PROT-EXEC
1 constant MAP-SHARED
2 constant MAP-PRIVATE
16 constant MAP-FIXED
32 constant MAP-ANON

\ ---------- Tests ----------
: test-ipc-adv
  \ --- mutex:new ( -- mid ) ---
  mutex:new dup . constant MID
  MID 0<> .                        \ -1 : cree

  \ --- mutex:lock/unlock recursif (retour immediat, meme pid) ---
  MID mutex:lock .                 \ -1
  MID mutex:lock .                 \ -1 : recursif (profondeur 2)
  MID mutex:unlock .               \ -1
  MID mutex:unlock .               \ -1
  MID mutex:unlock .               \ 0  : deja libere (profondeur 0)

  \ --- mid invalide ---
  0 mutex:lock .                   \ 0
  0 mutex:unlock .                 \ 0
  9999 mutex:lock .                \ 0

  \ --- mutex:destroy (bonus 1830) ---
  MID mutex:lock .                 \ -1
  MID mutex:destroy .              \ -1
  MID mutex:lock .                 \ 0  : detruit

  \ --- chan:new ( bufsize -- cid ) : 2 slots ---
  2 chan:new dup . constant CID
  CID 0<> .                        \ -1 : cree

  \ --- chan:send ( cid addr len -- ) / chan:recv ( cid addr max -- n ) ---
  here 4 0 fill
  here 0xCA 0 c!  here 0xFE 1 c!
  CID here 2 chan:send             \ envoyer 2 octets (pas de retour)
  CID here 64 chan:recv dup . constant N1
  N1 2 = .                         \ -1 : recu 2 octets
  here c@ .                        \ 0xCA
  here 1 + c@ .                    \ 0xFE

  \ --- canal vide : recv retourne 0 (non bloquant) ---
  CID here 64 chan:recv .          \ 0 : vide -> borne -> 0

  \ --- cid invalides ---
  0 here 64 chan:recv .            \ 0
  0 here 2 chan:send               \ sans effet (pas de retour)
  9999 here 64 chan:recv .         \ 0

  \ --- chan:destroy (bonus 1831) ---
  CID chan:destroy .               \ -1
  CID here 64 chan:recv .          \ 0 : detruit

  \ --- signaux : handler + livraison au point sur ---
  variable sig-hit
  0 sig-hit !
  : on-sig  -1 sig-hit ! ;
  9 on-sig sig:catch .             \ 0   (ancien handler = aucun)
  0 9 signal                        \ depose SIG9
  sig-hit @ .                      \ -1  : handler execute a la fin de la ligne

  \ --- sig:default : plus de handler, signal ignore ---
  sig:default 9 .                  \ <xt on-sig> : ancien handler rendu
  0 9 signal
  sig-hit @ .                      \ -1  : inchange (default ignore)

  \ --- sig:mask : signal masque = ignore ---
  : on-sig2  -2 sig-hit ! ;
  9 on-sig2 sig:catch drop         \ re-enregistre, drop de l'ancien (0)
  0 sig-hit !
  512 sig:mask .                   \ 0   (ancien masque)
  0 9 signal
  sig-hit @ .                      \ 0   : masque, handler PAS execute
  0 sig:mask drop                  \ restaure masque 0 (drop de l'ancien 512)
  0 9 signal
  sig-hit @ .                      \ -2  : non masque -> execute

  \ --- sig:default 9 pour nettoyer ---
  9 sig:default drop

  \ --- tls@ ( -- addr ) : bloc stable par processus ---
  tls@ dup . constant T1
  T1 0<> .                         \ -1 : alloue
  tls@ T1 = .                      \ -1 : meme adresse pour le meme pid

  \ --- fpu:save / fpu:restore (buf 512 octets aligne 16) ---
  0 4096 PROT-READ PROT-WRITE OR MAP-PRIVATE MAP-ANON OR -1 0 mmap dup . constant FBUF
  FBUF 0<> .                       \ -1 : mappe (page = aligne 16)
  FBUF 512 0 fill
  FBUF fpu:save
  FBUF 0 l@ 0<> .                  \ -1 : fxsave a ecrit (fcw/mxcsr != 0)
  FBUF fpu:restore                 \ pas de retour, ne doit pas crasher
  FBUF 4096 munmap .               \ -1 : cleanup

  \ --- atomic:xchg ( addr val -- old ) : LOCK XCHG octet ---
  here 0 c!
  here 42 atomic:xchg .            \ 0   (ancien)
  here c@ .                        \ 42
  here 7 atomic:xchg .             \ 42  (ancien)
  here c@ .                        \ 7
  -1 5 atomic:xchg .               \ 0   (sandbox bloque)

  \ --- kill (1818) : guards ---
  0 kill .                         \ 0   : kernel (PID 0) non tuable
  9999 kill .                      \ 0   : pid inexistant

  \ --- waitpid (1815) sur pid inexistant : -1 immediat ---
  9999 waitpid .                   \ -1

  \ --- spawn (1817) : tache Forth cooperative ---
  : noop  ;                        \ mot trivial
  ' noop spawn dup . constant SPID
  SPID 0 >= .                       \ -1 : cree (tid >= 0)

  \ --- cli / sti : sans crash ---
  cli sti
;
test-ipc-adv
