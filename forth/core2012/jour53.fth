\ ============================================================================
\ forth/core2012/jour53.fth - :NONAME
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 53
\ :NONAME ( -- colon-sys xt ) Core Ext : definition anonyme, retourne un
\ xt utilisable par execute et irq:attach.
\ Tests : appel direct, stockage dans une variable, passage a un vecteur
\ d'IRQ (irq:attach/irq:detach sur IRQ 31 non utilisee, non destructif).
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour53.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable xt53

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ :NONAME - appel direct via execute
\ ---------------------------------------------------------------------------
:NONAME ( -- 42 ) 42 ;
execute 42 = verif

\ ---------------------------------------------------------------------------
\ :NONAME - stockage dans une variable puis execute
\ ---------------------------------------------------------------------------
:NONAME ( x -- x x ) dup ;
xt53 !
5 xt53 @ execute
5 = verif 5 = verif

\ ---------------------------------------------------------------------------
\ :NONAME - un xt reste executable apres d'autres definitions
\ ---------------------------------------------------------------------------
:NONAME ( a b -- a b a ) over ;
xt53 !
: apres53 100 ;
1 2 xt53 @ execute
1 = verif 2 = verif 1 = verif
apres53 100 = verif

\ ---------------------------------------------------------------------------
\ :NONAME - passage a un vecteur d'IRQ (irq:attach / irq:detach)
\ IRQ 31 (non utilisee) : on stocke l'xt puis on le detache. Non destructif.
\ ---------------------------------------------------------------------------
:NONAME ( -- 7 ) 7 ;
dup xt53 !          \ sauvegarde l'xt pour la re-executer apres le detach
31 swap irq:attach  \ ( xt 31 -- ok? )
-1 = verif
31 irq:detach
\ apres detach, l'xt reste utilisable :
xt53 @ execute 7 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 53
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour53.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
