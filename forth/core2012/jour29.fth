\ ============================================================================
\ forth/core2012/jour29.fth - VARIABLE
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 29
\ Helper create_variable branche sur les 2 sites `variable` (interprete +
\ compile) : alloue 1 cellule dans HERE (init 0, borne MAX_MEM, message,
\ here inchange si echec), cree un mot dictionnaire [Push(addr), Exit]
\ (visible de ' / FIND), garde self.variables (map nom -> addr).
\ Section B15 : here +1, init 0, !/@, adresses distinctes, ' xt valide,
\ coherence avec ,.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour29.fth   (dans qemu_img)
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
\ B15 - VARIABLE : init 0, !/@
\ ---------------------------------------------------------------------------
variable v29
v29 @ 0 = verif
42 v29 !
v29 @ 42 = verif

\ ---------------------------------------------------------------------------
\ B15 - adresses distinctes entre variables
\ ---------------------------------------------------------------------------
variable v29b
v29b @ 0 = verif
v29b v29 <> verif
variable v29c
v29c v29b <> verif
v29c v29 <> verif

\ ---------------------------------------------------------------------------
\ B15 - ' renvoie un xt valide (execute -> adresse de la variable)
\ ---------------------------------------------------------------------------
' v29 execute @ 42 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 29
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour29.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
