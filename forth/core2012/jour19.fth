\ ============================================================================
\ forth/core2012/jour19.fth - PARSE-NAME
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 19
\ PARSE-NAME (primitive 329) corrigee : delimiteurs = espaces uniquement
\ ( ( / ) ne coupent plus le nom ) ; c-addr = source_addr + start (nom
\ dans le buffer d'entree, plus de copie ni d'avancement de HERE), >IN
\ avance apres le nom. Section B7 : u=11 pour une entree longue, espaces
\ multiples, >IN, HERE inchange.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour19.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable PN-LEN

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ helper : execute parse-name sur la source courante et capture la longueur
: pn-len ( -- ) parse-name nip PN-LEN ! ;

\ ---------------------------------------------------------------------------
\ B7 - PARSE-NAME sur source controlee (evaluate)
\ ---------------------------------------------------------------------------
\ u = 11 pour un nom de 11 caracteres
s" pn-len abcdefghijk" evaluate
PN-LEN @ 11 = verif

\ Espaces multiples ignores
s" pn-len   mnop" evaluate
PN-LEN @ 4 = verif

\ Un seul caractere
s" pn-len x" evaluate
PN-LEN @ 1 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 19
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour19.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
