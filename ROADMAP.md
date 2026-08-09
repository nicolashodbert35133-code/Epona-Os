# 🐴 Vision d'Epona OS / Vision of Epona OS

> **Version** : 1.98-beta3
> **Dernière mise à jour** : 9 août 2026
> **Auteur** : Nicolas — WeBOo Concept
> **Licence** : MIT (Forth, drivers, applications, documentation) + Propriétaire (noyau Rust, boot signé, JIT, sécurité)

---

## 🌌 Ce qu'est Epona OS aujourd'hui

Un système d'exploitation **bare-metal UEFI** écrit en **Rust**, avec un **interpréteur Forth ISO 2012** intégré.
Il démarre sur du vrai matériel — sans Linux, sans Windows, sans rien d'autre.

```
Métal nu → UEFI → Rust → Forth ISO 2012 → Shell / Bureau graphique

440+ primitives matériel
13 drivers Forth opérationnels
Forth ISO 2012 Core complet (133/133) et testé
GPU (GOP), USB 3.0 (xHCI), NVMe, AHCI, réseau (e1000), audio (HDA)
Multitâche préemptif
JIT x86-64 avec fallback interprété garanti
Suite de tests automatisés (NB-FAILS = 0)
Modèle hybride : MIT (Forth) + Propriétaire (noyau Rust)
Pilotes industriels natifs : CAN, Modbus, UART, SPI, GPIO, ADC, PWM
```

> **Ce projet s'adresse aux passionnés de bas-niveau, aux geeks, aux makers, aux bidouilleurs hardware, aux ingénieurs, aux professionnels de la cybersécurité, et à tous ceux qui veulent coder sur le métal, manipuler le hardware en direct, et comprendre comment fonctionne un ordinateur.**

Epona OS n'est plus seulement un exploit technique. C'est un **socle universel** : le code Forth écrit pour Epona est du Forth standard, lisible par n'importe quel développeur ou agent, et exécutable directement sur le métal.

---

## 🏗️ Architecture hybride

```
┌──────────────────────────────────────────────────────────────────┐
│                   ESPACE OUVERT — MIT (.fth)                     │
│  • Bureau, widgets, thèmes, jeux                                 │
│  • Pilotes industriels (CAN, Modbus, UART, SPI, GPIO, ADC, PWM)  │
│  • Pilotes matériels génériques (xHCI, AHCI, NVMe, HDA, e1000)   │
│  • Agents, dashboards, applications, outils éducatifs            │
│  • Bibliothèque standard Forth ISO 2012, tests, documentation    │
│  • Passerelle Raspberry Pi / Arduino / ESP32 / STM32             │
└─────────────────────────────┬────────────────────────────────────┘
                              │ API v1 — contrat figé
┌─────────────────────────────▼────────────────────────────────────┐
│              NOYAU PROPRIÉTAIRE — RUST (fermé)                   │
│  • Micro-noyau bare-metal, boot signé, chaîne de confiance       │
│  • Interpréteur Forth + JIT interne                              │
│  • Sandbox mémoire (check_mem), isolation des tâches             │
│  • Mapping MMIO, tables de pages, IDT/GDT, APIC/IOAPIC           │
│  • Modules de sécurité et validation de drivers                  │
└──────────────────────────────────────────────────────────────────┘
```

**Ce qu'un pilote `.fth` peut faire** : lire et écrire des registres via les primitives publiées (`mmio@`, `pci:bar`, `irq:attach`), piloter un UART, un bus SPI, des GPIO.
**Ce qu'il ne peut pas faire** : toucher directement une table de pages, l'IDT ou une BAR non validée. Le noyau Rust reste seul responsable de la survie de la machine.

**Conséquence** : un pilote Epona s'audite ligne par ligne. La confiance ne repose plus sur l'éditeur du binaire, mais sur la **lisibilité du code** — un atout majeur pour la cybersécurité et l'audit industriel.

---

## 🎯 Publics cibles

| Public | Besoin couvert |
|--------|----------------|
| 💡 **Geeks & architectes** | Comprendre le fonctionnement réel d'un PC, piloter le CPU sans couche d'abstraction opaque |
| 🦀 **Développeurs bas-niveau** (Rust, ASM, Forth) | Écrire des programmes et pilotes bare-metal sans dépendance lourde |
| 🔌 **Makers, électroniciens & hardware hackers** | Piloter puces custom, FPGA, modules USB, microcontrôleurs sans SDK ni IDE |
| 🍓 **Communauté Raspberry Pi / Arduino / ESP32 / STM32** | Retrouver la même simplicité GPIO/SPI/I2C/UART que sur un microcontrôleur, mais sur x86 — et piloter ses cartes depuis Epona via UART/USB |
| 🛠️ **Bidouilleurs & créateurs d'OS** | Tester instructions machine, drivers et interfaces graphiques en direct sur le métal |
| 🏭 **Intégrateurs industriels** | CAN, Modbus, UART, SPI, GPIO sans pile Linux de 30 millions de lignes |
| 🎓 **Enseignement supérieur** | Plateforme x86 pédagogique unique : PCI, IRQ, MMIO, mémoire manipulés interactivement |
| 🛡️ **Cybersécurité & souveraineté** | OS auditable ligne par ligne (`BOOT.FTH`, `.fth` drivers), surface d'attaque minimale, boot signé, zéro télémétrie |
| 🇫🇷 **Adeptes d'OS souverains** | Environnement sans bloatware, autonome, 100 % français |
| 🏗️ **Ingénieurs système & industriels** | Développement rapide de prototypes, bancs de test, supervision temps réel sur du matériel réel — sans attendre la compilation d'un noyau Linux |

---

## 🍓 Pourquoi les makers Raspberry Pi / Arduino vont aimer Epona OS

### Le problème qu'ils connaissent

Un utilisateur Arduino ou Raspberry Pi est habitué à :

```c
// Arduino
digitalWrite(13, HIGH);
analogRead(A0);
Serial.begin(115200);
SPI.transfer(0x42);
Wire.beginTransmission(0x3C);
```

C'est simple, direct, concret : **une ligne = un effet sur le matériel**.

Mais dès qu'il passe sur un PC x86, il tombe dans un gouffre :
- installer un OS (Linux, Windows)
- installer un SDK, un compilateur, des dépendances
- écrire un programme en C/Python
- utiliser des couches d'abstraction (`libgpiod`, `/dev/spidev`, `pyserial`)
- compiler, transférer, debugger à travers 15 couches

