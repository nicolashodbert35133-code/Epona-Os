\ TESTS/as.fth - Espaces d'adressage + memoire partagee (711-713, 718-719, 726-729)
\ Valeurs attendues en commentaire. Mot : test-as (auto-execute en fin de fichier).
\ Prerequis : mem-info (bitmap) puis vm:init (bascule CR3) - comme TESTS/vm.fth.
\ ATTENTION : as:switch bascule CR3 ; le clone contient le map identite complet
\ (deep copy), donc le noyau continue de fonctionner. as:free ne doit JAMAIS
\ etre appele sur l'espace courant. shared:map projette des pages physiques
\ partagees dans l'espace courant (R/W + user).

mem-info . . .                    \ total free used (informations, non testees)
vm:init dup . constant VM-OK      \ -1 si la self-check passe (sinon tables firmware)

\ Constantes POSIX (identiques a heap.fth)
1 constant PROT-READ
2 constant PROT-WRITE
4 constant PROT-EXEC
1 constant MAP-SHARED
2 constant MAP-PRIVATE
16 constant MAP-FIXED
32 constant MAP-ANON

\ ---------- Tests ----------
: test-as
  \ --- vm:info ( -- total free used ) ---
  vm:info dup . constant VUSED    \ imprime <used> ; VUSED = used
  dup . constant VFREE            \ imprime <free>  ; VFREE = free
  . constant VTOT                 \ imprime <total> ; VTOT = total
  VTOT 0<> .                      \ -1 : total jamais 0
  VFREE VUSED + VTOT = .          \ -1 : free + used = total

  \ --- nx-enabled ( -- ? ) : EFER.NXE (depend du firmware) ---
  nx-enabled .                    \ -1 ou 0 (information, non testee)

  \ --- wp-enabled ( -- ? ) : CR0.WP ---
  wp-enabled .                    \ -1 ou 0 (information, non testee)

  \ --- as:new ( -- asid ) : clone l'espace d'adressage courant ---
  as:new dup . constant ASID
  ASID 0<> .                      \ -1 : clone reussi
  ASID cr3@ <> .                  \ -1 : ASID != PML4 courante

  \ --- allocation + ecriture dans l'espace courant (cadres partages) ---
  4 vm:alloc constant VA
  VA 0xABCDEF01 l!  VA l@ .       \ 0xABCDEF01 : ecrit via la VA

  \ --- as:switch ( asid -- ) : bascule CR3 + vidage TLB ---
  ASID as:switch
  ASID cr3@ = .                   \ -1 : CR3 pointe bien sur le clone
  VA vm:virt->phys 0<> .          \ -1 : mapping present dans le clone
  VA l@ .                         \ 0xABCDEF01 : contenu partage accessible

  \ --- retour dans l'espace d'origine ---
  cr3@ constant ORIG
  ORIG as:switch
  ORIG cr3@ = .                   \ -1 : revenu a l'espace initial
  VA l@ .                         \ 0xABCDEF01 : intact

  \ --- as:free ( asid -- ) : libere le clone (pas l'espace courant !) ---
  ASID as:free

  \ --- shared:new ( key size -- id ) ---
  42 4096 shared:new dup . constant SID
  SID 0<> .                       \ -1 : region creee
  42 8192 shared:new SID = .      \ -1 : meme cle -> meme id (idempotent)

  \ --- adresse VMA libre : mmap puis munmap (VA reservee, non mappee) ---
  0 4096 PROT-READ PROT-WRITE OR MAP-PRIVATE MAP-ANON OR -1 0 mmap dup . constant SADDR
  SADDR 4096 munmap .             \ -1 : mapping libere

  \ --- shared:map ( id addr -- ) : map dans l'espace courant ---
  SID SADDR shared:map
  SADDR vm:virt->phys 0<> .       \ -1 : mappee
  0xFEEDFACE SADDR 0 l!  SADDR 0 l@ .   \ 0xFEEDFACE : ecrit/lit via la region partagee

  \ --- shared:map id invalide : sans effet (pas de crash) ---
  999 SADDR 4096 + shared:map
  SADDR 4096 + vm:virt->phys 0= . \ -1 : non mappee

  \ --- shared:destroy ( id -- ok? ) ---
  SID shared:destroy .            \ -1 : liberee
  SID shared:destroy .            \ 0 : id inconnu maintenant

  VA 4 vm:free
;
test-as
