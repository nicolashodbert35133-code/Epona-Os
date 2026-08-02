# 🐴 Epona OS — Roadmap 2026-2028

> **Vision** : Créer un OS souverain, éducatif, industriel et agentique, capable de rivaliser avec les OS historiques tout en restant 100% français, open-source et bare-metal.

> **Date** : 2 Août 2026

---

## Table des matières

1. [Phase 1 : Fondations — TERMINÉE ✅](#phase1)
2. [Phase 1.5 : Shell moderne — À FAIRE (Août 2026)](#phase1-5)
3. [Phase 2 : Bureau graphique (Janvier-Mars 2027)](#phase2)
4. [Phase 3 : Réseau complet (Avril-Juin 2027)](#phase3)
5. [Phase 4 : Multimédia (Juillet-Septembre 2027)](#phase4)
6. [Phase 5 : IA locale (Octobre-Décembre 2027)](#phase5)
7. [Phase 6 : Électronique embarquée (Janvier-Mars 2028)](#phase6)
8. [Phase 7 : OS "vrai" (Avril-Décembre 2028)](#phase7)
9. [Primitives — Récapitulatif](#primitives)
10. [Ce qui distingue Epona OS](#distingue)
11. [Guides de développement](#guides)

---

<a id="phase1"></a>
## 1. Phase 1 : Fondations — TERMINÉE ✅

**Toutes les phases du DEV_GUIDE_DRIVER_AGENT.MD sont terminées.** Voir ce guide pour les détails complets.

### Résumé de ce qui a été fait

| Phase | Description | Date | Statut |
|-------|-------------|------|--------|
| **Phase 1** | Corrections bugs bloquants (interrupts.rs, main.rs) | 2026-07-30 | ✅ Fait |
| **Phase 2** | Primitives noyau 720-864 (MMIO, PIO, PCI, IRQ, GOP, wrappers) | 2026-07-31 | ✅ Fait |
| **Phase 3** | Framework driver Rust (drv_api.rs, drivers.rs, auto-chargement) | 2026-08-01 | ✅ Fait |
| **Phase 4** | Bibliothèque standard Forth (drvlib, pci_enum, fmt, strings, tsc) | 2026-08-01 | ✅ Fait |
| **Phase 5** | Drivers communautaires (11 drivers + TEMPLATE.fth) | 2026-08-01 | ✅ Fait |
| **Phase 6** | Fichiers de démarrage (BOOT.FTH, default.fth) | 2026-08-01 | ✅ Fait |
| **Phase 7** | GitHub et documentation (docs/, .github/, README) | 2026-08-02 | ✅ Fait |
| **Phase 8** | CI (test-drivers.yml, validate-drivers.sh) | 2026-08-02 | ✅ Fait |

### Primitives implémentées (720-944)

| Plage | Catégorie | Nombre | Statut |
|-------|-----------|--------|--------|
| 720-727 | MMIO | 8 | ✅ Fait |
| 740-745 | Port I/O | 6 | ✅ Fait |
| 750-758 | PCI | 9 | ✅ Fait |
| 770-775 | Mémoire | 6 | ✅ Fait |
| 790-795 | IRQ | 6 | ✅ Fait |
| 800-805 | Framebuffer GOP | 6 | ✅ Fait |
| 810-826 | Wrappers drivers | 17 | ✅ Fait |
| 840-848 | Utilitaires drivers | 9 | ✅ Fait |
| 850-854 | RTC CMOS | 5 | ✅ Fait |
| 860-864 | Fichiers | 5 | ✅ Fait |
| 900-944 | Flottants IEEE 754 | 45 | ✅ Fait |
| **Total** | | **~122** | |

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
## 2. Phase 1.5 : Shell moderne — À FAIRE (Août 2026)

**Le shell est actuellement basique. Pour qu'Epona OS soit utilisable au quotidien, il faut le moderniser.**

Voir **DEV_GUIDE_SHELL.MD** pour les détails complets.

### 2.1 — Édition de ligne 🔴 P0 (indispensable)

| Amélioration | Description | Priorité |
|--------------|-------------|----------|
| **Curseur dans la ligne** | Champ `cursor_pos`, insertion/suppression à la position | 🔴 |
| **Flèches gauche/droite** | Déplacer le curseur dans l'input | 🔴 |
| **Home/End** | Aller au début/fin de la ligne | 🔴 |
| **Delete** | Supprimer le caractère sous le curseur | 🔴 |
| **Navigation historique** | Flèches haut/bas pour naviguer dans `cmd_history` | 🔴 |
| **Auto-complétion Tab** | Complète commandes + fichiers + mots Forth | 🔴 |

### 2.2 — Commandes de base 🔴 P0

| Commande | Arguments | Description |
|----------|-----------|-------------|
| `echo` | `texte...` | Affiche un texte (essentiel pour scripts) |
| `cp` | `src dst` | Copie un fichier |
| `edit` | `fichier` | Lance l'éditeur plein écran (primitive 146) |
| `pwd` | — | Affiche le chemin courant |
| `set` / `export` | `NOM=VAL` | Définit une variable d'environnement |
| `source` / `.` | `script.sh` | Exécute un script shell |

### 2.3 — Commandes système 🟠 P1

| Commande | Arguments | Description |
|----------|-----------|-------------|
| `date` | `[-s "AAAA-MM-JJ HH:MM"]` | Affiche ou positionne la date |
| `uname` | `[-a]` | Informations noyau (Epona 2.0 x86_64) |
| `uptime` | — | Temps depuis le boot + charge |
| `dmesg` | — | Affiche le journal noyau |
| `history` | `[N]` | Affiche l'historique |
| `grep` | `motif [fichier]` | Recherche de texte |
| `find` | `[dossier] [motif]` | Recherche récursive de fichiers |
| `head` | `-n N fichier` | Affiche les N premières lignes |
| `tail` | `-n N fichier` | Affiche les N dernières lignes |
| `wc` | `fichier` | Compte lignes/mots/caractères |
| `xxd` / `hexdump` | `fichier` | Dump hexadécimal |

### 2.4 — Périphériques & drivers 🟠 P1

| Commande | Arguments | Description |
|----------|-----------|-------------|
| `lspci` | `[-v] [-s b:d.f]` | Liste les périphériques PCI (amélioration) |
| `lsusb` | — | Liste les périphériques USB |
| `lsblk` | — | Liste les périphériques bloc (NVMe/AHCI/MSD) |
| `mount` | `[type périph point]` | Monte un FS |
| `umount` | `point` | Démonte |
| `modinfo` / `driver` | `nom` | Info sur un driver Forth chargé |
| `modload` / `insmod` | `fichier.fth` | Charge un driver |

### 2.5 — Réseau 🟠 P1 (après complétion primitives réseau)

| Commande | Arguments | Description |
|----------|-----------|-------------|
| `ifconfig` / `ip` | `[if addr]` | Affiche/configure les interfaces réseau |
| `ping` | `hôte` | Ping ICMP |
| `wget` / `curl` | `URL` | Télécharge un fichier |
| `nc` / `netcat` | `hôte port` | Connexion TCP brute |
| `dns` | `nom` | Résolution DNS |

### 2.6 — Debug & monitoring 🟠 P1

| Commande | Arguments | Description |
|----------|-----------|-------------|
| `ps` | `[-a]` | Liste des processus Forth + tasks scheduler |
| `kill` | `[-SIG] pid` | Envoie un signal à un processus |
| `top` / `htop` | — | Moniteur processus interactif |
| `irq-stats` | — | Compteurs d'interruptions par IRQ |
| `netstat` | — | Connexions TCP/sockets ouverts |
| `vm-stats` | — | Stats VM (heap, dict, JIT) |

### 2.7 — Fonctionnalités shell modernes

| Fonctionnalité | Description | Priorité |
|----------------|-------------|----------|
| **Redirections** | `cmd > fichier`, `cmd >> fichier`, `cmd < fichier` | 🔴 |
| **Variables** | `echo $PATH`, `$?`, `$$` | 🟠 |
| **Chaînage** | `cmd1 ; cmd2`, `cmd1 && cmd2`, `cmd1 \|\| cmd2` | 🟠 |
| **Pipelines** | `cmd1 \| cmd2 \| cmd3` (avec pipes VFS) | 🟡 |
| **Processus arrière-plan** | `cmd &` | 🟡 |
| **Globbing** | `*.FTH`, `?`, `[a-z]` | 🟡 |
| **Prompt configurable** | `prompt "<format>"` avec `$P`, `$T`, `$G`, `$V` | 🟡 |
| **Alias** | `alias dir=ls`, `alias copy=cp` | 🟡 |

### 2.8 — Variables d'environnement

Stocker dans un `BTreeMap<String, String>` dans `ShellApp` :

- `PATH` → liste de dossiers où chercher les `.FTH` et scripts
- `PROMPT` → format du prompt
- `HOME` → dossier personnel de l'utilisateur
- `SHELL` → chemin vers le shell courant
- `USER` / `LOGNAME` → utilisateur courant
- `PWD` → synchronisé avec `current_path`
- `HISTFILE` → fichier d'historique persistant
- `HISTSIZE` → taille max historique
- `EDITOR` → éditeur par défaut

### 2.9 — Alias par défaut (compatibilité Unix/DOS)

```
alias dir=ls
alias copy=cp
alias del=rm
alias rename=mv
alias md=mkdir
alias cls=clear
alias h=history
alias ?=aide
```

### 2.10 — Refactoring recommandés

| Refactoring | Description |
|-------------|-------------|
| **Séparer les handlers** | Extraire chaque commande dans une méthode dédiée |
| **Table de dispatch** | `const COMMANDS: &[(&str, CmdHandler)]` pour auto-complétion |
| **Gestion d'erreurs uniforme** | Helpers `err()`, `usage()`, `ok()` |
| **Normalisation chemins** | Résoudre `..` et `.` explicitement |
| **Persistance historique** | Sauvegarder `cmd_history` dans `\HISTORY.FTH` |

### 2.11 — Ordre d'implémentation (2 premières semaines août)

1. 🔴 **Curseur dans l'input + flèches/gauche/droite/home/end/delete**
2. 🔴 **Navigation historique avec flèches haut/bas**
3. 🔴 **`echo`** (essentiel pour scripts/test)
4. 🔴 **`cp`** (très utile, présent dans tous les shells depuis les années 70)
5. 🔴 **Édition ligne avec Tab-complete**
6. 🟠 **`pwd`, `uptime`, `date`, `uname`** (commandes d'info rapides)
7. 🟠 **`lspci` / `lsusb` / `lsblk`** (meilleur état matériel)
8. 🟠 **Variables d'environnement + `set`/`export`**
9. 🟠 **`history` avec persistance**
10. 🟠 **`ps`/`kill` améliorés**
11. 🟠 **`wget` simple** (téléchargement HTTP)
12. 🟠 **Redirections `>` et `>>`**

### 2.12 — Checklist avant merge d'une commande shell

- [ ] Aide mise à jour dans le cas `"aide"`
- [ ] Gestion des arguments manquants avec message `Usage:`
- [ ] Gestion de fs absent (`FS non disponible`)
- [ ] Gestion volume non prêt (`Aucun volume USB`)
- [ ] Gestion des erreurs FS (lecture/écriture) avec message `Erreur:`
- [ ] Code de sortie positionné (`last_exit_code = 0` si ok, `1` si erreur)
- [ ] Chemins résolus via `self.resolve_path()`
- [ ] Pas d'unwrap() sur des entrées utilisateur
- [ ] Scrollback : la sortie utilise `self.push_line()`
- [ ] Tests au clavier avec des cas limites

---

<a id="phase2"></a>
## 3. Phase 2 : Bureau graphique complet (Janvier-Mars 2027)

### 3.1 — Window Manager en Forth + primitives natives

```rust
// Primitives fenêtres (500-530)
self.add_primitive("win:create",    500, false); // ( x y w h title_addr title_len flags -- wid )
self.add_primitive("win:destroy",   501, false); // ( wid -- )
self.add_primitive("win:move",      502, false); // ( wid x y -- )
self.add_primitive("win:resize",    503, false); // ( wid w h -- )
self.add_primitive("win:show",      504, false); // ( wid -- )
self.add_primitive("win:hide",      505, false); // ( wid -- )
self.add_primitive("win:focus",     506, false); // ( wid -- )
self.add_primitive("win:title!",    507, false); // ( wid addr len -- )
self.add_primitive("win:fb",        508, false); // ( wid -- addr stride w h )
self.add_primitive("win:flip",      509, false); // ( wid -- )
self.add_primitive("win:event",     510, false); // ( wid -- type x y key )
self.add_primitive("win:list",      511, false); // ( -- n wid1 wid2 ... )
self.add_primitive("win:raise",     512, false); // ( wid -- )
self.add_primitive("win:lower",     513, false); // ( wid -- )
self.add_primitive("win:maximize",  514, false); // ( wid -- )
self.add_primitive("win:minimize",  515, false); // ( wid -- )
self.add_primitive("win:restore",   516, false); // ( wid -- )
self.add_primitive("win:flags",     517, false); // ( wid -- flags )
self.add_primitive("win:flags!",    518, false); // ( wid flags -- )
self.add_primitive("win:drag-start",519, false); // ( wid x y -- )
self.add_primitive("win:drag-end",  520, false); // ( wid -- )

// Primitives dessin avancé (530-560)
self.add_primitive("gfx:circle",    530, false); // ( cx cy r color -- )
self.add_primitive("gfx:fill-circle", 531, false);
self.add_primitive("gfx:ellipse",   532, false); // ( cx cy rx ry color -- )
self.add_primitive("gfx:arc",       533, false); // ( cx cy r start end color -- )
self.add_primitive("gfx:polygon",   534, false); // ( points_addr n color -- )
self.add_primitive("gfx:bezier",    535, false); // ( x1 y1 cx cy x2 y2 color -- )
self.add_primitive("gfx:gradient",  536, false); // ( x y w h c1 c2 direction -- )
self.add_primitive("gfx:alpha-blend", 537, false); // ( x y w h src_addr alpha -- )
self.add_primitive("gfx:clip-set",  538, false); // ( x y w h -- )
self.add_primitive("gfx:clip-clear",539, false); // ( -- )
self.add_primitive("gfx:sprite-load",   540, false); // ( addr w h -- sprite_id )
self.add_primitive("gfx:sprite-draw",   541, false); // ( sprite_id x y -- )
self.add_primitive("gfx:sprite-free",   542, false); // ( sprite_id -- )
self.add_primitive("gfx:font-load",     543, false); // ( addr size -- font_id )
self.add_primitive("gfx:font-text",     544, false); // ( font_id x y text_addr text_len color size -- )
self.add_primitive("gfx:image-decode",  545, false); // ( addr len -- img_id w h )
self.add_primitive("gfx:image-draw",    546, false); // ( img_id x y -- )
self.add_primitive("gfx:image-scale",   547, false); // ( img_id x y w h -- )
self.add_primitive("gfx:image-free",    548, false); // ( img_id -- )
self.add_primitive("gfx:rounded-rect",  549, false); // ( x y w h r color -- )
self.add_primitive("gfx:shadow",        550, false); // ( x y w h blur color -- )
```

### 3.2 — Décodeur d'images (PNG/BMP/JPEG)

```rust
// image.rs — décodeur PNG minimal
pub struct Image {
    pub width: u32,
    pub height: u32,
    pub pixels: Vec<u32>,  // ARGB
}
```

### 3.3 — Bureau graphique complet en Forth

Voir **BUREAU.FTH** — bureau complet avec :
- Fenêtres déplaçables
- Barre des tâches
- Menu démarrer
- Éditeur intégré
- Curseur souris
- Thème sombre

### 3.4 — Éditeur de code Forth

Voir **EDITEUR.FTH** — éditeur complet avec :
- Coloration syntaxique
- Numéros de ligne
- Curseur clignotant
- Sauvegarde/chargement
- Compilation et exécution

---

<a id="phase3"></a>
## 4. Phase 3 : Réseau complet (Avril-Juin 2027)

### 4.1 — Pile TCP/IP complète

```rust
// Primitives réseau avancées (600-650)
self.add_primitive("tcp:listen",    600, false); // ( port -- sock )
self.add_primitive("tcp:accept",    601, false); // ( sock -- client_sock )
self.add_primitive("tcp:read",      602, false); // ( sock buf len -- actual )
self.add_primitive("tcp:write",     603, false); // ( sock buf len -- actual )
self.add_primitive("tcp:close",     604, false); // ( sock -- )
self.add_primitive("tcp:status",    605, false); // ( sock -- state )
self.add_primitive("udp:socket",    610, false); // ( port -- sock )
self.add_primitive("udp:send",      611, false); // ( sock ip port buf len -- ok? )
self.add_primitive("udp:recv",      612, false); // ( sock buf maxlen -- actual ip port )
self.add_primitive("tls:connect",   620, false); // ( sock -- tls_sock )
self.add_primitive("tls:read",      621, false); // ( tls_sock buf len -- actual )
self.add_primitive("tls:write",     622, false); // ( tls_sock buf len -- actual )
self.add_primitive("tls:close",     623, false); // ( tls_sock -- )
self.add_primitive("http:get",      630, false); // ( url_addr url_len -- body_addr body_len status )
self.add_primitive("http:post",     631, false); // ( url body headers -- resp status )
self.add_primitive("http:serve",    632, false); // ( port handler_word -- )
self.add_primitive("ws:connect",    640, false); // ( url_addr url_len -- ws )
self.add_primitive("ws:send",       641, false); // ( ws buf len -- )
self.add_primitive("ws:recv",       642, false); // ( ws buf maxlen -- actual )
self.add_primitive("ws:close",      643, false); // ( ws -- )
```

### 4.2 — Serveur HTTP en Forth

```forth
( HTTP.FTH — serveur web minimal )
: http-handler ( client_sock -- )
  256 balloc { buf }
  client_sock buf 256 tcp:read { nread }
  nread 0 > if
    s" HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"
    client_sock swap tcp:write drop
    s" <h1>Epona OS</h1><p>Serveur Forth bare-metal</p>"
    client_sock swap tcp:write drop
  then
  client_sock tcp:close
;

: serveur ( -- )
  80 tcp:listen { sock }
  begin
    sock tcp:accept { client }
    client 0 >= if
      client http-handler
    then
  again
;
```

---

<a id="phase4"></a>
## 5. Phase 4 : Multimédia (Juillet-Septembre 2027)

### 5.1 — Audio avancé

```rust
// Primitives audio (700-720)
self.add_primitive("audio:init",      700, false); // ( -- ok? )
self.add_primitive("audio:info",      701, false); // ( -- sample_rate channels bits )
self.add_primitive("audio:play-raw",  702, false); // ( addr len rate channels bits -- )
self.add_primitive("audio:play-wav",  703, false); // ( addr len -- )
self.add_primitive("audio:stop",      704, false); // ( -- )
self.add_primitive("audio:volume",    705, false); // ( vol -- ) 0-100
self.add_primitive("audio:mixer",     706, false); // ( channel vol -- )
self.add_primitive("audio:synth",     707, false); // ( freq duration waveform -- )
// waveform: 0=sine, 1=square, 2=triangle, 3=sawtooth
self.add_primitive("audio:sample",    708, false); // ( -- sample ) microphone in
self.add_primitive("audio:midi-note", 709, false); // ( note velocity channel -- )
self.add_primitive("audio:midi-stop", 710, false); // ( note channel -- )
```

### 5.2 — Synthétiseur FM en Forth

```forth
\ Synthétiseur FM en Forth
: beep-sine ( freq ms -- )
  over 2 audio:synth
;

440 500 beep-sine   \ La 440 Hz pendant 500ms
```

---

<a id="phase5"></a>
## 6. Phase 5 : IA locale bare-metal (Octobre-Décembre 2027)

### 6.1 — Moteur de tenseurs

```rust
// tensor.rs — calcul tensoriel bare-metal
pub struct Tensor {
    pub shape: Vec<usize>,    // [batch, seq, hidden]
    pub data: Vec<f32>,       // données
    pub stride: Vec<usize>,   // strides pour indexation
}

// Optimisations x86_64 :
// - AVX2 pour matmul (8 flottants en parallèle)
// - Quantization INT8 pour les poids
// - Tiling pour le cache L1/L2
```

```rust
// Primitives IA (800-830)
self.add_primitive("tensor:create",   800, false); // ( shape_addr ndims -- tid )
self.add_primitive("tensor:free",     801, false); // ( tid -- )
self.add_primitive("tensor:load",     802, false); // ( tid data_addr -- )
self.add_primitive("tensor:matmul",   803, false); // ( tid_a tid_b -- tid_c )
self.add_primitive("tensor:add",      804, false); // ( tid_a tid_b -- tid_c )
self.add_primitive("tensor:softmax",  805, false); // ( tid dim -- )
self.add_primitive("tensor:relu",     806, false); // ( tid -- )
self.add_primitive("tensor:shape",    807, false); // ( tid -- d1 d2 ... ndims )
self.add_primitive("tensor:get",      808, false); // ( tid idx -- f32_as_i64 )
self.add_primitive("tensor:set",      809, false); // ( tid idx f32_as_i64 -- )
self.add_primitive("tensor:print",    810, false); // ( tid -- )

// LLM
self.add_primitive("llm:load",       820, false); // ( path_addr path_len -- model_id )
self.add_primitive("llm:generate",   821, false); // ( model_id prompt_addr prompt_len max_tokens -- out_addr out_len )
self.add_primitive("llm:embed",      822, false); // ( model_id text_addr text_len -- tensor_id )
self.add_primitive("llm:info",       823, false); // ( model_id -- params_M layers heads )
self.add_primitive("llm:free",       824, false); // ( model_id -- )
self.add_primitive("llm:temperature",825, false); // ( model_id temp_x100 -- )
self.add_primitive("llm:top-p",      826, false); // ( model_id p_x100 -- )
```

### 6.2 — Format de modèle GGUF

```rust
// gguf.rs — chargeur de modèles quantizés
pub struct GgufModel {
    pub name: String,
    pub layers: Vec<GgufLayer>,
    pub vocab: Vec<String>,
    pub config: ModelConfig,
}

pub struct ModelConfig {
    pub hidden_size: usize,    // ex: 2048 pour un petit modèle
    pub num_layers: usize,     // ex: 22
    pub num_heads: usize,      // ex: 32
    pub vocab_size: usize,     // ex: 32000
    pub max_seq_len: usize,    // ex: 4096
    pub quant_type: QuantType, // Q4_0, Q4_1, Q8_0, F16, F32
}
```

Usage en Forth :

```forth
( IA.FTH — inference locale )
s" /models/tinyllama-1.1b-q4.gguf" llm:load constant MODEL

: ask ( -- )
  s" Qu'est-ce que Forth ?" MODEL swap 256 llm:generate
  type cr
;

: chat ( -- )
  begin
    ." > "
    256 balloc { buf }
    buf 256 accept { len }
    len 0 > while
    MODEL buf len 512 llm:generate
    type cr
  repeat
;
```

---

<a id="phase6"></a>
## 7. Phase 6 : Électronique embarquée (Janvier-Mars 2028)

### 7.1 — Communication série/SPI/I2C étendue

```rust
// Primitives embarquées (850-880)
self.add_primitive("serial:init",    850, false); // ( port baud -- ok? )
self.add_primitive("serial:read",    851, false); // ( port buf len -- actual )
self.add_primitive("serial:write",   852, false); // ( port buf len -- actual )
self.add_primitive("serial:avail?",  853, false); // ( port -- n )
self.add_primitive("spi:init",      860, false); // ( bus speed mode -- ok? )
self.add_primitive("spi:transfer",  861, false); // ( bus tx_buf rx_buf len -- ok? )
self.add_primitive("spi:cs",        862, false); // ( bus state -- )
self.add_primitive("gpio:mode",     870, false); // ( pin mode -- ) 0=in, 1=out
self.add_primitive("gpio:read",     871, false); // ( pin -- val )
self.add_primitive("gpio:write",    872, false); // ( pin val -- )
self.add_primitive("gpio:irq",      873, false); // ( pin edge handler_word -- )
self.add_primitive("adc:read",      874, false); // ( channel -- value )
self.add_primitive("dac:write",     875, false); // ( channel value -- )
self.add_primitive("pwm:set",       876, false); // ( channel freq duty -- )

// Protocoles
self.add_primitive("modbus:read",   880, false); // ( slave reg count buf -- ok? )
self.add_primitive("modbus:write",  881, false); // ( slave reg count buf -- ok? )
self.add_primitive("canbus:send",   882, false); // ( id buf len -- ok? )
self.add_primitive("canbus:recv",   883, false); // ( buf -- id len )
```

### 7.2 — Bluetooth HCI via xHCI

```rust
// Primitives Bluetooth (950-961)
self.add_primitive("bt:init",       950, false); // ( -- ok? )
self.add_primitive("bt:scan",       951, false); // ( -- ok? )
self.add_primitive("bt:poll",       952, false); // ( -- )
self.add_primitive("bt:devices",    953, false); // ( -- n )
self.add_primitive("bt:device-info",954, false); // ( idx -- addr6 class rssi )
self.add_primitive("bt:device-name",955, false); // ( idx buf -- len )
self.add_primitive("bt:connect",    956, false); // ( idx -- ok? )
self.add_primitive("bt:disconnect", 957, false); // ( idx -- )
self.add_primitive("bt:paired",     958, false); // ( -- n )
self.add_primitive("bt:status",     959, false); // ( -- init? scanning? )
self.add_primitive("bt:addr",       960, false); // ( -- b1 b2 b3 b4 b5 b6 )
self.add_primitive("bt:info",       961, false); // ( -- )
```

---

<a id="phase7"></a>
## 8. Phase 7 : Ce qui fait un OS "vrai" (Avril-Décembre 2028)

### 8.1 — Installation sur disque dur

```forth
( INSTALL.FTH — installeur Epona OS )
: install-to-disk ( -- )
  ." Epona OS Installer" cr
  ." 1. Detecter les disques..." cr
  ahci:init drop
  nvme:init drop
  
  ." 2. Partitionner (GPT)..." cr
  ( ... créer partition EFI + partition Epona ... )
  
  ." 3. Formater en FAT32..." cr
  ( ... formatter la partition EFI ... )
  
  ." 4. Copier les fichiers..." cr
  ( ... copier BOOTX64.EFI, BOOT.FTH, FORTH.TXT ... )
  
  ." 5. Configurer le boot EFI..." cr
  ( ... ajouter une entrée dans le NVRAM EFI ... )
  
  ." Installation terminee !" cr
  ." Retirez la cle USB et redemarrez." cr
;
```

### 8.2 — Package manager

```forth
( PKG.FTH — gestionnaire de paquets )
: pkg-install ( name_addr name_len -- )
  ." Telechargement de " 2dup type ." ..." cr
  ( ... HTTP GET depuis un dépôt ... )
  ( ... vérifier la signature ... )
  ( ... extraire les fichiers ... )
  ( ... compiler les .FTH ... )
  ." Installe !" cr
;

\ Usage :
\ s" editeur" pkg-install
\ s" reseau-tools" pkg-install
\ s" jeux" pkg-install
```

### 8.3 — Format de paquet .EPA (Epona Package Archive)

```rust
// epa.rs — format de paquet
#[repr(C)]
pub struct EpaHeader {
    pub magic: [u8; 4],       // "EPA\0"
    pub version: u16,         // 1
    pub flags: u16,           // 0x01=JIT, 0x02=signed, 0x04=compressed
    pub name: [u8; 32],       // Nom du paquet
    pub author: [u8; 32],     // Auteur
    pub desc: [u8; 128],      // Description
    pub pkg_version: [u8; 16],// Version "1.0.0"
    pub created: u64,         // Timestamp
    pub source_size: u32,     // Taille du source .FTH
    pub jit_size: u32,        // Taille du code JIT compilé
    pub icon_size: u32,       // Taille de l'icône (BMP 32x32)
    pub deps_count: u16,      // Nombre de dépendances
    pub hash: [u8; 32],       // SHA-256 du contenu
    pub signature: [u8; 64],  // Signature ed25519
}
```

```rust
// Primitives Store (970-977)
self.add_primitive("pkg:list",     970, false); // ( -- n )
self.add_primitive("pkg:info",     971, false); // ( idx -- name_addr name_len ver_addr ver_len )
self.add_primitive("pkg:install",  972, false); // ( name_addr name_len -- ok? )
self.add_primitive("pkg:remove",   973, false); // ( name_addr name_len -- ok? )
self.add_primitive("pkg:update",   974, false); // ( name_addr name_len -- ok? )
self.add_primitive("pkg:search",   975, false); // ( query_addr query_len -- n )
self.add_primitive("pkg:pack",     976, false); // ( src_addr src_len name_addr name_len -- ok? )
self.add_primitive("pkg:verify",   977, false); // ( pkg_addr pkg_len -- ok? )
```

---

<a id="primitives"></a>
## 9. Primitives — Récapitulatif

### Déjà implémentées (Phase 1)

| Plage | Catégorie | Nombre | Statut |
|-------|-----------|--------|--------|
| 720-727 | MMIO | 8 | ✅ Fait |
| 740-745 | Port I/O | 6 | ✅ Fait |
| 750-758 | PCI | 9 | ✅ Fait |
| 770-775 | Mémoire | 6 | ✅ Fait |
| 790-795 | IRQ | 6 | ✅ Fait |
| 800-805 | Framebuffer GOP | 6 | ✅ Fait |
| 810-826 | Wrappers drivers | 17 | ✅ Fait |
| 840-848 | Utilitaires drivers | 9 | ✅ Fait |
| 850-854 | RTC CMOS | 5 | ✅ Fait |
| 860-864 | Fichiers | 5 | ✅ Fait |
| 900-944 | Flottants IEEE 754 | 45 | ✅ Fait |
| **Sous-total** | | **~122** | |

### À implémenter (Phases 2-7)

| Plage | Catégorie | Nombre | Phase |
|-------|-----------|--------|-------|
| 410-419 | Processus | 9 | Phase 1 (futur) |
| 500-520 | Fenêtres | 21 | Phase 2 |
| 530-560 | Dessin avancé | 21 | Phase 2 |
| 600-650 | Réseau avancé | 20 | Phase 3 |
| 700-720 | Audio | 11 | Phase 4 |
| 800-830 | IA/Tenseurs | 14 | Phase 5 |
| 850-883 | Embarqué | 17 | Phase 6 |
| 950-961 | Bluetooth | 12 | Phase 6 |
| 970-977 | Store | 8 | Phase 7 |
| **Sous-total** | | **~133** | |

### Total

| | Nombre |
|---|--------|
| **Implémentées** | ~122 |
| **À implémenter** | ~133 |
| **Total** | **~255** |

---

<a id="distingue"></a>
## 10. Ce qui distingue Epona OS de tous les autres OS

1. **Forth bare-metal avec JIT** → unique au monde
2. **Accès matériel direct depuis un langage interactif** → aucun autre OS ne fait ça
3. **USB 3.0, NVMe, GPU, réseau en Forth** → les OS hobby n'ont généralement que le clavier PS/2
4. **UEFI natif** → pas de BIOS legacy
5. **IA locale GGUF intégrée** → premier OS avec inférence locale
6. **Drivers industriels natifs** → CAN, Modbus, UART, SPI, GPIO
7. **Cours x86 interactifs** → plateforme éducative unique
8. **100% français et souverain** → alternative aux OS américains
9. **Architecture agentique** → agents autonomes
10. **Pipeline vectoriel GPU** → graphiques avancés

---

<a id="guides"></a>
## 11. Guides de développement

| Guide | Description | Statut |
|-------|-------------|--------|
| **DEVFORTH.MD** | Manuel 700+ primitives Forth | ✅ Complet |
| **DEVSHELL.MD** | Guide shell améliorations | ✅ Complet |
| **DEVWATCHDOG.MD** | Guide interruptions (15+ bugs) | ✅ Complet |
| **DEVMAIN.MD** | Guide noyau (14 bugs) | ✅ Complet |
| **DEV_GUIDE_DRIVERS.MD** | Guide drivers Forth | ✅ Complet |
| **DEV_GUIDE_DRIVER_AGENT.MD** | Guide agent codeur (8 phases) | ✅ Complet |
| **ROADMAP.MD** | Ce document | ✅ Complet |
| **Wiki GitHub** | Documentation technique | ✅ Complet |

---

## Planning global

```
2026 Août    : Phase 1 ✅ + Shell moderne (Phase 1.5)
2026 Sept    : Tests + démos + communication
2027 Q1      : Bureau graphique complet
2027 Q2      : Réseau TCP/IP + TLS + HTTP
2027 Q3      : Multimédia (audio, images)
2027 Q4      : IA locale (tenseurs, GGUF, LLM)
2028 Q1      : Électronique embarquée
2028 Q2-Q4   : OS "vrai" (installateur, store, sécurité)
```

---

## Conclusion

Epona OS est un projet **EXTRAORDINAIRE** qui combine :
- La simplicité de MS-DOS
- L'élégance de Mac System 7
- Le multitâche d'AmigaOS
- La modernité de BeOS
- La puissance de Linux
- L'IA de demain
- L'industrie d'aujourd'hui

**Aucun autre OS au monde ne combine toutes ces caractéristiques.**

**Phase 1 terminée. Place au shell moderne et au bureau graphique !**

---

*Dernière mise à jour : 2 Août 2026*
*Version : 2.0-beta1*
*Auteur : Nicolas, Architecte WeBOo Concept*
*Licence : MIT (open-source) + Propriétaire (noyau Rust)*