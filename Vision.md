# 🐴 Vision d'Epona OS

> **Dernière mise à jour** : 10 Août 2026
> **Version** : 1.98-beta2

---

## 🌌 Ce qu'est Epona OS aujourd'hui

Un système d'exploitation **bare-metal UEFI** écrit en **Rust**, avec un
**interpréteur Forth ISO 2012** intégré et un **JIT x86-64**.
Il démarre sur du vrai matériel — sans Linux, sans Windows, sans rien.

```
Métal nu → UEFI → Rust → Forth ISO 2012 → Bureau graphique
741+ primitives (dont 133/133 Core ISO 2012 complet)
13 drivers Forth (.fth) fonctionnels
GPU, USB 3.0, NVMe, AHCI, réseau, audio HDA
Multitâche préemptif
Suite de tests automatisés (core2012.fth, B0…B33, NB-FAILS = 0)
Double contrôle : agent codeur + agent auditeur
Bootable sur clé USB Live (Intel + AMD + QEMU)
```

Epona OS n'est plus un simple exploit technique : c'est une **plateforme
opérationnelle** avec un noyau Forth conforme au standard international,
un écosystème de drivers décentralisé et un positionnement unique au monde.

---

## 🏛️ Modèle de licence hybride

Epona OS utilise un modèle **hybride** qui garantit à la fois l'ouverture et
la sécurité :

```
┌──────────────────────────────────────────────────────────────────┐
│                   ESPACE OUVERT & MIT (FTH)                      │
│  - Bureau & Widgets personnalisés                                │
│  - Pilotes (.fth) : PCI, USB, UART, Modbus, CAN, SPI, GPIO…     │
│  - Agents IA, Dashboards, Applications & Outils Éducatifs        │
│  - Documentation, Tests & Standard Forth ISO 2012                │
└─────────────────────────────────┬────────────────────────────────┘
                                  │ Appel aux primitives (API v1)
┌─────────────────────────────────▼────────────────────────────────┐
│                NOYAU PROPRIÉTAIRE Epona OS (RUST)                │
│  - Noyau bare-metal & boot signé (chaîne de confiance)           │
│  - Moteur d'exécution Forth & JIT interne                        │
│  - Sandbox mémoire, isolation des tâches & sécurité matérielle   │
└──────────────────────────────────────────────────────────────────┘
```

- **Côté utilisateur / éducation / makers (MIT)** : liberté totale.
  N'importe quel étudiant, hacker ou agent IA peut lire, modifier et créer
  des scripts `.fth` sans licence restrictive.
- **Côté noyau / sécurité (propriétaire)** : garantie d'intégrité.
  Le boot signé et le cœur Rust protègent la chaîne de confiance et la
  propriété intellectuelle.

---

## 🎯 La vision unifiée : quatre piliers

La direction n'est plus un choix entre trois futurs possibles. Epona OS
poursuit simultanément **quatre piliers** qui se renforcent mutuellement :

### 🎓 Pilier 1 — Plateforme éducative x86 unique au monde

Epona OS est **le meilleur outil pour apprendre comment un ordinateur
fonctionne**, du registre CPU au driver réseau.

- Un étudiant tape `pci list`, voit son GPU, tape `pci:bar` pour trouver
  l'adresse mémoire, puis fait `mmio@` pour lire directement les registres.
- Pas de couche d'abstraction opaque : pas de POSIX, pas de Win32, pas de
  `systemd`, pas de `ioctl`. Tout est visible et modifiable.
- Chaque fichier `.fth` est un cours interactif : texte, exercices, solutions.
- Le bureau lui-même est un script Forth : l'étudiant peut recoder son propre
  gestionnaire de fenêtres, sa console cyberpunk ou son tableau de bord.

> Aucun autre projet au monde ne permet de « toucher le métal » aussi
> directement tout en restant dans un langage standardisé (ISO 2012).

### 🏭 Pilier 2 — Plateforme industrielle et embarquée

Epona OS cible l'automatisme, les bancs de test et la supervision :
CAN, Modbus, UART, SPI, GPIO, ADC, PWM — pilotables en Forth avec une
latence déterministe et un code auditable ligne par ligne.

**Ce qui fonctionne dès aujourd'hui** (sur tout PC x86 avec port série) :