**La magie du « je tape une ligne et le matériel bouge » disparaît.**

### Ce qu'Epona OS leur offre

Sur Epona, ils retrouvent **exactement la même simplicité**, mais sur x86 :

```forth
\ Allumer une LED sur GPIO (via un contrôleur PCH/chipset)
13 1 gpio:write

\ Lire un ADC
0 adc:read .

\ Envoyer un octet SPI
0x42 spi:emit

\ Initialiser un UART à 115200
0x3F8 115200 uart:init

\ Envoyer un message série
s" Hello from Epona!" uart:type

\ Lire la température I2C d'un capteur
0x48 0x00 i2c-read .
```

**Une ligne = un effet sur le matériel. Pas de compilation, pas de SDK, pas de couche d'abstraction.**

### Le pont entre les mondes

Epona OS ne remplace pas un Arduino ou un Raspberry Pi — il les **complète** :

```
┌────────────────────┐     UART / USB / SPI     ┌──────────────────┐
│    EPONA OS        │◄────────────────────────►│  Arduino / RPi    │
│    (PC x86)        │                           │  (MCU / SBC)      │
│                    │                           │                   │
│  • Shell Forth     │   Protocole Modbus,       │  • Capteurs       │
│  • Dashboard       │   série brut, ou          │  • Actuateurs     │
│  • Data logging    │   protocole custom        │  • GPIO           │
│  • Analyse temps   │                           │  • ADC/PWM        │
│    réel            │                           │                   │
└────────────────────┘                           └──────────────────┘
```

**Cas d'usage concrets :**

| Scénario | Rôle d'Epona | Rôle du MCU |
|----------|-------------|-------------|
| **Station météo** | Dashboard temps réel, stockage NVMe, affichage GOP | Arduino + capteurs DHT22/BMP280 via UART |
| **Banc de test moteur** | Acquisition, tracé, export CSV | STM32 + encodeur/PWM |
| **Domotique** | Serveur Modbus, journalisation, alertes | ESP32 + relais/capteurs |
| **Robot mobile** | Planification, télémétrie, vision (future IA locale) | Raspberry Pi Pico + moteurs/servos |
| **Enseignement** | Démonstration UART/SPI/I2C côté x86, analyse protocole | Arduino comme cible pédagogique |
| **Cybersécurité matérielle** | Audit direct des registres, analyse de bus, détection d'intrusion bas niveau | Module sécurisé (STM32) comme périphérique de confiance |

### Exemple complet : moniteur série Arduino depuis Epona

```forth
\ === MONITEUR SÉRIE ARDUINO — Epona OS ===
\ Branchez un Arduino sur COM1 (UART 0x3F8)
\ L'Arduino envoie des lignes "TEMP=23.5\n"

0x3F8 115200 uart:init drop

create buf 80 allot

: uart-line ( buf max -- len )
    0 { len }
    begin
        uart:key
        dup 10 = if drop len exit then
        over len + c!
        len 1+ to len
        len over >= until
    drop len ;

: monitor ( -- )
    ." === Moniteur série Epona ===" cr
    ." Appuyez Escape pour quitter" cr cr
    begin
        buf 80 uart-line
        dup 0 > if buf swap type cr then
        key? if key 27 = if exit then then
    again ;

monitor
```

### Comparaison directe : Arduino / MicroPython / Epona Forth

| Opération | Arduino (C++) | MicroPython (RPi) | Epona Forth |
|-----------|---------------|--------------------|----|
| Allumer LED | `digitalWrite(13, HIGH);` | `Pin(13, Pin.OUT).value(1)` | `13 1 gpio:write` |
| Lire ADC | `analogRead(A0);` | `ADC(Pin(26)).read_u16()` | `0 adc:read` |
| Envoyer série | `Serial.println("Hi");` | `uart.write("Hi")` | `s" Hi" uart:type` |
| Transfert SPI | `SPI.transfer(0x42);` | `spi.write(b'\x42')` | `0x42 spi:emit` |
| Lire I2C | `Wire.read();` | `i2c.readfrom(0x48,1)` | `0x48 0 i2c-read` |
| Délai | `delay(1000);` | `time.sleep(1)` | `1000 ms` |

**La syntaxe Forth est aussi concise que l'Arduino, et plus directe que Python.**

Mais Epona ajoute ce qu'aucun MCU ne fournit :

- un **shell interactif** : tapez `0 adc:read .` et voyez la valeur **immédiatement**
- un **éditeur de code** intégré
- un **bureau graphique** pour les dashboards
- du **stockage NVMe** (pas de carte SD lente)
- du **réseau TCP/IP** natif
- un **JIT x86-64** pour le calcul lourd
- la possibilité de **sauvegarder le code sur clé USB** et le recharger au boot
- à terme, de l'**IA locale** pour analyser les données capteurs

---

## 🚀 Philosophie : zéro bloatware, 100 % liberté

```
┌──────────────────────────────────────────────────────────────────┐
│         PHILOSOPHIE EPONA OS : ZÉRO BLOATWARE • 100 % LIBERTÉ    │
├──────────────────────────────────────────────────────────────────┤
│  ✓ Zéro application obligatoire préinstallée                     │
│  ✓ Zéro processus d'arrière-plan caché, zéro télémétrie          │
│  ✓ Un bureau sur-mesure codé en Forth, unique par utilisateur    │
│  ✓ Vos pilotes, vos widgets, vos jeux sur votre clé USB Live     │
│  ✓ Seul le code présent dans BOOT.FTH s'exécute                  │
│  ✓ Chaque cycle CPU de votre machine vous appartient              │
│  ✓ La même simplicité GPIO/SPI/UART que sur un Arduino            │
│  ✓ Un projet pour ceux qui veulent coder sur le métal             │
└──────────────────────────────────────────────────────────────────┘
```

L'environnement graphique est entièrement composé de scripts `.fth` ouverts. Chaque utilisateur crée son propre bureau : fenêtré classique, interface radiale, cyberpunk, minimaliste ou pur terminal. **Vous décidez de ce que charge `BOOT.FTH`. Votre système contient uniquement ce dont vous avez besoin.**

---

## 👥 Pourquoi ce projet s'adresse aussi aux ingénieurs et aux professionnels de la cybersécurité

