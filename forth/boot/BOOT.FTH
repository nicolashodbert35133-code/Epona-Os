\ ============================================================================
\ BOOT.FTH — Séquence de démarrage Epona (DEV_GUIDE_DRIVERS.md §6)
\ Chargé par la racine BOOT.FTH (loader) après config/default.fth.
\
\ L'autoload des drivers PCI (§6 étapes 2-7) est géré en Rust par
\ `drv_enumerate_and_load`, appelé automatiquement par main.rs après la
\ compilation de BOOT.FTH (bloc AUTO-BOOT). Ce script s'occupe donc de :
\   - l'initialisation matérielle (primitives init-*)
\   - la bascule UEFI -> runtime si AUTO-EXIT-UEFI (config/default.fth)
\   - le rapport de démarrage
\   - la définition du mot `principal` (entrée du runtime natif)
\
\ NOTE : n'utilisez PAS `init-fs` ici (elle relit et recompile BOOT.FTH).
\       `included` nécessite DISK_FS (bloc), indisponible pendant AUTO-BOOT.
\ ============================================================================

cr
." ============================================" cr
."   Epona OS — Séquence de démarrage"          cr
." ============================================" cr

\ --- 1. Initialisation matérielle (primitives noyau) --------------------------
xhci-init
init-gop
init-acpi
init-usb
init-drivers
init-scheduler
init-gfx
init-window

\ --- 2. Bascule UEFI -> runtime si demandée (config/default.fth) --------------
\ Le noyau (main.rs) surveille EXIT_UEFI_FLAG pendant la boucle de debug UEFI.
AUTO-EXIT-UEFI if
    exit-uefi
then

\ --- 3. Rapport de démarrage ---------------------------------------------------
cr
." === Démarrage Epona === " cr
." Initialisation matérielle terminée." cr
cr

\ --- 4. Word d'entrée du runtime natif ----------------------------------------
\ Exécuté par le noyau (run_slice) après `exit-uefi`.
\ Surchargez ce mot pour lancer le bureau : `: principal bureau ;`
: principal
    cr
    ." Epona OS — runtime natif actif." cr
;
