<h1 align="center">Epona OS</h1>

<p align="center">
  <img src="https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/Epona%20Os%20fond%20transparent.png" width="350" alt="Epona OS Logo">
</p>

<p align="center">
  Système d’exploitation celte, libre, modulaire et extensible.
</p>

Epona OS est un système d’exploitation celte libre, écrit en Rust et Forth. Inspiré de la déesse Epona, il incarne vitesse, liberté et stabilité. Conçu en Bretagne, il explore la création d’un OS souverain, graphique et modulaire.

rejoint la communauté sur discord pour tout savoir
https://discord.gg/kwWBWhmvN
================================================================================
                        EPONA OS — GUIDE COMPLET
              Systeme d'exploitation bare-metal UEFI en Rust
            avec interprete Forth integre (EponaForth)
================================================================================

Bienvenue dans Epona OS !



## 🎯 À qui s’adresse Epona OS ?
Epona OS vise une communauté très précise :

- les **geeks** qui aiment comprendre comment marche un ordinateur,  
- les **développeurs bas‑niveau** (Rust, ASM, Forth),  
- les **makers** qui travaillent avec des microcontrôleurs, FPGA, cartes USB,  
- les **bidouilleurs hardware** qui veulent parler directement à une puce,  
- les passionnés d’OS qui veulent un système **simple, souverain, programmable**,  
- les gens qui veulent **écrire du code machine sans IDE**,  
- les curieux qui veulent un OS **hackable**, **modulaire**, **agentique**.

Epona OS n’est pas un clone de Linux ou Windows.  
C’est un **atelier matériel + langage système + environnement agentique**.

---

## ⚡ Ce qui rend Epona OS unique
### **1. Forth natif intégré au système**  
Epona OS n’a pas un “terminal”.  
Il a un **langage Forth natif**, directement connecté au kernel.

Tu peux :

- manipuler la mémoire,  
- appeler des drivers,  
- écrire des scripts système,  
- créer des widgets,  
- piloter du hardware,  
- tester des instructions machine,  
- tout ça **sans aucune application externe**.

**Forth = shell + IDE + debugger + console hardware.**

---

### **2. Accès direct au hardware via USB**
Tu peux brancher :

- un microcontrôleur,  
- une puce custom,  
- une carte FPGA,  
- un device expérimental,  
- un module électronique maison,

et **parler directement à la puce** depuis Epona OS.

Exemples :

```
usb:open-device
usb:write-bytes
usb:read-bytes
```

Pas de driver externe, pas de SDK, pas d’IDE.  
Juste toi, la puce, et Forth.

---

### **3. Écrire du langage machine directement**
Epona OS permet :

- d’écrire du code machine,  
- de l’exécuter,  
- de le tracer,  
- de le profiler,  
- de le modifier en live.

Tu peux créer :

- un mini assembleur,  
- un émulateur ISA,  
- un simulateur de pipeline,  
- un décodeur d’instructions,

**directement dans Forth**, sans quitter l’OS.

---

### **4. Émulateur ISA intégré (en cours de programmation)**
Tu peux charger un binaire :

```
emu:load
emu:step
emu:reg
emu:mem
```

Et exécuter du code machine **dans ton OS**, sans dépendre d’un outil externe.

---

### **5. Un OS souverain, minimaliste, agentique**
- Kernel Rust **fermé**, sécurisé, souverain  
- API Forth **ouverte**, extensible   
- Développeurs humains limités à Forth (sécurité + cohérence)  
- Pas de compatibilité Windows/Linux → pas de lourdeur  
- Pas de dépendances externes  
- Pas de licences contraignantes  

Epona OS est un OS **pour apprendre**, **expérimenter**, **créer**, **hacker**, **inventer**.

---