### Pour les ingénieurs système et industriels

Epona OS est conçu comme un **outil de développement et de prototypage rapide**, pas comme un système d'exploitation grand public. Un ingénieur peut :

- **lire un registre PCI** avec `pci:bar` et `mmio@` sans compiler un module noyau
- **piloter un UART industriel** en 5 lignes Forth plutôt qu'en 500 lignes C
- **créer un banc de test** avec un dashboard graphique intégré, sans dépendre d'un framework externe
- **sauvegarder sa configuration sur une clé USB** et la déployer sur plusieurs machines sans réinstallation

Le langage Forth, combiné au noyau Rust propriétaire, offre un compromis rare :
- **l'ouverture et la transparence** du côté Forth (pilotes, applications, tests)
- **la fiabilité et la sécurité** du côté noyau (boot signé, isolation mémoire, sandbox)

### Pour la cybersécurité et la défense

Dans un contexte où la **souveraineté numérique** et la **réduction de la surface d'attaque** sont prioritaires :

- **Aucun binaire ELF opaque** : tout le code Forth (`BOOT.FTH`, `.fth` drivers, `.fth` applications) est du texte lisible. Un auditeur peut inspecter chaque ligne.
- **Aucune télémétrie cachée** : pas de processus d'arrière-plan, pas d'envoi automatique de données.
- **Boot signé** : la chaîne de confiance commence au firmware et se poursuit dans le noyau Rust.
- **Sandbox mémoire** : la frontière `check_mem` isole strictement l'espace Forth de la mémoire système.
- **Envoi volontaire uniquement** : `hw-check` produit un fichier local. L'envoi vers GitHub (`hw-submit`) exige une confirmation explicite et une anonymisation.
- **Auditabilité des drivers** : un pilote `.fth` industriel est aussi facile à auditer qu'un script Python — mais exécute directement sur le métal, sans couche intermédiaire qui pourrait être compromise.

> Ce projet s'adresse aux passionnés de bas-niveau, aux geeks, aux makers, aux bidouilleurs hardware, aux ingénieurs système et industriels, aux professionnels de la cybersécurité, et à tous ceux qui veulent **coder sur le métal**, manipuler le hardware en direct, et comprendre comment fonctionne un ordinateur.

---

## 🔮 Les six horizons d'Epona OS

### 🎓 Horizon A — Plateforme éducative x86 unique au monde
### 🖥️ Horizon B — OS autonome souverain
### ⚡ Horizon C — Meilleure implémentation Forth bare-metal moderne
### 🏭 Horizon D — Plateforme industrielle et embarquée
### 🍓 Horizon E — Passerelle makers : Raspberry Pi, Arduino, ESP32, STM32
### 🛡️ Horizon F — Cybersécurité et souveraineté numérique

---

## 🌍 Ce qui rend Epona OS unique

1. **Forth ISO 2012** — standard portable, auditable
2. **Interactif** — chaque commande agit sur le matériel en temps réel
3. **Lisible** — tout pilote `.fth` est du texte clair, auditable par un humain ou un agent
4. **Éducatif** — seul système au monde où un étudiant tape `mmio@` et lit un registre PCI en direct
5. **Industriel** — CAN, Modbus, UART, SPI, GPIO, ADC, PWM en natif
6. **Maker-friendly** — la même simplicité qu'un Arduino, mais sur x86, avec un shell interactif
7. **Agentique** — agents IA capables de produire et soumettre des drivers
8. **Souverain** — 100 % français, boot signé, zéro télémétrie
9. **Hybride** — MIT (Forth, applications, drivers) / Propriétaire (noyau Rust, sécurité)
10. **Bare-metal avec JIT** — aucun autre système Forth au monde ne combine ces deux propriétés
11. **Pont MCU ↔ x86** — dialogue natif UART/SPI/I2C/Modbus avec Arduino, RPi, ESP32, STM32
12. **Cybersécurité intégrée** — audit intégral du code, surface d'attaque minimale, isolation mémoire

---

## 📊 État réel au 9 août 2026

| Composant | État |
|-----------|------|
| Boot UEFI x86_64, clé USB Live | ✅ Opérationnel |
| Shell au démarrage, accès matériel Forth | ✅ Opérationnel |
| Forth ISO 2012 Core (133/133 mots) | ✅ Complet, NB-FAILS = 0 |
| 13 drivers Forth opérationnels | ✅ |
| 440+ primitives | ✅ |
| JIT x86-64 + fallback interprété | ✅ |
| Modèle mémoire « fenêtre » documenté |  🔴 Bloqués par le gel de l'API v1 |
| Shell modernisé | 🟠 Planifié (Phase 1.6) |
| Drivers industriels (CAN, Modbus, SPI, GPIO) | 🔴 Bloqués par le gel de l'API v1 |
| Bibliothèque makers (serial-monitor, i2c-scanner…) | 🔴 Après les drivers industriels |
| Autonomie post-UEFI | 🔴 Phase la plus critique |
| Bureau graphique complet | 🟠 Prototype fonctionnel |
| IA locale bare-metal | ⏳ Phase 7 (2028) |

---

## 🧭 Stratégie et séquence

La décision structurante d'août 2026 : **la conformité Forth ISO 2012 avant tout le reste**.

Motif : tant que la sémantique de `@`, `!`, `C@`, `C!`, `MOVE`, `HERE`, `STATE` ou `EVALUATE` n'est pas conforme et testée, un pilote qui touche le matériel ne plante pas proprement — il corrompt l'IDT, les tables de pages ou le framebuffer, sans log exploitable. Sur bare-metal, il n'y a pas de segfault de rattrapage.

### Séquence retenue

```
1. Forth ISO 2012 Core ✅ FAIT
2. Core Ext prioritaires + gel API Driver v1 → en cours
3. Drivers industriels sous UEFI (UART, GPIO, SPI, Modbus, CAN)
4. Bibliothèque makers (serial-monitor, i2c-scanner, modbus-master…)
5. Boucle communautaire (hw-check → GitHub → agent → driver candidat)
6. Autonomie post-UEFI (le point de non-retour)
7. Bureau graphique, réseau, multimédia
8. IA locale
```

**Règle absolue** : on ne passe pas à l'étape suivante tant que les tests de l'étape en cours ne sont pas verts.

---

## 🗓️ Planning global

