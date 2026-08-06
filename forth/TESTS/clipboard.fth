\ TESTS/clipboard.fth - Presse-papiers du WM (1150-1152)
\ Valeurs attendues en commentaire. Mot : test-clipboard (auto-execute en fin de fichier).
\ Prerequis : le Window Manager doit etre initialise (init-window).
\ Note : clipboard:get ecrit dans `here` (convention GUI, comme dlg:file-open) ;
\ la relecture se fait via `c@` (memory[], un octet par cellule).

: test-clipboard
  \ --- clipboard:has ( -- ? ) : vide au depart ---
  clipboard:has .                    \ 0

  \ --- clipboard:set ( addr len -- ) puis has ---
  s" Epona OS" clipboard:set
  clipboard:has .                    \ -1

  \ --- clipboard:get ( -- addr len ) ---
  clipboard:get                      \ ( addr len )
  constant CB-LEN                    \ len = 8
  constant CB-ADDR                   \ addr
  CB-LEN 8 = .                       \ -1 : longueur exacte

  \ --- verification octet par octet ---
  CB-ADDR 0 + c@ 69 = .              \ -1 : 'E'
  CB-ADDR 1 + c@ 112 = .             \ -1 : 'p'
  CB-ADDR 4 + c@ 110 = .             \ -1 : 'n'
  CB-ADDR 7 + c@ 115 = .             \ -1 : 's'
  CB-ADDR 7 + c@ 97  = .             \ 0  : coin sûr ('a' != 's')

  \ --- le contenu persiste dans le WM (deuxieme lecture) ---
  clipboard:get drop drop            \ ( addr len ) jete
  clipboard:has .                    \ -1 : toujours present

  \ --- set avec longueur 0 : vide le presse-papiers ---
  0 0 clipboard:set
  clipboard:has .                    \ 0
  clipboard:get . .                  \ 0 0 : plus rien

  \ --- set successif : seul le dernier est garde ---
  s" alpha" clipboard:set
  s" beta" clipboard:set
  clipboard:get                      \ ( addr len )
  dup 4 = .                          \ -1 : len = 4 ("beta")
  swap c@ 98 = .                     \ -1 : premier octet 'b'
  drop

  \ --- octets binaires : 0 et 255 passent tels quels ---
  0 here 0 c! 255 here 1 + c! 7 here 2 + c!
  here 3 clipboard:set
  clipboard:has .                    \ -1
  clipboard:get                      \ ( addr len )
  constant C2-LEN                    \ len = 3
  constant C2-ADDR
  C2-LEN 3 = .                       \ -1 : longueur 3
  C2-ADDR c@ 0 = .                   \ -1 : octet 0
  C2-ADDR 1 + c@ 255 = .             \ -1 : octet 255
  C2-ADDR 2 + c@ 7 = .               \ -1 : octet 7

  \ --- nettoyage ---
  0 0 clipboard:set
  clipboard:has .                    \ 0
;
test-clipboard
