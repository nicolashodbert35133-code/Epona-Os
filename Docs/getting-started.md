# Bien démarrer avec Epona OS

Ce guide explique comment obtenir, construire et booter Epona OS, puis utiliser
les commandes de base du shell.

## 1. Télécharger une image (option A — sans compiler)

1. Récupérez la dernière version pré-compilée sur la page **Releases** de GitHub.
2. Décompressez le fichier : il contient une arborescence prête à copier.

> La version pré-compilée arrive avec l'activation des Releases (Phase 7/8).
> En attendant, utilisez l'option B ci-dessous.

## 2. Construire depuis la source (option B)

Prérequis : `rustup` avec la toolchain nightly et la cible UEFI.

```bash
rustup override set nightly
rustup target add x86_64-unknown-uefi --toolchain nightly
cargo build --release --target x86_64-unknown-uefi
```

L'EFI est généré dans :

```
target/x86_64-unknown-uefi/release/rust_os.efi
```

## 3. Créer la clé USB

La clé doit être **FAT32**. Copiez l'EFI et le dossier `forth/` à la racine :

```
D:\EFI\BOOT\BOOTX64.EFI     <-- renommé depuis rust_os.efi
D:\BOOT.FTH                 <-- loader (config + séquence de boot)
D:\forth\...                <-- std/, drivers/, apps/, config/, boot/...
```

Exemple avec `cp` :

```bash
mkdir -p /mnt/usb/EFI/BOOT /mnt/usb/forth
cp target/x86_64-unknown-uefi/release/rust_os.efi /mnt/usb/EFI/BOOT/BOOTX64.EFI
cp BOOT.FTH /mnt/usb/
cp -r forth/* /mnt/usb/forth/
```

Démarrez la machine sur la clé (touche de boot du BIOS/UEFI). Le noyau affiche
le shell et exécute automatiquement `BOOT.FTH` (init matériel puis
auto-détection PCI + chargement des drivers Forth).

## 4. Premier boot

Au démarrage le shell affiche un rapport : mémoire, CPU, GPU (GOP), USB,
puis la liste des drivers chargés (`[DRV-AUTO]`).

Commandes utiles :

| Commande        | Rôle                                              |
|-----------------|---------------------------------------------------|
| `aide`          | Affiche l'aide du shell                            |
| `drivers`       | Liste les drivers chargés                          |
| `pci liste`     | Liste les périphériques PCI détectés               |
| `ls`            | Liste les fichiers du volume courant              |
| `cd <dossier>`  | Change de répertoire                               |
| `exec <f>`      | Exécute un script Forth                            |
| `exit-uefi`     | Bascule en runtime natif (après init-fs)          |

## 5. Personnaliser (CONFIG.FTH)

Créez ou modifiez `forth/config/default.fth` sur la clé. Il est chargé en
premier par `BOOT.FTH` et permet de surcharger la configuration :

```forth
16 constant FG-GREEN          \ couleur du texte
0  constant BG-BLACK          \ fond
0  constant AUTO-EXIT-UEFI    \ 1 = basculer en runtime natif automatiquement
```

Pas besoin de recompiler : seule la clé USB change.

## 6. Dépannage

- **Rien ne s'affiche** : vérifiez que la clé est FAT32 et que
  `EFI\BOOT\BOOTX64.EFI` est présent.
- **Pas de drivers** : le boot doit afficher `[DRV-AUTO]`. Si rien, lancez
  `init-fs` puis `exit-uefi`, ou vérifiez `forth/config/drvmap.fth`.
- **Système instable** : testez avec QEMU (voir `docs/kernel-hacking.md`).
