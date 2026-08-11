\ ============================================================================
\ forth/core2012/jour13.fth - SOURCE et >IN
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 13
\ SOURCE corrige : la source est copiee UNE seule fois par ligne
\ (set_source, champ source_addr memorise) ; SOURCE retourne
\ ( source_addr len ) sans avancer HERE. >IN : deja une adresse memoire
\ modifiable (to_in_addr = MAX_MEM-1), reset par set_source.
\ Section B4 : `here source 2drop here - .` -> 0 (SOURCE n'avance plus
\ HERE), `s" src-len" evaluate` -> 7 (contenu), `>in 5 ! >in @ .` -> 5.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour13.fth   (dans qemu_img)
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
\ B4 - SOURCE n'avance plus HERE
\ ---------------------------------------------------------------------------
here source 2drop here - 0 = verif

\ ---------------------------------------------------------------------------
\ B4 - SOURCE renvoie le bon contenu (longueur 7 pour "src-len")
\ ---------------------------------------------------------------------------
s" src-len" evaluate
7 = verif

\ ---------------------------------------------------------------------------
\ B4 - >IN reste modifiable
\ ---------------------------------------------------------------------------
>in 5 ! >in @ 5 = verif
>in 0 ! >in @ 0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 13
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour13.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