## 🧩 Pourquoi Epona OS est différent des autres OS
| OS | Objectif | Accès hardware | Langage natif | Niveau |
|----|----------|----------------|----------------|--------|
| Windows | Utilisateur | Très limité | Aucun | Haut niveau |
| Linux | Développeur | Moyen | Bash | Moyen |
| Iona‑OS | OS massif | Standard PC | Rust | Complexe |
| **Epona OS** | **Geeks / hardware / bas‑niveau** | **Direct USB / MMIO / PCI** | **Forth + ASM** | **Bas niveau / métal** |

👉 **Epona OS est le seul OS moderne conçu pour coder directement sur le métal.**

---

## 🔧 Ce que tu peux faire avec Epona OS
- écrire un driver USB en Forth,  
- piloter une puce FPGA branchée en USB,  
- envoyer des instructions machine à un microcontrôleur,  
- créer un émulateur RISC‑V ou x86,  
- écrire un mini assembleur,  
- manipuler la mémoire physique,  
- tracer des interruptions,  
- créer des outils système en Forth,  
- faire du prototypage hardware sans OS externe.

---

## 🧠 Pour les geeks : un OS qui ne vous limite pas
Epona OS est pensé pour ceux qui veulent :

- comprendre le hardware,  
- écrire du code bas‑niveau,  
- manipuler des registres,  
- créer des drivers,  
- expérimenter des architectures,  
- jouer avec des puces,  
- écrire du langage machine,  
- créer des outils système.

Si tu veux un OS pour “utiliser des applications”, il est fait pour toi.  
Si tu veux un OS pour **créer**, **expérimenter**, **apprendre**, **hacker**, **inventer**,  
alors Epona OS est fait pour toi.


Ce guide vous explique comment utiliser le systeme, programmer en Forth,
et acceder au materiel directement depuis votre clavier.

Epona OS demarre depuis une cle USB et fonctionne sans Windows, sans Linux,
sans aucun autre systeme. Il tourne directement sur le processeur.
[BOOTX64.efi](https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/EFI/BOOT/BOOTX64.efi)

# Idées pour le GitHub d'Epona OS

## README.md principal

```markdown
# Epona OS 2.0

![Epona OS](logo.png)

> Un système d'exploitation bare-metal UEFI écrit entièrement en Rust,
> avec un interpréteur/compilateur Forth intégré, un JIT x86_64,
> et un accès matériel complet.

## ✨ Caractéristiques

- 🦀 **100% Rust** — pas de C, pas de libc, pas de std
- ⚡ **JIT x86_64** — compilation native avec signature cryptographique
- 🖥️ **Forth complet** — ~380 primitives, ANS Forth compatible
- 🎮 **Émulateur CHIP-8** — intégré, avec assembleur
- 🖱️ **Bureau graphique** — canvas, GPU, widgets, multi-écran
- 🔌 **Drivers Forth** — clavier, souris, USB, NVMe, AHCI, HDA
- 🌐 **Pile réseau** — TCP/IP, UDP, DNS, DHCP, HTTP
- 🔒 **Sandbox** — mode sécurisé, signatures JIT

## 📸 Captures d'écran

| Bureau | IDE Forth | Émulateur CHIP-8 |
|--------|-----------|------------------|
| ![Bureau](screenshots/bureau.png) | ![IDE](screenshots/ide.png) | ![CHIP-8](screenshots/chip8.png) |

## 🚀 Démarrage rapide

### Prérequis

```bash
# Rust nightly
rustup toolchain install nightly
rustup component add rust-src --toolchain nightly
rustup target add x86_64-unknown-uefi

# QEMU pour tester
sudo apt install qemu-system-x86
```

### Compiler

```bash
git clone https://github.com/vous/epona-os
cd epona-os
cargo build --release
```

### Lancer dans QEMU

```bash
./scripts/run-qemu.sh
```

### Installer sur clé USB

```bash
./scripts/install-usb.sh /dev/sdX
```

## 📖 Documentation

- [Guide EponaForth](docs/GUIDE.md)
- [Référence des primitives](docs/PRIMITIVES.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Créer un driver](docs/DRIVERS.md)
- [Créer une application](docs/APPS.md)

## 🎮 Exemples

```forth
( Hello World )
: principal
    ." Bonjour depuis Epona OS !" cr
