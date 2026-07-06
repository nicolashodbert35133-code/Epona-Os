\ Epona OS Boot Script
\ Execute automatiquement au demarrage

cr ." ========== Epona OS Boot ==========" cr

\ Alias Forth standard
: .s pile ;       \ .s affiche la pile non-destructif
: / /mod nip ;    \ / = /mod + nip  (division standard)
: mod /mod drop ; \ mod = /mod + drop (reste standard)

\ Charger les pilotes depuis drivers/
cr ." [Boot] Chargement des pilotes..." cr
sys:load drivers\mouse_usb.fth

\ Afficher les pilotes enregistres
cr ." [Boot] Pilotes:" cr
sys:drivers
cr

cr ." [Boot] Probe materiel..." cr
sys:probe
cr

cr ." ========== Boot termine ==========" cr