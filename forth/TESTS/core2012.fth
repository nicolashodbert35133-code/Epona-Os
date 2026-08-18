\ ============================================================================
\ TESTS/core2012.fth - Suite de tests Core Forth 2012
\
\ CONVENTIONS (identiques aux autres TESTS/*.fth) :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - la valeur attendue est en commentaire apres le '\'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - les tests '... = verif' comptent les echecs dans NB-FAILS (auto)
\   - mot de test auto-execute en fin de fichier
\   - lancement :  exec TESTS/core2012.fth
\
\ PERIMETRE : mots des word sets Forth 2012 CORE / CORE EXT / DOUBLE-NUMBER /
\ EXCEPTION / LOCALS / STRING / FACILITY. Aucun mot non standard n'est
\ utilise dans les tests (les precedents -rot, 2+, 2-, 3+..11+, /pad ont ete
\ retires ; leurs equivalents standard 2 +, rot rot, etc. sont employes).
\
\ EXTENSIONS EPONA (marquees, NON standard) :
\   - B17 : w@ / w! / l@ / l! (fenetre memoire 16/32 bits, absents du Core)
\   - B19 : alloc (reserve u cellules depuis here ; ALLOCATE/FREE/RESIZE du
\     Memory-Allocation word set ne sont pas implementes)
\   - B32 : key? (absent du Core Forth 2012, qui ne definit que key)
\   - B37 : holds (absent de Forth 2012 ; seul hold est standard)
\
\ Aucun AUTRE mot non standard n'est utilise dans les tests : tous les mots
\ appartiennent aux word sets CORE / CORE EXT / DOUBLE-NUMBER / EXCEPTION /
\ LOCALS / STRING / FACILITY de Forth 2012.
\
\ VALIDATION CLAVIER : le test de la section ACCEPT/KEY est INTERACTIF.
\ Une touche du clavier ('A' puis Entree) doit etre appuyee dans QEMU pour
\ valider le test (cf. consignes affichees a l'ecran).
\
\ SECTIONS :
\   01 PILE (dup drop swap over rot nip 2dup 2drop 2swap 2over ?dup pick)
\   02 ARITHMETIQUE (+ - * / mod /mod 1+ 1- 2* 2/ abs negate min max)
\   03 LOGIQUE (and or xor invert lshift rshift)
\   04 FLAGS (true=-1 false=0, = <> < > <= >= 0= 0<> 0< 0>)
\   05 RSHIFT LOGIQUE (decalage logique u64, mod 64)
\   06 2/ SIGNE (decalage arithmetique) et DIVISION / MOD /MOD (symetrique)
\   07 SEARCH (String word set)
\   08 SOURCE / >IN
\   09 TUCK / -ROT (rot rot, equivalent standard de -rot)
\   10 STATE (adresse modifiable d'une cellule)
\   11 FIND (chaine comptee)
\   12 PARSE-NAME (delimiteurs, >IN, HERE)
\   13 PARSE (champs vides, >IN, HERE)
\   14 CONTRAT D'ADRESSAGE (cell=1 char=1 cells/chars/aligned identite)
\   15 MEMOIRE @ ! +! et BORNES
\   16 HERE / ALLOT / , / C,
\   17 FENETRE MEMOIRE C@ C! FILL CMOVE (standard) + W@ W! L@ L! (extension)
\   18 MOVE / ERASE
\   19 ALLOC (extension Epona)
\   20 VARIABLE
\   21 CONSTANT / VALUE / TO
\   22 CREATE / DOES>
\   23 S" COMPILE
\   24 EVALUATE
\   25 LOCAUX { }
\   26 BASE / ALIGN
\   27 2@ / 2!
\   28 U< / S>D
\   29 M* / */MOD / */ / UM* / UM/MOD
\   30 SORTIE NUMERIQUE <# # #S HOLD SIGN #>
\   31 FINALISATION ud. / d. (cas limites)
\   32 KEY / KEY? / ACCEPT (validation clavier interactive)
\   33 WORD
\   34 >NUMBER
\   35 ABORT / ENVIRONMENT? / QUIT / DEPTH
\   36 WITHIN / U> / PAD
\   37 .R / U.R / HOLDS
\   38 S" / S\" / .\" / COMPILE,
\   39 :NONAME
\   40 CATCH / THROW / POSTPONE
\ ============================================================================

variable NB-FAILS

\ verif ( flag -- ) : verifie que le flag vaut true (-1), incremente NB-FAILS
\ sinon. Affiche la valeur reelle. '=' renvoie un flag non nul si egal et IF
\ teste le non-nul.
: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
  then ;

\ ---------------------------------------------------------------------------
\ SECTION 01 - PILE
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
\ SECTION 02 - ARITHMETIQUE
\ ---------------------------------------------------------------------------
20 22 + .        \ 42
42 2 - .         \ 40
6 7 * .          \ 42
42 7 / .         \ 6
42 8 mod .       \ 2
42 8 /mod . .    \ 5 2     (/mod : quotient en sommet, reste dessous)
1 1+ .           \ 2
2 1- .           \ 1
2 2 + .          \ 4
4 2 - .          \ 2
3 2* .           \ 6
10 2/ .          \ 5
-5 abs .         \ 5
5 abs .          \ 5
5 negate .       \ -5
3 7 min .        \ 3
3 7 max .        \ 7

\ ---------------------------------------------------------------------------
\ SECTION 03 - LOGIQUE BIT A BIT
\ ---------------------------------------------------------------------------
12 10 and .      \ 8     (1100 & 1010 = 1000)
12 10 or .       \ 14    (1100 | 1010 = 1110)
12 10 xor .      \ 6     (1100 ^ 1010 = 0110)
0 invert .       \ -1
1 4 lshift .     \ 16
16 2 rshift .    \ 4

\ ---------------------------------------------------------------------------
\ SECTION 04 - FLAGS (vrai = -1, faux = 0)
\ ---------------------------------------------------------------------------
true .        \ -1 : true est tous les bits a 1
false .       \ 0
true 0<> verif   \ -1 : true est non nul
false 0= verif   \ -1 : false est nul
true 0< verif    \ -1 : -1 est negatif

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
\ SECTION 05 - RSHIFT LOGIQUE (decalage logique : (v as u64) >> n)
\ Positifs, negatifs, decalage nul, decalage >= 64 (mod 64, meme
\ comportement que le decalage SHR x86).
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
\ SECTION 06 - 2/ SIGNE (decalage arithmetique) et DIVISION / MOD /MOD
\ ---------------------------------------------------------------------------
\ 2/ : shift arithmetique >>1 (troncature vers -infini). Valeurs limites.
-5 2/ .                    \ -3
-1 63 lshift 2/ .          \ -4611686018427387904  (MIN >> 1)
-1 63 lshift 1+ 2/ .       \ -4611686018427387904  (MIN+1 >> 1, floor)
-1 2/ .                    \ -1
0 2/ .                     \ 0
1 2/ .                     \ 0
-3 2/ .                    \ -2
9223372036854775807 2/ .   \ 4611686018427387903  (MAX >> 1)
10 2/ .                    \ 5

\ / MOD /MOD : symetrique (troncature vers zero, reste du signe du dividende).
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
\ SECTION 07 - SEARCH
\ search ( addr1 len1 addr2 len2 -- addr3 len3 flag )
\   trouvee  : addr3 = addr1 + position, len3 = len1 - position, flag -1
\   non trouvee : addr3 = addr1, len3 = len1, flag 0
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
verif            \ -1   (sous-chaine vide TOUJOURS trouvee)
.                \ 7    (len3 = len1)
S1 @ - .         \ 0    (addr3 = addr1)
s" ab" s" xyzabc" search
0= verif         \ -1   (len2 > len1 : non trouvee)
.                \ 2
drop

\ ---------------------------------------------------------------------------
\ SECTION 08 - SOURCE / >IN
\ source ( -- addr u ) : retourne le buffer source courant SANS avancer HERE.
\ >in ( -- a-addr ) : adresse (cellule memory) modifiable du pointeur de
\ parsing. NB : dans Epona la source = TOUT le fichier charge ; >in est un
\ residu global -> ce test RESTAURE >in=0 en fin de ligne.
\ ---------------------------------------------------------------------------
here source 2drop here - .      \ 0   (SOURCE n'avance plus HERE)
: src-len  source nip . ;
s" src-len" evaluate            \ 7   (contenu : longueur du buffer courant)
5 >in ! >in @ .  0 >in !         \ 5   (>IN modifiable via ! et @, puis restaure)

\ ---------------------------------------------------------------------------
\ SECTION 09 - TUCK / -ROT (rot rot)
\ -rot n'est pas dans Forth 2012 : on utilise son equivalent standard
\ "rot rot" ( ( a b c -- c a b ) ). tuck (6.2.2300) : ( a b -- b a b ).
\ ---------------------------------------------------------------------------
1 2 3 rot rot 2 = verif drop drop   \ -1  (sommet apres -rot (=rot rot) = 2)
1 2 3 rot rot rot rot rot rot 3 = verif drop drop  \ -1  (-rot x3 = identite)
1 2 tuck 2 = verif drop drop     \ -1  (sommet de tuck = 2)
1 2 tuck drop 1 = verif drop     \ -1  (tuck -> (2 1 2), milieu = 1)

\ ---------------------------------------------------------------------------
\ SECTION 10 - STATE : adresse modifiable
\ state ( -- a-addr ) : adresse d'une cellule dont @ donne l'etat
\ (0 = interpretation, non-zero = compilation). La modification est testee
\ DANS une definition compilee (st-set) pour ne pas basculer le tokenizer
\ en plein milieu d'une ligne top-level.
\ ---------------------------------------------------------------------------
state 0<> verif             \ -1 : adresse NON NULLE
state @ 0= verif            \ -1 : en interpretation, @ de l'adresse = 0
: st-set  5 state ! state @ . 0 state ! ;
st-set                      \ 5 : cellule modifiable via ! (puis restauree)
state @ 0= verif            \ -1 : restauree, toujours en interpretation
\ Modification INDIRECTE : ecrire 1 dans state active reellement le mode
\ compilation (le token `[` qui suit n'est reconnu qu'en compilation), puis
\ `[` ramene en interpretation et on restaure 0.
1 state !  [  state @ .  0 state !   \ 0 : bascule compilation OK puis retour

\ ---------------------------------------------------------------------------
\ SECTION 11 - FIND (chaine comptee)
\ find ( c-addr -- c-addr 0 | xt 1 | xt -1 ) : c-addr pointe une CHAINE
\ COMPTEE (l'octet a c-addr est la longueur, le nom suit). On construit la
\ chaine comptee "dup" dans memory[HERE..] (1 octet par cellule) :
\   here 4 allot puis longueur=3 et 'd'=100 'u'=117 'p'=112.
\ ---------------------------------------------------------------------------
here 4 allot drop
here 3 !              \ longueur = 3
here 1+ 100 !         \ 'd'
here 2 + 117 !        \ 'u'
here 3 + 112 !        \ 'p'
here find depth 2 = verif 2drop   \ -1 : (xt flag) = 2 elements empiles
here find drop 1 = verif          \ -1 : flag 1 (mot non immediat)
\ Mot ABSENT : chaine comptee "xyz" -> ( c-addr 0 )
here 4 allot drop
here 3 !              \ longueur = 3
here 1+ 120 !         \ 'x'
here 2 + 121 !        \ 'y'
here 3 + 122 !        \ 'z'
here find drop 0 = verif          \ -1 : flag 0 (mot absent)

\ ---------------------------------------------------------------------------
\ SECTION 12 - PARSE-NAME
\ parse-name ( "<spaces>name" -- c-addr u ) : saute les espaces de debut,
\ parse jusqu'au premier ESPACE, avance >IN. Les ( ) ne sont PAS des
\ delimiteurs. NB : la source est controlee via `evaluate` (set_source remet
\ >IN a 0) ; dans Epona, source_buffer = TOUT le fichier charge et >IN est un
\ residu global.
\ ---------------------------------------------------------------------------
\ 1) Parenthese NON delimiteur : nom "t-px(c" (u=7) avec '(' au milieu.
\    s" eclate les parentheses -> on construit la chaine OCTET PAR OCTET dans
\    memory puis on l'execute via evaluate (la source est le buffer brut).
: t-px ( -- flag ) parse-name nip 7 = ;
here 7 allot drop
here 116 ! here 1+ 45 ! here 2 + 112 ! here 3 + 45 ! here 4 + 120 !
here 5 + 40 ! here 6 + 99 !
here 7 evaluate verif     \ -1
\ 2) Espaces multiples sautes avant le mot : source "   t-pspaces" (3 espaces
\    + "t-pspaces" = 9 caracteres). Construction manuelle.
: t-pspaces ( -- flag ) parse-name nip 9 = ;
here 12 allot drop
here 32 ! here 1+ 32 ! here 2 + 32 !
here 3 + 116 ! here 4 + 45 ! here 5 + 112 ! here 6 + 115 ! here 7 + 112 !
here 8 + 97 ! here 9 + 99 ! here 10 + 101 ! here 11 + 115 !
here 12 evaluate verif     \ -1
\ 3) >IN avance apres le mot ("t-pin" = 5 caracteres).
: t-pin ( -- n ) parse-name 2drop >in @ ;
s" t-pin" evaluate .          \ 5
\ 4) PARSE-NAME n'avance plus HERE : c-addr pointe dans la source.
: t-phere here parse-name 2drop here - 0 = ;
s" t-phere" evaluate verif    \ -1

