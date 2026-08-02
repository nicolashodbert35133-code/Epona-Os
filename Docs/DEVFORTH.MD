# DEVFORTH.MD — DOCK & ENCYCLOPÉDIE EXPLICATIVE DES PRIMITIVES FORTH EPONA OS

> **Projet :** Epona OS (v1.98 -> Release Septembre 2026)  
> **Auteur :** Antigravity AI — Pair Programming OS Architect  
> **Objet :** Explication détaillée primitive par primitive de toutes les commandes de la Machine Virtuelle Forth Epona OS  
> **Source Kernel :** [interpreter.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/interpreter.rs) & [jit.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/jit.rs)  

---

## 💡 INTRODUCTORY & PILE DE DONNÉES FORTH

Dans Epona OS, la Machine Virtuelle Forth s'appuie sur une **pile de données principale (Data Stack)** constituée de cellules 64 bits signées (`i64`). 

Les nombres flottants en virgule IEEE 754 64-bit sont encodés et stockés directement dans ces cellules 64-bit via la conversion binaire `f64::to_bits()` / `f64::from_bits()`.

Chaque primitive est documentée ci-dessous avec :
- **ID d'Indice :** Le numéro d'enregistrement dans le dictionnaire de la VM.
- **Signature de Pile `( avant -- apres )` :** Les éléments consommés à gauche et produits à droite de `--`.
- **Explication Détaillée :** Le comportement exact au niveau du noyau Rust et de l'assemblage x86-64.
- **Exemple Forth :** Un extrait de code directement exécutable.

---

## 1. PRIMITIVES DE MANIPULATION DE PILE ET ARITHMÉTIQUE ENTIÈRE (0-49)

### `nop` (Indice 0)
- **Signature :** `( -- )`
- **Explication :** Instruction "No Operation". N'effectue aucune modification sur la pile ou la mémoire. Utilisée pour le calage d'instructions et le débogage.
- **Exemple Forth :** `nop`

### `+` (Indice 1)
- **Signature :** `( n1 n2 -- n3 )`
- **Explication :** Dépile les entiers signés `n2` puis `n1`, calcule l'addition entière `n3 = n1 + n2` (avec débordement en complément à deux 64 bits) et empile le résultat `n3`.
- **Exemple Forth :** `10 20 + .` \ Affiche 30

### `-` (Indice 2)
- **Signature :** `( n1 n2 -- n3 )`
- **Explication :** Dépile `n2` puis `n1`, calcule la soustraction entière `n3 = n1 - n2` et empile le résultat `n3`.
- **Exemple Forth :** `50 15 - .` \ Affiche 35

### `*` (Indice 3)
- **Signature :** `( n1 n2 -- n3 )`
- **Explication :** Dépile `n2` puis `n1`, effectue la multiplication entière 64 bits `n3 = n1 * n2` et empile le produit.
- **Exemple Forth :** `6 7 * .` \ Affiche 42

### `/` (Indice 4)
- **Signature :** `( n1 n2 -- n3 )`
- **Explication :** Dépile le diviseur `n2` et le dividende `n1`, effectue la division entière tronquée vers zéro `n3 = n1 / n2`. Génère un piège noyau si `n2 == 0`.
- **Exemple Forth :** `100 4 / .` \ Affiche 25

### `dup` (Indice 5)
- **Signature :** `( n -- n n )`
- **Explication :** Duplique la cellule située au sommet de la pile (TOS - Top of Stack).
- **Exemple Forth :** `42 dup . .` \ Affiche 42 42

### `drop` (Indice 6)
- **Signature :** `( n -- )`
- **Explication :** Retire et jette la valeur située au sommet de la pile.
- **Exemple Forth :** `10 20 drop .` \ Affiche 10

### `swap` (Indice 7)
- **Signature :** `( n1 n2 -- n2 n1 )`
- **Explication :** Inverse la position des deux premiers éléments au sommet de la pile.
- **Exemple Forth :** `1 2 swap . .` \ Affiche 1 2

### `over` (Indice 8)
- **Signature :** `( n1 n2 -- n1 n2 n1 )`
- **Explication :** Copie le deuxième élément de la pile (NOS - Next on Stack) et le place au sommet.
- **Exemple Forth :** `10 20 over . . .` \ Affiche 10 20 10

### `rot` (Indice 9)
- **Signature :** `( n1 n2 n3 -- n2 n3 n1 )`
- **Explication :** Effectue une rotation vers la gauche des trois premiers éléments de la pile : le troisième élément `n1` monte au sommet.
- **Exemple Forth :** `1 2 3 rot . . .` \ Affiche 1 3 2

### `@` (Indice 10)
- **Signature :** `( addr -- n )`
- **Explication :** Lit un entier signé 64 bits (8 octets) en mémoire virtuelle à l'adresse `addr` et le dépose sur la pile.
- **Exemple Forth :** `var-addr @ .`

### `!` (Indice 11)
- **Signature :** `( n addr -- )`
- **Explication :** Écrit l'entier 64 bits `n` à l'adresse mémoire `addr`.
- **Exemple Forth :** `99 var-addr !`

### `c@` (Indice 12)
- **Signature :** `( addr -- byte )`
- **Explication :** Lit un octet unique (8 bits) à l'adresse mémoire `addr` et l'étend à 64 bits sur la pile.
- **Exemple Forth :** `str-ptr c@ .`

### `c!` (Indice 13)
- **Signature :** `( byte addr -- )`
- **Explication :** Écrit le bit de poids faible (8 bits) de `byte` à l'adresse mémoire `addr`.
- **Exemple Forth :** `65 str-ptr c!` \ Écrit 'A'

