\ ============================================================
\ TEST-NOUVELLES.FTH
\ Tests des primitives : depth, .s, forget
\ ============================================================
\ sys:load TEST-NOUVELLES.FTH

cr ." ==========================" cr
cr ."   Tests depth / .s / forget" cr
cr ." ==========================" cr

\ ─── depth ──────────────────────────────────────────────────
cr ." --- depth ---" cr

cr ." depth (pile vide) -> " depth . cr

10 20 30
cr ." depth apres 10 20 30 -> " depth . cr

drop drop drop
cr ." depth apres 3 drops -> " depth . cr

\ ─── .s ─────────────────────────────────────────────────────
cr ." --- .s (affichage non destructif) ---" cr

1 2 3 4 5
cr ." Pile: " .s cr
cr ." depth encore 5 -> " depth . cr
drop drop drop drop drop

\ ─── forget ─────────────────────────────────────────────────
cr ." --- forget ---" cr

\ On cree trois mots temporaires
: mot-a ." AAA " ;
: mot-b ." BBB " ;
: mot-c ." CCC " ;

cr ." Mots avant forget: " words cr

\ ' mot-a empile l'index de mot-a dans le dictionnaire
' mot-a
cr ." Index de mot-a: " . cr

\ forget supprime mot-a et tous les mots apres
' mot-a forget

cr ." Mots apres forget: " words cr

cr ." (verifie visuellement que mot-a/b/c ont disparu)" cr

cr ." ==========================" cr
cr ."   Tests termines" cr
cr ." ==========================" cr
