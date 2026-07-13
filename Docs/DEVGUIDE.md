

```forth
\ ════════════════════════════════════════════════════════════════════════
\                  EPONA OS — GUIDE DÉVELOPPEUR
\          Écrire des drivers, programmes et utilitaires
\                    en EponaForth (version 2026.2)
\ ════════════════════════════════════════════════════════════════════════
\
\ Ce fichier est à la fois :
\   - une documentation lisible (commentaires)
\   - du code exécutable (exemples fonctionnels)
\
\ Chargement : sys:load DEVGUIDE.FTH
\
\ Changements v2026.2 :
\   - 20 mots roadmap implémentés (see, value, defer, case...)
\   - FIXED.FTH virgule fixe Q20.12
\   - MUTEX.FTH synchronisation (critical-begin/end)
\   - STDLIB.FTH bibliothèque standard
\   - EVENTS.FTH système d'événements
\   - BOOT.FTH amorçage structuré
\   - ms yield (ne bloque plus le scheduler)
\   - Partie G — Roadmap langage mise à jour
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
\     A7. Bibliothèques standard
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
\     C9. Application avec événements (EVENTS.FTH)
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
\     E7. Synchronisation multitâche
\
\   PARTIE F — RÉFÉRENCE RAPIDE
\     F1. Toutes les primitives par catégorie
\     F2. Codes d'erreur
\     F3. Constantes utiles
\     F4. Patterns courants
\     F5. Bibliothèques disponibles
\
\   PARTIE G — ROADMAP LANGAGE (mise à jour v2025.2)
\     G1. Bilan des 20 mots implémentés
\     G2. Prochains mots à implémenter
\     G3. Évolution du runtime Rust
\     G4. Écosystème de fichiers .FTH
\     G5. Planning de développement
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
\   - Instructions : 10 millions par exécution (configurable)


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
\   - Primitives (implémentées en Rust, ~290 mots)
\   - Mots compilés (définis par l'utilisateur)
\   - Constantes, variables, values, defers
\   - create/does>, struct/field
\
\ Quand vous tapez un mot :
\
\   En mode IMMÉDIAT (state=0) :
\     Nombre     → empilé directement
\     Variable   → adresse empilée
\     Value      → valeur empilée
\     Primitive  → exécutée immédiatement
\     Mot compilé → exécuté immédiatement
\
\   En mode COMPILATION (state=1, entre : et ;) :
\     Nombre     → Op::Push(n) ajouté aux ops
\     Variable   → Op::VariableAddr(n) ajouté
\     Value      → Op::ValueAddr(n) ajouté
\     Primitive  → Op::CallPrim(idx) ajouté
\     Mot compilé → Op::Call(dict_idx) ajouté
\     Mot IMMÉDIAT → exécuté pendant la compilation !
\
\ Le bytecode interne (Op) :
\
\   Op::Push(val)         — Empile une valeur
\   Op::Call(idx)         — Appelle un mot compilé
\   Op::CallPrim(idx)     — Appelle une primitive Rust
\   Op::CallDeferred(addr) — Appelle un mot defer (indirection)
\   Op::ValueAddr(addr)   — Empile la valeur d'un value
\   Op::ToValue(addr)     — Modifie la valeur d'un value (to)
\   Op::AbortQuote(off,l) — Arrêt conditionnel avec message
\   Op::Jump(target)      — Saut inconditionnel
\   Op::JumpIfZero(tgt)   — Saut si pile=0
\   Op::VariableAddr(n)   — Empile adresse variable
\   Op::Exit              — Retour d'un mot
\   Op::Do/Loop/...       — Boucles
\   Op::Try/Catch/Throw   — Exceptions
\
\ Inspecter les ops d'un mot :
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
\ Rendre un mot immédiat (exécuté pendant la compilation) :
\   : mon-macro ... ; immediate
\
\ ATTENTION : les mots qui appelaient l'ancien "test"
\ appellent maintenant le nouveau (liaison dynamique par index).


\ ──────────────────────────────────────────────────────────────────────
\ A5. GESTION DES ERREURS
\ ──────────────────────────────────────────────────────────────────────
\
\ EponaForth offre 4 niveaux de gestion d'erreur :
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

\ Niveau 3 — abort" (arrêt conditionnel avec message) :
\   : check ( n -- )
\     dup 0 < abort" Valeur negative interdite !"
\     drop ;
\
\ Niveau 4 — Codes d'erreur dans les drivers :
\   -1 throw   → Erreur générique
\   -2 throw   → Timeout
\   -3 throw   → Périphérique non trouvé
\   -4 throw   → Erreur de communication


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
\   - ms yield : le mot ms rend la main au scheduler
\
\ Créer une tâche :
\   : ma-tache
\     begin
\       ." ." 100 ms        \ yield pendant l'attente
\     again ;
\   ' ma-tache task         \ → tid sur la pile
\
\ Lister les tâches :
\   tasks
\
\ Arrêter la tâche courante :
\   stop
\
\ Sections critiques (MUTEX.FTH) :
\   critical-begin           \ scheduler ne préempte plus
\   ... section critique ... \ opérations atomiques
\   critical-end             \ scheduler reprend
\
\ Protection anti-deadlock :
\   Si une section critique dépasse 100 000 instructions,
\   le scheduler force la préemption avec un warning.
\
\ ATTENTION :
\   - Les variables sont partagées entre tâches
\   - Utiliser mutex:lock / mutex:unlock pour protéger
\   - ms yield (ne monopolise plus le CPU)
\   - Voir MUTEX.FTH pour les primitives de synchronisation


\ ──────────────────────────────────────────────────────────────────────
\ A7. BIBLIOTHÈQUES STANDARD
\ ──────────────────────────────────────────────────────────────────────
\
\ EponaForth est livré avec 5 bibliothèques standard :
\
\ ┌──────────────┬──────────────────────────────────────────────────┐
\ │ STDLIB.FTH   │ Mots utilitaires : chaînes, tableaux, affichage │
\ │              │ true false bl tab max3 clamp within bounds       │
\ │              │ /string [] matrix[] 0.r hex. ? ?? >number        │
\ │              │ f>str time>str date>str times for map            │
\ │              │ array:create push pop                            │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ FIXED.FTH    │ Arithmétique virgule fixe Q20.12                │
\ │              │ f+ f- f* f/ fsqrt fsin fcos ftan fatan          │
\ │              │ v2.add v2.len v2.normalize v2.rotate             │
\ │              │ phys.move phys.bounce plot.curve                 │
\ │              │ sensor.adc-to-voltage sensor.celsius-to-f        │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ MUTEX.FTH    │ Synchronisation multitâche                      │
\ │              │ critical-begin critical-end                      │
\ │              │ spin:create spin:lock spin:unlock                │
\ │              │ mutex:create mutex:lock mutex:unlock mutex:with  │
\ │              │ sem:create sem:wait sem:signal                   │
\ │              │ chan:create chan:send chan:recv                   │
\ │              │ rwlock:create barrier:create pool:start          │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ EVENTS.FTH   │ Système d'événements                            │
\ │              │ on-key-press on-mouse-move on-tick               │
\ │              │ on-mouse-click on-resize on-quit                 │
\ │              │ event-loop                                       │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ TESTS.FTH    │ Suite de tests (29 sections, 180+ assertions)   │
\ │              │ test-reset ok ko assert= assert-true             │
\ │              │ section section-end resume-tests lancer-tests    │
\ └──────────────┴──────────────────────────────────────────────────┘
\
\ Chargement recommandé (dans BOOT.FTH ou manuellement) :
\   require STDLIB.FTH
\   require FIXED.FTH       \ si calcul virgule fixe
\   require MUTEX.FTH       \ si multitâche
\   require EVENTS.FTH      \ si application graphique


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
\   2. VARIABLES / VALUES : état interne du driver
\   3. ENUMS : codes d'état et d'erreur
\   4. MOTS BAS NIVEAU : lecture/écriture registres
\   5. MOTS D'INITIALISATION : probe, reset, config
\   6. MOTS D'INTERFACE : read, write, status
\   7. ENREGISTREMENT : sys:register
\   8. TESTS : auto-vérification
\
\ Squelette avec les mots v2025.2 :

\ --- Début squelette driver v2 ---

\ require STDLIB.FTH
\ require MUTEX.FTH
\
\ \ ── Constantes ──
\ 0x3F8 constant MYDRV-BASE
\
\ \ ── Énumérations ──
\ 0 enum MYDRV-UNINIT
\   enum MYDRV-READY
\   enum MYDRV-ERROR
\ drop
\
\ \ ── État ──
\ 0 value mydrv-state
\ mutex:create constant mydrv-lock
\
\ \ ── Structures ──
\ struct mydrv-regs
\   field .data
\   field .status
\   field .control
\ end-struct
\
\ \ ── Accès protégé ──
\ : mydrv:safe-read ( -- val )
\   mydrv-lock mutex:lock
\   MYDRV-BASE .data + inb
\   mydrv-lock mutex:unlock ;
\
\ \ ── Interface publique ──
\ : mydrv:init ( -- ok? )
\   MYDRV-BASE .status + inb
\   0<> if
\     MYDRV-READY to mydrv-state
\     1
\   else
\     MYDRV-ERROR to mydrv-state
\     0
\   then ;
\
\ : mydrv:status ( -- ok? )
\   mydrv-state MYDRV-READY = ;
\
\ : mydrv:info ( -- )
\   ." MyDriver v2.0" cr
\   ." Etat: " mydrv-state case
\     MYDRV-UNINIT of ." non initialise" endof
\     MYDRV-READY  of ." pret"           endof
\     MYDRV-ERROR  of ." erreur"         endof
\   endcase cr ;
\
\ \ ── Enregistrement ──
\ : mydrv-init ( -- )
\   mydrv:init if
\     ." MyDriver OK" cr
\   else
\     ." MyDriver ECHEC" cr
\   then ;
\
\ sys:register mydrv

\ --- Fin squelette driver v2 ---


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
\
\ Suffixes standards :
\
\   :init     — Initialisation unique
\   :read     — Lecture de données
\   :write    — Écriture de données
\   :status   — État courant
\   :info     — Affichage d'informations
\   :close    — Fermeture / libération
\   :test     — Auto-test
\
\ Nommage des values (v2025.2) :
\   mydrv-base   — adresse de base (value, modifiable)
\   mydrv-state  — état courant (value)
\   mydrv-lock   — mutex (constant)


\ ──────────────────────────────────────────────────────────────────────
\ B3. ACCÈS AUX PORTS I/O
\ ──────────────────────────────────────────────────────────────────────
\
\   inb  ( port -- byte )    Lecture 8-bit
\   outb ( byte port -- )    Écriture 8-bit
\   inw  ( port -- word )    Lecture 16-bit
\   outw ( word port -- )    Écriture 16-bit
\   inl  ( port -- long )    Lecture 32-bit
\   outl ( long port -- )    Écriture 32-bit

0x3F8 constant COM1-BASE
0x3FD constant COM1-LSR

: com1-ready? ( -- flag )
  COM1-LSR inb 0x20 and 0<> ;

: com1-data? ( -- flag )
  COM1-LSR inb 0x01 and 0<> ;

: com1-tx ( char -- )
  begin com1-ready? until
  COM1-BASE outb ;

: com1-rx ( -- char | -1 )
  com1-data? if COM1-BASE inb else -1 then ;

\ Pattern d'attente avec timeout (utilise ms yield) :

: wait-port ( port mask timeout_ms -- ok? )
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
\   mmio@ ( addr -- val )     Lecture 32-bit
\   mmio! ( val addr -- )     Écriture 32-bit
\   c@/c! w@/w! l@/l!        Lecture/écriture 8/16/32-bit

\ Pattern — registres avec struct (v2025.2) :

\ struct gpu-regs
\   field .mode
\   field .status
\   field .command
\   field .data
\ end-struct
\
\ 0 value gpu-base
\
\ : gpu-reg@ ( offset -- val )
\   gpu-base + mmio@ ;
\
\ : gpu-reg! ( val offset -- )
\   gpu-base + mmio! ;
\
\ : gpu-cmd! ( val -- )
\   .command gpu-reg! ;

\ Pattern — attente d'un bit :

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
\   pci-scan ( -- count )
\   pci-dev  ( idx -- bus dev func vid did class sub )
\   pci@     ( bus dev func off -- val )
\   pci!     ( val bus dev func off -- )
\   pci-bar  ( bus dev func barn -- addr size flag [type pref] )

: pci-find-device ( vid did -- bus dev func | -1 )
  pci-scan 0 ?do
    i pci-dev
    drop drop
    4 pick = if
      3 pick = if
        2drop
        unloop exit
      else
        drop
      then
    else
      2drop
    then
    drop drop drop
  loop
  2drop
  -1 ;

: pci-find-class ( class sub -- idx | -1 )
  pci-scan 0 ?do
    i pci-dev
    3 pick = if
      over = if
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
\   dw-i2c-init  ( base -- ok? )
\   dw-i2c-probe ( base addr -- ok? )
\   i2c-read     ( base dev reg -- val | -1 )

: i2c-scan-all ( base -- )
  dup dw-i2c-init 0= if
    drop ." Init echec" cr exit
  then
  128 0 do
    dup i dw-i2c-probe if
      ."   0x" i hex . decimal ."  PRESENT" cr
    then
  loop
  drop ;


\ ──────────────────────────────────────────────────────────────────────
\ B7. ACCÈS USB
\ ──────────────────────────────────────────────────────────────────────
\
\   usb:init      ( -- ok? )
\   usb:devices   ( -- n slot port speed vid pid conf ... )
\   usb:control   ( slot bm br wv wi buf len -- actual )
\   usb:bulk-read ( slot ep buf len -- actual )
\   usb:msd-probe ( -- n )
\   usb:msd-read  ( idx lba count buf -- ok? )

: usb-get-descriptor ( slot -- )
  0x80 6 0x0100 0 100 18 usb:control
  dup 0 > if
    ." Descripteur (" . ." octets)" cr
    18 0 do 100 i + @ hex . decimal loop cr
  else
    drop ." Echec" cr
  then ;


\ ──────────────────────────────────────────────────────────────────────
\ B8. INTERRUPTIONS
\ ──────────────────────────────────────────────────────────────────────
\
\   irq-handler ( vector dict_idx -- )

variable irq-count

: irq-counter ( -- )
  1 irq-count +! ;

\ Exemple :
\ ' irq-counter 33 irq-handler  \ IRQ1 = clavier


\ ──────────────────────────────────────────────────────────────────────
\ B9. ALLOCATION MÉMOIRE PHYSIQUE
\ ──────────────────────────────────────────────────────────────────────
\
\   alloc-phys ( pages -- addr | 0 )
\   free-phys  ( addr pages -- ok? )

: demo-alloc-phys ( -- )
  1 alloc-phys
  dup 0 = if drop ." Echec" cr exit then
  dup ." Buffer a 0x" hex . decimal cr
  dup 0x12345678 swap l!
  dup l@ 0x12345678 = if ." OK" else ." ECHEC" then cr
  1 free-phys drop ;

\ Pattern — buffer DMA avec cleanup garanti :

: with-phys ( pages xt -- )
  swap dup >r
  alloc-phys dup 0 = if drop r> drop ." Alloc echec" cr exit then
  dup >r swap execute
  r> r> free-phys drop ;


\ ──────────────────────────────────────────────────────────────────────
\ B10. TIMING ET DÉLAIS
\ ──────────────────────────────────────────────────────────────────────
\
\   ms       ( n -- )      Pause avec yield (ne bloque pas le scheduler)
\   attendre ( n -- )      Alias de ms
\   stall    ( us -- )     Délai UEFI (microsecondes, bloquant)
\   stall-us ( us -- )     Délai RDTSC (microsecondes, bloquant)
\   ticks    ( -- ms )     Millisecondes depuis le démarrage
\   rdtsc    ( -- tsc )    Compteur CPU brut
\
\ IMPORTANT v2025.2 : ms utilise maintenant le yield.
\ Pendant l'attente, la tâche cède la main aux autres tâches.
\ Pour un délai bloquant (drivers bas niveau), utiliser stall-us.

: benchmark ( xt -- ms )
  ticks swap execute ticks swap - ;

\ Utilisation :
\   ' mon-mot benchmark . ." ms" cr

: wait-with-timeout ( xt timeout_ms -- ok? )
  ticks +
  begin
    over execute if 2drop 1 exit then
    ticks over >= if 2drop 0 exit then
    1 ms
  again ;


\ ──────────────────────────────────────────────────────────────────────
\ B11. DRIVER COMPLET : UART 16550
\ ──────────────────────────────────────────────────────────────────────

0x3F8 constant UART-BASE
0x3FD constant UART-LSR
0x01 constant LSR-DATA-READY
0x20 constant LSR-TX-EMPTY

0 enum UART-UNINIT  enum UART-READY  enum UART-ERROR  drop

0 value uart-state
variable uart-tx-count
variable uart-rx-count
variable uart-errors

: uart:init ( baud -- ok? )
  115200 swap /
  0 0x3F9 outb
  0x80 0x3FB outb
  dup 0xFF and UART-BASE outb
  8 rshift 0xFF and 0x3F9 outb
  0x03 0x3FB outb
  0xC7 0x3FA outb
  0x0B 0x3FC outb
  0x1E 0x3FC outb
  0xAE UART-BASE outb
  100 0 do uart:rx-ready? if leave then 1 ms loop
  UART-BASE inb 0xAE = if
    0x0B 0x3FC outb
    UART-READY to uart-state
    0 uart-tx-count !  0 uart-rx-count !  0 uart-errors !
    1
  else
    UART-ERROR to uart-state  0
  then ;

: uart:tx-ready? ( -- flag )  UART-LSR inb LSR-TX-EMPTY and 0<> ;
: uart:rx-ready? ( -- flag )  UART-LSR inb LSR-DATA-READY and 0<> ;

: uart:tx ( char -- )
  uart-state UART-READY <> if drop exit then
  10 0 do uart:tx-ready? if leave then 1 ms loop
  uart:tx-ready? 0= if 1 uart-errors +! drop exit then
  UART-BASE outb  1 uart-tx-count +! ;

: uart:rx ( -- char | -1 )
  uart-state UART-READY <> if -1 exit then
  uart:rx-ready? if
    UART-BASE inb  1 uart-rx-count +!
  else -1 then ;

: uart:puts ( addr len -- )
  0 ?do dup i + @ 0xFF and uart:tx loop drop ;

: uart:info ( -- )
  ." === UART 16550 ===" cr
  ." Base: 0x" UART-BASE hex . decimal cr
  ." Etat: " uart-state case
    UART-UNINIT of ." non init" endof
    UART-READY  of ." pret"     endof
    UART-ERROR  of ." erreur"   endof
  endcase cr
  ." TX: " uart-tx-count @ . cr
  ." RX: " uart-rx-count @ . cr
  ." Err: " uart-errors @ . cr ;

: uart-init ( -- )
  115200 uart:init if
    ." UART 16550 OK (115200 8N1)" cr
  else
    ." UART 16550 ECHEC" cr
  then ;

sys:register uart


\ ──────────────────────────────────────────────────────────────────────
\ B12. DRIVER COMPLET : LED CLAVIER PS/2
\ ──────────────────────────────────────────────────────────────────────

0x60 constant KBD-DATA
0x64 constant KBD-STATUS

variable kbd-leds

: kbd-wait-input ( -- ok? )
  100 0 do KBD-STATUS inb 0x02 and 0= if 1 unloop exit then 1 ms loop 0 ;

: kbd-send ( byte -- ok? )
  kbd-wait-input 0= if drop 0 exit then
  KBD-DATA outb
  100 0 do
    KBD-STATUS inb 0x01 and 0<> if
      KBD-DATA inb 0xFA = if 1 unloop exit then
    then
    1 ms
  loop 0 ;

: led:set ( mask -- )
  7 and kbd-leds !
  0xED kbd-send drop
  kbd-leds @ kbd-send drop ;

: led:on ( bit -- )      kbd-leds @ or led:set ;
: led:off ( bit -- )     invert kbd-leds @ and led:set ;
: led:toggle ( bit -- )  kbd-leds @ xor led:set ;

: led:numlock    2 led:toggle ;
: led:capslock   4 led:toggle ;
: led:scrolllock 1 led:toggle ;

: led:knight-rider ( n -- )
  0 ?do
    1 led:set 100 ms
    2 led:set 100 ms
    4 led:set 100 ms
    2 led:set 100 ms
  loop
  0 led:set ;

: led:test ( -- )
  ." Test LEDs..." cr
  3 led:knight-rider
  ." OK" cr ;


\ ──────────────────────────────────────────────────────────────────────
\ B13. DRIVER COMPLET : TEMPÉRATURE CPU
\ ──────────────────────────────────────────────────────────────────────

0x19C constant MSR-THERM-STATUS
0x1A2 constant MSR-TEMP-TARGET

0 value cpu-tj-max

: temp:init ( -- ok? )
  try
    MSR-TEMP-TARGET msr@ drop 16 rshift 0xFF and
    dup 0 > if to cpu-tj-max else drop 100 to cpu-tj-max then
    1  0
  catch
    drop 100 to cpu-tj-max 1
  endtry ;

: temp:read ( -- celsius | -1 )
  try
    MSR-THERM-STATUS msr@ drop
    dup 0x80000000 and 0= if drop -1
    else 16 rshift 0x7F and cpu-tj-max swap - then
    0
  catch drop -1 endtry ;

: temp:info ( -- )
  ." === Temperature CPU ===" cr
  ." Tj_max: " cpu-tj-max . ." C" cr
  ." Actuelle: " temp:read dup -1 = if
    drop ." indisponible"
  else . ." C" then cr ;

: temp-init ( -- )
  temp:init if ." Capteur temp OK" cr
  else ." Capteur temp ECHEC" cr then ;

sys:register temp


\ ──────────────────────────────────────────────────────────────────────
\ B14. DRIVER COMPLET : WATCHDOG PCI (Intel TCO)
\ ──────────────────────────────────────────────────────────────────────

0 value tco-base
variable wdog-active

: wdog:find-tco ( -- ok? )
  pci-scan 0 ?do
    i pci-dev
    dup 0x01 = if over 0x06 = if
      drop drop drop
      2dup 0 0x50 pci@
      0xFFE0 and to tco-base
      drop drop drop
      tco-base 0 > if 1 unloop exit then
    else drop drop drop drop drop drop drop
    then else drop drop drop drop drop drop drop then
  loop 0 ;

: wdog:init ( seconds -- ok? )
  wdog:find-tco 0= if ." TCO non trouve" cr 0 exit then
  tco-base 8 + inw 0x0800 or tco-base 8 + outw
  tco-base 0x12 + inw 0xFC00 and or tco-base 0x12 + outw
  tco-base 8 + inw 0xF7FF and tco-base 8 + outw
  1 wdog-active ! 1 ;

: wdog:feed ( -- )
  wdog-active @ 0= if exit then
  tco-base 0x00 + inw 0x0008 or tco-base 0x00 + outw ;

: wdog:stop ( -- )
  wdog-active @ 0= if exit then
  tco-base 8 + inw 0x0800 or tco-base 8 + outw
  0 wdog-active ! ;

: wdog:info ( -- )
  ." === Watchdog TCO ===" cr
  ." Base: 0x" tco-base hex . decimal cr
  ." Actif: " wdog-active @ if ." OUI" else ." NON" then cr ;


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE C — ÉCRIRE UNE APPLICATION
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ C1. APPLICATION CONSOLE
\ ──────────────────────────────────────────────────────────────────────

: app-hello ( -- )
  cr ." === Hello Epona OS ===" cr
  ." Tapez un chiffre : "
  touche 48 -
  dup 0 >= over 9 <= and if
    cr ." Vous avez tape : " . cr
    ." Son carre : " dup * . cr
  else drop cr ." Pas un chiffre" cr then ;


\ ──────────────────────────────────────────────────────────────────────
\ C2. APPLICATION GRAPHIQUE (Canvas)
\ ──────────────────────────────────────────────────────────────────────

variable balle-x   variable balle-y
variable balle-dx  variable balle-dy

: balle-init ( -- )
  50 balle-x !  50 balle-y !  3 balle-dx !  2 balle-dy ! ;

: balle-move ( -- )
  balle-x @ balle-dx @ + balle-x !
  balle-y @ balle-dy @ + balle-y !
  balle-x @ 390 > if -3 balle-dx ! then
  balle-x @ 0 <   if  3 balle-dx ! then
  balle-y @ 290 > if -2 balle-dy ! then
  balle-y @ 0 <   if  2 balle-dy ! then ;

: balle-draw ( -- )
  balle-x @ balle-y @ 10 10 0xFF4444 rect ;

: demo-balle ( -- )
  balle-init
  begin
    0x000020 effacer
    balle-move balle-draw
    16 ms
    touche? 27 =
  until ;


\ ──────────────────────────────────────────────────────────────────────
\ C3. APPLICATION FENÊTRÉE (Widgets)
\ ──────────────────────────────────────────────────────────────────────

variable panneau-compteur

: panneau-inc ( -- )   1 panneau-compteur +! ;
: panneau-dec ( -- )  -1 panneau-compteur +! ;
: panneau-reset ( -- ) 0 panneau-compteur ! ;

: demo-panneau ( -- )
  0 panneau-compteur !
  widgets-clear
  100 100 300 200 app: "Panneau"
  10 10 80 25 button-push "Plus"  panneau-inc
  10 40 80 25 button-push "Moins" panneau-dec
  10 70 80 25 button-push "Reset" panneau-reset
  100 10 180 20 textfield: ;


\ ──────────────────────────────────────────────────────────────────────
\ C4. APPLICATION RÉSEAU
\ ──────────────────────────────────────────────────────────────────────

: ping-test ( -- )
  net:init 0= if ." Pas de carte" cr exit then
  net:dhcp 0= if ." DHCP echec" cr exit then
  ." Ping 8.8.8.8... "
  8 8 8 8 net:ping
  dup 0 < if drop ." timeout" else . ." ms" then cr ;


\ ──────────────────────────────────────────────────────────────────────
\ C5. APPLICATION DISQUE
\ ──────────────────────────────────────────────────────────────────────

: ls-root ( -- )
  disk:init 0= if ." Aucun disque" cr exit then
  cr ." === / ===" cr disk:ls / ;


\ ──────────────────────────────────────────────────────────────────────
\ C6. APPLICATION COMPLÈTE : MONITEUR SYSTÈME
\ ──────────────────────────────────────────────────────────────────────

: sysmon ( -- )
  cr ." === MONITEUR SYSTEME ===" cr
  ." CPU: " 0 cpuid drop swap drop swap drop ." leaf max=" . cr
  ." TSC: " rdtsc . cr
  ." Uptime: " ticks 1000 / . ." sec" cr
  ." RAM: " mem-map over 4 * 1024 / . ." MB total, "
  4 * 1024 / . ." MB libre" cr
  ." Ecran: " fb-size swap . ." x" . cr
  ." Heap: " heap-used . ." octets" cr
  ." PCI: " pci-scan . ." peripheriques" cr
  ." Heure: " get-time . ." /" . ." /" . ."  " . ." :" . ." :" . cr
  \ Température si disponible
  [defined] temp:read [if]
    ." Temp CPU: " temp:read dup -1 = if drop ." N/A"
    else . ." C" then cr
  [then]
  cr ;


\ ──────────────────────────────────────────────────────────────────────
\ C7. APPLICATION COMPLÈTE : TERMINAL SÉRIE
\ ──────────────────────────────────────────────────────────────────────

: minicom ( -- )
  115200 uart:init 0= if ." UART init echec" cr exit then
  cr ." === Minicom — Echap pour quitter ===" cr
  begin
    uart:rx dup -1 <> if emit else drop then
    touche? dup 27 = if drop cr ." Fin." cr exit then
    dup 0 <> if uart:tx else drop then
    1 ms
  again ;


\ ──────────────────────────────────────────────────────────────────────
\ C8. APPLICATION COMPLÈTE : ÉDITEUR HEXADÉCIMAL
\ ──────────────────────────────────────────────────────────────────────

: hex-line ( addr -- )
  dup ." 0x" hex . decimal ."  | "
  16 0 do
    dup i + c@ dup 16 < if ." 0" then hex . decimal space
  loop ." | "
  16 0 do
    dup i + c@ dup 32 >= over 126 <= and if emit else drop 46 emit then
  loop drop cr ;

: hexdump ( addr len -- )
  cr ." Adresse     | Hexadecimal                             | ASCII" cr
  over + swap
  begin 2dup > if dup hex-line 16 + else 2drop exit then again ;


\ ──────────────────────────────────────────────────────────────────────
\ C9. APPLICATION AVEC ÉVÉNEMENTS (EVENTS.FTH)
\ ──────────────────────────────────────────────────────────────────────
\
\ Exemple complet utilisant le système d'événements v2025.2 :

\ require EVENTS.FTH
\ require FIXED.FTH
\
\ 0 value obj-x
\ 0 value obj-y
\ 3 f.from value obj-vx
\ 2 f.from value obj-vy
\
\ : game-key ( char -- )
\   case
\     [char] w of obj-vy F.1 f- to obj-vy endof
\     [char] s of obj-vy F.1 f+ to obj-vy endof
\     [char] a of obj-vx F.1 f- to obj-vx endof
\     [char] d of obj-vx F.1 f+ to obj-vx endof
\     [char] q of stop endof
\     drop
\   endcase ;
\
\ : game-tick ( ms -- )
\   drop
\   obj-x obj-vx f+ to obj-x
\   obj-y obj-vy f+ to obj-y
\   0x000020 effacer
\   obj-x f.to obj-y f.to 10 10 0x00FF00 rect ;
\
\ ' game-key is on-key-press
\ ' game-tick is on-tick
\
\ : principal  event-loop ;


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE D — ÉCRIRE UN SIMULATEUR
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ D1. ARCHITECTURE D'UN SIMULATEUR CPU
\ ──────────────────────────────────────────────────────────────────────
\
\ Pattern v2025.2 avec value, case, enum :
\
\   \ Registres
\   0 value sim-pc
\   0 value sim-a
\   0 value sim-flags
\
\   \ Opcodes
\   0 enum OP-NOP  enum OP-LOAD  enum OP-STORE
\     enum OP-ADD  enum OP-HALT  drop
\
\   \ Mémoire simulée
\   256 buffer: sim-ram
\
\   : sim-fetch ( -- opcode )
\     sim-pc sim-ram + @ 0xFF and
\     sim-pc 1+ to sim-pc ;
\
\   : sim-step ( -- halt? )
\     sim-fetch case
\       OP-NOP   of 0 endof
\       OP-LOAD  of sim-fetch to sim-a 0 endof
\       OP-ADD   of sim-fetch sim-a + to sim-a 0 endof
\       OP-HALT  of 1 endof
\       ." Opcode inconnu" cr 1
\     endcase ;
\
\   : sim-run ( -- )
\     begin sim-step until ;


\ ──────────────────────────────────────────────────────────────────────
\ D2. SIMULATEUR CHIP-8 COMPLET
\ ──────────────────────────────────────────────────────────────────────

create c8-ram 4096 allot
create c8-v 16 allot
create c8-screen 2048 allot
variable c8-i  variable c8-pc  variable c8-sp
create c8-stack 16 allot
variable c8-dt  variable c8-st  variable c8-running

: c8-mem@ ( addr -- byte )  0xFFF and c8-ram + @ 0xFF and ;
: c8-mem! ( byte addr -- )  0xFFF and c8-ram + swap 0xFF and swap ! ;
: c8-v@ ( reg -- val )  0x0F and c8-v + @ 0xFF and ;
: c8-v! ( val reg -- )  0x0F and c8-v + swap 0xFF and swap ! ;

: c8-init ( -- )
  4096 0 do 0 i c8-ram + ! loop
  16 0 do 0 i c8-v + ! loop
  2048 0 do 0 i c8-screen + ! loop
  0 c8-i !  0x200 c8-pc !  0 c8-sp !
  0 c8-dt !  0 c8-st !  1 c8-running !
  \ Police 0-F (simplifié : chiffre 0)
  0xF0 0 c8-mem!  0x90 1 c8-mem!  0x90 2 c8-mem!
  0x90 3 c8-mem!  0xF0 4 c8-mem! ;

: c8-load ( src len -- )
  c8-init 0 ?do dup i + @ 0xFF and 0x200 i + c8-mem! loop drop ;

: c8-fetch ( -- op16 )
  c8-pc @ c8-mem@ 8 lshift c8-pc @ 1+ c8-mem@ or
  2 c8-pc +! ;

: c8-draw ( -- )
  0x000000 effacer
  32 0 do 64 0 do
    j 64 * i + c8-screen + @ 0<> if
      i 5 * 20 + j 5 * 20 + 5 5 0x00FF00 rect
    then
  loop loop ;

: c8-step ( -- )
  c8-running @ 0= if exit then
  c8-fetch
  dup 0xF000 and 12 rshift
  case
    0x0 of
      dup 0x00E0 = if 2048 0 do 0 i c8-screen + ! loop then
      dup 0x00EE = if -1 c8-sp +! c8-sp @ c8-stack + @ c8-pc ! then
    endof
    0x1 of dup 0x0FFF and c8-pc ! endof
    0x2 of c8-pc @ c8-sp @ c8-stack + !  1 c8-sp +!
           dup 0x0FFF and c8-pc ! endof
    0x6 of dup 0xFF and over 8 rshift 0x0F and c8-v! endof
    0x7 of dup 8 rshift 0x0F and dup c8-v@
           rot 0xFF and + 0xFF and swap c8-v! endof
    0xA of dup 0x0FFF and c8-i ! endof
  endcase
  drop
  c8-dt @ 0 > if -1 c8-dt +! then
  c8-st @ 0 > if -1 c8-st +! then ;

: c8-run ( -- )
  begin c8-step c8-draw 2 ms touche? 27 = c8-running @ 0= or until ;


\ ──────────────────────────────────────────────────────────────────────
\ D3. AUTOMATE CELLULAIRE (Jeu de la Vie)
\ ──────────────────────────────────────────────────────────────────────

40 constant LIFE-W
30 constant LIFE-H

create life-a  LIFE-W LIFE-H * allot
create life-b  LIFE-W LIFE-H * allot
variable life-gen  variable life-current

: life-grid ( -- addr )  life-current @ 0= if life-a else life-b then ;
: life-other ( -- addr ) life-current @ 0= if life-b else life-a then ;

: life-get ( x y -- 0|1 )
  swap LIFE-W mod swap LIFE-H mod
  LIFE-W * + life-grid + @ ;

: life-set! ( val x y -- )
  LIFE-W * + life-grid + swap 1 and swap ! ;

: life-clear ( -- )
  LIFE-W LIFE-H * 0 do 0 i life-a + ! 0 i life-b + ! loop
  0 life-gen !  0 life-current ! ;

: life-neighbors ( x y -- n )
  0
  3 0 do 3 0 do
    i 1 - j 1 - or 0<> if
      4 pick i 1 - + 4 pick j 1 - + life-get +
    then
  loop loop
  rot rot 2drop ;

: life-step ( -- )
  LIFE-H 0 do LIFE-W 0 do
    i j life-neighbors
    i j life-get if
      dup 2 < if drop 0
      else 3 > if 0 else 1 then then
    else 3 = if 1 else 0 then then
    i j LIFE-W * + life-other + !
  loop loop
  life-current @ 0= if 1 else 0 then life-current !
  1 life-gen +! ;

: life-draw ( -- )
  0x000000 effacer
  LIFE-H 0 do LIFE-W 0 do
    i j life-get 0<> if
      i 10 * j 10 * 9 9 0x00FF00 rect
    then
  loop loop ;

: life-glider ( x y -- )
  2dup 1 -rot life-set!
  2dup swap 1+ swap 1+ 1 -rot life-set!
  2dup swap 1- swap 2 + 1 -rot life-set!
  2dup swap swap 2 + 1 -rot life-set!
  swap 1+ swap 2 + 1 -rot life-set! ;

: life-run ( -- )
  life-clear  10 5 life-glider  20 10 life-glider
  begin life-draw life-step 50 ms touche? 27 = until ;


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
\     \ n = nombre d'éléments
\     \ addr = adresse du buffer
\     \ result = résultat
\     \ flag = 1 si succès
\     ... ;


\ ──────────────────────────────────────────────────────────────────────
\ E2. GESTION DES ERREURS DANS LES DRIVERS
\ ──────────────────────────────────────────────────────────────────────

: safe-mmio@ ( addr -- val | 0 )
  try mmio@ 0 catch drop 0 endtry ;

\ Pattern — chaîne d'initialisation :
\ : driver-init ( -- ok? )
\   step1-init 0= if 0 exit then
\   step2-init 0= if step1-cleanup 0 exit then
\   1 ;

\ Pattern — retry :
: retry-op ( xt retries -- ok? )
  0 ?do dup execute if drop 1 unloop exit then i 10 * ms loop drop 0 ;


\ ──────────────────────────────────────────────────────────────────────
\ E3. TESTS DE DRIVERS
\ ──────────────────────────────────────────────────────────────────────
\
\ Chaque driver devrait avoir un mot :test
\ Utiliser le framework de TESTS.FTH :
\
\   : uart:test ( -- )
\     section
\     ." UART init... "
\     115200 uart:init assert-true
\     uart:status assert-true
\     section-end ;


\ ──────────────────────────────────────────────────────────────────────
\ E4. PERFORMANCE
\ ──────────────────────────────────────────────────────────────────────
\
\ 1. Éviter les allocations en boucle
\    BON : create buf 512 allot  (ou buffer:)
\ 2. Utiliser value au lieu de variable pour l'état
\ 3. Utiliser case au lieu de if/else imbriqués
\ 4. ms yield (v2025.2) — ne bloque plus les autres tâches
\ 5. Benchmark :  ' mon-mot benchmark . ." ms"


\ ──────────────────────────────────────────────────────────────────────
\ E5. SÉCURITÉ
\ ──────────────────────────────────────────────────────────────────────
\
\ Mode sécurisé (secure on) bloque :
\   - MMIO, ports I/O, PCI
\   - Mémoire Forth restreinte à [0..256[
\   - Réseau, fichiers (sauf /SAFE/)
\   - reboot/poweroff, alloc-phys
\
\ Utiliser abort" pour valider les paramètres :
\   : check ( port -- )
\     dup 0 < abort" Port negatif !"
\     dup 65535 > abort" Port hors limites !"
\     drop ;


\ ──────────────────────────────────────────────────────────────────────
\ E6. PORTABILITÉ
\ ──────────────────────────────────────────────────────────────────────
\
\ EponaForth n'est PAS ANS Forth.
\ Différences : cellules 64-bit, mémoire en i64,
\ pas de vocabulaires, pas de virgule flottante native.
\
\ Pour du code portable :
\   - Utiliser cell+ et cells
\   - Documenter les dépendances
\   - Utiliser [defined] pour tester les fonctionnalités
\   - Séparer logique métier et accès matériel


\ ──────────────────────────────────────────────────────────────────────
\ E7. SYNCHRONISATION MULTITÂCHE (v2025.2)
\ ──────────────────────────────────────────────────────────────────────
\
\ Chargement : require MUTEX.FTH
\
\ Règles :
\   1. Toujours protéger les variables partagées
\   2. mutex:with garantit le unlock même en cas d'erreur
\   3. ms yield — les attentes ne monopolisent plus le CPU
\   4. Sections critiques : max quelques instructions
\   5. Timeout anti-deadlock : 100k instructions max
\
\ Pattern recommandé :
\   mutex:create constant my-lock
\   : safe-op ( -- ) my-lock ' do-op mutex:with ;
\
\ Pattern producteur/consommateur :
\   32 chan:create constant work-chan
\   : producer  begin ticks work-chan chan:send 100 ms again ;
\   : consumer  begin work-chan chan:recv . cr again ;
\   ' producer task  ' consumer task


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
\   depth .s pile  >r r> r@
\
\ === ARITHMÉTIQUE ===
\   + - * / mod /mod 1+ 1- 2+ 2- 2* 2/
\   abs negate min max hasard
\
\ === COMPARAISON ===
\   = <> < > <= >= 0= 0<> 0< 0>
\
\ === LOGIQUE ===
\   and or xor invert lshift rshift
\
\ === MÉMOIRE FORTH ===
\   @ ! +! variable constant value to
\   here allot , create does>
\   cell+ cells aligned char+ chars
\   erase move
\
\ === MÉMOIRE PHYSIQUE ===
\   c@ c! w@ w! l@ l! mmio@ mmio! phys@ phys!
\   alloc-phys free-phys
\
\ === AFFICHAGE ===
\   . u. cr space spaces emit type
\   ." ... s" ... hex decimal
\
\ === CONTRÔLE ===
\   if else then  begin until again
\   begin while repeat  do loop +loop ?do leave i j
\   case of endof endcase  exit recurse
\   try catch endtry throw  abort"
\
\ === COMPILATION ===
\   : ; immediate  ' execute postpone
\   [char] char  state ] [  find literal forget
\   see word-info  defer is  value to
\   include require
\   [if] [else] [then] [defined] [undefined]
\   struct field end-struct  enum  buffer:  marker
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
\   ms attendre ticks stall stall-us  get-time set-time
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
\   hda-info hda-beep hda-status  beep
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
\ === SYNCHRONISATION ===
\   critical-begin critical-end
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
\   step trace .ops  break unbreak watch unwatch
\   see word-info


\ ──────────────────────────────────────────────────────────────────────
\ F2. CODES D'ERREUR RECOMMANDÉS
\ ──────────────────────────────────────────────────────────────────────
\
\   -1   Erreur générique
\   -2   Timeout
\   -3   Périphérique non trouvé
\   -4   Erreur de communication
\   -5   Buffer trop petit
\   -6   Opération non supportée
\   -7   Permission refusée
\   -8   Ressource occupée
\   -9   Adresse invalide
\   -10  Paramètre hors limites
\   -11  Pile vide
\   -12  Pile pleine
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

0xFF0000 constant ROUGE
0x00FF00 constant VERT
0x0000FF constant BLEU
0xFFFFFF constant BLANC
0x000000 constant NOIR
0xFFFF00 constant JAUNE
0xFF00FF constant MAGENTA
0x00FFFF constant CYAN
0x808080 constant GRIS

10 constant LF
13 constant CR-CHAR
27 constant ESC
4096 constant PAGE-SIZE
512 constant SECTOR-SIZE

0x01 constant PCI-STORAGE
0x02 constant PCI-NETWORK
0x03 constant PCI-DISPLAY
0x06 constant PCI-BRIDGE


\ ──────────────────────────────────────────────────────────────────────
\ F4. PATTERNS COURANTS
\ ──────────────────────────────────────────────────────────────────────
\
\ --- Bitmask ---
\ : bit ( n -- mask )  1 swap lshift ;
\ : bit? ( val n -- flag )  bit and 0<> ;
\ : bit-set ( val n -- val' )  bit or ;
\ : bit-clear ( val n -- val' )  bit invert and ;
\
\ --- Buffer circulaire ---
\ 256 constant RING-SIZE
\ 256 buffer: ring-buf
\ variable ring-head  variable ring-tail
\
\ --- Table de sauts (avec defer) ---
\ defer handler
\ create handlers ' h0 , ' h1 , ' h2 ,
\ : dispatch ( n -- ) cells handlers + @ is handler handler ;
\
\ --- Compteur saturé ---
\ : sat+ ( val max -- val' ) over + over min nip ;
\
\ --- State machine avec enum+case ---
\ 0 enum ST-IDLE enum ST-RUN enum ST-DONE drop
\ 0 value state
\ : tick case
\     ST-IDLE of ... ST-RUN to state endof
\     ST-RUN  of ... ST-DONE to state endof
\   endcase ;


\ ──────────────────────────────────────────────────────────────────────
\ F5. BIBLIOTHÈQUES DISPONIBLES (v2025.2)
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌──────────────┬─────────────────────────────┬───────────────────────┐
\ │ Fichier      │ require                     │ Mots clés             │
\ ├──────────────┼─────────────────────────────┼───────────────────────┤
\ │ STDLIB.FTH   │ require STDLIB.FTH          │ true false bl tab     │
\ │              │                             │ max3 clamp within     │
\ │              │                             │ bounds /string        │
\ │              │                             │ [] matrix[] 0.r hex.  │
\ │              │                             │ ? ?? >number f>str    │
\ │              │                             │ time>str date>str     │
\ │              │                             │ times for map         │
\ │              │                             │ array:create push pop │
\ ├──────────────┼─────────────────────────────┼───────────────────────┤
\ │ FIXED.FTH    │ require FIXED.FTH           │ f+ f- f* f/ fsqrt    │
\ │              │                             │ fsin fcos ftan fatan  │
\ │              │                             │ v2.add v2.len         │
\ │              │                             │ v2.normalize v2.rot  │
\ │              │                             │ phys.move plot.curve  │
\ │              │                             │ sensor.* f. f.n       │
\ ├──────────────┼─────────────────────────────┼───────────────────────┤
\ │ MUTEX.FTH    │ require MUTEX.FTH           │ critical-begin/end   │
\ │              │                             │ spin:* mutex:*        │
\ │              │                             │ sem:* chan:*           │
\ │              │                             │ rwlock:* barrier:*    │
\ │              │                             │ pool:* tls:*          │
\ ├──────────────┼─────────────────────────────┼───────────────────────┤
\ │ EVENTS.FTH   │ require EVENTS.FTH          │ on-key-press          │
\ │              │                             │ on-mouse-move/click   │
\ │              │                             │ on-tick on-quit        │
\ │              │                             │ event-loop            │
\ ├──────────────┼─────────────────────────────┼───────────────────────┤
\ │ TESTS.FTH    │ sys:load TESTS.FTH          │ assert= assert-true  │
\ │              │                             │ section section-end   │
\ │              │                             │ lancer-tests          │
\ ├──────────────┼─────────────────────────────┼───────────────────────┤
\ │ DEVGUIDE.FTH │ sys:load DEVGUIDE.FTH       │ sysmon hexdump       │
\ │              │                             │ uart:* led:* temp:*   │
\ │              │                             │ c8-run life-run       │
\ └──────────────┴─────────────────────────────┴───────────────────────┘


\ ════════════════════════════════════════════════════════════════════════
\        PARTIE G — ROADMAP LANGAGE (mise à jour v2025.2)
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ G1. BILAN DES 20 MOTS IMPLÉMENTÉS
\ ──────────────────────────────────────────────────────────────────────
\
\ Les 20 mots de la roadmap initiale sont tous fonctionnels.
\
\ ┌────┬──────────────────────────┬───────┬────────────┬──────────────┐
\ │  # │ Mot                      │ Phase │ Difficulté │ Statut       │
\ ├────┼──────────────────────────┼───────┼────────────┼──────────────┤
\ │  1 │ see                      │   1   │ Faible     │ ✅ FAIT      │
\ │  2 │ value / to               │   1   │ Moyenne    │ ✅ FAIT      │
\ │  3 │ defer / is               │   1   │ Moyenne    │ ✅ FAIT      │
\ │  4 │ case/of/endof/endcase    │   1   │ Moyenne    │ ✅ FAIT      │
\ │  5 │ [char] / char            │   1   │ Triviale   │ ✅ FAIT      │
\ ├────┼──────────────────────────┼───────┼────────────┼──────────────┤
\ │  6 │ \n dans ."               │   2   │ Triviale   │ ✅ FAIT      │
\ │  7 │ abort"                   │   2   │ Faible     │ ✅ FAIT      │
\ │  8 │ include / require        │   2   │ Faible     │ ✅ FAIT      │
\ │  9 │ [if] / [then]            │   2   │ Faible     │ ✅ FAIT      │
\ │ 10 │ type                     │   2   │ Triviale   │ ✅ FAIT      │
\ ├────┼──────────────────────────┼───────┼────────────┼──────────────┤
\ │ 11 │ ,"                       │   3   │ Faible     │ ✅ FAIT      │
\ │ 12 │ count                    │   3   │ Triviale   │ ✅ FAIT      │
\ │ 13 │ compare                  │   3   │ Faible     │ ✅ FAIT      │
\ │ 14 │ search                   │   3   │ Moyenne    │ ✅ FAIT      │
\ │ 15 │ marker                   │   3   │ Moyenne    │ ✅ FAIT      │
\ ├────┼──────────────────────────┼───────┼────────────┼──────────────┤
\ │ 16 │ buffer:                  │   4   │ Triviale   │ ✅ FAIT      │
\ │ 17 │ struct / field           │   4   │ Moyenne    │ ✅ FAIT      │
\ │ 18 │ enum                     │   4   │ Triviale   │ ✅ FAIT      │
\ │ 19 │ [defined]                │   4   │ Triviale   │ ✅ FAIT      │
\ │ 20 │ word-info                │   4   │ Triviale   │ ✅ FAIT      │
\ └────┴──────────────────────────┴───────┴────────────┴──────────────┘
\
\ Op bytecode ajoutés : Op::ValueAddr, Op::ToValue,
\                       Op::CallDeferred, Op::AbortQuote
\
\ Corrections Rust associées :
\   - ms yield (ne bloque plus le scheduler)
\   - critical-begin/end (primitives 310-311)
\   - critical_depth dans ForthVm
\   - Timeout anti-deadlock 100k instructions


\ ──────────────────────────────────────────────────────────────────────
\ G2. PROCHAINS MOTS À IMPLÉMENTER (Phase 5)
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌────┬──────────────────────────┬────────────┬───────────┬──────────────────────┐
\ │  # │ Mot                      │ Difficulté │ Nouv. Op  │ Impact               │
\ ├────┼──────────────────────────┼────────────┼───────────┼──────────────────────┤
\ │ 21 │ does> (standard)         │ Moyenne    │     0     │ Mots créateurs       │
\ │ 22 │ action-of               │ Triviale   │     0     │ Inspection defer     │
\ │ 23 │ synonym                  │ Triviale   │     0     │ Alias de mots        │
\ │ 24 │ ['] (tick en compilation)│ Triviale   │     0     │ Confort compilation  │
\ │ 25 │ parse / parse-name       │ Moyenne    │     0     │ Parsing avancé       │
\ ├────┼──────────────────────────┼────────────┼───────────┼──────────────────────┤
\ │ 26 │ evaluate                 │ Moyenne    │     0     │ Eval dynamique       │
\ │ 27 │ refill                   │ Faible     │     0     │ Input multi-ligne    │
\ │ 28 │ source                   │ Faible     │     0     │ Input inspection     │
\ │ 29 │ >body                    │ Triviale   │     0     │ Accès create data    │
\ │ 30 │ [compile]                │ Triviale   │     0     │ Force compilation    │
\ ├────┼──────────────────────────┼────────────┼───────────┼──────────────────────┤
\ │ 31 │ locals ({\})              │ Haute      │     2     │ Variables locales    │
\ │ 32 │ exception names          │ Moyenne    │     0     │ Debug exceptions     │
\ │ 33 │ vocabularies             │ Haute      │     1     │ Namespaces           │
\ │ 34 │ float (logiciel)          │ Haute      │     4+    │ Calcul scientifique  │
\ │ 35 │ regexp (basique)          │ Haute      │     0     │ Parsing puissant     │
\ └────┴──────────────────────────┴────────────┴───────────┴──────────────────────┘
\
\ Priorité recommandée :
\   Immédiat (1 jour) : synonym, ['], action-of, >body
\   Court terme (1 sem) : does> standard, evaluate, parse
\   Moyen terme (2 sem) : locals, vocabularies
\   Long terme (1 mois) : float logiciel, regexp


\ ──────────────────────────────────────────────────────────────────────
\ G3. ÉVOLUTION DU RUNTIME RUST
\ ──────────────────────────────────────────────────────────────────────
\
\ Corrections Rust encore possibles :
\
\ ┌────┬────────────────────────────┬────────────┬───────────────────────┐
\ │  # │ Problème                   │ Effort     │ Impact                │
\ ├────┼────────────────────────────┼────────────┼───────────────────────┤
\ │  1 │ string_pool nettoyage      │ 1 heure    │ Fuite mémoire        │
\ │    │ dans forget                │            │                       │
\ ├────┼────────────────────────────┼────────────┼───────────────────────┤
\ │  2 │ touche bloquant avec yield│ 30 min     │ Programmes interactifs│
\ │    │ (comme ms)                 │            │                       │
\ ├────┼────────────────────────────┼────────────┼───────────────────────┤
\ │  3 │ Limite instructions       │ 30 min     │ Programmes longs      │
\ │    │ configurable               │            │                       │
\ ├────┼────────────────────────────┼────────────┼───────────────────────┤
\ │  4 │ Backtrace Forth           │ 2 heures   │ Debug                 │
\ │    │ (call stack dans erreurs)  │            │                       │
\ ├────┼────────────────────────────┼────────────┼───────────────────────┤
\ │  5 │ Mémoire u8 séparée        │ 1 jour     │ Buffers DMA/réseau   │
\ │    │ pour les buffers           │            │                       │
\ ├────┼────────────────────────────┼────────────┼───────────────────────┤
\ │  6 │ evaluate (compile+exec    │ 2 heures   │ Eval dynamique       │
\ │    │ une chaîne)                │            │                       │
\ └────┴────────────────────────────┴────────────┴───────────────────────┘


\ ──────────────────────────────────────────────────────────────────────
\ G4. ÉCOSYSTÈME DE FICHIERS .FTH
\ ──────────────────────────────────────────────────────────────────────
\
\ État actuel des fichiers .FTH :
\
\ ┌──────────────────┬──────────┬──────────────────────────────────────┐
\ │ Fichier          │ Statut   │ Description                          │
\ ├──────────────────┼──────────┼──────────────────────────────────────┤
\ │ BOOT.FTH         │ ✅ FAIT  │ Amorçage structuré                  │
\ │ STDLIB.FTH       │ ✅ FAIT  │ Bibliothèque standard               │
\ │ FIXED.FTH        │ ✅ FAIT  │ Virgule fixe Q20.12                 │
\ │ MUTEX.FTH        │ ✅ FAIT  │ Synchronisation                     │
\ │ EVENTS.FTH       │ ✅ FAIT  │ Événements                          │
\ │ TESTS.FTH        │ ✅ FAIT  │ Suite de tests                      │
\ │ DEVGUIDE.FTH     │ ✅ FAIT  │ Documentation développeur           │
\ │ GUIDE.txt        │ ✅ FAIT  │ Guide utilisateur complet           │
\ ├──────────────────┼──────────┼──────────────────────────────────────┤
\ │ GUIKIT.FTH       │ 🔲 TODO │ Toolkit UI (fenêtres, widgets)      │
\ │ CHIP8.FTH        │ 🔲 TODO │ Simulateur CHIP-8 complet           │
\ │ SNAKE.FTH        │ 🔲 TODO │ Jeu Snake                           │
\ │ RAYCAST.FTH      │ 🔲 TODO │ Raycaster 3D                        │
\ │ FILEMAN.FTH      │ 🔲 TODO │ Gestionnaire de fichiers            │
\ │ HTTPD.FTH        │ 🔲 TODO │ Serveur HTTP basique                │
\ │ STRINGS.FTH      │ 🔲 TODO │ Traitement de chaînes avancé        │
\ │ ASSERT.FTH       │ 🔲 TODO │ Framework d'assertions étendu       │
\ └──────────────────┴──────────┴──────────────────────────────────────┘


\ ──────────────────────────────────────────────────────────────────────
\ G5. PLANNING DE DÉVELOPPEMENT
\ ──────────────────────────────────────────────────────────────────────
\
\ === PHASE ACTUELLE : STABILISATION ET CONTENU ===
\
\ Le langage est fonctionnel. Le runtime est stable.
\ La priorité est maintenant de construire du contenu :
\   - Applications de référence
\   - Jeux
\   - Drivers utilisables
\   - Documentation par l'exemple
\
\ ┌────────────┬──────────────────────────────────────────────────────┐
\ │ Semaine 1  │ GUIKIT.FTH — Toolkit UI                            │
\ │            │ Fenêtres, labels, boutons, sliders                  │
\ │            │ Basé sur EVENTS.FTH et widgets existants            │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 2  │ CHIP-8 complet + SNAKE.FTH                         │
\ │            │ Tous les 35 opcodes, polices, clavier               │
\ │            │ Snake avec FIXED.FTH + EVENTS.FTH                  │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 3  │ RAYCAST.FTH — Raycaster Wolfenstein                │
\ │            │ Rendu 3D en virgule fixe                            │
\ │            │ Déplacement WASD + souris                           │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 4  │ Corrections Rust (string_pool, touche, backtrace)  │
\ │            │ FILEMAN.FTH — Explorateur de fichiers              │
\ │            │ HTTPD.FTH — Serveur HTTP basique                   │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 5  │ Mots avancés : synonym, evaluate, ['], action-of   │
\ │            │ ASSERT.FTH — Framework de test étendu              │
\ │            │ STRINGS.FTH — Traitement de chaînes avancé         │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 6+ │ does> standard, locals, vocabularies               │
\ │            │ Float logiciel (optionnel)                          │
\ │            │ Bluetooth HCI (si puce présente)                   │
\ └────────────┴──────────────────────────────────────────────────────┘
\
\ === INDICATEURS DE MATURITÉ ===
\
\ ┌─────────────────────────────┬───────┬──────────────────────────────┐
\ │ Critère                     │ Cible │ Actuel                       │
\ ├─────────────────────────────┼───────┼──────────────────────────────┤
\ │ Primitives Rust             │ 300   │ ~290 ✅                      │
\ │ Mots Forth dans dictionnaire│ 500+  │ ~350 (avec bibliothèques)   │
\ │ Tests automatisés           │ 250+  │ ~180 ✅                      │
\ │ Bibliothèques .FTH          │ 15+   │ 7 ✅                         │
\ │ Applications de référence   │ 10+   │ 5 (sysmon, minicom, etc.)   │
\ │ Jeux                        │ 3+    │ 1 (balle rebondissante)     │
\ │ Drivers Forth               │ 5+    │ 4 (uart, led, temp, wdog)   │
\ │ Simulateurs                 │ 2+    │ 2 (CHIP-8 partiel, Life)    │
\ │ Documentation (lignes)      │ 5000+ │ ~4000 ✅                     │
\ └─────────────────────────────┴───────┴──────────────────────────────┘
\
\ === VISION LONG TERME ===
\
\ EponaForth est un langage système embarqué dans un OS bare-metal.
\ L'objectif n'est pas de devenir un Forth ANS complet,
\ mais d'être la meilleure plateforme pour :
\
\   1. Explorer le matériel directement (drivers)
\   2. Prototyper des idées rapidement (scripts)
\   3. Construire des applications autonomes (apps)
\   4. Apprendre la programmation système (éducation)
\   5. Simuler des machines (simulateurs)
\
\ Chaque fichier .FTH ajouté rend EponaForth plus utile.
\ Chaque driver ajouté rend Epona OS plus capable.
\ Chaque jeu ajouté rend le système plus attrayant.


\ ════════════════════════════════════════════════════════════════════════
\              FIN DU GUIDE DÉVELOPPEUR EPONA OS v2026.2
\ ════════════════════════════════════════════════════════════════════════

cr
." ════════════════════════════════════════════════════════" cr
."  DEVGUIDE.FTH v2025.2 charge" cr
."  20/20 mots roadmap implementes" cr
."  Bibliotheques : STDLIB FIXED MUTEX EVENTS" cr
."  Drivers : uart led temp wdog" cr
."  Demos : sysmon minicom hexdump" cr
."  Simulateurs : c8-run life-run" cr
."  Tapez 'sysmon' / 'led:test' / 'demo-balle'" cr
." ════════════════════════════════════════════════════════" cr
```