### `mod` (Indice 14)
- **Signature :** `( n1 n2 -- rem )`
- **Explication :** Calcule le reste de la division entière de `n1` par `n2` (`rem = n1 % n2`).
- **Exemple Forth :** `17 5 mod .` \ Affiche 2

### `/mod` (Indice 15)
- **Signature :** `( n1 n2 -- rem quot )`
- **Explication :** Calcule simultanément le reste `rem` et le quotient `quot` de `n1 / n2`.
- **Exemple Forth :** `17 5 /mod . .` \ Affiche 3 2

### `1+` (Indice 16)
- **Signature :** `( n -- n+1 )`
- **Explication :** Incrémente la valeur au sommet de la pile de 1 (optimisé en assembleur `inc`).
- **Exemple Forth :** `9 1+ .` \ Affiche 10

### `1-` (Indice 17)
- **Signature :** `( n -- n-1 )`
- **Explication :** Décrémente la valeur au sommet de la pile de 1 (optimisé en assembleur `dec`).
- **Exemple Forth :** `10 1- .` \ Affiche 9

### `negate` (Indice 18)
- **Signature :** `( n -- -n )`
- **Explication :** Inverse le signe arithmétique de l'entier au sommet de la pile (`-n`).
- **Exemple Forth :** `42 negate .` \ Affiche -42

### `abs` (Indice 19)
- **Signature :** `( n -- |n| )`
- **Explication :** Calcule la valeur absolue de l'entier (`|n|`).
- **Exemple Forth :** `-15 abs .` \ Affiche 15

### `min` (Indice 20)
- **Signature :** `( n1 n2 -- min )`
- **Explication :** Compare `n1` et `n2` et conserve uniquement la valeur la plus petite.
- **Exemple Forth :** `12 8 min .` \ Affiche 8

### `max` (Indice 21)
- **Signature :** `( n1 n2 -- max )`
- **Explication :** Compare `n1` et `n2` et conserve uniquement la valeur la plus grande.
- **Exemple Forth :** `12 8 max .` \ Affiche 12

### `<` (Indice 22)
- **Signature :** `( n1 n2 -- flag )`
- **Explication :** Empile `-1` (Vrai) si `n1 < n2`, sinon `0` (Faux).
- **Exemple Forth :** `5 10 < .` \ Affiche -1

### `>` (Indice 23)
- **Signature :** `( n1 n2 -- flag )`
- **Explication :** Empile `-1` (Vrai) si `n1 > n2`, sinon `0` (Faux).
- **Exemple Forth :** `10 5 > .` \ Affiche -1

### `=` (Indice 24)
- **Signature :** `( n1 n2 -- flag )`
- **Explication :** Empile `-1` (Vrai) si `n1 == n2`, sinon `0` (Faux).
- **Exemple Forth :** `7 7 = .` \ Affiche -1

### `<=` (Indice 25)
- **Signature :** `( n1 n2 -- flag )`
- **Explication :** Empile `-1` (Vrai) si `n1 <= n2`, sinon `0` (Faux).
- **Exemple Forth :** `5 5 <= .` \ Affiche -1

### `>=` (Indice 26)
- **Signature :** `( n1 n2 -- flag )`
- **Explication :** Empile `-1` (Vrai) si `n1 >= n2`, sinon `0` (Faux).
- **Exemple Forth :** `6 5 >= .` \ Affiche -1

### `<>` (Indice 27)
- **Signature :** `( n1 n2 -- flag )`
- **Explication :** Empile `-1` (Vrai) si `n1 != n2`, sinon `0` (Faux).
- **Exemple Forth :** `5 6 <> .` \ Affiche -1

### `0=` (Indice 28)
- **Signature :** `( n -- flag )`
- **Explication :** Empile `-1` si `n == 0`, sinon `0`. Équivalent au `NOT` logique Forth.
- **Exemple Forth :** `0 0= .` \ Affiche -1

### `0<` (Indice 29)
- **Signature :** `( n -- flag )`
- **Explication :** Empile `-1` si l'entier `n` est négatif (`n < 0`), sinon `0`.
- **Exemple Forth :** `-5 0< .` \ Affiche -1

### `and` (Indice 30)
- **Signature :** `( n1 n2 -- n3 )`
- **Explication :** Effectue une opération logique ET bit à bit (`n3 = n1 & n2`).
- **Exemple Forth :** `0x0F 0xFF and .` \ Affiche 15

### `or` (Indice 31)
- **Signature :** `( n1 n2 -- n3 )`
- **Explication :** Effectue une opération logique OU bit à bit (`n3 = n1 | n2`).
- **Exemple Forth :** `0xF0 0x0F or .` \ Affiche 255

### `xor` (Indice 32)
- **Signature :** `( n1 n2 -- n3 )`
- **Explication :** Effectue une opération logique OU Exclusif (XOR) bit à bit (`n3 = n1 ^ n2`).
- **Exemple Forth :** `0xAA 0xFF xor .`

### `not` (Indice 33)
- **Signature :** `( n1 -- n2 )`
- **Explication :** Inverse l'intégralité des bits de l'entier (`n2 = ~n1`).
- **Exemple Forth :** `0 not .` \ Affiche -1

### `lshift` (Indice 34)
- **Signature :** `( n bits -- n2 )`
- **Explication :** Decale l'entier `n` vers la gauche de `bits` positions (`n2 = n << bits`).
- **Exemple Forth :** `1 4 lshift .` \ Affiche 16

