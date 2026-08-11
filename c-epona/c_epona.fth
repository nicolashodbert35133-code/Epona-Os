\ ==============================================================================
\ c-epona/c_epona.fth - Entry Point pour le Compilateur C-Épona
\ ==============================================================================

CR ." [C-EPONA] Chargement du Moteur C-Épona v1.98..." CR

INCLUDE c-epona/oof.fth
INCLUDE c-epona/lexer.fth
INCLUDE c-epona/parser.fth
INCLUDE c-epona/gui.fth
INCLUDE c-epona/sdk/eponafs.fth
INCLUDE c-epona/sdk/eponanet.fth
INCLUDE c-epona/sdk/eponamedia.fth
INCLUDE c-epona/sdk/eponasys.fth
INCLUDE c-epona/sdk/eponastore.fth

CR ." [C-EPONA] SDK complet chargé (EponaFS, EponaNet, EponaMedia 60 FPS, EponaSys IA, EponaStore)." CR

: C-COMPILE ( "filename" -- )
    PARSE-NAME C-PARSE-FILE
;

: C-LOAD ( "filename" -- )
    C-COMPILE
;

\ Exécute directement un fichier .cep via le moteur JIT d'Épona OS
: C-RUN ( "filename" -- )
    C-COMPILE
;

\ Compile un fichier .cep vers un binaire exécutable .JIT / .EPA signé
: C-BUILD ( "src.cep" "out.jit" -- )
    PARSE-NAME PARSE-NAME C-BUILD-BINARY
;

CR ." [C-EPONA] Astuce JIT & Binaire :" CR
CR ."   - Charger et exécuter direct en JIT : C-RUN c-epona/examples/hello_gui.cep" CR
CR ."   - Compiler en binaire standalone .JIT : C-BUILD c-epona/examples/hello_gui.cep hello_gui.jit" CR