\ ---------------------------------------------------------------------------
\ SECTION 13 - PARSE
\ parse ( char "ccc<char>" -- c-addr u ) : parse depuis >IN jusqu'au
\ delimiteur char (SANS sauter les delimiteurs initiaux : un delimiteur en
\ premier caractere -> champ VIDE, u=0), c-addr pointe dans la source, et
\ PARSE NE MODIFIE PAS >IN (conformite).
\ ---------------------------------------------------------------------------
\ 1) Champ vide au debut : source "t-p8", delimiteur 't' (116). PARSE ne
\    saute pas le 't' initial -> u=0.
: t-p8 ( -- flag ) 116 parse nip 0 = ;
s" t-p8" evaluate verif        \ -1
\ 2) Parse normal jusqu'a l'espace : "t-p9" = 4 caracteres.
: t-p9 ( -- flag ) 32 parse nip 4 = ;
s" t-p9" evaluate verif        \ -1
\ 3) PARSE ne modifie pas >IN : apres parse de "t-p10", >IN reste 0.
: t-p10 ( -- n ) 32 parse 2drop >in @ ;
s" t-p10" evaluate .           \ 0
\ 4) PARSE n'avance plus HERE : c-addr pointe dans la source.
: t-p11 here 32 parse 2drop here - 0 = ;
s" t-p11" evaluate verif       \ -1

