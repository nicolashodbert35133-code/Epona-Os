# Epona OS 2.0 — Référence Complète

## PRIMITIVES FORTH (interpreter.rs)

### Groupe 0 : Arithmétique et Pile (indices 0–99)

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 0 | `+` | `( a b -- sum )` | Addition |
| 1 | `-` | `( a b -- diff )` | Soustraction |
| 2 | `*` | `( a b -- prod )` | Multiplication |
| 3 | `/` | `( a b -- quot )` | Division entière |
| 4 | `mod` | `( a b -- rem )` | Modulo |
| 5 | `dup` | `( a -- a a )` | Duplique le sommet |
| 6 | `drop` | `( a -- )` | Supprime le sommet |
| 7 | `swap` | `( a b -- b a )` | Échange les 2 sommets |
| 8 | `over` | `( a b -- a b a )` | Copie l'avant-dernier |
| 9 | `rot` | `( a b c -- b c a )` | Rotation |
| 10 | `@` | `( addr -- val )` | Lecture 64-bit mémoire |
| 11 | `!` | `( val addr -- )` | Écriture 64-bit mémoire |
| 12 | `pixel` | `( x y color -- )` | Dessine un pixel (obsolète, utiliser fb:pixel) |
| 13 | `rect` | `( x y w h color -- )` | Dessine un rectangle (obsolète) |
| 14 | `ligne` | `( x1 y1 x2 y2 color -- )` | Dessine une ligne (obsolète) |
| 15 | `effacer` | `( -- )` | Efface l'écran |
| 16 | `couleur` | `( color -- )` | Définit la couleur courante |
| 17 | `touche` | `( -- char )` | Lecture clavier bloquante |
| 18 | `touche?` | `( -- flag )` | Test clavier non-bloquant |
| 19 | `souris` | `( -- mx my btn )` | Lit position souris et boutons |
| 20 | `ms` / `attendre` | `( n -- )` | Attend n millisecondes |
| 21 | `hasard` | `( max -- val )` | Nombre aléatoire [0..max) |
| 22 | `.` | `( n -- )` | Affiche un entier |
| 23 | `mmio@` | `( addr -- val )` | Lecture MMIO 32-bit |
| 24 | `mmio!` | `( val addr -- )` | Écriture MMIO 32-bit |
| 25 | `i2c.probe` | `( base -- )` | Probe I2C DesignWare |
| 26 | `sys:drivers` | `( -- )` | Liste pilotes système |
| 27 | `sys:probe` | `( -- )` | Probe matériel |
| 28 | `fb:pixel` | `( x y color -- )` | Dessine un pixel sur le canvas |
| 29 | `fb:rect` | `( x y w h color -- )` | Dessine un rectangle |
| 30 | `fb:line` | `( x1 y1 x2 y2 color -- )` | Dessine une ligne (Bresenham) |
| 31 | `fb:char` | `( x y char color -- )` | Dessine un caractère |
| 32 | `souris?` | `( -- flag )` | 1 si souris matérielle détectée |
| 33 | `dw-i2c-init` | `( base -- ok )` | Init I2C DesignWare |
| 34 | `dw-i2c-probe` | `( base -- )` | Probe périphériques I2C |
| 35 | `cr` | `( -- )` | Nouvelle ligne (retour chariot) |
| 36 | `pile` | `( -- )` | Affiche tout le contenu de la pile |
| 37 | `=` | `( a b -- flag )` | Égalité |
| 38 | `-rot` | `( a b c -- c a b )` | Rotation inverse |
| 39 | `nip` | `( a b -- b )` | Supprime l'avant-dernier |
| 40 | `tuck` | `( a b -- b a b )` | tuck |
| 41 | `2dup` | `( a b -- a b a b )` | Duplique 2 |
| 42 | `2drop` | `( a b -- )` | Supprime 2 |
| 43 | `2swap` | `( a b c d -- c d a b )` | Échange 2 |
| 44 | `2over` | `( a b c d -- a b c d a b )` | Copie 2 |
| 45 | `?dup` | `( a -- a a \| 0 )` | Duplique si non-zéro |
| 46 | `pick` | `( ... n -- ... val )` | Copie n-ième élément |
| 47 | `1+` | `( a -- a+1 )` | Incrémente |
| 48 | `1-` | `( a -- a-1 )` | Décrémente |
| 49 | `2+` | `( a -- a+2 )` | +2 |
| 50 | `2-` | `( a -- a-2 )` | -2 |
| 51 | `2*` | `( a -- a*2 )` | ×2 |
| 52 | `2/` | `( a -- a/2 )` | ÷2 |
| 53 | `abs` | `( a -- \|a\| )` | Valeur absolue |
| 54 | `negate` | `( a -- -a )` | Négation |
| 55 | `min` | `( a b -- min )` | Minimum |
| 56 | `max` | `( a b -- max )` | Maximum |
| 57 | `/mod` | `( a b -- rem quot )` | Division + modulo |
| 58 | `<>` | `( a b -- flag )` | Différent |
| 59 | `<` | `( a b -- flag )` | Inférieur |
| 60 | `>` | `( a b -- flag )` | Supérieur |
| 61 | `<=` | `( a b -- flag )` | Inférieur ou égal |
| 62 | `>=` | `( a b -- flag )` | Supérieur ou égal |
| 63 | `0=` | `( a -- flag )` | Égal à zéro |
| 64 | `0<>` | `( a -- flag )` | Différent de zéro |
| 65 | `0<` | `( a -- flag )` | Négatif |
| 66 | `0>` | `( a -- flag )` | Positif |
| 67 | `and` | `( a b -- res )` | ET bit-à-bit |
| 68 | `or` | `( a b -- res )` | OU bit-à-bit |
| 69 | `xor` | `( a b -- res )` | OU exclusif |
| 70 | `invert` | `( a -- ~a )` | NON bit-à-bit |
| 71 | `lshift` | `( a n -- res )` | Décalage gauche |
| 72 | `rshift` | `( a n -- res )` | Décalage droite |
| 73 | `c@` | `( addr -- byte )` | Lecture octet |
| 74 | `c!` | `( byte addr -- )` | Écriture octet |
| 75 | `w@` | `( addr -- half )` | Lecture 16-bit |
| 76 | `w!` | `( half addr -- )` | Écriture 16-bit |
| 77 | `l@` | `( addr -- word )` | Lecture 32-bit |
| 78 | `l!` | `( word addr -- )` | Écriture 32-bit |
| 79 | `fill` | `( addr len val -- )` | Remplit une zone mémoire |
| 80 | `cmove` | `( src dst len -- )` | Copie octets |
| 81 | `space` | `( -- )` | Affiche un espace |
| 82 | `spaces` | `( n -- )` | Affiche n espaces |
| 83 | `emit` | `( char -- )` | Affiche un caractère |
| 84 | `u.` | `( n -- )` | Affiche unsigned |
| 85 | `hex` | `( -- )` | Base 16 |
| 86 | `decimal` | `( -- )` | Base 10 |
| 87 | `inb` | `( port -- val )` | Lecture port I/O 8-bit |
| 88 | `outb` | `( val port -- )` | Écriture port I/O 8-bit |
| 89 | `inw` | `( port -- val )` | Lecture port I/O 16-bit |
| 90 | `outw` | `( val port -- )` | Écriture port I/O 16-bit |
| 91 | `inl` | `( port -- val )` | Lecture port I/O 32-bit |
| 92 | `outl` | `( val port -- )` | Écriture port I/O 32-bit |
| 93 | `pci@` | `( addr -- val )` | Lecture registre PCI |
| 94 | `pci!` | `( val addr -- )` | Écriture registre PCI |
| 95 | `alloc` | `( size -- addr )` | Alloue mémoire |
| 96 | `reboot` | `( -- )` | Redémarre la machine |
| 97 | `poweroff` | `( -- )` | Éteint la machine |
| 98 | `cpuid` | `( eax_in -- eax ebx ecx edx )` | Instruction CPUID |
| 99 | `ticks` | `( -- ticks )` | Lit le compteur PIT |

