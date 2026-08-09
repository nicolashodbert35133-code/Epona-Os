1. **En-tête formalisé** — le texte conversationnel collé depuis nos échanges est remplacé par un positionnement propre
2. **Nouvelle Phase 1.5 : Migration Forth ISO 2012** — le chantier actuel (S7/12 terminée, Core complet) inséré avec son état réel
3. **Boucle de collecte de drivers** (`pci save` → `hw-check` → issue GitHub → agent) documentée
4. **Section Drivers industriels** avec une matrice de faisabilité honnête (un PC x86 n'a pas de GPIO natif comme un Raspberry Pi — il faut distinguer UART/I2C directs de SPI/CAN via adaptateurs)
5. **Licence hybride MIT/Propriétaire** affirmée partout (le « 100% open-source » de l'intro était contradictoire)
6. **Chronologie réaliste** recalée sur la fin du planning ISO (fin octobre 2026)

````markdown
# 🐴 Epona OS — Roadmap 2026-2028

> **Vision** : Construire la première plateforme x86 bare-metal souveraine, minimale,
> éducative, industrielle et agentique — comprendre et contrôler le matériel sans
> l'opacité des OS modernes.

> **Modèle de licence** : hybride.
> - **MIT (open-source)** : Forth système, drivers `.fth`, agents, dashboards,
>   bureau, outils, documentation, tests.
> - **Propriétaire** : noyau Rust, boot signé, JIT interne, modules de sécurité.

> **Date** : 10 Août 2026

---

## Positionnement

Epona OS n'est pas une distribution Linux de plus. C'est un OS qui crée sa propre
catégorie : **l'OS souverain bare-metal, agentique, éducatif et industriel**.

```
┌──────────────────────────────────────────────────────────────────┐
│                   ESPACE OUVERT & MIT (FTH)                      │
│  - Bureau & Widgets personnalisés                                │
│  - Pilotes Industriels (CAN, Modbus, UART, SPI, GPIO, ADC, PWM)  │
│  - Agents IA, Dashboards, Applications & Outils Éducatifs        │
│  - Documentation, Tests & Standard Forth ISO 2012                │
└─────────────────────────────────┬────────────────────────────────┘
                                  │ Appel aux primitives (API v1)
┌─────────────────────────────────▼────────────────────────────────┐
│                NOYAU PROPRIÉTAIRE Epona OS (RUST)                │
│  - Noyau Bare-Metal & Boot Signé (chaîne de confiance)           │
│  - Moteur d'exécution Forth & JIT interne                        │
│  - Sandbox mémoire, isolation des tâches & sécurité matérielle   │
└──────────────────────────────────────────────────────────────────┘
```

### Publics cibles

- 💡 **Geeks & passionnés d'architecture** : comprendre le fonctionnement réel d'un
  ordinateur et piloter le processeur sans couche d'abstraction opaque.
- 🦀 **Développeurs bas-niveau (Rust, ASM, Forth)** : écrire des programmes et des
  pilotes bare-metal sans dépendance lourde.
- 🔌 **Makers, électroniciens & hardware hackers** : piloter puces, FPGA, modules
  USB et microcontrôleurs depuis l'OS, sans SDK ni IDE lourd.
- 🛠️ **Bidouilleurs hardware & créateurs d'OS** : tester instructions machine,
  drivers et interfaces graphiques en direct sur le métal.
- 🇫🇷 **Adeptes d'OS souverains & minimalistes** : environnement sans bloatware,
  autonome et agentique.
- 🏭 **Industriels & intégrateurs** : automatisme, bancs de test, supervision via
  CAN, Modbus, UART, SPI, GPIO, ADC, PWM.
- 🎓 **Écoles & universités** : plateforme pédagogique x86 unique — du registre CPU
  au driver, tout est visible et modifiable.

### Philosophie : Zéro bloatware • 100% liberté

```
┌──────────────────────────────────────────────────────────────────┐
│  ✓ Zéro application obligatoire préinstallée                     │
│  ✓ Zéro processus d'arrière-plan caché ou télémétrie             │
│  ✓ Un bureau sur-mesure codé en Forth, unique par utilisateur    │
│  ✓ Vos pilotes, vos widgets et vos jeux sur votre clé USB Live   │
└──────────────────────────────────────────────────────────────────┘
```

### Méthodologie de développement : double agent

| Agent | Rôle | Fréquence |
|-------|------|-----------|
| **Agent codeur** | Suit le planning, une modification limitée par séance, écrit les tests | Quotidien |
| **Agent auditeur** | Relit le code source Rust, cherche incohérences et bugs silencieux | Hebdomadaire |

Cette séparation a déjà prouvé son efficacité : bugs `-rot`, `tuck`, `alloc`,
locales en boucle infinie et dérive de `HERE` détectés par l'audit, invisibles
au codeur.

---

## Table des matières

1. [Phase 1 : Fondations — TERMINÉE ✅](#phase1)
2. [Phase 1.5 : Migration Forth ISO 2012 — EN COURS 🚧](#phase1-5)
3. [Phase 1.6 : Shell moderne — À FAIRE (Nov. 2026)](#phase1-6)
4. [Écosystème de drivers : boucle de collecte décentralisée](#ecosysteme)
5. [Drivers industriels (CAN, Modbus, UART, SPI, GPIO, ADC, PWM)](#industriel)
6. [Phase 2 : Bureau graphique (T1 2027)](#phase2)
7. [Phase 3 : Réseau complet (T2 2027)](#phase3)
8. [Phase 4 : Multimédia (T3 2027)](#phase4)
9. [Phase 5 : IA locale (T4 2027)](#phase5)
10. [Phase 6 : Électronique embarquée native (T1 2028)](#phase6)
11. [Phase 7 : OS "vrai" (T2-T4 2028)](#phase7)
12. [Primitives — Récapitulatif](#primitives)
13. [Ce qui distingue Epona OS](#distingue)
14. [Guides de développement](#guides)

---

<a id="phase1"></a>
## 1. Phase 1 : Fondations — TERMINÉE ✅

**Toutes les phases du DEV_GUIDE_DRIVER_AGENT.MD sont terminées.**

| Phase | Description | Date | Statut |
|-------|-------------|------|--------|
| **1** | Corrections bugs bloquants (interrupts.rs, main.rs) | 2026-07-30 | ✅ Fait |
| **2** | Primitives noyau 720-864 (MMIO, PIO, PCI, IRQ, GOP, wrappers) | 2026-07-31 | ✅ Fait |
| **3** | Framework driver Rust (drv_api.rs, drivers.rs, auto-chargement) | 2026-08-01 | ✅ Fait |
| **4** | Bibliothèque standard Forth (drvlib, pci_enum, fmt, strings, tsc) | 2026-08-01 | ✅ Fait |
| **5** | Drivers communautaires (13 drivers + TEMPLATE.fth) | 2026-08-01 | ✅ Fait |
| **6** | Fichiers de démarrage (BOOT.FTH, default.fth) | 2026-08-01 | ✅ Fait |
| **7** | GitHub et documentation (docs/, .github/, README) | 2026-08-02 | ✅ Fait |
| **8** | CI (test-drivers.yml, validate-drivers.sh) | 2026-08-02 | ✅ Fait |

### Drivers Forth implémentés

| Driver | PCI ID | Type | Statut |
|--------|--------|------|--------|
| generic-simplefb.fth | 03:00 | GPU | ✅ |
| generic-xhci.fth | 0C:03 | USB | ✅ |
| usb-hid.fth | — | Input | ✅ |
| generic-ahci.fth | 01:06 | Storage | ✅ |
| generic-nvme.fth | 01:08 | Storage | ✅ |
| generic-hda.fth | 04:03 | Audio | ✅ |
| e1000-generic.fth | 8086:* | Network | ✅ |
| rtc.fth | — | Generic | ✅ |
| pcspkr.fth | — | Generic | ✅ |
| bochs-vga.fth | 1234:1111 | GPU (QEMU) | ✅ |
| virtio-net.fth | 1af4:1000 | Network (QEMU) | ✅ |
| WD-SN770-NVMe.FTH | 15B7:5017 | Storage | ✅ |
| AMD-Ryzen5-5500U.FTH | 1022:1631 | CPU | ✅ |

---

<a id="phase1-5"></a>
## 2. Phase 1.5 : Migration Forth ISO 2012 — EN COURS 🚧

**Chantier prioritaire absolu. Aucun driver ni application nouveau avant la fin
de cette phase.**

**Objectif** : remplacer le Forth propriétaire historique par un sous-ensemble
**Forth ISO 2012 strict**, pour que n'importe quel développeur ou agent IA puisse
écrire un `.fth` conforme au standard universel — sans connaître le code Rust,
sans dépendre d'un langage maison.

**Référence** : `PLANNING_CODAGE_FORTH_12_SEMAINES.md` (84 jours, 2 h/jour).

### État d'avancement (au 2026-08-09)

| Semaine | Contenu | Statut |
|---------|---------|--------|
| S1 | Baseline, inventaire (741 primitives, 12 doublons), contrat API | ✅ |
| S2 | Sémantique Core : flags `-1/0`, `2/` signé, `RSHIFT` logique, `SEARCH`, `REFILL`, `SOURCE`/`>IN` | ✅ |
| S3 | `STATE` adressable, `FIND` chaîne comptée, `PARSE-NAME`, `PARSE` | ✅ |
| S4 | Modèle mémoire : **1 AU = 1 cellule i64**, helpers bornés, fenêtre `c@`/`c!` (memory < 65536 / MMIO ≥), `MAX_MEM` 4096→65536, `alloc` réparé | ✅ |
| S5 | `VARIABLE`/`CONSTANT`/`VALUE`/`CREATE`/`DOES>` conformes, chaînes compilées sans dérive de `HERE`, `EVALUATE` avec sauvegarde | ✅ |
| S6 | `BASE` adressable, `2@`/`2!`, `U<`/`S>D`, `M*`/`*/MOD` en i128, groupe `<# # #S HOLD SIGN #>`, `UD.`/`D.` | ✅ |
| S7 | `KEY`, `ACCEPT`, `WORD`, `>NUMBER`, `ABORT`, `QUIT`, `ENVIRONMENT?` → **Core ISO 2012 COMPLET** | ✅ |
| S8 | Core Ext prioritaires (`WITHIN`, `U>`, `.R`, `U.R`, `PAD`, `S\"`, `:NONAME`, `COMPILE,`) + **gel Driver API v1** | 🚧 En cours |
| S9 | API Application v1 (`forth/std/core.fth`, packaging `.fth`) | ⬜ |
| S10 | Portabilité contrôlée (fallback timing/JIT/GOP/périphériques) | ⬜ |
| S11 | Qualification : tests agent distant, utilisateur distant, driver distant | ⬜ |
| S12 | Release candidate x86_64 UEFI (QEMU + Intel réel + AMD réel) | ⬜ |

### Résultats mesurables

- **Core ISO 2012 : 103/133 → 133/133 mots** (complet au 2026-08-09).
- **Bugs critiques corrigés** : `-rot` identique à `rot`, `tuck` faux, `alloc`
  retournant toujours -1, locales `{}` en boucle infinie, `S"` compilé dérivant
  `HERE` à l'infini, `sys:load` masquant les erreurs, `parse_number` paniquant
  sur `i64::MIN`.
- **Suite de tests** : `forth/TESTS/core2012.fth` sections A + B0…B33,
  `NB-FAILS = 0` attendu sur matériel.
- **Builds** : debug + release, 0 erreur, 413 warnings (baseline stable).

### Pourquoi cette phase conditionne tout le reste

Sans noyau ISO strict, chaque driver ou application aurait dépendu d'un dialecte
maison : inutilisable par un agent externe, inauditable, non pérenne. Avec l'ISO
2012, un `.fth` Epona se lit, se teste et se maintient comme n'importe quel Forth
standard — c'est la garantie de **compatibilité irréprochable** exigée par le
modèle ouvert du projet.

---

<a id="phase1-6"></a>
## 3. Phase 1.6 : Shell moderne — À FAIRE (Nov. 2026)

**Démarre après la release candidate Forth ISO (fin S12).** Le shell actuel est
basique ; pour qu'Epona OS soit utilisable au quotidien, il faut le moderniser.

Voir **DEV_GUIDE_SHELL.MD** pour les détails complets.

### 3.1 — Édition de ligne 🔴 P0

| Amélioration | Description |
|--------------|-------------|
| Curseur dans la ligne | `cursor_pos`, insertion/suppression à la position |
| Flèches gauche/droite, Home/End, Delete | Navigation dans l'input |
| Historique haut/bas | Navigation dans `cmd_history` |
| Auto-complétion Tab | Commandes + fichiers + mots Forth |

### 3.2 — Commandes 🔴 P0 / 🟠 P1

| Priorité | Commandes |
|----------|-----------|
| 🔴 P0 | `echo`, `cp`, `edit`, `pwd`, `set`/`export`, `source` |
| 🟠 P1 | `date`, `uname`, `uptime`, `dmesg`, `history`, `grep`, `find`, `head`, `tail`, `wc`, `xxd` |
| 🟠 P1 | `lspci`, `lsusb`, `lsblk`, `mount`/`umount`, `modinfo`, `modload` |
| 🟠 P1 | `ifconfig`, `ping`, `wget`, `nc`, `dns` (après pile réseau) |
| 🟠 P1 | `ps`, `kill`, `top`, `irq-stats`, `netstat`, `vm-stats` |

### 3.3 — Fonctionnalités modernes

Redirections `>` `>>` `<`, variables `$PATH` `$?`, chaînage `;` `&&` `||`,
pipelines `|` (VFS), `cmd &`, globbing, prompt configurable, alias Unix/DOS,
persistance de l'historique dans `\HISTORY.FTH`.

### 3.4 — Checklist avant merge d'une commande shell

- [ ] Aide mise à jour ; `Usage:` sur arguments manquants
- [ ] Gestion FS absent / volume non prêt / erreurs lecture-écriture
- [ ] `last_exit_code` positionné ; chemins via `resolve_path()`
- [ ] Aucun `unwrap()` sur entrée utilisateur ; sortie via `push_line()`
- [ ] Tests clavier sur cas limites

---

<a id="ecosysteme"></a>
## 4. Écosystème de drivers : boucle de collecte décentralisée

Epona OS ne dépend d'aucune base de matériel centralisée : **chaque clé USB est
un nœud de collecte**, et chaque issue GitHub devient un ticket de travail
reproductible pour un agent.

```
Machine utilisateur (clé USB Live)
  │
  ├─ pci save      → /MATERIEL/<machine>_<date>.txt  (inventaire PCI complet)
  ├─ hw-check      → compare avec drivers/ présents
  │                → drivers_manquants.txt (PCI ID + class/subclass)
  │
  ▼
Issue GitHub automatique (titre : matériel, corps : drivers manquants)
  │
  ▼
Agent codeur (humain ou IA)
  ├─ lit docs/API_V1.md + docs/WRITING_DRIVERS.md        (obligatoire)
  ├─ écrit le driver en Forth ISO 2012 strict
  ├─ drv:name! / drv:register / drv:probe / drv:init     (protocole v1 figé)
  │
  ▼
Publication dans drivers/ → toute clé USB équipée du même matériel
en bénéficie au prochain hw-check
```

### Règles strictes de l'écosystème (norme v1.0)

1. **Deux documents obligatoires** avant toute écriture : `API_V1.md` (contrat)
   et le guide d'écriture driver (protocole). Aucune exception.
2. **Forth ISO 2012 uniquement** — aucune syntaxe propriétaire côté driver.
3. **Signatures figées** : `drv:probe ( bar bus dev func -- ok? )` retourne `0`
   si le matériel est absent, **sans crash** ; `drv:init` idempotent.
4. **Pas d'accès MMIO/PIO direct hors framework** — uniquement via les mots
   autorisés (`mmio@/!`, `inb..outl`, `pci:*`, `alloc`, `drv:log`).
5. **CI** : `validate-drivers.sh` + `test-drivers.yml` doivent passer.

---

<a id="industriel"></a>
## 5. Drivers industriels — CAN, Modbus, UART, SPI, GPIO, ADC, PWM

Objectif : faire d'Epona OS une plateforme d'automatisme, de banc de test et de
supervision pilotable en Forth, avec une latence maîtrisée et un code auditable
ligne par ligne.

### Matrice de faisabilité (honnêteté technique)

Un PC x86 de bureau n'a **pas** de broches GPIO/SPI/ADC natives comme un
microcontrôleur. Les accès se répartissent en trois catégories :

| Protocole | Accès | Prérequis | Disponibilité |
|-----------|-------|-----------|---------------|
| **UART (COM1-4)** | Ports I/O `0x3F8…` direct | `inb`/`outb` existants | ✅ **Aujourd'hui, en pur `.fth`** |
| **Modbus RTU** | Surcouche logicielle de l'UART | UART ci-dessus + CRC16 en Forth | ✅ **Aujourd'hui, en pur `.fth`** |
| **Modbus TCP** | Pile réseau | Phase 3 | ⬜ T2 2027 |
| **I2C / SMBus** | Contrôleur chipset (DesignWare, SB800…) | `i2c-read`, `dw-i2c-init` existants | 🚧 Partiel — à documenter S8-S9 |
| **SPI** | Contrôleur SoC ou carte PCIe/USB-SPI | Driver adaptateur | ⬜ Phase 6 |
| **GPIO** | GPIO chipset (SoC industriel) ou expandeur I2C/USB | Driver plateforme | ⬜ Phase 6 |
| **ADC / PWM** | SoC embarqué industriel ou module externe | Driver plateforme | ⬜ Phase 6 |
| **CAN / CANopen** | Carte PCI/PCIe-CAN ou adaptateur USB-CAN | Driver adaptateur | ⬜ Phase 6 |

**Cibles matérielles privilégiées** : cartes industrielles x86 (PC/104, Mini-ITX
embarqué, APU AMD/Intel SoC avec GPIO/I2C/SPI exposés), adaptateurs USB-CAN et
USB-UART courants.

### Exemple — ce qui est possible **dès aujourd'hui** : Modbus RTU sur COM1

```forth
\ === DRIVER MODBUS-RTU / UART — Conforme API v1 (MIT) ===
drv:name!    "modbus_uart.fth"
drv:register "INDUSTRIAL:UART:MODBUS ; Modbus RTU Master ; class=07/00"

115200 value BAUD-RATE
0x3F8  value COM1-BASE

: uart-tx-ready? ( -- flag ) COM1-BASE 5 + inb 0x20 and 0<> ;
: uart-emit      ( char -- ) begin uart-tx-ready? until COM1-BASE outb ;

: modbus-send-frame ( addr len -- )
  0 do dup i + c@ uart-emit loop drop ;

drv:probe ( bar bus dev func -- ok? )
  drop drop drop drop -1 ;

drv:init ( -- ok? )
  0x80 COM1-BASE 3 + outb   \ DLAB = 1
  0x01 COM1-BASE 0 + outb   \ 115200 baud
  0x00 COM1-BASE 1 + outb
  0x03 COM1-BASE 3 + outb   \ 8N1
  -1 ;
```

1. **100 % lisible** par un humain ou un agent IA.
2. **Exécuté directement sur le métal**, sans pile tty/serial de 10 000 lignes.
3. **Latence déterministe** (pas d'ordonnanceur opaque derrière).

### Jalon industriel

- **S8-S9 (2026)** : premier driver industriel de référence (Modbus RTU) validé
  par la CI, publié comme modèle pour les agents.
- **T1 2028 (Phase 6)** : primitives natives SPI/GPIO/ADC/PWM/CAN (850-883) pour
  les plateformes qui les exposent + drivers d'adaptateurs USB.

---

<a id="phase2"></a>
## 6. Phase 2 : Bureau graphique complet (T1 2027)

### 6.1 — Window Manager en Forth + primitives natives (500-520, 530-560)

Fenêtres (`win:create`, `win:move`, `win:event`, drag, focus, z-order…) et
dessin avancé (`gfx:circle`, `gfx:polygon`, `gfx:bezier`, `gfx:gradient`,
`gfx:alpha-blend`, clipping, sprites, polices, décodage PNG/BMP/JPEG,
`gfx:rounded-rect`, `gfx:shadow`). Détail inchangé : voir sections primitives
de la version précédente de ce document.

### 6.2 — Bureau complet en Forth (BUREAU.FTH)

Fenêtres déplaçables, barre des tâches, menu démarrer, éditeur intégré, curseur
souris, thème sombre. **Chaque utilisateur peut fork son bureau** : c'est un
script `.fth` comme un autre, chargé depuis `BOOT.FTH`.

### 6.3 — Éditeur de code Forth (EDITEUR.FTH)

Coloration syntaxique, numéros de ligne, curseur clignotant,
sauvegarde/chargement, compilation et exécution directes.

---

<a id="phase3"></a>
## 7. Phase 3 : Réseau complet (T2 2027)

### 7.1 — Pile TCP/IP (600-650)

`tcp:listen/accept/read/write/close/status`, `udp:socket/send/recv`,
`tls:connect/read/write/close`, `http:get/post/serve`, WebSocket
(`ws:connect/send/recv/close`).

### 7.2 — Serveur HTTP en Forth

```forth
: http-handler ( client_sock -- )
  256 balloc { buf }
  client_sock buf 256 tcp:read { nread }
  nread 0 > if
    s" HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"
    client_sock swap tcp:write drop
    s" <h1>Epona OS</h1><p>Serveur Forth bare-metal</p>"
    client_sock swap tcp:write drop
  then
  client_sock tcp:close ;

: serveur ( -- )
  80 tcp:listen { sock }
  begin sock tcp:accept { client }
    client 0 >= if client http-handler then
  again ;
```

**Débloque aussi** : Modbus TCP (§5), envoi automatique des rapports
`hw-check` vers GitHub (§4), package manager (Phase 7).

---

<a id="phase4"></a>
## 8. Phase 4 : Multimédia (T3 2027)

### 8.1 — Audio (700-720)

`audio:init/info/play-raw/play-wav/stop/volume/mixer/synth/sample/midi-*`.
Synthèse sine/square/triangle/sawtooth.

### 8.2 — Synthétiseur en Forth

```forth
: beep-sine ( freq ms -- ) over 2 audio:synth ;
440 500 beep-sine   \ La 440 Hz, 500 ms
```

---

<a id="phase5"></a>
## 9. Phase 5 : IA locale bare-metal (T4 2027)

### 9.1 — Moteur de tenseurs (800-830)

`tensor:create/free/load/matmul/add/softmax/relu/shape/get/set/print`.
Optimisations x86_64 : AVX2 pour matmul, quantization INT8, tiling cache L1/L2.

### 9.2 — LLM local GGUF (820-826)

`llm:load/generate/embed/info/free/temperature/top-p`. Chargeur GGUF quantizé
(Q4_0/Q4_1/Q8_0/F16/F32).

```forth
s" /models/tinyllama-1.1b-q4.gguf" llm:load constant MODEL
: ask ( -- )
  s" Qu'est-ce que Forth ?" MODEL swap 256 llm:generate type cr ;
```

**Synergie agentique** : les agents qui écrivent et auditent les `.fth`
pourront à terme tourner *dans* Epona OS lui-même.

---

<a id="phase6"></a>
## 10. Phase 6 : Électronique embarquée native (T1 2028)

### 10.1 — Primitives embarquées (850-883)

`serial:init/read/write/avail?`, `spi:init/transfer/cs`,
`gpio:mode/read/write/irq`, `adc:read`, `dac:write`, `pwm:set`,
protocoles `modbus:read/write`, `canbus:send/recv`.

Voir §5 pour la matrice de faisabilité : ces primitives ciblent les plateformes
x86 industrielles (SoC avec GPIO/SPI/I2C exposés) et les adaptateurs USB/PCIe.

### 10.2 — Bluetooth HCI via xHCI (950-961)

`bt:init/scan/poll/devices/device-info/device-name/connect/disconnect/paired/
status/addr/info`.

---

<a id="phase7"></a>
## 11. Phase 7 : OS "vrai" (T2-T4 2028)

### 11.1 — Installateur sur disque (INSTALL.FTH)

Détection disques (AHCI/NVMe), partitionnement GPT, formatage FAT32, copie
BOOTX64.EFI + BOOT.FTH, entrée NVRAM EFI.

### 11.2 — Package manager (PKG.FTH) et format .EPA

Paquets signés (ed25519 + SHA-256), métadonnées, dépendances, icône, JIT
optionnel. Primitives Store 970-977 (`pkg:list/info/install/remove/update/
search/pack/verify`).

### 11.3 — Sécurité renforcée

- Boot signé de bout en bout (noyau propriétaire → vérifie les composants MIT).
- Signature obligatoire des paquets `.EPA` du store officiel.
- Sandbox Forth documentée (bornes `MAX_MEM`, fenêtres MMIO) et auditables.
- **Formulation honnête** : le bare-metal et l'absence de Linux *réduisent* la
  surface d'attaque et rendent le système *auditable* ; ils ne dispensent ni de
  la validation, ni de l'isolation, ni d'une politique de mise à jour.

---

<a id="primitives"></a>
## 12. Primitives — Récapitulatif

### Implémentées

| Plage | Catégorie | Nombre | Statut |
|-------|-----------|--------|--------|
| 0-437 | Noyau Forth + ISO 2012 (dont 388-403 : BASE/ALIGN/2@/2!/U</S>D/M*/*/MOD/PNO ; 404-409 : KEY/KEY?/ACCEPT/WORD/>NUMBER ; 419 ABORT ; 435-437 ENVIRONMENT?/DEPTH/QUIT) | ~150 effectifs ISO | ✅ S1-S7 |
| 500-555 | Fenêtres & GFX (v1 existante) | ~40 | ✅ |
| 565-569 | Fichiers Forth | 5 | ✅ |
| 600-643 | Réseau/TCP/HTTP/DNS (v1) | ~30 | ✅ |
| 720-727 | MMIO | 8 | ✅ |
| 740-745 | Port I/O | 6 | ✅ |
| 750-758 | PCI | 9 | ✅ |
| 770-775 | Mémoire | 6 | ✅ |
| 790-795 | IRQ | 6 | ✅ |
| 800-805 | Framebuffer GOP | 6 | ✅ |
| 810-826 | Wrappers drivers | 17 | ✅ |
| 840-848 | Utilitaires drivers | 9 | ✅ |
| 850-854 | RTC CMOS | 5 | ✅ |
| 860-864 | Fichiers | 5 | ✅ |
| 900-944 | Flottants IEEE 754 | 45 | ✅ |

### À implémenter

| Plage | Catégorie | Phase |
|-------|-----------|-------|
| S8 (indices à définir) | `WITHIN`, `U>`, `.R`, `U.R`, `PAD`, `S\"`, `:NONAME`, `COMPILE,` | Phase 1.5 🚧 |
| 500-560 | Fenêtres v2 + dessin avancé | Phase 2 |
| 600-650 | Réseau avancé (TLS, WS) | Phase 3 |
| 700-720 | Audio | Phase 4 |
| 800-830 | IA/Tenseurs | Phase 5 |
| 850-883 | Embarqué (SPI/GPIO/ADC/PWM/CAN) | Phase 6 |
| 950-961 | Bluetooth | Phase 6 |
| 970-977 | Store | Phase 7 |

---

<a id="distingue"></a>
## 13. Ce qui distingue Epona OS de tous les autres OS

1. **Forth ISO 2012 bare-metal avec JIT** → unique au monde ; code standard,
   universel, écrivable par tout agent ou développeur.
2. **Accès matériel direct depuis un langage interactif** → `pci list`,
   `pci:bar`, `mmio@` en direct au shell.
3. **USB 3.0, NVMe, GPU, réseau en Forth** → là où les OS hobby n'ont souvent
   que le clavier PS/2.
4. **UEFI natif** → pas de BIOS legacy.
5. **Modèle hybride MIT/propriétaire** → ouvert pour l'éducation et les drivers,
   fermé pour le noyau et la chaîne de confiance.
6. **Écosystème de drivers décentralisé** → chaque clé USB collecte, chaque
   issue GitHub produit un driver standard.
7. **Drivers industriels** → Modbus/UART dès aujourd'hui, CAN/SPI/GPIO/ADC/PWM
   sur plateformes dédiées.
8. **Méthodologie double agent** → codeur quotidien + auditeur hebdomadaire,
   tests avant correction.
9. **Cours x86 interactifs** → plateforme éducative, du registre au driver.
10. **IA locale GGUF intégrée (à venir)** → agents tournant dans l'OS lui-même.
11. **Souveraineté** → zéro télémétrie, zéro bloatware, 100 % des cycles CPU
    maîtrisés par l'utilisateur.

---

<a id="guides"></a>
## 14. Guides de développement

| Guide | Description | Statut |
|-------|-------------|--------|
| **PLANNING_CODAGE_FORTH_12_SEMAINES.md** | Planning ISO 2012 (84 jours) | 🚧 S7/12 |
| **devguide_Forth_Iso_2012.md** | Invariants du noyau ISO (modèle mémoire, STATE, parsing) | 🚧 Vivant |
| **docs/API_V1.md** | Contrat Driver API v1 + Application API v1 | 🚧 Gel prévu S8 |
| **forth/std/CORE_WORDS.md** | Table de conformité des mots Core | 🚧 Vivant |
| **forth/TESTS/core2012.fth** | Suite de tests ISO (B0…B33) | ✅ |
| **DEVFORTH.MD** | Manuel primitives Forth | ✅ |
| **DEVSHELL.MD** | Guide shell | ✅ |
| **DEVWATCHDOG.MD** | Guide interruptions | ✅ |
| **DEVMAIN.MD** | Guide noyau | ✅ |
| **DEV_GUIDE_DRIVERS.MD** | Guide drivers Forth | ✅ |
| **DEV_GUIDE_DRIVER_AGENT.MD** | Guide agent codeur (8 phases) | ✅ |

---

## Planning global

```
2026 Août-Oct : Phase 1.5 🚧 Migration Forth ISO 2012 (S1-S7 ✅, S8-S12 à venir)
2026 Nov      : Phase 1.6 — Shell moderne
2026 Déc      : Tests, démos publiques, communication
2027 T1       : Phase 2 — Bureau graphique complet
2027 T2       : Phase 3 — Réseau TCP/IP + TLS + HTTP (+ Modbus TCP)
2027 T3       : Phase 4 — Multimédia
2027 T4       : Phase 5 — IA locale (tenseurs, GGUF, LLM)
2028 T1       : Phase 6 — Embarqué natif (SPI/GPIO/ADC/PWM/CAN) + Bluetooth
2028 T2-T4    : Phase 7 — Installateur, store signé, sécurité renforcée
```

---

## Conclusion

Epona OS ne cherche pas à rivaliser avec Linux sur le terrain du grand public,
mais à créer sa propre catégorie : **l'OS souverain bare-metal, agentique,
éducatif et industriel**.

Avec le Core Forth ISO 2012 désormais complet, le gel de la Driver API v1 en
cours, et la double discipline agent codeur / agent auditeur, les fondations
sont posées avec une rigueur rare pour un projet de cette taille.

---

*Dernière mise à jour : 10 Août 2026*
*Version : 2.0-beta2*
*Auteur : Nicolas, Architecte WeBOo Concept*
*Licence : MIT (Forth système, drivers, outils, docs) + Propriétaire (noyau Rust, boot signé, JIT, sécurité)*
````

### Points d'attention avant de pousser sur GitHub

1. **Vérifiez les plages de primitives** du tableau §12 : j'ai indiqué 388-437 pour l'ISO d'après votre planning, mais ajustez si vos indices réels diffèrent.
2. **S8 : attribuez les indices** des 8 mots Core Ext (`WITHIN`, `U>`, `.R`, `U.R`, `PAD`, `S\"`, `:NONAME`, `COMPILE,`) dès que l'agent codeur les aura choisis — la roadmap dit « indices à définir », il faudra les figer.
3. **La matrice de faisabilité industrielle** est volontairement prudente : si vous avez déjà du SPI/GPIO fonctionnel sur une carte précise, dites-le-moi et je la corrige.

Voulez-vous aussi que je prépare le message de commit et une entrée de changelog pour cette mise à jour ?
