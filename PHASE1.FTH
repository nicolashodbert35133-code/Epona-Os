\ ============================================================
\ PHASE1.FTH — Démo des nouveaux mots Phase 1
\ Chargez avec : sys:load PHASE1.FTH
\ ============================================================

\ -----------------------------------------------------------
\ CHAR — Empile le code ASCII d'un caractère
\ -----------------------------------------------------------
cr ." === CHAR ===" cr
char A . cr              \ 65
char Z . cr              \ 90
char 0 . cr              \ 48

\ -----------------------------------------------------------
\ SEE — Affiche la définition et le bytecode d'un mot
\ -----------------------------------------------------------
cr ." === SEE ===" cr
: test-see dup * 1+ ;
see test-see

\ -----------------------------------------------------------
\ VALUE / TO — Variable qui retourne sa valeur directement
\ -----------------------------------------------------------
cr ." === VALUE / TO ===" cr
42 value reponse
reponse . cr              \ 42
100 to reponse
reponse . cr              \ 100

\ Utile pour des paramètres :
0 value vitesse
: plus-vite vitesse 10 + to vitesse ;
plus-vite vitesse . cr    \ 10

\ -----------------------------------------------------------
\ DEFER / IS — Mot différé (redéfinissable)
\ -----------------------------------------------------------
cr ." === DEFER / IS ===" cr
defer salutation

: bonjour ." Bonjour !" cr ;
: salut   ." Salut !"   cr ;

' bonjour is salutation
salutation                \ Bonjour !

' salut is salutation
salutation                \ Salut !

\ -----------------------------------------------------------
\ [CHAR] — Version compilée de CHAR
\ -----------------------------------------------------------
cr ." === [CHAR] ===" cr
: affiche-A [char] A emit cr ;
affiche-A                 \ A

: affiche-X [char] X emit cr ;
affiche-X                 \ X

\ -----------------------------------------------------------
\ CASE / OF / ENDOF / ENDCASE — Sélection multiple
\ -----------------------------------------------------------
cr ." === CASE ===" cr

: jour-semaine ( n -- )
  case
    1 of ." Lundi"    endof
    2 of ." Mardi"    endof
    3 of ." Mercredi" endof
    4 of ." Jeudi"    endof
    5 of ." Vendredi" endof
    ." Weekend"
  endcase cr
;

1 jour-semaine           \ Lundi
3 jour-semaine           \ Mercredi
6 jour-semaine           \ Weekend

: note-scolaire ( n -- )
  case
    20 of ." Parfait !"        endof
    18 of ." Très bien"        endof
    15 of ." Bien"             endof
    12 of ." Assez bien"       endof
    10 of ." Passable"         endof
    ." Insuffisant"
  endcase cr
;

20 note-scolaire          \ Parfait !
12 note-scolaire          \ Assez bien
8  note-scolaire          \ Insuffisant

\ -----------------------------------------------------------
\ TEST COMBINÉ — Value + Defer + Case
\ -----------------------------------------------------------
cr ." === TEST COMBINÉ ===" cr

0 value choix
defer action

: action-un   ." Vous avez choisi 1" cr ;
: action-deux ." Vous avez choisi 2" cr ;
: action-trois ." Vous avez choisi 3" cr ;

: menu ( n -- )
  to choix
  choix case
    1 of ' action-un   is action endof
    2 of ' action-deux is action endof
    3 of ' action-trois is action endof
    ." Choix invalide" cr
  endcase
  choix 1 >= choix 3 <= and if action then
;

2 menu                    \ Vous avez choisi 2
3 menu                    \ Vous avez choisi 3
5 menu                    \ Choix invalide

cr ." === Fin de PHASE1.FTH ===" cr
