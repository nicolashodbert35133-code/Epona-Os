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
\   B5 - STATE adresse modifiable : VERT depuis Jour 16 (correction STATE)
\   B6 - FIND chaîne comptée : VERT depuis Jour 18 (correction FIND)
\   B7 - PARSE-NAME délimiteurs/>IN/HERE : VERT depuis Jour 19
\   B8 - PARSE champs vides/>IN/HERE : VERT depuis Jour 20
\   J21 (revue S3) : B4/B6/B7/B8 reecrits en SOURCE CONTROLEE (evaluate)
\     car source_buffer = TOUT le fichier (et non la ligne courante) ;
\     B7/B8 testent des-parentheses/espaces via construction manuelle.
\   B9 - CONTRAT D'ADRESSAGE (Jour 23) : cell=1, char=1, cells/chars/aligned
\     identite, cell+/char+ = +1 (1 cellule = 1 unite d'adresse).
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
\   parsing. NB : dans Epona la source = TOUT le fichier charge ; >in est un
\   residu global -> ce test RESTAURE >in=0 en fin de ligne (sinon les tests
\   suivants qui lisent >in partiraient avec une valeur parasite).
\ ---------------------------------------------------------------------------
here source 2drop here - .      \ 0   (SOURCE n'avance plus HERE)
: src-len  source drop . ;
s" src-len" evaluate            \ 7   (contenu : longueur du buffer courant)
>in 5 ! >in @ .  0 >in !         \ 5   (>IN modifiable via ! et @, puis restaure)

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
\ SECTION B5 - STATE : adresse modifiable (Jour 15 : test ecrit AVANT la
\ correction, il doit echouer aujourd'hui et passer apres le Jour 16).
\ state ( -- a-addr ) : la norme exige l'adresse d'une cellule modifiable
\ dont @ donne l'etat (0=interpretation, non-zero=compilation). Aujourd'hui
\ state pousse la VALEUR (0 en interpretation) -> `state 0<>` echoue.
\ Correction (Jour 16) : cellule reservee MAX_MEM-2, source de verite du
\ tokenizer (`state !` change reellement le mode de compilation).
\ NB : la modification est testee DANS une definition compilee (st-set) pour
\ ne pas basculer le tokenizer en plein milieu d'une ligne top-level.
\ ---------------------------------------------------------------------------
state 0<> verif             \ -1 : adresse NON NULLE (avant correction : ECHEC)
state @ 0= verif            \ -1 : en interpretation, @ de l'adresse = 0
: st-set  state 5 ! state @ . 0 state ! ;
st-set                      \ 5 : cellule modifiable via ! (puis restauree)
state @ 0= verif            \ -1 : restauree, toujours en interpretation
\ Modification INDIRECTE : ecrire 1 dans state active reellement le mode
\ compilation (le token `[` qui suit n'est reconnu qu'en compilation), puis
\ `[` nous ramene en interpretation et on restaure 0.
1 state !  [  state @ .  0 state !   \ 0 : bascule compilation OK puis retour

\ ---------------------------------------------------------------------------
\ SECTION B6 - FIND : chaîne comptée (Jour 17 : test ecrit AVANT la
\ correction, il doit echouer aujourd'hui et passer apres le Jour 18).
\ FIND ( c-addr -- c-addr 0 | xt 1 | xt -1 ) : c-addr pointe une CHAINE
\ COMPTEE (l'octet a c-addr est la longueur, le nom suit). Aujourd'hui find
\ a la signature ( addr len -- idx|-1 ) -> 1 seul resultat, pas de flag.
\ On construit la chaine comptee "dup" dans memory[HERE..] (1 octet par
\ cellule, comme les chaines s" a l'execution) :
\   here 4 allot puis longueur=3 et 'd'=100 'u'=117 'p'=112.
\ ---------------------------------------------------------------------------
here 4 allot drop
here 3 !              \ longueur = 3
here 1+ 100 !         \ 'd'
here 2+ 117 !         \ 'u'
here 3+ 112 !         \ 'p'
here find depth 2 = verif 2drop   \ -1 : (xt flag) = 2 elements empiles
here find drop 1 = verif          \ -1 : flag 1 (mot non immediat)
\ Mot ABSENT : chaine comptee "xyz" -> ( c-addr 0 )
here 4 allot drop
here 3 !              \ longueur = 3
here 1+ 120 !         \ 'x'
here 2+ 121 !         \ 'y'
here 3+ 122 !         \ 'z'
here find drop 0 = verif          \ -1 : flag 0 (mot absent)

\ ---------------------------------------------------------------------------
\ SECTION B7 - PARSE-NAME : delimiteurs, >IN, HERE (Jour 19)
\ parse-name ( "<spaces>name" -- c-addr u ) : saute les espaces de debut,
\ parse jusqu'au premier ESPACE, avance >IN. Les ( ) ne sont PAS des
\ delimiteurs (avant Jour 19 : coupaient sur ( et ) et copiaient le nom
\ dans HERE en avançant HERE).
\ NB : la source est controlee via `evaluate` (set_source remet >IN a 0).
\ Dans Epona, source_buffer = TOUT le fichier charge (compile appele une
\ seule fois set_source), et >IN est un residu global -> tester parse-name
\ sur la "ligne courante" serait non deterministe. Revue Jour 21 : tous les
\ tests B7/B8 sont reecrits en source controlee (evaluate).
\ ---------------------------------------------------------------------------
\ 1) Parenthese NON delimiteur : nom "t-px(c" (u=7) avec '(' au milieu.
\    NB : `s"` eclate les parentheses (tokens separes) -> impossible de
\    passer une parenthèse atomique dans une chaine s". On construit la
\    chaine OCTET PAR OCTET dans memory puis on l'execute via `evaluate`
\    (la source de evaluate est le buffer brut, la parenthese y est). 
\    Avant J19 : '(' coupait -> u=4 ("t-px") -> ECHEC.
: t-px ( -- flag ) parse-name nip 7 = ;
here 7 allot drop
here 116 ! here 1+ 45 ! here 2+ 112 ! here 3+ 45 ! here 4+ 120 !
here 5+ 40 ! here 6+ 99 !
here 7 evaluate verif     \ -1
\ 2) Espaces multiples sautes avant le mot : source "   t-pspaces" (3
\    espaces + "t-pspaces" = 9 caracteres). `s"` ne peut pas produire des
\    espaces initiaux (separateurs de tokens) -> construction manuelle.
: t-pspaces ( -- flag ) parse-name nip 9 = ;
here 12 allot drop
here 32 ! here 1+ 32 ! here 2+ 32 !
here 3+ 116 ! here 4+ 45 ! here 5+ 112 ! here 6+ 115 ! here 7+ 112 !
here 8+ 97 ! here 9+ 99 ! here 10+ 101 ! here 11+ 115 !
here 12 evaluate verif     \ -1
\ 3) >IN avance apres le mot ("t-pin" = 5 caracteres).
: t-pin ( -- n ) parse-name 2drop >in @ ;
s" t-pin" evaluate .          \ 5
\ 4) PARSE-NAME n'avance plus HERE : c-addr pointe dans la source.
\    Avant Jour 19 : copie dans HERE -> HERE bouge de 7 -> ECHEC.
: t-phere here parse-name 2drop here - 0 = ;
s" t-phere" evaluate verif    \ -1

\ ---------------------------------------------------------------------------
\ SECTION B8 - PARSE : champs vides, >IN, HERE (Jour 20)
\ parse ( char "ccc<char>" -- c-addr u ) : parse depuis >IN jusqu'au
\ delimiteur char (SANS sauter les delimiteurs initiaux : un delimiteur en
\ premier caractere -> champ VIDE, u=0), c-addr pointe dans la source, et
\ PARSE NE MODIFIE PAS >IN (conformite). Avant Jour 20 : sautait les
\ delimiteurs initiaux, copiait dans HERE et avançait >IN.
\ NB : source controlee via evaluate (cf. section B7).
\ ---------------------------------------------------------------------------
\ 1) Champ vide au debut : source "t-p8" (via evaluate), delimiteur 't'
\    (116). PARSE ne saute pas le 't' initial -> u=0.
\    Avant : sautait le 't' -> u=3 ("-p8") -> ECHEC.
: t-p8 ( -- flag ) 116 parse nip 0 = ;
s" t-p8" evaluate verif        \ -1
\ 2) Parse normal jusqu'a l'espace : "t-p9" = 4 caracteres.
: t-p9 ( -- flag ) 32 parse nip 4 = ;
s" t-p9" evaluate verif        \ -1
\ 3) PARSE ne modifie pas >IN : apres parse de "t-p10" (dans la source
\    evaluee), >IN reste 0. Avant : >IN = 6 -> ECHEC.
: t-p10 ( -- n ) 32 parse 2drop >in @ ;
s" t-p10" evaluate .           \ 0
\ 4) PARSE n'avance plus HERE : c-addr pointe dans la source.
\    Avant Jour 20 : copie dans HERE -> HERE bouge -> ECHEC.
: t-p11 here 32 parse 2drop here - 0 = ;
s" t-p11" evaluate verif       \ -1

\ ---------------------------------------------------------------------------
\ SECTION B9 - CONTRAT D'ADRESSAGE (Jour 23)
\ 1 unite d'adresse = 1 cellule i64 (chars larges permis par Forth 2012).
\ CELL = 1, CHAR = 1 (constantes Forth definies au boot) ; CELLS/CHARS =
\ identite ; CELL+ / CHAR+ = +1 ; ALIGNED = identite.
\ ---------------------------------------------------------------------------
cell .             \ 1   (taille cellule en unites d'adresse)
1 = verif          \ -1
char .             \ 1   (taille char en unites d'adresse)
1 = verif          \ -1
5 cells .          \ 5   (cells = identite, Jour 23)
5 = verif          \ -1
3 chars .          \ 3   (chars = identite)
3 = verif          \ -1
100 cell+ .        \ 101 (cell+ = +1, Jour 23)
101 = verif        \ -1
100 char+ .        \ 101 (char+ = +1)
101 = verif        \ -1
here aligned .     \ = here  (aligned = identite, Jour 23)
here - 0 = verif   \ -1
here 1 cells + .   \ = here+1  (adresse cellule suivante)
here - 1 = verif   \ -1
here 1 cells + cell+ .   \ = here+2
here - 2 = verif   \ -1

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
