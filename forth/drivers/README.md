# Drivers Forth pour Epona OS

Drivers communautaires au **format §7** (framework `drvlib.fth`). Chaque
fichier `.fth` définit des métadonnées (`drv:name!`, `drv:version!`,
`drv:license!`, `drv:desc!`), une table PCI (`pci:add-id`/`pci:add-class`),
trois mots de cycle de vie (`drv:probe`, `drv:init`, `drv:fini`) et se
termine par `drv:register`.

## Structure

```
forth/drivers/
├── TEMPLATE.fth          Template §7.1 a copier pour un nouveau driver
├── README.md             Ce fichier
├── generic-simplefb.fth  Framebuffer UEFI (fallback GPU universel)
├── generic-xhci.fth      Controleur hote USB xHCI
├── usb-hid.fth           Clavier / souris USB (HID)
├── generic-ahci.fth      Controleur SATA AHCI
├── generic-nvme.fth      Controleur NVMe
├── generic-hda.fth       Audio High Definition
├── e1000-generic.fth     Carte reseau Intel PRO/1000
├── rtc.fth               Horloge RTC (CMOS)
├── pcspkr.fth            Haut-parleur PC
├── WD-SN770-NVMe.FTH     Exemple materiel reel (NVMe WD Black SN770)
├── AMD-Ryzen5-5500U.FTH  Exemple plateforme (Root Complex Cezanne)
├── bochs-vga.fth         Exemple QEMU (Bochs VGA, framebuffer GOP)
├── virtio-net.fth        Exemple QEMU (VirtIO reseau)
└── ...                   Anciens pilotes (format pre-§7) en cours de
                          migration — voir notes ci-dessous
```

## Ecrire un nouveau driver

1. Copier `TEMPLATE.fth` : `cp TEMPLATE.fth mon-driver.fth`.
2. Remplir l'en-tete (nom, version, auteur, license, description).
3. Definir les metadonnees :
   ```forth
   s" mon-driver" drv:name!
   0 1 0 drv:version!
   s" MIT" drv:license!
   s" Description courte" drv:desc!
   3 drv:type!          \ 0 Generic, 1 Network, 2 Audio, 3 Storage,
                        \ 4 Input, 5 Usb, 6 Gpu
   ```
4. Declarer le materiel PCI :
   ```forth
   pci:add-id 0xVVVV 0xDDDD   \ correspondance exacte vendor:device
   pci:add-class 0xCC 0xSS    \ correspondance classe:subclasse
   ```
5. Ecrire `drv:probe` (test rapide, optionnel) et `drv:init` (retourne
   `-1` si OK, `0` sinon), optionnellement `drv:fini`.
6. Terminer par `drv:register`.
7. Ajouter une ligne dans `forth/config/drvmap.fth` pour le chargement
   automatique :
   ```forth
   pci:entry 0xVVVV 0xDDDD s" forth/drivers/mon-driver.fth"
   ```

## Regles

1. `drv:init ( bar bus dev func -- ok? )` : **ne quitte jamais le noyau**.
   Logguer avec `drv:log`/`drv:warn`/`drv:err`/`drv:ok` et retourner 0.
2. Memoire persistante : **`create` uniquement** (`create BUF 512 allot`).
   Ne jamais melanger `variable` et `create` (voir `forth/std/drvlib.fth`).
3. Pas d'adresse fixe : utiliser la `bar` passee a `drv:init`.
4. Handler d'IRQ court : pas de `type`, pas d'allocation, EOI immediat.
5. Ne pas utiliser `exit` dans un mot qui declare des locals
   (`{ ... }` : `Op::Exit` ne nettoie pas les locals).
6. Guide complet : `DEV_GUIDE_DRIVERS.md` §9 (ecrire un driver pas a pas)
   et `DEV_GUIDE_DRIVER_AGENT.md` §7 (template + drivers generiques).

## Table des drivers