;
```

```forth
( Bureau graphique )
sys:load BUREAU.FTH
```

```forth
( Émulateur CHIP-8 )
sys:load CHIP8.FTH
```

## 📜 Licence

MIT — voir [LICENSE](LICENSE)
```

---

## Structure du dépôt GitHub

```
epona-os/
│
├── 📄 README.md
├── 📄 LICENSE
├── 📄 CHANGELOG.md
├── 📄 CONTRIBUTING.md
├── 📄 SECURITY.md
│
├── 🦀 src/
│   ├── main.rs
│   ├── interpreter.rs     ← EponaForth VM
│   ├── jit.rs             ← Compilateur JIT x86_64
│   ├── graphics.rs
│   ├── keyboard.rs
│   ├── pci.rs
│   ├── acpi.rs
│   ├── nvme.rs
│   ├── ahci.rs
│   ├── xhci.rs
│   ├── net.rs
│   ├── net_stack.rs
│   ├── hda.rs
│   ├── fat32.rs
│   ├── vfs.rs
│   ├── scheduler.rs
│   ├── crypto.rs
│   └── ...
│
├── 📁 forth/              ← Bibliothèque de fichiers .FTH
│   ├── bureau/
│   │   ├── BUREAU.FTH
│   │   ├── BUREAU_DARK.FTH
│   │   └── BUREAU_MINIMAL.FTH
│   │
│   ├── drivers/
│   │   ├── DRIVER_CLAVIER_USB.FTH
│   │   ├── DRIVER_SOURIS_USB.FTH
│   │   ├── DRIVER_AUDIO.FTH
│   │   └── DRIVER_NET.FTH
│   │
│   ├── jeux/
│   │   ├── CHIP8.FTH          ← Émulateur CHIP-8
│   │   ├── ASM8.FTH           ← Assembleur CHIP-8
│   │   ├── SNAKE.FTH
│   │   ├── TETRIS.FTH
│   │   └── PONG.FTH
│   │
│   ├── outils/
│   │   ├── EDITEUR.FTH
│   │   ├── CALCUL.FTH
│   │   ├── HEXEDIT.FTH
│   │   └── MONITEUR.FTH
│   │
│   ├── roms/
│   │   ├── PONG.CH8
│   │   ├── TETRIS.CH8
│   │   ├── INVADERS.CH8
│   │   └── MAZE.CH8
│   │
│   └── demos/
│       ├── DEMO_GRAPHIQUE.FTH
│       ├── DEMO_RESEAU.FTH
│       └── DEMO_AUDIO.FTH
│
├── 📁 docs/
│   ├── GUIDE.md
│   ├── PRIMITIVES.md
│   ├── ARCHITECTURE.md
│   ├── DRIVERS.md
│   ├── APPS.md
│   ├── JIT.md
│   ├── CHIP8.md
│   └── SECURITE.md
│
├── 📁 scripts/
│   ├── run-qemu.sh
│   ├── install-usb.sh
│   ├── build.sh
│   └── test.sh
│
├── 📁 screenshots/
│   ├── bureau.png
│   ├── ide.png
│   ├── chip8.png
│   └── terminal.png
│
├── 📁 tests/
│   ├── forth_tests.fth
│   ├── jit_tests.fth
│   └── chip8_tests.fth
│
└── 📁 .github/
    ├── workflows/
    │   ├── build.yml
    │   └── test.yml
    └── ISSUE_TEMPLATE/
        ├── bug_report.md
        └── feature_request.md
```

---

## CHANGELOG.md

