# Epona OS — Contrat d'API v1 (Forth)

Statut : **v1 — GELÉE** (Jour 55, 2026-08-11). Aucune modification sans
incrément de numéro de version (v1.1+). Basée sur la réalité des drivers
existants (`DEV_GUIDE_DRIVER_AGENT.md`, écrits avant l'ISO 2012).

Ce document est le **contrat** entre le noyau Epona et le code Forth
(`.fth`) déposé par des agents/utilisateurs distants. Il sépare
strictement trois espaces de noms :

| Espace | Préfixe | Rôle | Implémenté ? |
|--------|---------|------|--------------|
| ISO Forth 2012 | *(aucun)* | Mots standard du langage | Partiel (voir §3.2) |
| Driver Epona | `drv:*` | Framework driver (PCI/MMIO) | OUI (`forth/std/drvlib.fth`) |
| Application Epona | `epona:*` | OS services pour applications | NON (proposé, réservé) |

Règle d'or : un driver n'utilise que **ISO + `drv:*` + bas niveau** ;
une application n'utilise que **ISO + `epona:*`** (+ lecture `drv:*`
métadonnées si besoin). Un driver ne doit jamais dépendre d'un mot
d'application, et réciproquement.

---

## 1. Espaces de noms — frontières

- **ISO 2012** : `+ - * / mod dup drop swap over rot @ ! c@ c! ...`.
  Source de vérité : `forth/std/CORE_WORDS.md` (signatures) et
  `forth_audit_2012.md` (écarts à corriger).
- **`drv:*`** : mots du framework driver (voir §2). Définis dans
  `forth/std/drvlib.fth`, chargés automatiquement par l'autoloader
  (`drv_ensure_stdlib`, `src/drv_api.rs:517`).
- **`epona:*`** : espace **réservé** aux services OS pour applications.
  Aucun mot `epona:*` n'existe encore dans le dictionnaire : ne les
  utilisez pas avant leur implémentation (Jour 12+).
- **`sys:*` / `disk:*` / `dev:*` / `pci:*`** : mots noyau de bas niveau
  (configuration, fichiers, périphériques). Ce sont des extensions Epona,
  pas de l'ISO.

---

## 2. Driver API v1 — `drv:*`

Un driver Epona est un fichier `.fth` dans `forth/drivers/`, sans aucune
recompilation du noyau.

### 2.1 Cycle de vie (contractuel)

```
chargement  → métadonnées → drv:register → [drv:probe] → [drv:init] → runtime → [drv:fini]
  (compile)   (drv:*!)      (drvlib)      (autoloader) (autoloader)   (mots du driver)
```

L'autoloader (`drv_enumerate_and_load`, `src/drv_api.rs:586`) :
1. charge la stdlib (drvlib, pci_enum, drvmap) ;
2. scanne le PCI ;
3. pour chaque périphérique, `drvmap:find ( vid did -- addr len )` renvoie
   le chemin du driver ;
4. compile le fichier driver (qui appelle `drv:register`) ;
5. appelle `drv:probe ( bar0 bus dev func -- ok? )` puis, si OK,
   `drv:init ( bar0 bus dev func -- ok? )` ;
6. enregistre le résultat (`DriverState::Active` si init OK).

### 2.2 Métadonnées (appelées en top-level du fichier)

| Mot | Signature | Rôle |
|-----|-----------|------|
| `drv:name!` | `( addr len -- )` | Nom (max 127) |
| `drv:version!` | `( maj min patch -- )` | Version numérique |
| `drv:license!` | `( addr len -- )` | Licence (max 63) |
| `drv:desc!` | `( addr len -- )` | Description (max 255) |
| `drv:type!` | `( type -- )` | Type (constantes §2.3) |

