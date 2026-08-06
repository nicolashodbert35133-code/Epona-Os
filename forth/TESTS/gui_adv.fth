\ TESTS/gui_adv.fth - GUI avance : reglages souris (1160-1162), themes
\ (1165-1166). Les primitives de configuration sans lecteur sont testees en
\ "vanne" (aucun crash). Valeurs attendues en commentaire.
\ Mot : test-gui-adv (auto-execute).

: test-gui-adv
  \ --- mouse:double-click ( -- ms ) : defaut 400 ---
  mouse:double-click dup . constant DC0
  DC0 400 = .                    \ -1 : valeur par defaut

  \ --- mouse:double-click! ( ms -- ) : arrondi / min 50 ---
  250 mouse:double-click!
  mouse:double-click .           \ 250
  10 mouse:double-click!         \ bornee a 50
  mouse:double-click .           \ 50
  DC0 mouse:double-click!        \ restaure

  \ --- mouse:set-accel ( speed threshold -- ) : 1.0 desactive ---
  1.0 0 mouse:set-accel          \ desactive : aucune erreur

  \ --- mouse:set-accel : acceleration active (bornee a 8) ---
  99.0 4 mouse:set-accel         \ speed > 8 : bornee, sans crash
  4.0 2 mouse:set-accel          \ acceleration x4 au-dela de 2 px

  \ --- theme:set ( thid -- ) : 0 = sombre, 1 = clair ---
  0 theme:set                    \ sombre (defaut), sans crash
  1 theme:set                    \ clair, sans crash
  5 theme:set                    \ inconnu -> tombe sur le defaut, sans crash
  0 theme:set                    \ restaure

  \ --- theme:colors ( fg bg hl btn sel -- ) : sans crash ---
  0x212121 0xFFFFFF 0xBBDEFF 0xE0E0E0 0x1976D2 theme:colors
  0xE0E0E0 0x1E1E2E 0x4444AA 0x333355 0x6666CC theme:colors

  \ --- win/theme avec bordure : fence - fenetre + theme restent valides ---
  mouse:double-click DC0 = .     \ -1 : toujours 400 (restaure)
;
test-gui-adv
