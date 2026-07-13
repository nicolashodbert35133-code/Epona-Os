# 🐴 Epona OS

**Un système d'exploitation bare-metal UEFI écrit en Rust
avec un interpréteur Forth intégré.**

Epona OS démarre directement sur le processeur — pas de Windows,
pas de Linux, pas de couche intermédiaire. Tapez du Forth,
manipulez le matériel en temps réel.

![Bureau Epona OS](screenshots/desktop.png)

## ✨ Fonctionnalités

- 🖥️ Bureau graphique avec fenêtres et icônes
- ⌨️ Interpréteur Forth complet (290+ primitives)
- 🎮 GPU Intel/AMD — accélération 2D native
- 🌐 Réseau TCP/UDP/HTTP (Intel e1000, Realtek)
- 💾 Stockage NVMe + SATA (FAT32, NTFS, ext4)
- 🔊 Audio HD (HDA)
- 🖱️ USB 3.0 (XHCI) — souris, clavier, disques
- 🔄 Multitâche préemptif avec mutex
- 📐 Virgule fixe Q20.12 (trigonométrie, physique)
- 🧪 Suite de tests automatisés

## 🚀 Démarrage rapide

1. Téléchargez `BOOTX64.EFI` depuis
  le dossier EFI
2. Formatez une clé USB en FAT32
3. Créez le dossier `EFI\BOOT\`
4. Copiez `BOOTX64.EFI` dedans
5. Démarrez votre PC sur la clé USB

**Aucune installation. Votre disque dur n'est pas modifié.**

## 📝 Premiers pas

```forth
\ Afficher la RAM
mem-map swap 4 * 1024 / . ." MB" cr

\ Scanner le bus PCI
pci-scan . ." peripheriques" cr

\ Ping Google
net:init drop net:dhcp drop
8 8 8 8 net:ping . ." ms" cr

# Contribuer à Epona OS

Merci de votre intérêt ! Voici comment contribuer.

## Pour commencer

1. Forkez le repo
2. Créez une branche (`git checkout -b ma-feature`)
3. Commitez (`git commit -m "Ajout de ..."`)
4. Poussez (`git push origin ma-feature`)
5. Ouvrez une Pull Request

## Types de contributions

### 🟢 Facile (pas besoin de connaître Rust)
- Tester sur votre machine et ouvrir une Issue
- Écrire des programmes Forth (.FTH)
- Corriger des fautes dans la documentation
- Traduire en anglais

### 🟡 Moyen (Forth ou Rust basique)
- Écrire un jeu en Forth
- Écrire un driver en Forth
- Ajouter des tests dans TESTS.FTH
- Créer un tutoriel

### 🔴 Avancé (Rust bare-metal)
- Ajouter des primitives matériel
- Améliorer le compilateur Forth
- Optimiser les drivers GPU
- Implémenter le JIT x86-64

## Convention de code

### Rust
- `cargo fmt` avant chaque commit
- Pas de `unsafe` sans commentaire justificatif
- Chaque primitive documentée avec stack effect

### Forth
- Stack effect obligatoire : `( avant -- après )`
- Noms en minuscules avec `:` pour les modules
- Tests pour chaque nouveau mot

## Rapporter un bug

Ouvrez une Issue avec :
- Votre matériel (CPU, GPU, carte mère)
- Ce que vous avez tapé
- Ce qui s'est passé
- Ce que vous attendiez

\ Dessiner un rectangle rouge
100 100 200 150 0xFF0000 gpu:fill
gpu:flip
