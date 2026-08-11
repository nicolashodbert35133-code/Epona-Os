\ ==============================================================================
\ c-epona/sdk/eponasys.fth - Processus, Threads et IA Locale pour C-Épona
\ ==============================================================================

INCLUDE c-epona/oof.fth

CLASS: Thread
    INT-FIELD: Thread.Id
    PTR-FIELD: Thread.EntryPoint

: THREAD-CREATE ( xt obj -- )
    >R
    R@ Thread.EntryPoint !
    R@ Thread.EntryPoint @ CREATE-THREAD-NAT R@ Thread.Id !
    RDROP
;

: THREAD-JOIN ( obj -- )
    >R
    R@ Thread.Id @ JOIN-THREAD-NAT
    RDROP
;

\ Interface IA Locale pour C-Épona
CLASS: LocalAI
    PTR-FIELD: AI.ModelName

: AI-PROMPT ( prompt-addr prompt-len resp-buf-addr max-len obj -- bytes-written )
    >R
    AI-QUERY-NAT
    RDROP
;