### `rshift` (Indice 35)
- **Signature :** `( n bits -- n2 )`
- **Explication :** Decale l'entier non signé `n` vers la droite de `bits` positions (`n2 = n >> bits`).
- **Exemple Forth :** `16 4 rshift .` \ Affiche 1

---

## 2. CONSOLE, ENTRÉES/SORTIES & PORTS HARDWARE (50-99)

### `.` (Indice 50)
- **Signature :** `( n -- )`
- **Explication :** Affiche la représentation décimale signée de l'entier `n` sur la console, suivie d'un espace.
- **Exemple Forth :** `1234 .`

### `emit` (Indice 51)
- **Signature :** `( char -- )`
- **Explication :** Affiche le caractère ASCII correspondant au code numérique `char`.
- **Exemple Forth :** `65 emit` \ Affiche 'A'

### `cr` (Indice 52)
- **Signature :** `( -- )`
- **Explication :** Émet un saut de ligne (Carriage Return / Line Feed) sur la console du terminal.
- **Exemple Forth :** `cr`

### `space` (Indice 53)
- **Signature :** `( -- )`
- **Explication :** Émet un espace unique (ASCII 32) sur la console.
- **Exemple Forth :** `space`

### `spaces` (Indice 54)
- **Signature :** `( n -- )`
- **Explication :** Émet `n` espaces consécutifs sur la console.
- **Exemple Forth :** `10 spaces`

### `type` (Indice 55)
- **Signature :** `( addr len -- )`
- **Explication :** Lit et affiche une séquence de `len` octets ASCII depuis la mémoire à l'adresse `addr`.
- **Exemple Forth :** `s" Bonjour Epona OS" type`

### `page` (Indice 56)
- **Signature :** `( -- )`
- **Explication :** Efface l'intégralité de l'écran console et réinitialise le curseur en haut à gauche `(0, 0)`.
- **Exemple Forth :** `page`

### `key` (Indice 57)
- **Signature :** `( -- char )`
- **Explication :** Bloque le processus jusqu'à la frappe d'une touche au clavier et empile le code ASCII de la touche.
- **Exemple Forth :** `key .`

### `key?` (Indice 58)
- **Signature :** `( -- flag )`
- **Explication :** Interroge le buffer clavier sans bloquer. Empile `-1` si une touche est disponible, sinon `0`.
- **Exemple Forth :** `key? if key . then`

### `inb` (Indice 60)
- **Signature :** `( port -- byte )`
- **Explication :** Exécute l'instruction d'assemblage x86 `in al, dx` pour lire un octet sur le port I/O matériel `port`.
- **Exemple Forth :** `0x3F8 inb .` \ Lit le registre de statut du port Série UART

### `outb` (Indice 61)
- **Signature :** `( byte port -- )`
- **Explication :** Exécute l'instruction x86 `out dx, al` pour écrire l'octet `byte` sur le port I/O matériel `port`.
- **Exemple Forth :** `0x20 0x20 outb` \ Envoie EOI au contrôleur PIC 8259

### `inw` (Indice 62)
- **Signature :** `( port -- word )`
- **Explication :** Lit un mot de 16 bits (Word) sur le port I/O x86 `port` (`in ax, dx`).
- **Exemple Forth :** `0x1F0 inw`

### `outw` (Indice 63)
- **Signature :** `( word port -- )`
- **Explication :** Écrit un mot de 16 bits sur le port I/O `port` (`out dx, ax`).
- **Exemple Forth :** `0x0000 0x1F0 outw`

### `inl` (Indice 64)
- **Signature :** `( port -- dword )`
- **Explication :** Lit un double-mot de 32 bits (DWord) sur le port I/O x86 `port` (`in eax, dx`).
- **Exemple Forth :** `0xCF8 inl` \ Lit le registre d'adresse PCI Config

### `outl` (Indice 65)
- **Signature :** `( dword port -- )`
- **Explication :** Écrit un double-mot 32 bits sur le port I/O x86 `port` (`out dx, eax`).
- **Exemple Forth :** `0x80000000 0xCF8 outl` \ Écrit dans le registre d'adresse PCI

### `rdtsc` (Indice 70)
- **Signature :** `( -- low high )`
- **Explication :** Exécute l'instruction x86 `rdtsc` et retourne le compteur de cycles horloge processeur (64 bits découpés en low et high).
- **Exemple Forth :** `rdtsc drop .` \ Mesure la fréquence / ticks processeur

---

## 3. ACCÈS BUS PCI, MÉMOIRE MMIO & COMPILATEUR JIT (100-199)

### `pci-read` (Indice 100)
- **Signature :** `( bus dev func offset -- val )`
- **Explication :** Interroge l'espace de configuration PCI 32-bit pour le périphérique spécifié et retourne la valeur du registre `offset`.
- **Exemple Forth :** `0 0 0 0 pci-read .` \ Lit le Vendor/Device ID du pont PCI Hôte

### `pci-write` (Indice 101)
- **Signature :** `( val bus dev func offset -- )`
- **Explication :** Écrit la valeur 32-bit `val` dans l'espace de configuration PCI du périphérique.
- **Exemple Forth :** `0xFFFFFFFF 0 2 0 0x10 pci-write`

### `pci-scan` (Indice 102)
- **Signature :** `( -- count )`
- **Explication :** Déclenche un balayage complet du bus PCI de la machine hôte et retourne le nombre total de périphériques découverts.
- **Exemple Forth :** `pci-scan . ." peripheriques PCI trouves." cr`

