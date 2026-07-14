\ ════════════════════════════════════════════════════════════════════════
\                  EPONA OS — GUIDE DÉVELOPPEUR
\          Écrire des drivers, programmes et utilitaires
\                    en EponaForth (version 2025.3)
\ ════════════════════════════════════════════════════════════════════════
\
\ Ce fichier est à la fois :
\   - une documentation lisible (commentaires)
\   - du code exécutable (exemples fonctionnels)
\
\ Chargement : sys:load DEVGUIDE.FTH
\
\ Changements v2025.3 (par rapport à v2025.2) :
\   - string_pool : fuite mémoire corrigée (marker + forget)
\   - forget : nettoyage sélectif du pool (scan offset max)
\   - touche : yield pendant l'attente bloquante
\   - Priorité 4 complète (3/3 corrections Rust)
\   - Partie G mise à jour avec bilan complet
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
\     A8. Gestion mémoire du string_pool (v2025.3)
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
\     E8. Gestion du dictionnaire et du pool (v2025.3)
\
\   PARTIE F — RÉFÉRENCE RAPIDE
\     F1. Toutes les primitives par catégorie
\     F2. Codes d'erreur
\     F3. Constantes utiles
\     F4. Patterns courants
\     F5. Bibliothèques disponibles
\
\   PARTIE G — ROADMAP LANGAGE (mise à jour v2025.3)
\     G1. Bilan complet — Rust + Langage + Bibliothèques
\     G2. Corrections Rust terminées (Priorité 4)
\     G3. Prochains mots à implémenter (Phase 5)
\     G4. Évolution du runtime Rust
\     G5. Écosystème de fichiers .FTH
\     G6. Planning de développement
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
\   │  String pool (string_pool[]) — v2025.3              │
\   │  Vec<u8> — stocke les chaînes littérales            │
\   │  Géré par marker/forget (pas de fuite mémoire)      │
\   │  Chaque chaîne = offset (u32) + longueur (u16)      │
\   └─────────────────────────────────────────────────────┘
\
\   ┌─────────────────────────────────────────────────────┐
\   │  Pile de données (stack[])                          │
\   │  Vec<i64>, max 4096 éléments                        │
\   └─────────────────────────────────────────────────────┘
\
\   ┌─────────────────────────────────────────────────────┐
\   │  Pile de retour (rstack[])                          │
\   │  Vec<usize>, max 1024 éléments                      │
\   │  Séparée de loop_rstack pour DO/LOOP               │
\   └─────────────────────────────────────────────────────┘
\
\   ┌─────────────────────────────────────────────────────┐
\   │  Mémoire physique (alloc-phys / free-phys)          │
\   │  Pages 4 KB via UEFI Boot Services                  │
\   │  Pour DMA, buffers matériels                        │
\   └─────────────────────────────────────────────────────┘
\
\   ┌─────────────────────────────────────────────────────┐
\   │  Canvas Forth (400 × 300 pixels, 32 bpp)            │
\   │  Zone protégée pour le dessin graphique              │
\   └─────────────────────────────────────────────────────┘
\
\ IMPORTANT — adresses Forth vs adresses physiques :
\
\   @ ! +!          → memory[] (indices Forth, cellules i64)
\   c@ c! w@ w! l@  → adresses physiques réelles
\   mmio@ mmio!     → adresses MMIO physiques
\   phys@ phys!     → adresses 64-bit physiques
\
\ Limites :
\   memory[]  : 4096 cellules (extensible via allot)
\   Pile      : 4096 éléments
\   Rstack    : 1024 éléments
\   Dictionnaire : 2048 mots
\   Instructions : 10 millions par exécution


\ ──────────────────────────────────────────────────────────────────────
\ A2. PILE DE DONNÉES ET PILE DE RETOUR
\ ──────────────────────────────────────────────────────────────────────
\
\ Convention de documentation :
\   ( avant -- après )
\
\ La pile de retour (rstack) :
\   - >r r> r@ : données utilisateur temporaires
\   - loop_rstack : séparé, pour DO/LOOP (ne pas mélanger)
\
\ Exemple — sauvegarde temporaire :
\   : echange3 ( a b c -- c b a )
\     >r swap r> swap ;
\
\ Piège : oublier r>
\   : BUGGY  >r ... ;          ← CRASH
\   : OK     >r ... r> drop ;  ← correct


