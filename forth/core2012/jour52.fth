\ ============================================================================
\ forth/core2012/jour52.fth - S\", COMPILE,
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 52
\ Conformite 2012 : S" redevient LITTERAL (plus d'unescape_string en
\ compile et en interprete), nouveau mot S\" (string) qui interprete
\ \n \t \r \\ \" (handler compile -> Op::PushStrAddr, handler interprete
\ -> copie en HERE). COMPILE, (compile-only) implemente dans la boucle
\ compile : pop l'xt de la pile, emet Op::CallPrim(prim_idx) pour une
\ primitive ou Op::Call(dict_idx) pour un mot defini (meme pattern que
\ POSTPONE). Bonus : .\" (variante echappee de .") ajoute.
\ Section B36 : S" litteral, S\" interprete, S\" compile + compare,
\ COMPILE, via mots immediats, .\" visuel.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour52.fth   (dans qemu_img)
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
\ B36 - S" LITTERAL : le \ est brut (octet 92), longueur 5
\ ---------------------------------------------------------------------------
s" ab\cd"
5 = verif
s" ab\cd" drop 2 + c@ 92 = verif

\ ---------------------------------------------------------------------------
\ B36 - S\" interprete : \n (10), \t (9), \" (34), \\ (92)
\ ---------------------------------------------------------------------------
s\" a\nb"
3 = verif
s\" a\nb" drop 1 + c@ 10 = verif
s\" x\ty" drop 1 + c@ 9 = verif
s\" a\"b" drop 1 + c@ 34 = verif
s\" a\\b" drop 1 + c@ 92 = verif

\ ---------------------------------------------------------------------------
\ B36 - S" compile (HERE inchange, longueur correcte)
\ ---------------------------------------------------------------------------
: s52c s" hello" ;
s52c 5 = verif
: s52d s" zz" ;
here s52d 2drop s52d 2drop here = verif

\ ---------------------------------------------------------------------------
\ B36 - S\" compile + compare
\ ---------------------------------------------------------------------------
: s52e s\" a\nb" ;
s52e s\" a\nb" compare 0 = verif

\ ---------------------------------------------------------------------------
\ B36 - COMPILE, via xt d'un mot defini
\ ---------------------------------------------------------------------------
: mydup ( x -- x x ) dup ;
: foo-c [ ' mydup ] compile, ;
5 foo-c 5 = verif 5 = verif

\ ---------------------------------------------------------------------------
\ B36 - .\" (variante echappee) visuel
\ ---------------------------------------------------------------------------
cr
.\" .\\\" visuel : tests S\" / COMPILE, OK" cr
cr

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 52
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour52.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
