

```forth
\ ════════════════════════════════════════════════════════════════════════
\                  EPONA OS — GUIDE DÉVELOPPEUR
\          Écrire des drivers, programmes et utilitaires
\                    en EponaForth (version 2026)
\ ════════════════════════════════════════════════════════════════════════
\
\ Ce fichier est à la fois :
\   - une documentation lisible (commentaires)
\   - du code exécutable (exemples fonctionnels)
\
\ Chargement : sys:load DEVGUIDE.FTH
\
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\                      TABLE DES MATIÈRES
\ ──────────────────────────────────────────────────────────────────────
\
\   PARTIE A — ARCHITECTURE DU RUNTIME
\     A1. Modèle mémoire
\     A2. Pile de données et pile de retour
\     A3. Dictionnaire et compilation
\     A4. Cycle de vie d'un mot
\     A5. Gestion des erreurs
\     A6. Multitâche
\
\   PARTIE B — ÉCRIRE UN DRIVER
\     B1. Anatomie d'un driver Forth
\     B2. Convention de nommage
\     B3. Accès aux ports I/O
\     B4. Accès MMIO
\     B5. Accès PCI
\     B6. Accès I2C
\     B7. Accès USB
\     B8. Interruptions
\     B9. Allocation mémoire physique
\     B10. Timing et délais
\     B11. Driver complet : UART 16550
\     B12. Driver complet : LED clavier PS/2
\     B13. Driver complet : lecteur de température CPU
\     B14. Driver complet : watchdog PCI
\
\   PARTIE C — ÉCRIRE UNE APPLICATION
\     C1. Application console
\     C2. Application graphique (Canvas)
\     C3. Application fenêtrée (Widgets)
\     C4. Application réseau
\     C5. Application disque
\     C6. Application complète : moniteur système
\     C7. Application complète : terminal série
\     C8. Application complète : éditeur hexadécimal
\
\   PARTIE D — ÉCRIRE UN SIMULATEUR
\     D1. Architecture d'un simulateur CPU
\     D2. Simulateur CHIP-8 complet
\     D3. Automate cellulaire (Jeu de la Vie)
\
\   PARTIE E — BONNES PRATIQUES
\     E1. Documentation des mots
\     E2. Gestion des erreurs
\     E3. Tests
\     E4. Performance
\     E5. Sécurité
\     E6. Portabilité
\
\   PARTIE F — RÉFÉRENCE RAPIDE
\     F1. Toutes les primitives par catégorie
\     F2. Codes d'erreur
\     F3. Constantes utiles
\     F4. Patterns courants
\
\ ──────────────────────────────────────────────────────────────────────


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE A — ARCHITECTURE DU RUNTIME
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ A1. MODÈLE MÉMOIRE
\ ──────────────────────────────────────────────────────────────────────
\
\ EponaForth utilise plusieurs zones mémoire distinctes :
\
\   ┌─────────────────────────────────────────────────────┐
\   │  Mémoire Forth (memory[])                           │
\   │  Vec<i64>, taille initiale 4096 cellules            │
\   │  Chaque cellule = 64 bits signés                    │
\   │                                                     │
\   │  [0..variables]     Variables Forth (@ ! +!)        │
\   │  [variables..here]  Données create/allot/,          │
\   │  [here..MAX_MEM]    Espace libre                    │
\   └─────────────────────────────────────────────────────┘
\
\   ┌─────────────────────────────────────────────────────┐
\   │  Pile de données (stack[])                          │
\   │  Vec<i64>, max 4096 éléments                        │
\   │  Notation : ( avant -- après )                      │
\   └─────────────────────────────────────────────────────┘
\
\   ┌─────────────────────────────────────────────────────┐
\   │  Pile de retour (rstack[])                          │
\   │  Vec<usize>, max 1024 éléments                      │
\   │  Utilisée par >r r> r@ (données utilisateur)        │
\   │  Séparée de loop_rstack pour DO/LOOP               │
\   └─────────────────────────────────────────────────────┘
\
\   ┌─────────────────────────────────────────────────────┐
\   │  Mémoire physique (alloc-phys / free-phys)          │
\   │  Pages 4 KB allouées via UEFI Boot Services         │
\   │  Utilisée pour DMA, buffers matériels               │
\   │  ATTENTION : adresses physiques réelles (pas Forth) │
\   └─────────────────────────────────────────────────────┘
\
\   ┌─────────────────────────────────────────────────────┐
\   │  Canvas Forth (400 × 300 pixels, 32 bpp)            │
\   │  Zone protégée pour le dessin graphique              │
\   │  Accessible via : pixel rect ligne effacer          │
\   └─────────────────────────────────────────────────────┘
\
\ IMPORTANT — adresses Forth vs adresses physiques :
\
\   Les mots @ ! +! travaillent sur memory[] (indices Forth).
\   Les mots c@ c! w@ w! l@ l! mmio@ mmio! travaillent sur
\   des adresses physiques (pointeurs mémoire réels).
\   Les mots phys@ phys! travaillent sur des adresses 64-bit.
\
\   NE PAS confondre :
\     42 monvar !          ← écrit 42 dans memory[monvar]
\     42 0xFEE00000 mmio!  ← écrit 42 à l'adresse physique
\
\ Limites :
\   - memory[] : 4096 cellules par défaut (extensible via allot)
\   - MAX_MEM : 4096 cellules maximum
\   - Pile : 4096 éléments maximum
\   - Rstack : 1024 éléments maximum
\   - Dictionnaire : 2048 mots maximum
\   - Instructions : 10 millions par exécution (anti-boucle infinie)


\ ──────────────────────────────────────────────────────────────────────
\ A2. PILE DE DONNÉES ET PILE DE RETOUR
\ ──────────────────────────────────────────────────────────────────────
\
\ La pile de données est le mécanisme central de Forth.
\ Tous les paramètres et résultats passent par la pile.
\
\ Convention de documentation :
\   ( avant -- après )
\   ( entrées -- sorties )
\
\ Exemples :
\   ( n -- n*2 )           Un entier entre, son double sort
\   ( addr -- val )        Une adresse entre, sa valeur sort
\   ( x y color -- )       Trois valeurs consommées, rien produit
\   ( -- n )               Rien consommé, un nombre produit
\   ( n -- n | 0 )         Retourne n ou 0 selon condition
\
\ Règle d'or : TOUJOURS documenter l'effet sur la pile.
\ Un mot non documenté est un mot inutilisable.
\
\ La pile de retour (rstack) sert à :
\   1. Stocker temporairement des valeurs (>r r> r@)
\   2. NE PAS mélanger avec les boucles DO/LOOP
\      (qui utilisent loop_rstack séparé)
\
\ Exemple — sauvegarde temporaire :
\   : echange3 ( a b c -- c b a )
\     >r swap r> swap ;
\
\ Piège classique : oublier de reprendre avec r>
\   : BUGGY >r ... ;   ← CRASH : r> manquant
\   : OK    >r ... r> drop ;   ← correct


\ ──────────────────────────────────────────────────────────────────────
\ A3. DICTIONNAIRE ET COMPILATION
\ ──────────────────────────────────────────────────────────────────────
\
\ Le dictionnaire contient tous les mots Forth :
\   - Primitives (implémentées en Rust, ~285 mots)
\   - Mots compilés (définis par l'utilisateur)
\   - Constantes, variables, create/does>
\
\ Quand vous tapez un mot :
\
\   En mode IMMÉDIAT (state=0) :
\     Nombre     → empilé directement
\     Variable   → adresse empilée
\     Primitive  → exécutée immédiatement
\     Mot compilé → exécuté immédiatement
\
\   En mode COMPILATION (state=1, entre : et ;) :
\     Nombre     → Op::Push(n) ajouté aux ops
\     Variable   → Op::VariableAddr(n) ajouté
\     Primitive  → Op::CallPrim(idx) ajouté
\     Mot compilé → Op::Call(dict_idx) ajouté
\     Mot IMMÉDIAT → exécuté pendant la compilation !
\
\ Le bytecode interne (Op) :
\
\   Op::Push(val)         — Empile une valeur
\   Op::Call(idx)         — Appelle un mot compilé
\   Op::CallPrim(idx)     — Appelle une primitive Rust
\   Op::Jump(target)      — Saut inconditionnel
\   Op::JumpIfZero(tgt)   — Saut si pile=0
\   Op::VariableAddr(n)   — Empile adresse variable
\   Op::Exit              — Retour d'un mot
\   Op::Do/Loop/...       — Boucles
\   Op::Try/Catch/Throw   — Exceptions
\
\ Voir les ops d'un mot :
\   see monmot              (affiche le bytecode)
\   word-info monmot        (affiche les métadonnées)


\ ──────────────────────────────────────────────────────────────────────
\ A4. CYCLE DE VIE D'UN MOT
\ ──────────────────────────────────────────────────────────────────────
\
\ 1. DÉFINITION :
\      : mon-mot ( stack -- effect )
\        ... corps ...
\      ;
\
\ 2. COMPILATION : le compilateur transforme le source en Vec<Op>
\
\ 3. STOCKAGE : le mot est ajouté au dictionnaire
\      Si un mot du même nom existe, il est REMPLACÉ (redéfinition)
\
\ 4. EXÉCUTION : execute_ops_limited() parcourt les Op
\
\ 5. SUPPRESSION (optionnel) :
\      forget ( idx -- )        Tronque le dictionnaire
\      marker ---clean---       Point de restauration
\
\ Redéfinition :
\   : test 1 . ;
\   : test 2 . ;    ← remplace l'ancienne définition
\   test             → affiche 2
\
\ ATTENTION : les mots qui appelaient l'ancien "test"
\ appellent maintenant le nouveau (liaison dynamique par index).


\ ──────────────────────────────────────────────────────────────────────
\ A5. GESTION DES ERREURS
\ ──────────────────────────────────────────────────────────────────────
\
\ EponaForth offre 3 niveaux de gestion d'erreur :
\
\ Niveau 1 — Vérification implicite :
\   - Stack overflow détecté (> 4096)
\   - Division par zéro → retourne 0
\   - Adresse mémoire hors bornes → message + ignore
\   - Mot inconnu → erreur de compilation
\
\ Niveau 2 — Exceptions try/catch/throw :

: demo-exception ( -- )
  try
    ." Tentative..." cr
    42 throw
    ." Jamais atteint" cr
    0
  catch
    ." Exception attrapee: " . cr
  endtry
;

\ Niveau 3 — abort" (arrêt conditionnel) :
\   : check ( n -- )
\     dup 0 < abort" Valeur negative interdite !"
\     drop ;
\
\ Conventions pour les drivers :
\   - Retourner ok? (1=succès, 0=échec) quand possible
\   - Utiliser throw avec des codes définis
\   - Documenter les codes d'erreur

\ Codes d'erreur recommandés pour les drivers :
\   -1   Erreur générique
\   -2   Timeout
\   -3   Périphérique non trouvé
\   -4   Erreur de communication
\   -5   Buffer trop petit
\   -6   Opération non supportée
\   -7   Permission refusée (secure mode)
\   -8   Ressource occupée


\ ──────────────────────────────────────────────────────────────────────
\ A6. MULTITÂCHE
\ ──────────────────────────────────────────────────────────────────────
\
\ EponaForth supporte le multitâche préemptif :
\
\   - Le PIT (timer) émet un IRQ toutes les ~10 ms
\   - Le scheduler round-robin alterne entre les tâches
\   - Chaque tâche a sa propre pile et rstack
\   - Le dictionnaire est PARTAGÉ (attention aux conflits !)
\
\ Créer une tâche :
\   : ma-tache
\     begin
\       ." ." 100 ms
\     again ;
\   ' ma-tache task   \ → tid sur la pile
\
\ Lister les tâches :
\   tasks
\
\ Arrêter la tâche courante :
\   stop
\
\ ATTENTION — problèmes courants :
\   - Les variables sont partagées entre tâches
\   - Pas de mutex/sémaphore (pas encore implémenté)
\   - Une tâche qui crashe n'affecte pas les autres
\   - Limite de ~2000 instructions par tranche de temps


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE B — ÉCRIRE UN DRIVER
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ B1. ANATOMIE D'UN DRIVER FORTH
\ ──────────────────────────────────────────────────────────────────────
\
\ Un driver Forth suit cette structure :
\
\   1. CONSTANTES : adresses, registres, valeurs magiques
\   2. VARIABLES : état interne du driver
\   3. MOTS BAS NIVEAU : lecture/écriture registres
\   4. MOTS D'INITIALISATION : probe, reset, config
\   5. MOTS D'INTERFACE : read, write, status
\   6. ENREGISTREMENT : sys:register
\   7. TESTS : auto-vérification
\
\ Convention de nommage :
\   <driver>:init     — Initialisation
\   <driver>:read     — Lecture
\   <driver>:write    — Écriture
\   <driver>:status   — État
\   <driver>:info     — Affichage d'information
\   <driver>:close    — Fermeture / cleanup
\   <driver>-init     — Mot appelé par sys:probe
\
\ Squelette minimal :

\ --- Début du squelette ---

\ : mondriver:init ( -- ok? )
\   \ 1. Détecter le matériel
\   \ 2. Configurer les registres
\   \ 3. Retourner 1 si OK, 0 si échec
\   1
\ ;
\
\ : mondriver:read ( -- val )
\   \ Lire une donnée depuis le matériel
\   0
\ ;
\
\ : mondriver:write ( val -- )
\   \ Écrire une donnée vers le matériel
\   drop
\ ;
\
\ : mondriver:status ( -- ok? )
\   \ Vérifier que le matériel fonctionne
\   1
\ ;
\
\ : mondriver:info ( -- )
\   ." MonDriver v1.0" cr
\   ." Status: " mondriver:status if ." OK" else ." ERREUR" then cr
\ ;
\
\ : mondriver-init ( -- )
\   mondriver:init if
\     ." MonDriver initialise" cr
\   else
\     ." MonDriver: echec init" cr
\   then
\ ;
\
\ sys:register mondriver

\ --- Fin du squelette ---


\ ──────────────────────────────────────────────────────────────────────
\ B2. CONVENTION DE NOMMAGE
\ ──────────────────────────────────────────────────────────────────────
\
\ Préfixes par catégorie :
\
\   uart:     — Communication série
\   spi:      — Bus SPI
\   gpio:     — Entrées/sorties numériques
\   rtc:      — Horloge temps réel
\   temp:     — Capteurs de température
\   fan:      — Contrôle ventilateur
\   led:      — LEDs
\   wdog:     — Watchdog timer
\   can:      — Bus CAN
\   midi:     — Protocole MIDI
\
\ Suffixes standards :
\
\   :init     — Initialisation unique
\   :probe    — Détection matériel
\   :reset    — Réinitialisation
\   :read     — Lecture de données
\   :write    — Écriture de données
\   :status   — État courant
\   :info     — Affichage d'informations
\   :config   — Configuration
\   :close    — Fermeture / libération
\   :test     — Auto-test
\
\ Constantes liées au driver :
\   UART-BASE      — Adresse de base
\   UART-IRQ       — Numéro d'interruption
\   UART-BAUD      — Vitesse par défaut
\
\ Variables liées au driver :
\   uart-ready     — Flag d'initialisation
\   uart-errors    — Compteur d'erreurs


\ ──────────────────────────────────────────────────────────────────────
\ B3. ACCÈS AUX PORTS I/O
\ ──────────────────────────────────────────────────────────────────────
\
\ Les ports I/O x86 sont accessibles via :
\
\   inb  ( port -- byte )    Lecture 8-bit
\   outb ( byte port -- )    Écriture 8-bit
\   inw  ( port -- word )    Lecture 16-bit
\   outw ( word port -- )    Écriture 16-bit
\   inl  ( port -- long )    Lecture 32-bit
\   outl ( long port -- )    Écriture 32-bit
\
\ ATTENTION : l'ordre des paramètres pour outb est
\ ( byte port -- ) donc la VALEUR est SOUS le PORT.
\
\ Exemple — lire le registre de statut du port série COM1 :

0x3F8 constant COM1-BASE
0x3FD constant COM1-LSR     \ Line Status Register

: com1-ready? ( -- flag )
  COM1-LSR inb 0x20 and 0<> ;

: com1-data? ( -- flag )
  COM1-LSR inb 0x01 and 0<> ;

\ Exemple — écrire un octet sur COM1 :

: com1-tx ( char -- )
  begin com1-ready? until
  COM1-BASE outb ;

\ Exemple — lire un octet depuis COM1 :

: com1-rx ( -- char | -1 )
  com1-data? if
    COM1-BASE inb
  else
    -1
  then ;

\ Pattern d'attente avec timeout :

: wait-port ( port mask timeout_ms -- ok? )
  \ Attend que (port inb AND mask) != 0
  \ Retourne 0 si timeout
  0 do
    over inb over and 0<> if
      2drop 1 unloop exit
    then
    1 ms
  loop
  2drop 0 ;


\ ──────────────────────────────────────────────────────────────────────
\ B4. ACCÈS MMIO
\ ──────────────────────────────────────────────────────────────────────
\
\ MMIO = Memory-Mapped I/O. Les registres matériels sont
\ mappés dans l'espace d'adressage physique.
\
\   mmio@ ( addr -- val )     Lecture 32-bit
\   mmio! ( val addr -- )     Écriture 32-bit
\   c@    ( addr -- byte )    Lecture 8-bit
\   c!    ( byte addr -- )    Écriture 8-bit
\   w@    ( addr -- word )    Lecture 16-bit
\   w!    ( word addr -- )    Écriture 16-bit
\   l@    ( addr -- long )    Lecture 32-bit (= mmio@)
\   l!    ( long addr -- )    Écriture 32-bit (= mmio!)
\
\ ATTENTION : ces mots accèdent à la mémoire PHYSIQUE,
\ pas à la mémoire Forth (memory[]). Une mauvaise adresse
\ peut crasher le système ou corrompre le matériel.
\
\ Pattern courant — registres d'un contrôleur :

\ : reg@ ( base offset -- val )
\   + mmio@ ;
\
\ : reg! ( val base offset -- )
\   + mmio! ;
\
\ : reg-set ( mask base offset -- )
\   \ Met à 1 les bits du masque
\   2dup + mmio@        \ lire la valeur actuelle
\   rot or              \ OR avec le masque
\   swap + mmio! ;      \ écrire
\
\ : reg-clear ( mask base offset -- )
\   \ Met à 0 les bits du masque
\   2dup + mmio@
\   rot invert and
\   swap + mmio! ;

\ Pattern — attente d'un bit dans un registre MMIO :

: mmio-wait ( base offset mask timeout_ms -- ok? )
  0 do
    2 pick 2 pick + mmio@
    over and 0<> if
      2drop 2drop 1 unloop exit
    then
    1 ms
  loop
  2drop 2drop 0 ;


\ ──────────────────────────────────────────────────────────────────────
\ B5. ACCÈS PCI
\ ──────────────────────────────────────────────────────────────────────
\
\ Le bus PCI est le mécanisme principal de détection matériel.
\
\   pci-scan ( -- count )
\     Scanne tout le bus, retourne le nombre de périphériques
\
\   pci-dev ( idx -- bus dev func vid did class sub )
\     Retourne les infos d'un périphérique par index
\
\   pci@ ( bus dev func off -- val )
\     Lit un registre de configuration PCI (32 bits)
\
\   pci! ( val bus dev func off -- )
\     Écrit un registre de configuration PCI
\
\   pci-bar ( bus dev func barn -- addr size flag [type pref] )
\     Lit un BAR (Base Address Register)
\
\ Exemple — trouver un périphérique par vendor/device ID :

: pci-find-device ( vid did -- bus dev func | -1 )
  pci-scan 0 ?do
    i pci-dev              \ -- bus dev func vid did class sub
    drop drop              \ -- bus dev func vid did
    4 pick = if            \ did match ?
      3 pick = if          \ vid match ?
        \ Trouvé ! Nettoyer et retourner bus dev func
        2drop              \ drop copies
        unloop exit
      else
        drop
      then
    else
      2drop
    then
    drop drop drop         \ nettoyer bus dev func
  loop
  2drop                    \ nettoyer vid did cherchés
  -1 ;

\ Exemple — lire le BAR0 d'un périphérique :

: pci-get-bar0 ( bus dev func -- addr | 0 )
  0 pci-bar                \ -- addr size flag [type pref]
  dup 1 = if               \ I/O BAR
    drop drop              \ -- addr
  else                     \ Memory BAR
    drop drop drop         \ -- addr (ignorer type et pref)
  then ;

\ Pattern — scanner pour une classe PCI :

: pci-find-class ( class sub -- idx | -1 )
  pci-scan 0 ?do
    i pci-dev              \ -- bus dev func vid did class sub
    3 pick = if            \ sub match ?
      over = if            \ class match ?
        drop drop drop drop drop
        2drop
        i unloop exit
      then
    then
    drop drop drop drop drop drop drop
  loop
  2drop -1 ;


\ ──────────────────────────────────────────────────────────────────────
\ B6. ACCÈS I2C
\ ──────────────────────────────────────────────────────────────────────
\
\ Le bus I2C sert aux périphériques intégrés (touchpad, capteurs).
\
\   dw-i2c-init  ( base -- ok? )
\     Initialise un contrôleur DesignWare I2C
\
\   dw-i2c-probe ( base addr -- ok? )
\     Teste si un périphérique répond à l'adresse
\
\   i2c.probe    ( base -- )
\     Scanne toutes les adresses HID connues
\
\   i2c-read     ( base dev reg -- val | -1 )
\     Lit un registre 8-bit
\
\ Exemple — scanner un bus I2C :

: i2c-scan-all ( base -- )
  ." Scan I2C bus a 0x" dup hex . decimal cr
  dup dw-i2c-init 0= if
    drop ." Init echec" cr exit
  then
  128 0 do
    dup i dw-i2c-probe if
      ."   0x" i hex . decimal ."  -> PRESENT" cr
    then
  loop
  drop ;

\ Exemple — lire un capteur de température I2C :

: i2c-temp-read ( base addr -- celsius | -1 )
  \ Registre 0 = température sur la plupart des capteurs
  0 i2c-read
  dup -1 = if exit then
  \ Conversion simple (dépend du capteur)
  \ LM75 : valeur sur 9 bits, résolution 0.5°C
  2/ ;


\ ──────────────────────────────────────────────────────────────────────
\ B7. ACCÈS USB
\ ──────────────────────────────────────────────────────────────────────
\
\ L'USB est accessible via le contrôleur XHCI.
\
\   usb:init    ( -- ok? )           Initialise XHCI
\   usb:devices ( -- n s1 p1 ... )   Liste les périphériques
\   usb:control ( slot bm br wv wi buf len -- actual )
\     Transfert de contrôle EP0
\   usb:bulk-read  ( slot ep buf len -- actual )
\   usb:bulk-write ( slot ep buf len -- actual )
\   usb:config-ep  ( slot ep attr mps interval -- ok? )
\
\ Les buffers Forth sont automatiquement copiés vers/depuis
\ des pages physiques DMA. Pas besoin d'alloc-phys manuellement.
\
\ Exemple — lire le descripteur de périphérique :

: usb-get-descriptor ( slot -- )
  \ GET_DESCRIPTOR(Device), type=1, index=0
  0x80 6 0x0100 0 100 18 usb:control
  dup 0 > if
    ." Descripteur (" . ." octets) :" cr
    18 0 do
      100 i + @ hex . decimal
    loop cr
  else
    drop ." Echec lecture descripteur" cr
  then ;

\ Exemple — lire depuis un périphérique MSD :

: usb-read-sector ( -- )
  usb:msd-probe dup 0 = if
    drop ." Aucun disque USB" cr exit
  then
  drop
  \ Lire le secteur 0 (MBR) du premier disque
  0 0 1 1000 usb:msd-read if
    ." MBR lu. Signature: "
    1000 510 + @ hex . decimal cr
  else
    ." Echec lecture MBR" cr
  then ;


\ ──────────────────────────────────────────────────────────────────────
\ B8. INTERRUPTIONS
\ ──────────────────────────────────────────────────────────────────────
\
\ EponaForth peut associer un mot Forth à un vecteur d'interruption.
\
\   irq-handler ( vector dict_idx -- )
\     Associe un mot Forth au vecteur IRQ donné
\
\ ATTENTION : le mot Forth sera exécuté dans un contexte spécial.
\ Il doit être court et ne pas faire d'allocation.
\
\ Exemple — handler pour IRQ1 (clavier) :

\ : mon-handler-clavier ( -- )
\   0x60 inb              \ Lire le scancode
\   dup 0x1C = if         \ Entrée pressée ?
\     drop
\     ." [ENTER]"
\   else
\     drop
\   then
\ ;
\
\ : installer-handler ( -- )
\   ' mon-handler-clavier 33 irq-handler
\   \ 33 = vecteur IDT pour IRQ1
\ ;

\ Pattern — compteur d'interruptions :

variable irq-count

: irq-counter ( -- )
  1 irq-count +! ;


\ ──────────────────────────────────────────────────────────────────────
\ B9. ALLOCATION MÉMOIRE PHYSIQUE
\ ──────────────────────────────────────────────────────────────────────
\
\ Pour le DMA et les buffers matériels, il faut de la mémoire
\ physique contiguë, pas de la mémoire Forth.
\
\   alloc-phys ( pages -- addr | 0 )
\     Alloue des pages physiques (4 KB chacune)
\
\   free-phys  ( addr pages -- ok? )
\     Libère des pages physiques
\
\   phys@ ( addr -- val )    Lit 64-bit en mémoire physique
\   phys! ( val addr -- )    Écrit 64-bit en mémoire physique
\
\ IMPORTANT : toujours libérer avec free-phys après usage !
\
\ Exemple — allouer un buffer DMA de 4 KB :

: demo-alloc-phys ( -- )
  1 alloc-phys                  \ 1 page = 4096 octets
  dup 0 = if
    drop ." Allocation echouee" cr exit
  then
  dup ." Buffer physique a 0x" hex . decimal cr

  \ Écrire quelque chose
  dup 0x12345678 swap l!

  \ Lire et vérifier
  dup l@ 0x12345678 = if
    ." Verification OK" cr
  else
    ." Verification ECHEC" cr
  then

  \ Libérer
  1 free-phys if
    ." Libere OK" cr
  else
    ." Liberation echouee" cr
  then ;

\ Pattern — buffer DMA avec nettoyage garanti :

: with-phys-buffer ( pages xt -- )
  \ Alloue, exécute xt avec l'adresse sur la pile, libère
  \ xt = ( phys_addr -- )
  swap dup >r                  \ sauver pages
  alloc-phys dup 0 = if
    drop r> drop
    ." Allocation echouee" cr exit
  then
  dup >r                       \ sauver addr
  swap execute                 \ exécuter xt
  r> r> free-phys drop ;      \ libérer


\ ──────────────────────────────────────────────────────────────────────
\ B10. TIMING ET DÉLAIS
\ ──────────────────────────────────────────────────────────────────────
\
\   ms       ( n -- )      Pause en millisecondes (calibré RDTSC)
\   attendre ( n -- )      Alias de ms
\   stall    ( us -- )     Délai via UEFI (microsecondes)
\   stall-us ( us -- )     Délai via RDTSC (microsecondes)
\   ticks    ( -- ms )     Millisecondes depuis le démarrage
\   rdtsc    ( -- tsc )    Compteur CPU brut
\
\ Exemple — mesurer le temps d'exécution :

: benchmark ( xt -- ms )
  ticks swap execute ticks swap - ;

\ Utilisation :
\   ' mon-mot benchmark . ." ms" cr

\ Exemple — timeout avec ticks :

: wait-with-timeout ( xt timeout_ms -- ok? )
  \ xt = ( -- flag ) mot qui retourne vrai quand c'est prêt
  ticks +                      \ deadline
  begin
    over execute if            \ condition remplie ?
      2drop 1 exit
    then
    ticks over >= if           \ timeout ?
      2drop 0 exit
    then
    1 ms
  again ;

\ Pattern — polling périodique :

: poll-loop ( interval_ms xt -- )
  \ Exécute xt toutes les interval_ms
  \ Quitte si touche Échap
  begin
    dup execute
    over ms
    touche? 27 =
  until
  2drop ;


\ ──────────────────────────────────────────────────────────────────────
\ B11. DRIVER COMPLET : UART 16550
\ ──────────────────────────────────────────────────────────────────────
\
\ Le UART 16550 est le port série standard des PC.
\ COM1 = 0x3F8, COM2 = 0x2F8, COM3 = 0x3E8, COM4 = 0x2E8

\ --- Constantes ---

0x3F8 constant UART-BASE
0x3F8 constant UART-THR      \ Transmit Holding Register
0x3F8 constant UART-RBR      \ Receive Buffer Register
0x3F9 constant UART-IER      \ Interrupt Enable Register
0x3FA constant UART-IIR      \ Interrupt Identification Register
0x3FA constant UART-FCR      \ FIFO Control Register
0x3FB constant UART-LCR      \ Line Control Register
0x3FC constant UART-MCR      \ Modem Control Register
0x3FD constant UART-LSR      \ Line Status Register
0x3FE constant UART-MSR      \ Modem Status Register
0x3FF constant UART-SCR      \ Scratch Register

\ --- Bits de statut ---

0x01 constant LSR-DATA-READY
0x20 constant LSR-TX-EMPTY
0x40 constant LSR-TX-IDLE

\ --- Variables ---

variable uart-initialized
variable uart-tx-count
variable uart-rx-count
variable uart-errors

\ --- Mots bas niveau ---

: uart-lsr@ ( -- byte )
  UART-LSR inb ;

: uart-tx-ready? ( -- flag )
  uart-lsr@ LSR-TX-EMPTY and 0<> ;

: uart-rx-ready? ( -- flag )
  uart-lsr@ LSR-DATA-READY and 0<> ;

\ --- Initialisation ---

: uart:init ( baud -- ok? )
  \ Calculer le diviseur (115200 / baud)
  115200 swap /

  \ Désactiver les interruptions
  0 UART-IER outb

  \ Activer DLAB pour configurer le diviseur
  0x80 UART-LCR outb

  \ Diviseur (16 bits : low + high)
  dup 0xFF and UART-BASE outb
  8 rshift 0xFF and UART-BASE 1+ outb

  \ 8 bits, pas de parité, 1 stop bit (8N1)
  0x03 UART-LCR outb

  \ Activer et réinitialiser les FIFOs, seuil 14 octets
  0xC7 UART-FCR outb

  \ Activer DTR + RTS + OUT2
  0x0B UART-MCR outb

  \ Test loopback
  0x1E UART-MCR outb    \ Passer en mode loopback
  0xAE UART-BASE outb   \ Envoyer un octet test
  100 0 do
    uart-rx-ready? if leave then
    1 ms
  loop
  UART-BASE inb 0xAE = if
    \ Loopback OK → revenir en mode normal
    0x0B UART-MCR outb
    1 uart-initialized !
    0 uart-tx-count !
    0 uart-rx-count !
    0 uart-errors !
    1                    \ OK
  else
    0 uart-initialized !
    0                    \ Échec
  then ;

\ --- Interface publique ---

: uart:tx ( char -- )
  uart-initialized @ 0= if drop exit then
  \ Attendre que le transmetteur soit prêt (timeout 10ms)
  10 0 do
    uart-tx-ready? if leave then
    1 ms
  loop
  uart-tx-ready? 0= if
    1 uart-errors +!
    drop exit
  then
  UART-BASE outb
  1 uart-tx-count +! ;

: uart:rx ( -- char | -1 )
  uart-initialized @ 0= if -1 exit then
  uart-rx-ready? if
    UART-BASE inb
    1 uart-rx-count +!
  else
    -1
  then ;

: uart:puts ( addr len -- )
  0 ?do
    dup i + @ 0xFF and uart:tx
  loop
  drop ;

: uart:info ( -- )
  ." === UART 16550 ===" cr
  ." Base: 0x" UART-BASE hex . decimal cr
  ." Init: " uart-initialized @ if ." OUI" else ." NON" then cr
  ." TX: " uart-tx-count @ . cr
  ." RX: " uart-rx-count @ . cr
  ." Erreurs: " uart-errors @ . cr ;

: uart:status ( -- ok? )
  uart-initialized @ ;

\ --- Mot pour sys:probe ---

: uart-init ( -- )
  115200 uart:init if
    ." UART 16550 initialise (115200 8N1)" cr
  else
    ." UART 16550: echec" cr
  then ;

sys:register uart

\ --- Test ---

: uart:test ( -- )
  ." Test UART... " cr
  115200 uart:init if
    ." Init OK" cr
    65 uart:tx    \ Envoyer 'A'
    66 uart:tx    \ Envoyer 'B'
    ." 2 octets envoyes" cr
    uart:info
  else
    ." Init ECHEC" cr
  then ;


\ ──────────────────────────────────────────────────────────────────────
\ B12. DRIVER COMPLET : LED CLAVIER PS/2
\ ──────────────────────────────────────────────────────────────────────
\
\ Contrôle les LEDs Num Lock, Caps Lock, Scroll Lock
\ via le contrôleur PS/2 (port 0x60/0x64).

0x60 constant KBD-DATA
0x64 constant KBD-STATUS

variable kbd-leds    \ bits: 0=ScrollLock 1=NumLock 2=CapsLock

: kbd-wait-input ( -- ok? )
  \ Attendre que le buffer d'entrée soit vide
  100 0 do
    KBD-STATUS inb 0x02 and 0= if 1 unloop exit then
    1 ms
  loop
  0 ;

: kbd-send ( byte -- ok? )
  kbd-wait-input 0= if drop 0 exit then
  KBD-DATA outb
  \ Attendre ACK (0xFA)
  100 0 do
    KBD-STATUS inb 0x01 and 0<> if
      KBD-DATA inb 0xFA = if 1 unloop exit then
    then
    1 ms
  loop
  0 ;

: led:set ( mask -- )
  \ mask : bit0=Scroll bit1=Num bit2=Caps
  7 and kbd-leds !
  0xED kbd-send drop          \ Commande SET_LEDS
  kbd-leds @ kbd-send drop ;  \ Valeur des LEDs

: led:on ( bit -- )
  kbd-leds @ or led:set ;

: led:off ( bit -- )
  invert kbd-leds @ and led:set ;

: led:toggle ( bit -- )
  kbd-leds @ xor led:set ;

: led:numlock    2 led:toggle ;
: led:capslock   4 led:toggle ;
: led:scrolllock 1 led:toggle ;

\ Animation de LEDs :
: led:knight-rider ( n -- )
  0 ?do
    1 led:set 100 ms
    2 led:set 100 ms
    4 led:set 100 ms
    2 led:set 100 ms
  loop
  0 led:set ;

\ Test :
: led:test ( -- )
  ." Test LEDs clavier..." cr
  3 led:knight-rider
  ." Termine" cr ;


\ ──────────────────────────────────────────────────────────────────────
\ B13. DRIVER COMPLET : TEMPÉRATURE CPU
\ ──────────────────────────────────────────────────────────────────────
\
\ Lit la température CPU via le MSR IA32_THERM_STATUS
\ et IA32_TEMPERATURE_TARGET (Intel seulement).

0x19C constant MSR-THERM-STATUS
0x1A2 constant MSR-TEMP-TARGET

variable cpu-tj-max    \ Température de junction maximale

: temp:init ( -- ok? )
  \ Vérifier si c'est un CPU Intel
  0 cpuid drop drop drop   \ leaf 0 → vendor string
  \ Lire Tj_max depuis MSR_TEMPERATURE_TARGET
  try
    MSR-TEMP-TARGET msr@
    drop                    \ ignorer edx
    16 rshift 0xFF and      \ bits 23:16 = Tj_max
    dup 0 > if
      cpu-tj-max !
      1
    else
      drop
      100 cpu-tj-max !      \ par défaut 100°C
      1
    then
    0
  catch
    drop
    100 cpu-tj-max !
    1                       \ continuer même en cas d'erreur MSR
  endtry ;

: temp:read ( -- celsius | -1 )
  try
    MSR-THERM-STATUS msr@
    drop                      \ ignorer edx
    dup 0x80000000 and 0= if  \ bit 31 = Reading Valid
      drop -1
    else
      16 rshift 0x7F and      \ bits 22:16 = DTS (distance to Tj)
      cpu-tj-max @ swap -     \ température = Tj_max - DTS
    then
    0
  catch
    drop -1
  endtry ;

: temp:info ( -- )
  ." === Temperature CPU ===" cr
  ." Tj_max: " cpu-tj-max @ . ." C" cr
  ." Actuelle: "
  temp:read dup -1 = if
    drop ." indisponible"
  else
    . ." C"
  then cr ;

: temp-init ( -- )
  temp:init if
    ." Capteur temperature CPU initialise" cr
  else
    ." Capteur temperature: echec" cr
  then ;

sys:register temp


\ ──────────────────────────────────────────────────────────────────────
\ B14. DRIVER COMPLET : WATCHDOG PCI (Intel TCO)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le watchdog Intel TCO est intégré au southbridge.
\ Il redémarre le PC si on ne le "nourrit" pas régulièrement.

variable tco-base
variable wdog-active

: wdog:find-tco ( -- ok? )
  \ Le TCO est dans le LPC/eSPI bridge (class 0x06, sub 0x01)
  pci-scan 0 ?do
    i pci-dev
    \ -- bus dev func vid did class sub
    dup 0x01 = if       \ subclass = ISA bridge
      over 0x06 = if    \ class = bridge
        drop drop       \ sub class
        drop            \ did
        drop            \ vid
        \ Lire TCO base depuis registre PCI 0x50
        2dup 0 0x50 pci@
        0xFFE0 and tco-base !
        drop drop drop  \ func dev bus
        tco-base @ 0 > if
          1 unloop exit
        then
        i 1+ 0 ?do loop \ skip à la fin
      else
        drop drop drop drop drop drop drop
      then
    else
      drop drop drop drop drop drop drop
    then
  loop
  0 ;

: wdog:init ( seconds -- ok? )
  wdog:find-tco 0= if
    ." TCO non trouve" cr 0 exit
  then
  \ Désactiver le watchdog d'abord
  tco-base @ 8 + inw 0x0800 or tco-base @ 8 + outw
  \ Configurer le timeout
  tco-base @ 0x12 + inw 0xFC00 and or
  tco-base @ 0x12 + outw
  \ Activer
  tco-base @ 8 + inw 0xF7FF and tco-base @ 8 + outw
  1 wdog-active !
  1 ;

: wdog:feed ( -- )
  \ "Nourrir" le watchdog — remet le compteur à zéro
  wdog-active @ 0= if exit then
  tco-base @ 0x00 + inw 0x0008 or
  tco-base @ 0x00 + outw ;

: wdog:stop ( -- )
  wdog-active @ 0= if exit then
  tco-base @ 8 + inw 0x0800 or tco-base @ 8 + outw
  0 wdog-active ! ;

: wdog:info ( -- )
  ." === Watchdog TCO ===" cr
  ." Base: 0x" tco-base @ hex . decimal cr
  ." Actif: " wdog-active @ if ." OUI" else ." NON" then cr ;


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE C — ÉCRIRE UNE APPLICATION
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ C1. APPLICATION CONSOLE
\ ──────────────────────────────────────────────────────────────────────
\
\ Une application console utilise le terminal pour I/O.
\ Pas de fenêtre graphique, juste du texte.

: app-hello ( -- )
  cr
  ." ╔══════════════════════════╗" cr
  ." ║   Hello Epona OS !      ║" cr
  ." ║   Application console   ║" cr
  ." ╚══════════════════════════╝" cr
  cr
  ." Tapez un nombre : "
  touche 48 -                 \ ASCII → chiffre
  dup 0 >= over 9 <= and if
    cr ." Vous avez tape : " . cr
    ." Son carre est : " dup * . cr
  else
    drop cr ." Ce n'est pas un chiffre" cr
  then ;


\ ──────────────────────────────────────────────────────────────────────
\ C2. APPLICATION GRAPHIQUE (Canvas)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le Canvas Forth est une zone protégée de 400×300 pixels.
\ Il s'ouvre automatiquement quand un mot "principal" existe.
\
\   pixel   ( x y color -- )       Dessiner un pixel
\   rect    ( x y w h color -- )   Dessiner un rectangle
\   ligne   ( x1 y1 x2 y2 col -- ) Dessiner une ligne
\   effacer ( color -- )           Remplir tout le canvas
\   couleur ( r g b -- color )     Composer une couleur
\   touche? ( -- char | 0 )       Touche non-bloquante
\   souris  ( -- x y btn )        Position souris
\   attendre ( ms -- )            Pause
\
\ Exemple — animation de balles rebondissantes :

variable balle-x   variable balle-y
variable balle-dx  variable balle-dy

: balle-init ( -- )
  50 balle-x !  50 balle-y !
  3 balle-dx !  2 balle-dy ! ;

: balle-move ( -- )
  balle-x @ balle-dx @ + balle-x !
  balle-y @ balle-dy @ + balle-y !
  \ Rebondir sur les bords
  balle-x @ 390 > if -3 balle-dx ! then
  balle-x @ 0 <   if  3 balle-dx ! then
  balle-y @ 290 > if -2 balle-dy ! then
  balle-y @ 0 <   if  2 balle-dy ! then ;

: balle-draw ( -- )
  balle-x @ balle-y @ 10 10 0xFF4444 rect ;

: principal-balle ( -- )
  balle-init
  begin
    0x000020 effacer          \ Fond bleu foncé
    balle-move
    balle-draw
    16 attendre               \ ~60 fps
    touche? 27 =              \ Échap pour quitter
  until ;

\ Pour l'exécuter :
\ Renommer "principal-balle" en "principal" puis F5


\ ──────────────────────────────────────────────────────────────────────
\ C3. APPLICATION FENÊTRÉE (Widgets)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le système de widgets permet de créer des interfaces graphiques
\ avec boutons, champs de texte et listes.
\
\   app: <nom> ( x y w h -- )          Créer une fenêtre
\   button-push "Label" [callback]     Bouton avec action
\   textfield: ( x y w h -- )          Champ de texte
\   list: ( x y w h -- )               Liste
\   list-add ( addr len -- )           Ajouter à la liste
\   widgets-draw ( wx wy ww wh -- )    Dessiner les widgets
\   widgets-clear ( -- )               Vider tous les widgets
\
\ Le mot [callback] est le nom d'un mot Forth qui sera
\ exécuté quand l'utilisateur clique sur le bouton.
\
\ Exemple — panneau de contrôle :

variable panneau-compteur

: panneau-incrementer ( -- )
  1 panneau-compteur +!
  ." Compteur: " panneau-compteur @ . cr ;

: panneau-decrementer ( -- )
  -1 panneau-compteur +!
  ." Compteur: " panneau-compteur @ . cr ;

: panneau-reset ( -- )
  0 panneau-compteur !
  ." Reset!" cr ;

: demo-panneau ( -- )
  0 panneau-compteur !
  widgets-clear

  \ Créer la fenêtre
  100 100 300 200 app: "Panneau"

  \ Boutons
  10 10 80 25 button-push "Plus" panneau-incrementer
  10 40 80 25 button-push "Moins" panneau-decrementer
  10 70 80 25 button-push "Reset" panneau-reset

  \ Champ de texte pour affichage
  100 10 180 20 textfield:
;


\ ──────────────────────────────────────────────────────────────────────
\ C4. APPLICATION RÉSEAU
\ ──────────────────────────────────────────────────────────────────────
\
\ Prérequis : appeler net:init et net:dhcp (ou config manuelle).
\
\   net:init    ( -- ok? )
\   net:dhcp    ( -- ok? )
\   net:ping    ( a b c d -- ms | -1 )
\   net:dns     ( addr len -- a b c d )
\   net:tcp-connect ( a b c d port -- sock | -1 )
\   net:tcp-send    ( sock buf len -- ok? )
\   net:tcp-recv    ( sock buf maxlen -- actual )
\   net:tcp-close   ( sock -- )
\   net:http-get    ( host hlen path plen -- addr len status )
\
\ Exemple — outil de ping :

: ping-test ( -- )
  net:init 0= if ." Pas de carte reseau" cr exit then
  net:dhcp 0= if ." DHCP echoue" cr exit then
  cr ." Ping 8.8.8.8... "
  8 8 8 8 net:ping
  dup 0 < if
    drop ." timeout" cr
  else
    . ." ms" cr
  then ;

\ Exemple — requête HTTP simple :

: http-demo ( -- )
  net:init drop
  net:dhcp drop
  \ Préparer les chaînes en mémoire
  here dup >r
  \ Écrire "example.com" dans la mémoire Forth
  69 , 120 , 97 , 109 , 112 , 108 , 101 ,   \ "example"
  46 ,                                        \ "."
  99 , 111 , 109 ,                            \ "com"
  here dup >r
  47 ,                                        \ "/"

  r> r>                       \ -- path_addr host_addr
  swap 11 swap 1              \ host_addr 11 path_addr 1
  net:http-get                \ -- data_addr data_len status
  cr ." HTTP Status: " . cr
  ." Reponse: " . ." octets" cr ;


\ ──────────────────────────────────────────────────────────────────────
\ C5. APPLICATION DISQUE
\ ──────────────────────────────────────────────────────────────────────
\
\ Accès aux disques internes (SATA/NVMe) et clés USB.
\
\   disk:init       ( -- ok? )
\   disk:ls <path>  ( -- )
\   disk:read <f>   ( addr -- len )
\   disk:write <f>  ( addr len -- )
\
\ Accès bas niveau :
\   ahci:init  ahci:read  ahci:write  ahci:info
\   nvme:init  nvme:read  nvme:write  nvme:info
\   fat:*      (primitives FAT32 bas niveau)
\
\ Exemple — explorateur de fichiers simple :

: ls-root ( -- )
  disk:init 0= if
    ." Aucun disque trouve" cr exit
  then
  cr ." === Contenu de / ===" cr
  disk:ls /
;

\ Exemple — lire et afficher un fichier :

: cat-file ( -- )
  disk:init drop
  here dup >r
  disk:read /BOOT.FTH
  dup 0 > if
    ." === BOOT.FTH (" . ." octets) ===" cr
    r@ swap 0 ?do
      r@ i + @ 0xFF and emit
    loop
    cr
  else
    drop ." Fichier non trouve" cr
  then
  r> drop ;


\ ──────────────────────────────────────────────────────────────────────
\ C6. APPLICATION COMPLÈTE : MONITEUR SYSTÈME
\ ──────────────────────────────────────────────────────────────────────

: sysmon-header ( -- )
  cr
  ." ╔══════════════════════════════════════╗" cr
  ." ║      EPONA OS — MONITEUR SYSTEME    ║" cr
  ." ╚══════════════════════════════════════╝" cr ;

: sysmon-cpu ( -- )
  ." CPU: "
  0 cpuid drop swap drop swap drop
  ." max leaf=" . cr
  ." TSC: " rdtsc . cr
  ." Uptime: " ticks 1000 / . ." sec" cr ;

: sysmon-ram ( -- )
  ." RAM: "
  mem-map
  over 4 * 1024 / . ." MB total, "
  4 * 1024 / . ." MB libre" cr ;

: sysmon-screen ( -- )
  ." Ecran: "
  fb-size swap . ." x" . cr ;

: sysmon-heap ( -- )
  ." Heap Rust: " heap-used . ." octets" cr ;

: sysmon-pci ( -- )
  ." PCI: " pci-scan . ." peripheriques" cr ;

: sysmon-time ( -- )
  ." Heure: "
  get-time
  \ Stack: sec min hour day month year
  . ." /" . ." /" .
  ."  " . ." :" . ." :" . cr ;

: sysmon ( -- )
  sysmon-header
  cr
  sysmon-cpu
  sysmon-ram
  sysmon-screen
  sysmon-heap
  sysmon-pci
  sysmon-time
  cr
  ." Appuyez sur une touche..." cr
  touche drop ;


\ ──────────────────────────────────────────────────────────────────────
\ C7. APPLICATION COMPLÈTE : TERMINAL SÉRIE
\ ──────────────────────────────────────────────────────────────────────
\
\ Mini terminal qui envoie/reçoit via UART.
\ Quitter avec Échap.

: minicom ( -- )
  115200 uart:init 0= if
    ." UART init echec" cr exit
  then
  cr ." === Minicom — Echap pour quitter ===" cr
  begin
    \ Recevoir depuis UART
    uart:rx dup -1 <> if
      emit                    \ Afficher le caractère reçu
    else
      drop
    then
    \ Envoyer depuis clavier
    touche? dup 27 = if
      drop cr ." Deconnexion." cr exit
    then
    dup 0 <> if
      uart:tx                 \ Envoyer vers UART
    else
      drop
    then
    1 ms
  again ;


\ ──────────────────────────────────────────────────────────────────────
\ C8. APPLICATION COMPLÈTE : ÉDITEUR HEXADÉCIMAL
\ ──────────────────────────────────────────────────────────────────────

: hex-line ( addr -- )
  \ Affiche une ligne de 16 octets en hexa + ASCII
  dup ." 0x" hex . decimal ."  | "
  \ Partie hexadécimale
  16 0 do
    dup i + c@ dup
    16 < if ." 0" then
    hex . decimal space
  loop
  ." | "
  \ Partie ASCII
  16 0 do
    dup i + c@
    dup 32 >= over 126 <= and if
      emit
    else
      drop 46 emit            \ '.' pour non-imprimable
    then
  loop
  drop cr ;

: hexdump ( addr len -- )
  cr
  ." ═══════════════════════════════════════════════════════" cr
  ." Adresse     | Hexadecimal                             | ASCII" cr
  ." ═══════════════════════════════════════════════════════" cr
  over + swap
  begin
    2dup > if
      dup hex-line
      16 +
    else
      2drop exit
    then
  again ;

\ Utilisation :
\   0x7C00 512 hexdump       \ Voir le secteur de boot
\   0xFEE00000 64 hexdump    \ Voir le Local APIC

\ Hexdump de la mémoire Forth (memory[]) :

: forth-hexdump ( addr len -- )
  cr ." === Memoire Forth ===" cr
  over + swap
  begin
    2dup > if
      dup ." [" . ." ] "
      dup 8 0 do
        dup i + dup 0 >= over 4096 < and if
          @ hex . decimal
        else
          drop ." -- "
        then
      loop
      drop cr
      8 +
    else
      2drop exit
    then
  again ;


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE D — ÉCRIRE UN SIMULATEUR
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ D1. ARCHITECTURE D'UN SIMULATEUR CPU
\ ──────────────────────────────────────────────────────────────────────
\
\ Un simulateur CPU dans EponaForth suit ce pattern :
\
\   1. Mémoire simulée   : tableau dans memory[] via create/allot
\   2. Registres          : variables Forth
\   3. Fetch              : lire l'opcode depuis la mémoire simulée
\   4. Decode             : case/of ou table de sauts
\   5. Execute            : modifier registres/mémoire
\   6. Boucle             : begin fetch decode execute ... until
\
\ Pattern générique :
\
\   variable sim-pc          \ Program Counter
\   variable sim-a           \ Accumulateur
\   variable sim-flags       \ Drapeaux
\
\   create sim-ram 256 allot \ 256 cellules de RAM simulée
\
\   : sim-fetch ( -- opcode )
\     sim-pc @ sim-ram + @ 0xFF and
\     1 sim-pc +! ;
\
\   : sim-step ( -- halt? )
\     sim-fetch
\     case
\       0x00 of ... endof   \ NOP
\       0x01 of ... endof   \ LOAD
\       0xFF of 1 exit endof \ HALT
\       ." Opcode inconnu" cr
\     endcase
\     0 ;
\
\   : sim-run ( -- )
\     begin sim-step until ;


\ ──────────────────────────────────────────────────────────────────────
\ D2. SIMULATEUR CHIP-8 COMPLET
\ ──────────────────────────────────────────────────────────────────────
\
\ CHIP-8 est une machine virtuelle de 1977 :
\   - 4 KB de RAM
\   - 16 registres 8-bit (V0-VF)
\   - Écran 64×32 monochrome
\   - Clavier hexadécimal (0-F)
\   - Timers (délai + son)
\
\ C'est le simulateur parfait pour commencer :
\   simple, bien documenté, des centaines de ROMs libres.

\ --- Mémoire et registres ---

create c8-ram 4096 allot      \ 4 KB de RAM
create c8-v 16 allot          \ 16 registres V0-VF
create c8-screen 2048 allot   \ 64×32 = 2048 pixels
variable c8-i                 \ Registre d'index
variable c8-pc                \ Program Counter
variable c8-sp                \ Stack Pointer
create c8-stack 16 allot      \ Pile (16 niveaux)
variable c8-dt                \ Delay Timer
variable c8-st                \ Sound Timer
variable c8-running

\ --- Accès mémoire simulée ---

: c8-mem@ ( addr -- byte )
  0xFFF and c8-ram + @ 0xFF and ;

: c8-mem! ( byte addr -- )
  0xFFF and c8-ram + swap 0xFF and swap ! ;

: c8-v@ ( reg -- val )
  0x0F and c8-v + @ 0xFF and ;

: c8-v! ( val reg -- )
  0x0F and c8-v + swap 0xFF and swap ! ;

\ --- Initialisation ---

: c8-init ( -- )
  \ Effacer la RAM
  4096 0 do 0 i c8-ram + ! loop
  \ Effacer les registres
  16 0 do 0 i c8-v + ! loop
  \ Effacer l'écran
  2048 0 do 0 i c8-screen + ! loop
  \ Initialiser les registres spéciaux
  0 c8-i !
  0x200 c8-pc !               \ Les programmes commencent à 0x200
  0 c8-sp !
  0 c8-dt !
  0 c8-st !
  1 c8-running !

  \ Charger la police (0-F) à l'adresse 0x000
  \ Chiffre 0 :
  0xF0 0 c8-mem!  0x90 1 c8-mem!  0x90 2 c8-mem!
  0x90 3 c8-mem!  0xF0 4 c8-mem!
  \ Chiffre 1 :
  0x20 5 c8-mem!  0x60 6 c8-mem!  0x20 7 c8-mem!
  0x20 8 c8-mem!  0x70 9 c8-mem!
  \ ... (ajouter les polices 2-F)
;

\ --- Charger un programme ---

: c8-load ( src_addr len -- )
  c8-init
  \ Copier depuis la mémoire Forth vers c8-ram à 0x200
  0 ?do
    dup i + @ 0xFF and
    0x200 i + c8-mem!
  loop
  drop ;

\ --- Fetch ---

: c8-fetch ( -- opcode16 )
  c8-pc @ c8-mem@  8 lshift     \ Octet haut
  c8-pc @ 1+ c8-mem@  or        \ Octet bas
  2 c8-pc +! ;                   \ Avancer PC

\ --- Dessin ---

: c8-draw-screen ( -- )
  0x000000 effacer
  32 0 do
    64 0 do
      j 64 * i + c8-screen + @
      0<> if
        \ Chaque pixel CHIP-8 = 5×5 pixels sur le canvas
        i 5 * 20 +
        j 5 * 20 +
        5 5 0x00FF00 rect
      then
    loop
  loop ;

\ --- Exécution d'une instruction ---

: c8-step ( -- )
  c8-running @ 0= if exit then

  c8-fetch                     \ -- opcode

  dup 0xF000 and 12 rshift     \ nibble haut
  case
    0x0 of
      dup 0x00E0 = if          \ CLS
        2048 0 do 0 i c8-screen + ! loop
      then
      dup 0x00EE = if          \ RET
        -1 c8-sp +!
        c8-sp @ c8-stack + @ c8-pc !
      then
    endof
    0x1 of                     \ JP addr
      dup 0x0FFF and c8-pc !
    endof
    0x2 of                     \ CALL addr
      c8-pc @ c8-sp @ c8-stack + !
      1 c8-sp +!
      dup 0x0FFF and c8-pc !
    endof
    0x3 of                     \ SE Vx, byte
      dup 8 rshift 0x0F and c8-v@
      over 0xFF and = if
        2 c8-pc +!
      then
    endof
    0x6 of                     \ LD Vx, byte
      dup 0xFF and
      over 8 rshift 0x0F and
      c8-v!
    endof
    0x7 of                     \ ADD Vx, byte
      dup 8 rshift 0x0F and dup c8-v@
      rot 0xFF and +
      0xFF and swap c8-v!
    endof
    0xA of                     \ LD I, addr
      dup 0x0FFF and c8-i !
    endof
    0xD of                     \ DRW Vx, Vy, n
      \ Dessin de sprite — simplifié
      dup 0x0F and             \ n (hauteur)
      over 4 rshift 0x0F and c8-v@  \ y
      swap
      over 8 rshift 0x0F and c8-v@  \ x
      swap
      \ -- opcode x y n
      0 0xF c8-v!             \ VF = 0 (pas de collision)
      0 ?do                   \ pour chaque ligne
        c8-i @ i + c8-mem@    \ sprite byte
        8 0 do                \ pour chaque pixel
          dup 0x80 i rshift and 0<> if
            \ pixel (x+j, y+i) XOR
            3 pick j + 64 mod
            3 pick i + 32 mod
            64 * +
            dup c8-screen + @ 0<> if
              1 0xF c8-v!     \ collision
            then
            dup c8-screen + @
            0= if 1 else 0 then
            swap c8-screen + !
          then
        loop
        drop                  \ sprite byte
      loop
      drop drop               \ x y
    endof
  endcase
  drop                        \ opcode résiduel

  \ Décrémenter les timers
  c8-dt @ 0 > if -1 c8-dt +! then
  c8-st @ 0 > if -1 c8-st +! then ;

\ --- Boucle principale ---

: c8-run ( -- )
  begin
    c8-step
    c8-draw-screen
    2 ms                       \ ~500 Hz
    touche? 27 =
    c8-running @ 0= or
  until ;

\ --- Utilisation ---
\ 1. Charger une ROM dans la mémoire Forth :
\    here dup >r disk:read PONG.CH8 r>
\ 2. Charger dans CHIP-8 :
\    here swap c8-load
\ 3. Lancer :
\    c8-run


\ ──────────────────────────────────────────────────────────────────────
\ D3. AUTOMATE CELLULAIRE (Jeu de la Vie)
\ ──────────────────────────────────────────────────────────────────────

40 constant LIFE-W
30 constant LIFE-H

create life-a  LIFE-W LIFE-H * allot    \ Grille A
create life-b  LIFE-W LIFE-H * allot    \ Grille B
variable life-gen                         \ Numéro de génération
variable life-current                     \ 0=A est courant, 1=B

: life-grid ( -- addr )
  life-current @ 0= if life-a else life-b then ;

: life-other ( -- addr )
  life-current @ 0= if life-b else life-a then ;

: life-idx ( x y -- idx )
  LIFE-W * + ;

: life-get ( x y -- 0|1 )
  \ Coordonnées toriques
  swap LIFE-W mod swap LIFE-H mod
  life-idx life-grid + @ ;

: life-set! ( val x y -- )
  life-idx life-grid + swap 1 and swap ! ;

: life-clear ( -- )
  LIFE-W LIFE-H * 0 do
    0 i life-a + !
    0 i life-b + !
  loop
  0 life-gen !
  0 life-current ! ;

\ Compter les voisins vivants :
: life-neighbors ( x y -- n )
  0                           \ compteur
  3 0 do                      \ dy = -1, 0, 1
    3 0 do                    \ dx = -1, 0, 1
      i 1 - j 1 - or 0<> if  \ Pas soi-même (0,0)
        4 pick i 1 - +        \ x + dx
        4 pick j 1 - +        \ y + dy
        life-get +
      then
    loop
  loop
  rot rot 2drop ;             \ nettoyer x y

\ Calculer la génération suivante :
: life-step ( -- )
  LIFE-H 0 do
    LIFE-W 0 do
      i j life-neighbors       \ n voisins
      i j life-get             \ état actuel
      if                       \ cellule vivante
        dup 2 < if             \ < 2 voisins → meurt
          drop 0
        else
          3 > if               \ > 3 voisins → meurt
            0
          else                 \ 2 ou 3 → survit
            1
          then
        then
      else                     \ cellule morte
        3 = if 1 else 0 then  \ exactement 3 → naît
      then
      i j life-idx life-other + !
    loop
  loop
  \ Échanger les grilles
  life-current @ 0= if 1 else 0 then life-current !
  1 life-gen +! ;

\ Dessiner :
: life-draw ( -- )
  0x000000 effacer
  LIFE-H 0 do
    LIFE-W 0 do
      i j life-get 0<> if
        i 10 * j 10 * 9 9 0x00FF00 rect
      then
    loop
  loop ;

\ Placer un planeur (glider) :
: life-glider ( x y -- )
  2dup 1 -rot life-set!             \ (x, y)
  2dup swap 1+ swap 1+ 1 -rot life-set!  \ (x+1, y+1)
  2dup swap 1- swap 2 + 1 -rot life-set! \ (x-1, y+2)
  2dup swap    swap 2 + 1 -rot life-set! \ (x, y+2)
  swap 1+ swap 2 + 1 -rot life-set! ;    \ (x+1, y+2)

\ Boucle principale :
: life-run ( -- )
  life-clear
  10 5 life-glider          \ Placer un glider
  20 10 life-glider         \ Un deuxième
  begin
    life-draw
    life-step
    50 ms
    touche? 27 =
  until ;


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE E — BONNES PRATIQUES
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ E1. DOCUMENTATION DES MOTS
\ ──────────────────────────────────────────────────────────────────────
\
\ TOUJOURS documenter l'effet sur la pile :
\
\   : bon-mot ( n addr -- result flag )
\     \ Description de ce que fait le mot
\     \ n = nombre d'éléments à traiter
\     \ addr = adresse du buffer
\     \ result = résultat calculé
\     \ flag = 1 si succès, 0 si échec
\     ... ;
\
\ Convention de documentation complète :
\
\   \ ────────────────────────────────────
\   \ nom ( stack-effect )
\   \   Description courte.
\   \   Paramètres :
\   \     param1 — description
\   \     param2 — description
\   \   Retourne :
\   \     result — description
\   \   Erreurs :
\   \     Throw -2 si timeout
\   \     Retourne 0 si périphérique absent
\   \   Exemple :
\   \     115200 uart:init .
\   \ ────────────────────────────────────


\ ──────────────────────────────────────────────────────────────────────
\ E2. GESTION DES ERREURS DANS LES DRIVERS
\ ──────────────────────────────────────────────────────────────────────
\
\ Pattern recommandé : try/catch autour des accès matériel

: safe-mmio@ ( addr -- val | 0 )
  try
    mmio@
    0
  catch
    drop 0
  endtry ;

\ Pattern — chaîne d'initialisation avec rollback :

\ : driver-init ( -- ok? )
\   step1-init 0= if 0 exit then
\   step2-init 0= if step1-cleanup 0 exit then
\   step3-init 0= if step2-cleanup step1-cleanup 0 exit then
\   1 ;

\ Pattern — retry avec backoff :

: retry-op ( xt retries -- ok? )
  \ xt = ( -- ok? )
  0 ?do
    dup execute if
      drop 1 unloop exit
    then
    i 10 * ms               \ Backoff exponentiel
  loop
  drop 0 ;


\ ──────────────────────────────────────────────────────────────────────
\ E3. TESTS DE DRIVERS
\ ──────────────────────────────────────────────────────────────────────
\
\ Chaque driver devrait avoir un mot :test

\ Pattern de test :

variable test-pass
variable test-fail

: t-assert ( flag msg_addr msg_len -- )
  rot if
    1 test-pass +!
    2drop
  else
    1 test-fail +!
    type ."  ECHEC" cr
  then ;

: t-reset  0 test-pass !  0 test-fail ! ;

: t-report
  cr ." Tests: "
  test-pass @ . ." OK, "
  test-fail @ . ." ECHEC" cr ;

\ Exemple :
\ : uart:test ( -- )
\   t-reset
\   115200 uart:init
\   s" uart:init" t-assert
\   uart:status
\   s" uart:status" t-assert
\   t-report ;


\ ──────────────────────────────────────────────────────────────────────
\ E4. PERFORMANCE
\ ──────────────────────────────────────────────────────────────────────
\
\ Conseils pour du code Forth rapide :
\
\ 1. Éviter les allocations dans les boucles chaudes
\    MAUVAIS :  begin here allot ... again
\    BON :      create buf 512 allot  begin buf ... again
\
\ 2. Utiliser des constantes au lieu de magic numbers
\    MAUVAIS :  0x3F8 inb
\    BON :      0x3F8 constant COM1  COM1 inb
\
\ 3. Minimiser la profondeur de pile (max 3-4 éléments)
\    MAUVAIS :  a b c d e f g h  (8 éléments → illisible)
\    BON :      utiliser des variables locales (>r r>)
\
\ 4. Pour les boucles serrées, préférer DO/LOOP à BEGIN/UNTIL
\    DO/LOOP est légèrement plus rapide (pas de JumpIfZero)
\
\ 5. Benchmark avec le mot benchmark :
\    ' mon-mot benchmark . ." ms" cr
\
\ 6. Limite : 10M instructions par exécution
\    Si votre programme a besoin de plus, découpez en étapes


\ ──────────────────────────────────────────────────────────────────────
\ E5. SÉCURITÉ
\ ──────────────────────────────────────────────────────────────────────
\
\ Mode sécurisé (secure on) :
\   - Bloque les accès MMIO, ports I/O, PCI
\   - Restreint la mémoire Forth à [0..256[
\   - Bloque le réseau
\   - Bloque les fichiers (sauf /SAFE/)
\   - Bloque reboot/poweroff
\   - Bloque alloc-phys/free-phys
\
\ Pour développer un driver, TOUJOURS en secure off.
\ Pour distribuer à des utilisateurs, envisager :
\   - Mettre le driver dans un fichier .FTH vérifié
\   - Documenter les accès matériel nécessaires
\   - Utiliser file-allow pour limiter les fichiers accessibles
\   - Utiliser mem-bounds pour limiter la mémoire


\ ──────────────────────────────────────────────────────────────────────
\ E6. PORTABILITÉ
\ ──────────────────────────────────────────────────────────────────────
\
\ EponaForth n'est PAS ANS Forth standard.
\ Différences principales :
\
\   - Cellules 64-bit (pas 32-bit)
\   - Mémoire Forth en i64 (pas en octets)
\   - Pas de DOES> standard (version simplifiée)
\   - Pas de vocabulaires/wordlists
\   - Pas de virgule flottante (entiers seulement)
\   - Pas de bloc (fichiers plats à la place)
\
\ Pour du code portable :
\   - Utiliser cell+ et cells au lieu de 8 + et 8 *
\   - Documenter les dépendances aux primitives Epona
\   - Séparer la logique métier des accès matériel
\   - Utiliser [defined] pour tester les fonctionnalités


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE F — RÉFÉRENCE RAPIDE
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ F1. TOUTES LES PRIMITIVES PAR CATÉGORIE
\ ──────────────────────────────────────────────────────────────────────
\
\ === PILE ===
\   dup drop swap over rot -rot nip tuck
\   2dup 2drop 2swap 2over ?dup pick
\   depth .s pile
\   >r r> r@
\
\ === ARITHMÉTIQUE ===
\   + - * / mod /mod
\   1+ 1- 2+ 2- 2* 2/
\   abs negate min max hasard
\
\ === COMPARAISON ===
\   = <> < > <= >= 0= 0<> 0< 0>
\
\ === LOGIQUE ===
\   and or xor invert lshift rshift
\
\ === MÉMOIRE FORTH ===
\   @ ! +! variable constant
\   here allot , create does>
\   cell+ cells aligned char+ chars
\   erase move
\
\ === MÉMOIRE PHYSIQUE ===
\   c@ c! w@ w! l@ l!
\   mmio@ mmio! phys@ phys!
\   alloc-phys free-phys
\
\ === AFFICHAGE ===
\   . u. cr space spaces emit
\   ." ..." hex decimal
\   type
\
\ === CONTRÔLE ===
\   if else then
\   begin until again
\   begin while repeat
\   do loop +loop ?do leave i j
\   case of endof endcase
\   exit recurse
\   try catch endtry throw
\
\ === COMPILATION ===
\   : ; immediate
\   ' execute postpone
\   [char] char
\   s" ."
\   state ] [
\   find literal forget
\
\ === PORTS I/O ===
\   inb outb inw outw inl outl
\
\ === PCI ===
\   pci-scan pci-dev pci-name pci@ pci! pci-bar
\
\ === ACPI ===
\   acpi-rsdp acpi-find acpi-hdr acpi-tables
\
\ === CPU ===
\   cpuid rdtsc msr@ msr!
\
\ === TEMPS ===
\   ms attendre ticks stall stall-us
\   get-time set-time
\
\ === ÉCRAN ===
\   fb-size fb-swap fb:pixel fb:rect fb:line fb:text fb:blit
\   pixel rect ligne effacer couleur (canvas)
\
\ === GPU ===
\   gpu:init gpu:info gpu:modeset gpu:fill gpu:blit
\   gpu:flip gpu:vsync gpu:fb-addr gpu:fb-stride
\   gpu:cursor gpu:cursor-set gpu:accel? gpu:resolution
\   gpu:line gpu:blend gpu:text
\   gpu:outputs gpu:select-output gpu:output-enable
\   gpu:output-disable gpu:output-flip gpu:output-fb
\   gpu:output-info gpu:output-edid
\
\ === ENTRÉES ===
\   touche touche? souris souris?
\
\ === USB ===
\   xhci-init xhci-souris xhci-souris?
\   usb:init usb:devices usb:control usb:read usb:write
\   usb:bulk-read usb:bulk-write
\   usb:config-ep usb:stop-ep usb:reset-ep
\   usb:msd-probe usb:msd-info usb:msd-read usb:msd-write
\
\ === RÉSEAU ===
\   net:init net:send net:recv net:mac net:status net:info
\   net:cards net:firmware
\   net:ip! net:ip@ net:mask! net:gw! net:dns!
\   net:ping net:arp net:dhcp net:poll net:dns
\   net:udp-send net:udp-recv
\   net:tcp-connect net:tcp-send net:tcp-recv net:tcp-close
\   net:http-get net:stack-info
\
\ === DISQUE ===
\   disk:init disk:ls disk:read disk:write
\   ahci:init ahci:drives ahci:read ahci:write ahci:info
\   nvme:init nvme:read nvme:write nvme:info
\   nvme:lba-size nvme:total-lbas nvme:capacity
\   fat:info fat:root-clus fat:cluster-lba fat:read-entry
\   fat:write-entry fat:read-cluster fat:write-cluster
\   fat:alloc-cluster fat:alloc-chain fat:free-chain
\   fat:dir-entries fat:eoc?
\
\ === AUDIO ===
\   hda-init hda-play hda-stop hda-volume
\   hda-info hda-beep hda-status
\   beep
\
\ === I2C ===
\   dw-i2c-init dw-i2c-probe i2c.probe i2c-read
\   i2c:status i2c:read i2c:gesture
\   i2c:cal-set i2c:cal-get i2c:contacts
\
\ === INTERRUPTIONS ===
\   apic-base ioapic-read ioapic-write
\   init-idt irq-handler
\
\ === SYSTÈME ===
\   mem-map heap-used smbios-entry smbios-info
\   cfg-tables reboot poweroff
\   sys:load sys:read sys:write
\   sys:register sys:drivers sys:probe sys:log
\   task stop tasks
\
\ === SÉCURITÉ ===
\   mem-bounds file-allow file-revoke-all
\   net-allow net-revoke
\
\ === WIDGETS ===
\   app: button-push textfield: list: list-add
\   widgets-draw widgets-clear
\
\ === DÉBOGAGE ===
\   step trace .ops
\   break unbreak watch unwatch
\   see word-info


\ ──────────────────────────────────────────────────────────────────────
\ F2. CODES D'ERREUR RECOMMANDÉS
\ ──────────────────────────────────────────────────────────────────────
\
\   -1   Erreur générique
\   -2   Timeout
\   -3   Périphérique non trouvé
\   -4   Erreur de communication (CRC, NAK, etc.)
\   -5   Buffer trop petit
\   -6   Opération non supportée
\   -7   Permission refusée (secure mode)
\   -8   Ressource occupée
\   -9   Adresse invalide
\   -10  Paramètre hors limites
\   -11  Pile vide (underflow)
\   -12  Pile pleine (overflow)
\   -13  Mot non trouvé
\   -14  Division par zéro
\   -15  Fichier non trouvé
\   -16  Disque plein
\   -17  Réseau indisponible
\   -18  Connexion refusée
\   -19  DNS échoué
\   -20  Checksum invalide


\ ──────────────────────────────────────────────────────────────────────
\ F3. CONSTANTES UTILES
\ ──────────────────────────────────────────────────────────────────────

\ Couleurs :
0xFF0000 constant ROUGE
0x00FF00 constant VERT
0x0000FF constant BLEU
0xFFFFFF constant BLANC
0x000000 constant NOIR
0xFFFF00 constant JAUNE
0xFF00FF constant MAGENTA
0x00FFFF constant CYAN
0x808080 constant GRIS
0x404040 constant GRIS-FONCE
0xC0C0C0 constant GRIS-CLAIR

\ ASCII :
10 constant LF
13 constant CR-CHAR
27 constant ESC
32 constant BL
127 constant DEL

\ Tailles :
4096 constant PAGE-SIZE
512 constant SECTOR-SIZE

\ PCI classes :
0x01 constant PCI-STORAGE
0x02 constant PCI-NETWORK
0x03 constant PCI-DISPLAY
0x04 constant PCI-MULTIMEDIA
0x06 constant PCI-BRIDGE
0x0C constant PCI-SERIAL


\ ──────────────────────────────────────────────────────────────────────
\ F4. PATTERNS COURANTS
\ ──────────────────────────────────────────────────────────────────────

\ --- Boucle avec index et accumulation ---
\ : sum-range ( lo hi -- sum )
\   0 -rot            \ acc lo hi
\   swap do            \ acc
\     i +
\   loop ;

\ --- Table de sauts ---
\ create jump-table
\   ' handler0 ,  ' handler1 ,  ' handler2 ,
\
\ : dispatch ( n -- )
\   cells jump-table + @ execute ;

\ --- Buffer circulaire ---
\ 256 constant RING-SIZE
\ create ring-buf RING-SIZE allot
\ variable ring-head
\ variable ring-tail
\
\ : ring-put ( byte -- ok? )
\   ring-head @ 1+ RING-SIZE mod
\   dup ring-tail @ = if drop 0 exit then
\   ring-head !
\   ring-head @ ring-buf + !
\   1 ;
\
\ : ring-get ( -- byte | -1 )
\   ring-head @ ring-tail @ = if -1 exit then
\   ring-tail @ ring-buf + @
\   ring-tail @ 1+ RING-SIZE mod ring-tail !
\ ;

\ --- Compteur avec saturation ---
\ : sat+ ( val max -- val' )
\   over + over min nip ;

\ --- Masque de bits ---
\ : bit ( n -- mask )  1 swap lshift ;
\ : bit? ( val n -- flag )  bit and 0<> ;
\ : bit-set ( val n -- val' )  bit or ;
\ : bit-clear ( val n -- val' )  bit invert and ;
\ : bit-toggle ( val n -- val' )  bit xor ;


\ ════════════════════════════════════════════════════════════════════════
\              FIN DU GUIDE DÉVELOPPEUR EPONA OS
\ ════════════════════════════════════════════════════════════════════════

cr
." ════════════════════════════════════════════════════════" cr
."  DEVGUIDE.FTH charge avec succes" cr
."  Constantes et utilitaires disponibles." cr
."  Tapez 'sysmon' pour le moniteur systeme." cr
."  Tapez 'uart:test' pour tester le port serie." cr
."  Tapez 'led:test' pour les LEDs clavier." cr
."  Tapez 'demo-alloc-phys' pour tester l'allocation." cr
." ════════════════════════════════════════════════════════" cr
```

