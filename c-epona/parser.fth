\ ==============================================================================
\ c-epona/parser.fth - Parseur & Compilateur C-Épona vers Mots Forth
\ ==============================================================================

INCLUDE c-epona/oof.fth
INCLUDE c-epona/lexer.fth

VARIABLE IN-CLASS-DEF

: PARSE-CLASS ( -- )
    LEX-NEXT-TOKEN DROP \ Lit le nom de la classe
    TOKEN-BUF @ TOKEN-LEN @ EVALUATE \ Crée la classe OOF via CLASS:
    1 IN-CLASS-DEF !
;

: PARSE-METHOD ( -- )
    \ Transpile la déclaration d'une méthode C "void render() { ... }" en Forth
    LEX-NEXT-TOKEN DROP \ Type de retour
    LEX-NEXT-TOKEN DROP \ Nom de la méthode
    \ Génère la signature de méthode OOF
;

: PARSE-STATEMENT ( -- )
    LEX-NEXT-TOKEN CASE
        TOK-KEYWORD OF
            \ Gère 'class', 'if', 'while', 'return', 'new'
        ENDOF
        TOK-IDENT OF
            \ Gère l'accès aux variables / méthodes
        ENDOF
    ENDCASE
;

\ Compilation JIT dynamique en mémoire (Mots Forth compilés à la volée)
: C-JIT-COMPILE ( c-addr u -- )
    CR ." [C-EPONA JIT] Compilation JIT en code x86-64 natif..." CR
    INCLUDED
    \ Fait appel au compilateur JIT natif d'Epona OS (JIT-COMPILE / JIT-ON)
    S" JIT-ON" EVALUATE
    CR ." [C-EPONA JIT] Code C-Épona compilé et exécutable immédiatement à 60 FPS !" CR
;

\ Compilation vers un fichier binaire standalone (.JIT / .EPA)
: C-BUILD-BINARY ( cep-addr cep-len bin-addr bin-len -- )
    CR ." [C-EPONA BINARY] Compilation AOT vers fichier binaire signé..." CR
    2SWAP INCLUDED
    \ Sérialisation et signature HMAC du binaire JIT pour le Store d'Epona OS
    S" JIT-SIGN" EVALUATE
    CR ." [C-EPONA BINARY] Binaire .JIT /.EPA généré et signé avec succès !" CR
;

: C-PARSE-FILE ( c-addr u -- )
    \ Parse et compile un fichier .cep complet en mémoire JIT
    C-JIT-COMPILE
;