### Groupe 1 : Pile avancée et compilation (100–119)

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 100 | `state` | `( -- a-addr )` | Adresse d'une cellule (MAX_MEM-2) : 0=interpret, 1=compile ; le tokenizer et `]`/`[`/`:`/`;` lisent/écrivent cette cellule |
| 101 | `]` | `( -- )` | Entre en mode compilation |
| 102 | `execute` | `( xt -- )` | Exécute un mot par son xt |
| 103 | `find` | `( c-addr -- c-addr 0 \| xt 1 \| xt -1 )` | Cherche un mot (chaîne comptée) ; xt = index dictionnaire, 1=non immédiat, -1=immédiat |
| 104 | `literal` | `( n -- )` | [immediate] Compile un littéral |
| 105 | `alloc-phys` | `( pages -- addr )` | Alloue mémoire physique |
| 106 | `free-phys` | `( addr pages -- ok )` | Libère mémoire physique |
| 107 | `stall` | `( us -- )` | Attente microsecondes (spin) |
| 108 | `stall-us` | `( us -- )` | Attente microsecondes (rdtsc) |
| 109 | `irq-handler` | `( dict_idx vector -- )` | Enregistre handler IRQ |
| 110 | `phys@` | `( addr -- val64 )` | Lecture physique 64-bit |
| 111 | `phys!` | `( val64 addr -- )` | Écriture physique 64-bit |
| 112 | `init-idt` | `( -- )` | Initialise l'IDT |
| 113 | `+!` | `( n addr -- )` | Additionne n à l'adresse |
| 114 | `i` | `( -- idx )` | Index de boucle DO/LOOP |
| 115 | `j` | `( -- idx )` | Index boucle imbriquée |
| 116 | `>r` | `( val -- )` | Push vers rstack |
| 117 | `r>` | `( -- val )` | Pop depuis rstack |
| 118 | `r@` | `( -- val )` | Copie sommet rstack |
| 119 | `type` | `( addr len -- )` | Affiche une chaîne |

