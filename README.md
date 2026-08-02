<h1 align="center">
  <br>
  <img src="https://raw.githubusercontent.com/nicolashodbert35133-code/Epona-Os/main/Epona%20Os%20fond%20transparent.png" alt="Epona OS Logo" width="380">
  <br>
  Epona OS 2.0 — Release v1.98 (Septembre 2026)
  <br>
</h1>

<h3 align="center">
  Système d'Exploitation Français Autonome Bare-Metal UEFI en Rust avec Machine Virtuelle Forth et Compilateur JIT x86-64 Natif
</h3>

<p align="center">
  <a href="https://github.com/nicolashodbert35133-code/Epona-Os/releases">
    <img src="https://img.shields.io/badge/Release-v1.98%20(Sept%202026)-8b5cf6.svg?style=for-the-badge&logo=github" alt="Release v1.98">
  </a>
  <a href="https://discord.gg/kwWBWhmvN">
    <img src="https://img.shields.io/badge/Discord-Rejoindre%20la%20Communaut%C3%A9-5865F2.svg?style=for-the-badge&logo=discord&logoColor=white" alt="Discord">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-10b981.svg?style=for-the-badge" alt="License MIT">
  </a>
</p>

<p align="center">
  <a href="https://www.rust-lang.org/">
    <img src="https://img.shields.io/badge/Kernel-Rust%20Bare--Metal%20no__std-f97316.svg" alt="Rust Kernel">
  </a>
  <a href="https://uefi.org/">
    <img src="https://img.shields.io/badge/Firmware-UEFI%20x86__64-0284c7.svg" alt="UEFI">
  </a>
  <a href="https://forth-standard.org/">
    <img src="https://img.shields.io/badge/VM-Forth%20JIT%20Compiler-ef4444.svg" alt="Forth VM">
  </a>
  <img src="https://img.shields.io/badge/Primitives-700%2B%20Natives-06b6d4.svg" alt="Primitives Forth">
  <img src="https://img.shields.io/badge/Shell-70%20Commandes-a855f7.svg" alt="Shell Commands">
</p>

<p align="center">
  <b>Epona OS</b> est un système d’exploitation français, libre, autonome et souverain, conçu et développé en Bretagne.
  Il combine la sécurité et la puissance d'un <b>noyau Rust fermé bare-metal</b> avec la liberté d'un <b>environnement Forth ouvert</b> doté d'un compilateur JIT x86-64 natif.
</p>

---

## 🎯 À qui s’adresse Epona OS ?

Epona OS est un système d'exploitation d'un genre nouveau, ciblant une communauté d'expérimentateurs et de créateurs :

- 💡 **Les Geeks & Passionnés d'Architecture** : Pour comprendre le fonctionnement réel d'un ordinateur et piloter le processeur sans couche d'abstraction opaque.
- 🦀 **Les Développeurs Bas-Niveau (Rust, ASM, Forth)** : Pour écrire des programmes et des pilotes bare-metal ultra-rapides sans aucune dépendance lourde.
- 🔌 **Les Makers, Électroniciens & Hardware Hackers** : Pour piloter des puces custom, des puces FPGA, des modules USB ou des microcontrôleurs directement depuis l'OS sans SDK ni IDE lourd.
- 🛠️ **Les Bidouilleurs Hardware & Créateurs d'OS** : Pour tester des instructions machine, des drivers et des interfaces graphiques en direct sur le métal.
- 🇫🇷 **Les Adeptes d'OS Souverains & Minimalistes** : Pour disposer d'un environnement sans bloatware, autonome et agentique.

---

## 🚀 Zéro Application Obligatoire & Bureau Unique à Chaque Utilisateur