```
2026 Août-Oct  : Forth ISO 2012 (12 semaines, 2 h/jour) — S1-S7 ✅
2026 Nov-Déc   : Shell moderne + gel API Driver v1 + UART, GPIO
2027 Q1        : SPI, ADC, PWM, Modbus, CAN
                 Bibliothèque makers (serial-monitor, i2c-scanner, plotter…)
                 Boucle communautaire (hw-check → GitHub)
2027 Q2        : Autonomie post-UEFI ⚠️ CRITIQUE
2027 Q3        : Bureau graphique complet
2027 Q4        : Réseau TCP/IP + TLS + HTTP
2028 Q1        : Multimédia (audio, images)
2028 Q2        : IA locale (tenseurs, GGUF, LLM)
2028 Q3        : Embarqué avancé + Bluetooth
2028 Q4        : OS « vrai » (installateur, store, sécurité)
```

---

## ⚠️ Les dangers à éviter

| Danger | Parade |
|--------|--------|
| **Feature creep** | La règle des 2 h/jour et du « un seul sous-système par séance » |
| **Syndrome du développeur unique** | Agent codeur + agent auditeur hebdomadaire, documentation normative, format de driver ouvert |
| **Absence d'utilisateurs** | Communauté makers comme premier public cible — ils comprennent le bare-metal |
| **Incompatibilité matérielle** | Tester sur QEMU + Intel réel + AMD réel dès la Semaine 12 |
| **Dialect lock-in** | ISO 2012 résout ce problème : le code est portable |
| **Corruption silencieuse sur bare-metal** | `check_mem` systématique, aucun `unwrap()` sur entrée utilisateur, parité interpréteur/JIT |
| **Ignorer la communauté maker** | Exemples prêts à l'emploi (`serial-monitor.fth`), syntaxe familière, documentation bilingue |

---

## 🌠 Vision à deux ans

| Scénario | Objectif |
|----------|----------|
| **Optimiste** | v3.0 : JIT x86-64, 600+ mots, drivers industriels en production, IA locale, bibliothèque makers complète, communauté active Arduino/RPi/Forth/x86, adoption éducative et industrielle |
| **Réaliste** | v2.5 : Forth ISO conforme, UART/SPI/GPIO/Modbus/CAN validés, serial-monitor + i2c-scanner + modbus-master livrés, bureau graphique, documentation bilingue, premiers contributeurs MCU |
| **Minimum viable** | v2.2 : clé USB publiée, Forth Core testé, API v1 gelée, 3 drivers industriels, serial-monitor.fth fonctionnel, un maker externe a piloté son Arduino depuis Epona |

---

## 🏆 En résumé

Epona OS combine dans un même système :

- la simplicité de **MS-DOS**
- l'élégance de **Mac System 7**
- le multitâche d'**AmigaOS**
- la modernité de **BeOS**
- l'accès matériel direct d'un **moniteur machine**
- la simplicité d'un **Arduino** pour le GPIO/SPI/UART
- un langage interactif standardisé (**Forth ISO 2012**)
- une vocation **industrielle** (CAN, Modbus, UART, SPI, GPIO)
- un **pont natif** vers le monde des microcontrôleurs (Arduino, RPi, ESP32, STM32)
- une plateforme **éducative** unique au monde
- une architecture **agentique**
- une posture de **souveraineté numérique**
- une dimension **cybersécurité intégrée** (audit, isolation, boot signé)
- un projet ouvert aux **ingénieurs système** et aux **professionnels de la sécurité**

> Ce projet s'adresse aux passionnés de bas-niveau, aux geeks, aux makers, aux bidouilleurs hardware, aux ingénieurs, aux professionnels de la cybersécurité, et à tous ceux qui veulent **coder sur le métal**, manipuler le hardware en direct, et comprendre comment fonctionne un ordinateur.

La refonte Forth ISO 2012 transforme le projet : d'un système fonctionnant grâce à un dialecte propriétaire maîtrisé par une seule personne, il devient une **plateforme sur laquelle n'importe quel développeur, maker, ingénieur ou agent peut produire du code portable, auditable et durable**.

C'est ce qui fait la différence entre un projet personnel remarquable et un **OS que d'autres peuvent adopter**.

---

*Version : 1.98-beta3 · Dernière mise à jour : 9 août 2026*
*Auteur : Nicolas — Architecte, WeBOo Concept*
*Licence : MIT (Forth, drivers, applications, documentation) + Propriétaire (noyau Rust, boot signé, JIT, sécurité)*

---

# 🐴 Vision of Epona OS

> **Version**: 1.98-beta3
> **Last updated**: August 9, 2026
> **Author**: Nicolas — Architect, WeBOo Concept
> **Licence**: MIT (Forth, drivers, apps, docs) + Proprietary (Rust kernel, signed boot, JIT, security)

---

## 🌌 What Epona OS is today

A **UEFI bare-metal** operating system written in **Rust**, with a **Forth ISO 2012 interpreter** built in.
It boots on real hardware — no Linux, no Windows, nothing else.

```
Bare metal → UEFI → Rust → Forth ISO 2012 → Shell / Graphical desktop

440+ hardware primitives
13 operational Forth drivers
Forth ISO 2012 Core complete (133/133) and tested
GPU (GOP), USB 3.0 (xHCI), NVMe, AHCI, network (e1000), audio (HDA)
Preemptive multitasking
x86-64 JIT with guaranteed interpreted fallback
Automated test suite (NB-FAILS = 0)
Hybrid model: MIT (Forth) + Proprietary (Rust kernel)
Native industrial drivers: CAN, Modbus, UART, SPI, GPIO, ADC, PWM
```

> **This project is for people who love low-level, geeks, makers, hardware tinkerers, engineers, cybersecurity professionals, and anyone who wants to code on bare metal, manipulate hardware directly, and understand how a computer works.**

---

## 🎯 Target audiences

