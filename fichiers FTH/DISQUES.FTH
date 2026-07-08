\ ============================================================
\  DISQUES.FTH — Exemple d'accès aux disques
\  Epona OS — EponaForth
\
\  Usage : exec DISQUES.FTH
\  Puis tapez : demo
\ ============================================================

\ Note : disk:ls, disk:read, disk:write prennent
\ le chemin comme token suivant, PAS de la pile.
\ Exemple : disk:ls /

\ ─── Initialisation ───────────────────────────────────────

: init-disque
    cr ." ============ DISQUES ============" cr
    disk:init
    dup 0= if
        ." AUCUN DISQUE DETECTE" cr
    else
        ." Disque initialise avec succes" cr
    then
;

\ ─── Lister un répertoire ─────────────────────────────────

: lister
    disk:ls /
;

: lister-epona
    disk:ls /EPONA
;

\ ─── Variables pour la lecture ────────────────────────────

variable bufaddr
variable buflen

\ ─── Lire et afficher un fichier ──────────────────────────

\ Chaque mot de lecture doit avoir le chemin compile
\ en dur (disk:read lit le token suivant a la compilation)

: lire-boot
    0x1000 bufaddr !
    bufaddr @
    disk:read /BOOT.FTH
    dup if
        buflen !
        cr ." --- BOOT.FTH (" buflen @ u. ." octets) ---" cr
        buflen @ 0 do
            bufaddr @ i + c@ emit
        loop
        cr
    else
        drop
        ." BOOT.FTH introuvable" cr
    then
;

: lire-disques
    0x1000 bufaddr !
    bufaddr @
    disk:read /DISQUES.FTH
    dup if
        buflen !
        cr ." --- DISQUES.FTH (" buflen @ u. ." octets) ---" cr
        buflen @ 0 do
            bufaddr @ i + c@ emit
        loop
        cr
    else
        drop
        ." DISQUES.FTH introuvable" cr
    then
;

\ ─── Infos mémoire ────────────────────────────────────────

: ram-info
    cr ." --- Memoire ---" cr
    mem-map
    cr ." Pages totales : " .
    cr ." Pages libres  : " .
    cr heap-used u. ." octets sur le heap" cr
;

\ ─── Menu ─────────────────────────────────────────────────

: menu
    cr
    ." ┌────────────────────────────────┐" cr
    ." │  1 — Initialiser le disque    │" cr
    ." │  2 — Lister la racine (/)     │" cr
    ." │  3 — Lister /EPONA            │" cr
    ." │  4 — Afficher BOOT.FTH        │" cr
    ." │  5 — Afficher DISQUES.FTH     │" cr
    ." │  6 — Infos memoire            │" cr
    ." │  0 — Quitter                  │" cr
    ." └────────────────────────────────┘" cr
    cr ." Choix : "
;

\ ─── Boucle principale ────────────────────────────────────

: demo
    begin
        menu
        touche 48 -         \ ASCII -> nombre
        dup 0 = if
            drop
            cr ." Au revoir !" cr
            exit
        then
        dup 1 = if
            drop init-disque
        else
        dup 2 = if
            drop cr ." Contenu de / :" cr lister
        else
        dup 3 = if
            drop cr ." Contenu de /EPONA :" cr lister-epona
        else
        dup 4 = if
            drop lire-boot
        else
        dup 5 = if
            drop lire-disques
        else
        dup 6 = if
            drop ram-info
        else
            drop
        then then then then then then then
        500 attendre
        0                \ continue la boucle (0 = ne pas quitter)
    until
;

\ ─── Version rapide ───────────────────────────────────────

: demo-rapide
    cr ." === DEMO RAPIDE ===" cr
    init-disque
    cr ." Contenu de la racine :" cr
    lister
    cr ." Contenu du fichier DISQUES.FTH :" cr
    lire-disques
;

\ ─── Message d'accueil ────────────────────────────────────

cr ." DISQUES.FTH charge." cr
cr ." Commandes :" cr
cr ."  demo         — Menu interactif" cr
cr ."  demo-rapide  — Demo automatique" cr
cr ."  init-disque  — Initialiser le disque" cr
cr ."  lister       — Lister la racine" cr
cr ."  lire-boot    — Afficher BOOT.FTH" cr
cr