| Fichier | Type | Materiel | Statut |
|---|---|---|---|
| `generic-simplefb.fth` | Gpu | Framebuffer UEFI (fallback universel) | stable |
| `generic-xhci.fth` | Usb | Controleurs xHCI (AMD/Intel/ASMedia) | testing |
| `usb-hid.fth` | Input | Clavier / souris USB (HID) | testing |
| `generic-ahci.fth` | Storage | Controleurs SATA AHCI | testing |
| `generic-nvme.fth` | Storage | SSD NVMe | testing |
| `generic-hda.fth` | Audio | Audio High Definition (04:03) | experimental |
| `e1000-generic.fth` | Network | Intel PRO/1000 (8254x/8257x/I217/...) | experimental |
| `rtc.fth` | Generic | Horloge RTC CMOS | stable |
| `pcspkr.fth` | Generic | Haut-parleur PC | stable |
| `WD-SN770-NVMe.FTH` | Storage | WD Black SN770 (15B7:5017) | stable |
| `AMD-Ryzen5-5500U.FTH` | Generic | Root Complex AMD Cezanne (1022:1631) | testing |
| `bochs-vga.fth` | Gpu | Bochs/QEMU VGA (1234:1111) — exemple QEMU | testing |
| `virtio-net.fth` | Network | VirtIO net (1af4:1000) — exemple QEMU | testing |

## Anciens pilotes (format pre-§7)

Les fichiers suivants utilisent l'ancien format (`register-driver`,
`hw-init`, `driver-register`) et **ne sont pas charges** par l'autoloader
car ils ne definissent ni `drv:probe` ni `drv:init`. Ils servent de
reference historique et doivent etre migres vers le format §7.1 :

- `ps2-keyboard.fth`, `rtl8139.fth` (utilisent `register-driver`)
- `AMD-ACP-Audio.FTH`, `AMD-Cezanne-ACPI.FTH`, `AMD-Cezanne-APIC.FTH`,
  `AMD-Radeon-Vega7.FTH`, `AMD-xHCI-USB3.FTH`, `ELAN-Tactile-I2C.FTH`,
  `PCIe-Standard.FTH`, `Realtek-ALC256.FTH`, `Realtek-RTL8168.FTH`,
  `Realtek-RTL8821CE.FTH`, `USB-HID-Keyboard-Standard.FTH`

## Primitives utiles pour les drivers

| Mot | Pile | Description |
|---|---|---|
| `mmio@` / `mmio!` | ( addr -- u32 ) / ( val addr -- ) | Lecture/ecriture MMIO 32-bit |
| `mmio-w@` / `mmio-b@` | ( addr -- u16 ) / ( addr -- u8 ) | MMIO 16/8-bit |
| `inb` / `outb` | ( port -- byte ) / ( byte port -- ) | Port I/O 8-bit |
| `inw` / `outw` | ( port -- word ) / ( word port -- ) | Port I/O 16-bit |
| `inl` / `outl` | ( port -- dword ) / ( dword port -- ) | Port I/O 32-bit |
| `pci:read-cfg8/16/32` | ( bus dev fn off -- val ) | Lecture config PCI |
| `pci:bar` | ( bus dev fn n -- addr size ) | Lit une BAR |
| `pci:list` / `pci:dev` | ( -- n ) / ( idx -- ... ) | Scan / infos PCI |
| `xhci:init` | ( bar -- ok? ) | Init controleur xHCI |
| `ahci:init` | ( -- ok? ) | Init controleur AHCI |
| `nvme:init` | ( -- ok? ) | Init controleur NVMe |
| `hda:init` | ( bar -- ok? ) | Init audio HDA (stub dans cette branche) |
| `net:e1000:init` | ( bar -- ok? ) | Init reseau Intel |
| `cmos:time` / `cmos:date` | ( -- s m h ) / ( -- d m y ) | Horloge RTC |
| `beep` | ( freq ms -- ) | Bip haut-parleur |
| `ms-delay` / `us-delay` | ( ms -- ) / ( us -- ) | Attente |
| `tsc` / `tsc:freq` | ( -- ticks ) / ( -- khz ) | Compteur TSC |