```forth
\ === DRIVER MODBUS-RTU / UART — Conforme API v1 (MIT) ===
0x3F8 value COM1-BASE
: uart-tx-ready? ( -- flag ) COM1-BASE 5 + inb 0x20 and 0<> ;
: uart-emit      ( char -- ) begin uart-tx-ready? until COM1-BASE outb ;
: modbus-send-frame ( addr len -- )
  0 do dup i + c@ uart-emit loop drop ;
```

1. 100 % lisible par un humain ou un agent IA.
2. Exécuté directement sur le métal, sans pile tty/serial de 10 000 lignes.
3. Latence déterministe — pas d'ordonnanceur opaque derrière.

**Feuille de route industrielle** :

| Protocole | Accès | Disponibilité |
|-----------|-------|---------------|
| UART (COM1-4) | Ports I/O directs | ✅ Aujourd'hui |
| Modbus RTU | Surcouche UART + CRC16 | ✅ Aujourd'hui |
| I2C / SMBus | Contrôleur chipset | 🚧 Partiel |
| Modbus TCP | Pile réseau | ⬜ T2 2027 |
| SPI, GPIO, ADC, PWM | SoC industriel ou adaptateur | ⬜ T1 2028 |
| CAN / CANopen | Carte PCIe/USB-CAN | ⬜ T1 2028 |

### 🛡️ Pilier 3 — Cyber-sécurité et souveraineté numérique

Dans le domaine de la cyber-sécurité, Epona OS apporte des propriétés
uniques :

1. **Surface d'attaque minimale** : aucun binaire ELF opaque, aucun démon
   caché, aucune pile réseau complexe dissimulée, aucune porte dérobée de
   distribution.
2. **Auditabilité totale** : l'expert sécurité peut auditer l'intégralité du
   code exécuté (`words`, `memory[]`, `BOOT.FTH`).
3. **Boot signé** : le noyau Rust valide la chaîne de confiance au démarrage.
4. **Zéro télémétrie** : seul le code présent dans `BOOT.FTH` s'exécute.
   L'utilisateur maîtrise 100 % des cycles CPU de sa machine.
5. **100 % français et souverain** : alternative aux OS américains pour les
   contextes sensibles.

> **Formulation honnête** : le bare-metal et l'absence de Linux *réduisent*
> la surface d'attaque et rendent le système *auditable*. Ils ne dispensent
> ni de la validation, ni de l'isolation, ni d'une politique de mise à jour.

### ⚡ Pilier 4 — Meilleure implémentation Forth bare-metal moderne

Epona OS est la **première et seule** implémentation Forth bare-metal qui
combine :

- **Conformité ISO 2012 complète** (133/133 Core) — un agent ou un
  développeur écrit du Forth standard, pas un dialecte maison.
- **JIT x86-64** pour les boucles chaudes.
- **Accès matériel complet** : GPU, USB 3.0 xHCI, NVMe, AHCI, audio HDA,
  réseau e1000/virtio, PCI, MMIO, IRQ, APIC, ACPI, SMBIOS, RTC.
- **Multitâche préemptif** avec scheduler.
- **Flottants IEEE 754** (45 primitives).
- **Vocabulaires et variables locales**.
- **741+ primitives** couvrant du calcul de pile au pilotage matériel.

---

## 🔄 Écosystème de drivers décentralisé

Chaque clé USB Epona est un **nœud de collecte**. Chaque issue GitHub
devient un **ticket de travail reproductible** pour un agent.

```
Machine utilisateur (clé USB Live)
  │
  ├─ pci save       → /MATERIEL/<machine>_<date>.txt
  ├─ hw-check       → compare avec drivers/ présents sur la clé
  │                 → drivers_manquants.txt (PCI ID + class/subclass)
  │
  ▼
Issue GitHub automatique
  │
  ▼
Agent codeur (humain ou IA)
  ├─ lit docs/API_V1.md + WRITING_DRIVERS.md   (obligatoire)
  ├─ écrit le driver en Forth ISO 2012 strict
  ├─ drv:name! / drv:register / drv:probe / drv:init
  │
  ▼
Publication dans drivers/ → toute clé USB équipée du même matériel
en bénéficie
```

