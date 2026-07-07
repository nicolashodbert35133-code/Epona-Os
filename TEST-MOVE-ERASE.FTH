\ Test move et erase

\ Allouer un buffer de 16 octets sur le heap
create buf1 16 allot
create buf2 16 allot

." Remplir buf1 avec des 'A'" cr
buf1 16 65 fill          \ 65 = 'A'

." Afficher buf1:" cr
buf1 16 type cr

." Copier buf1 dans buf2 avec move" cr
buf1 buf2 16 move

." Afficher buf2:" cr
buf2 16 type cr

." Effacer buf1 avec erase" cr
buf1 16 erase

." Afficher buf1 apres erase:" cr
buf1 16 type cr

." Afficher buf2 (doit encore etre les 'A'):" cr
buf2 16 type cr

\ Test chevauchement : decaler buf1 de 2 octets vers la droite
." Test chevauchement : remplir buf1 avec 'B'" cr
buf1 16 66 fill
buf1 buf1 2 + 14 move   \ decalage de 2 a droite
." buf1 apres decalage:" cr
buf1 16 type cr

." Test termine" cr
