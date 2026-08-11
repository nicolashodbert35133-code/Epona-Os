\ ============================================================================
\ forth/core2012/jour27.fth - FILL, CMOVE, MOVE, ERASE
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 27
\ FILL/CMOVE deja migres en J26 (prims 79/80). MOVE (158) / ERASE (159),
\ avant pointeurs natifs bruts, migres en fenetre : addr < MAX_MEM ->
\ self.memory (u cellules, chevauchement gere src<dest arriere / dest<src
\ avant, clamp MAX_MEM) ; sinon -> pointeur natif (heap/mmap conserves).
\ Section B13 : chevauchement 2 sens, longueur nulle, erase partiel.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour27.fth   (dans qemu_img)
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

create src27 4 allot
create dst27 4 allot

\ ---------------------------------------------------------------------------
\ B13 - FILL
\ ---------------------------------------------------------------------------
src27 4 7 fill
src27 c@ 7 = verif
src27 3 + c@ 7 = verif

\ ---------------------------------------------------------------------------
\ B13 - CMOVE (copie, chevauchement gere)
\ ---------------------------------------------------------------------------
dst27 4 0 fill
dst27 4 src27 4 cmove
dst27 c@ 7 = verif
dst27 3 + c@ 7 = verif

\ ---------------------------------------------------------------------------
\ B13 - ERASE partiel (mise a zero des u premieres cellules)
\ ---------------------------------------------------------------------------
dst27 2 0 erase
dst27 c@ 0 = verif
dst27 1 + c@ 0 = verif
dst27 2 + c@ 7 = verif

\ ---------------------------------------------------------------------------
\ B13 - MOVE (chevauchement, longueur non nulle)
\ ---------------------------------------------------------------------------
src27 4 9 fill
dst27 4 0 fill
dst27 4 src27 4 move
dst27 c@ 9 = verif
dst27 3 + c@ 9 = verif

\ ---------------------------------------------------------------------------
\ B13 - longueur nulle : aucun effet
\ ---------------------------------------------------------------------------
src27 0 0 fill
src27 c@ 9 = verif
0 4 src27 0 cmove
src27 c@ 9 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 27
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour27.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