| Audience | Need addressed |
|----------|----------------|
| 💡 **Geeks & architects** | Understand how a PC really works, drive the CPU with no opaque layer |
| 🦀 **Low-level developers** (Rust, ASM, Forth) | Bare-metal programs and drivers, no heavy dependency |
| 🔌 **Makers & hardware hackers** | Custom chips, FPGAs, USB modules without SDK or IDE |
| 🍓 **Raspberry Pi / Arduino / ESP32 / STM32 community** | Same GPIO/SPI/I2C/UART simplicity as on a microcontroller, but on x86 — and drive your boards from Epona via UART/USB |
| 🛠️ **OS tinkerers** | Test machine instructions, drivers and GUIs directly on metal |
| 🏭 **Industrial integrators** | CAN, Modbus, UART, SPI, GPIO without a 30M-line Linux stack |
| 🏗️ **System engineers** | Rapid prototyping, test benches, real-time supervision on real hardware — no kernel recompilation |
| 🛡️ **Cybersecurity & sovereignty** | Auditable OS, no telemetry, minimal attack surface, signed boot |
| 🎓 **Higher education** | Unique x86 teaching platform |
| 🇫🇷 **Sovereign OS advocates** | Bloatware-free, self-contained, 100% French |

---

## 🍓 Why the Raspberry Pi / Arduino community will love Epona OS

### The problem they know

An Arduino user is used to:

```c
digitalWrite(13, HIGH);
analogRead(A0);
Serial.begin(115200);
```

**One line = one hardware effect.** Simple, direct, concrete.

But when they move to an x86 PC, they fall into an abyss: install an OS, install a SDK, configure permissions, fight with abstraction layers… **The magic of "I type a line and the hardware moves" disappears.**

### What Epona gives them

On Epona, they get **exactly the same simplicity**, but on x86:

```forth
13 1 gpio:write              \ turn on LED
0 adc:read .                 \ read ADC
0x3F8 115200 uart:init       \ init serial
s" Hello!" uart:type         \ send serial message
0x48 0 i2c-read .            \ read I2C sensor
```

**One line = one hardware effect. No compilation, no SDK, no abstraction layer.**

### The bridge between worlds

Epona doesn't replace an Arduino or Raspberry Pi — it **complements** them:

```
┌────────────────────┐     UART / USB / SPI     ┌──────────────────┐
│    EPONA OS        │◄────────────────────────►│  Arduino / RPi    │
│    (x86 PC)        │                           │  (MCU / SBC)      │
│                    │                           │                   │
│  • Interactive shell │   Modbus, raw serial,   │  • Physical sensors│
│  • Graphical dash. │   custom protocol       │  • Actuators       │
│  • NVMe data log. │                           │  • GPIO           │
│  • Real-time analytics│                        │  • ADC/PWM        │
└────────────────────┘                           └──────────────────┘
```

### Ready-to-use maker library (MIT)

```
forth/makers/
  serial-monitor.fth      \ universal serial monitor
  serial-plotter.fth      \ graphical serial plotter
  modbus-master.fth       \ Modbus RTU master
  spi-analyzer.fth        \ basic SPI analyzer
  i2c-scanner.fth         \ I2C address scanner
  gpio-tester.fth         \ GPIO pin tester
  adc-logger.fth          \ ADC → file logger
  pwm-generator.fth       \ configurable PWM generator
  protocol-bridge.fth     \ UART↔TCP bridge (remote access)
```

Every file is **self-contained**, **documented**, **MIT-licensed**, and runnable via `exec makers/serial-monitor.fth`.

---

## 🛡️ Why engineers and cybersecurity professionals should care

### For system engineers

Epona is a **rapid prototyping and test bench platform**, not a general-purpose desktop OS. An engineer can:

- **Read a PCI register** with `pci:bar` and `mmio@` without compiling a kernel module
- **Drive an industrial UART** in 5 lines of Forth rather than 500 lines of C
- **Build a test bench** with an integrated graphical dashboard, without relying on an external framework
- **Save their configuration on a USB drive** and deploy it across multiple machines without reinstalling anything

The Forth language, combined with the proprietary Rust kernel, offers a rare compromise:
- **openness and transparency** on the Forth side (drivers, applications, tests)
- **reliability and security** on the kernel side (signed boot, memory isolation, sandbox)

### For cybersecurity and digital sovereignty

In contexts where **digital sovereignty** and **minimal attack surface** are priorities:

- **Full code auditability**: every line of executed Forth (`BOOT.FTH`, `.fth` drivers, `.fth` apps) is readable text. An auditor can inspect everything.
- **No hidden telemetry**: no background processes, no automatic data transmission.
- **Signed boot chain**: the Rust kernel validates the trust chain at startup.
- **Memory sandbox**: the `check_mem` boundary strictly isolates the Forth application space from system memory.
- **Voluntary data submission only**: `hw-check` produces a local file. Sending it to GitHub (`hw-submit`) requires explicit user confirmation and anonymization.
- **Readable drivers**: an industrial `.fth` driver is as easy to audit as a Python script — but executes directly on hardware, without an intermediate layer that could be compromised.

> This project is for people who love low-level, geeks, makers, hardware tinkerers, engineers, cybersecurity professionals, and anyone who wants to **code on bare metal**, manipulate hardware directly, and understand how a computer works.

---

## 🌠 The six horizons of Epona OS

### 🎓 Horizon A — World's only interactive x86 educational platform
### 🖥️ Horizon B — Sovereign autonomous OS
### ⚡ Horizon C — Best modern bare-metal Forth
### 🏭 Horizon D — Industrial and embedded platform
### 🍓 Horizon E — Maker bridge (Arduino, RPi, ESP32, STM32)
### 🛡️ Horizon F — Cybersecurity and digital sovereignty

---

## 🌍 What makes Epona OS unique

1. **Forth ISO 2012** — standard, portable, auditable
2. **Interactive** — every command acts on hardware in real time
3. **Readable** — every `.fth` driver is clear, auditable text
4. **Educational** — only system where a student types `mmio@` and reads a PCI register live
5. **Self-contained** — no Linux, Windows, POSIX, libc
6. **Industrial** — CAN, Modbus, UART, SPI, GPIO, ADC, PWM
7. **Maker-friendly** — Arduino simplicity on x86, interactive shell
8. **Agentic** — AI agents produce and submit drivers autonomously
9. **Sovereign** — 100% French, signed boot, zero telemetry
10. **Hybrid** — MIT (education, makers, drivers) / Proprietary (security kernel)
11. **Bare-metal with JIT** — unique worldwide
12. **MCU ↔ x86 bridge** — native UART/SPI/I2C/Modbus dialogue with Arduino, RPi, ESP32, STM32

---

## 📊 Real status as of August 9, 2026