**Règle absolue** : deux documents obligatoires avant toute écriture de
driver. Protocole v1 figé. Forth ISO 2012 uniquement — aucune syntaxe
propriétaire côté driver.

---

## 👥 Publics cibles

| Public | Proposition de valeur |
|--------|----------------------|
| 💡 **Geeks & passionnés d'architecture** | Comprendre le fonctionnement réel d'un ordinateur et piloter le processeur sans couche d'abstraction opaque |
| 🦀 **Développeurs bas-niveau (Rust, ASM, Forth)** | Écrire des programmes et des pilotes bare-metal sans dépendance lourde |
| 🔌 **Makers, électroniciens & hardware hackers** | Piloter puces, FPGA, modules USB et microcontrôleurs depuis l'OS, sans SDK ni IDE lourd |
| 🛠️ **Bidouilleurs hardware & créateurs d'OS** | Tester instructions machine, drivers et interfaces graphiques en direct sur le métal |
| 🇫🇷 **Adeptes d'OS souverains & minimalistes** | Environnement sans bloatware, autonome et agentique |
| 🏭 **Industriels & intégrateurs** | Automatisme, bancs de test, supervision via CAN, Modbus, UART, SPI, GPIO |
| 🎓 **Écoles & universités** | Plateforme pédagogique x86 unique — du registre CPU au driver, tout est visible |
| 🤖 **Agents IA & développement agentique** | Agents qui écrivent, auditent et exécutent des `.fth` de façon autonome |

---

## 🧪 Méthodologie de développement

### Double agent

| Agent | Rôle | Fréquence |
|-------|------|-----------|
| **Agent codeur** | Suit le planning quotidien, une modification limitée par séance, écrit les tests avant la correction | Quotidien (2 h/jour) |
| **Agent auditeur** | Relit le code source Rust, cherche incohérences et bugs silencieux | Hebdomadaire |

### Règles strictes

1. Ne modifier qu'un seul sous-système par séance.
2. Écrire la signature de pile avant le code.
3. Ne jamais ajouter un mot standard sans test.
4. Chaque semaine se termine par une journée de stabilisation.
5. Ne pas annoncer la conformité ISO avant les tests de régression.

### Résultats mesurables

| Métrique | Valeur (au 2026-08-09) |
|----------|------------------------|
| Core ISO 2012 | **133/133** (complet) |
| Bugs critiques corrigés par l'audit | 7+ (`-rot`, `tuck`, `alloc`, locales, `S"`, `sys:load`, `parse_number`) |
| Régressions de boot | 0 |
| Builds cassés | 0 |
| Suite de tests | core2012.fth B0…B33, NB-FAILS = 0 |

---

## 📅 Planning global

```
2026 Août-Oct   : Migration Forth ISO 2012 (S1-S7 ✅, S8-S12 en cours)
                  Gel Driver API v1 et Application API v1
2026 Nov        : Shell moderne (édition de ligne, historique, complétion)
2026 Déc        : Tests, démos publiques, communication

2027 T1         : Phase 2 — Bureau graphique complet
                  Fenêtres, dessin avancé, sprites, polices, décodeur PNG/BMP
2027 T2         : Phase 3 — Réseau TCP/IP + TLS + HTTP + WebSocket
                  Modbus TCP, serveur HTTP en Forth, package manager réseau
2027 T3         : Phase 4 — Multimédia
                  Audio HDA avancé, synthétiseur FM, décodeur WAV
2027 T4         : Phase 5 — IA locale bare-metal
                  Moteur de tenseurs, chargeur GGUF, LLM quantizé, AVX2

2028 T1         : Phase 6 — Embarqué natif
                  SPI, GPIO, ADC, PWM, CAN/CANopen, Bluetooth HCI
2028 T2-T4      : Phase 7 — OS « vrai »
                  Installateur sur disque, store signé (.EPA), sécurité renforcée
```

---

## 🌍 Ce qui rend Epona OS unique

1. **Forth ISO 2012 bare-metal avec JIT** → unique au monde ; code standard,
   universel, écrivable par tout agent ou développeur.
2. **Accès matériel direct depuis un langage interactif** → `pci list`,
   `pci:bar`, `mmio@` en direct au shell.
3. **USB 3.0, NVMe, GPU, réseau en Forth** → là où les OS hobby n'ont
   souvent que le clavier PS/2.