### `mmio-read32` (Indice 110)
- **Signature :** `( addr -- val )`
- **Explication :** Lit directement une valeur 32-bit en mémoire mappée matériel (MMIO) à l'adresse physique `addr`.
- **Exemple Forth :** `0xF0000000 mmio-read32 .`

### `mmio-write32` (Indice 111)
- **Signature :** `( val addr -- )`
- **Explication :** Écrit une valeur 32-bit dans un registre mémoire MMIO d'un composant matériel (ex. carte réseau, GPU).
- **Exemple Forth :** `0x01 0xF0000004 mmio-write32`

### `alloc-mem` (Indice 120)
- **Signature :** `( size -- addr )`
- **Explication :** Fait appel à l'allocateur Heap Rust du noyau pour réserver un bloc mémoire contigu de `size` octets. Retourne l'adresse `addr`.
- **Exemple Forth :** `4096 alloc-mem` \ Reserve 4 KB

### `free-mem` (Indice 121)
- **Signature :** `( addr -- )`
- **Explication :** Libère un bloc mémoire précédemment alloué via `alloc-mem`.
- **Exemple Forth :** `buffer-ptr free-mem`

### `compile-jit` (Indice 130)
- **Signature :** `( xt -- )`
- **Explication :** Passe le mot Forth `xt` dans le compilateur JIT ([jit.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/jit.rs)) pour traduire son bytecode en instructions natives x86-64 exécutables.
- **Exemple Forth :** `' mon-calcul-lourd compile-jit`

---

## 4. PILE RÉSEAU TCP/IP & SERVICES (200-229)

### `net:init` (Indice 200)
- **Signature :** `( -- ok? )`
- **Explication :** Initialise l'interface réseau (Intel E1000 ou Realtek RTL8168), lance le client DHCP pour récupérer une IP et prépare la stack TCP/IP ([net_stack.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/net_stack.rs)).
- **Exemple Forth :** `net:init if ." Reseau Pret" else ." Echec Reseau" then cr`

### `net:ip` (Indice 201)
- **Signature :** `( -- ip_u32 )`
- **Explication :** Retourne l'adresse IPv4 locale de la machine sous forme d'entier 32 bits non signé.
- **Exemple Forth :** `net:ip .`

### `net:ping` (Indice 202)
- **Signature :** `( ip1 ip2 ip3 ip4 -- ms )`
- **Explication :** Formate un paquet ICMP Echo Request vers l'adresse IP spécifiée et calcule la latence aller-retour en millisecondes.
- **Exemple Forth :** `8 8 8 8 net:ping . ." ms" cr` \ Ping Google DNS

### `net:udp-send` (Indice 210)
- **Signature :** `( ip_u32 port buf len -- ok? )`
- **Explication :** Émet un datagramme UDP contenant `len` octets depuis la zone mémoire `buf` vers l'IP et le port cibles.
- **Exemple Forth :** `dest-ip 5353 buf len net:udp-send`

### `net:udp-recv` (Indice 211)
- **Signature :** `( port buf max_len -- actual )`
- **Explication :** Écoute sur le port UDP local spécifié et remplit le tampon `buf`. Retourne la taille réelle reçue.
- **Exemple Forth :** `5353 rx-buf 512 net:udp-recv`

### `net:tcp-connect` (Indice 220)
- **Signature :** `( ip_u32 port -- socket_fd )`
- **Explication :** Effectue le Handshake TCP 3-voies (SYN, SYN-ACK, ACK) vers un serveur distant et retourne un handle de socket.
- **Exemple Forth :** `server-ip 80 net:tcp-connect`

### `net:tcp-send` (Indice 221)
- **Signature :** `( socket_fd buf len -- ok? )`
- **Explication :** Transmet des données fiables sur une connexion TCP établie.
- **Exemple Forth :** `sock req-buf req-len net:tcp-send`

### `net:tcp-recv` (Indice 222)
- **Signature :** `( socket_fd buf max_len -- actual )`
- **Explication :** Lit les données arrivant sur le socket TCP et les dépose dans le tampon.
- **Exemple Forth :** `sock rx-buf 1024 net:tcp-recv`

---

## 5. GPU MULTI-ÉCRAN, USB & FICHIERS FAT32 (230-289)

### `gpu:mode` (Indice 230)
- **Signature :** `( w h bpp -- ok? )`
- **Explication :** Tente de modifier la résolution d'affichage du contrôleur graphique (GOP UEFI / GPU i915 / AMDGPU) aux dimensions désignées.
- **Exemple Forth :** `1920 1080 32 gpu:mode`

### `gpu:fb` (Indice 231)
- **Signature :** `( -- fb_addr stride w h )`
- **Explication :** Retourne le pointeur mémoire du Framebuffer principal, le stride (pas de balayage), la largeur et la hauteur en pixels.
- **Exemple Forth :** `gpu:fb . . . .`

### `usb:scan` (Indice 240)
- **Signature :** `( -- count )`
- **Explication :** Interroge le contrôleur hôte USB 3.0 XHCI ([xhci.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/xhci.rs)) et retourne le nombre de périphériques USB connectés.
- **Exemple Forth :** `usb:scan . ." peripheriques USB vus." cr`

### `usb:read-sector` (Indice 241)
- **Signature :** `( lba buf -- ok? )`
- **Explication :** Transmet un paquet SCSI Read(10) via le protocole USB Mass Storage ([usb_msd.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/usb_msd.rs)) pour lire un secteur LBA 512 octets de la clé USB.
- **Exemple Forth :** `0 sector-buf usb:read-sector`