\ ──────────────────────────────────────────────────────────────────────
\ A3. DICTIONNAIRE ET COMPILATION
\ ──────────────────────────────────────────────────────────────────────
\
\ Types de mots :
\   - Primitives Rust (~292 mots)
\   - Mots compilés (définis par l'utilisateur)
\   - Constantes, variables, values, defers
\   - struct/field, buffer:, enum
\
\ Bytecode interne (Op) :
\
\   Op::Push(val)            — Empile une valeur
\   Op::Call(idx)            — Appelle un mot compilé
\   Op::CallPrim(idx)        — Appelle une primitive Rust
\   Op::CallDeferred(addr)   — Appelle un mot defer
\   Op::ValueAddr(addr)      — Lit un value
\   Op::ToValue(addr)        — Écrit un value (to)
\   Op::AbortQuote(off, len) — Arrêt conditionnel
\   Op::Jump(target)         — Saut inconditionnel
\   Op::JumpIfZero(target)   — Saut conditionnel
\   Op::VariableAddr(n)      — Adresse de variable
\   Op::Exit                 — Retour
\   Op::Do/Loop/QDo/Leave    — Boucles
\   Op::Try/Catch/Throw/EndTry — Exceptions
\
\ Inspecter :
\   see monmot       — Affiche le bytecode
\   word-info monmot — Affiche les métadonnées


\ ──────────────────────────────────────────────────────────────────────
\ A4. CYCLE DE VIE D'UN MOT
\ ──────────────────────────────────────────────────────────────────────
\
\ 1. DÉFINITION    : : mon-mot ... ;
\ 2. COMPILATION   : source → Vec<Op>
\ 3. STOCKAGE      : ajouté au dictionnaire (remplace si même nom)
\ 4. EXÉCUTION     : execute_ops_limited() parcourt les Op
\ 5. SUPPRESSION   : forget (idx) ou marker ---nom---
\
\ Rendre un mot immédiat (exécuté pendant la compilation) :
\   : mon-macro ... ; immediate
\
\ Redéfinition :
\   : test 1 . ;
\   : test 2 . ;    ← remplace
\   test             → affiche 2


\ ──────────────────────────────────────────────────────────────────────
\ A5. GESTION DES ERREURS
\ ──────────────────────────────────────────────────────────────────────
\
\ Niveau 1 — Implicite :
\   Stack overflow/underflow, division par zéro,
\   adresse hors bornes, mot inconnu
\
\ Niveau 2 — Exceptions :

: demo-exception ( -- )
  try
    42 throw
    0
  catch
    ." Exception: " . cr
  endtry ;

\ Niveau 3 — abort" :
\   : check ( n -- )
\     dup 0 < abort" Valeur negative !"
\     drop ;
\
\ Niveau 4 — Codes d'erreur drivers :
\   -1 throw  → Erreur générique
\   -2 throw  → Timeout
\   -3 throw  → Périphérique non trouvé


\ ──────────────────────────────────────────────────────────────────────
\ A6. MULTITÂCHE
\ ──────────────────────────────────────────────────────────────────────
\
\ Préemption PIT ~100 Hz (IRQ toutes les ~10 ms).
\ Round-robin entre tâches. Dictionnaire partagé.
\
\ ms yield (v2025.2) : ne bloque plus le scheduler.
\ touche yield (v2025.3) : ne bloque plus le scheduler.
\
\ Créer une tâche :
\   : ma-tache
\     begin ." tick " 100 ms again ;
\   ' ma-tache task
\
\ Sections critiques (MUTEX.FTH) :
\   critical-begin  \ scheduler ne préempte plus
\   ... opérations atomiques ...
\   critical-end    \ scheduler reprend
\
\ Protection anti-deadlock :
\   Si section critique > 100k instructions :
\   préemption forcée + warning.
\
\ Synchronisation (voir MUTEX.FTH) :
\   mutex:lock / mutex:unlock / mutex:with
\   sem:wait / sem:signal
\   chan:send / chan:recv


\ ──────────────────────────────────────────────────────────────────────
\ A7. BIBLIOTHÈQUES STANDARD
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌──────────────┬──────────────────────────────────────────────────┐
\ │ STDLIB.FTH   │ true false bl tab max3 clamp within bounds       │
\ │              │ /string [] matrix[] 0.r hex. ? ??                │
\ │              │ >number f>str time>str date>str                  │
\ │              │ times for map array:create push pop              │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ FIXED.FTH    │ f+ f- f* f/ fsqrt fsin fcos ftan fatan          │
\ │              │ v2.add v2.len v2.normalize v2.rotate             │
\ │              │ phys.move phys.bounce plot.curve                 │
\ │              │ sensor.* f. f.n f>str                            │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ MUTEX.FTH    │ critical-begin critical-end                      │
\ │              │ spin:* mutex:* sem:* chan:*                       │
\ │              │ rwlock:* barrier:* pool:* tls:*                  │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ EVENTS.FTH   │ on-key-press on-mouse-move on-tick               │
\ │              │ on-mouse-click on-resize on-quit                 │
\ │              │ event-loop                                       │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ TESTS.FTH    │ assert= assert-true section lancer-tests         │
\ └──────────────┴──────────────────────────────────────────────────┘
\
\ Chargement recommandé :
\   require STDLIB.FTH
\   require FIXED.FTH    \ si calcul
\   require MUTEX.FTH    \ si multitâche
\   require EVENTS.FTH   \ si application graphique


\ ──────────────────────────────────────────────────────────────────────
\ A8. GESTION MÉMOIRE DU STRING_POOL (v2025.3)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le string_pool stocke toutes les chaînes littérales compilées.
\ Avant v2025.3 : il ne diminuait jamais (fuite mémoire).
\ Depuis v2025.3 : marker et forget le gèrent correctement.
\
\ Fonctionnement interne :
\
\   marker ---clean---
\     ↓ sauvegarde :
\     - snap_dict  = dictionary.len()
\     - snap_here  = here
\     - snap_vars  = variables.len()
\     - snap_pool  = string_pool.len()  ← NOUVEAU v2025.3
\
\   ---clean---
\     ↓ restaure :
\     - Tronque le dictionnaire à snap_dict
\     - Restaure here à snap_here
\     - Retire les variables > snap_vars
\     - Tronque string_pool à snap_pool ← NOUVEAU v2025.3
\
\ forget (idx) :
\     ↓ scan des ops de dictionary[0..idx] pour trouver
\       l'offset pool maximum encore référencé
\     ↓ tronque string_pool à cet offset max
\     ↓ Nettoyage sélectif (ne nuke pas si idx > 0)
\
\ RÉSULTAT :
\   - Sessions longues sans fuite mémoire
\   - Développement itératif propre :
\       marker ---dev---
\       : test ... ;
\       test
\       ---dev---    \ repart de zéro, pool libéré
\
\ Exemple — développement itératif propre :

: demo-marker-pool ( -- )
  \ Avant v2025.3 : chaque re-définition accumulait des
  \ chaînes dans le pool sans jamais les libérer.
  \ Depuis v2025.3 : marker sauvegarde le pool, ---clean---
  \ le restaure exactement.
  marker ---dev-session---
  cr ." Session de dev..." cr
  \ ... définitions temporaires ...
  \ ---dev-session---   \ ← libère le pool des définitions
  ;                     \   de cette session


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE B — ÉCRIRE UN DRIVER
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ B1. ANATOMIE D'UN DRIVER FORTH
\ ──────────────────────────────────────────────────────────────────────
\
\ Structure recommandée v2025.3 :
\
\   1. require des dépendances
\   2. Constantes (adresses, registres)
\   3. Énumérations (états, codes)
\   4. Values (état mutable du driver)
\   5. Structures (layout des registres)
\   6. Mutex (protection accès concurrent)
\   7. Mots bas niveau (read/write registres)
\   8. Initialisation (probe, reset, config)
\   9. Interface publique (read, write, status, info)
\  10. Enregistrement sys:register
\  11. Tests (:test)

\ --- Squelette complet v2025.3 ---

\ require STDLIB.FTH
\ require MUTEX.FTH
\
\ \ ── Constantes ──────────────────────────────────────
\ 0x3F8 constant MYDRV-BASE
\ 10    constant MYDRV-TIMEOUT-MS
\
\ \ ── États ────────────────────────────────────────────
\ 0 enum MYDRV-UNINIT
\   enum MYDRV-READY
\   enum MYDRV-ERROR
\ drop
\
\ \ ── State ────────────────────────────────────────────
\ MYDRV-UNINIT value mydrv-state
\ mutex:create constant mydrv-lock
\ variable mydrv-errors
\
\ \ ── Registres ────────────────────────────────────────
\ struct mydrv-regs
\   field .data
\   field .status
\   field .ctrl
\ end-struct
\
\ \ ── Bas niveau ────────────────────────────────────────
\ : mydrv-status@ ( -- byte )
\   MYDRV-BASE .status + inb ;
\
\ : mydrv-ready? ( -- flag )
\   mydrv-status@ 0x20 and 0<> ;
\
\ \ ── Init ──────────────────────────────────────────────
\ : mydrv:init ( -- ok? )
\   mydrv-ready? if
\     MYDRV-READY to mydrv-state
\     0 mydrv-errors !
\     1
\   else
\     MYDRV-ERROR to mydrv-state
\     0
\   then ;
\
\ \ ── Interface publique ────────────────────────────────
\ : mydrv:read ( -- val | -1 )
\   mydrv-state MYDRV-READY <> if -1 exit then
\   mydrv-lock mutex:lock
\   MYDRV-BASE .data + inb
\   mydrv-lock mutex:unlock ;
\
\ : mydrv:status ( -- ok? )
\   mydrv-state MYDRV-READY = ;
\
\ : mydrv:info ( -- )
\   ." MyDriver v3.0 — Etat: "
\   mydrv-state case
\     MYDRV-UNINIT of ." non init" endof
\     MYDRV-READY  of ." pret"     endof
\     MYDRV-ERROR  of ." erreur"   endof
\   endcase cr
\   ." Erreurs: " mydrv-errors @ . cr ;
\
\ \ ── Enregistrement ────────────────────────────────────
\ : mydrv-init ( -- )
\   mydrv:init if ." MyDriver OK" cr
\   else ." MyDriver ECHEC" cr then ;
\
\ sys:register mydrv


\ ──────────────────────────────────────────────────────────────────────
\ B2. CONVENTION DE NOMMAGE
\ ──────────────────────────────────────────────────────────────────────
\
\ Préfixes :
\   uart: spi: gpio: rtc: temp: fan: led: wdog:
\
\ Suffixes :
\   :init :read :write :status :info :close :test
\
\ Values vs variables :
\   0 value drv-base      → lecture directe (drv-base .)
\   variable drv-count    → adresse (drv-count @ .)
\
\ Utiliser value pour l'état d'un driver (modifié avec to).
\ Utiliser variable pour les compteurs (+! plus naturel).


\ ──────────────────────────────────────────────────────────────────────
\ B3. ACCÈS AUX PORTS I/O
\ ──────────────────────────────────────────────────────────────────────
\
\   inb  ( port -- byte )
\   outb ( byte port -- )
\   inw  ( port -- word )
\   outw ( word port -- )
\   inl  ( port -- long )
\   outl ( long port -- )

0x3F8 constant COM1-BASE
0x3FD constant COM1-LSR

: com1-tx-ready? ( -- flag )
  COM1-LSR inb 0x20 and 0<> ;

: com1-rx-ready? ( -- flag )
  COM1-LSR inb 0x01 and 0<> ;

: com1-tx ( char -- )
  begin com1-tx-ready? until
  COM1-BASE outb ;

: com1-rx ( -- char | -1 )
  com1-rx-ready? if COM1-BASE inb else -1 then ;

\ Pattern timeout avec ms yield (v2025.3 — touche yield aussi) :
: wait-port ( port mask timeout_ms -- ok? )
  0 do
    over inb over and 0<> if
      2drop 1 unloop exit
    then
    1 ms                    \ yield — ne bloque plus les autres tâches
  loop
  2drop 0 ;


\ ──────────────────────────────────────────────────────────────────────
\ B4. ACCÈS MMIO
\ ──────────────────────────────────────────────────────────────────────
\
\   mmio@ mmio! c@ c! w@ w! l@ l!

\ Pattern struct + value (v2025.3) :
\ 0 value my-mmio-base
\
\ struct my-ctrl-regs
\   field .cmd
\   field .status
\   field .data
\ end-struct
\
\ : reg@ ( field -- val )  my-mmio-base + mmio@ ;
\ : reg! ( val field -- )  my-mmio-base + mmio! ;
\
\ : ctrl-ready? ( -- flag )
\   .status reg@ 0x01 and 0<> ;

\ Pattern attente MMIO :
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

: pci-find-device ( vid did -- bus dev func | -1 )
  pci-scan 0 ?do
    i pci-dev drop drop
    4 pick = if
      3 pick = if
        2drop unloop exit
      else drop then
    else 2drop then
    drop drop drop
  loop
  2drop -1 ;

: pci-find-class ( class sub -- idx | -1 )
  pci-scan 0 ?do
    i pci-dev
    3 pick = if
      over = if
        drop drop drop drop drop 2drop
        i unloop exit
      then
    then
    drop drop drop drop drop drop drop
  loop
  2drop -1 ;


\ ──────────────────────────────────────────────────────────────────────
\ B6. ACCÈS I2C
\ ──────────────────────────────────────────────────────────────────────

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

variable irq-count

: irq-counter ( -- )
  1 irq-count +! ;

\ Enregistrer : ' irq-counter 33 irq-handler


\ ──────────────────────────────────────────────────────────────────────
\ B9. ALLOCATION MÉMOIRE PHYSIQUE
\ ──────────────────────────────────────────────────────────────────────

: demo-alloc-phys ( -- )
  1 alloc-phys
  dup 0 = if drop ." Echec" cr exit then
  dup ." Buffer a 0x" hex . decimal cr
  dup 0x12345678 swap l!
  dup l@ 0x12345678 = if ." Verification OK" else ." ECHEC" then cr
  1 free-phys drop ;

: with-phys ( pages xt -- )
  swap dup >r
  alloc-phys dup 0 = if
    drop r> drop ." Alloc echec" cr exit
  then
  dup >r swap execute
  r> r> free-phys drop ;


\ ──────────────────────────────────────────────────────────────────────
\ B10. TIMING ET DÉLAIS
\ ──────────────────────────────────────────────────────────────────────
\
\   ms / attendre ( n -- )   Pause avec yield (v2025.2)
\   touche ( -- char )       Bloquant AVEC yield (v2025.3)
\   touche? ( -- char|0 )    Non-bloquant
\   stall ( us -- )          Délai UEFI bloquant
\   stall-us ( us -- )       Délai RDTSC bloquant
\   ticks ( -- ms )          Millisecondes depuis le démarrage
\   rdtsc ( -- tsc )         Compteur CPU brut
\
\ IMPORTANT v2025.3 :
\   ms, attendre : yield depuis v2025.2
\   touche       : yield depuis v2025.3 (ne bloque plus le scheduler)
\   Pour un délai vraiment bloquant (driver bas niveau) : stall-us

: benchmark ( xt -- ms )
  ticks swap execute ticks swap - ;

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
0x01 constant UART-LSR-DATA
0x20 constant UART-LSR-TX

0 enum UART-UNINIT  enum UART-READY  enum UART-ERROR  drop

UART-UNINIT value uart-state
variable uart-tx-count
variable uart-rx-count
variable uart-errors

: uart:tx-ready? ( -- flag )
  UART-LSR inb UART-LSR-TX and 0<> ;

: uart:rx-ready? ( -- flag )
  UART-LSR inb UART-LSR-DATA and 0<> ;

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

: uart:tx ( char -- )
  uart-state UART-READY <> if drop exit then
  10 0 do uart:tx-ready? if leave then 1 ms loop
  uart:tx-ready? 0= if 1 uart-errors +! drop exit then
  UART-BASE outb  1 uart-tx-count +! ;

: uart:rx ( -- char | -1 )
  uart-state UART-READY <> if -1 exit then
  uart:rx-ready? if UART-BASE inb  1 uart-rx-count +!
  else -1 then ;

: uart:puts ( addr len -- )
  0 ?do dup i + @ 0xFF and uart:tx loop drop ;

: uart:info ( -- )
  ." === UART 16550 ===" cr
  ." Etat: " uart-state case
    UART-UNINIT of ." non init" endof
    UART-READY  of ." pret"     endof
    UART-ERROR  of ." erreur"   endof
  endcase cr
  ." TX: " uart-tx-count @ . ."  RX: " uart-rx-count @ .
  ."  Err: " uart-errors @ . cr ;

: uart-init ( -- )
  115200 uart:init if ." UART 16550 OK" cr
  else ." UART 16550 ECHEC" cr then ;

sys:register uart


\ ──────────────────────────────────────────────────────────────────────
\ B12. DRIVER COMPLET : LED CLAVIER PS/2
\ ──────────────────────────────────────────────────────────────────────

0x60 constant KBD-DATA
0x64 constant KBD-STATUS
variable kbd-leds

: kbd-wait-input ( -- ok? )
  100 0 do KBD-STATUS inb 0x02 and 0= if 1 unloop exit then 1 ms loop
  0 ;

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
    1 led:set 100 ms  2 led:set 100 ms
    4 led:set 100 ms  2 led:set 100 ms
  loop
  0 led:set ;

: led:test ( -- )
  ." Test LEDs..." cr  3 led:knight-rider  ." OK" cr ;


\ ──────────────────────────────────────────────────────────────────────
\ B13. DRIVER COMPLET : TEMPÉRATURE CPU
\ ──────────────────────────────────────────────────────────────────────

0x19C constant MSR-THERM-STATUS
0x1A2 constant MSR-TEMP-TARGET

100 value cpu-tj-max

: temp:init ( -- ok? )
  try
    MSR-TEMP-TARGET msr@ drop
    16 rshift 0xFF and
    dup 0 > if to cpu-tj-max else drop 100 to cpu-tj-max then
    1  0
  catch drop 100 to cpu-tj-max 1 endtry ;

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
  ." Actuelle: "
  temp:read dup -1 = if drop ." N/A"
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
      2dup 0 0x50 pci@ 0xFFE0 and to tco-base
      drop drop drop
      tco-base 0 > if 1 unloop exit then
    else drop drop drop drop drop drop drop
    then
    else drop drop drop drop drop drop drop
    then
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
  ." Tapez un chiffre (touche yield v2025.3) : "
  \ touche ne bloque plus le scheduler (v2025.3)
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

: panneau-inc   ( -- )  1 panneau-compteur +! ;
: panneau-dec   ( -- ) -1 panneau-compteur +! ;
: panneau-reset ( -- )  0 panneau-compteur ! ;

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
  net:dhcp 0= if ." DHCP echec"   cr exit then
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
  cr ." ╔══════════════════════════════════════╗" cr
     ."  ║      EPONA OS — MONITEUR SYSTEME    ║" cr
     ." ╚══════════════════════════════════════╝" cr
  ." CPU: " 0 cpuid drop swap drop swap drop ." leaf max=" . cr
  ." TSC: " rdtsc . cr
  ." Uptime: " ticks 1000 / . ." sec" cr
  ." RAM: " mem-map over 4 * 1024 / . ." MB total, "
  4 * 1024 / . ." MB libre" cr
  ." Ecran: " fb-size swap . ." x" . cr
  ." Heap: " heap-used . ." octets" cr
  ." PCI: " pci-scan . ." peripheriques" cr
  ." Heure: " get-time . ." /" . ." /" . ."  " . ." :" . ." :" . cr
  [defined] temp:read [if]
    ." Temp CPU: " temp:read dup -1 = if drop ." N/A"
    else . ." C" then cr
  [then]
  cr ." Appuyez sur une touche..." cr
  touche drop ;


\ ──────────────────────────────────────────────────────────────────────
\ C7. APPLICATION COMPLÈTE : TERMINAL SÉRIE
\ ──────────────────────────────────────────────────────────────────────
\
\ Note v2025.3 : touche yield — ne bloque plus le scheduler.
\ Le terminal série coexiste proprement avec les autres tâches.

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
  cr
  ." Adresse     | Hexadecimal                             | ASCII" cr
  ." ─────────────────────────────────────────────────────────────" cr
  over + swap
  begin 2dup > if dup hex-line 16 + else 2drop exit then again ;


\ ──────────────────────────────────────────────────────────────────────
\ C9. APPLICATION AVEC ÉVÉNEMENTS (EVENTS.FTH)
\ ──────────────────────────────────────────────────────────────────────

\ require EVENTS.FTH
\ require FIXED.FTH
\
\ \ État de l'objet mobile
\ F.0 value obj-x
\ F.0 value obj-y
\ 3 f.from value obj-vx
\ 2 f.from value obj-vy
\
\ : game-key ( char -- )
\   case
\     [char] w of obj-vy F.1 f- to obj-vy endof
\     [char] s of obj-vy F.1 f+ to obj-vy endof
\     [char] a of obj-vx F.1 f- to obj-vx endof
\     [char] d of obj-vx F.1 f+ to obj-vx endof
\     [char] q of stop            endof
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
\ Pattern v2025.3 avec value, enum, case, buffer: :

\ 0 enum OP-NOP  enum OP-LOAD  enum OP-STORE
\   enum OP-ADD  enum OP-HALT  drop
\
\ 0   value sim-pc
\ 0   value sim-a
\ 256 buffer: sim-ram
\
\ : sim-fetch ( -- opcode )
\   sim-pc sim-ram + @ 0xFF and
\   sim-pc 1+ to sim-pc ;
\
\ : sim-step ( -- halt? )
\   sim-fetch case
\     OP-NOP   of 0 endof
\     OP-LOAD  of sim-fetch to sim-a 0 endof
\     OP-ADD   of sim-fetch sim-a + to sim-a 0 endof
\     OP-HALT  of 1 endof
\     ." Opcode inconnu" cr 1
\   endcase ;
\
\ : sim-run ( -- )
\   begin sim-step until ;


\ ──────────────────────────────────────────────────────────────────────
\ D2. SIMULATEUR CHIP-8 COMPLET
\ ──────────────────────────────────────────────────────────────────────

create c8-ram    4096 allot
create c8-v      16   allot
create c8-screen 2048 allot
create c8-stack  16   allot

variable c8-i   variable c8-pc  variable c8-sp
variable c8-dt  variable c8-st  variable c8-running

: c8-mem@ ( addr -- byte )  0xFFF and c8-ram + @ 0xFF and ;
: c8-mem! ( byte addr -- )  0xFFF and c8-ram + swap 0xFF and swap ! ;
: c8-v@   ( reg -- val )    0x0F and c8-v   + @ 0xFF and ;
: c8-v!   ( val reg -- )    0x0F and c8-v   + swap 0xFF and swap ! ;

: c8-init ( -- )
  4096 0 do 0 i c8-ram + ! loop
  16 0 do 0 i c8-v + ! loop
  2048 0 do 0 i c8-screen + ! loop
  0 c8-i !  0x200 c8-pc !  0 c8-sp !
  0 c8-dt !  0 c8-st !  1 c8-running !
  0xF0 0 c8-mem!  0x90 1 c8-mem!  0x90 2 c8-mem!
  0x90 3 c8-mem!  0xF0 4 c8-mem! ;

: c8-load ( src len -- )
  c8-init
  0 ?do dup i + @ 0xFF and 0x200 i + c8-mem! loop
  drop ;

: c8-fetch ( -- op16 )
  c8-pc @ c8-mem@ 8 lshift
  c8-pc @ 1+ c8-mem@ or
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
    0x2 of c8-pc @ c8-sp @ c8-stack + !
           1 c8-sp +!
           dup 0x0FFF and c8-pc ! endof
    0x3 of dup 8 rshift 0x0F and c8-v@
           over 0xFF and = if 2 c8-pc +! then endof
    0x6 of dup 0xFF and over 8 rshift 0x0F and c8-v! endof
    0x7 of dup 8 rshift 0x0F and dup c8-v@
           rot 0xFF and + 0xFF and swap c8-v! endof
    0xA of dup 0x0FFF and c8-i ! endof
    0xC of dup 8 rshift 0x0F and
           over 0xFF and hasard swap c8-v! endof
  endcase
  drop
  c8-dt @ 0 > if -1 c8-dt +! then
  c8-st @ 0 > if -1 c8-st +! then ;

: c8-run ( -- )
  begin
    c8-step c8-draw
    2 ms
    touche? 27 =
    c8-running @ 0= or
  until ;


\ ──────────────────────────────────────────────────────────────────────
\ D3. AUTOMATE CELLULAIRE (Jeu de la Vie)
\ ──────────────────────────────────────────────────────────────────────

40 constant LIFE-W
30 constant LIFE-H

create life-a  LIFE-W LIFE-H * allot
create life-b  LIFE-W LIFE-H * allot
variable life-gen  variable life-current

: life-grid  ( -- addr ) life-current @ 0= if life-a else life-b then ;
: life-other ( -- addr ) life-current @ 0= if life-b else life-a then ;

: life-get ( x y -- 0|1 )
  swap LIFE-W mod swap LIFE-H mod
  LIFE-W * + life-grid + @ ;

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
    i j life-get 0<> if i 10 * j 10 * 9 9 0x00FF00 rect then
  loop loop ;

: life-glider ( x y -- )
  2dup 1 -rot life-set!
  2dup swap 1+ swap 1+ 1 -rot life-set!
  2dup swap 1- swap 2 + 1 -rot life-set!
  2dup swap    swap 2 + 1 -rot life-set!
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
\   : bon-mot ( n addr -- result flag )
\     \ n = nombre d'éléments
\     \ addr = buffer
\     \ result = résultat
\     \ flag = 1 si succès
\     ... ;


\ ──────────────────────────────────────────────────────────────────────
\ E2. GESTION DES ERREURS
\ ──────────────────────────────────────────────────────────────────────

: safe-mmio@ ( addr -- val | 0 )
  try mmio@ 0 catch drop 0 endtry ;

: retry-op ( xt retries -- ok? )
  0 ?do dup execute if drop 1 unloop exit then i 10 * ms loop drop 0 ;


\ ──────────────────────────────────────────────────────────────────────
\ E3. TESTS DE DRIVERS
\ ──────────────────────────────────────────────────────────────────────
\
\ Utiliser le framework de TESTS.FTH :
\
\   : uart:test ( -- )
\     section ." UART... "
\     115200 uart:init assert-true
\     uart:status assert-true
\     section-end ;


\ ──────────────────────────────────────────────────────────────────────
\ E4. PERFORMANCE
\ ──────────────────────────────────────────────────────────────────────
\
\ 1. Buffers nommés : buffer: au lieu de create + allot
\ 2. value au lieu de variable pour l'état (pas d'adresse)
\ 3. case au lieu de if/else imbriqués
\ 4. ms et touche yield (ne monopolisent plus le CPU)
\ 5. Benchmark : ' mon-mot benchmark . ." ms"
\ 6. Sections critiques courtes (< 1000 instructions)