### Groupe 2 : Hardware et framebuffer (120–199)

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 120 | `mem-map` | `( -- total free )` | Info mémoire |
| 121 | `fb-size` | `( -- w h )` | Taille du framebuffer |
| 122 | `fb-swap` | `( -- )` | Copie le canvas vers le framebuffer |
| 123 | `rdtsc` | `( -- tsc )` | Lit le compteur TSC |
| 124 | `get-time` | `( -- sec min hour day month year )` | Heure système |
| 125 | `set-time` | `( year month day hour min sec -- )` | Règle l'heure |
| 126 | `pci-scan` | `( -- count )` | Scan PCI |
| 127 | `pci-dev` | `( idx -- bus dev func class vid did )` | Infos device PCI |
| 128 | `pci-name` | `( class sub -- addr len )` | Nom du device PCI |
| 129 | `msr@` | `( ecx -- edx eax )` | Lecture MSR |
| 130 | `msr!` | `( edx eax ecx -- )` | Écriture MSR |
| 131 | `i2c-read` | `( base dev reg -- val )` | Lecture I2C |
| 132 | `usb-scan` | `( -- count )` | Scan périphériques USB |
| 133 | `smbios-entry` | `( -- addr )` | Pointeur SMBIOS |
| 134 | `smbios-info` | `( -- )` | Info SMBIOS |
| 135 | `acpi-rsdp` | `( -- addr )` | Pointeur RSDP ACPI |
| 136 | `acpi-find` | `( sig -- addr )` | Cherche table ACPI |
| 137 | `acpi-hdr` | `( addr -- )` | Affiche en-tête ACPI |
| 138 | `acpi-tables` | `( -- )` | Liste tables ACPI |
| 139 | `pci-bar` | `( bus dev func bar -- addr )` | Lit BAR PCI |
| 140 | `cfg-tables` | `( -- )` | Liste UEFI config tables |
| 141 | `apic-base` | `( -- addr )` | Adresse LAPIC |
| 142 | `ioapic-read` | `( reg -- val )` | Lecture IOAPIC |
| 143 | `ioapic-write` | `( val reg -- )` | Écriture IOAPIC |
| 144 | `get-var` | `( idx -- val )` | Lit variable globale |
| 145 | `set-var` | `( val idx -- )` | Écrit variable globale |
| 146 | `newedit` | `( -- )` | Éditeur texte intégré |
| 147 | `sys:unregister` | `( "name" -- )` | Désenregistre pilote |
| 148 | `heap-used` | `( -- octets )` | Mémoire heap utilisée |
| 149 | `depth` | `( -- n )` | Profondeur de pile |
| 150 | `.s` | `( -- )` | Affiche la pile sans la vider |
| 151 | `forget` | `( "name" -- )` | Oublie un mot du dictionnaire |
| 152 | `cell+` | `( addr -- addr+1 )` | +1 unité d'adresse (1 cellule = 1 AU, Jour 23) |
| 153 | `cells` | `( n -- n )` | Identité (Jour 23 : 1 cellule = 1 AU) |
| 154 | `aligned` | `( addr -- addr )` | Identité (Jour 23 : alignement = 1) |
| 155 | `char+` | `( addr -- addr+1 )` | +1 unité d'adresse |
| 156 | `chars` | `( n -- n )` | × 1 (1 char = 1 AU) |
| 157 | `beep` | `( freq dur -- )` | Bip PC speaker |
| 158 | `move` | `( src dst len -- )` | Copie mémoire (pointeur natif) |
| 159 | `erase` | `( addr len -- )` | Remplit de zéros (pointeur natif) |
| 160 | `task` | `( "name" -- )` | Crée une tâche Forth |
| 161 | `stop` | `( -- )` | Arrête la tâche courante |
| 162 | `tasks` | `( -- )` | Liste les tâches |
| 163 | `step` | `( -- )` | Exécute une instruction |
| 164 | `trace` | `( -- )` | Active/désactive le trace |
| 165 | `.ops` | `( "name" -- )` | Affiche les ops d'un mot |
| 166 | `widgets-draw` | `( -- )` | Dessine les widgets |
| 167 | `textfield:` | `( "name" -- )` | Crée un champ de texte |
| 168 | `list:` | `( "name" -- )` | Crée une liste |
| 169 | `list-add` | `( "name" "item" -- )` | Ajoute à une liste |
| 170 | `widgets-clear` | `( -- )` | Efface les widgets |
| 171 | `nvme:init` | `( -- ok )` | Init NVMe |
| 172 | `nvme:read` | `( lba count buf -- ok )` | Lecture NVMe |
| 173 | `nvme:write` | `( lba count buf -- ok )` | Écriture NVMe |
| 174 | `nvme:lba-size` | `( -- bytes )` | Taille LBA NVMe |
| 175 | `nvme:total-lbas` | `( -- count )` | Nombre total LBA |
| 176 | `nvme:capacity` | `( -- octets )` | Capacité NVMe |
| 177 | `nvme:info` | `( -- )` | Infos NVMe |
| 178 | `ahci:init` | `( -- ok )` | Init AHCI |
| 179 | `ahci:drives` | `( -- count )` | Nombre disques AHCI |
| 180 | `xhci-init` | `( -- ok )` | Init xHCI (USB) |
| 181 | `xhci-souris` | `( -- dx dy btn )` | Lit delta souris xHCI |
| 182 | `xhci-souris?` | `( -- flag )` | 1 si souris xHCI présente |
| 183 | `usb:init` | `( -- ok )` | Init USB générique |
| 184 | `usb:devices` | `( -- count )` | Nombre devices USB |
| 185 | `usb:control` | `( ... -- ... )` | Transfert control USB |
| 186 | `usb:read` | `( ... -- ... )` | Lecture USB |
| 187 | `usb:write` | `( ... -- ... )` | Écriture USB |
| 188 | `fb:blit` | `( src_x src_y w h dst_x dst_y -- )` | Copie région framebuffer |
| 189 | `hda-init` | `( -- ok )` | Init audio HDA |
| 190 | `hda-play` | `( addr len -- )` | Joue audio HDA |
| 191 | `hda-stop` | `( -- )` | Arrête audio HDA |
| 192 | `hda-volume` | `( vol -- )` | Volume HDA |
| 193 | `hda-info` | `( -- )` | Infos HDA |
| 194 | `hda-beep` | `( freq dur -- )` | Bip HDA |
| 195 | `hda-status` | `( -- )` | Statut HDA |
| 196 | `ahci:read` | `( idx lba count buf -- ok )` | Lecture AHCI |
| 197 | `ahci:write` | `( idx lba count buf -- ok )` | Écriture AHCI |

### Primitives 200+ : Networking

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 200 | `net:init` | `( -- ok )` | Init réseau |
| 201 | `net:mac` | `( -- b5 b4 b3 b2 b1 b0 )` | Adresse MAC |
| 202 | `net:ip` | `( -- d c b a )` | Adresse IP |
| 203 | `net:link-up` | `( -- flag )` | Lien actif |
| 204 | `net:link-speed` | `( -- mbps )` | Vitesse du lien |
| 205 | `net:stats` | `( -- tx rx err )` | Statistiques |
| 206 | `net:phy-read` | `( reg -- val )` | Lecture PHY |
| 207 | `net:phy-write` | `( val reg -- )` | Écriture PHY |
| 208 | `net:tx` | `( addr len -- ok )` | Envoi paquet |
| 209 | `net:rx` | `( buf -- len )` | Réception paquet |
| 210 | `net:poll` | `( -- )` | Poll réseau |
| 211 | `net:arp-table` | `( -- )` | Table ARP |
| 212 | `net:arp-resolve` | `( ip -- mac5..mac0 ok )` | Résolution ARP |
| 213 | `net:udp-send` | `( dst_ip dst_port src_port addr len -- ok )` | Envoi UDP |
| 214 | `net:udp-recv` | `( buf -- len src_ip src_port )` | Réception UDP |
| 215 | `net:ip-addr` | `( a b c d -- )` | Définit IP locale |
| 216 | `net:gateway` | `( a b c d -- )` | Définit passerelle |
| 217 | `net:mask` | `( a b c d -- )` | Définit masque |
| 218 | `net:dhcp` | `( -- ok )` | DHCP discover |
| 219 | `net:poll` | `( -- )` | Poll (doublon) |

