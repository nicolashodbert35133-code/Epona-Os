\ ============================================================================
\ forth/core2012/jour33.fth - Chaines compilees S"
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 33
\ S" compile copiait la chaine dans memory[HERE] A CHAQUE EXECUTION
\ (derive infinie de HERE en boucle). Correctif : la chaine est copiee
\ UNE fois a la compilation (bornee MAX_MEM avec message) et l'op genere
\ devient Op::PushStrAddr(addr, len) qui pousse (addr, len) SANS avancer
\ HERE. S" interprete (copie ponctuelle standard) et ." compile inchanges.
\ Section B18 : compilation +5, len, addr < here, here inchange apres
\ executions repetees.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour33.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B18 - S" compile : longueur correcte
\ ---------------------------------------------------------------------------
: s33c s" hello" ;
s33c
5 = verif

\ ---------------------------------------------------------------------------
\ B18 - adresse de la chaine < HERE (copiee dans l'espace de donnees)
\ ---------------------------------------------------------------------------
s33c drop here > verif

\ ---------------------------------------------------------------------------
\ B18 - HERE inchange apres executions repetees (la correction)
\ ---------------------------------------------------------------------------
: s33b s" xyz" ;
here s33b 2drop s33b 2drop s33b 2drop s33b 2drop here = verif

\ ---------------------------------------------------------------------------
\ B18 - contenu accessible (octets corrects)
\ ---------------------------------------------------------------------------
s33c drop 0 + c@ 104 = verif
s33c drop 4 + c@ 111 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 33
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour33.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