### `fat:open` (Indice 250)
- **Signature :** `( path_addr len -- handle )`
- **Explication :** Ouvre directement un fichier sur la partition FAT32 de la clé USB bootable.
- **Exemple Forth :** `s" /BOOT.FTH" fat:open`

### `fat:read` (Indice 251)
- **Signature :** `( handle buf count -- actual )`
- **Explication :** Lit les clusters de la clé USB FAT32 et remplit le tampon mémoire.
- **Exemple Forth :** `file-h rx-buf 512 fat:read`

### `fat:write` (Indice 252)
- **Signature :** `( handle buf count -- actual )`
- **Explication :** Allocation de nouveaux clusters et écriture sur la clé USB FAT32.
- **Exemple Forth :** `file-h tx-buf 128 fat:write`

---

## 6. MULTITÂCHE & SCHEDULER V2 (410-419)

### `process-create` (Indice 410)
- **Signature :** `( name_addr len -- pid )`
- **Explication :** Crée un nouveau processus indépendant dans l'ordonnateur préemptif ([scheduler_v2.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/scheduler_v2.rs)), alloue sa pile et son contexte `CpuContext`.
- **Exemple Forth :** `s" TacheArrierePlan" process-create .`

### `process-kill` (Indice 411)
- **Signature :** `( pid -- )`
- **Explication :** Interrompt et détruit le processus spécifié par son PID, libérant ses ressources mémoire et descripteurs.
- **Exemple Forth :** `target-pid process-kill`

### `process-list` (Indice 412)
- **Signature :** `( -- )`
- **Explication :** Imprime le tableau récapitulatif des processus en cours d'exécution (PID, Nom, État, Priorité, Utilisation CPU).
- **Exemple Forth :** `process-list`

### `getpid` (Indice 414)
- **Signature :** `( -- pid )`
- **Explication :** Empile le PID numérique du processus en cours d'exécution.
- **Exemple Forth :** `getpid .`

### `yield` (Indice 415)
- **Signature :** `( -- )`
- **Explication :** Abandonne volontairement le reste du quantum de temps processeur du processus et déclenche un changement de contexte vers le processus suivant.
- **Exemple Forth :** `yield`

### `sleep` (Indice 416)
- **Signature :** `( ms -- )`
- **Explication :** Place le processus dans l'état `Blocked(Sleeping)` pendant au moins `ms` millisecondes.
- **Exemple Forth :** `500 sleep` \ Mettre en pause pendant 500 ms

---

## 7. SYSTÈME DE FICHIERS VIRTUEL (VFS V2) (420-449)

### `open` (Indice 420)
- **Signature :** `( path_addr len flags -- fd )`
- **Explication :** Ouvre un fichier ou périphérique sur l'arborescence VFS ([vfs_v2.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/vfs_v2.rs)) (`/`, `/usb/`, `/dev/`, `/proc/`, `/tmp/`).
- **Exemple Forth :** `s" /proc/cpuinfo" 0 open`

### `close` (Indice 421)
- **Signature :** `( fd -- )`
- **Explication :** Ferme le descripteur de fichier VFS `fd`.
- **Exemple Forth :** `fd close`

### `read` (Indice 422)
- **Signature :** `( fd buf_addr count -- actual )`
- **Explication :** Lit jusqu'à `count` octets depuis le nœud VFS référencé par `fd`.
- **Exemple Forth :** `fd buf-addr 256 read`

### `write` (Indice 423)
- **Signature :** `( fd buf_addr count -- actual )`
- **Explication :** Écrit `count` octets dans le fichier ou le périphérique VFS.
- **Exemple Forth :** `fd log-buf 64 write`

### `seek` (Indice 424)
- **Signature :** `( fd pos whence -- new_pos )`
- **Explication :** Modifie la position de lecture/écriture du fichier VFS (`whence` : 0=SEEK_SET, 1=SEEK_CUR, 2=SEEK_END).
- **Exemple Forth :** `fd 0 0 seek` \ Retour au début du fichier

### `stat` (Indice 425)
- **Signature :** `( path_addr len -- size type )`
- **Explication :** Interroge le VFS pour obtenir la taille en octets et le type d'élément (Fichier, Répertoire, Dev).
- **Exemple Forth :** `s" /BOOT.FTH" stat . .`

### `readdir` (Indice 426)
- **Signature :** `( fd buf_addr -- count )`
- **Explication :** Lit les entrées de répertoire du dossier ouvert dans VFS.
- **Exemple Forth :** `dir-fd buf-addr readdir`

### `mkdir` (Indice 427)
- **Signature :** `( path_addr len -- ok? )`
- **Explication :** Crée un nouveau répertoire sur le VFS.
- **Exemple Forth :** `s" /usb/sauvegarde" mkdir`

---

## 8. GESTIONNAIRE DE FENÊTRES (WINDOW MANAGER GUI) (500-529)

### `win:create` (Indice 500)
- **Signature :** `( x y w h title_addr len flags -- wid )`
- **Explication :** Déclare et crée une nouvelle fenêtre graphique auprès du gestionnaire de fenêtres ([window_manager.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/window_manager.rs)).
- **Exemple Forth :** `100 100 500 400 s" Terminal Forth" 0 win:create`

### `win:destroy` (Indice 501)
- **Signature :** `( wid -- )`
- **Explication :** Ferme et détruit la fenêtre `wid`, libérant son tampon d'affichage et son enregistrement dans la liste des z-orders.
- **Exemple Forth :** `wid win:destroy`

