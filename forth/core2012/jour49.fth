\ ============================================================================
\ forth/core2012/jour49.fth - Revue semaine 7 (ENVIRONMENT?)
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 49
\ ENVIRONMENT?(435) Core ajoute (dernier Core absent) : reconnait les 12
\ requetes obligatoires ANS 3.2.6 (casse ignoree, chaine lue dans memory,
\ 1 octet/cellule) : /COUNTED-STRING=39, /HOLD=68, /PAD=1024,
\ ADDRESS-UNIT-BITS=64, FLOORED=false, MAX-CHAR=255, MAX-D=i128::MAX,
\ MAX-N=i64::MAX, MAX-U=u64::MAX, MAX-UD=u128::MAX,
\ RETURN-STACK-CELLS=1024, STACK-CELLS=4096 ; toute autre chaine -> false.
\ Section B33 : 14 cas (13 requetes + 1 inconnue).
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour49.fth   (dans qemu_img)
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
\ B33 - requete inconnue -> false (0)
\ ---------------------------------------------------------------------------
s" N'IMPORTE-QUOI" environment?
0 = verif

\ ---------------------------------------------------------------------------
\ B33 - MAX-N = i64::MAX (9223372036854775807)
\ ---------------------------------------------------------------------------
s" max-n" environment?
-1 = verif
9223372036854775807 = verif

\ ---------------------------------------------------------------------------
\ B33 - MAX-U = u64::MAX (-1 en i64)
\ ---------------------------------------------------------------------------
s" MAX-U" environment?
-1 = verif
-1 = verif

\ ---------------------------------------------------------------------------
\ B33 - MAX-CHAR = 255
\ ---------------------------------------------------------------------------
s" MAX-CHAR" environment?
-1 = verif
255 = verif

\ ---------------------------------------------------------------------------
\ B33 - ADDRESS-UNIT-BITS = 64
\ ---------------------------------------------------------------------------
s" ADDRESS-UNIT-BITS" environment?
-1 = verif
64 = verif

\ ---------------------------------------------------------------------------
\ B33 - /COUNTED-STRING = 39
\ ---------------------------------------------------------------------------
s" /counted-string" environment?
-1 = verif
39 = verif

\ ---------------------------------------------------------------------------
\ B33 - /HOLD = 68 (zone PNO)
\ ---------------------------------------------------------------------------
s" /hold" environment?
-1 = verif
68 = verif

\ ---------------------------------------------------------------------------
\ B33 - /PAD = 1024
\ ---------------------------------------------------------------------------
s" /pad" environment?
-1 = verif
1024 = verif

\ ---------------------------------------------------------------------------
\ B33 - FLOORED = false (/, MOD symetriques)
\ ---------------------------------------------------------------------------
s" floored" environment?
-1 = verif
0 = verif

\ ---------------------------------------------------------------------------
\ B33 - STACK-CELLS = 4096 (MAX_STACK)
\ ---------------------------------------------------------------------------
s" stack-cells" environment?
-1 = verif
4096 = verif

\ ---------------------------------------------------------------------------
\ B33 - RETURN-STACK-CELLS = 1024 (MAX_RSTACK)
\ ---------------------------------------------------------------------------
s" return-stack-cells" environment?
-1 = verif
1024 = verif

\ ---------------------------------------------------------------------------
\ B33 - MAX-D = (lo=u64::MAX, hi=i64::MAX), hi au sommet
\ ---------------------------------------------------------------------------
s" max-d" environment?
-1 = verif
9223372036854775807 = verif

\ ---------------------------------------------------------------------------
\ B33 - MAX-UD = (lo=u64::MAX, hi=u64::MAX)
\ ---------------------------------------------------------------------------
s" max-ud" environment?
-1 = verif
-1 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 49
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour49.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
