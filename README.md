<h1 align="center">
  <br>
  <img src="https://raw.githubusercontent.com/nicolashodbert35133-code/Epona-Os/main/Epona%20Os%20fond%20transparent.png" alt="Epona OS Logo" width="380">
  <br>
  Epona OS 2.0 — Release v1.98 (Septembre 2026)
  <br>
</h1>

<h3 align="center">
  Système d'Exploitation Celte Bare-Metal UEFI en Rust avec Machine Virtuelle Forth et Compilateur JIT x86-64 Natif
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
  <img src="https://img.shields.io/badge/Primitives-290%2B%20Natives-06b6d4.svg" alt="Primitives Forth">
  <img src="https://img.shields.io/badge/Shell-42%20Commandes-a855f7.svg" alt="Shell Commands">
</p>

<p align="center">
  <b>Epona OS</b> est un système d’exploitation français, libre, autonome et souverain, conçu et développé en Bretagne.
  Il combine la sécurité et la puissance d'un <b>noyau Rust fermé bare-metal</b> avec la liberté d'un <b>environnement Forth ouvert</b> doté d'un compilateur JIT x86-64 natif.
</p>

---

## 🎨 Aperçu de l'Environnement Graphique Forth (Vision Septembre 2026)

Voici l'interface du bureau graphique windowed d'Epona OS, codée et compositée entièrement en **Forth bare-metal** sur le Framebuffer GOP UEFI à 60 FPS VSync :

<p align="center">
  <img src="https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/desktop.svg"  alt="desktop" width=1000">
  <br>
</p>

<p align="center">
  <img src="https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/desktop_futuristic.svg"  alt="desktop2" width="1000">
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
   Fermé et sécurisé pour protéger l'intégrité du matériel, la pagination mémoire [vmm.rs], l'ordonnancement préemptif [scheduler_v2.rs] et les contrôleurs de bus (USB 3.0 XHCI, NVMe, SATA AHCI, GPU).
2. **L'Environnement Forth (`.fth`) & JIT (`jit.rs`) :**  
   Ouvert à la communauté des développeurs et makers. Permet d'écrire des pilotes matériels, des jeux, des interfaces graphiques et des outils système **sans jamais avoir à recompiler le noyau Rust** ! Le compilateur JIT traduit les boucles Forth en code machine x86-64 natif exécuté à vitesse maximale.

---

## ⚡ Ce Qui Rendra Epona OS Unique en septembre 2026

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
| Rapport d'audit d'architecture complet des 55 modules Rust de `src/` et feuille de route vers Septembre 2026. |
| **[DEVFORTH.MD](https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/Docs/DEVFORTH.MD)** | Manuel d'ingénierie exhaustif des 700+ primitives Forth (Signatures de pile, code Rust, exemple). |
| **[DEVSHELL.MD](https://github.com/nicolashodbert35133-code/Epona-Os/blob/main/Docs/DEVSHELL.MD)** | Guide officiel du Shell et des 42 commandes natives avec sessions de terminal. |
| Guide de démarrage bare-metal, boot sequence UEFI et `ExitBootServices`. |
| Manuel d'écriture des pilotes matériels en Forth (`.fth`). |
| Architecture interne du moteur d'édition de ligne et d'affichage terminal `shell.rs`. |

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
  <i>Epona OS — Système d'Exploitation Celte Souverain & Bar-Metal. Conçu avec passion en Bretagne.</i>
</p>
