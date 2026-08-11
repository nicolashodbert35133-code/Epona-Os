\ ============================================================================
\ forth/core2012/jour54.fth - Validation CATCH/THROW et POSTPONE
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 54
\ Verifier que ABORT" leve bien -2 THROW ; que CATCH capture correctement
\ et restaure les piles ; que POSTPONE fonctionne sur un mot ordinaire et
\ sur un mot immediat. Documenter les ecarts residuels dans
\ forth_audit_2012.md et le profil EPONA-FORTH2012-CORE-1 si necessaire.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour54.fth   (dans qemu_img)
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
\ CATCH - pas de throw : retourne 0 et empile le resultat de l'xt
\ ---------------------------------------------------------------------------
: ok54 ( -- 7 ) 7 ;
' ok54 catch
0 = verif
7 = verif

\ ---------------------------------------------------------------------------
\ CATCH / THROW : capture la valeur lancee
\ ---------------------------------------------------------------------------
: t54 ( -- ) -2 throw 42 ;
' t54 catch
-2 = verif

\ ---------------------------------------------------------------------------
\ CATCH restaure les piles (data + retour) au snapshot du catch
\ ---------------------------------------------------------------------------
: t54p ( -- ) 1 2 3 42 throw ;
' t54p catch 42 = verif   \ code = 42
depth 1 = verif drop      \ les 3 valeurs poussees ont ete restaurees (snapshot)
: t54s ( -- ) >r 42 throw ;
' t54s catch 42 = verif   \ rstack restauree : execution normale, code capture

\ ---------------------------------------------------------------------------
\ ABORT" leve bien -2 THROW
\ ---------------------------------------------------------------------------
: a54 abort" oops" ;
' a54 catch
-2 = verif

\ ---------------------------------------------------------------------------
\ CATCH - capture d'une valeur quelconque
\ ---------------------------------------------------------------------------
: t54b ( -- ) 99 throw ;
' t54b catch
99 = verif

\ ---------------------------------------------------------------------------
\ POSTPONE sur un mot ordinaire
\ ---------------------------------------------------------------------------
: post-inc ( n -- n+1 ) 1+ ;
: p54 ( n -- n+1 ) postpone post-inc ;
5 p54 6 = verif

\ ---------------------------------------------------------------------------
\ POSTPONE sur un mot immediat (s'execute au runtime)
\ ---------------------------------------------------------------------------
: pr ( -- ) 1 + ;
: q54 postpone pr ;
5 q54 6 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 54
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour54.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