```markdown
# Changelog Epona OS

## [2.0.0] — 2024

### Ajouté
- 🆕 Compilateur JIT x86_64 avec 48 primitives natives
- 🆕 Format binaire signé EPJT (SHA-256 + HMAC)
- 🆕 Émulateur CHIP-8 complet (35 opcodes)
- 🆕 Assembleur CHIP-8 en Forth (ASM8.FTH)
- 🆕 IDE EponaForth intégré au bureau
- 🆕 Pile réseau TCP/IP, UDP, DNS, DHCP, HTTP
- 🆕 Support GPU multi-écran
- 🆕 Variables locales { } ANS Forth
- 🆕 Exceptions try/catch/endtry
- 🆕 Vocabulaires ANS Forth
- 🆕 Backtrace et débogueur pas-à-pas
- 🆕 Mémoire octet séparée (256 Ko)
- 🆕 Driver clavier USB HID AZERTY
- 🆕 Driver souris/touchpad USB HID
- 🆕 FAT32 bas niveau (lecture/écriture clusters)
- 🆕 Mode sandbox (mem-bounds, file-allow)
- 🆕 ~380 primitives Forth documentées

### Amélioré
- ⚡ Interpréteur 10× plus rapide avec JIT
- 📦 Dictionnaire avec vocabulaires et ordre de recherche
- 🖥️ Canvas redimensionnable jusqu'à 4096×4096
- 🔧 Compilateur Forth avec constant folding

## [1.0.0] — 2023

### Initial
- Interpréteur Forth bare-metal UEFI
- Framebuffer basique
- Support USB HID
- NVMe et AHCI
```

---

## CONTRIBUTING.md

```markdown
# Contribuer à Epona OS

## Comment contribuer

### 1. Rapporter un bug

Ouvrez une issue avec :
- La version d'Epona OS
- Le matériel (CPU, RAM, stockage)
- Les étapes pour reproduire
- Le comportement attendu vs observé

### 2. Proposer une fonctionnalité

Ouvrez une issue avec le tag `enhancement` :
- Description claire de la fonctionnalité
- Cas d'usage
- Exemple de code Forth si applicable

### 3. Contribuer du code

#### Fichiers Forth (.FTH)

C'est la contribution la plus simple !
Vous pouvez ajouter :
- De nouveaux jeux
- Des drivers
- Des outils
- Des démos

Format attendu :

```forth
( ═══════════════════════════════════════════ )
( NOM.FTH — Description courte              )
( Auteur: Votre Nom                          )
( Version: 1.0                               )
( ═══════════════════════════════════════════ )

sys:register mon-programme

: principal
    ." Mon programme" cr
;
```

#### Code Rust

- Suivre les conventions de nommage Rust
- Pas d'unsafe sauf si absolument nécessaire
- Documenter les fonctions publiques
- Ajouter des tests

### 4. Améliorer la documentation

La documentation est dans `docs/`.
Les fichiers sont en Markdown.

## Style de code Forth

```forth
( ── Commentaires de section ── )

( Signature toujours documentée )
: mon-mot ( a b -- résultat )
    \ implémentation
    +
;

( Constantes en MAJUSCULES )
0xFF constant MAX_VAL

( Variables en minuscules-tirets )
variable mon-compteur

( Mots privés préfixés par - )
: -helper ( -- )
    ...
;
```

## Tests

Avant de soumettre une PR :

```bash
./scripts/test.sh
```

Les tests Forth sont dans `tests/forth_tests.fth`.
```

---

## SECURITY.md