### `win:move` (Indice 502)
- **Signature :** `( wid x y -- )`
- **Explication :** Re-positionne le coin supérieur gauche de la fenêtre aux coordonnées écran `(x, y)`.
- **Exemple Forth :** `wid 200 150 win:move`

### `win:resize` (Indice 503)
- **Signature :** `( wid w h -- )`
- **Explication :** Modifie la largeur `w` et la hauteur `h` du tampon de la fenêtre.
- **Exemple Forth :** `wid 800 600 win:resize`

### `win:show` (Indice 504)
- **Signature :** `( wid -- )`
- **Explication :** Rendre la fenêtre visible sur le bureau.
- **Exemple Forth :** `wid win:show`

### `win:hide` (Indice 505)
- **Signature :** `( wid -- )`
- **Explication :** Masque la fenêtre sans la détruire.
- **Exemple Forth :** `wid win:hide`

### `win:focus` (Indice 506)
- **Signature :** `( wid -- )`
- **Explication :** Donne le focus actif à la fenêtre et la monte au sommet du z-order.
- **Exemple Forth :** `wid win:focus`

### `win:fb` (Indice 508)
- **Signature :** `( wid -- addr stride w h )`
- **Explication :** Retourne le pointeur du tampon graphique interne de la fenêtre `wid` pour autoriser le dessin direct.
- **Exemple Forth :** `wid win:fb`

### `win:flip` (Indice 509)
- **Signature :** `( wid -- )`
- **Explication :** Copie le tampon graphique de la fenêtre vers le Framebuffer écran principal (Double Buffering).
- **Exemple Forth :** `wid win:flip`

### `win:event` (Indice 510)
- **Signature :** `( wid -- type x y key )`
- **Explication :** Dépile le prochain événement utilisateur dédié à cette fenêtre (Clics souris, déplacements, frappes clavier).
- **Exemple Forth :** `wid win:event`

---

## 9. DESSIN AVANCÉ & FORMES GRAPHIQUES 2D (530-575)

### `gfx:circle` (Indice 530)
- **Signature :** `( cx cy r color -- )`
- **Explication :** Dessine le contour d'un cercle de rayon `r` centré sur `(cx, cy)` avec la couleur ARGB 32 bits `color`.
- **Exemple Forth :** `250 250 80 0xFFFF0000 gfx:circle` \ Cercle Rouge

### `gfx:fill-circle` (Indice 531)
- **Signature :** `( cx cy r color -- )`
- **Explication :** Rempli la surface complète d'un cercle avec la couleur spécifiée.
- **Exemple Forth :** `250 250 80 0xFF00FF00 gfx:fill-circle` \ Cercle Vert Plein

### `gfx:ellipse` (Indice 532)
- **Signature :** `( cx cy rx ry color -- )`
- **Explication :** Dessine le contour d'une ellipse définie par ses demi-axes `rx` et `ry`.
- **Exemple Forth :** `300 200 100 50 0xFF0000FF gfx:ellipse`

### `gfx:gradient` (Indice 536)
- **Signature :** `( x y w h c1 c2 direction -- )`
- **Explication :** Dessine un rectangle ombré avec un dégradé progressif entre la couleur `c1` et `c2` (direction 0 = Horizontal, 1 = Vertical).
- **Exemple Forth :** `0 0 400 300 0xFF000000 0xFF444444 1 gfx:gradient`

### `gfx:alpha-blend` (Indice 537)
- **Signature :** `( x y w h src_addr alpha -- )`
- **Explication :** Copie une zone d'image rectangulaire en appliquant un niveau de transparence globale `alpha` (0 = transparent, 255 = opaque).
- **Exemple Forth :** `50 50 200 200 img-buf 128 gfx:alpha-blend`

### `gfx:sprite-load` (Indice 540)
- **Signature :** `( addr w h -- sprite_id )`
- **Explication :** Enregistre une matrice de pixels comme sprite 2D réutilisable et retourne son identifiant `sprite_id`.
- **Exemple Forth :** `pixels-addr 32 32 gfx:sprite-load`

### `gfx:sprite-draw` (Indice 541)
- **Signature :** `( sprite_id x y -- )`
- **Explication :** Affiche le sprite spécifié par son `sprite_id` aux coordonnées `(x, y)`.
- **Exemple Forth :** `my-sprite 120 80 gfx:sprite-draw`

### `gfx:image-decode` (Indice 545)
- **Signature :** `( addr len -- img_id w h )`
- **Explication :** Transmet un fichier d'image brut en mémoire (BMP, TGA, PNG) au décodeur du noyau ([image.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/image.rs)) et retourne son ID.
- **Exemple Forth :** `file-buf file-size gfx:image-decode`

### `gfx:image-draw` (Indice 546)
- **Signature :** `( img_id x y -- )`
- **Explication :** Affiche l'image décodée sur le tampon graphique.
- **Exemple Forth :** `my-img 0 0 gfx:image-draw`

---

## 10. FLOTTANTS IEEE 754 SSE2 (900-944)

### `f+` (Indice 900)
- **Signature :** `( f1 f2 -- f3 )`
- **Explication :** Additionne deux flottants 64-bit IEEE 754 via l'instruction x86-64 SSE2 `addsd`.
- **Exemple Forth :** `3.14 2.00 f+ f.` \ Affiche 5.140000

### `f-` (Indice 901)
- **Signature :** `( f1 f2 -- f3 )`
- **Explication :** Soustrait `f2` de `f1` via l'instruction SSE2 `subsd`.
- **Exemple Forth :** `10.5 0.5 f- f.` \ Affiche 10.000000