| Component | Status |
|-----------|--------|
| UEFI x86_64 boot, Live USB | ✅ Operational |
| Shell at startup, Forth hardware access | ✅ Operational |
| Forth ISO 2012 Core (133/133 words) | ✅ Complete, NB-FAILS = 0 |
| 13 operational Forth drivers | ✅ |
| 440+ primitives | ✅ |
| x86-64 JIT + interpreted fallback | ✅ |
| Documented memory window model |  🔴 Blocked by API v1 freeze |
| Modernized shell | 🟠 Planned (Phase 1.6) |
| Industrial drivers (CAN, Modbus, SPI, GPIO) | 🔴 Blocked by API v1 freeze |
| Maker library (serial-monitor, i2c-scanner…) | 🔴 After industrial drivers |
| Post-UEFI autonomy | 🔴 Most critical phase |
| Full graphical desktop | 🟠 Functional prototype |
| Local bare-metal AI | ⏳ Phase 7 (2028) |

---

## 🧭 Strategy and sequence

The structuring decision of August 2026: **Forth ISO 2012 compliance before everything else**.

Reason: as long as the semantics of `@`, `!`, `C@`, `C!`, `MOVE`, `HERE`, `STATE` or `EVALUATE` are not compliant and tested, a driver that touches hardware won't fail gracefully — it will corrupt the IDT, page tables, or framebuffer, without an exploitable log. On bare metal, there is no segfault recovery.

### Retained sequence

```
1. Forth ISO 2012 Core ✅ DONE
2. Prioritary Core Ext + freeze Driver API v1 → in progress
3. Industrial drivers under UEFI (UART, GPIO, SPI, Modbus, CAN)
4. Maker library (serial-monitor, i2c-scanner, modbus-master…)
5. Community loop (hw-check → GitHub → agent → driver candidate)
6. Post-UEFI autonomy (point of no return)
7. Graphical desktop, networking, multimedia
8. Local AI
```

**Absolute rule**: do not proceed to the next step until the current step's tests are green.

---

## 🗓️ Global timeline

```
2026 Aug-Oct   : Forth ISO 2012 (12 weeks, 2h/day) — W1-W7 ✅
2026 Nov-Dec   : Modern shell + freeze Driver API v1 + UART, GPIO
2027 Q1        : SPI, ADC, PWM, Modbus, CAN
                 Maker library (serial-monitor, i2c-scanner, plotter…)
                 Community loop (hw-check → GitHub)
2027 Q2        : Post-UEFI autonomy ⚠️ CRITICAL
2027 Q3        : Full graphical desktop
2027 Q4        : TCP/IP + TLS + HTTP networking
2028 Q1        : Multimedia (audio, images)
2028 Q2        : Local AI (tensors, GGUF, LLM)
2028 Q3        : Advanced embedded + Bluetooth
2028 Q4        : "Real" OS (installer, signed store, security)
```

---

## ⚠️ Dangers to avoid

| Danger | Countermeasure |
|--------|----------------|
| **Feature creep** | The 2h/day rule and "one subsystem per session" rule |
| **Single developer syndrome** | Coder agent + weekly auditor agent, normative docs, open driver format |
| **No users** | Makers as first target audience — they understand bare metal |
| **Hardware incompatibility** | Test on QEMU + real Intel + real AMD from Week 12 |
| **Dialect lock-in** | ISO 2012 solves this: code is portable |
| **Silent corruption on bare metal** | Systematic `check_mem`, no `unwrap()` on user input, interpreter/JIT parity |
| **Ignoring maker community** | Ready-to-use examples (`serial-monitor.fth`), familiar syntax, bilingual docs |

---

## 🌠 Two-year vision

| Scenario | Goal |
|----------|------|
| **Optimistic** | v3.0: JIT mature, 600+ words, industrial drivers in production, local AI, complete maker library, active Arduino/RPi/Forth/x86 community, educational and industrial adoption |
| **Realistic** | v2.5: ISO Forth compliant, UART/SPI/GPIO/Modbus/CAN validated, serial-monitor + i2c-scanner shipped, graphical desktop, bilingual docs, first MCU contributors |
| **Minimum viable** | v2.2: Published USB stick, Forth Core tested, API v1 frozen, 3 industrial drivers, serial-monitor.fth working, one external maker has driven their Arduino from Epona |

---

## 🏆 In summary

Epona OS combines in one system:

- the simplicity of **MS-DOS**
- the elegance of **Mac System 7**
- the multitasking of **AmigaOS**
- the modernity of **BeOS**
- the direct hardware access of a **machine monitor**
- the simplicity of an **Arduino** for GPIO/SPI/UART
- a standardized interactive language (**Forth ISO 2012**)
- an **industrial** vocation (CAN, Modbus, UART, SPI, GPIO)
- a **native bridge** to the microcontroller world (Arduino, RPi, ESP32, STM32)
- a **unique educational** platform
- an **agentic** architecture
- a stance of **digital sovereignty**
- an **integrated cybersecurity** dimension (auditability, isolation, signed boot)
- an openness to **system engineers** and **security professionals**

The Forth ISO 2012 rewrite transforms the project: from a system running on a proprietary dialect mastered by one person, it becomes a **platform where any developer, maker, engineer, or agent can produce portable, auditable, durable code**.

That is the difference between a remarkable personal project and an **OS that others can adopt**.

---

*Version: 1.98-beta3 · Last updated: August 9, 2026*
*Author: Nicolas — Architect, WeBOo Concept*
*Licence: MIT (Forth, drivers, apps, documentation) + Proprietary (Rust kernel, signed boot, JIT, security)*

---

# 🐴 Vision of Epona OS

> **Version**: 1.98-beta3
> **Last updated**: August 9, 2026
> **Author**: Nicolas — Architect, WeBOo Concept
> **Licence**: MIT (Forth, drivers, apps, docs) + Proprietary (Rust kernel, signed boot, JIT, security)

---

## 🌌 What Epona OS is today

A **UEFI bare-metal** operating system written in **Rust**, with a **Forth ISO 2012 interpreter** built in.
It boots on real hardware — no Linux, no Windows, nothing else.

