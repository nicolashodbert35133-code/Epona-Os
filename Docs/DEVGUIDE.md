```forth
\ ════════════════════════════════════════════════════════════════════════
\                  EPONA OS — GUIDE DÉVELOPPEUR
\          Écrire des drivers, programmes et utilitaires
\                    en EponaForth (version 2025.4)
\ ════════════════════════════════════════════════════════════════════════
\
\ Ce fichier est à la fois :
\   - une documentation lisible (commentaires)
\   - du code exécutable (exemples fonctionnels)
\
\ Chargement : sys:load DEVGUIDE.FTH
\
\ Changements v2025.4 (par rapport à v2025.3) :
\   - Locals { } implémentés (Op::LocalGet/Set/Alloc/Free)
\   - Phase 5 : 12 primitives ANS (evaluate, fm/mod, um*, etc.)
\   - Bureau Forth complet (fullscreen-mode, app:, THEME.FTH)
\   - 7 apps de bureau (Clock, Notepad, Files, Settings, Calc, etc.)
\   - fullscreen-mode / fullscreen-off / canvas-resize
\   - fb-text, rect-outline, fb-swap, fb-size
\   - ~310+ primitives, ~400+ mots Forth, 15 fichiers .FTH
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
\     A8. Gestion mémoire du string_pool
\     A9. Variables locales { } (v2025.4)
\
\   PARTIE B — ÉCRIRE UN DRIVER
\     B1. Anatomie d'un driver Forth (v2025.4 avec locals)
\     B2. Convention de nommage
\     B3. Accès aux ports I/O
\     B4. Accès MMIO
\     B5. Accès PCI
\     B6. Accès I2C
\     B7. Accès USB
\     B8. Interruptions
\     B9. Allocation mémoire physique
\     B10. Timing et délais
\     B11. Driver complet : UART 16550 (v2025.4 avec locals)
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
\     C10. Application de bureau (ForthApp) (v2025.4)
\     C11. Bureau complet en Forth (fullscreen-mode) (v2025.4)
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
\     E8. Gestion du dictionnaire et du pool
\     E9. Utilisation des locals (v2025.4)
\
\   PARTIE F — RÉFÉRENCE RAPIDE
\     F1. Toutes les primitives par catégorie
\     F2. Codes d'erreur
\     F3. Constantes utiles
\     F4. Patterns courants
\     F5. Bibliothèques et fichiers disponibles
\
\   PARTIE G — ROADMAP LANGAGE (mise à jour v2025.4)
\     G1. Bilan complet — tout ce qui est implémenté
\     G2. Historique des corrections Rust
\     G3. Prochains mots et améliorations
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
\   ┌─────────────────────────────────────────────────────┐
\   │  Mémoire Forth (memory[])                           │
\   │  Vec<i64>, 4096 cellules (extensible via allot)     │
\   │  [0..variables] [variables..here] [here..MAX_MEM]   │
\   └─────────────────────────────────────────────────────┘
\   ┌─────────────────────────────────────────────────────┐
\   │  String pool (string_pool[])                        │
\   │  Vec<u8> — chaînes littérales, géré par marker/forget│
\   └─────────────────────────────────────────────────────┘
\   ┌─────────────────────────────────────────────────────┐
\   │  Locals stack (locals[]) — v2025.4                  │
\   │  Vec<i64> — variables locales { }                    │
\   │  Séparé de rstack, frame pointers dans locals_frame │
\   └─────────────────────────────────────────────────────┘
\   ┌─────────────────────────────────────────────────────┐
\   │  Pile de données (stack[]) — max 4096               │
\   │  Pile de retour (rstack[]) — max 1024               │
\   │  Loop rstack (loop_rstack[]) — séparé pour DO/LOOP  │
\   └─────────────────────────────────────────────────────┘
\   ┌─────────────────────────────────────────────────────┐
\   │  Mémoire physique — alloc-phys / free-phys          │
\   │  Canvas Forth — 400×300 (ou redimensionné)          │
\   └─────────────────────────────────────────────────────┘
\
\ Adresses Forth vs physiques :
\   @ ! +!          → memory[] (indices, cellules i64)
\   c@ c! w@ w!     → adresses physiques réelles
\   mmio@ mmio!     → MMIO physique
\   phys@ phys!     → 64-bit physique


\ ──────────────────────────────────────────────────────────────────────
\ A2. PILE DE DONNÉES ET PILE DE RETOUR
\ ──────────────────────────────────────────────────────────────────────
\
\ Notation : ( avant -- après )
\
\ >r r> r@ : pile de retour utilisateur
\ i j : loop_rstack séparé (immunisé contre >r/r>)
\ Locals : locals[] séparé (immunisé contre >r/r> ET DO/LOOP)


\ ──────────────────────────────────────────────────────────────────────
\ A3. DICTIONNAIRE ET COMPILATION
\ ──────────────────────────────────────────────────────────────────────
\
\ Bytecode Op (v2025.4 — 17 types) :
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
\   Op::LocalGet(i)          — Lit local[base+i] (v2025.4)
\   Op::LocalSet(i)          — Écrit local[base+i] (v2025.4)
\   Op::LocalsAlloc(N)       — Alloue N locaux (v2025.4)
\   Op::LocalsFree(N)        — Libère N locaux (v2025.4)


\ ──────────────────────────────────────────────────────────────────────
\ A4. CYCLE DE VIE D'UN MOT
\ ──────────────────────────────────────────────────────────────────────
\
\ 1. DÉFINITION : : nom ... ;  ou : nom { params -- } ... ;
\ 2. COMPILATION : source → Vec<Op>
\ 3. STOCKAGE : ajouté au dictionnaire
\ 4. EXÉCUTION : execute_ops_limited()
\ 5. SUPPRESSION : forget / marker


\ ──────────────────────────────────────────────────────────────────────
\ A5. GESTION DES ERREURS
\ ──────────────────────────────────────────────────────────────────────
\
\ 4 niveaux :
\   1. Implicite (overflow, /0, hors bornes)
\   2. try/catch/throw
\   3. abort"
\   4. Codes d'erreur drivers (-1..-20)

: demo-exception ( -- )
  try 42 throw 0
  catch ." Exception: " . cr endtry ;


\ ──────────────────────────────────────────────────────────────────────
\ A6. MULTITÂCHE
\ ──────────────────────────────────────────────────────────────────────
\
\ PIT ~100 Hz, round-robin, dictionnaire partagé.
\ ms yield (v2025.2), touche yield (v2025.3).
\ critical-begin/end (v2025.2), timeout 100k.
\ Voir MUTEX.FTH pour la synchronisation complète.


\ ──────────────────────────────────────────────────────────────────────
\ A7. BIBLIOTHÈQUES STANDARD
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌──────────────┬──────────────────────────────────────────────────┐
\ │ STDLIB.FTH   │ true false bl tab max3 clamp within bounds      │
\ │              │ /string [] matrix[] 0.r hex. ? ?? >number        │
\ │              │ f>str time>str date>str times for map            │
\ │              │ array:create push pop                            │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ FIXED.FTH    │ f+ f- f* f/ fsqrt fsin fcos ftan fatan          │
\ │              │ v2.add v2.len v2.normalize v2.rotate             │
\ │              │ phys.move phys.bounce plot.curve sensor.*        │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ MUTEX.FTH    │ critical-begin/end spin:* mutex:* sem:*          │
\ │              │ chan:* rwlock:* barrier:* pool:* tls:*            │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ EVENTS.FTH   │ on-key-press on-mouse-move on-tick event-loop   │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ THEME.FTH    │ BG-DARK BG-MID ACCENT FG WIN-BG WIN-HDR        │
\ │              │ BTN-N BTN-H TASKBAR-H HEADER-H                 │
\ ├──────────────┼──────────────────────────────────────────────────┤
\ │ TESTS.FTH    │ assert= assert-true section lancer-tests        │
\ └──────────────┴──────────────────────────────────────────────────┘


\ ──────────────────────────────────────────────────────────────────────
\ A8. GESTION MÉMOIRE DU STRING_POOL
\ ──────────────────────────────────────────────────────────────────────
\
\ marker sauvegarde snap_pool ; restore-marker (prim 300)
\ tronque le pool. forget scanne les ops restants pour
\ trouver l'offset max, puis tronque sélectivement.
\ Sessions longues sans fuite mémoire.


\ ──────────────────────────────────────────────────────────────────────
\ A9. VARIABLES LOCALES { } (v2025.4)
\ ──────────────────────────────────────────────────────────────────────
\
\ Syntaxe :
\   : nom { param1 param2 / local1 local2 -- retours }
\     corps ;
\
\ Règles :
\   - Noms AVANT / → paramètres (pop de la pile)
\   - Noms APRÈS / → locaux (initialisés à 0)
\   - -- → documentation des retours (ignoré)
\   - nom → LocalGet (empile la valeur)
\   - to nom → LocalSet (écrit la valeur)
\   - LocalsFree compilé automatiquement avant Exit
\
\ Résolution de priorité :
\   locals > dictionnaire > variables > nombres
\
\ Stockage :
\   locals[] : Vec<i64> séparé de rstack
\   locals_frame[] : Vec<usize> pour les frame pointers
\   Chaque appel (y compris récursif) a sa propre frame
\
\ Bytecode :
\   Op::LocalsAlloc(N) — pop N valeurs → locals
\   Op::LocalGet(i)    — empile locals[base+i]
\   Op::LocalSet(i)    — dépile → locals[base+i]
\   Op::LocalsFree(N)  — libère N locaux + restaure base
\
\ Exemples :

: add-local { a b -- sum }
  a b + ;

: swap-local { a b / tmp -- }
  a to tmp  b to a  tmp to b
  a . b . cr ;

: fact-local { n -- n! }
  n 1 <= if 1 else n n 1- recurse * then ;

: sum-to-local { n / acc -- sum }
  0 to acc
  n 1+ 1 do i acc + to acc loop
  acc ;

\ Avant / Après comparaison :
\
\   AVANT (pile jonglage) :
\     : hyp ( x y -- h )
\       dup * swap dup * + ;
\
\   APRÈS (locals) :
\     : hyp { x y -- h }
\       x x * y y * + ;


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE B — ÉCRIRE UN DRIVER
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ B1. ANATOMIE D'UN DRIVER FORTH (v2025.4 avec locals)
\ ──────────────────────────────────────────────────────────────────────

\ --- Squelette complet v2025.4 ---

\ require STDLIB.FTH
\ require MUTEX.FTH
\
\ 0x3F8 constant MYDRV-BASE
\ 10    constant MYDRV-TIMEOUT
\
\ 0 enum MYDRV-UNINIT  enum MYDRV-READY  enum MYDRV-ERROR  drop
\
\ MYDRV-UNINIT value mydrv-state
\ mutex:create constant mydrv-lock
\ variable mydrv-errors
\
\ struct mydrv-regs
\   field .data  field .status  field .ctrl
\ end-struct
\
\ : mydrv:safe-read { -- val }
\   mydrv-lock mutex:lock
\   MYDRV-BASE .data + inb
\   mydrv-lock mutex:unlock ;
\
\ : mydrv:init { -- ok? }
\   MYDRV-BASE .status + inb 0<> if
\     MYDRV-READY to mydrv-state  0 mydrv-errors !  1
\   else
\     MYDRV-ERROR to mydrv-state  0
\   then ;
\
\ : mydrv:info ( -- )
\   ." MyDriver v4 — Etat: "
\   mydrv-state case
\     MYDRV-UNINIT of ." non init" endof
\     MYDRV-READY  of ." pret"     endof
\     MYDRV-ERROR  of ." erreur"   endof
\   endcase cr ;
\
\ : mydrv-init ( -- )
\   mydrv:init if ." OK" else ." ECHEC" then cr ;
\
\ sys:register mydrv


\ ──────────────────────────────────────────────────────────────────────
\ B2. CONVENTION DE NOMMAGE
\ ──────────────────────────────────────────────────────────────────────
\
\ Préfixes : uart: spi: gpio: temp: led: wdog:
\ Suffixes : :init :read :write :status :info :close :test
\ Values : drv-base drv-state (modifiables avec to)
\ Variables : drv-count drv-errors (compteurs avec +!)
\ Mutex : drv-lock (constant)


\ ──────────────────────────────────────────────────────────────────────
\ B3-B10. ACCÈS MATÉRIEL
\ ──────────────────────────────────────────────────────────────────────

\ B3 — Ports I/O
0x3F8 constant COM1-BASE
0x3FD constant COM1-LSR

: com1-tx-ready? ( -- flag )  COM1-LSR inb 0x20 and 0<> ;
: com1-rx-ready? ( -- flag )  COM1-LSR inb 0x01 and 0<> ;

: com1-tx ( char -- )
  begin com1-tx-ready? until COM1-BASE outb ;

: com1-rx ( -- char|-1 )
  com1-rx-ready? if COM1-BASE inb else -1 then ;

\ Pattern timeout ms yield :
: wait-port { port mask timeout -- ok? }
  timeout 0 do
    port inb mask and 0<> if 1 unloop exit then
    1 ms
  loop
  0 ;

\ B4 — MMIO avec struct :
\ : reg@ { base offset -- val }  base offset + mmio@ ;
\ : reg! { val base offset -- }  val base offset + mmio! ;

\ B5 — PCI :
: pci-find-device { vid did -- bus dev func | -1 }
  pci-scan 0 ?do
    i pci-dev drop drop
    did = if vid = if unloop exit then else drop then
    drop drop drop
  loop -1 ;

\ B9 — Allocation physique :
: with-phys { pages xt -- }
  pages alloc-phys dup 0 = if
    drop ." Alloc echec" cr exit
  then
  dup >r xt execute
  r> pages free-phys drop ;

\ B10 — Timing :
: benchmark { xt -- ms }
  ticks xt execute ticks swap - ;


\ ──────────────────────────────────────────────────────────────────────
\ B11. DRIVER COMPLET : UART 16550 (v2025.4 avec locals)
\ ──────────────────────────────────────────────────────────────────────

0x3F8 constant UART-BASE
0x3FD constant UART-LSR
0x01 constant UART-LSR-DATA
0x20 constant UART-LSR-TX

0 enum UART-UNINIT  enum UART-READY  enum UART-ERROR  drop

UART-UNINIT value uart-state
variable uart-tx-count  variable uart-rx-count  variable uart-errors

: uart:tx-ready? ( -- flag )  UART-LSR inb UART-LSR-TX and 0<> ;
: uart:rx-ready? ( -- flag )  UART-LSR inb UART-LSR-DATA and 0<> ;

: uart:init { baud -- ok? }
  115200 baud /
  0 0x3F9 outb
  0x80 0x3FB outb
  dup 0xFF and UART-BASE outb
  8 rshift 0xFF and 0x3F9 outb
  0x03 0x3FB outb  0xC7 0x3FA outb  0x0B 0x3FC outb
  \ Loopback test
  0x1E 0x3FC outb  0xAE UART-BASE outb
  100 0 do uart:rx-ready? if leave then 1 ms loop
  UART-BASE inb 0xAE = if
    0x0B 0x3FC outb
    UART-READY to uart-state
    0 uart-tx-count !  0 uart-rx-count !  0 uart-errors !
    1
  else UART-ERROR to uart-state  0 then ;

: uart:tx { char -- }
  uart-state UART-READY <> if exit then
  10 0 do uart:tx-ready? if leave then 1 ms loop
  uart:tx-ready? 0= if 1 uart-errors +! exit then
  char UART-BASE outb  1 uart-tx-count +! ;

: uart:rx { -- char|-1 }
  uart-state UART-READY <> if -1 exit then
  uart:rx-ready? if UART-BASE inb 1 uart-rx-count +!
  else -1 then ;

: uart:puts { addr len -- }
  len 0 ?do addr i + @ 0xFF and uart:tx loop ;

: uart:info ( -- )
  ." === UART 16550 ===" cr
  ." Etat: " uart-state case
    UART-UNINIT of ." non init" endof
    UART-READY  of ." pret"     endof
    UART-ERROR  of ." erreur"   endof
  endcase cr
  ." TX:" uart-tx-count @ . ."  RX:" uart-rx-count @ .
  ."  Err:" uart-errors @ . cr ;

: uart-init ( -- )
  115200 uart:init if ." UART OK" cr else ." UART ECHEC" cr then ;

sys:register uart


\ ──────────────────────────────────────────────────────────────────────
\ B12. DRIVER : LED CLAVIER PS/2
\ ──────────────────────────────────────────────────────────────────────

0x60 constant KBD-DATA  0x64 constant KBD-STATUS
variable kbd-leds

: kbd-wait-input ( -- ok? )
  100 0 do KBD-STATUS inb 2 and 0= if 1 unloop exit then 1 ms loop 0 ;

: kbd-send { byte -- ok? }
  kbd-wait-input 0= if 0 exit then
  byte KBD-DATA outb
  100 0 do
    KBD-STATUS inb 1 and 0<> if
      KBD-DATA inb 0xFA = if 1 unloop exit then
    then 1 ms
  loop 0 ;

: led:set { mask -- }
  mask 7 and kbd-leds !
  0xED kbd-send drop  kbd-leds @ kbd-send drop ;
: led:on { bit -- }      kbd-leds @ bit or led:set ;
: led:off { bit -- }     bit invert kbd-leds @ and led:set ;
: led:toggle { bit -- }  kbd-leds @ bit xor led:set ;
: led:numlock    2 led:toggle ;
: led:capslock   4 led:toggle ;
: led:scrolllock 1 led:toggle ;

: led:knight-rider { n -- }
  n 0 ?do
    1 led:set 100 ms  2 led:set 100 ms
    4 led:set 100 ms  2 led:set 100 ms
  loop 0 led:set ;

: led:test ( -- ) ." LEDs..." cr 3 led:knight-rider ." OK" cr ;


\ ──────────────────────────────────────────────────────────────────────
\ B13. DRIVER : TEMPÉRATURE CPU
\ ──────────────────────────────────────────────────────────────────────

0x19C constant MSR-THERM  0x1A2 constant MSR-TEMP-TGT
100 value cpu-tj-max

: temp:init ( -- ok? )
  try
    MSR-TEMP-TGT msr@ drop 16 rshift 0xFF and
    dup 0 > if to cpu-tj-max else drop then 1  0
  catch drop 100 to cpu-tj-max 1 endtry ;

: temp:read { -- celsius|-1 }
  try
    MSR-THERM msr@ drop
    dup 0x80000000 and 0= if drop -1
    else 16 rshift 0x7F and cpu-tj-max swap - then 0
  catch drop -1 endtry ;

: temp:info ( -- )
  ." Tj_max:" cpu-tj-max . ."  Actuelle:"
  temp:read dup -1 = if drop ." N/A" else . ." C" then cr ;

: temp-init ( -- )
  temp:init if ." Temp OK" cr else ." Temp ECHEC" cr then ;

sys:register temp


\ ──────────────────────────────────────────────────────────────────────
\ B14. DRIVER : WATCHDOG TCO
\ ──────────────────────────────────────────────────────────────────────

0 value tco-base  variable wdog-active

: wdog:find-tco ( -- ok? )
  pci-scan 0 ?do
    i pci-dev dup 0x01 = if over 0x06 = if
      drop drop drop 2dup 0 0x50 pci@ 0xFFE0 and to tco-base
      drop drop drop tco-base 0 > if 1 unloop exit then
    else drop drop drop drop drop drop drop then
    else drop drop drop drop drop drop drop then
  loop 0 ;

: wdog:init { seconds -- ok? }
  wdog:find-tco 0= if ." TCO absent" cr 0 exit then
  tco-base 8 + inw 0x0800 or tco-base 8 + outw
  tco-base 0x12 + inw 0xFC00 and seconds or tco-base 0x12 + outw
  tco-base 8 + inw 0xF7FF and tco-base 8 + outw
  1 wdog-active ! 1 ;

: wdog:feed ( -- )
  wdog-active @ 0= if exit then
  tco-base inw 8 or tco-base outw ;

: wdog:stop ( -- )
  wdog-active @ 0= if exit then
  tco-base 8 + inw 0x0800 or tco-base 8 + outw
  0 wdog-active ! ;

: wdog:info ( -- )
  ." WDog TCO base:0x" tco-base hex . decimal
  ."  actif:" wdog-active @ if ." OUI" else ." NON" then cr ;


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE C — ÉCRIRE UNE APPLICATION
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ C1-C5. APPLICATIONS CLASSIQUES
\ ──────────────────────────────────────────────────────────────────────

\ C1 — Console :
: app-hello ( -- )
  cr ." === Hello Epona OS ===" cr
  ." Chiffre ? " touche 48 -
  dup 0 >= over 9 <= and if
    cr ." Tape: " . ."  Carre: " dup * . cr
  else drop cr ." Pas un chiffre" cr then ;

\ C2 — Canvas :
variable bx  variable by  variable bdx  variable bdy

: demo-balle ( -- )
  50 bx ! 50 by ! 3 bdx ! 2 bdy !
  begin
    0x000020 effacer
    bx @ bdx @ + bx !  by @ bdy @ + by !
    bx @ 390 > if -3 bdx ! then  bx @ 0 < if 3 bdx ! then
    by @ 290 > if -2 bdy ! then  by @ 0 < if 2 bdy ! then
    bx @ by @ 10 10 0xFF4444 rect
    16 ms touche? 27 =
  until ;

\ C4 — Réseau :
: ping-test ( -- )
  net:init 0= if ." Pas de carte" cr exit then
  net:dhcp 0= if ." DHCP echec" cr exit then
  ." Ping 8.8.8.8... "
  8 8 8 8 net:ping dup 0 < if drop ." timeout" else . ." ms" then cr ;


\ ──────────────────────────────────────────────────────────────────────
\ C6. MONITEUR SYSTÈME (v2025.4 avec locals)
\ ──────────────────────────────────────────────────────────────────────

: sysmon ( -- )
  cr ." === MONITEUR SYSTEME ===" cr
  ." CPU leaf max: " 0 cpuid drop swap drop swap drop . cr
  ." Uptime: " ticks 1000 / . ." sec" cr
  ." RAM: " mem-map over 4 * 1024 / . ." MB total, "
  4 * 1024 / . ." MB libre" cr
  ." Ecran: " fb-size swap . ." x" . cr
  ." Heap: " heap-used . ." octets" cr
  ." PCI: " pci-scan . ." peripheriques" cr
  ." Heure: " get-time . ." /" . ." /" . ."  " . ." :" . ." :" . cr
  [defined] temp:read [if]
    ." Temp: " temp:read dup -1 = if drop ." N/A" else . ." C" then cr
  [then] ;


\ ──────────────────────────────────────────────────────────────────────
\ C7. TERMINAL SÉRIE
\ ──────────────────────────────────────────────────────────────────────

: minicom ( -- )
  115200 uart:init 0= if ." UART echec" cr exit then
  cr ." Minicom — Echap=quitter" cr
  begin
    uart:rx dup -1 <> if emit else drop then
    touche? dup 27 = if drop cr ." Fin." cr exit then
    dup 0 <> if uart:tx else drop then
    1 ms
  again ;


\ ──────────────────────────────────────────────────────────────────────
\ C8. ÉDITEUR HEXADÉCIMAL
\ ──────────────────────────────────────────────────────────────────────

: hex-line { addr -- }
  addr ." 0x" hex . decimal ."  | "
  16 0 do addr i + c@ dup 16 < if ." 0" then hex . decimal space loop
  ." | "
  16 0 do addr i + c@ dup 32 >= over 126 <= and if emit else drop 46 emit then loop
  cr ;

: hexdump { addr len -- }
  cr ." Adresse     | Hex                                     | ASCII" cr
  addr len + addr
  begin 2dup > if dup hex-line 16 + else 2drop exit then again ;


\ ──────────────────────────────────────────────────────────────────────
\ C9. APPLICATION AVEC ÉVÉNEMENTS
\ ──────────────────────────────────────────────────────────────────────
\
\ require EVENTS.FTH
\ require FIXED.FTH
\
\ F.0 value obj-x  F.0 value obj-y
\ 3 f.from value obj-vx  2 f.from value obj-vy
\
\ : game-key { char -- }
\   char case
\     [char] w of obj-vy F.1 f- to obj-vy endof
\     [char] s of obj-vy F.1 f+ to obj-vy endof
\     [char] a of obj-vx F.1 f- to obj-vx endof
\     [char] d of obj-vx F.1 f+ to obj-vx endof
\     [char] q of stop endof
\     drop
\   endcase ;
\
\ : game-tick { ms -- }
\   obj-x obj-vx f+ to obj-x
\   obj-y obj-vy f+ to obj-y
\   0x000020 effacer
\   obj-x f.to obj-y f.to 10 10 0x00FF00 rect ;
\
\ ' game-key is on-key-press  ' game-tick is on-tick
\ : principal  event-loop ;


\ ──────────────────────────────────────────────────────────────────────
\ C10. APPLICATION DE BUREAU (ForthApp) (v2025.4)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le système ForthApp permet de créer des fenêtres avec :
\   - Barre de titre, bordure, bouton fermer
\   - Callbacks : <nom>-draw, <nom>-key, <nom>-click
\   - Z-order automatique, focus clavier
\
\ Syntaxe :
\   app: <nom> ( x y w h -- )
\
\ Exemple minimal :

\ variable mon-compteur
\ 0 mon-compteur !
\
\ : MonApp-draw { wx wy ww wh -- }
\   wx wy ww wh 0x001122 rect ;
\
\ : MonApp-key { char -- }
\   char 13 = if 1 mon-compteur +! then ;
\
\ : MonApp-click ( -- )
\   1 mon-compteur +! ;
\
\ 100 100 200 150 app: MonApp


\ ──────────────────────────────────────────────────────────────────────
\ C11. BUREAU COMPLET EN FORTH (fullscreen-mode) (v2025.4)
\ ──────────────────────────────────────────────────────────────────────
\
\ Le mode fullscreen remplace le bureau Rust par un bureau Forth.
\
\ Primitives :
\   fullscreen-mode ( addr len -- )  Active le mode plein écran
\   fullscreen-off  ( -- )           Retour au bureau Rust
\   canvas-resize   ( w h -- )       Redimensionne le canvas
\
\ Architecture du bureau Forth :
\
\   BOOT.FTH
\   ├── require STDLIB.FTH
\   ├── require FIXED.FTH
\   ├── require THEME.FTH
\   ├── require CLOCK_APP.FTH
\   ├── require NOTEPAD_APP.FTH
\   ├── require FILEMAN_APP.FTH
\   ├── require SETTINGS_APP.FTH
\   ├── require CALC_APP.FTH
\   ├── app: Clock  app: Notepad  app: Files ...
\   └── : principal  begin 100 ms again ;
\
\ Constantes THEME.FTH :
\   BG-DARK=0x1A1A2E  BG-MID=0x16213E  ACCENT=0xE94560
\   FG=0xFFFFFF  WIN-BG=0x222222  WIN-HDR=0x333344
\   BTN-N=0x444455  BTN-H=0x5555AA  TASKBAR-H=35
\
\ Exemple bureau complet :
\   fb-size canvas-resize
\   s" mon-bureau" fullscreen-mode
\
\ IMPORTANT : principal doit boucler à l'infini !
\   Si principal se termine, les fenêtres ForthApp ne sont plus
\   dessinées. Utiliser : begin 100 ms again


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE D — ÉCRIRE UN SIMULATEUR
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ D1. ARCHITECTURE SIMULATEUR CPU (v2025.4 avec locals)
\ ──────────────────────────────────────────────────────────────────────
\
\ Pattern avec value, enum, case, buffer:, locals :
\
\   0 enum OP-NOP  enum OP-LOAD  enum OP-ADD  enum OP-HALT  drop
\   0 value sim-pc  0 value sim-a
\   256 buffer: sim-ram
\
\   : sim-fetch { -- opcode }
\     sim-pc sim-ram + @ 0xFF and
\     sim-pc 1+ to sim-pc ;
\
\   : sim-step { -- halt? }
\     sim-fetch case
\       OP-NOP  of 0 endof
\       OP-LOAD of sim-fetch to sim-a 0 endof
\       OP-ADD  of sim-fetch sim-a + to sim-a 0 endof
\       OP-HALT of 1 endof
\       ." ?" cr 1
\     endcase ;


\ ──────────────────────────────────────────────────────────────────────
\ D2. SIMULATEUR CHIP-8
\ ──────────────────────────────────────────────────────────────────────

create c8-ram    4096 allot
create c8-v      16   allot
create c8-screen 2048 allot
create c8-stack  16   allot
variable c8-i  variable c8-pc  variable c8-sp
variable c8-dt  variable c8-st  variable c8-running

: c8-mem@ { addr -- byte }  addr 0xFFF and c8-ram + @ 0xFF and ;
: c8-mem! { byte addr -- }  byte 0xFF and addr 0xFFF and c8-ram + ! ;
: c8-v@   { reg -- val }    reg 0x0F and c8-v + @ 0xFF and ;
: c8-v!   { val reg -- }    val 0xFF and reg 0x0F and c8-v + ! ;

: c8-init ( -- )
  4096 0 do 0 i c8-ram + ! loop
  16 0 do 0 i c8-v + ! loop
  2048 0 do 0 i c8-screen + ! loop
  0 c8-i !  0x200 c8-pc !  0 c8-sp !
  0 c8-dt !  0 c8-st !  1 c8-running !
  0xF0 0 c8-mem!  0x90 1 c8-mem!  0x90 2 c8-mem!
  0x90 3 c8-mem!  0xF0 4 c8-mem! ;

: c8-load { src len -- }
  c8-init len 0 ?do src i + @ 0xFF and 0x200 i + c8-mem! loop ;

: c8-fetch { -- op16 }
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
  c8-fetch dup 0xF000 and 12 rshift
  case
    0x0 of dup 0x00E0 = if 2048 0 do 0 i c8-screen + ! loop then
           dup 0x00EE = if -1 c8-sp +! c8-sp @ c8-stack + @ c8-pc ! then endof
    0x1 of dup 0x0FFF and c8-pc ! endof
    0x2 of c8-pc @ c8-sp @ c8-stack + ! 1 c8-sp +!
           dup 0x0FFF and c8-pc ! endof
    0x6 of dup 0xFF and over 8 rshift 0x0F and c8-v! endof
    0x7 of dup 8 rshift 0x0F and dup c8-v@
           rot 0xFF and + 0xFF and swap c8-v! endof
    0xA of dup 0x0FFF and c8-i ! endof
    0xC of dup 8 rshift 0x0F and over 0xFF and hasard swap c8-v! endof
  endcase drop
  c8-dt @ 0 > if -1 c8-dt +! then
  c8-st @ 0 > if -1 c8-st +! then ;

: c8-run ( -- )
  begin c8-step c8-draw 2 ms touche? 27 = c8-running @ 0= or until ;


\ ──────────────────────────────────────────────────────────────────────
\ D3. JEU DE LA VIE
\ ──────────────────────────────────────────────────────────────────────

40 constant LIFE-W  30 constant LIFE-H
create life-a  LIFE-W LIFE-H * allot
create life-b  LIFE-W LIFE-H * allot
variable life-gen  variable life-current

: life-grid  ( -- a ) life-current @ 0= if life-a else life-b then ;
: life-other ( -- a ) life-current @ 0= if life-b else life-a then ;
: life-get { x y -- 0|1 }
  x LIFE-W mod y LIFE-H mod LIFE-W * + life-grid + @ ;

: life-clear ( -- )
  LIFE-W LIFE-H * 0 do 0 i life-a + ! 0 i life-b + ! loop
  0 life-gen !  0 life-current ! ;

: life-neighbors { x y -- n }
  0
  3 0 do 3 0 do
    i 1 - j 1 - or 0<> if
      x i 1 - + y j 1 - + life-get +
    then
  loop loop ;

: life-step ( -- )
  LIFE-H 0 do LIFE-W 0 do
    i j life-neighbors i j life-get if
      dup 2 < if drop 0 else 3 > if 0 else 1 then then
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

: life-run ( -- )
  life-clear
  \ Gliders
  begin life-draw life-step 50 ms touche? 27 = until ;


\ ════════════════════════════════════════════════════════════════════════
\                    PARTIE E — BONNES PRATIQUES
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ E1-E8. BONNES PRATIQUES (inchangées depuis v2025.3)
\ ──────────────────────────────────────────────────────────────────────
\
\ E1. Documenter : ( avant -- après )
\ E2. Erreurs : try/catch, abort", retry-op
\ E3. Tests : section + assert= dans TESTS.FTH
\ E4. Performance : buffer:, value, case, ms yield, benchmark
\ E5. Sécurité : secure on, abort", mem-bounds
\ E6. Portabilité : cell+, cells, [defined], require
\ E7. Synchronisation : mutex:with, chan:send/recv
\ E8. Pool : marker pour sessions, forget sélectif


\ ──────────────────────────────────────────────────────────────────────
\ E9. UTILISATION DES LOCALS (v2025.4)
\ ──────────────────────────────────────────────────────────────────────
\
\ QUAND utiliser des locals :
\   ✅ 4+ paramètres (pile illisible)
\   ✅ Valeurs réutilisées plusieurs fois
\   ✅ Algorithmes complexes (récursion, accumulateurs)
\   ✅ Drivers avec struct/champs multiples
\
\ QUAND NE PAS utiliser :
\   ❌ Mots simples 1-2 params (dup * plus rapide que { n -- } n n *)
\   ❌ Mots très courts (overhead LocalsAlloc/Free)
\
\ PATTERNS :
\
\ Pattern 1 — Driver avec locals :
\   : drv:read { port timeout -- val ok? }
\     timeout 0 do
\       port inb dup 0<> if 1 unloop exit then drop
\       1 ms
\     loop 0 0 ;
\
\ Pattern 2 — Accumulateur :
\   : sum-squares { n / acc -- }
\     0 to acc
\     n 1+ 1 do i dup * acc + to acc loop
\     acc ;
\
\ Pattern 3 — Récursion :
\   : fib { n -- }
\     n 2 < if n else
\       n 1- recurse  n 2- recurse  +
\     then ;
\
\ Pattern 4 — Multi-retour :
\   : divmod { a b -- quot rem }
\     a b /  a b mod ;
\
\ PIÈGE — to dans une boucle :
\   : BUGGY { n / acc -- }
\     n 0 do i to acc loop acc ;
\   \ ↑ acc vaut n-1 (dernière valeur), pas la somme !
\   : CORRECT { n / acc -- }
\     0 to acc  n 0 do i acc + to acc loop acc ;


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
\   + - * / mod /mod */ 1+ 1- 2+ 2- 2* 2/
\   abs negate min max hasard
\   fm/mod sm/rem um* um/mod
\
\ === COMPARAISON ===
\   = <> < > <= >= 0= 0<> 0< 0>
\
\ === LOGIQUE ===
\   and or xor invert lshift rshift
\
\ === MÉMOIRE FORTH ===
\   @ ! +! variable constant value to
\   here allot , c, cell cell+ cells aligned char+ chars
\   blank erase move  create does>
\
\ === MÉMOIRE PHYSIQUE ===
\   c@ c! w@ w! l@ l! mmio@ mmio! phys@ phys!
\   alloc-phys free-phys
\
\ === AFFICHAGE ===
\   . u. cr space spaces emit type count
\   compare search  ." ... s" ...
\   abort"  hex decimal
\
\ === CONTRÔLE ===
\   if else then  begin until again  begin while repeat
\   do loop +loop ?do leave i j
\   case of endof endcase
\   exit recurse  try catch endtry throw
\
\ === COMPILATION ===
\   : ; immediate  { } / -- to  (locals)
\   ' ['] execute postpone  defer is action-of
\   see word-info synonym  >body evaluate
\   value to  include require  marker
\   [if] [else] [then] [defined] [undefined]
\   struct field end-struct  enum  buffer:
\   state ] [  find literal forget
\   [char] char  ,"
\
\ === PLEIN ÉCRAN (v2025.4) ===
\   fullscreen-mode ( addr len -- )
\   fullscreen-off  ( -- )
\   canvas-resize   ( w h -- )
\
\ === ÉCRAN ===
\   fb-size fb-swap fb:pixel fb:rect fb:line fb:text fb:blit
\   fb-text rect-outline
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
\
\ === TEMPS ===
\   ms attendre ticks stall stall-us  get-time set-time  rdtsc
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
\   hda-init hda-play hda-stop hda-volume hda-info hda-beep hda-status
\   beep
\
\ === I2C ===
\   dw-i2c-init dw-i2c-probe i2c.probe i2c-read
\   i2c:status i2c:read i2c:gesture i2c:cal-set i2c:cal-get i2c:contacts
\
\ === INTERRUPTIONS ===
\   apic-base ioapic-read ioapic-write init-idt irq-handler
\
\ === SYSTÈME ===
\   mem-map heap-used smbios-entry smbios-info cfg-tables
\   reboot poweroff  alloc
\   sys:load sys:read sys:write sys:register sys:drivers sys:probe sys:log
\   task stop tasks
\
\ === SYNCHRONISATION ===
\   critical-begin critical-end
\
\ === SÉCURITÉ ===
\   mem-bounds file-allow file-revoke-all net-allow net-revoke
\
\ === WIDGETS / APPS ===
\   app: button-push textfield: list: list-add
\   widgets-draw widgets-clear
\
\ === DÉBOGAGE ===
\   step trace .ops  break unbreak watch unwatch  see word-info


\ ──────────────────────────────────────────────────────────────────────
\ F2. CODES D'ERREUR
\ ──────────────────────────────────────────────────────────────────────
\
\   -1  Générique         -11 Pile vide
\   -2  Timeout           -12 Pile pleine
\   -3  Non trouvé        -13 Mot inconnu
\   -4  Communication     -14 Division par zéro
\   -5  Buffer petit      -15 Fichier absent
\   -6  Non supporté      -16 Disque plein
\   -7  Permission        -17 Réseau absent
\   -8  Ressource occupée -18 Connexion refusée
\   -9  Adresse invalide  -19 DNS échoué
\   -10 Hors limites      -20 Checksum


\ ──────────────────────────────────────────────────────────────────────
\ F3. CONSTANTES UTILES
\ ──────────────────────────────────────────────────────────────────────

0xFF0000 constant ROUGE    0x00FF00 constant VERT
0x0000FF constant BLEU     0xFFFFFF constant BLANC
0x000000 constant NOIR     0xFFFF00 constant JAUNE
0xFF00FF constant MAGENTA  0x00FFFF constant CYAN
0x808080 constant GRIS

10 constant LF  13 constant CR-CHAR
27 constant ESC  32 constant BL-CONST
4096 constant PAGE-SIZE  512 constant SECTOR-SIZE

0x01 constant PCI-STORAGE  0x02 constant PCI-NETWORK
0x03 constant PCI-DISPLAY  0x06 constant PCI-BRIDGE


\ ──────────────────────────────────────────────────────────────────────
\ F4. PATTERNS COURANTS (v2025.4)
\ ──────────────────────────────────────────────────────────────────────
\
\ --- State machine (enum + case + value + locals) ---
\ 0 enum ST-IDLE  enum ST-RUN  enum ST-DONE  drop
\ ST-IDLE value state
\ : tick { / prev-state -- }
\   state to prev-state
\   state case
\     ST-IDLE of ... ST-RUN to state endof
\     ST-RUN  of ... ST-DONE to state endof
\   endcase ;
\
\ --- Driver avec locals ---
\ : drv:transfer { buf len addr timeout -- ok? }
\   timeout 0 do
\     addr inb 0x01 and 0<> if
\       len 0 do buf i + @ 0xFF and addr outb loop
\       1 unloop exit
\     then 1 ms
\   loop 0 ;
\
\ --- Retry avec backoff ---
\ : retry { xt retries delay -- ok? }
\   retries 0 do
\     xt execute if 1 unloop exit then
\     delay ms
\   loop 0 ;
\
\ --- Safe cleanup ---
\ : with-lock { lock xt -- }
\   lock mutex:lock
\   try xt execute 0 catch drop endtry
\   lock mutex:unlock ;


\ ──────────────────────────────────────────────────────────────────────
\ F5. FICHIERS DISPONIBLES (v2025.4)
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌──────────────────┬──────────┬────────────────────────────────────┐
\ │ Fichier          │ Statut   │ Description                        │
\ ├──────────────────┼──────────┼────────────────────────────────────┤
\ │ BOOT.FTH         │ ✅       │ Amorçage + bureau Forth            │
\ │ STDLIB.FTH       │ ✅       │ Bibliothèque standard              │
\ │ FIXED.FTH        │ ✅       │ Virgule fixe Q20.12                │
\ │ MUTEX.FTH        │ ✅       │ Synchronisation multitâche         │
\ │ EVENTS.FTH       │ ✅       │ Système d'événements               │
\ │ TESTS.FTH        │ ✅       │ Tests automatisés (180+)           │
\ │ DEVGUIDE.FTH     │ ✅       │ Ce guide (v2025.4)                 │
\ │ THEME.FTH        │ ✅       │ Constantes couleurs/layout         │
\ │ CLOCK_APP.FTH    │ ✅       │ Horloge analogique/digitale        │
\ │ NOTEPAD_APP.FTH  │ ✅       │ Éditeur de texte                   │
\ │ FILEMAN_APP.FTH  │ ✅       │ Gestionnaire de fichiers           │
\ │ SETTINGS_APP.FTH │ ✅       │ Panneau de paramètres              │
\ │ CALC_APP.FTH     │ ✅       │ Calculatrice                       │
\ │ SNAKE.FTH        │ ✅       │ Jeu Snake                          │
\ │ DESKTOP.FTH      │ ✅       │ Bureau plein écran                 │
\ ├──────────────────┼──────────┼────────────────────────────────────┤
\ │ CHIP8.FTH        │ 🔲 P1   │ CHIP-8 complet (35 opcodes)        │
\ │ RAYCAST.FTH      │ 🔲 P1   │ Raycaster 3D                       │
\ │ GUIKIT.FTH       │ 🔲 P2   │ Toolkit UI étendu                  │
\ │ HTTPD.FTH        │ 🔲 P2   │ Serveur HTTP                       │
\ │ COURSES/         │ 🔲 P3   │ Cours interactifs                  │
\ └──────────────────┴──────────┴────────────────────────────────────┘


\ ════════════════════════════════════════════════════════════════════════
\       PARTIE G — ROADMAP LANGAGE (mise à jour v2025.4)
\ ════════════════════════════════════════════════════════════════════════


\ ──────────────────────────────────────────────────────────────────────
\ G1. BILAN COMPLET — TOUT CE QUI EST IMPLÉMENTÉ
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌─────────────────────────────────────┬────────────────────────────┐
\ │ Composant                           │ État                       │
\ ├─────────────────────────────────────┼────────────────────────────┤
\ │ Primitives Rust                     │ ~310+  ✅                  │
\ │ Mots Forth (avec bibliothèques)     │ ~400+  ✅                  │
\ │ Tests automatisés                   │ ~180+  ✅                  │
\ │ Fichiers .FTH                       │ 15     ✅                  │
\ │ Apps de bureau                      │ 7      ✅                  │
\ │ Jeux                                │ 2      ✅ (balle, snake)   │
\ │ Drivers Forth                       │ 4      ✅ (uart,led,temp,wd)│
\ │ Simulateurs                         │ 2      ✅ (chip8, life)    │
\ ├─────────────────────────────────────┼────────────────────────────┤
\ │ Roadmap 20 mots (Phase 1-4)        │ 20/20  ✅                  │
\ │ Phase 5 — ANS (12 mots)            │ 12/12  ✅                  │
\ │ Locals { }                          │ ✅ 4 nouveaux Op           │
\ │ Bureau Forth (fullscreen)           │ ✅                         │
\ │ ForthApp système                    │ ✅                         │
\ ├─────────────────────────────────────┼────────────────────────────┤
\ │ ms yield                            │ ✅ v2025.2                 │
\ │ touche yield                        │ ✅ v2025.3                 │
\ │ critical_depth                      │ ✅ v2025.2                 │
\ │ string_pool fuite                   │ ✅ v2025.3                 │
\ │ forget sélectif                     │ ✅ v2025.3                 │
\ │ CallFrame safe                      │ ✅                         │
\ └─────────────────────────────────────┴────────────────────────────┘


\ ──────────────────────────────────────────────────────────────────────
\ G2. HISTORIQUE DES CORRECTIONS RUST
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌─────────┬────────────────────────────────┬───────────────────────┐
\ │ Version │ Correction                     │ Impact                │
\ ├─────────┼────────────────────────────────┼───────────────────────┤
\ │ v2025.2 │ ms yield (prim 20)             │ Scheduler fluide      │
\ │ v2025.2 │ critical-begin/end (310-311)   │ Mutex Forth           │
\ │ v2025.2 │ critical_depth + timeout 100k  │ Anti-deadlock         │
\ │ v2025.3 │ string_pool + marker (prim 300)│ Fuite mémoire         │
\ │ v2025.3 │ forget sélectif (prim 151)     │ Pool propre           │
\ │ v2025.3 │ touche yield (prim 17)         │ Bloquant coopératif   │
\ │ v2025.4 │ Locals Op (LocalGet/Set/etc.)  │ Lisibilité code       │
\ │ v2025.4 │ Phase 5 (12 prims ANS)         │ Compliance partielle  │
\ │ v2025.4 │ fullscreen-mode                │ Bureau Forth          │
\ │ v2025.4 │ app: + callbacks               │ ForthApp système      │
\ │ v2025.4 │ fb-text, rect-outline          │ Rendu texte           │
\ └─────────┴────────────────────────────────┴───────────────────────┘


\ ──────────────────────────────────────────────────────────────────────
\ G3. PROCHAINS MOTS ET AMÉLIORATIONS
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌────┬──────────────────────┬────────────┬─────────────────────────┐
\ │  # │ Mot / Amélioration   │ Difficulté │ Impact                  │
\ ├────┼──────────────────────┼────────────┼─────────────────────────┤
\ │  1 │ parse / parse-name   │ Moyenne    │ Parsing avancé          │
\ │  2 │ source / >in         │ Faible     │ Input standard ANS      │
\ │  3 │ refill               │ Faible     │ Multi-ligne             │
\ │  4 │ vocabularies         │ Haute      │ Namespaces              │
\ │  5 │ JIT x86-64 prototype │ Très haute │ Performance ×50         │
\ ├────┼──────────────────────┼────────────┼─────────────────────────┤
\ │  6 │ Backtrace Forth      │ 2h         │ Debug (call chain)      │
\ │  7 │ Mémoire u8 séparée   │ 1 jour     │ Buffers DMA/réseau     │
\ │  8 │ Limite instructions  │ 30 min     │ Configurable            │
\ │  9 │ Float logiciel       │ 1 mois     │ Calcul scientifique    │
\ │ 10 │ Bluetooth HCI        │ 2 semaines │ Périphériques modernes │
\ └────┴──────────────────────┴────────────┴─────────────────────────┘
\
\ Recommandation :
\   Immédiat (< 1 jour) : parse/source/refill Option A (minimal)
\   Court terme (1 sem)  : backtrace, limite configurable
\   Moyen terme (1 mois) : vocabularies, JIT prototype
\   Long terme : float, bluetooth


\ ──────────────────────────────────────────────────────────────────────
\ G4. ÉCOSYSTÈME .FTH
\ ──────────────────────────────────────────────────────────────────────
\
\ Fait : 15 fichiers .FTH
\ À faire :
\   P1 : CHIP8.FTH (35 opcodes), RAYCAST.FTH (3D)
\   P2 : GUIKIT.FTH (toolkit), HTTPD.FTH (serveur)
\   P3 : COURSES/ (13 cours interactifs)


\ ──────────────────────────────────────────────────────────────────────
\ G5. PLANNING
\ ──────────────────────────────────────────────────────────────────────
\
\ ┌────────────┬──────────────────────────────────────────────────────┐
\ │ Semaine 1  │ GitHub + vidéo YouTube + README                     │
\ │            │ SNAKE.FTH testé sur vrai matériel                   │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 2  │ CHIP8.FTH complet + RAYCAST.FTH                    │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 3  │ parse/source/refill + backtrace                     │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Semaine 4  │ HTTPD.FTH + GUIKIT.FTH                             │
\ ├────────────┼──────────────────────────────────────────────────────┤
\ │ Mois 2-3   │ Vocabularies + JIT prototype + communauté           │
\ └────────────┴──────────────────────────────────────────────────────┘
\
\ === INDICATEURS ===
\
\ ┌─────────────────────────┬────────┬──────────────────────────────┐
\ │ Critère                 │ Cible  │ Actuel                       │
\ ├─────────────────────────┼────────┼──────────────────────────────┤
\ │ Primitives Rust         │ 320    │ ~310 ✅                      │
\ │ Mots Forth total        │ 500+   │ ~400+ ✅                     │
\ │ Tests                   │ 250+   │ ~180 ✅                      │
\ │ Fichiers .FTH           │ 20+    │ 15 ✅                        │
\ │ Apps de bureau          │ 10+    │ 7 ✅                         │
\ │ Jeux                    │ 3+     │ 2 ✅                         │
\ │ Drivers                 │ 5+     │ 4 ✅                         │
\ │ Corrections Rust        │ 7/7    │ 7/7 ✅                       │
\ │ Locals { }              │ ✅     │ ✅                           │
\ │ Bureau Forth            │ ✅     │ ✅                           │
\ │ Communauté              │ 50+    │ 0 (pas encore publié)        │
\ └─────────────────────────┴────────┴──────────────────────────────┘


\ ════════════════════════════════════════════════════════════════════════
\            FIN DU GUIDE DÉVELOPPEUR EPONA OS v2025.4
\ ════════════════════════════════════════════════════════════════════════

cr
." ════════════════════════════════════════════════════════" cr
."  DEVGUIDE.FTH v2025.4 charge" cr
."  Locals { } : operationnel" cr
."  ~310 primitives, ~400 mots, 15 fichiers .FTH" cr
."  Bureau Forth : 7 apps (Clock, Notepad, Files...)" cr
."  Corrections Rust : 7/7 terminees" cr
."  Drivers : uart led temp wdog" cr
."  Jeux : demo-balle, snake, c8-run, life-run" cr
."  Commandes : sysmon hexdump minicom ping-test" cr
." ════════════════════════════════════════════════════════" cr
```

