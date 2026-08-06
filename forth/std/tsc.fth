\ ============================================================================
\ tsc.fth — Minuterie TSC (DEV_GUIDE_DRIVER_AGENT.md §6.5)
\
\ Primitives déjà fournies par le noyau :
\   tsc:freq (854)  -> kHz de la TSC (après calibration)
\   tsc     (844)  -> compteur TSC
\   ms-delay(842) / us-delay (843) -> attente
\   ms      (20)   -> déjà une primitive (alias de `attendre`) : NE PAS
\                    redéfinir ici pour éviter le shadowing.
\
\ Mémoire : voir drvlib.fth — uniquement `create` (espace `here`), jamais
\ `variable`, pour éviter le chevauchement variables.len() / here.
\ ============================================================================

cr ." [TSC] minuterie pret" cr

create TICKS-PER-US
0 TICKS-PER-US !

\ calibrate-tsc ( -- ) : calcule ticks/microseconde depuis tsc:freq (kHz)
: calibrate-tsc ( -- )
    tsc:freq 1000 / TICKS-PER-US !
;

\ ticks-per-us ( -- n ) : valeur calculée par calibrate-tsc
: ticks-per-us ( -- n ) TICKS-PER-US @ ;

\ us ( n -- ) : attend n microsecondes (alias de la primitive us-delay)
: us ( n -- ) us-delay ;