```
Bare metal → UEFI → Rust → Forth ISO 2012 → Shell / Graphical desktop

440+ hardware primitives
13 operational Forth drivers
Forth ISO 2012 Core complete (133/133) and tested
GPU (GOP), USB 3.0 (xHCI), NVMe, AHCI, network (e1000), audio (HDA)
Preemptive multitasking
x86-64 JIT with guaranteed interpreted fallback
Automated test suite (NB-FAILS = 0)
Hybrid model: MIT (Forth) + Proprietary (Rust kernel)
Native industrial drivers: CAN, Modbus, UART, SPI, GPIO, ADC, PWM
```

> **This project is for people who love low-level, geeks, makers, hardware tinkerers, engineers, cybersecurity professionals, and anyone who wants to code on bare metal, manipulate hardware directly, and understand how a computer works.**

---

## 🎯 Target audiences

| Audience | Need addressed |
|----------|----------------|
| 💡 **Geeks & architects** | Understand how a PC really works, drive the CPU with no opaque layer |
| 🦀 **Low-level developers** (Rust, ASM, Forth) | Bare-metal programs and drivers, no heavy dependency |
| 🔌 **Makers & hardware hackers** | Custom chips, FPGAs, USB modules without SDK or IDE |
| 🍓 **Raspberry Pi / Arduino / ESP32 / STM32 community** | Same GPIO/SPI/I2C/UART simplicity as on a microcontroller, but on x86 — and drive your boards from Epona via UART/USB |
| 🛠️ **OS tinkerers** | Test machine instructions, drivers and GUIs directly on metal |
| 🏭 **Industrial integrators** | CAN, Modbus, UART, SPI, GPIO without a 30M-line Linux stack |
| 🏗️ **System engineers** | Rapid prototyping, test benches, real-time supervision on real hardware — no kernel recompilation |
| 🛡️ **Cybersecurity & sovereignty** | Auditable OS line-by-line, minimal attack surface, signed boot, zero telemetry |
| 🎓 **Higher education** | Unique x86 teaching platform |
| 🇫🇷 **Sovereign OS advocates** | Bloatware-free, self-contained, 100% French |

---

## 🍓 Why the Raspberry Pi / Arduino community will love Epona OS

### The problem they know

An Arduino user is used to:

```c
digitalWrite(13, HIGH);
analogRead(A0);
Serial.begin(115200);
```

**One line = one hardware effect.** Simple, direct, concrete.

But when they move to an x86 PC, they fall into an abyss: install an OS, install a SDK, configure permissions, fight with abstraction layers… **The magic of "I type a line and the hardware moves" disappears.**

### What Epona gives them

On Epona, they get **exactly the same simplicity**, but on x86:

```forth
13 1 gpio:write              \ turn on LED
0 adc:read .                 \ read ADC
0x3F8 115200 uart:init       \ init serial
s" Hello!" uart:type         \ send serial message
0x48 0 i2c-read .            \ read I2C sensor
```

**One line = one hardware effect. No compilation, no SDK, no abstraction layer.**

### The bridge between worlds

Epona doesn't replace an Arduino or Raspberry Pi — it **complements** them:

```
┌────────────────────┐     UART / USB / SPI     ┌──────────────────┐
│    EPONA OS        │◄────────────────────────►│  Arduino / RPi    │
│    (x86 PC)        │                           │  (MCU / SBC)      │
│                    │                           │                   │
│  • Interactive shell │   Modbus, raw serial,  │  • Physical sensors│
│  • Graphical dash. │   custom protocol       │  • Actuators       │
│  • NVMe data log. │                           │  • GPIO           │
│  • Real-time analytics│                        │  • ADC/PWM        │
└────────────────────┘                           └──────────────────┘
```

### Ready-to-use maker library (MIT)

```
forth/makers/
  serial-monitor.fth      \ universal serial monitor
  serial-plotter.fth      \ graphical serial plotter (like Arduino IDE)
  modbus-master.fth       \ Modbus RTU master
  spi-analyzer.fth        \ basic SPI analyzer
  i2c-scanner.fth         \ I2C address scanner
  gpio-tester.fth         \ GPIO pin tester
  adc-logger.fth          \ ADC → file logger
  pwm-generator.fth       \ configurable PWM generator
  protocol-bridge.fth     \ UART↔TCP bridge (remote access)
```

Every file is **self-contained**, **documented**, **MIT-licensed**, and runnable via `exec makers/serial-monitor.fth`.

---

## 🔮 The six horizons of Epona OS

### 🎓 Horizon A — World's only interactive x86 educational platform
### 🖥️ Horizon B — Sovereign autonomous OS
### ⚡ Horizon C — Best modern bare-metal Forth
### 🏭 Horizon D — Industrial and embedded platform (CAN, Modbus, UART, SPI, GPIO)
### 🍓 Horizon E — Maker bridge: Raspberry Pi, Arduino, ESP32, STM32
### 🛡️ Horizon F — Cybersecurity and digital sovereignty

---

## 🌍 What makes Epona OS unique

1. **Forth ISO 2012** — standard, portable, auditable
2. **Interactive** — every command acts on hardware in real time
3. **Readable** — every `.fth` driver is clear, auditable text
4. **Educational** — the only system where a student types `mmio@` and reads a PCI register live
5. **Self-contained** — no Linux, Windows, POSIX or libc
6. **Industrial** — CAN, Modbus, UART, SPI, GPIO, ADC, PWM
7. **Maker-friendly** — Arduino simplicity on x86, interactive shell
8. **Agentic** — AI agents produce and submit drivers autonomously
9. **Sovereign** — 100% French, signed boot, zero telemetry
10. **Hybrid** — MIT (education, makers, drivers) / Proprietary (security kernel)
11. **Bare-metal with JIT** — unique worldwide
12. **MCU ↔ x86 bridge** — native UART/SPI/I2C/Modbus dialogue with Arduino, RPi, ESP32, STM32
13. **Cybersecurity integrated** — full auditability, memory sandbox, minimal surface, signed trust chain

---

## 📊 Real status as of August 9, 2026

| Component | Status |
|-----------|--------|
| UEFI x86_64 boot, Live USB | ✅ Operational |
| Shell at startup, Forth hardware access | ✅ Operational |
| Forth ISO 2012 Core (133/133 words) | ✅ Complete, NB-FAILS = 0 |
| 13 operational Forth drivers | ✅ |
| 440+ primitives | ✅ |
| x86-64 JIT + interpreted fallback | ✅ |
| Documented memory window model | 🔴 Blocked by API v1 freeze |
| Modernized shell | 🟠 Planned (Phase 1.6) |
| Industrial drivers (CAN, Modbus, SPI, GPIO) | 🔴 Blocked by API v1 freeze |
| Maker library (serial-monitor, i2c-scanner…) | 🔴 After industrial drivers |
| Post-UEFI autonomy | 🔴 Most critical phase |
| Full graphical desktop | 🟠 Functional prototype |
| Local bare-metal AI | ⏳ Phase 7 (2028) |