\ ---------------------------------------------------------------------------
\ SECTION 14 - CONTRAT D'ADRESSAGE
\ 1 unite d'adresse = 1 cellule i64 (chars larges permis par Forth 2012).
\ CELL = 1, CHAR = 1 ; CELLS/CHARS = identite ; CELL+ / CHAR+ = +1 ;
\ ALIGNED = identite.
\ ---------------------------------------------------------------------------
cell .             \ 1   (taille cellule en unites d'adresse)
1 = verif          \ -1
char .             \ 1   (taille char en unites d'adresse)
1 = verif          \ -1
5 cells .          \ 5   (cells = identite)
5 = verif          \ -1
3 chars .          \ 3   (chars = identite)
3 = verif          \ -1
100 cell+ .        \ 101 (cell+ = +1)
101 = verif        \ -1
100 char+ .        \ 101 (char+ = +1)
101 = verif        \ -1
here aligned .     \ = here  (aligned = identite)
here - 0 = verif   \ -1
here 1 cells + .   \ = here+1  (adresse cellule suivante)
here - 1 = verif   \ -1
here 1 cells + cell+ .   \ = here+2
here - 2 = verif   \ -1

\ ---------------------------------------------------------------------------
\ SECTION 15 - MEMOIRE @ ! +! et BORNES
\ @ ! +! passent par read_cell/write_cell (bornes check_mem, mem_high).
\ Une adresse hors bornes ne modifie pas la pile ni memory.
\ ---------------------------------------------------------------------------
123 here !          \ ecrit 123 a here ( ! = val addr )
here @ .            \ 123
123 = verif         \ -1
5 here +!           \ +5 ( +! = n addr )
here @ .            \ 128
128 = verif         \ -1
42 100000 @ .       \ 42   (@ hors bornes : rien pousse, 42 reste au sommet)
42 = verif          \ -1
5 100000 !          \ ecriture hors bornes bloquee (message sandbox)
5 100000 +!         \ idem +!
here @ .            \ 128  (memory inchangee apres les tentatives bloquees)
128 = verif         \ -1

\ ---------------------------------------------------------------------------
\ SECTION 16 - HERE / ALLOT / , / C,
\ 1 unite d'adresse = 1 cellule i64 : here/alloc/,( )/c, incrementent de +1.
\ ALLOT negatif recule. Debordement borne (MAX).
\ ---------------------------------------------------------------------------
here aligned swap - 0= verif          \ -1  (ALIGNED = identite)

here 1 allot                       \ reserve 1 cellule
here swap - 1 = verif              \ -1  (ALLOT 1 avance d'1 unite)

here -1 allot                      \ libere 1 cellule
here swap - -1 = verif             \ -1  (ALLOT -1 recule d'1)

here 42 ,                          \ , ecrit 1 cellule (val a here)
here swap - 1 = verif              \ -1  (, avance d'1)
here @ 42 = verif                  \ -1  (la valeur est bien stockee)

here 65 c,                         \ c, ecrit 1 char (1 cellule)
here swap - 1 = verif              \ -1  (c, avance d'1)
here @ 65 = verif                  \ -1  (char stocke dans la cellule)

here 200000 allot                  \ allot geant : bloque (MAX)
here swap - 0= verif               \ -1  (here inchange apres blocage)

\ ---------------------------------------------------------------------------
\ SECTION 17 - FENETRE MEMOIRE
\ c@ c! fill cmove : STANDARDS (Core 6.1.0770/0760, 6.1.1540, String).
\ w@ w! l@ l!   : EXTENSION EPONA (non standard). Pour addr < mem_high :
\ acces a self.memory (1 char/octet par cellule, valeurs masquees 8/16/32
\ bits). Au-dela : MMIO natif (non teste, depend du materiel).
\ ---------------------------------------------------------------------------
\ c! puis c@ : octet stocke dans la cellule
123 here c! here c@ 123 = verif      \ -1
\ masquage 8 bits (c! ne garde que l'octet bas)
256 here c! here c@ 0 = verif        \ -1

\ w! / w@ (extension) : cellule 16 bits
0x1234 here w! here w@ 0x1234 = verif  \ -1
65536 here w! here w@ 0 = verif        \ -1  (masque 16 bits)

\ l! / l@ (extension) : cellule 32 bits
0x12345678 here l! here l@ 0x12345678 = verif  \ -1

\ fill : 4 cellules a 0xAB
here 4 0xAB fill
here c@ 0xAB = verif                  \ -1
here 1 + c@ 0xAB = verif              \ -1

\ cmove : copie 1 cellule de here vers here+1
here 16 ! here 1 + 32 !
here here 1 + 1 cmove
here 1 + @ 16 = verif                 \ -1

\ ---------------------------------------------------------------------------
\ SECTION 18 - MOVE / ERASE
\ move/erase sur addr < mem_high = self.memory (u cellules) ; au-dela :
\ pointeur natif (non teste). Chevauchement gere (src<dest arriere,
\ dest<src avant).
\ ---------------------------------------------------------------------------
\ move : copie u cellules (src < dest, copie arriere)
here 10 ! here 1 + 20 ! here 2 + 30 !
here here 1 + 2 move
here 1 + @ 10 = verif                 \ -1
here 2 + @ 20 = verif                 \ -1

\ move : chevauchement dest < src (copie avant)
here 10 ! here 1 + 20 ! here 2 + 30 ! here 3 + 40 !
here 2 + here 2 move
here @ 30 = verif                     \ -1
here 1 + @ 40 = verif                 \ -1

\ move : longueur nulle (rien ne change)
here 99 ! here 1 + 0 move
here @ 99 = verif                     \ -1

\ erase : efface u cellules
here 3 0xAA fill
here 2 erase
here c@ 0 = verif                     \ -1
here 1 + c@ 0 = verif                 \ -1
here 2 + c@ 0xAA = verif              \ -1

\ erase : longueur nulle (rien ne change)
here 77 ! here 0 erase
here @ 77 = verif                     \ -1

\ ---------------------------------------------------------------------------
\ SECTION 19 - ALLOC (EXTENSION EPONA)
\ alloc ( u -- addr ) : reserve u cellules a partir de here. Le Forth 2012 ne
\ definit que ALLOCATE/FREE/RESIZE (Memory-Allocation), non implementes ici.
\ ---------------------------------------------------------------------------
1000 alloc
here swap - 1000 = verif              \ -1  (delta = taille allouee)

1000 alloc constant BUF               \ BUF = adresse reservee
BUF @ 0 = verif                       \ -1  (cellule initialisee a 0)
123 BUF ! BUF @ 123 = verif           \ -1  (adresse utilisable via @/!)

here constant H-BEFORE
1000000 alloc drop                    \ allocation geante : echec (message)
here H-BEFORE = verif                 \ -1  (here inchange apres l'echec)

\ ---------------------------------------------------------------------------
\ SECTION 20 - VARIABLE
\ variable : alloue 1 cellule dans HERE (init 0), cree un mot dictionnaire
\ [Push(addr),Exit] et l'enregistre dans la map.
\ ---------------------------------------------------------------------------
here constant H15
variable V15
here H15 - 1 = verif                 \ -1  (here avance de 1 cellule)
V15 @ 0 = verif                      \ -1  (cellule initialisee a 0)
42 V15 ! V15 @ 42 = verif            \ -1  (adresse utilisable via @/!)

variable V15B
V15B V15 <> verif                    \ -1  (adresses distinctes)

' V15 0 > verif                      \ -1  (mot au dictionnaire, xt valide)

\ coherence avec , : la donnee suivante vient apres la variable
here constant H15C
99 ,
here H15C - 1 = verif                \ -1  (unite d'adresse coherente)

\ ---------------------------------------------------------------------------
\ SECTION 21 - CONSTANT / VALUE / TO
\ constant : mot [Push(val),Exit], aucune allocation.
\ value : cellule dans HERE + mot [ValueAddr(addr)] ; TO ecrit la cellule.
\ value compile (ValueCreate) : les defining words dans une definition
\ s'executent AU RUNTIME -> TO compile exige le value deja defini a la
\ compilation (definitions separees ci-dessous).
\ ---------------------------------------------------------------------------
42 constant C42
C42 42 = verif                       \ -1  (constante pousse la valeur)

here constant H16
7 value V16
here H16 - 1 = verif                 \ -1  (value alloue 1 cellule dans HERE)
V16 7 = verif                        \ -1  (pousse la valeur stockee)
99 to V16
V16 99 = verif                       \ -1  (TO met a jour la cellule)

\ value compile (ValueCreate au runtime de init16)
: init16  123 value V16C ;
init16
V16C 123 = verif                     \ -1  (value cree en mode compile)

\ to compile (V16C existe a la compilation)
: set16  5 to V16C ;
set16
V16C 5 = verif                       \ -1  (TO compile met a jour)

\ constant compile (ConstantCreate au runtime)
: init16b  777 constant C777 ;
init16b
C777 777 = verif                     \ -1  (constant compile)

\ ---------------------------------------------------------------------------
\ SECTION 22 - CREATE / DOES>
\ create ne reserve PAS : data_addr = here ; la memoire est reservee par ,
\ ou allot apres CREATE. Le body DOES> est insere AVANT l'Exit final. Le
\ body recoit data_addr sur la pile.
\ ---------------------------------------------------------------------------
here constant H17
create X17
here H17 = verif                     \ -1  (create ne reserve pas)
X17 H17 = verif                      \ -1  (X17 pousse data_addr = here)

here constant H17B
create BUF17 5 allot
here H17B - 5 = verif                \ -1  (create 0 + allot 5 = 5 cellules)
BUF17 H17B = verif                   \ -1  (BUF17 = base du buffer)
42 BUF17 ! BUF17 @ 42 = verif        \ -1  (ecriture/lecture dans le buffer)
7 BUF17 1 + ! BUF17 1 + @ 7 = verif  \ -1  (2e cellule)

\ defining word standard : CREATE , DOES> @  (pattern "constante")
: my-const  create , does> @ ;
11 my-const ELEVEN
ELEVEN 11 = verif                    \ -1  (body does> lit la valeur stockee)

\ body qui consomme data_addr puis ajoute : DOES> @ 10 +
: plus-data  create , 2 allot does> @ 10 + ;
5 plus-data PD
PD 15 = verif                        \ -1  (5 stocke ; body : @ puis +10)

\ create compile (CreateWord au runtime de make-buf)
: make-buf  create 3 allot ;
make-buf CB17
here CB17 - 3 = verif                \ -1  (CreateWord : 3 cellules reservees)

\ ---------------------------------------------------------------------------
\ SECTION 23 - CHAINES COMPILEES S"
\ S" compile copie la chaine UNE FOIS dans memory[here] (donnees compilees,
\ comme ,/allot) ; le runtime pousse (addr, len) sans avancer HERE.
\ ---------------------------------------------------------------------------
here constant H18
: hi18  s" hello" ;
here H18 5 + = verif                 \ -1  (compilation copie la chaine, +5)
hi18 drop 5 = verif                  \ -1  (pousse len = 5)
hi18 drop here < verif               \ -1  (addr dans l'espace de donnees)
hi18 2drop hi18 2drop hi18 2drop
here H18 5 + = verif                 \ -1  (executions n'avancent PAS HERE)
: hi18b  s" xyz" ;
hi18b drop 3 = verif                 \ -1  (2e chaine, len = 3)

\ ---------------------------------------------------------------------------
\ SECTION 24 - EVALUATE
\ EVALUATE sauvegarde/restaure l'etat d'entree (source_buffer, source_addr,
\ >IN, STATE) via eval_source -> evaluation imbriquee OK, source externe
\ conservee meme en cas d'erreur. HERE avance a chaque evaluation
\ (set_source copie la source) : limite connue, source non recyclee.
\ ---------------------------------------------------------------------------
source drop constant SAB             \ adresse de la source avant evaluate
s" 5" evaluate                       \ evalue "5" -> pousse 5
5 = verif                            \ -1  (resultat de l'evaluation)
source drop SAB = verif              \ -1  (source_addr restauree)

\ evaluation imbriquee / resultats empiles
: evA  s" 40 2" evaluate ;
evA + 42 = verif                     \ -1  (40 + 2)
: evB  s" 5 6" evaluate  s" 7" evaluate ;
evB + + 18 = verif                   \ -1  (5 + 6 + 7)

\ definition via evaluate + STATE restaure
state @ 0= verif                     \ -1  (interprete avant)
s" : defT19 99 ;" evaluate
state @ 0= verif                     \ -1  (STATE restaure apres evaluate)
defT19 99 = verif                    \ -1  (le mot defini existe)

\ erreur de compilation : la source doit etre restauree quand meme
source drop constant SAC
s" unknownword19" evaluate           \ eerr mot inconnu (gere)
source drop SAC = verif              \ -1  (source restauree apres erreur)

\ ---------------------------------------------------------------------------
\ SECTION 25 - LOCAUX { }
\ LocalGet/LocalSet/LocalsAlloc/LocalsFree (Locals word set).
\ ---------------------------------------------------------------------------
: add20  { x y } x y + ;
3 4 add20 7 = verif                  \ -1  (x=3, y=4, x+y=7)
: swap20  { a b } b a ;
10 20 swap20 10 = verif 20 = verif   \ -1 -1  (b a = (20 10))
: dup20  { v } v v ;
7 dup20 + 14 = verif                 \ -1  (v v -> 7 +7=14)

\ ---------------------------------------------------------------------------
\ SECTION 26 - BASE / ALIGN
\ BASE = cellule adressable, lue par le parsing et l'affichage (cur_base).
\ HEX/DECIMAL ecrivent la cellule. ALIGN : 1 AU = 1 cellule -> no-op.
\ ---------------------------------------------------------------------------
base @ 10 = verif                    \ -1  (base par defaut = decimal)
hex base @ decimal 16 = verif        \ -1  (hex met BASE = 16)
decimal base @ 10 = verif            \ -1  (decimal remet BASE = 10)
hex ff decimal 255 = verif           \ -1  (ff parse en base 16 = 255)
16 base ! base @ decimal 16 = verif  \ -1  (BASE modifiable)
2 base ! 101 decimal 5 = verif       \ -1  (101 parse en base 2 = 5)

here align here = verif              \ -1  (align : no-op, 1 AU = 1 cellule)
here constant HAL
3 allot align
here HAL - 3 = verif                 \ -1  (align ne change pas here)

\ ---------------------------------------------------------------------------
\ SECTION 27 - 2@ / 2!
\ Ordre des cellules (Forth 2012) : la paire x1 x2 est stockee avec x2 a
\ addr et x1 a addr+1 (cellule basse a addr, haute a addr+1). Bornes via
\ read_cell/write_cell.
\ ---------------------------------------------------------------------------
create DBL37 2 allot
1 2 DBL37 2!
DBL37 2@ 2 = verif 1 = verif         \ -1 -1  (2@ rend ( x1 x2 ))

\ ordre des cellules : x2 a addr, x1 a addr+1
5 7 DBL37 2!
DBL37 @ 7 = verif                    \ -1  (memory[addr] = x2)
DBL37 1 + @ 5 = verif                \ -1  (memory[addr+1] = x1)

\ negatifs et zero
-3 0 DBL37 2!
DBL37 2@ 0 = verif -3 = verif        \ -1 -1  (paire ( -3 0 ))

\ bornes : hors bornes sans effet
here constant HG37
HG37 @ 0 = verif                     \ -1  (cellule libre = 0 avant)
1 2 70000 2!
HG37 @ 0 = verif                     \ -1  (2! hors bornes n'a rien ecrit)
55 70000 2@ 55 = verif               \ -1  (2@ hors bornes ne pousse rien)

\ ---------------------------------------------------------------------------
\ SECTION 28 - U< / S>D
\ U< : comparaison NON SIGNEE (u64) ; flag -1/0. S>D : extension de signe
\ n -> ( n, 0|-1 ) ; hi = 0 si n>=0, -1 sinon.
\ ---------------------------------------------------------------------------
\ U< : limites signees/non signees
0 0 u< 0= verif                      \ -1  (0 < 0 faux)
0 1 u< verif                         \ -1  (0 < 1 vrai)
1 0 u< 0= verif                      \ -1  (1 < 0 faux)
0 -1 u< verif                        \ -1  (0 < 0xFFFF... : -1 non signe = max)
-1 0 u< 0= verif                     \ -1  (max < 0 faux)
-1 -1 u< 0= verif                    \ -1  (max < max faux)
\ contraste signe / non signe
-1 0 < verif                         \ -1  (signe : -1 < 0 vrai)
-1 0 u< 0= verif                     \ -1  (non signe : max < 0 faux)

\ S>D : extension de signe
0 s>d 0 = verif 0 = verif            \ -1 -1  (0 -> ( 0 0 ))
42 s>d 0 = verif 42 = verif          \ -1 -1  (42 -> ( 42 0 ))
-1 s>d -1 = verif -1 = verif         \ -1 -1  (-1 -> ( -1 -1 ))
-5 s>d -1 = verif -5 = verif         \ -1 -1  (-5 -> ( -5 -1 ))

\ aller-retour avec 2!/2@
42 s>d DBL37 2! DBL37 2@ 0 = verif 42 = verif
-7 s>d DBL37 2! DBL37 2@ -1 = verif -7 = verif

\ ---------------------------------------------------------------------------
\ SECTION 29 - M* / */MOD / */ / UM* / UM/MOD
\ Intermediaire double cellule en i128/u128. Division symetrique
\ (troncature, comme /). Diviseur nul / quotient hors limites -> ( 0 0 ).
\ ---------------------------------------------------------------------------
\ M* : produit signe double
2 3 m* 0 = verif 6 = verif           \ -1 -1  (6 -> ( 6 0 ))
-2 3 m* -1 = verif -6 = verif        \ -1 -1  (-6 -> ( -6 -1 ))
hex 100000000 100000000 decimal m* 1 = verif 0 = verif  \ 2^64 -> ( 0 1 )

\ */MOD : d = n1*n2 (i128), n4 = reste, n5 = quotient
10 20 4 */mod 50 = verif 0 = verif   \ -1 -1  (200/4 = 50 r0)
7 3 4 */mod 5 = verif 1 = verif      \ -1 -1  (21/4 = 5 r1)
-10 3 3 */mod -10 = verif 0 = verif  \ -1 -1  (-30/3 = -10 r0)
-7 5 2 */mod -17 = verif -1 = verif  \ -1 -1  (-35/2 = -17 r-1)

\ */MOD : diviseur nul et quotient hors limites -> ( 0 0 ) + message
1 2 0 */mod 0 = verif 0 = verif      \ -1 -1  (diviseur nul)
hex 4000000000000000 2 1 */mod decimal 0 = verif 0 = verif  \ 2^63 hors i64

\ */ : intermediaire > i64 sans overflow
4611686018427387904 4 4 */ 4611686018427387904 = verif   \ 2^62 *4 /4 = 2^62
10 4 2 */ 20 = verif                 \ -1  (cas simple)

\ UM* : hi non nul pour grandes valeurs
3 4 um* 0 = verif 12 = verif         \ -1 -1  (12 -> ( 12 0 ))
hex 100000000 100000000 decimal um* 1 = verif 0 = verif  \ 2^64 -> ( 0 1 )

\ UM/MOD : double cellule 64 bits
100 0 7 um/mod 14 = verif 2 = verif  \ -1 -1  (100/7 = 14 r2)
0 1 4 um/mod 4611686018427387904 = verif 0 = verif  \ 2^64/4 = 2^62 r0

\ ---------------------------------------------------------------------------
\ SECTION 30 - SORTIE NUMERIQUE <# # #S HOLD SIGN #>
\ Zone "pictured numeric output" : construite vers l'arriere. Chiffres
\ majuscules (0-9, A-Z).
\ ---------------------------------------------------------------------------
\ 0 -> "0"
0 0 <# #s #> swap drop 1 = verif     \ -1  (len = 1)
0 0 <# #s #> drop c@ 48 = verif      \ -1  (1er char = '0')

\ 42 -> "42" (decimal)
42 s>d <# #s #>
2 = verif                            \ -1  (len = 2)
dup c@ 52 = verif                    \ -1  ('4')
1 + c@ 50 = verif                    \ -1  ('2')

\ signe : "-42"
-42 abs 0 <# #s -1 sign #>
3 = verif                            \ -1  (len = 3)
c@ 45 = verif                        \ -1  ('-')

\ base 16 : 255 -> "FF"
hex ff 0 <# #s #> decimal
2 = verif                            \ -1  (len = 2)
c@ 70 = verif                        \ -1  ('F')

\ HOLD : ajoute '!' au debut -> "!0"
0 0 <# #s 33 hold #>
2 = verif                            \ -1  (len = 2)
c@ 33 = verif                        \ -1  ('!')

\ # seul : un chiffre (123 % 10 = 3 -> "3", reste 12 abandonne par #>)
123 s>d <# # #>
1 = verif                            \ -1  (len = 1)
c@ 51 = verif                        \ -1  ('3')

\ usage type (visuel) : u. = 0 <# #s #> type space
: u.40  0 <# #s #> type space ;
255 u.40                             \ affiche "255 "

\ ---------------------------------------------------------------------------
\ SECTION 31 - FINALISATION ud. / d. (cas limites)
\ ud. / d. affichent (visuel) puis laissent la sentinelle 999 sur la pile.
\ ---------------------------------------------------------------------------
\ u64 max en decimal : 20 chiffres, 1er chiffre '1'
18446744073709551615 0 <# #s #>
20 = verif                           \ -1  (len = 20)
dup c@ 49 = verif                    \ -1  (1er chiffre = '1')
drop                                 \ pile vide

\ u64 max en base 16 : "FFFFFFFFFFFFFFFF" (16 chiffres)
18446744073709551615 hex 0 <# #s #> decimal
16 = verif                           \ -1  (len = 16)
c@ 70 = verif                        \ -1  ('F')
drop

\ base 2 : 255 -> "11111111" (8 chiffres)
255 2 base ! 0 <# #s #> decimal
8 = verif                            \ -1  (len = 8)
c@ 49 = verif                        \ -1  ('1')
drop

\ ud. : u64 max (affiche 18446744073709551615 )
-1 1 um* 999 ud. 999 = verif         \ -1  (double consomme, sentinelle intacte)

\ d. : positif / negatif single (affiche 123 / -123 )
123 s>d 999 d. 999 = verif           \ -1
-123 s>d 999 d. 999 = verif          \ -1

\ d. : negatif profond -2^64 = ( lo=0 hi=-1 ) (affiche -18446744073709551616 )
0 -1 999 d. 999 = verif              \ -1

\ d. : 2^64 positif = ( lo=0 hi=1 ) (affiche 18446744073709551616 )
4294967296 4294967296 um* 999 d. 999 = verif  \ -1

\ ud. en base 16 : u64 max -> "FFFFFFFFFFFFFFFF" (visuel)
-1 1 um* 999 hex ud. decimal 999 = verif  \ -1

\ ---------------------------------------------------------------------------
\ SECTION 32 - KEY / KEY? / ACCEPT
\ key ( -- char ) : Core, bloquant (boucle key_queue, preemption PIT +
\ emergency_break). accept ( c-addr +n1 -- +n2 ) : lit <= +n1 chars du
\ clavier dans le tampon, retourne +n2 (sans le CR) ; backspace retire le
\ dernier, Escape annule (0), au-dela de +n1 ignore.
\ key? ( -- flag ) : EXTENSION EPONA (absent du Core Forth 2012) : une touche
\ en attente, NON BLOQUANT et NE CONSOMME PAS le caractere.
\ VALIDATION : la lecture reelle d'une touche est INTERACTIVE (QEMU).
\ ---------------------------------------------------------------------------
create tbuf 32 allot

\ key? : file vide -> 0 (aucune touche en attente)
key? 0 = verif                          \ -1

\ key? ne consomme pas : deux appels donnent le meme resultat
key? 0 = verif 0 = verif                \ -1 -1

\ --- VALIDATION CLAVIER INTERACTIVE (UNE touche puis Entree) ---
cr
." ========================================" cr
." VALIDATION CLAVIER" cr
." Appuie sur la touche 'A' puis Entree" cr
." pour valider le test du fichier : " 
tbuf 16 accept
dup . ."  char(s) recu(s)" cr
1 = verif                          \ -1  (accept -> +n2 = 1)
tbuf c@ 65 = verif                 \ -1  (tbuf[0] = 'A' = 65)
." Validation clavier OK." cr

\ ---------------------------------------------------------------------------
\ SECTION 33 - WORD
\ word ( char -- c-addr ) : parse la source courante, skip les delimiteurs
\ initiaux, lit jusqu'au delimiteur final (non inclus), copie en chaine
\ comptee (octet 0 = longueur) dans le buffer WORD, avance >IN.
\ NB : source controlee via evaluate (cf. PARSE-NAME).
\ ---------------------------------------------------------------------------
\ 1) Lecture du nom du mot de test : source "t-w1" -> WORD lit "t-w1" (4).
: t-w1 ( -- flag ) 32 word c@ 4 = ;
s" t-w1" evaluate verif                \ -1

\ 2) Skip des espaces initiaux : source "  t-w2" -> WORD lit "t-w2" (4).
: t-w2 ( -- flag ) 32 word c@ 4 = ;
here 6 allot drop
here 32 ! here 1+ 32 !
here 2 + 116 ! here 3 + 45 ! here 4 + 119 ! here 5 + 50 !
here 6 evaluate verif                \ -1

\ 3) Contenu de la chaine comptee : source "t-w3" -> octet 0 = 4, octet 1 = 't'.
: t-w3 ( -- flag ) 32 word c@ 4 = ;
s" t-w3" evaluate verif                \ -1
: t-w3c ( -- flag ) 32 word 1+ c@ 116 = ;
s" t-w3c" evaluate verif               \ -1  ('t' = 116)

\ 4) Deux mots successifs : source "t-w4 ab" -> WORD -> "t-w4" (4) puis
\    skip ' ' -> "ab" (2) ; >IN avance a chaque appel.
: t-w4 ( -- n1 n2 ) 32 word c@ 32 word c@ ;
here 7 allot drop
here 116 ! here 1+ 45 ! here 2 + 119 ! here 3 + 52 !
here 4 + 32 ! here 5 + 97 ! here 6 + 98 !
here 7 evaluate 2 = verif 4 = verif  \ -1 -1

\ 5) Delimiteur personnalise ':' (58) : source "t-w6 ab:cd" -> 1er mot
\    "t-w6 ab" (7, jusqu'au ':', l'espace en fait partie), 2e mot "cd" (2).
: t-w6 ( -- n1 n2 ) 58 word c@ 58 word c@ ;
here 10 allot drop
here 116 ! here 1+ 45 ! here 2 + 119 ! here 3 + 54 !
here 4 + 32 ! here 5 + 97 ! here 6 + 98 ! here 7 + 58 !
here 8 + 99 ! here 9 + 100 !
here 10 evaluate 2 = verif 7 = verif \ -1 -1

\ 6) Entree vide : source "t-w7 ::" -> apres skip des ':', 0 char -> longueur 0.
: t-w7 ( -- n1 n2 ) 58 word c@ 58 word c@ ;
here 7 allot drop
here 116 ! here 1+ 45 ! here 2 + 119 ! here 3 + 55 !
here 4 + 32 ! here 5 + 58 ! here 6 + 58 !
here 7 evaluate 0 = verif 5 = verif \ -1 -1

\ ---------------------------------------------------------------------------
\ SECTION 34 - >NUMBER
\ >number ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) : convertit la chaine
\ c-addr1/u1 selon BASE (0-9, A-Z/a-z), accumule dans ud1, s'arrete au
\ premier caractere non convertible (ud2 = resultat, c-addr2/u2 = reste).
\ Convention double Epona : ( lo hi ), hi au sommet.
\ ---------------------------------------------------------------------------
\ 1) Base 10, chaine complete : "123" (3) -> lo=123, hi=0, u2=0.
0 0 s" 123" >number
0 = verif                          \ -1  (u2)
drop                               \ ( ud2 c-addr2 )
swap 123 = verif                   \ -1  (lo)
0 = verif                          \ -1  (hi)

\ 2) Arret au caractere invalide : "123x" -> convertit "123", reste "x" (u2=1).
0 0 s" 123x" >number
1 = verif                          \ -1  (u2)
drop                               \ ( ud2 c-addr2 )
swap 123 = verif                   \ -1  (lo)
0 = verif                          \ -1  (hi)

\ 3) Reste multiple : "12ab" en base 10 -> "12" (lo=12), reste "ab" (u2=2),
\    c-addr2 pointe sur 'a' (97).
0 0 s" 12ab" >number
2 = verif                          \ -1  (u2)
c@ 97 = verif                      \ -1  (c-addr2 -> 'a')
swap 12 = verif                    \ -1  (lo)
0 = verif                          \ -1  (hi)

\ 4) Base 16 : "ff" -> 255.
0 0 s" ff" hex >number decimal
0 = verif                          \ -1  (u2)
drop                               \ ( ud2 c-addr2 )
swap 255 = verif                   \ -1  (lo)
0 = verif                          \ -1  (hi)

\ 5) Signe non convertible (le signe est gere AVANT >NUMBER) : "-12" -> rien
\    de converti, ud2 = ud1 = (0,0), u2 = 3.
0 0 s" -12" >number
3 = verif                          \ -1  (u2)
drop                               \ ( ud2 c-addr2 )
drop                               \ ( ud2 )
swap 0 = verif                     \ -1  (lo)
0 = verif                          \ -1  (hi)