### Primitives 220+ : TCP/HTTP/DNS

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 220 | `net:tcp-connect` | `( a b c d port -- sock\|-1 )` | Connexion TCP |
| 221 | `net:tcp-send` | `( sock addr len -- ok )` | Envoi TCP |
| 222 | `net:tcp-recv` | `( sock buf -- len )` | Réception TCP |
| 223 | `net:tcp-close` | `( sock -- )` | Ferme TCP |
| 224 | `net:tcp-listen` | `( port -- sock )` | Écoute TCP |
| 225 | `net:tcp-accept` | `( sock -- client_sock )` | Accepte TCP |
| 226 | `net:tcp-state` | `( sock -- state )` | État TCP |
| 227 | `net:tcp-local` | `( sock -- ip port )` | Info locale TCP |
| 228 | `net:tcp-remote` | `( sock -- ip port )` | Info distante TCP |
| 229 | `net:tcp-buf-size` | `( -- bytes )` | Taille buffer TCP |
| 230 | `dns-resolve` | `( "name" -- ip )` | Résolution DNS |
| 231 | `dns-server` | `( a b c d -- )` | Définit serveur DNS |
| 232 | `http-get` | `( "host" "path" -- addr len ok )` | Requête HTTP GET |
| 233 | `http-post` | `( "host" "path" addr len -- addr resp_len ok )` | Requête HTTP POST |

### Primitives 240+ : GPU / GFX

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 241 | `gpu:resolution` | `( -- w h )` | Résolution écran |
| 242 | `gpu:mode-count` | `( -- count )` | Nombre modes GPU |
| 243 | `gpu:set-mode` | `( w h -- ok )` | Change résolution |
| 244 | `gpu:fill-rect` | `( x y w h color -- )` | Remplit un rectangle |
| 245 | `gpu:draw-text` | `( x y "text" color -- )` | Dessine du texte |
| 246 | `gpu:blit` | `( addr x y w h -- )` | Copie image vers GPU |

### Primitives 250–299 : Strings, Vocab, Mémoire

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 250 | `strcmp` | `( a1 l1 a2 l2 -- flag )` | Compare chaînes |
| 251 | `strcpy` | `( src len dst -- )` | Copie chaîne |
| 252 | `strcat` | `( a1 l1 a2 l2 -- addr len )` | Concatène |
| 253 | `strlen` | `( addr -- len )` | Longueur chaîne |
| 254 | `vocabulary` | `( "name" -- )` | Définit un vocabulaire |
| 255 | `definitions` | `( -- )` | Change vocabulaire courant |
| 260 | `set-mem-bounds` | `( lo hi -- )` | Définit bornes sandbox |
| 261 | `is-dangerous` | `( -- flag )` | 1 si primitive dangereuse |
| 270 | `alloc-page` | `( -- addr )` | Alloue une page 4K |
| 271 | `free-page` | `( addr -- )` | Libère une page |
| 272 | `page-size` | `( -- 4096 )` | Taille d'une page |
| 280 | `inb` | `( port -- val )` | Lecture I/O 8-bit |
| 281 | `outb` | `( val port -- )` | Écriture I/O 8-bit |
| 282 | `inw` | `( port -- val )` | Lecture I/O 16-bit |
| 283 | `outw` | `( val port -- )` | Écriture I/O 16-bit |
| 284 | `inl` | `( port -- val )` | Lecture I/O 32-bit |
| 285 | `outl` | `( val port -- )` | Écriture I/O 32-bit |
| 290 | `count` | `( addr -- addr+1 len )` | Compteur counted string |

### Primitives 300+ : Forth ANS

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 319 | `fm/mod` | `( d n -- rem quot )` | Division floored |
| 320 | `sm/rem` | `( d n -- rem quot )` | Division symétrique |
| 325 | `canvas-resize` | `( w h -- )` | Redimensionne le canvas Forth |
| 326 | `fb-text` | `( x y addr len color scale -- )` | Texte sur canvas |
| 327 | `rect-outline` | `( x y w h color -- )` | Rectangle vide |
| 328 | `source` | `( -- addr len )` | Buffer source courant |
| 329 | `parse-name` | `( "<spaces>name" -- c-addr u )` | Parse le prochain nom (délimiteurs = espaces) ; c-addr pointe dans la source, avance >in |
| 330 | `parse` | `( char "ccc<char>" -- c-addr u )` | Parse depuis >in jusqu'au délimiteur ; champ vide si le délimiteur est le 1er caractère ; c-addr pointe dans la source ; ne modifie pas >in (Jour 20) |
| 331 | `refill` | `( -- flag )` | Lit la ligne suivante ; ligne vide = -1, Escape = 0 |
| 332 | `>in` | `( -- addr )` | Adresse du pointer de parse |