Contrairement aux systèmes propriétaires ou aux distributions grand public, **Epona OS ne vous impose AUCUNE application préinstallée ni aucun bloatware**.

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│              PHILOSOPHIE EPONA OS : ZÉRO BLOATWARE • 100% LIBERTÉ                │
├──────────────────────────────────────────────────────────────────────────────────┤
│  ✓ Zéro application obligatoire préinstallée                                      │
│  ✓ Zéro processus d'arrière-plan caché ou télémétrie                             │
│  ✓ Un Bureau sur-mesure codé en Forth, unique pour chaque utilisateur            │
│  ✓ Vos pilotes, vos widgets et vos jeux sur votre clé USB Live                   │
└──────────────────────────────────────────────────────────────────────────────────┘
```

- 🎨 **Un Bureau Personnel et Unique** : Comme tout l'environnement graphique repose sur des scripts Forth ouverts (`.fth`), chaque utilisateur peut créer ou modifier son propre bureau (mode fenêtré classique, interface radiale, mode cyberpunk, minimaliste ou pur terminal).
- 🛠️ **Liberté Totale de Création** : Vous décidez des scripts chargés dans `BOOT.FTH`. Votre système contient uniquement ce dont vous avez besoin.

---

## 🛠️ Quelles Applications Peut-on Créer avec Epona OS ?

Grâce à ses **700+ primitives Forth** et son **compilateur JIT x86-64 natif**, les possibilités de création sont infinies :

1. 🎮 **Jeux 2D/3D & Émulateurs** :
   - Moteurs graphiques 3D en Raycasting (style *Doom*), jeux de réflexion (Snake, Tetris), émulateurs complets (ex. émulateur CHIP-8 avec assembleur intégré).
2. 🔌 **Outils Matériels & Hardware Hacking** :
   - Enregistreurs de données pour capteurs I2C/SPI, oscilloscopes virtuels, outils de flashage de puces microcontrôleurs/FPGA via USB XHCI.
3. 📝 **Bureaux & Outils de Productivité Personnalisés** :
   - Éditeurs de texte natifs (`EDITEUR.fth`), moniteurs de ressources CPU/RAM temps réel (`sysmon`), calculateurs à pile ou lecteurs audio PCM (HDA Codec).
4. 🌐 **Applications Réseau & Serveurs Web** :
   - Serveurs HTTP/HTTPS légers, clients de diagnostic réseau (Ping, DNS), utilitaires de communication inter-machines.

---

## 🤖 VISION À 2 ANS (HORIZON 2028) : LE SYSTÈME AUTONOME & SOUVERAIN (Spécification `Os autonome.md`)

Inspiré de la feuille de route d'ingénierie **`Os autonome.md`**, Epona OS évolue d'ici 2 ans vers un système **100% autonome, auto-géré et agentique** affranchi de toute dépendance historique :

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                   EPONA OS 2028 : SYSTÈME TOTALEMENT AUTONOME                    │
├──────────────────────────────────────────────────────────────────────────────────┤
│ 1. AUTONOMIE POST-BOOT   : Sortie totale ExitBootServices, GDT/IDT/PML4 directes │
│ 2. SCHEDULER CPU V2      : Processus préemptifs isolés (CpuContext & Ring 3)     │
│ 3. VFS ARBORESCENT V2    : Mounting DevFS, ProcFS, RamFS (/tmp) & NVMe FAT32     │
│ 4. AGENT IA PILOTES      : Auto-détection matériel & binding dynamique .FTH      │
│ 5. BLUETOOTH & WIRELESS  : Pile Bluetooth HCI autonome, Wi-Fi 802.11 & HDA Audio │
│ 6. STORE SOUVERAIN .FTH  : Store décentralisé d'applications et drivers signés  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

1. ⚡ **Autonomie Matérielle Totale (`ExitBootServices`)** :
   - Dès l'amorce terminée, Epona OS quitte définitivement les Boot Services UEFI via `exit_boot_services`. Le noyau contrôle le processeur x86-64 avec sa propre table de pagination PML4, sa table de descripteurs d'interruptions IDT et son allocateur mémoire physique autonome.
2. 🔄 **Ordonnancement Préemptif V2 (`CpuContext` & IPC)** :
   - Un scheduler multitâche préemptif gérant la commutation de contexte CPU complète (`rax`...`r15`, `fxsave` FPU/SSE), les files d'attente IPC inter-processus et la mémoire partagée.
3. 🤖 **Agent IA Autonome de Détection Matérielle** :
   - Un sous-système agentique scannant les bus PCI, USB XHCI et I2C, associant automatiquement chaque composant détecté au pilote Forth `.fth` approprié depuis le VFS.
4. 🏬 **Le Store Souverain Epona Forth (`fth-store`) & Usage Quotidien** :
   - Un store décentralisé où les développeurs partagent leurs scripts, jeux et outils. En un clic ou une commande, l'application est chargée et compilée en code machine natif par le JIT x86-64. Epona OS devient un système rapide (boot < 1 sec, < 150 MB RAM) utilisable au quotidien face aux OS américains propriétaires devenus trop lourds et truffés de télémétrie.

---

## ⚔️ Epona OS Comparé aux Systèmes d'Exploitation Historiques

Contrairement aux systèmes d'exploitation traditionnels qui empilent des couches d'abstractions complexes, Epona OS adopte une philosophie de contrôle direct et interactif :

| Caractéristique | MS-DOS | AmigaOS | Linux (Kernel C) | Windows | **Epona OS (Sept 2026/2028)** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Noyau & Sécurité** | 16-bit Mono-tâche, non protégé | 32-bit Multi-tâche sans protection | Kernel massif en C / POSIX | Fermé, boîte noire | **Noyau Rust 64-bit Autonome (`ExitBootServices`)** |
| **Langage Système** | Assembleur 16-bit | C / Assembleur 68k | C / Shell Bash | C / C++ | **Rust Bare-Metal + Forth JIT x86-64** |
| **Extensibilité Pilotes** | Fichiers `.SYS` statiques | Pilotes C / Bibliothèques | Modules Kernel `.ko` complexes | Drivers signés lourds | **Scripts `.FTH` Ouverts & Agent IA Autonome** |
| **Compilateur JIT** | Aucun | Aucun | Aucun (Interpréteur BPF) | Aucun | **Compilateur JIT x86-64 Natif Intégré** |
| **Accès Hardware Direct** | Accès I/O direct sans mémoire | Puces Custom (OCS/AGA) | Bloqué / Via `/dev/` et `/sys/` | Entièrement bloqué | **Registres MMIO, PCI, USB XHCI, Bluetooth & I2C** |
| **Environnement GUI** | Ligne de commande pure | Workbench 2D pionnier | X11 / Wayland lourd | Desktop propriétaire | **Bureau Windowed Composité Forth 60 FPS** |
| **Personnalisation Bureau** | Aucune | Thèmes Workbench | Thèmes Desktop (Gnome/KDE) | Thèmes fermés | **Bureau Sur-Mesure Codé en Forth (.fth)** |
| **Écosystème & Store** | Aucun | Disquettes Aminet | Dépôts `.deb`/`.rpm` lourds | Microsoft Store fermé | **Store Décentralisé FTH JIT Souverain** |

---

## 🎨 Aperçu de l'Environnement Graphique Forth (Vision Septembre 2026)

Voici l'interface du bureau graphique windowed d'Epona OS, codée et compositée entièrement en **Forth bare-metal** sur le Framebuffer GOP UEFI à 60 FPS VSync :

<p align="center">
  <img src="https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/desktop.svg" alt="desktop" width="1000">
  <br>
</p>

<p align="center">
  <img src="https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/desktop_futuristic.svg" alt="desktop2" width="1000">
  <br>
</p>

---

## 💡 Le Concept Architectural : Noyau Fermé + Forth JIT Ouvert

Epona OS résout le dilemme entre sécurité bas niveau et extensibilité communautaire rapide grâce à une architecture à deux couches :

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                      ÉCOSYSTÈME OUVERT (COMMUNAUTÉ & MAKERS)                     │
│  [Pilotes .FTH]      [Jeux & Démos .FTH]      [Bureau GUI .FTH]    [EDITEUR.fth]  │
└────────────────────────────────────────┬─────────────────────────────────────────┘
                                         │ API Forth VM & Compilateur JIT x86-64
                                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                           NOYAU RUST FERMÉ ET SÉCURISÉ                           │
│                     Délivré sous forme de binaire BOOTX64.EFI                    │
│ [Boot UEFI] [Paging vmm.rs] [Scheduler_v2] [USB XHCI] [NVMe/SATA] [GOP Framebuffer]│
└──────────────────────────────────────────────────────────────────────────────────┘
```