\ 6) Accumulation sur double non nul : ud1 = 2^64 (hi=1, lo=0) + "0" base 10
\    -> 10 * 2^64 (lo=0, hi=10).
0 1 s" 0" >number
0 = verif                          \ -1  (u2)
drop                               \ ( ud2 c-addr2 )
swap 0 = verif                     \ -1  (lo)
10 = verif                         \ -1  (hi)

\ 7) Base 2 : "101" -> 5.
0 0 s" 101" 2 base ! >number decimal
0 = verif                          \ -1  (u2)
drop                               \ ( ud2 c-addr2 )
swap 5 = verif                     \ -1  (lo)
0 = verif                          \ -1  (hi)

\ ---------------------------------------------------------------------------
\ SECTION 35 - ABORT / ENVIRONMENT? / QUIT / DEPTH
\ abort ( i*x -- ) : vide les piles, STATE = interpretation, stoppe la
\ source courante sans message. environment? ( c-addr u -- false | i*x true )
\ : interroge l'environnement (ANS 3.2.6), les 12 requetes obligatoires sont
\ reconnues (casse ignoree), autre -> false. quit ( -- ) : vide la pile de
\ retour, STATE = interpretation, retour au prompt ; la pile de DONNEES est
\ CONSERVEE (difference avec ABORT). depth ( -- +n ) : profondeur de pile.
\ ---------------------------------------------------------------------------
\ 1) Requete inconnue -> false (0).
s" N'IMPORTE-QUOI" environment?
0 = verif                          \ -1  (false)