4. **UEFI natif** → pas de BIOS legacy.
5. **Modèle hybride MIT / propriétaire** → ouvert pour l'éducation et les
   drivers, fermé pour le noyau et la chaîne de confiance.
6. **Écosystème de drivers décentralisé** → chaque clé USB collecte, chaque
   issue GitHub produit un driver standard.
7. **Drivers industriels** → Modbus/UART dès aujourd'hui, CAN/SPI/GPIO sur
   plateformes dédiées à venir.
8. **Méthodologie double agent** → codeur quotidien + auditeur hebdomadaire.
9. **Plateforme éducative x86** → du registre CPU au driver, tout est
   visible et modifiable.
10. **IA locale GGUF intégrée** (à venir) → agents tournant dans l'OS
    lui-même.
11. **Souveraineté** → zéro télémétrie, zéro bloatware, 100 % des cycles
    CPU maîtrisés par l'utilisateur.
12. **Zéro application obligatoire** → le bureau est un script `.fth`,
    unique pour chaque utilisateur.

---

## ⚠️ Les dangers à éviter

- **Feature creep** : ajouter sans fin au lieu de polir. Le planning de
  12 semaines impose une discipline stricte : un seul sous-système par
  séance, tests avant correction.
- **Syndrome du développeur unique** : documenter, tester, ouvrir. La
  méthodologie double agent et l'écosystème de drivers décentralisé sont
  conçus pour éviter cette dépendance.
- **Absence d'utilisateurs** : publier tôt, montrer des démos. La release
  candidate UEFI (fin octobre 2026) est le premier jalon public.
- **Compatibilité matérielle** : tester sur plusieurs machines. La boucle
  `pci save` → `hw-check` → issue GitHub → agent automatise la collecte
  et la production de drivers.
- **Promesses de sécurité excessives** : le bare-metal réduit la surface
  d'attaque mais ne la supprime pas. Chaque affirmation de sécurité doit
  être validée et qualifiée.

---

## 🌠 Vision à deux ans

| Scénario | Objectif |
|----------|----------|
| **Optimiste** | v3.0 : JIT x86-64 mature, 800+ primitives, IA locale GGUF, communauté active, drivers industriels CAN/SPI/GPIO, adoption éducative |
| **Réaliste** | v2.5 : Forth ISO 2012 complet + Extensions, bureau graphique fluide, documentation exemplaire, 30+ drivers communautaires, premiers utilisateurs industriels |
| **Minimum viable** | v2.2 : USB bootable stable, Core ISO complet, API Driver v1 gelée, 5 drivers de référence, publication GitHub, premières contributions externes |

---

## 📚 Guides de développement

| Guide | Description | Statut |
|-------|-------------|--------|
| **PLANNING_CODAGE_FORTH_12_SEMAINES.md** | Planning ISO 2012 (84 jours) | 🚧 S8/12 |
| **devguide_Forth_Iso_2012.md** | Invariants du noyau ISO | 🚧 Vivant |
| **docs/API_V1.md** | Contrat Driver API v1 + Application API v1 | 🚧 Gel S8 |
| **forth/std/CORE_WORDS.md** | Table de conformité Core | 🚧 Vivant |
| **ROADMAP.md** | Phases 1-7 détaillées | ✅ |
| **DEVFORTH.MD** | Manuel 741+ primitives | ✅ |
| **DEVSHELL.MD** | Guide shell | ✅ |
| **DEV_GUIDE_DRIVERS.MD** | Guide drivers Forth | ✅ |
| **DEV_GUIDE_DRIVER_AGENT.MD** | Guide agent codeur (8 phases) | ✅ |

---

*Auteur : Nicolas, Architecte WeBOo Concept*
*Licence : MIT (Forth système, drivers, outils, docs) + Propriétaire (noyau Rust, boot signé, JIT, sécurité)*

---

# 🐴 Vision of Epona OS

> **Last updated**: August 10, 2026
> **Version**: 2.0-beta2

---

## 🌌 What Epona OS is today

A **bare-metal UEFI** operating system written in **Rust**, with an integrated
**Forth ISO 2012 interpreter** and an **x86-64 JIT**.
It boots on real hardware — no Linux, no Windows, nothing in between.

