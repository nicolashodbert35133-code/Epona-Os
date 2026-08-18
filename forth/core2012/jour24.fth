\ ============================================================================
\ forth/core2012/jour24.fth - Helpers memoire
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 24
\ Helpers ajoutes : read_cell/write_cell (i64) et read_byte/write_byte
\ (octet bas d'une cellule, & 0xFF), bornes par check_mem (Option ->
\ signaler le debordement). @ (10), ! (11), +! (113) migres vers
\ read_cell/write_cell (meme comportement sandbox).
\ Section B10 : valeurs normales + adresses hors bornes
\ (pile et memory inchangees).
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour24.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable m24

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B10 - @ / ! valeurs normales
\ ---------------------------------------------------------------------------
42 m24 !
m24 @ 42 = verif
5 m24 +!
m24 @ 47 = verif
m24 @ here < verif

\ ---------------------------------------------------------------------------
\ B10 - +! sur valeur negative
\ ---------------------------------------------------------------------------
-10 m24 +!
m24 @ 37 = verif

\ ---------------------------------------------------------------------------
\ B10 - ecriture/lecture aux bornes de la fenetre (adresses valides)
\ ---------------------------------------------------------------------------
123 here !
here @ 123 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 24
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour24.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
