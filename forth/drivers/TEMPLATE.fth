\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        exemple-driver                                   ║
\ ║ Version:    0.1.0                                            ║
\ ║ Auteur:     <votre nom ou pseudo>                           ║
\ ║ License:    MIT                                              ║
\ ║ Description: Driver exemple (a copier pour un nouveau        ║
\ ║             peripherique)                                    ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   VVVV:DDDD  Description du materiel                        ║
\ ║                                                             ║
\ ║ Classe PCI:  <classe:subclasse, ex 02:00 = reseau>          ║
\ ║ Requiert:    (liste des drivers dependants, si applicable)   ║
\ ║ Statut:      experimental / testing / stable                 ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ ============================================================================
\ COMMENT UTILISER CE FICHIER
\ ----------------------------------------------------------------------------
\ 1. Copier ce fichier (ex : `cp TEMPLATE.fth mon-driver.fth`).
\ 2. Remplir l'en-tete ci-dessus et les metadonnees drv:* (nom, version,
\    license, description) — sections en bas.
\ 3. Declarer le materiel avec pci:add-id / pci:add-class.
\ 4. Ecrire drv:probe (test rapide), drv:init (init complete) et
\    drv:fini (arret propre). Les versions par defaut (drvlib.fth)
\    retournent TRUE sans rien faire : un driver qui ne definit pas
\    drv:init restera enregistre mais passera l'init par defaut.
\ 5. Terminer par `drv:register` (obligatoire).
\ 6. Ajouter une ligne `pci:entry <vid> <did> s" <chemin>"` dans
\    forth/config/drvmap.fth pour le chargement automatique au boot.
\
\ REGLES
\ - drv:init retourne -1 (TRUE) si OK, 0 (FALSE) sinon. Ne quitte jamais
\   le noyau en cas d'erreur : logguer avec drv:warn/drv:err et retourner 0.
\ - Memoire persistante : utiliser UNIQUEMENT `create <nom> <n> allot`
\   (espace `here`). NE PAS melanger `variable` et `create` (voir drvlib.fth).
\ - Acces materiel : BAR passee en argument de drv:init, pas d'adresse fixe.
\ - Handler d'IRQ court : pas de `type`, pas d'allocation.
\ ============================================================================

cr ." [DRV] chargement exemple-driver..." cr

\ --- Metadonnees obligatoires -----------------------------------------------
s" exemple-driver" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Driver exemple" drv:desc!

\ --- Type du driver (constantes definies dans drvlib.fth) --------------------
\ 0 Generic   1 Network   2 Audio   3 Storage   4 Input   5 Usb   6 Gpu
0 drv:type!

\ --- Table des IDs PCI supportes --------------------------------------------
\ Decommentez et completez pour declarer le materiel gere :
\ pci:add-id 0xVVVV 0xDDDD          \ correspondance exacte vendor:device
\ pci:add-class 0xCC 0xSS           \ correspondance classe:subclasse

\ --- Constantes du materiel (cf. datasheet) ----------------------------------
\ 0x00 constant REG-EXEMPLE

\ --- Memoire persistante du driver -------------------------------------------
\ create EXEMPLE-BUF 64 allot

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
\ Test rapide et sans effet de bord : le peripherique repond-il ?
\ Optionnel (la version par defaut retourne TRUE).
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    bar 0= if
        s" exemple-driver: BAR0 nulle, materiel absent" drv:warn
        0
    else
        \ TODO: lecture de test (ex: `bar mmio@`) pour confirmer la presence
        -1
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Initialisation complete du peripherique. Retourne -1 si OK, 0 sinon.
\ PAS de `exit` ici : les locals ne sont pas nettoyes par Op::Exit.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    bar 0= if
        s" exemple-driver: aucune BAR, init impossible" drv:err
        0
    else
        \ TODO: initialiser le materiel ici (reset, configuration, IRQ...)
        s" Driver exemple initialise" drv:ok
        -1
    then
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
\ Arret propre du materiel (optionnel, appele au dechargement).
: drv:fini  ( -- )
    s" Driver exemple arrete" drv:ok
;

\ --- Enregistrement officiel du driver ---------------------------------------
drv:register