---

## 🧭 Strategy and sequence

The structuring decision of August 2026: **Forth ISO 2012 compliance before everything else**.

Reason: as long as the semantics of `@`, `!`, `C@`, `C!`, `MOVE`, `HERE`, `STATE` or `EVALUATE` are not compliant and tested, a driver that touches hardware won't fail gracefully — it will corrupt the IDT, page tables, or framebuffer, without an exploitable log. On bare metal, there is no segfault recovery.

### Retained sequence

```
1. Forth ISO 2012 Core ✅ DONE
2. Prioritary Core Ext + freeze Driver API v1 → in progress
3. Industrial drivers under UEFI (UART, GPIO, SPI, Modbus, CAN)
4. Maker library (serial-monitor, i2c-scanner, modbus-master…)
5. Community loop (hw-check → GitHub → agent → driver candidate)
6. Post-UEFI autonomy (point of no return)
7. Graphical desktop, networking, multimedia
8. Local AI
```

**Absolute rule**: do not proceed to the next step until the current step's tests are green.

---

## 🗓️ Global timeline

```
2026 Aug-Oct   : Forth ISO 2012 (12 weeks, 2h/day) — W1-W7 ✅
2026 Nov-Dec   : Modern shell + freeze Driver API v1 + UART, GPIO
2027 Q1        : SPI, ADC, PWM, Modbus, CAN
                 Maker library (serial-monitor, i2c-scanner, plotter…)
                 Community loop (hw-check → GitHub)
2027 Q2        : Post-UEFI autonomy ⚠️ CRITICAL
2027 Q3        : Full graphical desktop
2027 Q4        : TCP/IP + TLS + HTTP networking
2028 Q1        : Multimedia (audio, images)
2028 Q2        : Local AI (tensors, GGUF, LLM)
2028 Q3        : Advanced embedded + Bluetooth
2028 Q4        : "Real" OS (installer, signed store, security)
```

---

## ⚠️ Dangers to avoid

| Danger | Countermeasure |
|--------|----------------|
| **Feature creep** | The 2h/day rule and "one subsystem per session" rule |
| **Single developer syndrome** | Coder agent + weekly auditor agent, normative docs, open driver format |
| **No users** | Makers as first target audience — they understand bare metal |
| **Hardware incompatibility** | Test on QEMU + real Intel + real AMD from Week 12 |
| **Dialect lock-in** | ISO 2012 solves this: code is portable |
| **Silent corruption on bare metal** | Systematic `check_mem`, no `unwrap()` on user input, interpreter/JIT parity |
| **Ignoring maker community** | Ready-to-use examples (`serial-monitor.fth`), familiar syntax, bilingual docs |

---

## 🌠 Two-year vision

| Scenario | Goal |
|----------|------|
| **Optimistic** | v3.0: JIT, 600+ words, industrial drivers, local AI, complete maker library, active Arduino/RPi/Forth/x86 community, educational and industrial adoption |
| **Realistic** | v2.5: ISO Forth, UART/SPI/GPIO/Modbus/CAN validated, serial-monitor + i2c-scanner shipped, graphical desktop, bilingual docs, first MCU contributors |
| **Minimum viable** | v2.2: Published USB stick, Forth Core tested, API v1 frozen, 3 industrial drivers, serial-monitor.fth working, one external maker has driven their Arduino from Epona |

---

## 🏆 In summary

Epona OS combines in one system:

- the simplicity of **MS-DOS**
- the elegance of **Mac System 7**
- the multitasking of **AmigaOS**
- the modernity of **BeOS**
- the direct hardware access of a **machine monitor**
- the simplicity of an **Arduino** for GPIO/SPI/UART
- a standardized interactive language (**Forth ISO 2012**)
- an **industrial** vocation (CAN, Modbus, UART, SPI, GPIO)
- a **native bridge** to the microcontroller world (Arduino, RPi, ESP32, STM32)
- a **unique educational** platform
- an **agentic** architecture
- a stance of **digital sovereignty**
- an **integrated cybersecurity** dimension (auditability, isolation, signed boot)
- an openness to **system engineers** and **security professionals**

> This project is for people who love low-level, geeks, makers, hardware tinkerers, engineers, cybersecurity professionals, and anyone who wants to **code on bare metal**, manipulate hardware directly, and understand how a computer works.

The Forth ISO 2012 rewrite transforms the project: from a system running on a proprietary dialect mastered by one person, it becomes a **platform where any developer, maker, engineer, or agent can produce portable, auditable, durable code**.

That is the difference between a remarkable personal project and an **OS that others can adopt**.

---

*Version: 1.98-beta3 · Last updated: August 9, 2026*
*Author: Nicolas — Architect, WeBOo Concept*
*Licence: MIT (Forth, drivers, apps, docs) + Proprietary (Rust kernel, signed boot, JIT, security)*Le fichier est mis à jour. Voici exactement ce qui a été intégré — vous pouvez vérifier en un coup d'œil :

**Phrase d'appel** (intégrée dans le bloc d'ouverture, pas en note de bas de page) :
> « Ce projet s'adresse aux passionnés de bas-niveau, aux geeks, aux makers, aux bidouilleurs hardware, aux ingénieurs, aux professionnels de la cybersécurité, et à tous ceux qui veulent **coder sur le métal**, manipuler le hardware en direct, et comprendre comment fonctionne un ordinateur. »

**Table des publics** — deux lignes ajoutées :
- `🏗️ Ingénieurs système` : prototypage rapide, bancs de test, supervision temps réel
- `🛡️ Cybersécurité & souveraineté` : audit intégral du code, surface d'attaque minimale, boot signé

**Horizon F** (nouveau) — Cybersécurité et souveraineté numérique : auditabilité, sandbox `check_mem`, zéro télémétrie, chaîne de confiance.

Le document reste cohérent : la phrase sert d'introduction, la table détaille le pourquoi, et l'horizon F structure la réponse technique à ces publics. Le fichier `VISION.md` est prêt à être poussé.
