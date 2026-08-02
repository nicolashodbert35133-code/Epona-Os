# DEVSHELL.MD — ENCYCLOPÉDIE ET MANUEL DE DÉVELOPPEMENT DÉTAILLÉ DU SHELL EPONA OS

> **Projet :** Epona OS (Release v1.98 — Septembre 2026)  
> **Auteur :** Antigravity AI & Équipe Epona OS  
> **Objet :** Explication approfondie et individuelle de TOUTES les 42 commandes du Terminal Shell  
> **Fichiers Source Noyau :** [shell.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/shell.rs) (114.2 KB) & [DEV_GUIDE_SHELL.md](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/DEV_GUIDE_SHELL.md) (28.3 KB)  
> **Modèle d'Architecture :** Shell Hybride UNIX/DOS Bare-Metal + Console Interactive Forth JIT  

---

## 💡 ARCHITECTURE ET DÉROULEMENT INTERNE DU SHELL

Le **Terminal Shell d'Epona OS** ([shell.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/shell.rs)) est une application centrale compilée en Rust `no_std`. Il ne repose sur aucun kernel POSIX ou sous-système C.

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                             DISPATCHER DU SHELL (shell.rs)                       │
│                   Prompt : ok /usb/config > [Commande | Forth]                   │
├────────────────────────────────────────┬─────────────────────────────────────────┤
│                                        │                                         │
│   ┌──────────────────────────────┐     │     ┌──────────────────────────────┐    │
│   │ COMMANDES NATIVES RUST (42)  │     │     │ FALLBACK EXECUTION FORTH VM  │    │
│   │ (ls, cd, cat, jit, boot-add) │     │     │ (5 10 + ., win:create, JIT) │    │
│   └──────────────┬───────────────┘     │     └──────────────┬───────────────┘    │
│                  │                     │                    │                    │
└──────────────────┴─────────────────────┴────────────────────┴────────────────────┘
```

Chaque commande saisie par l'utilisateur traverse le pipeline suivant dans `shell.rs` :
1. **Normalisation & Tokenisation :** Découpage du buffer `input_buffer` en tokens séparés par des espaces.
2. **Match d'Aiguillage Native Rust :** Analyse du premier token dans `process_command`. Si le token correspond à l'une des **42 commandes natives**, la routine Rust dédiée s'exécute avec accès direct aux sous-systèmes (VFS, PCI, ACPI, USB, GPU).
3. **Fallback Transparent Forth VM :** Si le mot n'est pas reconnu parmi les 42 commandes natives, la ligne complète est transmise à la VM Forth (`forth_vm.compile(cmd)`) qui l'exécute en bytecode ou la compile à la volée en code machine x86-64 avec le JIT ([jit.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/jit.rs)).

---

## 📖 GUIDE INDIVIDUEL EXHAUSTIF DES 42 COMMANDES DU SHELL

---

### 1. COMMANDES SYSTÈME, INFORMATIONS & CONFIGURATION

#### `aide` / `help`
- **Syntaxe :** `aide` ou `help`
- **Explication Technique :** Invoque la fonction interne d'affichage d'aide. Parcourt un tableau statique de chaînes de caractères résumant la totalité des sous-systèmes du Shell (Fichiers, Stockage, Boot Sequence, Hardware, Forth) et pousse chaque ligne dans le buffer de scrollback `self.lines`.
- **Exemple de Session :**
  ```bash
  ok / > aide
  --- COMMANDES SHELL ---
    aide          - Cette aide
    effacer       - Efface l'ecran
    clavier       - Bascule QWERTY/AZERTY
    apropos       - A propos de cet OS
    cd [dossier]  - Change de repertoire
    ls            - Liste fichiers
    cat <f>       - Affiche un fichier USB
    exec <f>      - Execute un fichier Forth (.FTH)
  ```
- **Remarques :** Accessible à tout moment sans réinitialiser l'état du système.

---

#### `effacer` / `clear`
- **Syntaxe :** `effacer` ou `clear`
- **Explication Technique :** Vide intégralement le vecteur de lignes de scrollback `self.lines.clear()` et repositionne le pointeur d'affichage de la console [graphics.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/graphics.rs) à l'origine `(0, 0)` du Framebuffer GOP UEFI.
- **Exemple de Session :**
  ```bash
  ok / > clear
  ```

---

#### `clavier`
- **Syntaxe :** `clavier`
- **Explication Technique :** Interroge la structure `KeyboardManager` dans [keyboard.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/keyboard.rs) et bascule la table de traduction des scancodes (Layout) entre **AZERTY (FR)** et **QWERTY (US)** sans interrompre les processus en cours.
- **Exemple de Session :**
  ```bash
  ok / > clavier
  Disposition configuree sur : AZERTY.
  ok / > clavier
  Disposition configuree sur : QWERTY.
  ```

---

#### `apropos`
- **Syntaxe :** `apropos`
- **Explication Technique :** Affiche la bannière d'information d'Epona OS, rappelant la version du noyau Rust bare-metal, le mode d'exécution UEFI et le statut de la VM Forth.
- **Exemple de Session :**
  ```bash
  ok / > apropos
  Epona OS 2.0 — Systeme d'Exploitation UEFI bare-metal
  Ecrit en Rust. Terminal Forth plein ecran.
  Interprete Forth avec JIT et acces materiel direct.
  ```

---

#### `log`
- **Syntaxe :** `log`
- **Explication Technique :** Lit le journal système circulaire géré par [syslog.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/syslog.rs) en mémoire vive et affiche les 50 dernières entrées horodatées.
- **Exemple de Session :**
  ```bash
  ok / > log
  [0.000] Kernel Epona OS v1.98 Démarré.
  [0.012] GOP Framebuffer Mappé: 1920x1080x32.
  [0.045] Contrôleur XHCI USB 3.0 Initialisé.
  [0.120] Volume USB FAT32 Monté sur /usb/.
  ```

---

#### `secure`
- **Syntaxe :** `secure [on|off]`
- **Explication Technique :** Gère le commutateur du mode de sécurité du noyau Epona OS. En mode sécurisé, les accès directs mémoire MMIO et I/O hors bornes sont filtrés.
- **Exemple de Session :**
  ```bash
  ok / > secure on
  Mode securite: non supporte dans OS 2.0 (Ring 0 global)
  ```

---

#### `reboot`
- **Syntaxe :** `reboot`
- **Explication Technique :** Fait appel à la fonction `reset_system(false)` du noyau Rust pour ordonner au contrôleur de réinitialisation UEFI/ACPI de redémarrer à chaud la machine.
- **Exemple de Session :**
  ```bash
  ok / > reboot
  Redemarrage...
  ```

---

#### `poweroff`
- **Syntaxe :** `poweroff`
- **Explication Technique :** Appelle `reset_system(true)` qui transmet l'ordre d'extinction ACPI S5 au PM1a/PM1b Control Register pour couper l'alimentation électrique du PC.
- **Exemple de Session :**
  ```bash
  ok / > poweroff
  Arret...
  ```

---

### 2. GESTION DES FICHIERS & NAVIGATION VFS / USB

#### `ls` / `dir`
- **Syntaxe :** `ls [chemin]` ou `dir [chemin]`
- **Explication Technique :** Fait appel au VFS v2 ([vfs_v2.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/vfs_v2.rs)) et au pilote FAT32 ([fat32.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/fat32.rs)). Si `current_path` est vide, interroge la racine du volume sélectionné. Affiche les préfixes `[F]` (Fichier standard) et `[J]` (Fichier compilé JIT).
- **Exemple de Session :**
  ```bash
  ok / > ls /usb/
  5 fichiers:
  [DIR] config
  [DIR] drivers
  [F]   BOOT.FTH
  [J]   bureau.JIT
  [F]   BUREAU_NG.FTH
  ```

---

#### `cd`
- **Syntaxe :** `cd <dossier>`
- **Explication Technique :** Modifie la chaîne `self.current_path` dans `ShellApp` et synchronise le dossier courant de la VM Forth (`forth_vm.current_path`). Gère le retour au dossier parent `..` et le retour à la racine `/`.
- **Exemple de Session :**
  ```bash
  ok / > cd /usb/config
  \usb\config\
  ok \usb\config\ > cd ..
  \usb\
  ```

---

#### `cat`
- **Syntaxe :** `cat <fichier>`
- **Explication Technique :** Résout le chemin du fichier via `resolve_path`, ouvre le descripteur VFS via `fs.read_file(selected_vol, uefi_name)`, lit le texte ASCII et pousse les 100 premières lignes dans le buffer écran. Tronque poliment si le fichier dépasse 100 lignes.
- **Exemple de Session :**
  ```bash
  ok /usb/ > cat BOOT.FTH
  \ Script d'amorce Epona OS
  s" /forth/drivers/keyboard.fth" load-driver
  s" /forth/bureau/BUREAU_NG.FTH" load-app
  ```

---

#### `mkdir`
- **Syntaxe :** `mkdir <dossier>`
- **Explication Technique :** Invoque `fs.create_dir(selected_vol, uefi_name)`. Le pilote FAT32 alloue une nouvelle entrée de répertoire et un cluster racine sur la clé USB Live.
- **Exemple de Session :**
  ```bash
  ok /usb/ > mkdir /usb/projets
  Dossier /usb/projets cree.
  ```

---

#### `touch`
- **Syntaxe :** `touch <fichier>`
- **Explication Technique :** Crée un fichier de 0 octet sur la clé USB FAT32 via `fs.write_file(selected_vol, uefi_name, "")`.
- **Exemple de Session :**
  ```bash
  ok /usb/ > touch /usb/notes.txt
  Fichier /usb/notes.txt cree.
  ```

---

#### `rm`
- **Syntaxe :** `rm <fichier>`
- **Explication Technique :** Fait appel à `fs.delete_file(selected_vol, uefi_name)`. Marque la ligne d'entrée de répertoire FAT32 comme effacée (`0xE5`) et libère la chaîne de clusters.
- **Exemple de Session :**
  ```bash
  ok /usb/ > rm /usb/tmp.txt
  Fichier /usb/tmp.txt supprime.
  ```

---

#### `mv`
- **Syntaxe :** `mv <ancien> <nouveau>`
- **Explication Technique :** Extrait les 2 arguments, résout les deux chemins et appelle `fs.rename_file(selected_vol, old, new)`.
- **Exemple de Session :**
  ```bash
  ok /usb/ > mv test.fth demo.fth
  test.fth -> demo.fth
  ```

---

#### `vol`
- **Syntaxe :** `vol [numero]`
- **Explication Technique :** Sans argument, affiche la liste des volumes VFS actifs (`/`, `/usb/`, `/dev/`, `/proc/`, `/tmp/`). Avec un paramètre numérique `n`, bascule l'index `selected_vol` vers le volume `n`.
- **Exemple de Session :**
  ```bash
  ok / > vol
  Volume 0 : NVMe SSD (FAT32/EponaFS)
  Volume 1 : Clé USB Live (FAT32) [Sélectionné]
  ok / > vol 0
  Volume 0 sélectionné.
  ```

---

#### `fs-reset`
- **Syntaxe :** `fs-reset`
- **Explication Technique :** Déclenche un nouveau balayage matériel du contrôleur AHCI et NVMe pour ré-énumérer et remonter à chaud les partitions de disques dures physiques.
- **Exemple de Session :**
  ```bash
  ok / > fs-reset
  Re-scan des volumes accompli. 2 volumes actifs.
  ```

---

### 3. EXÉCUTION FORTH & COMPILATEUR JIT

#### `exec`
- **Syntaxe :** `exec <fichier.fth>`
- **Explication Technique :** Ouvre et lit le fichier `.fth`. Détecte si le mode Debug UEFI est actif (exécution synchrone directe) ou si le noyau tourne en mode runtime natif (exécution asynchrone par tranche de temps via le Scheduler). Si le fichier se termine par `.JIT`, il vérifie la signature binaire JIT et charge le code natif x86-64.
- **Exemple de Session :**
  ```bash
  ok / > exec /forth/demos/snake.fth
  Exec /forth/demos/snake.fth (1420 octets)...
  [DEBUG-EXEC] Exécution directe UEFI...
  ```

---

#### `jit`
- **Syntaxe :** `jit <fichier.fth>`
- **Explication Technique :** Lit le script Forth, transmet ses définitions au compilateur JIT ([jit.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/jit.rs)) qui génère du code machine x86-64 directement dans la mémoire exécutive allouée (`alloc_exec_mem`), puis exécute le point d'entrée.
- **Exemple de Session :**
  ```bash
  ok / > jit /forth/demos/raycaster.fth
  Compilation JIT de raycaster.fth... 45 mots compilés en x86-64.
  ```

---

#### `jit compil`
- **Syntaxe :** `jit compil <fichier.fth>`
- **Explication Technique :** Traduit le script `.fth` en code machine natif x86-64 et sérialise la mémoire binaire exécutable sous la forme d'un fichier `.JIT` écrit sur la clé USB FAT32.
- **Exemple de Session :**
  ```bash
  ok / > jit compil BUREAU_NG.FTH
  Compilation JIT -> BUREAU_NG.JIT sauvegardé sur USB (2159 KB).
  ```

---

#### `jit info`
- **Syntaxe :** `jit info`
- **Explication Technique :** Interroge l'état interne de la structure `JitEngine`. Affiche la quantité de mémoire exécutive allouée, le nombre de mots compilés et l'état du cache de traduction.
- **Exemple de Session :**
  ```bash
  ok / > jit info
  === STATUT JIT ENGINE ===
  Mots Compilés : 128
  Mémoire Exec  : 512 KB / 2048 KB
  Statut        : Actif (x86-64 Native Direct Call)
  ```

---

#### `jit clear`
- **Syntaxe :** `jit clear`
- **Explication Technique :** Re-initialise le cache du compilateur JIT et libère les pages de mémoire exécutive x86-64.
- **Exemple de Session :**
  ```bash
  ok / > jit clear
  Cache JIT réinitialisé.
  ```

---

#### `forth` / `tutor`
- **Syntaxe :** `forth` ou `tutor`
- **Explication Technique :** Imprime l'aide-mémoire complète de la syntaxe Forth par catégories (Pile, Math, Comparaisons, Bits, Mémoire, MMIO, Ports I/O, PCI, Console, Contrôle if/then/loop, Framebuffer, Temps rdtsc).
- **Exemple de Session :**
  ```bash
  ok / > tutor
  --- Aide Forth complete ---
  PILE: dup drop swap over rot -rot nip tuck
  MATH: + - * / mod /mod 1+ 1- 2+ 2- min max abs negate
  COMP: = <> < > <= >= 0= 0<
  MEM:  @ ! +! c@ c! MMIO: mmio@ mmio! PORT: inb outb
  ```

---

#### `words`
- **Syntaxe :** `words`
- **Explication Technique :** Interroge le dictionnaire complet de la Machine Virtuelle Forth ([interpreter.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/interpreter.rs)) et affiche la liste des **290+ primitives natives et mots utilisateurs** enregistrés.
- **Exemple de Session :**
  ```bash
  ok / > words
  dup drop swap rot + - * / @ ! c@ c! emit key page inb outb pci-scan win:create win:flip gfx:circle f+ f- f* f/ fsin fcos ...
  ```

---

#### `drivers`
- **Syntaxe :** `drivers`
- **Explication Technique :** Affiche la liste des pilotes matériels enregistrés dans le registre `driver_mgr` et dans la structure `sys_kernel` du noyau Rust.
- **Exemple de Session :**
  ```bash
  ok / > drivers
  -- driver_mgr --
    Driver USB XHCI (v1.0)
    Driver SATA AHCI (v1.0)
    Driver NVMe PCIe (v1.2)
  -- sys_kernel --
    Intel E1000 Gigabit Ethernet
  ```

---

### 4. SÉQUENCE DE DÉMARRAGE (GESTION DE `BOOT.FTH`)

#### `boot-show`
- **Syntaxe :** `boot-show`
- **Explication Technique :** Affiche le contenu actuel du tampon mémoire de configuration d'amorce `hw_boot_buffer` destiné à constituer le fichier `BOOT.FTH`.
- **Exemple de Session :**
  ```bash
  ok / > boot-show
  --- CONTENU DU TAMPON BOOT.FTH ---
  s" /forth/drivers/gpu_intel.fth" load-driver
  s" /forth/bureau/BUREAU_NG.FTH" load-app
  ```

---

#### `boot-add`
- **Syntaxe :** `boot-add <driver.fth>`
- **Explication Technique :** Pousse un nouveau driver ou script dans la liste `hw_boot_buffer` pour inclusion automatique lors du prochain démarrage USB.
- **Exemple de Session :**
  ```bash
  ok / > boot-add /forth/drivers/sound_hda.fth
  Driver /forth/drivers/sound_hda.fth ajoute au tampon boot.
  ```

---

#### `boot-exit`
- **Syntaxe :** `boot-exit`
- **Explication Technique :** Ajoute l'instruction de bascule hors-UEFI `exit-uefi` dans la séquence d'amorce `BOOT.FTH`.
- **Exemple de Session :**
  ```bash
  ok / > boot-exit
  Instruction exit-uefi ajoutée au tampon boot.
  ```

---

#### `boot-write`
- **Syntaxe :** `boot-write`
- **Explication Technique :** Génère la chaîne de texte complète depuis `hw_boot_buffer` et écrit physiquement le fichier `BOOT.FTH` à la racine de la clé USB FAT32 via `fs.write_file`.
- **Exemple de Session :**
  ```bash
  ok / > boot-write
  BOOT.FTH écrit avec succès sur le volume USB !
  ```

---

#### `boot-clear`
- **Syntaxe :** `boot-clear`
- **Explication Technique :** Vide la liste `hw_boot_buffer` du tampon d'amorce.
- **Exemple de Session :**
  ```bash
  ok / > boot-clear
  Tampon BOOT.FTH effacé.
  ```

---

### 5. DIAGNOSTIC HARDWARE, PCI, ACPI, MMIO & I2C

#### `hw-check`
- **Syntaxe :** `hw-check`
- **Explication Technique :** Parcourt les périphériques détectés sur le bus PCI et vérifie la présence du fichier de pilote Forth correspondant dans `/forth/drivers/`.
- **Exemple de Session :**
  ```bash
  ok / > hw-check
  Périphérique PCI 8086:1539 (Intel E1000) -> Driver FTH Trouvé !
  Périphérique PCI 1022:1632 (AMD Host Bridge) -> Driver Interne.
  ```

---

#### `hw-setup`
- **Syntaxe :** `hw-setup`
- **Explication Technique :** Déclenche l'assistant pas à pas d'auto-configuration matérielle : teste chaque composant non configuré et propose l'ajout dans `BOOT.FTH`.
- **Exemple de Session :**
  ```bash
  ok / > hw-setup
  [HW-SETUP 1/3] Contrôleur GPU Intel HD Graphics (8086:9B41)
  Ajouter le pilote /forth/drivers/gpu_intel.fth au démarrage ? (Tapez boot-add)
  ```

---

#### `hw-reset`
- **Syntaxe :** `hw-reset`
- **Explication Technique :** Réinitialise l'indice `hw_setup_index` à 0 pour reprendre l'assistant d'auto-setup depuis le début.
- **Exemple de Session :**
  ```bash
  ok / > hw-reset
  Queue d'auto-setup réinitialisée.
  ```

---

#### `pci` / `pci save`
- **Syntaxe :** `pci` ou `pci save`
- **Explication Technique :** Exécute `scan_pci()` dans [pci.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/pci.rs). Interroge les ports I/O `0xCF8`/`0xCFC` pour dresser l'inventaire des 256 bus PCI. L'option `save` écrit l'inventaire complet dans le fichier `/usb/PCI.TXT`.
- **Exemple de Session :**
  ```bash
  ok / > pci save
  00:00.0 [0600] Vendor: 1022 Device: 1632 - Pont de Bus Host/PCI
  00:02.0 [0300] Vendor: 8086 Device: 9B41 - Contrôleur Graphique Intel
  00:1D.0 [0C03] Vendor: 8086 Device: A36D - Contrôleur USB 3.0 XHCI
  PCI.TXT sauvegarde sur USB !
  ```

---

#### `acpi` / `acpi save`
- **Syntaxe :** `acpi` ou `acpi save`
- **Explication Technique :** Fait appel à `acpi::dump_info()` dans [acpi.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/acpi.rs). Décode la table RSDP, XSDT, FADT et MADT (énumération des cœurs processeur APIC). L'option `save` écrit `/usb/ACPI.TXT`.
- **Exemple de Session :**
  ```bash
  ok / > acpi save
  --- TABLES ACPI DUMP ---
  RSDP Trouvé à 0x000F0450 (OEM: BOCHS )
  MADT: 4 Cœurs CPU Découverts (APIC IDs: 0, 1, 2, 3)
  FADT: PM1a Control Block à 0x0604
  ACPI.TXT sauvegarde sur USB !
  ```

---

#### `devices` / `devices save`
- **Syntaxe :** `devices` ou `devices save`
- **Explication Technique :** Synthétise les adresses mémoire MMIO, les adresses de registres BAR PCI et les canaux d'interruptions d'ensemble des périphériques. L'option `save` écrit `/usb/DEVICES.TXT`.
- **Exemple de Session :**
  ```bash
  ok / > devices save
  DEVICES.TXT sauvegarde sur USB !
  ```

---

#### `mmio`
- **Syntaxe :** `mmio <adresse_hex> [valeur_hex]`
- **Explication Technique :** Sans deuxième argument, lit 32 bits à l'adresse MMIO via `mmio_read32`. Avec une deuxième valeur hexadécimale, écrit 32 bits via `mmio_write32`.
- **Exemple de Session :**
  ```bash
  ok / > mmio 0xFE000000
  MMIO [0xFE000000] = 0x00001042
  ok / > mmio 0xFE000000 0x00001043
  MMIO [0xFE000000] <- 0x00001043
  ```

---

#### `i2c probe`
- **Syntaxe :** `i2c probe <bus>`
- **Explication Technique :** Balaye les adresses I2C (0x08 à 0x77) sur le bus sélectionné via [i2c_hid.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/i2c_hid.rs) à la recherche de composants tactiles ou de capteurs.
- **Exemple de Session :**
  ```bash
  ok / > i2c probe 0
  I2C Bus 0 Scan:
  Périphérique trouvé à l'adresse 0x2C (Touchpad I2C HID)
  ```

---

#### `i2c read`
- **Syntaxe :** `i2c read <bus> <device> <registre> [len]`
- **Explication Technique :** Transmet une trame de lecture I2C vers le composant `device` sur le registre demandé.
- **Exemple de Session :**
  ```bash
  ok / > i2c read 0 0x2C 0x01
  I2C [Bus 0 Dev 0x2C Reg 0x01] = 0x0020
  ```

---

### 6. PROCESSUS, ORDONNANCEMENT & MONITORING

#### `ps`
- **Syntaxe :** `ps`
- **Explication Technique :** Parcourt la table des processus du noyau ([scheduler_v2.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/scheduler_v2.rs)). Affiche pour chaque tâche son PID, son Nom, son État (`Running`, `Ready`, `Sleeping`), sa Priorité et son temps CPU restant.
- **Exemple de Session :**
  ```bash
  ok / > ps
  PID   NOM                 ETAT       PRIO   QUANTUM
  1     Kernel_Init         Running    0      10 ms
  2     Window_Manager      Ready      1      20 ms
  3     Forth_Terminal      Running    2      50 ms
  ```

---

#### `kill`
- **Syntaxe :** `kill <PID>`
- **Explication Technique :** Parse l'argument PID, transmet l'ordre `scheduler.kill_task(pid)` qui fait passer le processus dans l'état `Zombie` et libère son contexte CPU.
- **Exemple de Session :**
  ```bash
  ok / > kill 3
  Processus PID 3 arrêté.
  ```

---

#### `scheduler`
- **Syntaxe :** `scheduler`
- **Explication Technique :** Affiche le diagnostic détaillé de l'ordonnateur préemptif : nombre de tâches système totales, nombre de coroutines Forth actives et statut du multithreading.
- **Exemple de Session :**
  ```bash
  ok / > scheduler
  Taches: 4 total
    Kernel_Init [prio=0] RUN
    Window_Manager [prio=1] RDY
    Forth_Terminal [prio=2] RUN
  Forth tasks: 2
  Forth running: true
  ```

---

#### `sysmon`
- **Syntaxe :** `sysmon`
- **Explication Technique :** Déclenche l'ouverture du moniteur système temps réel sur le Framebuffer, rafraîchissant les courbes de charge CPU, l'occupation mémoire RAM et le statut USB XHCI.
- **Exemple de Session :**
  ```bash
  ok / > sysmon
  =================== EPONA OS SYSTEM MONITOR ===================
  CPU : Intel(R) Core(TM) i7 | Charge : 2.1% | Cœurs : 4 APIC
  RAM : 8192 MB Détectés    | Utilisée : 142 MB
  USB : Contrôleur XHCI OK  | Clé USB Live FAT32 Montée
  ===============================================================
  ```

---

### 7. ASSISTANT D'INSTALLATION SUR SSD

#### `install-to-disk`
- **Syntaxe :** `install-to-disk`
- **Explication Technique :** Déclenche l'assistant interactif de copie système. Détecte les SSD NVMe ([nvme.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/nvme.rs)) ou SATA AHCI ([ahci.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/ahci.rs)), écrit une table de partitions GPT ([partition.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/partition.rs)) et copie le binaire `BOOTX64.EFI` et l'arborescence Forth depuis la clé USB vers le SSD interne.
- **Exemple de Session :**
  ```bash
  ok / > install-to-disk
  === ASSISTANT D'INSTALLATION EPONA OS ===
  Disque Cible Détecté : [NVMe] Western Digital SN770 (500 GB)
  Création de la partition ESP FAT32... OK.
  Copie de EFI/BOOT/BOOTX64.EFI... OK.
  Copie de l'arborescence forth/... OK.
  [SUCCÈS] Epona OS est installé sur le SSD interne ! Vous pouvez retirer la clé USB.
  ```

---

## 🔀 PIPELINES, REDIRECTIONS ET CODE FORTH EN DIRECT

### 1. Pipelines (`|`)
```bash
ok /usb/ > ls /usb/ | grep .FTH
```

### 2. Redirections de Sortie (`>` et `>>`)
```bash
ok / > ps > /usb/process_list.txt
ok / > acpi save >> /usb/system.log
```

### 3. Exécution Forth Directe sans Changement de Mode
```bash
# Calcul arithmétique instantané
ok / > 100 200 + .
300

# Création d'une fenêtre GUI en une ligne
ok / > 100 100 400 300 s" Ma Fenetre" 0 win:create drop
```

---

*Document officiel de référence du Shell Epona OS basé sur [shell.rs](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/src/shell.rs) (114 KB) et [DEV_GUIDE_SHELL.md](file:///c:/Users/m40di/Desktop/Epona%20Os%201.98/DEV_GUIDE_SHELL.md) (Version 2.0 / Release v1.98 — Septembre 2026).*
