\ ==============================================================================
\ c-epona/lexer.fth - Lexer / Tokenizer C-Épona en Forth ISO 2012
\ ==============================================================================

VARIABLE TOKEN-TYPE
VARIABLE TOKEN-BUF
256 ALLOCATE THROW TOKEN-BUF !
VARIABLE TOKEN-LEN

\ Types de Tokens
0 CONSTANT TOK-EOF
1 CONSTANT TOK-IDENT
2 CONSTANT TOK-KEYWORD
3 CONSTANT TOK-NUMBER
4 CONSTANT TOK-STRING
5 CONSTANT TOK-SYMBOL

: C-CHAR ( -- c )
    KEY
;

: IS-SPACE ( c -- flag )
    DUP 32 = OVER 9 = OR OVER 10 = OR SWAP 13 = OR
;

: IS-ALPHA ( c -- flag )
    DUP 65 >= OVER 90 <= AND SWAP DUP 97 >= SWAP 122 <= AND OR
;

: IS-DIGIT ( c -- flag )
    DUP 48 >= SWAP 57 <= AND
;

: SKIP-WHITESPACE
    BEGIN
        KEY DUP IS-SPACE WHILE
        DROP
    REPEAT
    KEY-PUSHBACK \ Réinjecte le dernier caractère non-espace
;

: LEX-NEXT-TOKEN ( -- token-type )
    SKIP-WHITESPACE
    C-CHAR DUP 0= IF DROP TOK-EOF EXIT THEN
    
    DUP IS-ALPHA IF
        \ Identifier / Keyword
        0 TOKEN-LEN !
        BEGIN
            TOKEN-BUF @ TOKEN-LEN @ + C!
            1 TOKEN-LEN +!
            C-CHAR DUP IS-ALPHA OVER IS-DIGIT OR 95 = OR \ Alpha + Digit + '_'
        0= UNTIL
        KEY-PUSHBACK
        TOK-IDENT TOKEN-TYPE !
        TOKEN-TYPE @ EXIT
    THEN

    DUP IS-DIGIT IF
        \ Number
        0 TOKEN-LEN !
        BEGIN
            TOKEN-BUF @ TOKEN-LEN @ + C!
            1 TOKEN-LEN +!
            C-CHAR DUP IS-DIGIT
        0= UNTIL
        KEY-PUSHBACK
        TOK-NUMBER TOKEN-TYPE !
        TOKEN-TYPE @ EXIT
    THEN

    \ Symboles et ponctuation C
    TOKEN-BUF @ C!
    1 TOKEN-LEN !
    TOK-SYMBOL TOKEN-TYPE !
    TOKEN-TYPE @
;
