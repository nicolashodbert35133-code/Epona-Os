\ ============================================================================
\ forth/core2012/jour30.fth - CONSTANT et VALUE
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 30
\ constant/value interpretes deja conformes. Manque corrige : value n'avait
\ aucun cas en mode compile -> ajout de Op::ValueCreate (alloue 1 cellule
\ dans HERE, borne MAX_MEM, Word [ValueAddr(addr)]). Sementique : les
\ defining words dans une definition s'executent au runtime -> TO compile
\ exige le value defini a la compilation.
\ Section B16 : constant interprete/compile, value interprete + to,
\ value compile + to compile.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour30.fth   (dans qemu_img)
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
\ B16 - CONSTANT interprete et compile
\ ---------------------------------------------------------------------------
42 constant c30
c30 42 = verif
: c30c c30 ;
c30c 42 = verif

\ ---------------------------------------------------------------------------
\ B16 - VALUE interprete + TO
\ ---------------------------------------------------------------------------
7 value v30
v30 7 = verif
8 to v30
v30 8 = verif

\ ---------------------------------------------------------------------------
\ B16 - VALUE compile + TO compile
\ ---------------------------------------------------------------------------
: v30b v30 ;
v30b 8 = verif
: v30c 9 to v30 ;
v30c
v30 9 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 30
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour30.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
