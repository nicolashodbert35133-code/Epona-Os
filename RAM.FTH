\ RAM.FTH — Demo d'affichage de la memoire systeme
\ Execute avec: ram-info

: ram-info ( -- )
    cr ." === MEMOIRE SYSTEME ===" cr
    mem-map                     \ -- total free
    over cr ." Pages totales : " . cr
    dup  cr ." Pages libres  : " . cr
    over 4 * cr ." RAM totale : " . ." KB" cr
    dup  4 * cr ." RAM libre  : " . ." KB" cr
    over 4 * 1024 / cr ." RAM totale : " . ." MB" cr
    dup  4 * 1024 / cr ." RAM libre  : " . ." MB" cr
    2drop
    cr ." === FIN ===" cr
;

cr ." RAM.FTH charge. Faites: ram-info" cr