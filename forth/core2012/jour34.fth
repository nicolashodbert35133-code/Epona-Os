\ ============================================================================
\ forth/core2012/jour34.fth - EVALUATE
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 34
\ evaluate (prim 318) et included (prim 862) appelaient self.compile
\ directement -> set_source ecrasait source_buffer/source_addr/>IN/HERE
\ sans sauvegarde. Correctif : helper eval_source (apres set_source)
\ sauvegarde source_buffer/source_addr/>IN/STATE, appelle compile, puis
\ RESTAURE les 4 champs MEME en cas d'erreur. HERE avance a chaque
\ evaluation (limite connue). Section B19 : source_addr restauree,
\ imbrication, definition via evaluate + STATE restaure, source restauree
\ apres erreur.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour34.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable ev-flag

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B19 - evaluation simple
\ ---------------------------------------------------------------------------
s" 1 2 +" evaluate 3 = verif
s" 5 ev-flag !" evaluate
ev-flag @ 5 = verif

\ ---------------------------------------------------------------------------
\ B19 - imbrication
\ ---------------------------------------------------------------------------
: eva 1 ;
: evb eva 2 + ;
s" evb" evaluate 3 = verif

\ ---------------------------------------------------------------------------
\ B19 - definition via evaluate + STATE restaure
\ ---------------------------------------------------------------------------
state @ 0 = verif
s" : evdef 5 ;" evaluate
state @ 0 = verif
evdef 5 = verif

\ ---------------------------------------------------------------------------
\ B19 - source restauree apres erreur de compilation
\ ---------------------------------------------------------------------------
s" : errword" evaluate
state @ 0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 34
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour34.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
