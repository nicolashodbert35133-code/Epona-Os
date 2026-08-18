\ ============================================================================
\ forth/core2012/jour40.fth - SIGN et sortie numerique
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 40
\ Groupe complet <#(396) #(397) #s(398) hold(399) sign(400) #>(401).
\ Zone "pictured numeric output" memory[131000..131068) construite vers
\ l'arriere, pointeur HOLD dans memory[131068] (init au boot). #/#S lisent
\ BASE au runtime (cur_base()) ; chiffres majuscules. Garde bornes (zone
\ pleine -> message, pas d'ecriture). Section B25 : 0 -> "0", 42,
\ -42 via sign, base 16 "FF", hold "!0", # seul, usage u.40.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour40.fth   (dans qemu_img)
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
\ B25 - 0 -> "0"
\ ---------------------------------------------------------------------------
0 s>d <# #s #> s" 0" compare 0 = verif

\ ---------------------------------------------------------------------------
\ B25 - 42 -> "42"
\ ---------------------------------------------------------------------------
42 s>d <# #s #> s" 42" compare 0 = verif

\ ---------------------------------------------------------------------------
\ B25 - -42 via sign
\ ---------------------------------------------------------------------------
-42 dup abs s>d <# #s rot sign #> s" -42" compare 0 = verif

\ ---------------------------------------------------------------------------
\ B25 - base 16 "FF"
\ ---------------------------------------------------------------------------
hex
FF s>d <# #s #> s" FF" compare 0 = verif
decimal

\ ---------------------------------------------------------------------------
\ B25 - hold "!0"
\ ---------------------------------------------------------------------------
0 s>d <# #s 33 hold #> s" !0" compare 0 = verif

\ ---------------------------------------------------------------------------
\ B25 - # seul (un chiffre)
\ ---------------------------------------------------------------------------
5 s>d <# # #> s" 5" compare 0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 40
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour40.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
