\ ============================================================================
\ core.fth — Bibliothèque Core Epona (Semaine 9, Jour 57)
\
\ Objectif : mots PURS, utilisables SANS matériel (ni MMIO, ni PCI, ni IRQ,
\ ni framebuffer, ni fichiers). Une application Forth distante peut s'appuyer
\ dessus sans connaître le moindre détail x86_64.
\
\ Liste des mots (voir aussi DEV_GUIDE_DRIVER_AGENT.md §6.6) :
\   Math     : clamp between? even? odd? sgn gcd lcm pow
\   Chaînes  : starts-with ends-with str-find count-char upper lower trim
\   Nombres  : str>num num>str
\
\ Règles :
\ - Mémoire UNIQUEMENT via `create` (espace `here`), jamais `variable`
\   (chevauchement variables.len() / here).
\ - Pas de `exit` dans un mot à `{ locals }` (Op::Exit ne nettoie pas).
\ - Aucun appel à une primitive dangereuse (220+ / 280+ / 720+ / 750+...).
\ - Les chaînes sont des paires ( addr len ), un octet par cellule.
\ ============================================================================

cr ." [CORE] bibliotheque pure pret" cr

\ ────────────────────────────────────────────────────────────────────────────
\ MATHÉMATIQUES
\ ────────────────────────────────────────────────────────────────────────────

\ clamp ( n lo hi -- n' ) : borne n entre lo et hi (inclus)
: clamp ( n lo hi -- n' ) { n lo hi }
    n lo < if
        lo
    else
        n hi > if hi else n then
    then
;

\ between? ( n lo hi -- flag ) : -1 si lo <= n <= hi
: between? ( n lo hi -- flag ) { n lo hi }
    n lo >= n hi <= and
;

\ even? ( n -- flag ) : -1 si n est pair
: even? ( n -- flag ) 2 mod 0= ;

\ odd? ( n -- flag ) : -1 si n est impair
: odd? ( n -- flag ) 2 mod 0<> ;

\ sgn ( n -- -1|0|1 ) : signe de n
: sgn ( n -- n' )
    dup 0< if drop -1 else
    dup 0> if drop 1 else drop 0 then then
;

\ gcd ( a b -- g ) : PGCD (algorithme d'Euclide, entiers >= 0)
: gcd ( a b -- g ) { a b -- t }
    begin
        b 0<>
    while
        b to t
        a b mod to b
        t to a
    repeat
    a
;

\ lcm ( a b -- l ) : PPCM (0 si a ou b vaut 0)
: lcm ( a b -- l ) { a b -- g }
    a b gcd to g
    g 0= if
        0
    else
        a b * g / abs
    then
;

\ pow ( base exp -- result ) : exponentiation entière, exp >= 0
\ (pow 0 0 -- 1 ; exp négatif non géré : retourne 1)
: pow ( base exp -- result ) { b e -- r }
    1 to r
    begin
        e 0>
    while
        b r * to r
        e 1- to e
    repeat
    r
;

\ ────────────────────────────────────────────────────────────────────────────
\ CHAÎNES  ( paires addr len , un octet par cellule dans l'espace here )
\ ────────────────────────────────────────────────────────────────────────────

\ starts-with ( a1 l1 a2 l2 -- flag ) : -1 si a1 commence par a2
: starts-with ( a1 l1 a2 l2 -- flag ) { a1 l1 a2 l2 -- ok }
    l1 l2 < if
        0
    else
        -1 to ok
        l2 0 ?do
            a1 i + @ a2 i + @ <> if
                0 to ok
            then
        loop
        ok
    then
;

\ ends-with ( a1 l1 a2 l2 -- flag ) : -1 si a1 se termine par a2
: ends-with ( a1 l1 a2 l2 -- flag ) { a1 l1 a2 l2 -- ok o }
    l1 l2 < if
        0
    else
        -1 to ok
        l1 l2 - to o
        l2 0 ?do
            a1 o + i + @ a2 i + @ <> if
                0 to ok
            then
        loop
        ok
    then
;

\ str-find ( a1 l1 a2 l2 -- idx|-1 ) : index de la 1re occurrence de a2 dans a1
\ (-1 si absent ; a2 vide → 0)
: str-find ( a1 l1 a2 l2 -- idx|-1 ) { a1 l1 a2 l2 -- pos m k ok }
    -1 to ok
    l1 l2 - 1+ 0 max to m
    0 to pos
    begin
        pos m < ok -1 = and
    while
        true to k
        l2 0 ?do
            a1 pos + i + @ a2 i + @ <> if
                false to k
            then
        loop
        k if
            pos to ok
        then
        pos 1+ to pos
    repeat
    ok
;

\ count-char ( addr len ch -- n ) : nombre d'occurrences de ch dans la chaîne
: count-char ( addr len ch -- n ) { a l c -- n }
    0 to n
    l 0 ?do
        a i + @ c = if
            n 1+ to n
        then
    loop
    n
;

\ upper ( addr len -- ) : met la chaîne en MAJUSCULES (en place)
: upper ( addr len -- ) { a l -- c }
    l 0 ?do
        a i + @ to c
        c 97 >= c 122 <= and if
            c 32 - a i + !
        then
    loop
;

\ lower ( addr len -- ) : met la chaîne en minuscules (en place)
: lower ( addr len -- ) { a l -- c }
    l 0 ?do
        a i + @ to c
        c 65 >= c 90 <= and if
            c 32 + a i + !
        then
    loop
;

\ trim ( addr len -- addr' len' ) : retire les espaces de tête et de queue
\ (ne modifie pas la chaîne ; renvoie une sous-paire)
: trim ( addr len -- addr' len' ) { a l -- n }
    a to n
    begin
        l 0> n @ 32 = and
    while
        n 1+ to n
        l 1- to l
    repeat
    begin
        l 0> n l + 1- @ 32 = and
    while
        l 1- to l
    repeat
    n l
;

\ ────────────────────────────────────────────────────────────────────────────
\ NOMBRES
\ ────────────────────────────────────────────────────────────────────────────

\ str>num ( addr len -- n ok ) : parse un entier décimal signé
\ (ok = -1 si tous les caractères étaient valides, sinon 0)
: str>num ( addr len -- n ok ) { a l -- n ok c }
    0 to n
    -1 to ok
    l 0 ?do
        a i + @ to c
        c 45 = i 0 = and if
            \ signe moins en tête : ignoré ici, appliqué après
        else
            c 48 >= c 57 <= and if
                n 10 * c 48 - + to n
            else
                0 to ok
            then
        then
    loop
    l 0= if
        0 to ok
    then
    ok 0<> if
        a @ 45 = if
            n negate to n
        then
    then
    n ok
;

create NUM-BUF 32 allot   \ buffer de conversion n → chaîne
\ num>str ( n -- addr len ) : convertit n en chaîne décimale signée
\ (buffer statique NUM-BUF : l'appel suivant écrase le précédent)
: num>str ( n -- addr len ) { n -- b a v }
    NUM-BUF 31 + to b
    n 0< if
        n negate to a
    else
        n to a
    then
    begin
        a 10 mod to v
        v 48 + b !
        b 1- to b
        a 10 / to a
        a 0=
    until
    b 1+ to b
    n 0< if
        b 1- to b
        45 b !
    then
    b
    NUM-BUF 32 + b -
;
