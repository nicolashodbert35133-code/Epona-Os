\ TESTS/gui_widgets.fth - Widgets GUI (1130-1135)
\ Valeurs attendues en commentaire. Mot : test-widgets (auto-exécuté en fin de fichier).
\ Prérequis : aucun (pas d'affichage requis pour ces lectures).
\ Les boîtes modales (dlg:msg/dlg:yesno/dlg:file-open) sont interactives et bloquantes :
\ elles se testent à la main en QEMU, pas ici.

widgets-clear

\ ---------- Tests ----------
: test-widgets
  \ --- label: ( x y color addr len -- ) : texte statique, pas de wid ---
  0 0 0x212121 s" Bonjour" label:
  \ Le widget label a été créé (le prochain wid poussé doit être 1, pas 0)

  \ --- checkbox: ( x y w h label_addr label_len state -- wid ) ---
  10 10 100 16 s" Activer X" -1 checkbox: dup .   \ 1 : wid du 1er checkbox
  constant CB1
  10 30 100 16 s" Activer Y"  0 checkbox: dup .   \ 2 : wid du 2e checkbox
  constant CB2

  \ --- checkbox? ( wid -- state ) : -1 coché / 0 décoché ---
  CB1 checkbox? .   \ -1
  CB2 checkbox? .   \ 0

  \ --- scrollbar: ( x y w h orient -- wid ) : retourne un wid ---
  10 60 160 14 0 scrollbar: dup .   \ 3 : scrollbar horizontal
  constant SBH
  10 80 14 160 1 scrollbar: dup .   \ 4 : scrollbar vertical
  constant SBV

  \ --- scrollbar:pos ( wid -- pos max ) : pos = 0, max = 100 ---
  SBH scrollbar:pos swap . .   \ 0 100   (max pos)
  SBV scrollbar:pos swap . .   \ 0 100

  \ --- vérifications booléennes ---
  SBH scrollbar:pos 100 = .    \ -1 : max = 100 (le sommet est max)
  SBH scrollbar:pos swap 0 = . \ -1 : pos = 0
  SBV scrollbar:pos 100 = .    \ -1 : max = 100

  \ --- widgets-clear : tout est retiré ---
  widgets-clear
  0 widgets-clear   \ idempotent
;

test-widgets