### `f*` (Indice 902)
- **Signature :** `( f1 f2 -- f3 )`
- **Explication :** Multiplie deux flottants via l'instruction SSE2 `mulsd`.
- **Exemple Forth :** `2.5 4.0 f* f.` \ Affiche 10.000000

### `f/` (Indice 903)
- **Signature :** `( f1 f2 -- f3 )`
- **Explication :** Divise `f1` par `f2` via l'instruction SSE2 `divsd`.
- **Exemple Forth :** `1.0 2.0 f/ f.` \ Affiche 0.500000

### `f.` (Indice 904)
- **Signature :** `( f -- )`
- **Explication :** Affiche le nombre flottant au sommet de la pile avec une précision par défaut de 6 chiffres après la virgule.
- **Exemple Forth :** `3.14159265 f.`

### `f<` (Indice 905)
- **Signature :** `( f1 f2 -- flag )`
- **Explication :** Empile `-1` si `f1 < f2` via la comparaison SSE2 `ucomisd`, sinon `0`.
- **Exemple Forth :** `1.5 2.5 f< .` \ Affiche -1

### `f>` (Indice 906)
- **Signature :** `( f1 f2 -- flag )`
- **Explication :** Empile `-1` si `f1 > f2`, sinon `0`.
- **Exemple Forth :** `2.5 1.5 f> .` \ Affiche -1

### `f=` (Indice 907)
- **Signature :** `( f1 f2 -- flag )`
- **Explication :** Empile `-1` si `f1 == f2`, sinon `0`.
- **Exemple Forth :** `2.5 2.5 f= .` \ Affiche -1

### `f<=` (Indice 908)
- **Signature :** `( f1 f2 -- flag )`
- **Explication :** Empile `-1` si `f1 <= f2`, sinon `0`.
- **Exemple Forth :** `2.5 2.5 f<= .` \ Affiche -1

### `f>=` (Indice 909)
- **Signature :** `( f1 f2 -- flag )`
- **Explication :** Empile `-1` si `f1 >= f2`, sinon `0`.
- **Exemple Forth :** `3.0 2.5 f>= .` \ Affiche -1

### `f0=` (Indice 910)
- **Signature :** `( f -- flag )`
- **Explication :** Empile `-1` si le flottant est égal à `0.0`, sinon `0`.
- **Exemple Forth :** `0.0 f0= .` \ Affiche -1

### `f0<` (Indice 911)
- **Signature :** `( f -- flag )`
- **Explication :** Empile `-1` si le flottant est strictement négatif (`f < 0.0`), sinon `0`.
- **Exemple Forth :** `-3.14 f0< .` \ Affiche -1

### `fnegate` (Indice 912)
- **Signature :** `( f -- -f )`
- **Explication :** Invoque l'instruction SSE2 `xorpd` avec un masque de bit de signe pour inverser le signe du flottant.
- **Exemple Forth :** `3.14 fnegate f.` \ Affiche -3.140000

### `fabs` (Indice 913)
- **Signature :** `( f -- |f| )`
- **Explication :** Applique l'instruction SSE2 `andpd` pour forcer le bit de signe à `0` (valeur absolue).
- **Exemple Forth :** `-15.75 fabs f.` \ Affiche 15.750000

### `fmin` (Indice 914)
- **Signature :** `( f1 f2 -- f )`
- **Explication :** Conserve le plus petit des deux flottants via l'instruction SSE2 `minsd`.
- **Exemple Forth :** `10.5 4.2 fmin f.` \ Affiche 4.200000

### `fmax` (Indice 915)
- **Signature :** `( f1 f2 -- f )`
- **Explication :** Conserve le plus grand des deux flottants via l'instruction SSE2 `maxsd`.
- **Exemple Forth :** `10.5 4.2 fmax f.` \ Affiche 10.500000

### `fsqrt` (Indice 916)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule la racine carrée flottante directe via l'instruction assembleur SSE2 `sqrtsd`.
- **Exemple Forth :** `16.0 fsqrt f.` \ Affiche 4.000000

### `fsin` (Indice 917)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule le sinus de l'angle `f` (exprimé en radians).
- **Exemple Forth :** `0.0 fsin f.` \ Affiche 0.000000

### `fcos` (Indice 918)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule le cosinus de l'angle `f` (exprimé en radians).
- **Exemple Forth :** `0.0 fcos f.` \ Affiche 1.000000

### `ftan` (Indice 919)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule la tangente de l'angle `f` (radians).
- **Exemple Forth :** `0.785398 ftan f.` \ Affiche 1.000000

### `fatan2` (Indice 920)
- **Signature :** `( fy fx -- f )`
- **Explication :** Calcule l'arc tangente de `fy / fx` en gérant les 4 quadrants géométriques.
- **Exemple Forth :** `1.0 1.0 fatan2 f.`

### `fexp` (Indice 921)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule la fonction exponentielle `e^f`.
- **Exemple Forth :** `1.0 fexp f.` \ Affiche 2.718281

### `fln` (Indice 922)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule le logarithme népérien `ln(f)` pour `f > 0`.
- **Exemple Forth :** `2.718281828 fln f.` \ Affiche 1.000000

### `flog2` (Indice 923)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule le logarithme en base 2 `log2(f)`.
- **Exemple Forth :** `8.0 flog2 f.` \ Affiche 3.000000

### `fpow` (Indice 924)
- **Signature :** `( base exp -- f )`
- **Explication :** Élève la `base` à la puissance `exp` (`base^exp`).
- **Exemple Forth :** `2.0 3.0 fpow f.` \ Affiche 8.000000