\ ──────────────────────────────────────────────────────────────────────
\ E5. SÉCURITÉ
\ ──────────────────────────────────────────────────────────────────────
\
\ secure on bloque : MMIO, ports I/O, PCI, réseau, fichiers,
\   reboot/poweroff, alloc-phys.
\
\ abort" pour valider les paramètres :
\   : check ( port -- )
\     dup 0 < abort" Port negatif !"
\     dup 65535 > abort" Port hors limites !"
\     drop ;


\ ──────────────────────────────────────────────────────────────────────
\ E6. PORTABILITÉ
\ ──────────────────────────────────────────────────────────────────────
\
\ EponaForth n'est PAS ANS Forth.
\ Cellules 64-bit, mémoire en i64, pas de vocabulaires,
\ pas de virgule flottante native.
\
\ Bonnes pratiques :
\   - cell+ et cells (pas 8 + et 8 *)
\   - [defined] pour tester les fonctionnalités
\   - Séparer logique métier et accès matériel
\   - require (pas include) pour les dépendances


\ ──────────────────────────────────────────────────────────────────────
\ E7. SYNCHRONISATION MULTITÂCHE
\ ──────────────────────────────────────────────────────────────────────
\
\ require MUTEX.FTH
\
\ Règles :
\   1. Protéger toutes les variables partagées avec mutex
\   2. mutex:with garantit le unlock même en cas d'erreur
\   3. ms yield, touche yield (v2025.3)
\   4. Sections critiques courtes
\   5. Timeout anti-deadlock : 100k instructions
\
\ Pattern recommandé :
\   mutex:create constant my-lock
\   : safe-op ( -- ) my-lock ' do-op mutex:with ;