---

## Changements v2025.3 → v2025.4

| Section | Changement |
|---|---|
| **En-tête** | Version 2025.4, changelog locals + Phase 5 + bureau |
| **A1** | Ajouté `locals[]` et `locals_frame[]` dans le modèle mémoire |
| **A3** | 17 types Op (ajouté LocalGet/Set/Alloc/Free) |
| **A9** | **Nouvelle section** — Locals { } avec syntaxe, bytecode, exemples |
| **B1** | Squelette driver réécrit avec locals |
| **B3** | `wait-port` réécrit avec locals |
| **B5** | `pci-find-device` réécrit avec locals |
| **B9** | `with-phys` réécrit avec locals |
| **B10** | `benchmark` réécrit avec locals |
| **B11** | **UART complet réécrit** avec locals (`uart:init { baud -- }` etc.) |
| **B12** | LED réécrit avec locals (`kbd-send { byte -- }`) |
| **B13** | Temp réécrit avec locals (`temp:read { -- celsius }`) |
| **B14** | Watchdog réécrit avec locals (`wdog:init { seconds -- }`) |
| **C8** | `hexdump` réécrit avec locals |
| **C10** | **Nouvelle section** — ForthApp système |
| **C11** | **Nouvelle section** — Bureau Forth fullscreen |
| **D1** | Pattern simulateur avec locals |
| **D2** | CHIP-8 réécrit avec locals (`c8-mem@` etc.) |
| **D3** | Life réécrit avec locals (`life-neighbors { x y -- }`) |
| **E9** | **Nouvelle section** — Quand/comment utiliser les locals |
| **F1** | Ajouté : `{ } / -- to`, `fullscreen-mode/off`, `canvas-resize`, `fm/mod`, `um*`, `evaluate`, `synonym`, `action-of`, `[']`, `>body`, `*/`, `cell`, `blank`, `c,`, `rect-outline`, `fb-text` |
| **F4** | Patterns avec locals |
| **F5** | 15 fichiers listés + DESKTOP.FTH + apps |
| **G1** | Bilan complet avec locals, Phase 5, bureau, 7 corrections |
| **G2** | **Nouveau** — historique chronologique des corrections |
| **G3** | Prochains mots restants (parse, vocabularies, JIT) |
| **G5** | Planning + indicateurs mis à jour |