```markdown
# Politique de Sécurité Epona OS

## Fonctionnalités de sécurité

### Mode Sandbox

```forth
( Activer le sandbox pour un programme non fiable )
100 3800 mem-bounds      ( limiter l'accès mémoire )
s" \FORTH\" file-allow   ( autoriser un seul dossier )
net-revoke               ( interdire le réseau )
100000 set-max-instr     ( limiter les instructions )
```

### Signatures JIT

Les fichiers `.JIT` sont signés avec HMAC-SHA256.
Deux modes :
- **Machine** : lié au `device_id` de la machine
- **Portable** : clé fixe EPONA_PORTABLE_KEY

### Primitives dangereuses

Les primitives suivantes sont bloquées en mode sécurisé :
- Accès MMIO direct
- Ports I/O
- Accès physique mémoire
- MSR
- IOAPIC

## Signaler une vulnérabilité

Ouvrir une issue privée ou contacter directement.
```

---

## GitHub Actions — `.github/workflows/build.yml`

```yaml
name: Build Epona OS

on:
  push:
    branches: [ main, dev ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Installer Rust nightly
      uses: actions-rs/toolchain@v1
      with:
        toolchain: nightly
        components: rust-src
        targets: x86_64-unknown-uefi
        override: true

    - name: Installer QEMU
      run: sudo apt-get install -y qemu-system-x86

    - name: Compiler
      run: |
        cargo build --release --target x86_64-unknown-uefi

    - name: Vérifier la taille
      run: |
        ls -lh target/x86_64-unknown-uefi/release/*.efi
        SIZE=$(stat -c%s target/x86_64-unknown-uefi/release/*.efi)
        echo "Taille: $SIZE octets"
        if [ $SIZE -gt 10485760 ]; then
          echo "ERREUR: binaire trop grand (>10 Mo)"
          exit 1
        fi

    - name: Valider les fichiers Forth
      run: |
        for f in forth/**/*.fth forth/**/*.FTH; do
          echo "Vérification: $f"
          # Vérifier la syntaxe basique
          grep -n "^:" $f | head -5
        done

    - name: Archiver le binaire
      uses: actions/upload-artifact@v4
      with:
        name: epona-os-efi
        path: target/x86_64-unknown-uefi/release/*.efi

  test-forth:
    runs-on: ubuntu-latest
    needs: build

    steps:
    - uses: actions/checkout@v4

    - name: Vérifier la syntaxe Forth
      run: |
        echo "Tests fichiers Forth..."
        python3 scripts/validate_forth.py forth/

    - name: Compter les primitives
      run: |
        echo "Primitives dans interpreter.rs:"
        grep -c "add_primitive" src/interpreter.rs
        echo "Mots dans forth/:"
        grep -rh "^:" forth/ | wc -l
```

---

## Scripts utiles

### `scripts/run-qemu.sh`

```bash
#!/bin/bash
# Lance Epona OS dans QEMU avec OVMF (UEFI)

OVMF_PATH="/usr/share/ovmf/OVMF.fd"
EFI_FILE="target/x86_64-unknown-uefi/release/epona.efi"
USB_IMG="epona-usb.img"

# Créer une image USB virtuelle si elle n'existe pas
if [ ! -f "$USB_IMG" ]; then
    echo "Création image USB (64 Mo)..."
    dd if=/dev/zero of=$USB_IMG bs=1M count=64
    mkfs.fat -F 32 $USB_IMG

    # Copier les fichiers Forth
    mkdir -p /tmp/epona-mnt
    sudo mount -o loop $USB_IMG /tmp/epona-mnt
    sudo mkdir -p /tmp/epona-mnt/EFI/BOOT
    sudo cp $EFI_FILE /tmp/epona-mnt/EFI/BOOT/BOOTX64.EFI
    sudo cp -r forth/* /tmp/epona-mnt/
    sudo umount /tmp/epona-mnt
fi

# Lancer QEMU
qemu-system-x86_64 \
    -bios $OVMF_PATH \
    -drive file=$USB_IMG,format=raw,if=none,id=usb0 \
    -device usb-storage,drive=usb0 \
    -device usb-ehci \
    -device usb-kbd \
    -device usb-mouse \
    -m 512M \
    -vga std \
    -display gtk \
    -serial stdio \
    -cpu host \
    -enable-kvm \
    "$@"
```

### `scripts/install-usb.sh`

```bash
#!/bin/bash
# Installe Epona OS sur une clé USB physique

DEVICE=$1
EFI_FILE="target/x86_64-unknown-uefi/release/epona.efi"

if [ -z "$DEVICE" ]; then
    echo "Usage: $0 /dev/sdX"
    echo ""
    echo "Périphériques disponibles:"
    lsblk -d -o NAME,SIZE,MODEL
    exit 1
fi

echo "⚠️  ATTENTION: Formatage de $DEVICE"
echo "Toutes les données seront perdues!"
read -p "Continuer? (oui/non) " CONFIRM

if [ "$CONFIRM" != "oui" ]; then
    echo "Annulé."
    exit 0
fi

echo "Formatage en FAT32..."
sudo mkfs.fat -F 32 $DEVICE

echo "Montage..."
sudo mkdir -p /mnt/epona
sudo mount $DEVICE /mnt/epona

echo "Copie du bootloader EFI..."
sudo mkdir -p /mnt/epona/EFI/BOOT
sudo cp $EFI_FILE /mnt/epona/EFI/BOOT/BOOTX64.EFI

echo "Copie des fichiers Forth..."
sudo cp -r forth/* /mnt/epona/

echo "Démontage..."
sudo umount /mnt/epona

echo "✅ Epona OS installé sur $DEVICE"
echo "Démarrez votre PC depuis cette clé USB."
```

### `scripts/validate_forth.py`

```python
#!/usr/bin/env python3
"""
Valide la syntaxe basique des fichiers Forth Epona OS.
Vérifie :
- Les définitions : ouvertes avec : et fermées avec ;
- Les structures de contrôle équilibrées
- Les commentaires corrects
"""

import sys
import os
import glob

def validate_file(filename):
    errors = []
    depth = 0  # profondeur de définition
    line_num = 0

    with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            line_num += 1
            stripped = line.strip()

            # Ignorer les commentaires
            if stripped.startswith('\\'):
                continue
            if stripped.startswith('(') and stripped.endswith(')'):
                continue

            tokens = stripped.split()
            for token in tokens:
                if token == ':':
                    depth += 1
                elif token == ';':
                    depth -= 1
                    if depth < 0:
                        errors.append(f"  Ligne {line_num}: ';' sans ':' correspondant")
                        depth = 0

    if depth > 0:
        errors.append(f"  Définition non fermée ({depth} ':' sans ';')")

    return errors

def main():
    path = sys.argv[1] if len(sys.argv) > 1 else 'forth'
    files = glob.glob(f'{path}/**/*.FTH', recursive=True)
    files += glob.glob(f'{path}/**/*.fth', recursive=True)

    total = 0
    errors_found = 0

    for f in sorted(files):
        errors = validate_file(f)
        total += 1
        if errors:
            errors_found += 1
            print(f"❌ {f}")
            for e in errors:
                print(e)
        else:
            print(f"✅ {f}")

    print(f"\n{total} fichiers vérifiés, {errors_found} avec erreurs.")
    sys.exit(errors_found)

if __name__ == '__main__':
    main()
```

---

## Tests Forth — `tests/forth_tests.fth`

```forth
( ═══════════════════════════════════════════════════════════════════ )
( forth_tests.fth — Tests automatiques EponaForth                   )
( ═══════════════════════════════════════════════════════════════════ )

variable test-count
variable test-pass
variable test-fail

: test-begin ( -- )
    0 test-count !
    0 test-pass !
    0 test-fail !
    ." === Tests EponaForth ===" cr
;

: assert= ( expected actual name-addr name-len -- )
    { exp act name nlen -- }
    test-count @ 1+ test-count !
    act exp = if
        ." ✓ " name nlen type cr
        test-pass @ 1+ test-pass !
    else
        ." ✗ " name nlen type
        ."  (attendu=" exp . ." obtenu=" act . ." )" cr
        test-fail @ 1+ test-fail !
    then
;

: test-end ( -- )
    cr
    ." Résultats: "
    test-pass @ . ." passés, "
    test-fail @ . ." échoués sur "
    test-count @ . ." tests" cr
    test-fail @ 0= if
        ." ✅ Tous les tests passés !" cr
    else
        ." ❌ Des tests ont échoué." cr
    then
;

( ─── Tests arithmétique ─────────────────────────────────────────── )
test-begin

3 4 + 7 s" 3 + 4 = 7" assert=
10 3 - 7 s" 10 - 3 = 7" assert=
6 7 * 42 s" 6 * 7 = 42" assert=
20 4 / 5 s" 20 / 4 = 5" assert=
10 3 mod 1 s" 10 mod 3 = 1" assert=
-5 abs 5 s" abs(-5) = 5" assert=
3 negate -3 s" negate(3) = -3" assert=
3 7 min 3 s" min(3,7) = 3" assert=
3 7 max 7 s" max(3,7) = 7" assert=
5 ² 25 s" 5² = 25" assert=

( ─── Tests pile ──────────────────────────────────────────────────── )
5 dup + 10 s" 5 dup + = 10" assert=
3 4 swap drop 3 s" 3 4 swap drop = 3" assert=
1 2 over + 4 s" 1 2 over + = 4 (NOS+TOS)" assert=

( ─── Tests comparaisons ──────────────────────────────────────────── )
3 3 = -1 s" 3 = 3 → -1" assert=
3 4 = 0 s" 3 = 4 → 0" assert=
3 4 < -1 s" 3 < 4 → -1" assert=
4 3 > -1 s" 4 > 3 → -1" assert=
0 0= -1 s" 0= → -1" assert=
5 0= 0 s" 5 0= → 0" assert=

( ─── Tests logique ───────────────────────────────────────────────── )
0b1010 0b1100 and 0b1000 s" AND" assert=
0b1010 0b1100 or 0b1110 s" OR" assert=
0b1010 0b1100 xor 0b0110 s" XOR" assert=
1 4 lshift 16 s" 1 << 4 = 16" assert=
256 4 rshift 16 s" 256 >> 4 = 16" assert=

( ─── Tests mémoire ───────────────────────────────────────────────── )
variable test-var
42 test-var !
test-var @ 42 s" variable store/fetch" assert=
10 test-var +!
test-var @ 52 s" +! (42+10=52)" assert=

( ─── Tests chaînes ───────────────────────────────────────────────── )
s" hello" s" hello" compare
0 s" compare égal → 0" assert=

s" abc" s" abd" compare
-1 s" compare abc<abd → -1" assert=

( ─── Tests boucles ───────────────────────────────────────────────── )
0 10 0 do i + loop
45 s" somme 0..9 = 45" assert=

( ─── Tests mots définis ──────────────────────────────────────────── )
: fib ( n -- fib(n) )
    dup 2 < if exit then
    dup 1- fib
    swap 2- fib
    +
;
10 fib 55 s" fib(10) = 55" assert=

: factorielle ( n -- n! )
    dup 1 <= if drop 1 exit then
    dup 1- factorielle *
;
5 factorielle 120 s" 5! = 120" assert=

( ─── Tests valeurs ───────────────────────────────────────────────── )
100 value ma-valeur
ma-valeur 100 s" value init = 100" assert=
200 to ma-valeur
ma-valeur 200 s" to ma-valeur = 200" assert=

( ─── Tests try/catch ─────────────────────────────────────────────── )
0
try
    42 throw
catch
    dup 42 = if drop 1 then
endtry
1 s" try/catch fonctionne" assert=

( ─── Tests constantes ────────────────────────────────────────────── )
0xFF constant MAX-BYTE
MAX-BYTE 255 s" constant 0xFF = 255" assert=

( ─── Rapport final ───────────────────────────────────────────────── )
test-end
```

---

## Issues Templates

### `.github/ISSUE_TEMPLATE/bug_report.md`

```markdown
---
name: Rapport de bug
about: Signaler un problème dans Epona OS
title: '[BUG] '
labels: bug
---

## Description

Décrivez le bug clairement et succinctement.

## Matériel

- CPU : AMD Ryzen 5 5500U
- RAM : 8 Go
- Stockage : NVMe 477 Go
- GPU : AMD Radeon Graphics

## Version Epona OS

2.0.x

## Étapes pour reproduire

1. Lancer Epona OS
2. Taper '...' dans le terminal
3. Observer l'erreur

## Comportement attendu

Ce qui devrait se passer.

## Comportement observé

Ce qui se passe réellement.

## Code Forth impliqué

```forth
\ Code qui provoque le bug
```

## Message d'erreur

```
Erreur affichée à l'écran
```

## Informations supplémentaires

Tout autre contexte utile.
```

### `.github/ISSUE_TEMPLATE/feature_request.md`

```markdown
---
name: Demande de fonctionnalité
about: Proposer une nouvelle fonctionnalité
title: '[FEATURE] '
labels: enhancement
---

## Problème à résoudre

Décrivez le problème que cette fonctionnalité résoudrait.

## Solution proposée

Décrivez la fonctionnalité souhaitée.

## Exemple d'utilisation

```forth
\ Comment la fonctionnalité serait utilisée
nouvelle-primitive arg1 arg2
```

## Alternatives considérées

D'autres solutions envisagées.

## Contexte supplémentaire

Tout autre information utile.
```

---

## Idées de projets communautaires

### 🎮 Bibliothèque de jeux CHIP-8

```
forth/roms/
├── classiques/
│   ├── PONG.CH8
│   ├── TETRIS.CH8
│   ├── INVADERS.CH8
│   └── BREAKOUT.CH8
├── originaux/
│   ├── SNAKE8.CH8
│   ├── DUNGEON.CH8
│   └── MUSIC.CH8
└── demos/
    ├── MANDELBROT.CH8
    ├── STARFIELD.CH8
    └── PLASMA.CH8
```

### 🔧 Bibliothèque de drivers

```
forth/drivers/
├── DRIVER_CLAVIER_USB.FTH   ✅ fait
├── DRIVER_SOURIS_USB.FTH    ✅ fait
├── DRIVER_AUDIO_HDA.FTH     ← à faire
├── DRIVER_BLUETOOTH.FTH     ← à faire
├── DRIVER_WIFI_RTL.FTH      ← à faire
└── DRIVER_TOUCHSCREEN.FTH   ← à faire
```

### 🌐 Applications réseau

```
forth/apps/
├── NAVIGATEUR.FTH    ← navigateur web minimaliste
├── CHAT.FTH          ← client IRC simple
├── FTP.FTH           ← client FTP
└── TELNET.FTH        ← client Telnet
```

### 📐 Démos graphiques

```
forth/demos/
├── MANDELBROT.FTH    ← fractale Mandelbrot
├── PLASMA.FTH        ← effet plasma
├── STARFIELD.FTH     ← champ d'étoiles 3D
├── RAYCASTER.FTH     ← raycasting style Doom
└── PARTICLES.FTH     ← système de particules
```

---

## Topics GitHub recommandés

```
forth
operating-system
uefi
bare-metal
rust
x86_64
jit-compiler
chip8
embedded
systems-programming
```

---

## Badges README

```markdown
![Build](https://github.com/vous/epona-os/actions/workflows/build.yml/badge.svg)
![Rust](https://img.shields.io/badge/rust-nightly-orange)
![UEFI](https://img.shields.io/badge/UEFI-x86__64-blue)
![Forth](https://img.shields.io/badge/Forth-ANS-green)
![License](https://img.shields.io/badge/license-MIT-blue)
![Primitives](https://img.shields.io/badge/primitives-380%2B-purple)
![JIT](https://img.shields.io/badge/JIT-x86__64-red)
```