```
Bare metal → UEFI → Rust → Forth ISO 2012 → Graphical desktop
741+ primitives (including 133/133 Core ISO 2012 — complete)
13 working Forth drivers (.fth)
GPU, USB 3.0, NVMe, AHCI, network, HDA audio
Preemptive multitasking
Automated test suite (core2012.fth, B0…B33, NB-FAILS = 0)
Dual control: coder agent + auditor agent
Bootable from USB drive (Intel + AMD + QEMU)
```

Epona OS is no longer just a technical feat: it is an **operational platform**
with a standard-compliant Forth kernel, a decentralized driver ecosystem, and
a unique positioning worldwide.

---

## 🏛️ Hybrid licensing model

Epona OS uses a **hybrid** model ensuring both openness and security:

- **MIT (open-source)**: Forth system, `.fth` drivers, agents, dashboards,
  desktop, tools, documentation, tests.
- **Proprietary**: Rust kernel, signed boot, internal JIT, security modules.

---

## 🎯 The unified vision: four pillars

### 🎓 Pillar 1 — A unique x86 educational platform

The **best tool to learn how a computer works**, from CPU registers to
network drivers. No opaque abstraction layers. Every `.fth` file is an
interactive lesson. The desktop itself is a Forth script the student can
rewrite from scratch.

> No other project in the world lets you "touch the metal" this directly
> while staying within a standardized language (ISO 2012).

### 🏭 Pillar 2 — An industrial and embedded platform

Targeting automation, test benches and supervision: CAN, Modbus, UART,
SPI, GPIO, ADC, PWM — controllable in Forth with deterministic latency
and line-by-line auditable code.

- **Available today**: UART direct (COM1-4 via `inb`/`outb`), Modbus RTU.
- **Planned**: Modbus TCP (Q2 2027), SPI/GPIO/ADC/PWM/CAN (Q1 2028).

### 🛡️ Pillar 3 — Cybersecurity and digital sovereignty

Minimal attack surface, total auditability, signed boot, zero telemetry.
100% French and sovereign — an alternative to American operating systems
for sensitive contexts.

> **Honest statement**: bare-metal and the absence of Linux *reduce* the
> attack surface and make the system *auditable*. They do not substitute
> for validation, isolation, or an update policy.

### ⚡ Pillar 4 — The best modern bare-metal Forth implementation

The first and only bare-metal Forth combining **full ISO 2012 compliance**
(133/133 Core), **x86-64 JIT**, **complete hardware access** (GPU, USB 3.0,
NVMe, AHCI, HDA, e1000, PCI, MMIO, IRQ, ACPI, SMBIOS), **preemptive
multitasking**, **IEEE 754 floating point**, and **741+ primitives**.

---

## 🔄 Decentralized driver ecosystem

Every Epona USB drive is a **collection node**. Every GitHub issue becomes
a **reproducible work ticket** for an agent.

```
User machine (Live USB)
  ├─ pci save     → /MATERIEL/<machine>_<date>.txt
  ├─ hw-check     → compares with drivers/ on the drive
  │               → missing_drivers.txt (PCI ID + class/subclass)
  ▼
Automatic GitHub issue
  ▼
Coder agent (human or AI)
  ├─ reads docs/API_V1.md + WRITING_DRIVERS.md (mandatory)
  ├─ writes the driver in strict Forth ISO 2012
  ▼
Published in drivers/ → every USB drive with the same hardware benefits
```

---

## 👥 Target audiences

| Audience | Value proposition |
|----------|-------------------|
| 💡 Architecture enthusiasts | Understand how a computer really works — no opaque layers |
| 🦀 Low-level developers | Write bare-metal programs and drivers without heavy dependencies |
| 🔌 Makers & hardware hackers | Drive chips, FPGAs, USB modules directly from the OS |
| 🇫🇷 Sovereign OS advocates | Bloatware-free, autonomous, agentic environment |
| 🏭 Industrialists & integrators | Automation, test benches, supervision via CAN, Modbus, UART |
| 🎓 Schools & universities | Unique x86 teaching platform — from CPU register to driver |
| 🤖 AI agents | Agents that write, audit and execute `.fth` files autonomously |

---

## 📅 Global timeline

