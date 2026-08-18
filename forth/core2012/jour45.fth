\ ============================================================================
\ forth/core2012/jour45.fth - WORD
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 45
\ word(408) ( char -- c-addr ) Core : lit la source courante (comme
\ parse-name/parse, pas le clavier) -- skip des delimiteurs initiaux,
\ parse jusqu'au delimiteur final (exclu), copie en chaine comptee
\ (octet 0 = longueur) dans le buffer dedie [130960..131000) (40 cellules,
\ constantes WORD_BASE/WORD_END, duree de vie : ecrasee au prochain
\ appel), avance >IN. Tests B29 en source controlee (evaluate) :
\ longueur, skip espaces initiaux, contenu (1+ c@), deux mots successifs,
\ delimiteur personnalise ':', entree vide (longueur 0).
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour45.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable W1
variable W2

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ helper : WORD espace (32), capture longueur + contenu
: w-cap ( -- ) 32 word dup c@ W1 ! ;
\ helper : WORD ':'
: w-colon ( -- ) 58 word drop 58 word dup c@ W1 ! ;

\ ---------------------------------------------------------------------------
\ B29 - longueur et skip des espaces initiaux (contenu "hello")
\ ---------------------------------------------------------------------------
." [T1]" cr
s" w-cap   hello" evaluate
W1 @ 5 = verif

\ ---------------------------------------------------------------------------
\ B29 - contenu : 1+ c@ = 'h' (104)
\ ---------------------------------------------------------------------------
." [T2]" cr
s" w-cap   hello" evaluate
W1 @ 5 = verif
." [T2b]" cr
: w-h ( -- flag ) 32 word drop 32 word 1+ c@ 104 = ;
." [T2c]" cr
s" w-h hello" evaluate verif

\ ---------------------------------------------------------------------------
\ B29 - deux mots successifs
\ ---------------------------------------------------------------------------
." [T3]" cr
: w-cap2 ( -- ) 32 word dup c@ W1 ! 32 word dup c@ W2 ! ;
." [T3b]" cr
s" w-cap2 hello world" evaluate
." [T3c]" cr
W1 @ 5 = verif
W2 @ 5 = verif

\ ---------------------------------------------------------------------------
\ B29 - delimiteur personnalise ':'
\ ---------------------------------------------------------------------------
." [T4]" cr
s" w-colon ab:cd" evaluate
W1 @ 2 = verif

\ ---------------------------------------------------------------------------
\ B29 - entree vide (delimiteur en premier caractere) -> longueur 0
\ ---------------------------------------------------------------------------
." [T5]" cr
: w-z ( -- ) 32 word drop 32 word dup c@ W1 ! ;
." [T5b]" cr
s" w-z " evaluate
." [T5c]" cr
W1 @ 0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 45
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour45.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
