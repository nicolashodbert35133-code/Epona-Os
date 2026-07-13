\ ============================================================
\ test-20-mots.FTH  —  Test des 20 nouveaux mots EponaForth
\ ============================================================
\ Charger : exec test-20-mots.FTH
\ ============================================================

\ ─── Préparation ───────────────────────────────────────────
cr ." === TEST DES 20 NOUVEAUX MOTS ===" cr

\ ─── 1. see ────────────────────────────────────────────────
cr ." --- 1. see ---" cr
: carre dup * ;
see carre

\ ─── 2. value / to ─────────────────────────────────────────
cr ." --- 2. value / to ---" cr
42 value reponse
reponse . cr            \ → 42
100 to reponse
reponse . cr            \ → 100

\ ─── 3. defer / is ─────────────────────────────────────────
cr ." --- 3. defer / is ---" cr
defer ma-fonction
: dire-bonjour ." Bonjour !" ;
' dire-bonjour is ma-fonction
ma-fonction cr

: dire-salut ." Salut !" ;
' dire-salut is ma-fonction
ma-fonction cr

\ ─── 4. case/of/endof/endcase ──────────────────────────────
cr ." --- 4. case ... of ... endof ... endcase ---" cr
: jour-semaine ( n -- )
  case
    1 of ." Lundi" endof
    2 of ." Mardi" endof
    3 of ." Mercredi" endof
    4 of ." Jeudi" endof
    5 of ." Vendredi" endof
    ." Weekend"
  endcase cr
;
3 jour-semaine
6 jour-semaine

\ ─── 5. [char] / char ──────────────────────────────────────
cr ." --- 5. [char] / char ---" cr
char A . cr             \ → 65
: affiche-A [char] A emit cr ;
affiche-A

\ ─── 6. \n dans ." ─────────────────────────────────────────
cr ." --- 6. sequences d'echappement ---" cr
." Ligne1\nLigne2\tTabulation\n" cr

\ ─── 7. abort" ─────────────────────────────────────────────
cr ." --- 7. abort\" ---" cr
0 abort" NE DOIT PAS APPARAITRE"
1 abort" ARRET VOLONTAIRE"
." Cette ligne ne doit pas etre affichee" cr

\ ─── 8. include / require ──────────────────────────────────
cr ." --- 8. include / require ---" cr
\ Cree un petit fichier auxiliaire
s" test-helper.FTH" w/create
\ (si w/create existe - sinon on simule)
." include/require ne peuvent pas etre testes ici" cr

\ ─── 9. [if] / [else] / [then] ─────────────────────────────
cr ." --- 9. [if] / [else] / [then] ---" cr
1 [if]
  ." BRANCHE VRAIE (1)" cr
[else]
  ." BRANCHE FAUSSE" cr
[then]

0 [if]
  ." BRANCHE FAUSSE" cr
[else]
  ." BRANCHE VRAIE (0→else)" cr
[then]

\ ─── 10. type ──────────────────────────────────────────────
cr ." --- 10. type ---" cr
s" Hello par type!" cr type cr
cr

\ ─── 11. ," ────────────────────────────────────────────────
cr ." --- 11. ,\" ---" cr
create msg ," Hello Epona !"
msg count type cr

\ ─── 12. count ─────────────────────────────────────────────
cr ." --- 12. count ---" cr
msg count
." Longueur: " . cr   \ → 14
msg count type cr      \ → Hello Epona !

\ ─── 13. compare ───────────────────────────────────────────
cr ." --- 13. compare ---" cr
s" hello" s" hello" compare . cr   \ → 0
s" abc" s" def" compare . cr      \ → -1
s" xyz" s" abc" compare . cr      \ → 1

\ ─── 14. search ────────────────────────────────────────────
cr ." --- 14. search ---" cr
s" Hello World" s" World" search
." Flag: " . ." Reste: " . drop cr   \ → flag=-1, reste=5
s" Hello World" s" xyz" search
." Flag: " . drop drop cr            \ → flag=0

\ ─── 15. marker ────────────────────────────────────────────
cr ." --- 15. marker ---" cr
marker ---clean---
: test-marker 42 . ;
test-marker cr         \ → 42
---clean---
\ test-marker est supprime
." test-marker supprime par marker" cr

\ ─── 16. buffer: ───────────────────────────────────────────
cr ." --- 16. buffer: ---" cr
512 buffer: secteur
secteur 512 erase
secteur 0 +!             \ verifie que l'adresse est valide
." Buffer secteur alloue et efface: OK" cr

\ ─── 17. struct / field ────────────────────────────────────
cr ." --- 17. struct / field ---" cr
struct point
  field .x
  field .y
end-struct
." Taille de point: " . ." cellules" cr

point buffer: mon-point
42 mon-point .x !
99 mon-point .y !
mon-point .x @ . cr    \ → 42
mon-point .y @ . cr    \ → 99

\ ─── 18. enum ──────────────────────────────────────────────
cr ." --- 18. enum ---" cr
0 enum ROUGE
  enum VERT
  enum BLEU
  enum JAUNE
drop

ROUGE . cr             \ → 0
VERT . cr              \ → 1
BLEU . cr              \ → 2
JAUNE . cr             \ → 3

\ ─── 19. [defined] / [undefined] ───────────────────────────
cr ." --- 19. [defined] / [undefined] ---" cr
[defined] + [if]
  ." Le mot + existe bien" cr
[then]

[defined] mot-inexistant [if]
  ." NE DOIT PAS APPARAITRE" cr
[then]

[undefined] mot-inexistant [if]
  ." mot-inexistant n'existe pas (OK)" cr
[then]

[undefined] + [if]
  ." NE DOIT PAS APPARAITRE (+ existe)" cr
[then]

\ ─── 20. word-info ─────────────────────────────────────────
cr ." --- 20. word-info ---" cr
word-info +
cr
word-info carre
cr
word-info ma-fonction
cr
word-info dire-bonjour
cr

\ ─── FIN ───────────────────────────────────────────────────
cr ." === TEST TERMINE ===" cr