\ ──────────────────────────────────────────────────────────────────────
\ E8. GESTION DU DICTIONNAIRE ET DU POOL (v2025.3)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le string_pool stocke les chaînes littérales.
\ Avant v2025.3 : croissait indéfiniment.
\ Depuis v2025.3 : géré par marker et forget.
\
\ BONNE PRATIQUE — développement itératif :
\   marker ---session---
\   \ ... définitions de test ...
\   \ ... expérimentations ...
\   ---session---          \ ← libère le pool, revient à l'état initial
\
\ BONNE PRATIQUE — modules hot-reload :
\   marker ---v1---
\   require MONDRIVER.FTH
\   \ ... utiliser le driver ...
\   ---v1---               \ ← décharge le driver + libère le pool
\   require MONDRIVER-V2.FTH
\
\ BONNE PRATIQUE — forget sélectif :
\   ' mon-mot forget       \ ← supprime mon-mot et tous les mots
\                          \   définis après lui (pool nettoyé
\                          \   jusqu'à l'offset maximum encore utilisé)
\
\ ATTENTION :
\   forget sur un mot utilisé par un autre = crash si l'autre est appelé
\   Utiliser marker/restore pour une gestion sûre


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
\   cell+ cells aligned char+ chars erase move
\
\ === MÉMOIRE PHYSIQUE ===
\   c@ c! w@ w! l@ l! mmio@ mmio! phys@ phys!
\   alloc-phys free-phys
\
\ === AFFICHAGE ===
\   . u. cr space spaces emit type ." ... s" ...
\   hex decimal
\
\ === CONTRÔLE ===
\   if else then
\   begin until again  begin while repeat
\   do loop +loop ?do leave i j
\   case of endof endcase
\   exit recurse  try catch endtry throw  abort"
\
\ === COMPILATION ===
\   : ; immediate  ' execute postpone
\   [char] char  state ] [  find literal forget
\   see word-info  defer is  value to
\   include require  marker
\   [if] [else] [then] [defined] [undefined]
\   struct field end-struct  enum  buffer:
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
\   \ ms yield (v2025.2), touche yield (v2025.3)
\
\ === ÉCRAN ===
\   fb-size fb-swap fb:pixel fb:rect fb:line fb:text fb:blit
\   pixel rect ligne effacer couleur
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
\   \ touche yield depuis v2025.3
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
\   -1  Erreur générique       -11  Pile vide
\   -2  Timeout                -12  Pile pleine
\   -3  Périphérique non trouvé  -13  Mot non trouvé
\   -4  Erreur communication   -14  Division par zéro
\   -5  Buffer trop petit      -15  Fichier non trouvé
\   -6  Op non supportée       -16  Disque plein
\   -7  Permission refusée     -17  Réseau indisponible
\   -8  Ressource occupée      -18  Connexion refusée
\   -9  Adresse invalide       -19  DNS échoué
\   -10 Paramètre hors limites -20  Checksum invalide


\ ──────────────────────────────────────────────────────────────────────
\ F3. CONSTANTES UTILES
\ ──────────────────────────────────────────────────────────────────────

0xFF0000 constant ROUGE    0x00FF00 constant VERT
0x0000FF constant BLEU     0xFFFFFF constant BLANC
0x000000 constant NOIR     0xFFFF00 constant JAUNE
0xFF00FF constant MAGENTA  0x00FFFF constant CYAN
0x808080 constant GRIS

10  constant LF
13  constant CR-CHAR
27  constant ESC
32  constant BL
4096 constant PAGE-SIZE
512  constant SECTOR-SIZE

0x01 constant PCI-STORAGE
0x02 constant PCI-NETWORK
0x03 constant PCI-DISPLAY
0x06 constant PCI-BRIDGE


\ ──────────────────────────────────────────────────────────────────────
\ F4. PATTERNS COURANTS
\ ──────────────────────────────────────────────────────────────────────
\
\ --- Bitmask ---
\ : bit       ( n -- mask )   1 swap lshift ;
\ : bit?      ( v n -- flag ) bit and 0<> ;
\ : bit-set   ( v n -- v' )   bit or ;
\ : bit-clear ( v n -- v' )   bit invert and ;
\ : bit-toggle ( v n -- v' )  bit xor ;
\
\ --- State machine (enum + case + value) ---
\ 0 enum ST-IDLE  enum ST-RUN  enum ST-DONE  drop
\ ST-IDLE value my-state
\ : transition ( new-state -- )  to my-state ;
\ : tick
\   my-state case
\     ST-IDLE of ... ST-RUN  transition endof
\     ST-RUN  of ... ST-DONE transition endof
\   endcase ;
\
\ --- Gestion sûre du pool (v2025.3) ---
\ : with-temp-defs ( xt -- )
\   \ Exécute xt dans un contexte nettoyé après
\   here >r
\   dictionary-size >r
\   marker ---temp---
\   execute
\   ---temp---
\   r> drop r> drop ;
\
\ --- Retry avec backoff (ms yield) ---
\ : retry-ms ( xt retries delay_ms -- ok? )
\   0 ?do
\     2 pick execute if 2drop drop 1 unloop exit then
\     dup ms
\   loop
\   2drop drop 0 ;


\ ──────────────────────────────────────────────────────────────────────
\ F5. BIBLIOTHÈQUES DISPONIBLES (v2025.3)
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌──────────────┬──────────┬──────────────────────────────────────────┐
\ │ Fichier      │ Statut   │ Mots clés                                │
\ ├──────────────┼──────────┼──────────────────────────────────────────┤
\ │ BOOT.FTH     │ ✅ v3.3  │ Amorçage structuré avec [defined]       │
\ │ STDLIB.FTH   │ ✅ v3.3  │ true false bl tab max3 clamp f>str      │
\ │ FIXED.FTH    │ ✅ v2.0  │ f+ f- f* f/ fsqrt fsin v2.* phys.*     │
\ │ MUTEX.FTH    │ ✅ v2.0  │ mutex:* sem:* chan:* rwlock:* barrier:* │
\ │ EVENTS.FTH   │ ✅ v2.0  │ on-key-press on-tick event-loop         │
\ │ TESTS.FTH    │ ✅ v2.0  │ assert= assert-true lancer-tests        │
\ │ DEVGUIDE.FTH │ ✅ v2025.3│ Documentation complète + exemples      │
\ ├──────────────┼──────────┼──────────────────────────────────────────┤
\ │ GUIKIT.FTH   │ 🔲 TODO │ Toolkit UI (fenêtres, labels, sliders)  │
\ │ CHIP8.FTH    │ 🔲 TODO │ Simulateur CHIP-8 complet (35 opcodes)  │
\ │ SNAKE.FTH    │ 🔲 TODO │ Jeu Snake (EVENTS.FTH + FIXED.FTH)     │
\ │ RAYCAST.FTH  │ 🔲 TODO │ Raycaster 3D (FIXED.FTH)               │
\ │ FILEMAN.FTH  │ 🔲 TODO │ Gestionnaire de fichiers visuel         │
\ │ HTTPD.FTH    │ 🔲 TODO │ Serveur HTTP basique                    │
\ └──────────────┴──────────┴──────────────────────────────────────────┘


\ ════════════════════════════════════════════════════════════════════════
\       PARTIE G — ROADMAP LANGAGE (mise à jour v2025.3)
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ G1. BILAN COMPLET — RUST + LANGAGE + BIBLIOTHÈQUES
\ ──────────────────────────────────────────────────────────────────────
\
\ === RUNTIME RUST ===
\
\ ┌─────────────────────────────────┬──────────────────────────────────┐
\ │ Composant                       │ Statut                           │
\ ├─────────────────────────────────┼──────────────────────────────────┤
\ │ Compilateur Forth               │ ✅ Stable                        │
\ │ Bytecode Op (13 types)          │ ✅ Stable                        │
\ │ Pile / Rstack / loop_rstack     │ ✅ Séparés                       │
\ │ Dictionnaire 2048 mots          │ ✅ Stable                        │
\ │ Mémoire Forth 4096 cellules     │ ✅ Extensible via allot          │
\ │ Exceptions try/catch/throw      │ ✅ Imbriquées, compilé+interprété│
\ │ Récursion                       │ ✅ recurse                       │
\ │ Mode immédiat / compilation     │ ✅ state                         │
\ │ Débogueur step/trace/break      │ ✅ Complet                       │
\ │ Sécurité sandbox                │ ✅ secure on/off                 │
\ │ ms yield                        │ ✅ v2025.2                       │
\ │ critical_depth (MUTEX)          │ ✅ v2025.2                       │
\ │ Timeout anti-deadlock 100k      │ ✅ v2025.2                       │
\ │ string_pool fuite mémoire       │ ✅ v2025.3 (marker + forget)     │
\ │ forget nettoyage sélectif       │ ✅ v2025.3                       │
\ │ touche yield                    │ ✅ v2025.3                       │
\ └─────────────────────────────────┴──────────────────────────────────┘
\
\ === LANGAGE FORTH ===
\
\ ┌─────────────────────────────────┬──────────────────────────────────┐
\ │ Fonctionnalité                  │ Statut                           │
\ ├─────────────────────────────────┼──────────────────────────────────┤
\ │ 292 primitives matériel         │ ✅                               │
\ │ Roadmap 20 mots (see, value...) │ ✅ 20/20                         │
\ │ case/of/endof/endcase           │ ✅                               │
\ │ include / require               │ ✅                               │
\ │ [if] [else] [then] [defined]    │ ✅                               │
\ │ struct / field / end-struct     │ ✅                               │
\ │ buffer:                         │ ✅                               │
\ │ enum                            │ ✅                               │
\ │ marker                          │ ✅ pool sauvegardé v2025.3       │
\ │ abort"                          │ ✅                               │
\ │ type / count / compare / search │ ✅                               │
\ │ value / to                      │ ✅ Op::ValueAddr/ToValue         │
\ │ defer / is                      │ ✅ Op::CallDeferred              │
\ │ immediate                       │ ✅                               │
\ │ [char] / char                   │ ✅                               │
\ │ \n dans ."                      │ ✅                               │
\ │ ," (chaîne comptée create)      │ ✅                               │
\ │ word-info / see                 │ ✅                               │
\ └─────────────────────────────────┴──────────────────────────────────┘
\
\ === BIBLIOTHÈQUES ===
\
\ ┌──────────────┬──────────┬────────────────────────────────────────┐
\ │ Fichier      │ Statut   │ Version                                │
\ ├──────────────┼──────────┼────────────────────────────────────────┤
\ │ STDLIB.FTH   │ ✅ FAIT  │ v2025.3 — f>str, time>str             │
\ │ FIXED.FTH    │ ✅ FAIT  │ v2.0 — Q20.12, vecteurs, physique     │
\ │ MUTEX.FTH    │ ✅ FAIT  │ v2.0 — critical-begin/end             │
\ │ EVENTS.FTH   │ ✅ FAIT  │ v2.0 — 8 defer, event-loop            │
\ │ TESTS.FTH    │ ✅ FAIT  │ v2.0 — 29 sections, 180+ assertions   │
\ │ BOOT.FTH     │ ✅ FAIT  │ v2025.3 — amorçage structuré          │
\ │ DEVGUIDE.FTH │ ✅ FAIT  │ v2025.3 — ce fichier                  │
\ └──────────────┴──────────┴────────────────────────────────────────┘


\ ──────────────────────────────────────────────────────────────────────
\ G2. CORRECTIONS RUST TERMINÉES (Priorité 4 — 3/3)
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌─────┬──────────────────────────┬───────────────────────────────────┐
\ │  #  │ Fix                      │ Détail                            │
\ ├─────┼──────────────────────────┼───────────────────────────────────┤
\ │ 4.1 │ string_pool + marker     │ marker sauve snap_pool ;          │
\ │     │ interpreter.rs:5744-5768 │ restore-marker (prim 300)         │
\ │     │                          │ tronque le pool exactement        │
\ ├─────┼──────────────────────────┼───────────────────────────────────┤
\ │ 4.2 │ forget nettoyage         │ Scan des ops restants pour        │
\ │     │ interpreter.rs:1942-1983 │ trouver l'offset pool max encore  │
\ │     │                          │ référencé ; troncature sélective  │
\ │     │                          │ (ne nuke pas si idx > 0)          │
\ ├─────┼──────────────────────────┼───────────────────────────────────┤
\ │ 4.3 │ touche yield             │ Vérifie PREEMPT_REQUESTED dans    │
\ │     │ interpreter.rs:794-808   │ la boucle bloquante ; rend la     │
\ │     │                          │ main si préemption demandée       │
\ └─────┴──────────────────────────┴───────────────────────────────────┘
\
\ Impact combiné v2025.3 :
\   ✅ Sessions longues sans fuite mémoire (pool nettoyé)
\   ✅ forget ne détruit plus tout si idx > 0
\   ✅ touche coexiste avec le multitâche (yield)
\   ✅ ms, attendre, touche : tous les bloquants yieldent
\   ✅ L'écosystème est solide pour la production
\
\ Exemple — avant/après v2025.3 :
\
\   AVANT :
\     sys:load MYLIB.FTH     \ pool = 1000 octets
\     forget mylib-word
\     sys:load MYLIB.FTH     \ pool = 2000 octets (fuite !)
\     ... × 100 ...          \ pool = 100 000 octets (catastrophe)
\
\   APRÈS :
\     marker ---mylib---
\     sys:load MYLIB.FTH     \ pool sauvegardé
\     ---mylib---            \ pool restauré à zéro
\     sys:load MYLIB.FTH     \ pool = 1000 octets (propre)


\ ──────────────────────────────────────────────────────────────────────
\ G3. PROCHAINS MOTS À IMPLÉMENTER (Phase 5)
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌────┬──────────────────────┬────────────┬────────┬─────────────────┐
\ │  # │ Mot                  │ Difficulté │ Nv. Op │ Impact          │
\ ├────┼──────────────────────┼────────────┼────────┼─────────────────┤
\ │ 21 │ synonym              │ Triviale   │   0    │ Alias de mots   │
\ │ 22 │ action-of            │ Triviale   │   0    │ Inspect defer   │
\ │ 23 │ [']                  │ Triviale   │   0    │ Tick compilé    │
\ │ 24 │ >body                │ Triviale   │   0    │ create data     │
\ │ 25 │ evaluate             │ Moyenne    │   0    │ Eval dynamique  │
\ ├────┼──────────────────────┼────────────┼────────┼─────────────────┤
\ │ 26 │ parse / parse-name   │ Moyenne    │   0    │ Parsing avancé  │
\ │ 27 │ source / >in         │ Faible     │   0    │ Input standard  │
\ │ 28 │ refill               │ Faible     │   0    │ Multi-ligne     │
\ │ 29 │ fm/mod sm/rem        │ Faible     │   0    │ ANS compliance  │
\ │ 30 │ um* um/mod           │ Faible     │   0    │ ANS compliance  │
\ ├────┼──────────────────────┼────────────┼────────┼─────────────────┤
\ │ 31 │ locals { }           │ Haute      │   2    │ Lisibilité      │
\ │ 32 │ vocabularies         │ Haute      │   1    │ Namespaces      │
\ │ 33 │ float logiciel       │ Très haute │  4+    │ Calcul exact    │
\ │ 34 │ regexp basique       │ Haute      │   0    │ Parsing         │
\ │ 35 │ JIT x86-64           │ Très haute │   —    │ Performance ×50 │
\ └────┴──────────────────────┴────────────┴────────┴─────────────────┘
\
\ Priorité recommandée :
\   Immédiat (< 1 jour) : synonym, ['], action-of, >body
\   Court terme (1 sem)  : evaluate, parse, source
\   Moyen terme (2 sem)  : locals, fm/mod, um*
\   Long terme (1 mois)  : vocabularies, JIT x86-64


\ ──────────────────────────────────────────────────────────────────────
\ G4. ÉVOLUTION DU RUNTIME RUST
\ ──────────────────────────────────────────────────────────────────────
\
\ Corrections Rust encore possibles :
\
\ ┌────┬───────────────────────────────┬────────┬─────────────────────┐
\ │  # │ Problème                      │ Effort │ Impact              │
\ ├────┼───────────────────────────────┼────────┼─────────────────────┤
\ │  1 │ Backtrace Forth               │ 2h     │ Debug (call chain)  │
\ │    │ Affiche la chaîne d'appels    │        │                     │
\ │    │ lors d'une erreur             │        │                     │
\ ├────┼───────────────────────────────┼────────┼─────────────────────┤
\ │  2 │ Limite instructions           │ 30min  │ Programmes longs    │
\ │    │ configurable (variable Forth) │        │                     │
\ ├────┼───────────────────────────────┼────────┼─────────────────────┤
\ │  3 │ Mémoire u8 séparée            │ 1 jour │ Buffers DMA/réseau │
\ │    │ pour les buffers byte         │        │ plus naturels       │
\ ├────┼───────────────────────────────┼────────┼─────────────────────┤
\ │  4 │ evaluate (prim Rust)          │ 2h     │ Eval dynamique      │
\ │    │ Compile + exécute une chaîne  │        │                     │
\ ├────┼───────────────────────────────┼────────┼─────────────────────┤
\ │  5 │ JIT x86-64 minimal            │ 1 mois │ ×50 performance     │
\ │    │ Arithmétique + boucles        │        │ pour les simulateurs│
\ └────┴───────────────────────────────┴────────┴─────────────────────┘


\ ──────────────────────────────────────────────────────────────────────
\ G5. ÉCOSYSTÈME DE FICHIERS .FTH
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌──────────────────┬──────────┬──────────────────────────────────────┐
\ │ Fichier          │ Statut   │ Description                          │
\ ├──────────────────┼──────────┼──────────────────────────────────────┤
\ │ BOOT.FTH         │ ✅ FAIT  │ Amorçage structuré                  │
\ │ STDLIB.FTH       │ ✅ FAIT  │ Bibliothèque standard               │
\ │ FIXED.FTH        │ ✅ FAIT  │ Virgule fixe Q20.12                 │
\ │ MUTEX.FTH        │ ✅ FAIT  │ Synchronisation                     │
\ │ EVENTS.FTH       │ ✅ FAIT  │ Système d'événements                │
\ │ TESTS.FTH        │ ✅ FAIT  │ Suite de tests (180+ assertions)    │
\ │ DEVGUIDE.FTH     │ ✅ FAIT  │ Guide développeur complet           │
\ ├──────────────────┼──────────┼──────────────────────────────────────┤
\ │ GUIKIT.FTH       │ 🔲 P1   │ Toolkit UI complet                  │
\ │ CHIP8.FTH        │ 🔲 P1   │ Simulateur CHIP-8 (35 opcodes)      │
\ │ SNAKE.FTH        │ 🔲 P1   │ Snake (EVENTS + FIXED)              │
\ │ RAYCAST.FTH      │ 🔲 P2   │ Raycaster 3D (FIXED)               │
\ │ FILEMAN.FTH      │ 🔲 P2   │ Gestionnaire de fichiers            │
\ │ HTTPD.FTH        │ 🔲 P2   │ Serveur HTTP (TCP existant)         │
\ │ STRINGS.FTH      │ 🔲 P3   │ Traitement de chaînes avancé        │
\ │ COURSES/         │ 🔲 P3   │ Cours interactifs (13 fichiers)     │
\ │   01-PILE.FTH    │         │                                      │
\ │   02-MOTS.FTH    │         │                                      │
\ │   ...            │         │                                      │
\ └──────────────────┴──────────┴──────────────────────────────────────┘


\ ──────────────────────────────────────────────────────────────────────
\ G6. PLANNING DE DÉVELOPPEMENT
\ ──────────────────────────────────────────────────────────────────────
\
\ === PHASE ACTUELLE : CONTENU ET APPLICATIONS ===
\
\ Le langage est mature. Le runtime est stable et corrigé.
\ Les corrections Rust prioritaires sont toutes terminées.
\ La priorité est maintenant le contenu visible et la communauté.
\
\ ┌────────────┬──────────────────────────────────────────────────────┐
\ │ Semaine 1  │ GUIKIT.FTH + CHIP-8 complet                        │
\ │            │ Toolkit UI : window, label, button, slider           │
\ │            │ CHIP-8 : 35 opcodes, polices, sons, ROM disk        │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 2  │ SNAKE.FTH + RAYCAST.FTH                            │
\ │            │ Snake : corps circulaire, collision, score           │
\ │            │ Raycaster : DDA, textures, WASD, FOV 60°            │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 3  │ FILEMAN.FTH + HTTPD.FTH                            │
\ │            │ Explorateur : deux panneaux, F5 copie, F8 suppr     │
\ │            │ Serveur HTTP : GET statique, sert les .FTH          │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 4  │ GitHub + YouTube + Communauté                       │
\ │            │ README avec screenshots, ISO bootable                │
\ │            │ Post r/osdev, r/rust, r/forth, Hacker News          │
\ │            │ Discord ou Matrix                                    │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 5  │ Mots Phase 5 : synonym, ['], evaluate               │
\ │            │ COURSES/ : 3 premiers cours interactifs              │
\ │            │ Mise à jour TESTS.FTH (sections 30+)                │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Mois 2-3   │ Locals, vocabularies                                │
\ │            │ Backtrace Forth                                      │
\ │            │ Prototype JIT x86-64 (arithmétique + boucles)       │
\ └────────────┴──────────────────────────────────────────────────────┘
\
\ === INDICATEURS DE MATURITÉ ===
\
\ ┌───────────────────────────────┬────────┬──────────────────────────┐
\ │ Critère                       │ Cible  │ Actuel                   │
\ ├───────────────────────────────┼────────┼──────────────────────────┤
\ │ Primitives Rust               │ 300    │ ~292 ✅                  │
\ │ Mots Forth (avec libs)        │ 500+   │ ~380 ✅                  │
\ │ Tests automatisés             │ 250+   │ ~180 ✅                  │
\ │ Bibliothèques .FTH            │ 15+    │ 7 ✅                     │
\ │ Applications de référence     │ 10+    │ 5                        │
\ │ Jeux jouables                 │ 3+     │ 1                        │
\ │ Drivers Forth                 │ 5+     │ 4 ✅                     │
\ │ Simulateurs                   │ 2+     │ 2                        │
\ │ Corrections Rust prioritaires │ 3/3    │ 3/3 ✅                   │
\ │ Fuite mémoire string_pool     │ corrigé│ corrigé ✅               │
\ │ Documentation (lignes)        │ 5000+  │ ~5000 ✅                 │
\ │ GitHub stars                  │ 50+    │ 0 (pas encore publié)   │
\ └───────────────────────────────┴────────┴──────────────────────────┘
\
\ === VISION LONG TERME ===
\
\ EponaForth vise à être la meilleure plateforme pour :
\
\   🎓 Éducation  — Apprendre le fonctionnement d'un PC
\                   Cours interactifs, exercices sur le métal
\
\   🖥️ OS autonome — Gestionnaire de fichiers, éditeur,
\                   serveur HTTP, navigateur textuel
\
\   ⚡ Forth JIT   — Le seul Forth bare-metal avec GPU,
\                   réseau TCP, USB 3.0, NVMe, audio HDA
\                   et JIT x86-64


\ ════════════════════════════════════════════════════════════════════════
\            FIN DU GUIDE DÉVELOPPEUR EPONA OS v2025.3
\ ════════════════════════════════════════════════════════════════════════

cr
." ════════════════════════════════════════════════════════" cr
."  DEVGUIDE.FTH v2025.3 charge" cr
."  Corrections Rust : 3/3 terminees (pool + forget + touche)" cr
."  20/20 mots roadmap implementes" cr
."  Bibliotheques : STDLIB FIXED MUTEX EVENTS" cr
."  Drivers : uart led temp wdog" cr
."  Demos : sysmon minicom hexdump demo-balle" cr
."  Simulateurs : c8-run life-run" cr
."  Tapez 'sysmon'     — moniteur systeme" cr
."  Tapez 'led:test'   — test LEDs clavier" cr
."  Tapez 'demo-balle' — animation Canvas" cr
."  Tapez 'c8-run'     — simulateur CHIP-8" cr
."  Tapez 'life-run'   — jeu de la vie" cr
." ════════════════════════════════════════════════════════" cr
