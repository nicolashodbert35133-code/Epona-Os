\ ============================================================================
\ forth/core2012/jour51.fth - .R, U.R, HOLDS
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 51
\ Les 3 mots Core Ext implementes :
\ - .r (prim 1834) : ( n +n -- ) aligne a droite sur +n colonnes, BASE
\   courante (prefixe 0x en hex comme .), PAS d'espace final, champ etendu
\   au necessaire si largeur insuffisante (pas de troncature).
\ - u.r (prim 1835) : idem non signe (u64).
\ - holds (prim 1836) : ( c-addr u -- ) ajoute la chaine au debut de la
\   chaine picturale PNO (construite vers l'arriere), meme garde de zone
\   que hold/sign, longueur nulle ignoree.
\ Section B35 : affichages .r/u.r documentes + 4 tests holds auto-verifies
\ via compare (!!-42, AB, 12-34 avec hold imbrique, longueur nulle).
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour51.fth   (dans qemu_img)
\
\ PERIMETRE : CORE / CORE EXT + extension Epona marquee (holds).
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
\ B35 - HOLDS "!!-42"
\ ---------------------------------------------------------------------------
-42 dup abs s>d <# #s 45 hold 33 hold 33 hold #> s" !!-42" compare 0 = verif

\ ---------------------------------------------------------------------------
\ B35 - HOLDS "AB"
\ ---------------------------------------------------------------------------
<# 42 s>d #s s" AB" holds #> s" AB42" compare 0 = verif

\ ---------------------------------------------------------------------------
\ B35 - HOLDS + HOLD imbrique "12-34"
\ ---------------------------------------------------------------------------
<# s" 34" holds 45 hold 12 s>d #s #> s" 12-34" compare 0 = verif

\ ---------------------------------------------------------------------------
\ B35 - HOLDS longueur nulle ignoree
\ ---------------------------------------------------------------------------
42 s>d <# s" " holds #s #> s" 42" compare 0 = verif

\ ---------------------------------------------------------------------------
\ B35 - affichages .r / u.r (visuel)
\ ---------------------------------------------------------------------------
cr
42 5 .r ." |" cr
-42 5 .r ." |" cr
0 5 .r ." |" cr
42 2 .r ." | (largeur insuffisante -> etendu)" cr
-7 4 u.r ." |" cr
cr

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 51
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour51.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
