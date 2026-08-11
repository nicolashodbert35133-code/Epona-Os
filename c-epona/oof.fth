\ ==============================================================================
\ c-epona/oof.fth - Object-Oriented Forth (OOF) Engine for Epona OS
\ Compatible Forth ISO 2012 / Epona Kernel 1.98
\ ==============================================================================

VARIABLE CURRENT-CLASS
VARIABLE METHOD-COUNT

\ Structure d'une VTable : [ Parent Class Ptr | Method Table Pointer | Object Size ]
: CLASS: ( "name" -- )
    CREATE
        HERE CURRENT-CLASS !
        0 ,             \ Parent Pointer (0 = Object)
        0 ,             \ Method Count
        0 ,             \ Instance Field Size in Bytes
    DOES>
        \ Quand le nom de la classe est exécuté, renvoie son adresse de VTable
;

: INHERITS: ( parent-class -- )
    CURRENT-CLASS @ >R
    R@ !                \ Fixe le Parent Ptr
    DUP CELL+ @ R@ CELL+ ! \ Copie le Method Count du parent
    2 CELLS + @ R@ 2 CELLS + ! \ Copie la taille du parent
    RDROP
;

: FIELD: ( size "name" -- )
    CREATE
        CURRENT-CLASS @ 2 CELLS + DUP @ ( size addr current-offset )
        ,               \ Sauvegarde l'offset du champ dans le mot
        + SWAP !        \ Augmente la taille de la classe
    DOES> ( obj-addr -- field-addr )
        @ +             \ Calcule l'adresse réelle du champ dans l'instance
;

: INT-FIELD: ( "name" -- ) 4 FIELD: ;
: PTR-FIELD: ( "name" -- ) CELL FIELD: ;

: METHOD: ( "name" -- )
    CREATE
        CURRENT-CLASS @ CELL+ DUP @ ( addr-count count )
        DUP ,           \ Sauvegarde l'index de la méthode
        1+ SWAP !       \ Incrémente le compteur de méthodes
    DOES> ( obj-addr ... method-sys -- )
        @               \ Obtient l'index de méthode
        OVER @          \ Obtient la vtable de l'objet (premier cell de l'instance)
        3 CELLS +       \ Saute l'en-tête de vtable (parent, count, size)
        SWAP CELLS + @  \ Trouve l'adresse de fonction dans la vtable
        EXECUTE         \ Exécute la méthode avec ( obj-addr ... )
;

: OVERRIDE: ( xt method-name -- )
    >BODY @             \ Trouve l'index de la méthode
    CURRENT-CLASS @ 3 CELLS + SWAP CELLS + ! \ Place l'adresse XT dans la VTable
;

\ Instanciation dynamique d'objets (Allocation dynamique en tas Epona Forth)
: NEW ( class-addr -- obj-addr )
    DUP 2 CELLS + @     \ Récupère la taille de l'instance
    CELL+ ALLOCATE THROW \ Alloue (Taille + 1 cell pour VTable Ptr)
    SWAP OVER !         \ Stocke le pointeur VTable au début de l'objet
;

: FREE ( obj-addr -- )
    FREE THROW
;

\ Sélecteur d'envoi explicite de message "->"
: -> ( obj-addr "method" -- )
    ' EXECUTE
;
