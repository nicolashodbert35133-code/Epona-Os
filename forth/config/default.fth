\ ============================================================================
\ default.fth — Configuration utilisateur Epona (DEV_GUIDE_DRIVERS.md §6, étape 1)
\ Chargé en premier par BOOT.FTH, avant toute initialisation matérielle.
\ Surchargez ces valeurs sur votre machine sans modifier BOOT.FTH.
\
\ Mémoire : uniquement `create` / `constant` / `value` (espace `here`), jamais
\ `variable`, pour éviter le chevauchement variables.len() / here.
\ ============================================================================

\ --- Couleurs du terminal ----------------------------------------------------
16 constant FG-GREEN          \ texte principal
0  constant BG-BLACK          \ fond d'écran

\ --- Écran -------------------------------------------------------------------
0  constant SCREEN-W          \ 0 = résolution GOP actuelle (par défaut)
0  constant SCREEN-H

\ --- Démarrage ---------------------------------------------------------------
0  constant AUTO-EXIT-UEFI    \ 1 = basculer en runtime natif à la fin de BOOT.FTH

\ --- Rappel des mots disponibles (voir PRIMITIVES_REFERENCE.md) --------------
\ init-gop init-acpi init-usb init-drivers init-scheduler init-gfx init-window
\ xhci-init init-fs exit-uefi included
