\ TEST-P1-SORTIE.FTH — Section 3.10 Sortie
cr ." [3.10 Sortie]" cr

variable ok  0 ok !
variable ko  0 ko !
: pass  1 ok +! ."  OK " ;
: fail  1 ko +! ."  FAIL " ;

\ . et u. : affichage visuel + pas de crash
." .        " 42 . pass cr
." u.       " 255 u. pass cr

\ cr, space, spaces : pas de crash
." cr       " pass cr
." space    " pass space cr
." spaces   " pass 3 spaces cr

\ emit : 65 = 'A'
." emit     " 65 emit pass cr

\ type : affiche "OK"
." type     " s" OK" type pass cr

\ .r : 42 en 8 colonnes, aligne a droite
cr ." .r test : 42 8 .r = [" 42 8 .r ." ]" cr

\ u.r : 255 en 8 colonnes, aligne a droite
." u.r test: 255 8 u.r = [" 255 8 u.r ." ]" cr

cr ." Sortie: OK:" ok @ . ." FAIL:" ko @ . cr