### `ffloor` (Indice 925)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule l'arrondi entier inférieur (`floor`).
- **Exemple Forth :** `3.9 ffloor f.` \ Affiche 3.000000

### `fceil` (Indice 926)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule l'arrondi entier supérieur (`ceil`).
- **Exemple Forth :** `3.1 fceil f.` \ Affiche 4.000000

### `fround` (Indice 927)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule l'arrondi au nombre entier le plus proche.
- **Exemple Forth :** `3.5 fround f.` \ Affiche 4.000000

### `f>i` (Indice 928)
- **Signature :** `( f -- n )`
- **Explication :** Convertit le nombre flottant 64 bits en un entier signé 64 bits (`i64`) via `cvttsd2si`.
- **Exemple Forth :** `15.85 f>i .` \ Affiche 15

### `i>f` (Indice 929)
- **Signature :** `( n -- f )`
- **Explication :** Convertit l'entier signé 64 bits `i64` en nombre flottant via `cvtsi2sd`.
- **Exemple Forth :** `42 i>f f.` \ Affiche 42.000000

### `f>s` (Indice 930)
- **Signature :** `( f buf_addr -- len )`
- **Explication :** Convertit le nombre flottant en sa représentation ASCII décimale écrite dans `buf_addr` et retourne la longueur de la chaîne.
- **Exemple Forth :** `3.14159 buf-addr f>s`

### `s>f` (Indice 931)
- **Signature :** `( addr len -- f )`
- **Explication :** Parse une chaîne de caractères ASCII représentative d'un nombre décimal et empile le flottant correspondant.
- **Exemple Forth :** `s" 123.456" s>f f.`

### `fpi` (Indice 932)
- **Signature :** `( -- pi )`
- **Explication :** Empile la constante mathématique π (`3.141592653589793`).
- **Exemple Forth :** `fpi f.`

### `fe` (Indice 933)
- **Signature :** `( -- e )`
- **Explication :** Empile la constante d'Euler `e` (`2.718281828459045`).
- **Exemple Forth :** `fe f.`

### `fdup` (Indice 935)
- **Signature :** `( f -- f f )`
- **Explication :** Duplique le nombre flottant au sommet de la pile (alias sémantique de `dup`).
- **Exemple Forth :** `3.14 fdup`

### `fdrop` (Indice 936)
- **Signature :** `( f -- )`
- **Explication :** Supprime le nombre flottant au sommet de la pile (alias de `drop`).
- **Exemple Forth :** `3.14 fdrop`

### `fswap` (Indice 937)
- **Signature :** `( f1 f2 -- f2 f1 )`
- **Explication :** Échange les positions des deux nombres flottants supérieurs (alias de `swap`).
- **Exemple Forth :** `1.0 2.0 fswap`

### `fover` (Indice 938)
- **Signature :** `( f1 f2 -- f1 f2 f1 )`
- **Explication :** Copie le deuxième flottant au sommet de la pile (alias de `over`).
- **Exemple Forth :** `1.0 2.0 fover`

### `frot` (Indice 939)
- **Signature :** `( f1 f2 f3 -- f2 f3 f1 )`
- **Explication :** Effectue une rotation des trois flottants supérieurs (alias de `rot`).
- **Exemple Forth :** `1.0 2.0 3.0 frot`

### `f!` (Indice 940)
- **Signature :** `( f addr -- )`
- **Explication :** Écrit le motif 64 bits du flottant `f` à l'adresse mémoire `addr`.
- **Exemple Forth :** `3.14159 var-f-addr f!`

### `f@` (Indice 941)
- **Signature :** `( addr -- f )`
- **Explication :** Lit une valeur 64 bits en mémoire à l'adresse `addr` et la dépose comme flottant sur la pile.
- **Exemple Forth :** `var-f-addr f@ f.`

### `fhypot` (Indice 942)
- **Signature :** `( fx fy -- f )`
- **Explication :** Calcule la longueur de l'hypoténuse `sqrt(fx² + fy²)` sans risque de dépassement de capacité intermédiaire.
- **Exemple Forth :** `3.0 4.0 fhypot f.` \ Affiche 5.000000

### `fasin` (Indice 943)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule l'arc sinus de `f` (domaine `[-1.0, 1.0]`, résultat en radians).
- **Exemple Forth :** `1.0 fasin f.`

### `facos` (Indice 944)
- **Signature :** `( f -- f2 )`
- **Explication :** Calcule l'arc cosinus de `f` (domaine `[-1.0, 1.0]`, résultat en radians).
- **Exemple Forth :** `1.0 facos f.` \ Affiche 0.000000

---

## 11. PLAN DE VALIDATION D'ICI FIN AOÛT 2026

En complétant l'ensemble des 7 Guides de Développement (`DEV_GUIDE_*.md`) d'ici la **fin Août 2026**, le fichier **[DEVFORTH.MD](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/DEVFORTH.MD)** sert d'encyclopédie de référence exhaustive pour valider :
1. L'alignement 64-bit et l'absence de conflit d'indexation de chaque primitive.
2. La compatibilité avec les scripts d'extension Forth de la communauté (`forth/drivers/`, `forth/apps/`).
3. La génération correcte d'instructions x86-64 natives par le compilateur JIT ([jit.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/jit.rs)) pour le lancement de la Release v1.98 en Septembre 2026.

---

*Fin du document DEVFORTH.MD — Encyclopédie explicative des primitives Epona OS.*
