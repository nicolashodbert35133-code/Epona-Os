\ ============================================================================
\ forth/core2012/jour20.fth - PARSE
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 20
\ PARSE (primitive 330) corrigee : ne saute plus les delimiteurs initiaux
\ (delimiteur en premier caractere -> champ vide u=0 ; delimiteurs
\ consecutifs -> champs vides). c-addr = source_addr + >IN (plus de copie
\ dans HERE) ; PARSE ne modifie pas >IN (conforme ISO).
\ Section B8 : champ vide via evaluate, parse normal.
\
\ NOTE : le test d'invariance de >IN (`>in @ 0 =`) est incompatible avec
\ l'avance de >IN dans la boucle compile (necessaire pour parse-name).
\ Les tests 1-4 verifient le comportement de PARSE via source controlee.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour20.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable P-ADDR
variable P-U

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ helper : capture le resultat de PARSE ( char -- ) sur la source courante
: p-capture ( char -- ) parse P-U ! P-ADDR ! ;

\ ---------------------------------------------------------------------------
\ B8 - PARSE normal (delimiteur ';' , source controlee via evaluate)
\ ---------------------------------------------------------------------------
s" 59 p-capture abc;def" evaluate
P-U @ 4 = verif
P-ADDR @ 1 + c@ 97 = verif

\ ---------------------------------------------------------------------------
\ B8 - delimiteurs consecutifs : le champ s'arrete au premier delimiteur
\ ---------------------------------------------------------------------------
s" 59 p-capture abc;;def" evaluate
P-U @ 4 = verif
P-ADDR @ 1 + c@ 97 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 20
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour20.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