### Primitives 380+ : Forth 2012 (Core + Core Ext, jours 37-52)

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 388 | `base` | `( -- a-addr )` | Adresse de la cellule BASE courante |
| 389 | `align` | `( -- )` | Aligne HERE sur la taille de cellule (1 AU = 1 cellule → identité) |
| 390 | `2@` | `( addr -- x1 x2 )` | Lit une paire de cellules (x2 à addr, x1 à addr+1) |
| 391 | `2!` | `( x1 x2 addr -- )` | Écrit une paire de cellules |
| 392 | `u<` | `( u1 u2 -- flag )` | Comparaison non signée (u64) |
| 393 | `s>d` | `( n -- d )` | Extension de signe vers double cellule (lo hi) |
| 394 | `m*` | `( n1 n2 -- d )` | Produit signé sur double cellule (i128) |
| 395 | `*/mod` | `( n1 n2 n3 -- n4 n5 )` | d = n1*n2 (i128) ; n4 = reste, n5 = quotient |
| 396 | `<#` | `( -- )` | Initialise la conversion picturale (zone PNO) |
| 397 | `#` | `( ud1 -- ud2 )` | Convertit un chiffre (BASE courante) |
| 398 | `#s` | `( ud -- 0 0 )` | Convertit tous les chiffres jusqu'à ud = 0 |
| 399 | `hold` | `( char -- )` | Ajoute un caractère au début de la chaîne picturale |
| 400 | `sign` | `( n -- )` | Ajoute '-' au début si n < 0 |
| 401 | `#>` | `( xd -- c-addr u )` | Termine la conversion, rend la chaîne |
| 402 | `ud.` | `( ud -- )` | Affiche double non signé (BASE courante + espace) |
| 403 | `d.` | `( d -- )` | Affiche double signé ('-' si négatif + espace) |
| 404 | `key` | `( -- char )` | Attend une touche (bloquant) |
| 405 | `key?` | `( -- flag )` | -1 si une touche est disponible |
| 406 | `accept` | `( c-addr +n1 -- +n2 )` | Lit ≤ +n1 caractères clavier (Entrée / Backspace / Escape) |
| 407 | `touche:inject` | `( char -- )` | Injecte un caractère dans la file clavier (test) |
| 408 | `word` | `( char -- c-addr )` | Chaîne comptée temporaire dans WORD_BASE, avance >IN |
| 409 | `>number` | `( ud1 c-addr1 u1 -- ud2 c-addr2 u2 )` | Convertit selon BASE jusqu'au 1er caractère non convertible |
| 419 | `abort` | `( i*x -- )` | Vide piles + STATE=0, arrête la source (silencieux) |
| 435 | `environment?` | `( c-addr u -- false \| i*x true )` | Requêtes ANS 3.2.6 (12 reconnues, sinon false) |
| 436 | `depth` | `( -- +n )` | Nombre de cellules sur la pile de données |
| 437 | `quit` | `( -- )` | Vide la pile de retour, STATE=0, retour au prompt (pile de données conservée) |
| 1832 | `u>` | `( u1 u2 -- flag )` | Comparaison non signée (u64) |
 | 1833 | `within` | `( n lo hi -- flag )` | 6.2.2440 : `(n-lo) U< (hi-lo)` en u64 wrapping, -1 si lo ≤ n < hi (borne haute exclue, plages circulaires OK). Corrigé J54 (lisait `last()` sans dépiler n → résidus de pile) |
| 1834 | `.r` | `( n +n -- )` | Affiche n aligné à droite sur +n colonnes (BASE courante, sans espace final) |
| 1835 | `u.r` | `( u +n -- )` | Affiche u (non signé) aligné à droite sur +n colonnes |
| 1836 | `holds` | `( c-addr u -- )` | Ajoute une chaîne au début de la chaîne picturale |

### Exceptions : CATCH / THROW / try-catch-endtry / POSTPONE (Jour 54)

Gestion d'erreurs Forth 2012 (chapitre 9) + `postpone`.