---

## Ce qui a changé par rapport à la version précédente

| Section | Changement |
|---|---|
| **A3** | Ajouté `CallDeferred`, `ValueAddr`, `ToValue`, `AbortQuote` dans la liste des Op |
| **A4** | Ajouté `immediate`, `marker` dans le cycle de vie |
| **A6** | Réécrit avec ms yield, critical_depth, MUTEX.FTH |
| **A7** | **Nouvelle section** — liste des 5 bibliothèques |
| **B1** | Squelette driver réécrit avec `value`, `enum`, `struct`, `case`, `mutex` |
| **B2** | Ajouté conventions pour `value` et `mutex` |
| **B3-B10** | Patterns mis à jour avec `ms` yield, `struct`, `value` |
| **B11** | Driver UART réécrit avec `enum`, `value`, `case` |
| **B13** | Driver temp réécrit avec `try/catch`, `value` |
| **C9** | **Nouvelle section** — application avec EVENTS.FTH |
| **D1** | Pattern simulateur réécrit avec `value`, `enum`, `case`, `buffer:` |
| **E7** | **Nouvelle section** — synchronisation multitâche |
| **F1** | Ajouté : `value to defer is case of endof endcase include require` etc. |
| **F4** | Patterns avec `defer`, `enum`, `case`, `value` |
| **F5** | **Nouvelle section** — tableau des bibliothèques |
| **G1** | **Réécrit** — bilan 20/20 mots ✅ |
| **G2** | **Réécrit** — prochains 15 mots (phase 5) |
| **G3** | **Réécrit** — corrections Rust restantes |
| **G4** | **Réécrit** — écosystème fichiers avec statut |
| **G5** | **Réécrit** — planning semaines + indicateurs de maturité |
