\ ============================================================
\ STDLIB.FTH  —  EponaForth Standard Library
\ ============================================================
\ Mots utilitaires pour tous les programmes Forth.
\ Charger avec :  require STDLIB.FTH
\ ============================================================

\ ─── Constantes ──────────────────────────────────────────────
0 constant false
-1 constant true
32 constant bl
9 constant tab

\ ─── Utilitaires de pile ─────────────────────────────────────
: noop ( -- ) ;

\ ─── Algèbre ─────────────────────────────────────────────────
: max3 ( a b c -- max ) max max ;
: min3 ( a b c -- min ) min min ;
: clamp ( n lo hi -- n' )
  rot min max
;
: within ( n lo hi -- flag )
  >r over < r> swap < and
;
: between ( n lo hi -- flag )
  rot tuck > -rot < and
;

\ ─── Chaînes ─────────────────────────────────────────────────
: bounds ( addr len -- end addr )
  over + swap
;
: /string ( addr len n -- addr' len' )
  >r r@ - swap r> + swap
;

\ ─── Tableaux ────────────────────────────────────────────────
: [] ( addr i -- addr[i] )
  cells +
;
: matrix[] ( addr cols x y -- addr[x+y*cols] )
  rot * + cells +
;
: c[] ( addr i -- addr[i] )
  chars +
;

\ ─── Affichage formaté ──────────────────────────────────────
: 0.r ( n width -- )
  \ Affiche n sur width chiffres avec zéros de remplissage
  >r
  dup abs 0
  begin
    1+ swap 10 / swap over 0=
  until
  drop
  r> rot -
  dup 0> if 0 swap spaces then
  .
;

: hex. ( n -- )
  hex . decimal
;

: ? ( addr -- )
  \ Affiche le contenu d'une cellule mémoire
  dup ." [0x" hex. decimal ." ] = " @ .
;

: ?? ( addr -- )
  \ Affiche le contenu d'une cellule mémoire + word name
  dup ." [0x" hex. ." ] = " @ . cr
;

\ ─── Nombre ↔ Chaîne ────────────────────────────────────────
\ Compté : ( addr len ) sur la pile

create num-buf 20 chars allot

: >number ( addr len -- n flag )
  \ Convertit une chaîne en nombre. flag = -1 si OK, 0 si erreur.
  \ Gère préfixe 0x pour hexadécimal.
  0 >r        \ accumulateur
  0 >r        \ signe
  0 >r        \ base
  over c@
  dup [char] - = if
    1 r> drop 0 >r  \ signe négatif
    1 /string
  else
    drop
  then
  r@ over c@
  dup [char] 0 = if
    drop 1 /string 1 /string
    dup c@ [char] x = if
      1 /string 16 r> drop rot r> swap >r >r
    else
      10 r> drop rot r> swap >r >r
    then
  then
  begin
    dup 0> while
    over c@
    dup [char] 0 [char] 9 between if
      [char] 0 -
    else
      dup [char] a [char] f between if
        [char] a - 10 +
      else
        dup [char] A [char] F between if
          [char] A - 10 +
        else
          0 swap
        then
      then
    then
    dup rot >r
    r> rot >r        \ val
    r> r@ * + r> r> \ accumulateur * base + val
    -rot
    1 /string
    r> swap >r
  repeat
  2drop
  r> drop
  r> if negate then
  r> swap
  -1 \ flag OK
;

: number> ( n -- addr len )
  \ Convertit un nombre en chaîne comptée dans num-buf
  num-buf 20 erase
  num-buf 1+ 19 + \ end
  0 >r  \ compteur
  dup 0< if
    negate
    num-buf c@ 1+ num-buf c!  \ marqueur négatif (sera écrasé)
  then
  begin
    dup 0> while
    10 /mod
    [char] 0 +
    r> 1+ >r
    -rot
  repeat
  drop
  \ Inverser dans num-buf
  num-buf 1+ r@ 1- + ( src )
  num-buf 1+ ( dst )
  r@ 0 ?do
    dup c@ -rot c!
    1- swap 1+ swap
  loop
  2drop
  r> >r
  \ Vérifier signe
  dup 0< if
    num-buf 1+ r@ move
    num-buf 1+ r> 1+ dup >r move
    [char] - num-buf 1+ c!
  then
  num-buf r>
;

\ ─── Virgule fixe → chaîne ──────────────────────────────────
create f-buf 30 chars allot

: f>str ( fix -- addr len )
  \ Convertit un Q20.12 en chaîne dans f-buf
  \ Format : "-123.456"
  f-buf 30 erase
  0 >r  \ index
  dup 0< if
    [char] - f-buf 1+ r@ 1+ + c!
    r> 1+ >r
    negate
  then
  \ Partie entière
  dup 4096 /mod
  \ Partie fractionnaire
  dup 0 ?do
    10 *
    4096 /mod
    swap
  loop
  drop
  \ ... simplification : on utilise number>
  \ Partie entière
  number>
  f-buf 1+ r@ + swap cmove
  r> over + >r
  [char] . f-buf 1+ r@ + c!
  r> 1+ >r
  \ Partie frac (3 chiffres)
  swap 4096 / ( frac en millièmes )
  number>
  drop over + r@ + swap cmove
  r> over + >r
  \ Signe si négatif
  \ Longueur totale
  f-buf 1+ r@
;

\ ─── Date / Heure ───────────────────────────────────────────
create time-buf 30 chars allot

: time>str ( s m h -- addr len )
  \ Format "HH:MM:SS"
  time-buf 30 erase
  0 >r
  h number> drop over r@ + swap cmove r> over + >r
  [char] : time-buf 1+ r@ + c! r> 1+ >r
  m number> drop over r@ + swap cmove r> over + >r
  [char] : time-buf 1+ r@ + c! r> 1+ >r
  s number> drop over r@ + swap cmove r> over + >r
  time-buf 1+ r>
;

: date>str ( j m a -- addr len )
  \ Format "AAAA-MM-JJ"
  time-buf 30 erase
  0 >r
  a number> drop over r@ + swap cmove r> over + >r
  [char] - time-buf 1+ r@ + c! r> 1+ >r
  m 0.r 2 drop over r@ + swap cmove r> over + >r
  [char] - time-buf 1+ r@ + c! r> 1+ >r
  j 0.r 2 drop over r@ + swap cmove r> over + >r
  time-buf 1+ r>
;

\ ─── Itération ──────────────────────────────────────────────
: times ( n -- )
  \ Execute la définition suivante n fois
  0 ?do
    r@ drop
  loop
;

: for ( limit start -- )
  \ Boucle de start à limit-1
  swap over
  ?do
    r@ drop
  loop
;

: map ( addr len -- )
  \ Pour chaque élément du tableau, appelle xt ( addr -- )
  bounds
  ?do
    i @ execute
  cell +loop
;

\ ─── Tableaux dynamiques ────────────────────────────────────
struct array-slot
  field .ptr
  field .len
  field .cap
end-struct

: array:create ( -- addr )
  array-slot buffer: _arr
  _arr
;

: array:push ( val addr -- )
  >r
  r@ .len @ 1+ r@ .cap @ >= if
    \ Agrandir
    r@ .cap @ 2* dup 1 max 16 max
    r@ .cap @ cells here swap cells move
    r@ .cap !
    r@ .ptr @ here !
  then
  r@ .ptr @ r@ .len @ cells + !
  r@ .len @ 1+ r@ .len !
  r>
  drop
;

: array:pop ( addr -- val )
  >r
  r@ .len @ 0= if
    r> drop 0 exit
  then
  r@ .len @ 1- r@ .len !
  r@ .ptr @ r@ .len @ cells + @
  r> drop
;

\ ─── Test de validation ─────────────────────────────────────
\ Décommenter pour tester :
\ cr ." STDLIB.FTH charge" cr
\ cr ." Tests rapides :" cr
\ ." max3: " 10 20 30 max3 . cr
\ ." clamp: " 50 0 100 clamp . cr
\ ." within: " 5 0 10 within . cr
\ ." hex. : " 255 hex. cr
\ 1234 0.r cr
\ s" 255" >number .s cr
\ 42 number> type cr
\ get-time time>str type cr
\ cr ." STDLIB.FTH OK" cr