| Mot | Mode | Stack | Description |
|-----|------|-------|-------------|
| `throw` | prim 199 | `( err -- )` | Lève une exception. Code 0 = no-op (retiré, l'exécution continue). Sinon retour au `catch` le plus récent : piles (données + retour + boucles) restaurées à la profondeur du catch, code poussé. Non rattrapé = arrêt de la source |
| `catch` | state 0 | `( i*x xt -- j*x 0 \| i*x n )` | Exécute xt sous un handler. Si un `throw` non-zéro survient : piles restaurées + code n poussé. Sinon 0 poussé |
| `try` | state 1 | `( -- )` | Début d'un bloc structuré try (extension Epona, compilation uniquement) |
| `catch` (structuré) | state 1 | `( -- )` | Handler du bloc try ; si le `throw` intérieur n'est pas rattrapé, exécute les mots jusqu'à `endtry` avec le code sur la pile |
| `endtry` | state 1 | `( -- )` | Fin du bloc try ; empile le handler (0 = pas de throw) |
| `postpone` | state 1 | `( "name" -- )` | Compile la sémantique de compilation de `name` dans la définition courante. `postpone if/else/then` non supporté (mots de compilation structurés → « Mot inconnu ») |
| `abort"` | compilé | `( flag -- )` | 6.1.0685 : si flag ≠ 0, affiche le message puis `THROW -2` (capturable par `CATCH`). Corrigé J54 : faisait `Err("abort")` qui stoppait tout sans passer par le mécanisme d'exception |

Note : `throw` est une primitive (199) mais se compile en `Op::Throw` (sentinel `catch_ip == 0` pour le catch interprété, champ `caught_code: Option<i64>` reset à `None` dans `abort`/`quit` et dans `catch`).


### Primitives 400+ : File I/O

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 420 | `open` | `( "path" flags -- fh )` | Ouvre un fichier (flags: 0x40=create, 0x200=truncate) |
| 421 | `close` | `( fh -- )` | Ferme un fichier |
| 422 | `read` | `( fh buf len -- n )` | Lit depuis un fichier |
| 423 | `write` | `( fh buf len -- n )` | Écrit dans un fichier |
| 424 | `seek` | `( fh offset whence -- pos )` | Seek (whence: 0=SET, 1=CUR, 2=END) |
| 425 | `stat` | `( "path" -- size mtime file_type )` | Info fichier (0=Fichier 1=Dossier 3=Device) |
| 426 | `readdir` | `( "path" -- count )` | Liste un dossier (entrées affichées) |
| 427 | `mkdir` | `( "path" -- ok )` | Crée un dossier |
| 428 | `unlink` | `( "path" -- ok )` | Supprime un fichier |
| 429 | `mount` | `( fs_type "path" -- ok )` | Monte un FS (0=Ram 1=Dev 2=Proc) |
| 430 | `umount` | `( "path" -- ok )` | Démonte un filesystem |
| 431 | `sync` | `( -- )` | Synchronise les filesystems |
| 432 | `dup-fd` | `( fh -- new_fh )` | Duplique un descripteur |
| 433 | `pipe` | `( -- read_fh write_fh )` | Crée un pipe |
| 434 | `fcntl` | `( fh cmd arg -- result )` | Contrôle de fichier |

Montages VFS : `/` → FAT32 (NVMe/AHCI), `/dev` → DevFS (null/zero/random/fb0/full/port), `/proc` → ProcFS (cpuinfo/meminfo/uptime/version/devices/drivers/self), `/tmp` → RamFS.

### Primitives 500+ : Window Manager, GFX, Init

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 500 | `win:create` | `( x y w h addr len flags -- wid )` | Crée une fenêtre |
| 501 | `win:close` | `( wid -- )` | Ferme une fenêtre |
| 502 | `win:move` | `( wid x y -- )` | Déplace une fenêtre |
| 503 | `win:resize` | `( wid w h -- )` | Redimensionne |
| 504 | `win:draw` | `( wid -- )` | Dessine une fenêtre |
| 505 | `win:title` | `( wid addr len -- )` | Change le titre |
| 506 | `win:count` | `( -- count )` | Nombre de fenêtres |
| 507 | `win:active` | `( -- wid )` | Fenêtre active |
| 508 | `win:focus` | `( wid -- )` | Donne le focus |
| 509 | `win:at` | `( x y -- wid )` | Fenêtre sous le point |
| 510 | `win:clear` | `( wid -- )` | Efface une fenêtre |
| 511 | `win:present` | `( wid -- )` | Présente une fenêtre |
| 512 | `win:invert` | `( wid x y w h -- )` | Inversion vidéo zone |
| 513 | `win:flags` | `( wid -- flags )` | Lit les flags |
| 514 | `win:set-flags` | `( flags wid -- )` | Définit les flags |
| 515 | `win:xy` | `( wid -- x y )` | Position fenêtre |
| 516 | `win:wh` | `( wid -- w h )` | Taille fenêtre |
| 517 | `win:z-order` | `( -- )` | Affiche l'ordre Z |
| 518 | `win:bring-front` | `( wid -- )` | Met au premier plan |
| 519 | `win:drag-start` | `( wid x y -- )` | Début drag |
| 520 | `win:drag-end` | `( wid -- )` | Fin drag |
| 540 | `gfx:clear` | `( -- )` | Efface le canvas gfx |
| 541 | `gfx:pixel` | `( x y color -- )` | Pixel gfx |
| 542 | `gfx:rect` | `( x y w h color -- )` | Rectangle gfx |
| 543 | `gfx:text` | `( x y addr len color -- )` | Texte gfx |
| 544 | `gfx:line` | `( x1 y1 x2 y2 color -- )` | Ligne gfx |
| 545 | `gfx:circle` | `( cx cy r color -- )` | Cercle gfx |
| 546 | `gfx:image-draw` | `( img_id x y -- )` | Dessine une image |
| 547 | `gfx:image-info` | `( img_id -- w h )` | Taille image |
| 548 | `gfx:image-free` | `( img_id -- )` | Libère image |
| 550 | `gfx:save-bmp` | `( "path" -- ok )` | Sauve en BMP |
| 551 | `gfx:image-load-file` | `( addr len -- img_id w h )` | Charge image PNG/BMP |
| 552 | `gfx:image-load-data` | `( addr len -- img_id w h )` | Charge image depuis mémoire |
| 553 | `fb:pixel` | `( x y color -- )` | Alias framebuffer pixel |
| 554 | `gfx:set-target-canvas` | `( -- )` | Redirige gfx vers canvas Forth |
| 555 | `exit-uefi` | `( -- )` | Quitte UEFI, passe en runtime |

### Primitives 556+ : Init Commands

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 556 | `init-gop` | `( -- )` | Affiche info GOP |
| 557 | `init-acpi` | `( -- )` | Init ACPI |
| 558 | `init-pit` | `( -- )` | Init PIT |
| 559 | `init-usb` | `( -- )` | Init USB/xHCI |
| 560 | `init-drivers` | `( -- )` | Init tous pilotes |
| 561 | `init-fs` | `( -- )` | Init FAT32 + UEFI FsManager |
| 562 | `init-scheduler` | `( -- )` | Init scheduler |
| 563 | `init-gfx` | `( -- )` | Init graphics canvas |
| 564 | `init-window` | `( -- )` | Init Window Manager |

### Primitives 565+ : File I/O Forth

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 565 | `file-read` | `( buf buf_len path_addr path_len -- bytes )` | Lit fichier FAT32 |
| 566 | `file-write` | `( addr len path_addr path_len -- bytes )` | Écrit fichier FAT32 |
| 567 | `file-exists` | `( addr len -- flag )` | Vérifie existence |
| 568 | `file-size` | `( addr len -- size )` | Taille fichier |
| 569 | `file-list` | `( addr len -- )` | Liste répertoire |

### Primitives 720+ : Drivers — MMIO (dangereuses)

Accès MMIO volatile 32/16/8 bits. (Sémantique identique aux primitives 23/24.)

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 720 | `mmio@` | `( addr -- val )` | Lecture MMIO 32-bit (`read_volatile`) |
| 721 | `mmio!` | `( val addr -- )` | Écriture MMIO 32-bit |
| 722 | `mmio-w@` | `( addr -- u16 )` | Lecture MMIO 16-bit |
| 723 | `mmio-w!` | `( val addr -- )` | Écriture MMIO 16-bit |
| 724 | `mmio-b@` | `( addr -- u8 )` | Lecture MMIO 8-bit |
| 725 | `mmio-b!` | `( val addr -- )` | Écriture MMIO 8-bit |

> Note : `phys@`/`phys!` (726/727 dans le plan) existent aux indices 110/111
> (lecture/écriture physique 64-bit) — non ré-enregistrés en 32 bits pour ne
> pas casser les programmes existants.

### Primitives 740+ : Port I/O (dangereuses)

(Sémantique identique aux primitives 87–92.)

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 740 | `inb` | `( port -- u8 )` | Lecture port I/O 8-bit |
| 741 | `outb` | `( val port -- )` | Écriture port I/O 8-bit |
| 742 | `inw` | `( port -- u16 )` | Lecture port I/O 16-bit |
| 743 | `outw` | `( val port -- )` | Écriture port I/O 16-bit |
| 744 | `inl` | `( port -- u32 )` | Lecture port I/O 32-bit |
| 745 | `outl` | `( val port -- )` | Écriture port I/O 32-bit |

### Primitives 750+ : PCI (dangereuses)

Accès à l'espace de configuration PCI via les ports CF8/CFC (mécanisme #1).

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 750 | `pci:read-cfg8` | `( bus dev fn offset -- u8 )` | Lit 8 bits config space |
| 751 | `pci:read-cfg16` | `( bus dev fn offset -- u16 )` | Lit 16 bits |
| 752 | `pci:read-cfg32` | `( bus dev fn offset -- u32 )` | Lit 32 bits |
| 753 | `pci:write-cfg8` | `( val bus dev fn offset -- )` | Écrit 8 bits |
| 754 | `pci:write-cfg16` | `( val bus dev fn offset -- )` | Écrit 16 bits |
| 755 | `pci:write-cfg32` | `( val bus dev fn offset -- )` | Écrit 32 bits |
| 756 | `pci:bar` | `( bus dev fn n -- addr size )` | Lit la BAR n (0..5), ou 0 0 si absente |
| 757 | `pci:list` | `( -- count )` | Scan PCI, remplit la liste interne |
| 758 | `pci:dev` | `( idx -- bus dev fn vendor device class subclass )` | Infos du device n°idx |

### Primitives 770+ : Mémoire / mapping

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 770 | `mem:alloc-pages` | `( n -- vaddr )` | Alloue n pages physiques (0 si échec) |
| 771 | `mem:free-pages` | `( vaddr n -- )` | Libère n pages |
| 772 | `mem:map-mmio` | `( phys size flags -- vaddr )` | Map une région MMIO (avant P0 : retourne phys) |
| 773 | `mem:unmap` | `( vaddr size -- )` | Démap (avant P0 : no-op) |
| 774 | `mem:virt->phys` | `( vaddr -- paddr )` | Traduction (avant P0 : retourne vaddr) |
| 775 | `mem:total` | `( -- total free )` | Stats mémoire |

### Primitives 790+ : IRQ (dangereuses sauf irq:wait)

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 790 | `irq:attach` | `( irq xt -- )` | Attache un mot Forth à un IRQ (file, pas en IRQ) |
| 791 | `irq:detach` | `( irq -- )` | Détache |
| 792 | `irq:mask` | `( irq -- )` | Masque l'IRQ (PIC ou APIC) |
| 793 | `irq:unmask` | `( irq -- )` | Démasque |
| 794 | `irq:ack` | `( irq -- )` | Acquitte (EOI) |
| 795 | `irq:wait` | `( -- )` | Attend la prochaine IRQ (hlt) |

### Primitives 800+ : Framebuffer GOP

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 800 | `gfb-addr` | `( -- addr )` | Adresse du framebuffer |
| 801 | `gfb-width` | `( -- w )` | Largeur |
| 802 | `gfb-height` | `( -- h )` | Hauteur |
| 803 | `gfb-stride` | `( -- s )` | Stride (octets) |
| 804 | `gfb-bpp` | `( -- bpp )` | Bits par pixel |
| 805 | `gfb-pixel-format` | `( -- fmt )` | 0=BGR, 1=RGB |

### Primitives 810+ : Wrappers drivers Rust (dangereuses)

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 810 | `xhci:init` | `( bar -- ok? )` | Init contrôleur xHCI |
| 811 | `xhci:stop` | `( bar -- )` | Stop xHCI |
| 812 | `xhci:port-count` | `( bar -- n )` | Nombre de ports |
| 813 | `ahci:init` | `( -- ok? )` | Init AHCI (BAR scannée en interne) |
| 814 | `ahci:stop` | `( bar -- )` | Stop AHCI |
| 815 | `ahci:port-count` | `( bar -- n )` | Ports |
| 816 | `ahci:disk-count` | `( bar -- n )` | Disques |
| 817 | `ahci:read` | `( bar port buf lba count -- n )` | Lecture disque |
| 818 | `ahci:write` | `( bar port buf lba count -- n )` | Écriture disque |
| 819 | `nvme:init` | `( -- ok? )` | Init NVMe (BAR scannée en interne) |
| 820 | `nvme:shutdown` | `( bar -- )` | Shutdown NVMe |
| 821 | `nvme:ns-count` | `( bar -- n )` | Namespaces |
| 822 | `hda:init` | `( bar -- ok? )` | Init audio HDA |
| 823 | `hda:reset` | `( bar -- )` | Reset HDA |
| 824 | `hda:stream-count` | `( bar -- n )` | Streams |
| 825 | `hda:output-pin` | `( bar -- widget-nid )` | Pin de sortie |
| 826 | `net:e1000:init` | `( bar -- ok? )` | Init réseau Intel e1000 |

### Primitives 840+ : Utilitaires drivers

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 840 | `drv:log` | `( a l -- )` | Log `[DRV]` vers le shell + syslog |
| 841 | `drv:loaded?` | `( a l -- idx )` | Cherche un driver par nom (idx ou -1) |
| 842 | `ms-delay` | `( ms -- )` | Délai millisecondes |
| 843 | `us-delay` | `( us -- )` | Délai microsecondes |
| 844 | `tsc` | `( -- tsc )` | Lit rdtsc |
| 848 | `dev:register` | `( name-addr name-len type priv -- devid )` | Enregistre un périphérique |

> Note : `cpuid` (845 dans le plan) existe à l'indice 98
> `( eax -- eax ebx ecx edx )`. `msr@`/`msr!` (846/847) correspondent aux
> indices 129/130 `( ecx -- hi lo )` / `( lo hi ecx -- )`.

### Primitives 850+ : RTC CMOS

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 850 | `cmos:read` | `( reg -- u8 )` | Lit registre CMOS |
| 851 | `cmos:write` | `( val reg -- )` | Écrit registre CMOS |
| 852 | `cmos:time` | `( -- s m h )` | Heure |
| 853 | `cmos:date` | `( -- d mth y )` | Date |
| 854 | `tsc:freq` | `( -- khz )` | Fréquence TSC calibrée |

### Primitives 862+ : Fichiers

| Idx | Nom | Stack | Description |
|-----|-----|-------|-------------|
| 862 | `included` | `( a l -- )` | Inclut un fichier (compiler + exécuter) |
| 863 | `read-file` | `( a l buf max -- n )` | Lit un fichier dans un buffer |
| 864 | `list-dir` | `( a l -- count )` | Liste un répertoire dans une table |

> Note : `file-exists`/`file-size` (860/861 dans le plan) existent aux indices
> 567/568.

### Mots Forth immédiats (traités en mode state 0 et state 1)

| Mot | Mode | Description |
|-----|------|-------------|
| `:` | state 0 | Commence une définition |
| `;` | state 1 | Termine une définition |
| `:noname` | state 0 | Définition anonyme : pousse son xt sur la pile de données, passe en mode compilation (Jour 53) |
| `if` | state 1 | Condition compilée |
| `else` | state 1 | Sinon compilé |
| `then` | state 1 | Fin condition |
| `begin` | state 1 | Début boucle |
| `again` | state 1 | Boucle infinie |
| `until` | state 1 | Boucle jusqu'à vrai |
| `while` | state 1 | Boucle conditionnelle |
| `repeat` | state 1 | Fin while |
| `do` | state 1 | Boucle comptée |
| `loop` | state 1 | Fin boucle comptée |
| `+loop` | state 1 | Fin boucle +incrémentation |
| `i` | state 1 | Index boucle |
| `j` | state 1 | Index boucle imbriquée |
| `variable` | state 0 | Déclare une variable |
| `constant` | state 0 | Déclare une constante |
| `create` | state 0 | Crée un mot créateur |
| `does>` | state 1 | Body d'un mot créateur |
| `immediate` | state 0 | Marque immédiat |
| `recurse` | state 1 | Appel récursif |
| `[` | state 1 | Mode interprétation |
| `]` | state 0 | Mode compilation |
| `s"` | state 0/1 | Lit/définit chaîne |
| `."` | state 1 | Affiche chaîne compilée |
| `(` | both | Commentaire |
| `\` | both | Commentaire fin de ligne |
| `[if]` | both | Compilation conditionnelle |
| `[else]` | both | Sinon conditionnel |
| `[then]` | both | Fin conditionnel |
| `[defined]` | both | Teste si mot existe |
| `[undefined]` | both | Teste si mot n'existe pas |
| `'` | state 0 | Lit xt d'un mot |
| `[']` | state 1 | Compile xt |
| `to` | state 0 | Modifie une valeur |
| `is` | state 1 | Associe à un defer |
| `action-of` | state 0 | Lit xt d'un defer |
| `catch` | state 0 | CATCH standard (6.1.0675) : exécute xt sous un handler ; `throw` non-zéro → code poussé, sinon 0 (Jour 54) |
| `postpone` | state 1 | Compile la sémantique de compilation de name (Jour 54) |
| `{` | state 1 | Variables locales |
| `}` | state 1 | Fin variables locales |
| `.(` | state 0 | Affiche littéral |
| `c"` | state 0/1 | Chaîne counted |
| `s"` | state 0/1 | Chaîne standard |

---

## COMMANDES SHELL (shell.rs)

### Fichiers

| Commande | Usage | Description |
|----------|-------|-------------|
| `ls` / `dir` | `ls` | Liste les fichiers de la clé USB |
| `cat` | `cat <fichier>` | Affiche le contenu d'un fichier |
| `cd` | `cd [dossier]` | Change de répertoire (`..` = parent, `/` = racine) |
| `mkdir` | `mkdir <nom>` | Crée un dossier |
| `touch` | `touch <nom>` | Crée un fichier vide |
| `rm` | `rm <nom>` | Supprime un fichier |
| `mv` | `mv <ancien> <nouveau>` | Renomme/déplace un fichier |
| `exec` | `exec <fichier.fth>` | Exécute un fichier Forth |
| `jit` | `jit <f>` / `jit compil <f>` / `jit info` / `jit clear` | Compilation JIT |

### Storage

| Commande | Usage | Description |
|----------|-------|-------------|
| `vol` | `vol` / `vol <n>` | Liste/sélectionne les volumes |
| `fs-reset` | `fs-reset` | Re-scane les volumes USB |

### Boot

| Commande | Usage | Description |
|----------|-------|-------------|
| `boot-add` | `boot-add <driver.fth>` | Ajoute un driver à BOOT.FTH |
| `boot-exit` | `boot-exit` | Ajoute exit-uefi à BOOT.FTH |
| `boot-show` | `boot-show` | Affiche BOOT.FTH |
| `boot-write` | `boot-write` | Écrit BOOT.FTH sur la clé |
| `boot-clear` | `boot-clear` | Efface BOOT.FTH |
| `boot-rt` | `boot-rt` | Compile BOOT.FTH et lance en runtime |

### Hardware

| Commande | Usage | Description |
|----------|-------|-------------|
| `hw-check` | `hw-check` | Vérifie matériel vs drivers FTH |
| `hw-setup` | `hw-setup [y\|n\|s]` | Auto-setup driver par driver |
| `hw-reset` | `hw-reset` | Réinitialise la file d'auto-setup |
| `pci` | `pci` / `pci list` / `pci save` | Liste PCI / sauvegarde |
| `acpi` | `acpi` / `acpi save` | Infos ACPI / sauvegarde |
| `mmio` | `mmio <adr> [val]` | Lit/écrit registre MMIO 32-bit |
| `i2c` | `i2c probe <base>` / `i2c read <base> <dev> <reg>` | Probe/lit I2C |
| `devices` | `devices` / `devices save` | Liste matériel + adresses |

### Système

| Commande | Usage | Description |
|----------|-------|-------------|
| `aide` / `help` | `aide` | Affiche l'aide |
| `effacer` / `clear` | `effacer` | Efface l'écran |
| `clavier` | `clavier` | Bascule QWERTY/AZERTY |
| `apropos` | `apropos` | À propos de l'OS |
| `tutor` / `forth` | `tutor` | Aide mémoire Forth |
| `drivers` | `drivers` | Liste pilotes enregistrés |
| `words` | `words` | Tous les mots Forth |
| `scheduler` | `scheduler` | État des tâches |
| `secure` | `secure on\|off` | Mode sécurisé (non implémenté) |
| `log` | `log` | Journal système |
| `reboot` | `reboot` | Redémarre |
| `poweroff` | `poweroff` | Éteint |

### Forth direct

Toute commande non reconnue est passée directement au compilateur Forth.