## Résumé de ce que contient ce guide

| Partie | Contenu | Pages |
|---|---|---|
| **A — Architecture** | Mémoire, pile, dictionnaire, erreurs, multitâche | Fondations |
| **B — Drivers** | Ports I/O, MMIO, PCI, I2C, USB, IRQ, DMA, timing | 4 drivers complets |
| **C — Applications** | Console, Canvas, Widgets, réseau, disque | 3 apps complètes |
| **D — Simulateurs** | Architecture CPU, CHIP-8, Jeu de la Vie | 2 simulateurs complets |
| **E — Bonnes pratiques** | Documentation, erreurs, tests, perf, sécurité | Conventions |
| **F — Référence rapide** | Toutes les primitives, codes d'erreur, constantes, patterns | Aide-mémoire |

### Drivers complets inclus
1. **UART 16550** — Port série avec init, loopback test, TX/RX, info
2. **LED clavier PS/2** — Contrôle Num/Caps/Scroll Lock + animation
3. **Température CPU** — Lecture MSR Intel IA32_THERM_STATUS
4. **Watchdog TCO** — Détection PCI, init, feed, stop

### Applications complètes incluses
1. **Moniteur système** — CPU, RAM, écran, heap, PCI, heure
2. **Terminal série** — Minicom basique via UART
3. **Éditeur hexadécimal** — Hexdump mémoire physique et Forth

### Simulateurs complets inclus

    CHIP-8 — RAM, registres, fetch/decode/execute, affichage Canvas
    Jeu de la Vie — Grille torique, calcul voisins, affichage Canvas



2. e Canvas
3. **Jeu de la Vie** — Grille torique, calcul voisins, affichage Canvas