\ 2) MAX-N = i64::MAX (9223372036854775807).
s" max-n" environment?
-1 = verif                         \ -1  (true)
9223372036854775807 = verif        \ -1  (MAX-N)

\ 3) MAX-U = u64::MAX (-1 en i64).
s" MAX-U" environment?
-1 = verif                         \ -1  (true)
-1 = verif                         \ -1  (MAX-U)

\ 4) MAX-CHAR = 255.
s" MAX-CHAR" environment?
-1 = verif                         \ -1  (true)
255 = verif                        \ -1  (MAX-CHAR)

\ 5) ADDRESS-UNIT-BITS = 64 (1 adresse = 1 cellule i64).
s" ADDRESS-UNIT-BITS" environment?
-1 = verif                         \ -1  (true)
64 = verif                         \ -1  (ADDRESS-UNIT-BITS)

\ 6) /COUNTED-STRING = 39 (capacite du tampon WORD).
s" /counted-string" environment?
-1 = verif                         \ -1  (true)
39 = verif                         \ -1  (/COUNTED-STRING)

\ 7) /HOLD = 68 (zone PNO, 1 char/cellule).
s" /hold" environment?
-1 = verif                         \ -1  (true)
68 = verif                         \ -1  (/HOLD)

\ 8) /PAD = 1024 (taille de la zone transitoire PAD).
s" /pad" environment?
-1 = verif                         \ -1  (true)
1024 = verif                       \ -1  (/PAD)

