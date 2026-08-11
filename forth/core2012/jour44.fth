\ ============================================================================
\ forth/core2012/jour44.fth - ACCEPT
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 44
\ accept(406) ( c-addr +n1 -- +n2 ) lit <= +n1 chars dans memory[c-addr..]
\ (retourne +n2 sans CR) ; backspace retire, Escape annule (0), longueur
\ max -> ignore (saisie continue jusqu'au CR), entree vide -> 0, bornage
\ sandbox, preemption PIT + emergency_break -> 0. Ajout de
\ touche:inject(407) pour tester/simuler la saisie.
\ Section B28 : injection 'A', entree vide, backspace, longueur max,
\ key/key? + injection. Validation finale INTERACTIVE (clavier QEMU).
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour44.fth   (dans qemu_img)
\   - ATTENTION : test INTERACTIF (clavier QEMU).
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
create tbuf 32 allot

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B28 - ACCEPT : validation interactive (une touche puis Entree)
\ ---------------------------------------------------------------------------
cr
." =================================" cr
." VALIDATION CLAVIER" cr
." Appuie sur la touche 'A' puis Entree" cr
." pour valider le test du fichier : "
tbuf 16 accept
dup . ."  char(s) recu(s)" cr
1 = verif
tbuf c@ 65 = verif

\ ---------------------------------------------------------------------------
\ B28 - key / key? sur le buffer deja rempli
\ ---------------------------------------------------------------------------
key? 0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 44
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour44.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
