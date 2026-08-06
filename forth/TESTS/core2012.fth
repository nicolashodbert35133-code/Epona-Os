\ ============================================================================
\ TESTS/core2012.fth - Tests de base Core Forth 2012
\ Semaine 1, Jour 4.
\
\ FORMAT (convention Epona identique aux autres TESTS/*.fth) :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - la valeur attendue est en commentaire apres le '\'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - les tests '... = verif' comptent les echecs dans NB-FAILS (auto)
\   - mot de test auto-execute en fin de fichier
\   - lancement :  exec TESTS/core2012.fth
\
\ SECTIONS :
\   A - Pile / arithmetique / logique : CONFORMES, vertes
\   B0 - Vrai/Faux (true=-1, false=0) : VERD depuis Jour 8
\   B1 - Comparaisons (flags -1) : VERD depuis Jour 8
\   B2b/B2b2 - 2/ signe + division signee : VERD depuis Jour 9
\   B2 - rshift logique : VERD depuis Jour 10
\   B3 - SEARCH : VERD depuis Jour 11
\   B4 - SOURCE / >IN : VERD depuis Jour 13
\   B2c - -rot, tuck : rouges (a corriger)
\
\ BUGS DECOUVERTS (en plus de l'audit) :
\   -rot (idx 38) a la MEME implementation que rot (idx 9) : -rot est faux
\   tuck (idx 40) copie le bas de pile au lieu de dupliquer le 2e element
\   rshift (idx 72) : CORRIGE Jour 10 (decalage logique ((v as u64) >> n))
\ ============================================================================

variable NB-FAILS

\ verif : verifie que le flag vaut true (-1). Affiche la valeur reelle.
\ Marche aujourd'hui comme apres le correctif flags : '=' renvoie un flag
\ non nul si egal, et IF teste le non-nul.
: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
  then ;

\ ---------------------------------------------------------------------------
\ SECTION A1 - PILE (conforme, verte des aujourd'hui)
\ ---------------------------------------------------------------------------
\ dup ( x -- x x )
42 dup . .   \ 42 42

\ drop ( x -- )
1 2 drop .   \ 1

\ swap ( a b -- b a )
1 2 swap . .   \ 1 2

\ over ( a b -- a b a )
1 2 over . . .   \ 1 2 1

\ rot ( a b c -- b c a )
1 2 3 rot . . .   \ 1 3 2

\ nip ( a b -- b )
1 2 nip .   \ 2

\ 2dup ( a b -- a b a b )
1 2 2dup . . . .   \ 2 1 2 1

\ 2drop ( a b -- )
1 2 2drop   \ (rien)

\ 2swap ( a b c d -- c d a b )
1 2 3 4 2swap . . . .   \ 2 1 4 3

\ 2over ( a b c d -- a b c d a b )
1 2 3 4 2over . . . . . .   \ 2 1 4 3 2 1

\ ?dup ( x -- x | 0 )
0 ?dup .    \ 0
5 ?dup . .  \ 5 5

\ pick ( ... x_n ... x_0 u -- ... x_n ... x_0 x_n )
1 2 3 0 pick . . . .   \ 3 3 2 1   (0 pick = copie du sommet)
1 2 3 1 pick . . . .   \ 2 3 2 1   (1 pick = copie du 2e)

\ ---------------------------------------------------------------------------
\ SECTION A2 - ARITHMETIQUE (conforme, verte des aujourd'hui)
\ ---------------------------------------------------------------------------
20 22 + .        \ 42
42 2 - .         \ 40
6 7 * .          \ 42
42 7 / .         \ 6
42 8 mod .       \ 2
42 8 /mod . .    \ 5 2     (/mod : quotient en sommet, reste dessous)
1 1+ .           \ 2
2 1- .           \ 1
2 2+ .           \ 4
4 2- .           \ 2
3 2* .           \ 6
10 2/ .          \ 5
-5 abs .         \ 5
5 abs .          \ 5
5 negate .       \ -5
3 7 min .        \ 3
3 7 max .        \ 7

\ ---------------------------------------------------------------------------
\ SECTION A3 - LOGIQUE BIT A BIT (conforme, verte des aujourd'hui)
\ ---------------------------------------------------------------------------
12 10 and .      \ 8     (1100 & 1010 = 1000)
12 10 or .       \ 14    (1100 | 1010 = 1110)
12 10 xor .      \ 6     (1100 ^ 1010 = 0110)
0 invert .       \ -1
1 4 lshift .     \ 16
16 2 rshift .    \ 4     (positif : OK meme aujourd'hui)

\ ---------------------------------------------------------------------------
\ SECTION B0 - VRAI / FAUX (Jour 8 : flag vrai = -1, faux = 0)
\ ---------------------------------------------------------------------------
true .        \ -1 : true est tous les bits a 1
false .       \ 0
true 0<> verif   \ -1 : true est non nul
false 0= verif   \ -1 : false est nul
true 0< verif    \ -1 : -1 est negatif

\ ---------------------------------------------------------------------------
\ SECTION B1 - COMPARAISONS (flags en -1 : VERD depuis Jour 8)
\ Corrige Jour 8 : = <> < > <= >= 0= 0<> 0< 0> renvoient -1 (vrai) / 0 (faux).
\ Avant le correctif ils renvoyaient 1 (audit section 84). Les lignes
\ '= verif' sont vertes depuis le correctif ; NB-FAILS doit rester 0.
\ ---------------------------------------------------------------------------
\ =   ( a b -- flag )   vrai = -1
20 22 + 42 = verif   \ -1
42 43 = .            \ 0

\ <>  ( a b -- flag )
1 2 <> verif   \ -1
1 1 <> .       \ 0

\ <   ( a b -- flag )
1 2 < verif   \ -1
2 1 < .       \ 0

\ >   ( a b -- flag )
2 1 > verif   \ -1
1 2 > .       \ 0

\ <=  ( a b -- flag )
1 1 <= verif   \ -1
2 1 <= .       \ 0

\ >=  ( a b -- flag )
1 1 >= verif   \ -1
1 2 >= .       \ 0

\ 0=  ( n -- flag )
0 0= verif   \ -1
1 0= .       \ 0

\ 0<> ( n -- flag )
1 0<> verif   \ -1
0 0<> .       \ 0

\ 0<  ( n -- flag )
-1 0< verif   \ -1
1 0< .        \ 0

\ 0>  ( n -- flag )
1 0> verif   \ -1
-1 0> .      \ 0

\ ---------------------------------------------------------------------------
\ SECTION B2 - RSHIFT LOGIQUE (VERD depuis Jour 10 : ((v as u64) >> n))
\ Corrige Jour 10 : -16 2 rshift = 0x3FFFFFFFFFFFFFFC (avant : -4, decalage
\ arithmetique). Positifs, negatifs, decalage nul, decalage >= 64 (mod 64,
\ meme comportement que SHR x86 / JIT).
\ ---------------------------------------------------------------------------
-16 2 rshift 0x3FFFFFFFFFFFFFFC = verif   \ -1
16 2 rshift .                  \ 4
1 4 rshift .                   \ 0
1 0 rshift .                   \ 1
-1 63 rshift .                 \ 1
-2 1 rshift .                  \ 9223372036854775807
-16 4 rshift .                 \ 1152921504606846975
-16 0 rshift .                 \ -16
123 0 rshift .                 \ 123
-1 64 rshift .                 \ -1   (mod 64 : decalage de 0)
1 65 rshift .                  \ 0    (mod 64 : decalage de 1 -> 1 >> 1 = 0)

\ ---------------------------------------------------------------------------
\ SECTION B2b - 2/ signe (VERD depuis Jour 9 : shift arithmetique >>1)
\ Corrige Jour 9 : -5 2/ = -3 (avant : -2, troncature vers zero).
\ Valeurs limites : MIN (construit via -1 63 lshift), MIN+1, -1, 0, 1,
\ MAX, positif.
\ ---------------------------------------------------------------------------
-5 2/ .                    \ -3
-1 63 lshift 2/ .          \ -4611686018427387904  (MIN >> 1)
-1 63 lshift 1+ 2/ .       \ -4611686018427387904  (MIN+1 >> 1, floor)
-1 2/ .                    \ -1
0 2/ .                     \ 0
1 2/ .                     \ 0
-3 2/ .                    \ -2
9223372036854775807 2/ .   \ 4611686018427387903  (MAX >> 1)
10 2/ .                    \ 5

\ ---------------------------------------------------------------------------
\ SECTION B2b2 - DIVISION SIGNEE / MOD /MOD (VERDE : symetrique ANS, J9)
\ Rust / et % tronquent vers zero, reste = signe du dividende : conforme a
\ la suite CORE ANS/2012. Aucune reecriture necessaire, tests de preuve.
\ ---------------------------------------------------------------------------
-7 3 / .        \ -2
7 -3 / .        \ -2
-7 -3 / .       \ 2
-7 3 mod .      \ -1
7 -3 mod .      \ 1
-7 -3 mod .     \ -1
-7 3 /mod . .   \ -2 -1   (/mod : quotient en sommet, reste dessous)
7 -3 /mod . .   \ -2 1
-14 3 /mod . .  \ -4 -2

\ ---------------------------------------------------------------------------
\ SECTION B3 - SEARCH (VERD depuis Jour 11 : cas chaine vide corrige)
\ search ( addr1 len1 addr2 len2 -- addr3 len3 flag )
\   trouvee  : addr3 = addr1 + position, len3 = len1 - position, flag -1
\   non trouv : addr3 = addr1, len3 = len1, flag 0
\   chaine vide (len2=0) : TOUJOURS trouvee, addr3 = addr1, len3 = len1.
\ ---------------------------------------------------------------------------
variable S1
s" xxxabcd" over S1 ! s" abc" search
verif            \ -1   (flag true)
.                \ 4    (len3 = 7 - 3)
S1 @ 3 + - .     \ 0    (addr3 = addr1 + 3)
s" abcdef" s" abc" search
verif            \ -1
.                \ 6    (trouvee en debut : len3 = 6 - 0)
drop
s" abcdef" s" def" search
verif            \ -1
.                \ 3    (trouvee en fin : len3 = 6 - 3)
drop
s" abcabc" s" bca" search
verif            \ -1
.                \ 5    (premiere occurrence : len3 = 6 - 1)
drop
s" xxxabcd" over S1 ! s" zzz" search
0= verif         \ -1   (flag faux = 0)
.                \ 7    (len3 = len1 inchange)
S1 @ - .         \ 0    (addr3 = addr1)
s" xxxabcd" over S1 ! 0 0 search
verif            \ -1   (sous-chaine vide TOUJOURS trouvee - correction J11)
.                \ 7    (len3 = len1)
S1 @ - .         \ 0    (addr3 = addr1)
s" ab" s" xyzabc" search
0= verif         \ -1   (len2 > len1 : non trouvee)
.                \ 2
drop

\ ---------------------------------------------------------------------------
\ SECTION B4 - SOURCE / >IN (VERD depuis Jour 13)
\ source ( -- addr u ) : retourne le buffer source courant SANS avancer HERE
\   (avant Jour 13 : copiait dans memory et avançait HERE a chaque appel).
\ >in ( -- a-addr ) : adresse (cellule memory) modifiable du pointeur de
\   parsing. Attention : modifier >IN avec une valeur >= offset du token
\   suivant fait sauter ce token (tokenizer) -> valeur modeste ici (5 < 8).
\ ---------------------------------------------------------------------------
here source 2drop here - .      \ 0   (SOURCE n'avance plus HERE)
: src-len  source drop . ;
s" src-len" evaluate            \ 7   (contenu : longueur du buffer courant)
>in 5 ! >in @ .                 \ 5   (>IN modifiable via ! et @)

\ ---------------------------------------------------------------------------
\ SECTION B2c - tuck / -rot (BUGS DECOUVERTS)
\ -rot : la norme veut ( a b c -- c a b ). 1 2 3 -rot = 3 1 2 (sommet 2).
\        Actuellement -rot fait comme rot : 1 2 3 -rot = 2 3 1 (sommet 1).
\ tuck : la norme veut ( a b -- b a b ). 1 2 tuck = 2 1 2 (sommet 2).
\        Actuellement tuck copie le bas de pile : 1 2 tuck = 2 1 1.
\ ---------------------------------------------------------------------------
1 2 3 -rot . . .   \ 2 1 3  (actuellement 1 3 2 - BUG)
1 2 tuck . . .     \ 2 1 2  (actuellement 2 1 1 - BUG)

\ ---------------------------------------------------------------------------
\ RESUME
\ ---------------------------------------------------------------------------
: test-core
  cr
  ." ==========================" cr
  ." core2012.fth - resume" cr
  ." NB-FAILS = " NB-FAILS @ . cr
  NB-FAILS @ 0= if
    ." TOUTES LES CIBLES ATTEINTES" cr
  else
    ." CORRECTIONS RESTANTES" cr
  then
  ." ==========================" cr ;

test-core