\ 9) FLOORED = false (/, MOD symetriques).
s" floored" environment?
-1 = verif                         \ -1  (true)
0 = verif                          \ -1  (FLOORED)

\ 10) STACK-CELLS = 4096 (MAX_STACK).
s" stack-cells" environment?
-1 = verif                         \ -1  (true)
4096 = verif                       \ -1  (STACK-CELLS)

\ 11) RETURN-STACK-CELLS = 1024 (MAX_RSTACK).
s" return-stack-cells" environment?
-1 = verif                         \ -1  (true)
1024 = verif                       \ -1  (RETURN-STACK-CELLS)

\ 12) MAX-D = (lo=u64::MAX, hi=i64::MAX), hi au sommet.
s" max-d" environment?
-1 = verif                         \ -1  (true)
swap -1 = verif                    \ -1  (lo)
9223372036854775807 = verif        \ -1  (hi)

\ 13) MAX-UD = (lo=u64::MAX, hi=u64::MAX).
s" max-ud" environment?
-1 = verif                         \ -1  (true)
swap -1 = verif                    \ -1  (lo)
-1 = verif                         \ -1  (hi)

\ 14) ABORT — CONTRAT D'ETAT via evaluate (source imbriquee) : piles videes,
\     reste de la source ignore, flot exterieur repris.
\     (a) le code qui suit "abort" ne doit PAS s'executer.
variable abort-flag
0 abort-flag !
s" abort 1 abort-flag !" evaluate
abort-flag @ 0 = verif             \ -1  (0 = code apres abort ignore)

