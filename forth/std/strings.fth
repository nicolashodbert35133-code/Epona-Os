\ ============================================================================
\ strings.fth — Fonctions chaînes (DEV_GUIDE_DRIVER_AGENT.md §6.4)
\
\ Les chaînes Epona sont des paires ( addr len ), un octet par cellule dans
\ l'espace `here`. strlen / strcpy / strcat travaillent sur des chaînes
\ terminées par une cellule 0.
\
\ Mémoire : voir drvlib.fth — uniquement `create` (espace `here`), jamais
\ `variable`, pour éviter le chevauchement variables.len() / here.
\ ============================================================================

cr ." [STRINGS] utilitaires chaines pret" cr

\ strlen ( addr -- len ) : longueur d'une chaîne terminée par 0
: strlen ( addr -- len ) { a -- n }
    0 to n
    begin
        a n + @ 0<>
    while
        n 1+ to n
    repeat
    n
;

\ strcpy ( src dst -- ) : copie src (jusqu'au 0 inclus) vers dst
: strcpy ( src dst -- ) { s d -- k v }
    0 to k
    begin
        s k + @ to v
        v d k + !
        v 0=
    until
;

\ strcat ( src dst -- ) : concatène src à la fin de dst
: strcat ( src dst -- ) { s d -- k l v }
    d strlen to l
    0 to k
    begin
        s k + @ to v
        v d l + k + !
        v 0=
    until
;

\ streq ( a1 l1 a2 l2 -- flag ) : compare deux paires ( addr len )
: streq ( a1 l1 a2 l2 -- flag ) { a1 l1 a2 l2 -- ok j }
    l1 l2 = if
        true to ok
        l1 0 ?do
            a1 j + @ a2 j + @ <> if
                false to ok
            then
        loop
        ok
    else
        false
    then
;
