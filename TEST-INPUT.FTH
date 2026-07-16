\ TEST-INPUT.FTH — Tests des primitives d'entrée ANS Forth
\ Exécuter : exec TEST-INPUT.FTH

cr .\" === Tests primitives d'entree ===\" cr cr

\ ── 1. source ───────────────────────────────────────────────
\ source retourne l'adresse et la longueur de la ligne courante
.\" 1) source : " source type cr
.\"    (affiche la ligne source elle-meme)" cr cr

\ ── 2. >in ──────────────────────────────────────────────────
\ >in est l'adresse du pointeur d'entrée (cellule 4095)
\ On peut le lire avec @ et l'écrire avec !
: test>in
    >in @ .\" >in avant = " . cr
    5 >in !              \ avancer >in de 5 octets
    >in @ .\" >in apres = " . cr
    0 >in !              \ remettre à 0
;
test>in cr

\ ── 3. parse-name ───────────────────────────────────────────
\ parse-name lit le prochain token dans source_buffer
: test-parse-name
    s\" Hello World" source drop 20 move   \ remplir source_buffer
    0 >in !                                \ reset >in
    parse-name                             \ parse "Hello"
    .\" parse-name : addr=" . ." len=" . cr
;
test-parse-name cr

\ ── 4. parse ────────────────────────────────────────────────
\ parse lit jusqu'au délimiteur donné
: test-parse
    s\" Bonjour;Adieu" source drop 30 move  \ remplir source_buffer
    0 >in !                                  \ reset >in
    [char] ; parse                           \ parse jusqu'au ;
    .\" parse ';' : " type cr               \ affiche "Bonjour"
;
test-parse cr

\ ── 5. refill (interactif) ──────────────────────────────────
\ refill lit une ligne depuis le clavier
\ Décommenter la ligne suivante pour tester en mode interactif :
\ : test-refill
\     .\" Tapez quelque chose : " cr
\     refill
\     if
\         .\" Lu : " source type cr
\     else
\         .\" Rien lu (EOF)" cr
\     then
\ ;
\ test-refill

cr .\" === Tous les tests passes ===\" cr