Accesseurs (utilisés par l'autoloader Rust, ne pas redéfinir) :

| Mot | Signature |
|-----|-----------|
| `drv:name-string` | `( -- addr len )` |
| `drv:desc-string` | `( -- addr len )` |
| `drv:license-string` | `( -- addr len )` |
| `drv:version` | `( -- maj min patch )` |

### 2.3 Types de drivers (constantes `drvlib.fth`)

| Constante | Valeur | Type |
|-----------|--------|------|
| `Generic` | 0 | Générique |
| `Network` | 1 | Réseau |
| `Audio` | 2 | Audio |
| `Storage` | 3 | Stockage |
| `Input` | 4 | Entrée |
| `Usb` | 5 | USB |
| `Gpu` | 6 | Graphique |

### 2.4 Cycle de vie (mots que le driver DOIT/PEUT définir)

| Mot | Signature | Défaut | Obligatoire ? |
|-----|-----------|--------|---------------|
| `drv:probe` | `( bar bus dev func -- ok? )` | `drop drop drop drop -1` | recommandé |
| `drv:init` | `( bar bus dev func -- ok? )` | idem | recommandé |
| `drv:fini` | `( -- )` | vide | non |
| `drv:register` | `( -- )` | fourni par drvlib | **appelé en fin de fichier** |
| `drv:stop` | `( -- )` | `drv:fini` + flag arrêt | fourni par drvlib |
| `drv:status` | `( -- id type etat )` | — | fourni par drvlib |

`drv:probe`/`drv:init` reçoivent `bar0` = adresse physique de la BAR 0
(0 si absente), puis `bus dev func`.

`drv:stop` appelle `drv:fini` puis marque le driver arrêté (flag
`DRV-REGISTERED` à 0). `drv:status` retourne l'id, le type et l'état
(`0` = non enregistré, `1` = enregistré) du driver courant.

### 2.5 Déclaration du matériel

| Mot | Signature | Rôle |
|-----|-----------|------|
| `pci:add-id` | `( vid did -- )` | Match exact vendor:device |
| `pci:add-class` | `( class sub -- )` | Fallback par classe |
| `pci:entry` | `( vid did addr len -- )` | Table du drvmap (`drvmap.fth`) |
| `drvmap:find` | `( vid did -- addr len )` | Résolution vid:did → chemin |

### 2.6 Bas niveau autorisé dans un driver

Primitives noyau (signatures vérifiées dans `docs/PRIMITIVES_REFERENCE.md`) :

- **MMIO** : `mmio@ ( addr -- val )`, `mmio! ( val addr -- )`,
  `mmio-w@/w! ( 16-bit )`, `mmio-b@/b! ( 8-bit )`.
- **Physique** : `phys@ ( addr -- val64 )`, `phys! ( val64 addr -- )`.
- **Port I/O** : `inb/outb/inw/outw/inl/outl`
  (`inb ( port -- val )`, `outb ( val port -- )`, ...).
- **PCI config** : `pci@ ( addr -- val )`, `pci! ( val addr -- )` (CF8/CFC),
  `pci:list ( -- count )`, `pci:dev ( idx -- bus dev fn vendor device class subclass )`,
  `pci:bar ( bus dev fn n -- addr size )`.
- **Mémoire** : `alloc ( size -- addr )`, `alloc-page ( -- addr )`,
  `alloc-phys ( pages -- addr )`, `mem:alloc-pages ( n -- vaddr )`.
- **Temps** : `ticks ( -- ticks )`, `attendre ( ms -- )`, `us-delay`, `ms-delay`.
- **Logging** : `drv:log ( a l -- )`, `drv:warn`, `drv:err`, `drv:ok`
  (préfixent `[DRV]` / `[DRV!WARN]` / `[DRV!ERR]` / `[DRV+OK]`).
- **État** : `drv:loaded? ( a l -- idx )` (idx ou -1).

⚠️ **Écart doc/code** (`docs/writing-drivers.md` §6 liste des mots qui
**n'existent pas** encore) : `port-io-wr`, `port-io-rd`, `port-io-b-wr`,
`port-io-b-rd`, `boot-alloc`, `mmio-map`, `mmio-unmap`. Utilisez les vrais
noms ci-dessus. (À corriger dans writing-drivers.md.)

⚠️ **`drv:log` existe en double** : primitive noyau (idx 840) ET définition
`drvlib.fth`. La version Forth (la plus récente dans le dictionnaire) est
utilisée : comportement identique (préfixe `[DRV]`).

### 2.7 Contrat & règles du driver

1. `."` fonctionne en top-level comme en compilation (le mode immédiat
   gère `."`, `s"`, `abort"`, `,"` — `src/interpreter.rs:12441/12465/
   12483/12512`). **Seule limite** : la chaîne ne doit pas contenir `(`
   ni `)`, car le stripping des commentaires `( ... )` (Étape 2 du
   tokenizer) s'applique à tous les tokens, même à l'intérieur d'une chaîne.
2. Mémoire : utiliser `create`/`constant`/`value`/`allot` (espace `here`).
   **Ne pas utiliser `variable`** : chevauchement `variables.len()`/`here`
   (voir note `drvlib.fth` ligne 6-9 et `drv_ensure_stdlib` alignement).
3. Équilibre des blocs : `if/then`, `begin/while/repeat/until`,
   `do/?do/loop`, `{ locals }`.
4. Retour `ok?` : **non nul** = succès (l'autoloader teste `!= 0`, donc
   `1` comme `-1` conviennent). C'est un prédicat de statut driver, distinct
   des comparaisons (corrigées en `-1`/`0` au Jour 8).
5. Le fichier se termine par `drv:register` (vérifié par la CI).
6. Ne pas modifier la pile du noyau (restaurer tout effet, sauf résultat).

---

## 3. Application API v1

Une application est un fichier `.fth` lancé par `exec` (shell) ou
`epona:exec` (à venir).

### 3.1 Point d'entrée

- Mot d'entrée : **`principal`** (cherché par `run()`/`run_slice()`,
  `src/interpreter.rs:9662` et `:9690`).
- Le shell `exec` détecte automatiquement le dernier mot appelé en
  top-level (`fth_find_entry`, `src/shell.rs:28`) et :
  - si le fichier définit `: principal` → exécute tel quel ;
  - sinon si entrée `X` trouvée → compile le fichier sans `X`, puis
    `: principal begin X again ;` (boucle jusqu'à Échap) ;
  - sinon → tente `principal`, `bureau`, `main` ; sinon
    « Aucun point d'entrée » (`src/shell.rs:2114`).
- Comportement sans mot d'entrée :
  - `run()` → `Erreur : le mot 'principal' n'est pas défini.` ;
  - `run_slice()` → `RunResult::Error("entry not found")` puis la tâche
    est marquée terminée (`[Programme termine]`, `src/main.rs:1221`).

### 3.2 Sous-ensemble ISO 2012 garanti

- **103 mots Core / 133** présents (S1J2). Les 30 manquants (23 Core +
  37 Core Ext non conformes) sont listés dans `forth_audit_2012.md` §74 et
  `forth/std/CORE_WORDS.md`. **Ne pas dépendre d'un mot manquant.**
- **Vérifié conforme** (Jour 4, `forth/TESTS/core2012.fth` Section A) :
  pile (`dup drop swap over rot nip 2dup 2drop 2swap 2over ?dup pick`),
  arithmétique (`+ - * / mod /mod 1+ 1- 2+ 2- 2* 2/ abs negate min max`),
  logique (`and or xor invert lshift rshift`).
- **Conforme depuis le Jour 8** : comparaisons (`= <> < > <= >= 0= 0<> 0< 0>`
  renvoient `-1`/`0`, interpreter + JIT).
- **Conforme depuis le Jour 9** : `2/` signé (`v >> 1`, arrondi vers moins
  l'infini, interpréteur + JIT) ; `/`, `MOD`, `/MOD` vérifiés conformes
  (division symétrique ANS).
- **Conforme depuis le Jour 10** : `rshift` logique (`((v as u64) >> n)`,
  compte mod 64 aligné SHR x86, interpréteur + JIT).
- **Non conforme (à ne pas utiliser en application) tant que non corrigé** :
  `-rot`, `tuck`,
  `c@/c!` (MMIO au lieu de l'espace Forth — modèle mémoire à unifier).

### 3.3 Mots `epona:*` — proposition v1 (réservée, NON implémentée)

| Mot proposé | Signature | Rôle |
|-------------|-----------|------|
| `epona:version` | `( -- addr len )` | Version OS |
| `epona:screen` | `( -- w h )` | Taille écran |
| `epona:key` | `( -- char \| 0 )` | Clavier non bloquant |
| `epona:mouse` | `( -- x y btn )` | Souris |
| `epona:sleep` | `( ms -- )` | Attente |
| `epona:time` | `( -- s m h )` | Heure CMOS |
| `epona:args` | `( -- addr len )` | Arguments d'appel |
| `epona:exec` | `( addr len -- ok? )` | Lancer une autre app |
| `epona:exit` | `( code -- )` | Terminer l'app |
| `epona:log` | `( addr len -- )` | Log applicatif |

Implémentation prévue en Phase 2 (Jour 12+). D'ici là, les applications
utilisent les primitives existantes (`touche`, `souris`, `attendre`,
`ticks`, `get-time`...).

### 3.4 Contrat & règles de l'application

1. Entrée : définir `: principal` ou laisser le shell trouver l'entrée.
2. `."` autorisé partout ; chaîne sans `(` ni `)` (cf. §2.7).
3. Ne pas dépendre des mots manquants (cf. §3.2).
4. L'application ne doit pas accéder au matériel directement sans
   justification ; elle demande les services via `epona:*` (à venir) ou
   les primitives fournies.
5. Retour : `principal` ne remet rien sur la pile ; un code de sortie est
   un futur `epona:exit`.

---

## 4. Matrice de compatibilité (rappel des conventions Epona)

| Sujet | Convention |
|-------|------------|
| Vrai/Faux | cible `-1`/`0` (aujourd'hui `1`/`0` pour les comparaisons) |
| Test | `\ -1` = OK, `\ 0` = échec ; lancement `exec TESTS/x.fth` |
| Sortie | valeurs via `.`, chaînes via `s"` + `type` |
| Chaînes | `( addr len )`, stockées octet/cellule dans `memory[]` |
| Mémoire persistante | `create`/`constant`/`value` (espace `here`) |
| Variables | éviter (chevauchement variables.len()/here) |

Sources : `forth/std/drvlib.fth`, `forth/std/pci_enum.fth`,
`forth/config/drvmap.fth`, `src/drv_api.rs`, `src/shell.rs`,
`src/interpreter.rs`, `docs/PRIMITIVES_REFERENCE.md`,
`docs/writing-drivers.md`, `forth/std/CORE_WORDS.md`,
`forth_audit_2012.md`.