```
2026 Aug-Oct    : Forth ISO 2012 migration (S1-S7 ✅, S8-S12 in progress)
                  Driver API v1 and Application API v1 freeze
2026 Nov        : Modern shell (line editing, history, completion)
2026 Dec        : Tests, public demos, communication

2027 Q1         : Phase 2 — Full graphical desktop
2027 Q2         : Phase 3 — TCP/IP + TLS + HTTP + WebSocket network stack
2027 Q3         : Phase 4 — Multimedia (HDA audio, FM synth, WAV)
2027 Q4         : Phase 5 — Local bare-metal AI (tensors, GGUF, quantized LLM)

2028 Q1         : Phase 6 — Native embedded (SPI, GPIO, ADC, PWM, CAN, BT)
2028 Q2-Q4      : Phase 7 — "Real" OS (disk installer, signed store, security)
```

---

## 🌍 What makes Epona OS unique

1. **Bare-metal Forth ISO 2012 with JIT** → unique worldwide.
2. **Direct hardware access from an interactive language** → `pci list`,
   `pci:bar`, `mmio@` right at the shell.
3. **USB 3.0, NVMe, GPU, networking in Forth** → hobby OSes typically only
   have PS/2 keyboard support.
4. **Native UEFI** → no legacy BIOS.
5. **Hybrid MIT / proprietary model** → open for education and drivers,
   closed for kernel and trust chain.
6. **Decentralized driver ecosystem** → every USB drive collects, every
   GitHub issue produces a standard driver.
7. **Industrial drivers** → Modbus/UART today, CAN/SPI/GPIO on dedicated
   platforms coming.
8. **Dual agent methodology** → daily coder + weekly auditor.
9. **x86 educational platform** → from CPU register to driver, everything
   is visible and modifiable.
10. **Local GGUF AI** (planned) → agents running inside the OS itself.
11. **Sovereignty** → zero telemetry, zero bloatware, 100% of CPU cycles
    controlled by the user.
12. **Zero mandatory application** → the desktop is a `.fth` script, unique
    per user.

---

## ⚠️ Dangers to avoid

- **Feature creep**: the 12-week planning enforces strict discipline.
- **Single developer syndrome**: the dual agent methodology and decentralized
  driver ecosystem are designed to prevent this dependency.
- **Absence of users**: publish early, show demos. The UEFI release candidate
  (end of October 2026) is the first public milestone.
- **Hardware compatibility**: the `pci save` → `hw-check` → GitHub issue →
  agent loop automates driver collection and production.
- **Overstated security claims**: bare-metal reduces the attack surface but
  does not eliminate it. Every security assertion must be validated.

---

## 🌠 Two-year vision

| Scenario | Objective |
|----------|-----------|
| **Optimistic** | v3.0: mature x86-64 JIT, 800+ primitives, local GGUF AI, active community, industrial CAN/SPI/GPIO drivers, educational adoption |
| **Realistic** | v2.5: complete Forth ISO 2012 + Extensions, fluid graphical desktop, exemplary documentation, 30+ community drivers, first industrial users |
| **Minimum viable** | v2.2: stable bootable USB, complete Core ISO, frozen Driver API v1, 5 reference drivers, GitHub publication, first external contributions |

---

*Author: Nicolas, Architect WeBOo Concept*
*License: MIT (Forth system, drivers, tools, docs) + Proprietary (Rust kernel, signed boot, JIT, security)*
````

---

### Changements principaux par rapport à l'ancien `vision.md`

| Ancien | Nouveau |
|--------|---------|
| « 290+ primitives » | **741+ primitives** dont 133/133 Core ISO 2012 |
| « Trois futurs possibles (A/B/C) » | **Quatre piliers unifiés** : éducatif, industriel, souverain, Forth moderne |
| Pas de mention de licence | **Modèle hybride MIT / Propriétaire** affirmé |
| Pas de méthodologie | **Double agent** (codeur + auditeur) documenté |
| Pas de drivers industriels | **Matrice CAN/Modbus/UART/SPI/GPIO** avec faisabilité honnête |
| Pas d'écosystème de collecte | **Boucle `pci save` → `hw-check` → issue → agent** |
| Tableau bilingue séparé en deux blocs désordonnés | **Document bilingue propre** FR puis EN |
| « Recommandation : combiner A+C court terme » | **Planning global 2026-2028 aligné sur le planning 12 semaines** |