\     (b) la pile de donnees est VIDE apres abort (depth = 0).
s" 1 2 3 abort" evaluate
depth 0 = verif                    \ -1  (pile videe)

\     (c) silencieux : la source imbriquee se termine normalement (Ok),
\         l'arithmetique apres abort tourne sur une pile vide.
s" 1 2 3 abort 7 8 +" evaluate
15 = verif                         \ -1  (seul residu = 7 + 8)

\     (d) STATE = interpretation apres abort.
s" abort" evaluate
state @ 0 = verif                  \ -1  (STATE = interpretation)

\ 15) QUIT — stoppe la source courante : le code qui suit ne doit PAS
\     s'executer ; la pile de DONNEES est CONSERVEE.
variable quit-flag
0 quit-flag !
s" quit 1 quit-flag !" evaluate
quit-flag @ 0 = verif              \ -1  (0 = code apres quit ignore)
1 2 3 s" quit" evaluate
depth 3 = verif                    \ -1  (pile conservee)
drop drop drop                     \ (nettoie)
s" quit" evaluate
state @ 0 = verif                  \ -1  (STATE = interpretation)

\ 16) depth (436) : nombre de cellules sur la pile de donnees.
1 2 3 depth
3 = verif                          \ -1  (depth = 3)
drop drop drop                     \ (nettoie)

\ ---------------------------------------------------------------------------
\ SECTION 36 - WITHIN / U> / PAD
\ within ( n lo hi -- flag ) : -1 si lo <= n < hi, sinon 0 (borne haute
\ exclue). u> ( u1 u2 -- flag ) : comparaison NON SIGNEE (u64).
\ pad ( -- addr ) : adresse d'une zone transitoire d'au moins 84 chars
\ (Forth 2012 6.2.2000 ; Epona : 1024 chars sous la zone WORD).
\ ---------------------------------------------------------------------------
\ WITHIN
0 0 10 within verif                \ -1  (0 dans [0..10) )
10 10 20 within verif              \ -1  (10 dans [10..20) )
20 10 20 within verif              \ 0   (20 exclu)
-5 -10 0 within verif              \ -1  (negatif dans [-10..0) )
5 10 20 within verif               \ 0   (5 < lo)
10 10 10 within verif              \ 0   (lo == hi -> vide)
-1 -1 0 within verif               \ -1  (borne inferieure incluse)

\ U>
5 3 u> verif                       \ -1  (5 > 3)
3 5 u> verif                       \ 0   (3 < 5)
5 5 u> verif                       \ 0   (egal)
0 -1 u> verif                      \ 0   (0 < 2^64-1 non signe)
-1 0 u> verif                      \ -1  (2^64-1 > 0 non signe)
-2 -1 u> verif                     \ 0   (2^64-2 < 2^64-1 non signe)
1 0 u> verif                       \ -1  (1 > 0)
\ contraste avec le signe : -1 > 0 en signe, faux en non signe
-1 0 > verif                       \ -1  (signe : -1 > 0 -> -1)
-1 0 u> verif                      \ -1  (non signe : 2^64-1 > 0 -> -1)

\ PAD
pad .                              \ adresse PAD (129936)
pad 0<> verif                      \ -1  (PAD non nul)
pad 83 chars + 65 over c! c@ 65 = verif   \ -1  (zone >= 84 chars utilisable)
\ PAD + 1024 ne doit pas depasser la zone (reste sous WORD/PNO/systeme)
pad 1024 + 130960 = verif          \ -1  (PAD = 129936, PAD+1024 = 130960 = WORD_BASE)

\ ---------------------------------------------------------------------------
\ SECTION 37 - .R / U.R / HOLDS
\ .r ( n +n -- ) : affiche n aligne a droite sur +n colonnes (BASE courante).
\ u.r ( u +n -- ) : idem, non signe. Pas d'espace final (contrairement a .).
\ holds ( c-addr u -- ) : EXTENSION EPONA (absent de Forth 2012 ; seul hold
\ est standard) : ajoute la chaine au debut de la chaine picturale.
\ ---------------------------------------------------------------------------
\ 1) .R / U.R : affichages documentes (verification visuelle, padding a
\    gauche ; si largeur insuffisante, tous les chiffres sont affiches).
42 5 .r cr            \  "   42" (3 espaces + "42")
42 2 .r cr            \  "42"    (largeur insuffisante -> pas de troncature)
-7 4 .r cr            \  "  -7"
0 3 .r cr             \  "  0"
7 4 u.r cr            \  "   7"
-1 5 u.r cr           \  20 chiffres (2^64-1), etendus
42 5 .r 32 emit 42 5 .r cr   \  "   42    42"

\ 2) HOLDS : la chaine est ajoutee DEVANT les chiffres dans <# ... #>.
: holds-test ( -- addr len )
  s" !!-" 42 0 <# #s 2swap holds #> ;     \  "!!-42"
holds-test s" !!-42" compare 0 = verif    \  -1  (compare : egal)

\ HOLDS seul (sans chiffres) : prefixe seul.
: holds-only ( -- addr len )
  s" AB" 0 0 <# 2swap holds #> ;          \  "AB"
holds-only s" AB" compare 0 = verif       \  -1

\ HOLDS apres #S et HOLD : "12-34" (hold ajoute '-' avant 34, puis holds "12").
: holds-mix ( -- addr len )
  s" 12" 34 0 <# #s 45 hold 2swap holds #> ;   \  45 = '-'
holds-mix s" 12-34" compare 0 = verif          \  -1

\ HOLDS longueur nulle : ne modifie pas la chaine picturale.
: holds-empty ( -- addr len )
  s" XX" drop 0 7 0 <# #s 2swap holds #> ;    \  u=0 -> "7" seul
holds-empty s" 7" compare 0 = verif            \  -1