1. **Le Noyau Rust (`BOOTX64.EFI`) :**  
   Fermé et sécurisé pour protéger l'intégrité du matériel, la pagination mémoire `vmm.rs`, l'ordonnancement préemptif `scheduler_v2.rs` et les contrôleurs de bus (USB 3.0 XHCI, NVMe, SATA AHCI, GPU).
2. **L'Environnement Forth (`.fth`) & JIT (`jit.rs`) :**  
   Ouvert à la communauté des développeurs et makers. Permet d'écrire des pilotes matériels, des jeux, des interfaces graphiques et des outils système **sans jamais avoir à recompiler le noyau Rust** ! Le compilateur JIT traduit les boucles Forth en code machine x86-64 natif exécuté à vitesse maximale.

---

## ⚡ Ce Qui Rendra Epona OS Unique en Septembre 2026

- 🦀 **100% Rust Bare-Metal `no_std`** : Aucun kernel Linux, aucun runtime C, aucune dépendance std.
- ⚡ **Compilateur JIT x86-64 Natif** : Compilation à la volée des mots Forth avec signature cryptographique.
- 🖥️ **700+ Primitives Forth Natives** : Arithmétique 64-bit, flottants SSE2 (`fsin`, `fcos`, `fsqrt`), accès registres MMIO, ports I/O (`inb`, `outb`), scan PCI et compositage GUI 2D/3D.
- ⌨️ **Terminal Shell Hybride (70 Commandes)** : Support de l'autocomplétion `Tab`, de l'historique, des pipelines `|`, des redirections `>` et du fallback automatique vers l'interpréteur Forth.
- 🔌 **Accès Matériel Direct via USB 3.0 & PCI** : Pilotez des puces custom, FPGA, cartes réseau ou microcontrôleurs directement depuis la console Forth.
- 🎵 **Multimédia & Réseau** : Pilote Intel High Definition Audio (HDA), pile réseau TCP/IP, UDP, ICMP Ping et Wi-Fi Realtek.

