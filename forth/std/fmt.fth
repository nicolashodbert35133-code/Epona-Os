\ ============================================================================
\ fmt.fth — Formatage et conversion (DEV_GUIDE_DRIVER_AGENT.md §6.3)
\
\ Note : h.2 / h.4 / h.8 (hexadécimal sur largeur fixe) sont fournis par
\ drvlib.fth (§6.1). Ils ne sont PAS redéfinis ici (éviter le shadowing).
\
\ Mémoire : voir drvlib.fth — uniquement `create` (espace `here`), jamais
\ `variable`, pour éviter le chevauchement variables.len() / here.
\ ============================================================================

cr ." [FMT] formatage pret" cr

\ ud. ( n -- ) : affichage non signé (Epona = cellules 64 bits signées)
: ud. ( n -- ) u. ;

\ .0d ( n pad -- ) : décimal avec zéros de tête sur `pad` chiffres
: .0d ( n pad -- ) { n p -- m digits }
    n to m
    1 to digits
    begin
        m 10 / to m
        digits 1+ to digits
        m 0=
    until
    digits 1- to digits
    p digits - dup 0> if
        0 ?do
            s" 0" type
        loop
    else
        drop
    then
    n .
;

\ hex>s ( n -- addr len ) : convertit une valeur en chaîne hexa minuscules
create HEX-BUF 32 allot
: hex>s ( n -- addr len ) { n -- pp dd }
    HEX-BUF 15 + to pp
    begin
        n 0x0f and to dd
        dd 10 < if
            dd 48 + pp !
        else
            dd 87 + pp !
        then
        pp 1- to pp
        n 4 rshift to n
        n 0=
    until
    pp 1+
    HEX-BUF 15 + pp -
;

\ s>hex ( addr len -- n ) : parse une chaîne hexa (0-9, a-f, A-F)
: s>hex ( addr len -- n ) { a l -- n c }
    0 to n
    l 0 ?do
        n 16 * to n
        a i + @ to c
        c 48 >= c 57 <= and if
            c 48 - n + to n
        else
            c 65 >= c 70 <= and if
                c 55 - n + to n
            else
                c 97 >= c 102 <= and if
                    c 87 - n + to n
                then
            then
        then
    loop
    n
;