\ ---------------------------------------------------------------------------
\ SECTION 38 - S" / S\" / .\" / COMPILE,
\ s" ( -- c-addr u ) : chaine LITTERALE — les \ sont du texte brut (core).
\ s\" : chaine avec echappements \n \t \r \\ \" interpretes (string).
\ .\" : variante d'affichage de ." avec echappements (controle visuel).
\ compile, ( xt -- ) : compile la definition de xt dans la definition
\ courante (core 2012 6.1.0860).
\ ---------------------------------------------------------------------------
\ 1) S" interprete : le backslash n'est PAS un echappement -> 4 octets a,\ ,n,b.
s" a\nb" drop 4 = verif               \  -1  (longueur litterale)
s" a\nb" over c@ 97 = verif 2drop     \  -1  ('a')
s" a\nb" swap 1 + c@ 92 = verif 2drop \  -1  ('\' = 92, non converti en LF)
s" x\tY" drop 4 = verif               \  -1  (x \ t Y = 4 octets)

\ 2) S\" interprete : echappements interpretes.
s\" a\nb" drop 3 = verif              \  -1  (a LF b)
s\" a\nb" over c@ 97 = verif 2drop    \  -1  ('a')
s\" a\nb" swap 1 + c@ 10 = verif 2drop \  -1  (LF = 10)
s\" x\tY" drop 3 = verif              \  -1  (x TAB Y)
s\" x\tY" swap 1 + c@ 9 = verif 2drop \  -1  (TAB = 9)
s\" a\"b" drop 3 = verif              \  -1  (a " b)
s\" a\\b" drop 3 = verif              \  -1  (a \ b)
s\" a\rb" swap 1 + c@ 13 = verif 2drop \  -1  (CR = 13)

\ 3) S\" COMPILE (dans une definition).
: str-c   s\" HELLO\nW" ;
str-c drop 7 = verif                  \  -1  (H E L L O LF W)
str-c s\" HELLO\nW" compare 0 = verif \  -1  (identiques apres compilation)

\ 4) S" COMPILE reste litteral.
: str-c2  s" a\nb" ;
str-c2 drop 4 = verif                 \  -1  (a \ n b, 4 octets)

\ 4b) .\" : variante echappee de ." (affichage direct, controle visuel).
.\" A\tB\nC" cr            \  affiche: A<TAB>B<LF>C
: pt-t .\" X\nY" ;  pt-t cr    \  affiche: X<LF>Y

\ 5) COMPILE, : defini un mot immediat qui fournit une xt, puis compile,
: double    dup + ;
: get-dup   ( -- xt )   ' dup ;    immediate
: get-double ( -- xt )  ' double ; immediate

: foo1  get-dup compile, ;              \  foo1 = dup
5 foo1 drop 5 = verif                  \  -1  (5 -> 5 5)

: foo2  get-double compile, ;           \  foo2 = double
3 foo2 6 = verif                       \  -1  (3 -> 6)

\ COMPILE, multiple : double puis dup.
: foo4  get-double compile, get-dup compile, ;
4 foo4 drop 8 = verif                  \  -1  (4 -> 8 -> 8 8, drop -> 8)

\ COMPILE, d'une primitive repetee : dup dup.
: foo5  get-dup compile, get-dup compile, ;
2 foo5 2 = verif 2 = verif 2 = verif   \  -1 -1 -1  (2 -> 2 2 2, chacun = 2)

\ ---------------------------------------------------------------------------
\ SECTION 39 - :NONAME
\ :noname ( core 2012 6.1.1800 ) : cree une definition SANS NOM, pousse son
\ xt (index dictionnaire) sur la pile de donnees et passe en mode compilation.
\ Le ; qui suit finalise l'entree. L'xt s'utilise avec execute ou via un
\ defer (is). Chaque :noname cree sa propre entree de dictionnaire.
\ ---------------------------------------------------------------------------
\ 1) Execution directe : :noname ... ; laisse le xt sur la pile, execute le pop.
:noname 42 ; execute 42 = verif          \  -1  (xt -> 42)

\ 2) Definition anonyme avec argument.
5 :noname 10 + ; execute 15 = verif      \  -1  (5 + 10 = 15)

\ 3) Le xt est laisse sur la pile : profondeur 1 apres ; (avant execution).
:noname 42 ; depth 1 = verif drop        \  -1  (1 cellule = le xt, puis drop)

\ 4) Association a un defer : :noname ... ; is <defer>.
defer f
:noname 7 ; is f
f 7 = verif                              \  -1  (defer -> xt anonyme -> 7)

\ 5) Deux definitions anonymes independantes (pas d'ecrasement).
:noname 1 ; execute 1 = verif            \  -1
:noname 2 ; execute 2 = verif            \  -1

\ 6) Recursion dans une definition anonyme (recurse -> anon_idx).
\    factorielle : n! avec 5 -> 120.
:noname dup 1 <= if drop 1 else dup 1- recurse * then ;
5 swap execute 120 = verif               \  -1  (5! = 120)

\ 7) Defer + definition anonyme qui consomme des arguments.
defer g
:noname + ; is g
20 22 g 42 = verif                       \  -1  (20 + 22 = 42)

\ ---------------------------------------------------------------------------
\ SECTION 40 - CATCH / THROW / POSTPONE
\ throw ( err -- ) ( core 2012 6.1.2270 ) : code 0 = no-op ; sinon retour au
\ CATCH le plus recent : piles restaurees + code pousse.
\ catch ( i*x xt -- j*x 0 | i*x n ) ( core 2012 6.1.0675 ) : execute xt sous
\ un handler d'exception. Si throw non-zero -> code pousse (piles
\ restaurees), sinon 0 pousse. En mode COMPILATION, catch reste le mot
\ structure try/catch/endtry (extension Epona).
\ postpone ( "name" -- ) ( core 2012 6.1.2030 ) : compile la semantique de
\ compilation de name dans la definition courante.
\ ---------------------------------------------------------------------------
\ 1) CATCH normal : pas de throw -> 0 pousse.
' dup catch 0 = verif                    \  -1

\ 2) CATCH + THROW : le code de l'exception est pousse.
: boom  42 throw ;
' boom catch 42 = verif                  \  -1

\ 3) THROW 0 = no-op (le code 0 est retire, execution continue).
5 0 throw 5 = verif                      \  -1

\ 4) THROW restaure la profondeur de pile du CATCH (arguments jetes).
: boom2  1 2 3 42 throw ;
' boom2 catch 42 = verif                 \  -1
' boom2 catch depth 1 = verif drop      \  -1  (un seul element : le code)

\ 5) THROW 0 dans une definition : pas d'exception (0 pousse).
: boom0  0 throw ;
' boom0 catch 0 = verif                  \  -1

\ 6) CATCH : les i*x (sous l'xt) sont conserves, le code pousse par-dessus.
: boom5  42 throw ;
7 ' boom5 catch 42 = verif drop          \  -1  (7 conserve + code 42)
' boom5 catch depth 1 = verif drop       \  -1  (sans i*x : seul le code 42)

\ 7) POSTPONE d'une primitive : test1 = 2drop.
: test1  postpone 2drop ;
1 2 test1 depth 0 = verif                \  -1

\ 8) POSTPONE d'un mot defini non immediat : test2 = double.
: double  dup + ;
: test2  postpone double ;
3 test2 6 = verif                        \  -1

\ 9) POSTPONE multiple : test3 = dup +.
: test3  postpone dup postpone + ;
4 test3 8 = verif                        \  -1  (4 dup + -> 4 +4=8)

\ 10) POSTPONE d'un mot immediat du dictionnaire (semantique de compilation
\     executee au runtime : ici get-2drop pousse l'xt de 2drop).
: get-2drop  ' 2drop ;  immediate
: test4  postpone get-2drop ;
5 test4 execute depth 0 = verif          \  -1  (5 -> xt -> 2drop -> vide)

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