---

## 🔍 Compatibilité Matérielle : Envoyez Votre Dump PCI !

Epona OS est en constante évolution matérielle. Pour nous aider à supporter le matériel de votre PC :

1. Téléchargez la dernière release et démarrez Epona OS sur votre clé USB Live.
2. Dans le Terminal Shell, tapez la commande :
   ```bash
   ok / > pci save
   ```
3. Le fichier **`PCI.TXT`** est automatiquement créé sur votre clé USB.
4. Ouvrez une **[Issue sur GitHub](https://github.com/nicolashodbert35133-code/Epona-Os/issues)** et joignez votre fichier `PCI.TXT`.
5. Nous utiliserons votre inventaire PCI pour valider et créer les pilotes Forth nécessaires !

---

## 📖 Spécifications & Guides de Développement

Le projet est intégralement documenté pour les développeurs et la communauté :

| Fichier de Documentation | Description & Contenu |
| :--- | :--- |
| **[rapport.md](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/rapport.md)** | Rapport d'audit d'architecture complet des 55 modules Rust de `src/` et feuille de route vers Septembre 2026. |
| **[DEVFORTH.MD](https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/Docs/DEVFORTH.MD)** | Manuel d'ingénierie exhaustif des 700+ primitives Forth (Signatures de pile, code Rust, exemple). |
| **[DEVSHELL.MD](https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/Docs/DEVSHELL.MD)** | Guide officiel du Shell et des 70 commandes natives avec sessions de terminal. |
| **[DEV_GUIDE_MAIN.md](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/DEV_GUIDE_MAIN.md)** | Guide de démarrage bare-metal, boot sequence UEFI et `ExitBootServices`. |
| **[DEV_GUIDE_DRIVERS.md](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/DEV_GUIDE_DRIVERS.md)** | Manuel d'écriture des pilotes matériels en Forth (`.fth`). |
| **[DEV_GUIDE_SHELL.md](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/DEV_GUIDE_SHELL.md)** | Architecture interne du moteur d'édition de ligne et d'affichage terminal `shell.rs`. |

---

## 🚀 Démarrage Rapide (Clé USB Live)

### 1. Installation sur Clé USB

1. Insérez une clé USB (formatée en FAT32).
2. Copiez le binaire compilé `BOOTX64.EFI` dans le dossier `EFI/BOOT/` de la clé USB :
   ```
   E:\ (Clé USB FAT32)
   ├── EFI/
   │   └── BOOT/
   │       └── BOOTX64.EFI
   ├── BOOT.FTH
   └── forth/
       ├── bureau/
       ├── drivers/
       └── demos/
   ```
3. Insérez la clé USB dans votre ordinateur PC, redémarrez et choisissez le démarrage UEFI sur la clé USB !

---

## 💬 Rejoignez la Communauté Discord !

Venez échanger sur l'architecture bas niveau, le langage Forth, les pilotes matériels et participer à l'aventure Epona OS :

👉 **[Rejoindre le Serveur Discord Epona OS](https://discord.gg/kwWBWhmvN)**

---

<p align="center">
  <i>Epona OS — Système d'Exploitation Français Souverain & Bare-Metal. Conçu avec passion en Bretagne.</i>
</p>
