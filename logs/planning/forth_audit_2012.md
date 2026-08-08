# Audit de conformité — interpréteur Forth

Référence retenue : **Forth 2012**, jeu *Core* puis *Core Extensions*.  
État : audit de `interpreter.rs` terminé ; il reste possible que des définitions Forth chargées par `BOOT.FTH` complètent certains mots.

## Inventaire confirmé dans les extraits

- Noyau pile/arithmétique : `+ - * / MOD DUP DROP SWAP OVER ROT -ROT NIP TUCK 2DUP 2DROP 2SWAP 2OVER ?DUP PICK 1+ 1- 2+ 2- 2* 2/ ABS NEGATE MIN MAX /MOD`.
- Comparaisons/logique : `= <> < > <= >= 0= 0<> 0< 0> AND OR XOR INVERT LSHIFT RSHIFT`.
- Mémoire/chaînes déclarées : `@ ! C@ C! W@ W! L@ L! FILL CMOVE MOVE ERASE COUNT COMPARE SEARCH TYPE`.
- Compilation/dictionnaire déclarés : `STATE ] EXECUTE FIND LITERAL`, plus des mécanismes à vérifier dans les extraits ultérieurs (`HERE`, `ALLOT`, `,`, `CREATE`, `CONSTANT`, `DOES>`, contrôle de flux, etc.).
- Retour/boucles : `>R R> R@ I J` ; `2>R 2R> UNLOOP` enregistrés mais implémentations encore à recevoir.
- Extensions matérielles, OS, réseau, graphique, stockage : nombreuses ; elles sont hors norme Forth et seront séparées du bilan de conformité.

## Écarts ou risques déjà visibles (à confirmer dans le bilan final)

| Mot / aspect | Constat dans l'extrait | Référence Forth 2012 | Impact |
|---|---|---|---|
| Flags booléens | ~~La plupart des comparaisons et prédicats renvoient `1` pour vrai.~~ **✅ Corrigé Jour 8 (S2)** : les 10 comparaisons entières (`= <> < > <= >= 0= 0<> 0< 0>`) renvoient `-1`/`0` (interpreter.rs + jit.rs). Hors périmètre : les prédicats de statut (`touche?`, `souris?`, probes, `drv:probe`) renvoient toujours `1`. | Un *true flag* standard est tous les bits à 1 (`-1` sur cellule signée), faux = `0`. | Résolu pour les comparaisons. |
| `RSHIFT` | ~~`i64::wrapping_shr`, donc décalage arithmétique sur valeur négative.~~ | `RSHIFT` doit être un décalage logique à droite. | **✅ Corrigé Jour 10** : `((v as u64) >> n)` interpréteur, JIT déjà conforme (SHR). Compte mod 64 aligné hardware. |
| `2/` | ~~Rust `/ 2`, qui tronque vers zéro.~~ | `2/` doit fournir le quotient arrondi vers moins l'infini. | **✅ Corrigé Jour 9** : `v >> 1` (shift arithmétique) interpréteur, JIT déjà conforme (SAR). `-5 2/` donne `-3`. |
| `C@ C! W@ W! L@ L! FILL CMOVE` | Implémentés ici comme accès MMIO bruts, non comme accès au même espace mémoire Forth que `@ !`. | `C@` / `C!` et `FILL` sont des mots Core à mémoire adressable par caractères ; les adresses doivent être cohérentes avec le reste du système Forth. | Écart majeur et accès dangereux ; cassera les programmes standard manipulant des buffers Forth. |
| `MOVE` / `ERASE` | Opèrent sur pointeurs natifs bruts. | Mots Core Extension, attendus sur l'espace d'adresses Forth. | Incohérence avec `memory: Vec<i64>` et risque de sécurité. |
| Modèle d'adresses | `@` et `!` indexent `memory[a]`, alors que `CELL+` ajoute 8 et `CELLS` multiplie par 8. Les textes utilisent aussi les indices de `memory` comme octets. | Les unités d'adresse doivent rester cohérentes. | À vérifier avec `VARIABLE`, `HERE`, `ALLOT` et `,`, mais incohérence probable. |
| `STATE` | ~~Renvoie directement `state` au lieu d'une adresse.~~ | `STATE ( -- a-addr )` doit renvoyer l'adresse d'une cellule modifiable. | **✅ Corrigé Jour 16** : cellule réservée `MAX_MEM-2` (`state_addr`), source de vérité du tokenizer — `@` lit l'état réel, `!` change réellement le mode de compilation, `]`/`[`/`:`/`;` écrivent la cellule. `self.state` (champ Rust) supprimé. |
| `FIND` | `(addr len -- dict-index|-1)`. | `FIND ( c-addr -- c-addr 0 | xt 1 | xt -1 )`, sur chaîne comptée. | Non conforme ; ce n'est pas l'API standard. |
| `SEARCH` | ~~Renvoie `-1` quand trouvé (bon flag), mais ne considère pas une sous-chaîne vide comme trouvée.~~ | Le cas `u2 = 0` doit réussir. | **✅ Corrigé Jour 11** : `len2 == 0` → toujours trouvée (flag `-1`, `addr3 = addr1`, `len3 = len1`). |
| Affichage numérique | `.`/`U.` ajoutent `0x` en hexadécimal. | Le format normalisé est fondé sur `BASE`; le préfixe n'est pas la sortie ANS habituelle. | Écart mineur de portabilité. |
| `BASE` | Champ Rust présent, `HEX`/`DECIMAL` présents, mais aucun mot standard `BASE` visible à ce stade. | `BASE ( -- a-addr )` est un mot Core. | À confirmer avec les définitions ultérieures. |

## Écarts ajoutés — extrait `300..554`

| Mot / aspect | Constat dans l'extrait | Référence Forth 2012 | Impact |
|---|---|---|---|
| `,` et `C,` | Les deux stockent une valeur dans `memory[here]` puis font `HERE += 1`. | `C,` alloue un caractère ; `,` alloue une cellule. Sur une machine où `CELL` vaut 8 caractères, ils ne peuvent pas avoir le même incrément. | Confirme l'incohérence d'unités d'adresse/d'espace de données. |
| `*/` | Calcule `(n1 * n2) / n3` dans une cellule `i64`. | Le produit intermédiaire doit être traité en double précision ; l'arrondi suit les règles de division du mot standard. | Débordement pour beaucoup d'entrées valides. |
| `FM/MOD`, `SM/REM`, `UM*`, `UM/MOD` | Les doubles sont composés de deux moitiés de 32 bits, malgré `CELL = 8` et une pile `i64`; `UM*` force en pratique la moitié haute à zéro. | Avec des cellules 64 bits, les doubles demandent une arithmétique 128 bits (`i128`/`u128`). | Non conforme pour les valeurs générales ; probablement seulement partiellement utilisable comme Forth 32 bits. |
| `SOURCE` | ~~Copie la source dans `memory[HERE..]` et avance `HERE` à chaque appel.~~ | `SOURCE` retourne le buffer source courant ; il ne doit pas consommer/altérer le dictionnaire ou l'espace de données. | **✅ Corrigé Jour 13** : `(source_addr, len)` stable, copie unique par ligne via `set_source`, `HERE` inchangé. |
| `PARSE-NAME` | ~~Copie vers `HERE`; considère aussi `(` et `)` comme délimiteurs.~~ | Les délimiteurs du nom sont les espaces selon la sémantique standard. | **✅ Corrigé Jour 19** : délimiteurs = espaces uniquement ; c-addr pointe le nom dans la source (`source_addr`), `HERE` inchangé ; `>IN` avancé après le nom. |
| `PARSE` | ~~Ignore tous les délimiteurs initiaux ; copie vers `HERE` ; avance `>IN`.~~ | Si le caractère suivant est le délimiteur, `PARSE` doit retourner une chaîne vide correspondante (u=0), pas sauter les délimiteurs ; `c-addr` pointe dans la source ; `PARSE` ne modifie pas `>IN`. | **✅ Corrigé Jour 20** : délimiteur en premier caractère → champ vide (u=0) ; délimiteurs consécutifs → champs vides ; `c-addr = source_addr + >IN` ; `HERE` et `>IN` inchangés. |
| `REFILL` | ~~Une ligne vide retourne `0` (EOF/échec).~~ | Une ligne vide obtenue avec succès doit produire le flag vrai ; faux signifie qu'aucune nouvelle ligne n'est disponible. | **✅ Corrigé Jour 12** : Entrée sur ligne vide → `-1` ; Escape → `0` ; préemption/break → `0`. |
| `>IN` | Renvoie bien une adresse modifiable dans `memory`. | Conforme dans son principe, sous réserve de cohérence de la source et du modèle mémoire. | **✅ Vérifié Jour 13** : modifiable (`>in 5 ! >in @` = 5) ; cohérent avec `SOURCE`/`EVALUATE`. |

## Revue Semaine 2 (Jour 14, 2026-08-06)

Relecture statique complète des corrections S2 (J8→J13), en l'absence d'exécution matérielle :

- **`core2012.fth`** relu section par section (B0/B1/B2/B2b/B2b2/B3/B4) : toutes les valeurs attendues recalculées à la main sont cohérentes avec le code, à **une exception corrigée ici** : `1 65 rshift` attendait `1` mais `wrapping_shr` masque le compte mod 64 → `1 >> 1 = 0` (attente corrigée en `\ 0`). Le cas `-1 64 rshift = -1` (mod 64 = 0) était correct.
- **`BOOT.FTH`** (boot) relu : aucun usage des mots corrigés (comparaisons, `2/`, `rshift`, `search`, `source`, `>in`, `refill`) ; `AUTO-EXIT-UEFI if` teste le non-nul et n'est pas affecté par les flags `-1`/`0`. Non impacté par S2.
- **Drivers/scripts** : `audio.fth`, `AMD-Ryzen5-5500U.FTH`, `fmt.fth` utilisent `rshift` uniquement sur valeurs positives (revu J10) ; aucun usage de `source`/`evaluate`/`>in`/`refill` hors `TESTS/` (grep) → corrections SOURCE/REFILL sans régression.
- **Reste à corriger en S4** : `S\"` (HERE), `tuck`/`-rot` (B2c), ~~`STATE`~~ (✅ corrigé Jour 16), ~~`FIND`~~ (✅ corrigé Jour 18), ~~`PARSE-NAME`~~ (✅ corrigé Jour 19), ~~`PARSE`~~ (✅ corrigé Jour 20), modèle d'adressage, arithmétique double.

## Revue Semaine 3 (Jour 21, 2026-08-07)

Relecture statique des corrections J15→J20 (STATE, FIND, PARSE-NAME, PARSE, tokenizer recâblé), en l'absence d'exécution matérielle :

- **Code relu** : `state`/`]`/`[`/`:`/`;` et tokenizer (interpreter.rs:10900, 10976-10978, 11067, 11706-11720), `find` (103, l.2254), `parse-name` (329, l.4778), `parse` (330, l.4808), synchro `>IN` (l.10907-10911), `sys:load`/`include`/`require` (sauvegarde/restauration de `state_addr` l.12035/12069/12107). Cohérents : `[` n'est reconnu qu'en compilation (test B5 l.299 valide, la bascule est prouvée par l'absence d'erreur "Mot inconnu").
- **DÉCOUVERTE MAJEURE — modèle source** : dans Epona, `compile()` appelle `set_source` UNE fois avec **TOUT le fichier** (l.10765, 6464, 12036) et `>IN` est un résidu global (test B4 `>in 5 !` laissait 5 pour la suite). Les tests B7/B8 d'origine supposaient « source = ligne courante avec `>IN`=0 » → ils étaient **non déterministes/rouges** (par ex. parse-name voyait `\` ou `===` au lieu de `(commentaire`). **Corrigé** : tous les tests B7/B8 réécrits en **source contrôlée** (`evaluate` : `set_source` remet `>IN` à 0) ; les cas « parenthèse atomique » et « espaces initiaux » (impossibles via `s"`, qui éclate les parenthèses en tokens séparés) sont construits octet par octet dans `memory` puis exécutés via `evaluate`.
- **B4** : `>in 5 ! >in @ .` laissait un résidu global → **restauré** (`0 >in !` en fin de ligne). **B6** : résidus de pile (`here find` sans cleanup) **nettoyés** (`2drop`, `drop`).
- **Régression** : aucun usage des mots recâblés (`state`, `find`, `parse`, `parse-name`, `>in`) dans BOOT.FTH, forth/boot, forth/config, forth/std, forth/drivers, applications racine (grep) ; `find-device`/`drvmap:find`/`acpi-find` sont des noms de mots locaux, pas la primitive. Aucun impact.
- **Incompatibilités conservées (documentées)** : `S\"` consomme `HERE` (interprété l.12519-12529 et `PushStr` compilé), `tuck`/`-rot` (B2c, volontairement rouges), modèle `Vec<i64>` (unités d'adresse), arithmétique double 32 bits, `CREATE`/`VARIABLE`/`DOES>`, `CATCH`/`THROW`, 21 mots Core absents, jeux Core Extensions/optionnels non fournis, `EVALUATE` ne sauvegarde pas l'entrée précédente, `(`/`)` éclatés en tokens séparés (impossibilité de nom/mot contenant une parenthèse exécutable — limite testable de la correction PARSE-NAME, à re-évaluer avec le chantier mémoire S4).


## Jour 22 — Inventaire mémoire (Semaine 4, 2026-08-07)

Inventaire statique complet de `src/interpreter.rs` (12939 lignes), aucun changement de code. 278 occurrences `self.memory` : **119 adresse** / **82 octet** / **50 cellule** / **27 resize** (25×`resize` + 2×`push`).

### Zonage

| Zone | Type | Convention | Lieux |
|---|---|---|---|
| `memory` | `Vec<i64>` (4096) | cellules **et** octets mélangés (1 octet/cellule pour les chaînes) | `@`/`!` l.1562/1573 ; chaînes l.530, 9297, 10078, 11552, 12558 |
| `here` | `usize` | bump **mixte** : 1/cellule pour `,`/`create`/`value`/`defer`/`allot`/`buffer:` (l.10606, 10654, 11935, 11968, 12316, 12378, 12761) ; 1/octet pour les chaînes (l.530, 9297, 10078, 11552, 12558) | l.294 |
| `variables` | `BTreeMap<String,usize>` | valeur = **index de cellule** = `variables.len()` à l'insertion (l.11658-11659, 11769-11770) → adresses dépendantes de l'ordre de compilation | l.272 |
| `string_pool` | `Vec<u8>` (64 Ko) | noms de mots du dictionnaire uniquement (`store_str` l.502-514) | l.293 |
| `source_buffer`/`source_addr` | String + index | **double représentation** : String UTF-8 (parse l.4779/4810) + copie octets dans `memory` à `here` (l.529-530) ; c-addr retournés dans la copie memory (l.4801-4804) | l.329-330, `set_source` l.520-535 |
| `to_in_addr`/`state_addr` | 4095/4094 | cellules système **dans** l'espace utilisateur (0..4096) — `check_mem` l.483 les accepte | l.450-451 |
| `byte_mem` | `Vec<u8>` (256 Ko) | mémoire u8 **séparée** (DMA/réseau) ; `b@`..`b>c` 348-356 (l.4991-5059), `balloc` bump sur `byte_here` | l.343, 458 |

### Usages cellule / octet / MMIO / pointeur natif

- **Cellule i64** : `@` `!` `+!` (10/11/113), `state`, `>in`, variables, `,` `.`, `value`/`defer`, `buffer:`, `f64::to_bits` (l.7958), atomic, JIT `*mut i64` (l.10116-10128).
- **Octet (1/cellule)** : chaînes `s"`/`."`/`type`/`key`, `find` (l.2263-2270), `get-var`/`set-var` (l.2696-2755), `sys:read`/`disk:read` (l.10322-10478, 12143-12282), VFS/http (l.3637-3971), gfx images (l.4471-4757).
- **MMIO natif (hors `memory`)** : `c@` `c!` `w@` `w!` `l@` `l!` `fill` `cmove` = **primitives 73-80** → `i2c_hid::mmio_read8/write8/read16/write16/read32/write32` (l.1989-2060). **Le jeu `C@`..`CMOVE` standard ne touche PAS `memory`** — point clé pour les Jours 26-27.
- **Pointeur natif** : `move` (158) = `core::ptr::copy` (l.2880-2888) ; `erase` (159) = `core::ptr::write_bytes` (l.2889-2897) ; `inb`/`outb`/`inw`/`outw`/`inl`/`outl` (740-745, asm, l.2087-2146) ; `phys@`/`phys!` (110/111, `read/write_volatile`, l.2326-2335) ; `alloc-phys`/`free-phys` (105/106) ; VFS/DMA USB/disk/audio via `boot_alloc_pages` + `from_raw_parts` (l.3073-3392, 4141-4379, 5424-5688, 8845-8874) ; `mmio-w@`/`mmio-w!` (722/723, `drv_api`, l.6719-6746).
- **Atomic** : `atomic:add/cas/xchg` (l.8383-8428) castent la cellule en `*mut AtomicU8` → seuls 8 bits verrouillés (granularité incohérente avec la cellule 64 bits).

### Les 9 ambiguïtés structurelles

1. `cells` (l.2843) = n×8 mais les chaînes occupent **1 cellule/octet** → facteur 8 ;
2. `memory` = RAM cellules **et** RAM octets simultanément (même tableau) ;
3. deux espaces d'adressage : index `memory` (0..4095) vs pointeurs natifs physiques (`move`/`erase`/VFS/DMA/JIT) ;
4. croissance non bornée : seul `alloc` (l.2190) est borné par `MAX_MEM` ; les autres `resize` étendent sans limite ;
5. `state`/`>in` (4094/4095) dans l'espace utilisateur → corruptibles par un `!` utilisateur ;
6. `variables.len()` = index → adresses dépendantes de l'ordre de compilation, en unités mélangées ;
7. atomic 8 bits vs cellule 64 bits ;
8. `gfx:polygon-fill` lit des paires de cellules i64 alors que le reste du gfx utilise `byte_mem` ou le framebuffer natif ;
9. source en double représentation (String + copie memory) → toute divergence casse la correspondance `>IN`/c-addr.

### Conclusion pour la Semaine 4

Le mot « adresse » n'a pas de définition unique dans le code : 119 vérifications en unités mixtes (addr en cellules + len en octets), `here` à sémantique mixte, `variables` indexées en cellules, pointeurs natifs hors `memory`. **Jour 23 : trancher l'unité d'adresse avant tout changement.**

## Jour 23 — Contrat d'adressage (Semaine 4, 2026-08-07)

**Décision (validée par l'utilisateur) : 1 unité d'adresse = 1 cellule i64.**

| Mot | Avant | Après (J23) | Implémentation |
|---|---|---|---|
| `CELL` | (absent) | 1 | constante Forth `1 constant cell` (boot BOOT.FTH) |
| `CHAR` | (absent) | 1 | constante Forth `1 constant char` (boot BOOT.FTH) |
| `CELL+` | +8 | +1 | primitive 152 (l.2836-2840) |
| `CELLS` | n×8 | n | primitive 153 (l.2841-2845) |
| `ALIGNED` | align-8 | identité | primitive 154 (l.2846-2850) |
| `CHAR+` | +1 | +1 | primitive 155 (inchangée) |
| `CHARS` | n | n | primitive 156 (inchangée) |

### Justification

- Les applications allouent déjà en cellules (`create X N allot`, `N 2 * allot`,
  `[char] q ... azerty-normal-base @ + !` avec 1 char par cellule) ;
- `cells`/`aligned`/`cell+` étaient **inutilisés** par tout le code Forth du
  projet (vérifié par grep) → changement sans impact ;
- le standard Forth 2012 autorise explicitement des chars > 8 bits (3.1.2.3) ;
  restriction environnementale : chars de 64 bits, documentée.

### Endianness

Little-endian natif (x86_64). `memory` stocke les cellules brutes (i64) ; pas
d'encodage binaire multi-octets exposé côté Forth. L'endianness ne s'applique
qu'aux échanges binaires (fichiers/DMA/réseau) via `byte_mem` ou pointeurs
natifs — hors contrat Forth.

### Incompatibilités documentées (Jour 23)

- `CHAR <c>` (parsing) non supporté : utiliser `[char] <c>` (token compilateur
  l.11177-11181) ; `char` seul retourne la taille (1), pas le char du mot
  suivant ;
- `c@`/`c!` restent du MMIO natif (73-80) → rebranchement sur `memory`
  prévu au **J26** (requis : DESKTOP/STDLIB/EDITEUR/KEYLOG les utilisent sur
  des buffers `allot`és) ;
- cellules système `state`/`>in` (4094/4095) dans l'espace utilisateur
  (ambiguïté n°5, à résoudre en J24+).

### Tests

- Section **B9** ajoutée dans `TESTS/core2012.fth` (cell/char/cells/chars/
  aligned/cell+/char+).

### Validation

- `cargo build` : 0 erreur, 413 warnings (baseline). Aucun warning sur les
  lignes modifiées. Validation matérielle : `exec TESTS/core2012.fth` → B9
  vert (NB-FAILS = 2 uniquement pour B2c).

## Jour 24 — Helpers mémoire (Semaine 4, 2026-08-07)

### Helpers ajoutés (`src/interpreter.rs:494-510`)

```rust
fn read_cell(&self, addr: usize) -> Option<i64>   // check_mem borné
fn write_cell(&mut self, addr: usize, val: i64) -> bool
fn read_byte(&self, addr: usize) -> Option<u8>    // (v & 0xFF)
fn write_byte(&mut self, addr: usize, val: u8) -> bool
```

- bornés par `check_mem` (`[mem_low, mem_high)` + `memory.len()`) ;
- `read_byte`/`write_byte` : octet **bas** d'une cellule (modèle « 1 octet par
  cellule » des chaînes/apps) — `write_byte` met la cellule à `val` (8 bits) ;
- `read_byte`/`write_byte` non branchés pour l'instant → `#[allow(dead_code)]`
  (seront utilisés par `C@`/`C!` au J26).

### Migrations

- `@` (10), `!` (11), `+!` (113) passent par `read_cell`/`write_cell`
  (`src/interpreter.rs:1580-1608, 2360-2372`). Comportement identique
  (message « sandbox bloque adresse » en cas de débordement, pile inchangée).

### Tests — section B10 (`TESTS/core2012.fth`)

- `123 here ! here @` → 123 ;
- `5 here +!` → 128 ;
- `42 4096 @` → 42 (le `@` hors bornes ne pousse rien) ;
- `5 4096 !` / `5 4096 +!` → bloqués, `here @` reste 128 (memory intacte).

### Validation

- `cargo build` : 0 erreur, 413 warnings (baseline). Le warning temporaire
  `read_byte`/`write_byte` never used a été éliminé par `#[allow(dead_code)]`.

## Jour 25 — HERE/ALLOT/`,`/C, et l'unité d'adresse (Semaine 4, 2026-08-07)

### Relation à l'unité d'adresse (1 AU = 1 cellule i64)

Déjà cohérent : `here` est un index de cellule, `ALLOT n` avance de `n`,
`,`/`c,` écrivent 1 cellule et avancent `here` de +1, `ALIGNED` = identité
(défini J23). Le travail J25 porte sur le **bornage** et la **sécurité**.

### Bornage strict `MAX_MEM` (4096) — 4 points de code

- `here`/`allot` interprétés (`src/interpreter.rs:12365-12383`) ;
- `Op::Allot` / `Op::Comma` (mots compilés, `:...;`) — `Err("allot:, ...")`
  au dépassement ;
- primitives immédiates `c,` (315) et `,` (316) — message `print_buffer` ;
- `create` (1 cellule réservée) — même borne.

`ALLOT` négatif : `here.saturating_sub` — supprime l'ancien
`wrapping_add(n as usize)` qui, pour `n` très négatif, provoquait un wrap 64
bits → `here` énorme → `memory.resize(énorme)` → risque d'allocation
géante/OOM (crash noyau). C'est la correction de sécurité majeure de J25.

### Écart résiduel (documenté)

`set_source` (`src/interpreter.rs:544-559`) et `Op::PushStr` font toujours
croître `here`/`memory` **sans borne** à chaque exécution de source. Cohérent
avec J23 (au-delà de 4096 les données ne sont plus adressables par `@`/`!`)
mais à traiter à J26 (rebranchement chaînes sur l'espace Forth).

### Tests — section B11 (`TESTS/core2012.fth`)

- `here aligned` = identité ;
- `here 1 allot` → delta +1 ; `here -1 allot` → delta -1 ;
- `here 42 ,` → delta +1 et `here @` = 42 ;
- `here 65 c,` → delta +1 et `here @` = 65 ;
- `here 65536 allot` → bloqué, delta 0 (here inchangé, message erreur).

### Validation

- `cargo build` / `--release` : 0 erreur, 413 warnings (baseline).
- `qemu_img/EFI/BOOT/BOOTX64.efi` + `qemu_img/forth/TESTS/core2012.fth`
  resynchronisés.

## Jour 26 — Fenêtre mémoire `C@`/`C!`/`W@`/`W!`/`L@`/`L!`/`FILL`/`CMOVE`

Décision utilisateur : **fenêtre** (recommendée J23). Primitives 73-80
(`src/interpreter.rs:2010-2163`) :

- `addr` passe `check_mem` (< 4096) → accès à `self.memory` via
  `read_byte`/`write_byte` (octet bas d'une cellule) et `read_cell`/
  `write_cell` (masques 16/32 bits pour `w@`/`w!`/`l@`/`l!`) ;
- sinon → **MMIO natif** (`i2c_hid::mmio_*`, comportement antérieur intact).

Conséquences :
- Les buffers des apps (`create`/`allot`, EDITEUR/KEYLOG/DESKTOP) sont
  désormais cohérents entre `c@`/`c!` et `@`/`!`/`allot` (avant : `c@` lisait
  la vraie mémoire physique aux petites adresses → incohérent).
- heap/mmap (~1 TiB) et MMIO haut : adresses ≥ 4096 → accès réel conservé
  (tests `TESTS/heap.fth` intacts).
- `FILL`/`CMOVE` fenêtre : bornés à `MAX_MEM` (clamp), chevauchement géré.
- `read_byte`/`write_byte` (J24) : les `#[allow(dead_code)]` retirés (désormais
  utilisés par `c@`/`c!`).

### Point pré-existant signalé (non lié à J26)

`alloc` (95) est borné à `MAX_MEM`=4096. `EDITEUR.fth` fait `10000 alloc
constant buf-addr` → retourne **-1** (échec) depuis toujours. `debug-buf` =
`2048 alloc` passe si la mémoire libre le permet. À revoir si l'éditeur doit
charger des fichiers de 10 000 cellules (dépasserait la borne d'adressage).

### Tests — section B12 (`TESTS/core2012.fth`)

- `123 here c! here c@` → 123 ; `256 here c! here c@` → 0 (masque 8 bits) ;
- `0x1234 here w! here w@` → 0x1234 ; `65536 here w! here w@` → 0 ;
- `0x12345678 here l! here l@` → 0x12345678 ;
- `here 4 0xAB fill` → `here c@` et `here 1 + c@` = 0xAB ;
- `cmove` : `here 16 ! here 1 + 32 ! here here 1 + 1 cmove` → `here 1 + @` = 16.

### Validation

- `cargo build` / `--release` : 0 erreur, 413 warnings (baseline).
- qemu_img resynchronisée (BOOTX64.efi + core2012.fth).

## Jour 27 — Fenêtre `MOVE`/`ERASE` (Semaine 4, 2026-08-07)

`FILL`/`CMOVE` ont déjà été migrés en J26 (primitives 79/80). Restaient
`MOVE` (158) et `ERASE` (159), des pointeurs natifs bruts :
`core::ptr::copy` / `core::ptr::write_bytes` en **octets**, incohérents avec
l'unité d'adresse (1 AU = 1 cellule).

Migration en fenêtre (`src/interpreter.rs:2948-2992`) :
- `addr` passe `check_mem` (< 4096) → `self.memory`, **u cellules**, copie
  avec chevauchement géré (src<dest → arrière, dest<src → avant), clamp
  `MAX_MEM` (même logique que `cmove`) ;
- sinon → pointeur natif (comportement antérieur, pour heap/mmap).

### Tests — section B13 (`TESTS/core2012.fth`)

- `move` : copie 2 cellules (src<dest, arrière) → valeurs vérifiées ;
- `move` : chevauchement dest<src (avant) → valeurs vérifiées ;
- `move` longueur nulle → mémoire inchangée ;
- `erase` : `here 3 0xAA fill here 2 erase` → 2 cellules à 0, 3e intacte ;
- `erase` longueur nulle → mémoire inchangée.

### Validation

- `cargo build` / `--release` : 0 erreur, 413 warnings (baseline).
- qemu_img resynchronisée (BOOTX64.efi + core2012.fth).

## Jour 28 — Revue S4 (2026-08-08)

Revue de la migration mémoire (J24-J27). Décision : **migration maintenue**,
mais `MAX_MEM` insuffisant.

### `MAX_MEM` 4096 → 65536

La source est stockée dans l'espace de données à 1 octet/cellule : le simple
chargement de `TESTS/core2012.fth` (23 630 octets) fait croître `here` vers
~25 000 → au-delà des 4096. Les bornages J25-J27 étaient donc inopérants en
pratique (tout chargement dépassait la borne). Élevé à **65536**
(`src/interpreter.rs:260`) → fichiers source jusqu'à ~64 Ko.

- `state_addr`/`to_in_addr` sont définis comme `MAX_MEM - 2`/`MAX_MEM - 1`
  → recalculés automatiquement (65534/65535).
- `check_mem` (l.482-484) : `addr >= mem_low && addr < mem_high &&
  addr < memory.len()` — porté par construction.

### `alloc` (95) réparé

Avant : poussait `memory.len()` et vérifiait une taille au-delà → échec
systématique (EDITEUR `10000 alloc` → -1). Maintenant : réserve `size`
cellules depuis `here` via `checked_add` (`src/interpreter.rs:2253-2271`) ;
message « Erreur: alloc — mémoire insuffisante (demandé {}, libre {}) » si
dépassement. `here` inchangé en cas d'échec (testé B14).

### Résidus pointeurs natifs

Plus que 2 accès `core::ptr` : les branches natives de `MOVE` (158) /
`ERASE` (159) (adresses ≥ `MAX_MEM`, hors fenêtre → comportement antérieur
conservé pour heap/mmap ~1 TiB).

### Limite résiduelle documentée

`here` croît à **chaque** chargement de source (`set_source` copie le fichier
dans `memory[HERE..]`) : la source n'est pas recyclée. Deux chargements
successifs ~doublent l'empreinte. Une vraie séparation source/espace de
données reste à faire (refonte ultérieure, cf. section suivante).

### Tests — section B14 (`TESTS/core2012.fth`)

- `alloc` réserve `u` cellules depuis `here` (`here` enregistré avant/après) ;
- BUF initialisé puis relu via `@` (écriture/lecture cohérentes) ;
- `alloc` géant (1 000 000) → -1, `here` inchangé.

### Validation

- `cargo build` / `--release` : 0 erreur, 413 warnings (baseline).
- qemu_img resynchronisée (BOOTX64.efi + core2012.fth).
- NB-FAILS attendu en exec : 2 (B2c seul, volontairement rouges).


## Jour 29 — `VARIABLE` alloue dans `HERE` (Semaine 5, 2026-08-08)

### Diagnostic (audit, l.394)

« `VARIABLE` n'ajoute pas de mot au dictionnaire, n'alloue pas une cellule
alignée dans `HERE`, et ses adresses entrent en collision avec les chaînes
et la source. »

Cause racine (inventaire J22, l.74) : `variables` = `BTreeMap<String,usize>`
avec valeur = **index de cellule** = `variables.len()` à l'insertion →
adresses 0,1,2,… dépendantes de l'ordre de compilation, en bas de `memory`
(non protégé : source, chaînes, boot).

### Correctif

Helper `create_variable` (`src/interpreter.rs:515-541`), calqué sur
`CREATE` (l.12415-12441), branché sur les 2 sites `variable` (interprété
l.11905 et compilé l.11796) :

1. **Alloue dans HERE** : `data_addr = here; here += 1` (borné `MAX_MEM`,
   message « Erreur: variable — mémoire dépassée (MAX {}) », `here` inchangé
   si échec).
2. **Initialise à 0** : `memory[data_addr] = 0`.
3. **Crée un mot dictionnaire** `[Push(data_addr), Exit]` → `VARIABLE`
   visible de `'`/`FIND` (grief 1 de l'audit réglé ; la métaprogrammation
   l.404 s'applique désormais à moins de mots).
4. **Garde `self.variables` rempli** (map `var_name → data_addr`, `insert`
   → toujours à jour) : compat watchpoints/debug/marker, et la résolution
   par nom (interprété l.12890 / compilé l.11826) reste prioritaire via la
   map → pas de dépendance à un éventuel doublon de dictionnaire.

Alignement : avec `CELL`=1 (J23), `ALIGNED` = identité → toute adresse est
alignée (grief « cellule alignée » satisfait par construction).

### Sécurité source

`set_source` copie la source dans `memory[here..here+len]` puis avance
`here` (l.576-591) → les variables créées pendant l'exécution tombent
**après** la source, pas de collision (testé B15).

### Tests — section B15 (`TESTS/core2012.fth`)

- `here` avance de 1 cellule à la création ;
- cellule initialisée à 0, utilisable via `!`/`@` ;
- adresses distinctes entre 2 variables ;
- `' V15 0 >` : mot présent au dictionnaire (xt valide) ;
- cohérence d'unité avec `,` (donnée suivante à +1).

### Impact apps

EDITEUR (`W`,`H`,`BARRE_Y`,…) et TESTS (`NB-FAILS`, `S1`) accèdent par nom
→ transparent ; adresses 0..n → ~HERE (aucun usage en dur vérifié).
BOOT.FTH : aucun `variable` → sans impact. `constant`/`value` inchangés.

### Validation

- `cargo build` / `--release` : 0 erreur, 413 warnings (baseline).
- qemu_img resynchronisée (BOOTX64.efi + core2012.fth).
- NB-FAILS attendu en exec : 2 (B2c seul, volontairement rouges).


## Jour 30 — `CONSTANT` / `VALUE` / `TO` (Semaine 5, 2026-08-08)

### État avant J30

- `constant` interprété (l.12422) : pop val, Word `[Push(val), Exit]` sans
  allocation — conforme. Compilé : `Op::ConstantCreate` (l.11736 + runtime
  l.10772) — conforme.
- `value` interprété (l.12096) : pop val, alloue 1 cellule dans `HERE`,
  `memory[addr]=val`, Word `[ValueAddr(addr)]` (pousse la valeur),
  `create_data=addr` — conforme. **Mais non borné `MAX_MEM`**.
- `to` interprété (l.12122) / compilé (`Op::ToValue`, l.11430) : écrit la
  cellule via `create_data` — conforme.
- **Manque** : `value` en mode compilé n'avait **aucun cas** → `eerr "Mot
  inconnu : value"` dans toute définition. `defer` interprété non borné
  `MAX_MEM` (même famille, traité plus tard).

### Correctif

1. **`Op::ValueCreate(u32,u16)`** (enum l.61) + runtime (l.10790-10816) :
   pop val, alloue 1 cellule dans `HERE` (borné `MAX_MEM`, message d'erreur,
   here inchangé si échec), `memory[addr]=val`, Word `[ValueAddr(addr)]` avec
   `create_data=addr`. Cas compilé `"value"` (l.11771-11776) ajouté à côté de
   `"constant"`.
2. **Sérialisation JIT** (jit.rs) : code 47 pour `ValueCreate`
   (sérialisation l.238 + deserial l.312). Le JIT ne compile pas cet op
   (`_ => return false`, l.1387) → exécution par l'interpréteur (fallback
   normal). Ajouté aussi au comptage `string_pool` du `forget` (l.2918).
3. **`value` interprété borné `MAX_MEM`** (même garde que `variable`).

### Sémantique du système (à retenir)

Les defining words (`constant`/`value`/`create`) dans une définition
s'exécutent **au runtime** (via `Op::ConstantCreate`/`ValueCreate`/
`CreateWord`), pas à la compilation. Conséquence : `5 to X` compilé exige
que `X` existe déjà au moment de la **compilation** (le `to` résout
l'adresse à la compilation via `create_data`). Testé avec définitions
séparées (B16).

### Tests — section B16 (`TESTS/core2012.fth`)

- `constant` : pousse la valeur, pas d'allocation ;
- `value` interprété : alloue 1 cellule dans `HERE`, pousse la valeur,
  `to` met à jour ;
- `value` compilé (`ValueCreate` au runtime) + `to` compilé (`ToValue`) ;
- `constant` compilé (`ConstantCreate` au runtime).

### Validation

- `cargo build` / `--release` : 0 erreur, 413 warnings (baseline).
- qemu_img resynchronisée (BOOTX64.efi + core2012.fth).
- NB-FAILS attendu en exec : 2 (B2c seul, volontairement rouges).

## Jour 31 — `CREATE` / `DOES>` (Semaine 5, 2026-08-08)

### État avant J31

- `CREATE` réservait 1 cellule (`here += 1`) dès sa création, avant le `,`
  ou `ALLOT` : `create X N allot` donnait N+1 cellules utilisables
  (décalage de 1 par rapport au standard).
- `DOES>` : le nouveau mot créé avait `ops = [Push(addr), Exit]`, puis le
  body `does>` était étendu **après** l'`Exit` → code inatteignable
  (2 sites : bloc `;` et résolution interprétée d'un defining word).
- Aucun usage de `does>` dans les apps ; `create` utilisé par
  KEYLOG.fth (`LOG_BUF 4000 allot`, `NUM_BUF`, `NUM_DIGS`),
  bureau3.fth (`CLK_BUF 6 allot`). Aucun test B existant ne couvrait
  `create`.

### Correctif (Option A — standard)

- `CREATE` ne réserve plus : `data_addr = here` (identique à `buffer:`),
  la mémoire est réservée par `,` ou `ALLOT` après `CREATE` (4 sites :
  create interprété, résolution interprétée d'un defining word,
  `Op::CreateWord` runtime, `Op::CreateDefining` runtime).
- `DOES>` : body inséré **avant** l'`Exit` final
  (`new_ops = [Push(data_addr), ...body, Exit]`) à la résolution
  interprétée d'un defining word (le site effectif) ; le body reçoit
  `data_addr` sur la pile (standard). Analyse : le bloc `does_offset` du
  `;` était redondant — `does_ops` est déjà extrait par
  `rposition(DoesMarker)` et `ops` est réécrit avec `compiling_ops`
  ensuite → bloc supprimé (aucun changement de comportement).
- Compatibilité apps vérifiée : `create X N allot` → `X` = base utilisable,
  N cellules ; DESKTOP.FTH `variable num-buf 16 allot` (J29 + allot) OK.

### Tests — section B17 (`TESTS/core2012.fth`)

- `create X17` : `here` inchangé, `X17` pousse `data_addr = here` ;
- `create BUF17 5 allot` : `here +5`, `!`/`@` dans le buffer ;
- `: my-const  create , does> @ ;  11 my-const ELEVEN` : `ELEVEN 11 = verif`
  (pattern « constante », body `does>` lit la valeur stockée par `,`) ;
- `: plus-data  create , 2 allot does> @ 10 + ;  5 plus-data PD` :
  `PD 15 = verif` (body consomme `data_addr` puis ajoute) ;
- `: make-buf  create 3 allot ;  make-buf CB17` : `here = CB17 + 3`
  (`CreateWord` compilé).

### Validation

- `cargo build` / `--release` : 0 erreur, 413 warnings (baseline).
- qemu_img resynchronisée (BOOTX64.efi + forth en miroir).
- NB-FAILS attendu en exec : 2 (B2c seul, volontairement rouges).


## Chaînes compilées — moteur d'exécution

`Op::PushStr` (utilisé vraisemblablement par `S\"` et possiblement par d'autres littéraux) recopie la chaîne dans `memory[HERE..]` **à chaque exécution**, puis avance `HERE`. Pour un Forth standard, une chaîne compilée doit au minimum disposer d'une durée de vie correcte et ne doit pas épuiser/faire dériver indéfiniment l'espace de données à chaque passage dans une boucle. Cela aggrave l'incohérence déjà relevée entre source, chaînes, `HERE` et les données compilées.

`Op::AbortQuote` applique bien le test non nul attendu par `ABORT\"` au moment de l'exécution, mais la conformité complète dépendra encore du compilateur (parsing de la chaîne) et de la façon dont l'erreur remet les piles et la source à l'état imposé par `ABORT`.

### Jour 33 (2026-08-08) — `S"` compilé corrigé

Le bug de consommation infinie de `HERE` est corrigé : `S"` compilé copie
désormais la chaîne **une seule fois** dans `memory[HERE]` (données
compilées, comme `,`/`ALLOT`), à la compilation, et génère
`Op::PushStrAddr(addr, len)` qui pousse `(addr, len)` au runtime **sans
avancer `HERE`** (avant : recopie + `HERE += len` à chaque passage dans une
boucle). `S"` interprété (copie ponctuelle standard) et `."` compilé
(`PrintStr` → print_buffer, pas de copie `HERE`) sont inchangés. Les chaînes
compilées vivent dans `memory` (> 4096) ; `TYPE`/`COUNT`/`COMPARE` lisent
`memory` en direct → compatibles. `restore-marker` restaure `HERE` → les
chaînes sont récupérées par `marker`/`forget`. Sérialisation JIT code 48
(fallback interpréteur). `Op::PushStr` conservé pour compat des images
existantes. Tests : section B18 (compilation +5, `len` correct, `addr <
here`, `here` inchangé après exécutions répétées).

## Flottants — extrait `900..979`

Le bloc constitue une extension propriétaire de flottants encodés en `f64` dans la pile de données. Il ne suffit pas, à lui seul, à annoncer la compatibilité avec le **Floating-Point word set** Forth 2012 :

- Le standard permet une pile flottante unifiée à la pile de données, mais uniquement comme restriction environnementale documentée. Le choix de `self.stack` n'est donc pas interdit en soi ; il doit néanmoins être documenté et tous les effets de pile normalisés doivent rester corrects.
- Les noms standard de conversion `S>F` et `F>S` ne sont pas présents dans la table enregistrée. `i>f` / `f>i` ne sont pas les noms normalisés, et `s>f` / `f>s` servent ici à parser/produire des chaînes, non à convertir un entier signé.
- `f>i` réalise une troncature ; ce n'est pas un substitut direct documenté à `F>S`.
- Plusieurs mots usuels du jeu flottant ne sont pas encore visibles : notamment `FALIGN`, `FALIGNED`, `FCONSTANT`, `FDEPTH`, `FLITERAL`, `FLOAT+`, `FLOATS`, `F>S`, `S>F`; à vérifier aussi si des définitions Forth les ajoutent plus loin.
- Point positif : les comparaisons flottantes visibles (`F<`, `F>`, `F=`, `F0=`, `F0<`) renvoient bien `-1` ou `0`, contrairement à plusieurs comparaisons entières du noyau.

## Hors norme mais erreurs d'effet de pile visibles

Ces mots sont propriétaires, donc ils ne déterminent pas la conformité ANS, mais leurs commentaires et leurs poussées sont inversés dans l'extrait :

- `font:size` annonce `( -- w h )` mais pousse `h` puis `w`.
- `font:measure` annonce `( addr len -- w h )` mais pousse `h` puis `w`.
- `gfx:glyph` annonce `( cp -- addr w h )` mais pousse `h`, puis `w`, puis `addr`.

## Bilan final — Forth 2012 Core

### Verdict

L'interpréteur possède beaucoup de fonctionnalités Forth et un très grand ensemble d'extensions OS, mais **ne peut pas actuellement être qualifié de système Forth 2012 Core conforme**. Deux raisons indépendantes suffisent : plusieurs mots Core sont absents, et plusieurs mots Core existants ont une sémantique incompatible.

### Mots Core absents de `interpreter.rs`

`#  #>  #S  */MOD  2!  2@  <#  >NUMBER  ABORT  ACCEPT  ALIGN  BASE  ENVIRONMENT?  HOLD  KEY  M*  QUIT  S>D  SIGN  U<  WORD`

Ces 21 mots peuvent être fournis par un fichier Forth chargé au démarrage, mais aucun n'est implémenté par la table de primitives ni par les cas spéciaux du compilateur observés.

### Mots Core présents mais à corriger

| Zone | Problème principal |
|---|---|
| Flags | ~~`=`, `<`, `>`, `<>`, `0=`, `0<`, etc. retournent `1` au lieu d'un vrai flag `-1` (tous les bits à 1).~~ **✅ Corrigé Jour 8** : renvoient maintenant `-1`/`0`. |
| Adressage | ~~`CELL` vaut 8, mais `,` et `C,` font tous deux `HERE += 1`; `@` indexe un `Vec<i64>` tandis que les chaînes utilisent un élément par octet.~~ **✅ Corrigé Jour 23** : 1 unité d'adresse = 1 cellule (`CELL`=1, `CHAR`=1, `CELLS`/`CHARS`/`ALIGNED` = identité), `CELL+`/`CHAR+` = +1, endianness little-endian. |
| Mémoire caractère | ~~`C@`, `C!`, `FILL`, `CMOVE` vont vers le MMIO brut au lieu de l'espace de données Forth. `MOVE` et `ERASE` utilisent des pointeurs natifs incompatibles avec `HERE`/`@`/`!`.~~ **✅ Corrigé J26/J27** : fenêtre mémoire — `addr` dans `self.memory` (`< MAX_MEM`) → accès mémoire (masques 8/16/32 bits), sinon → MMIO/pointeur natif (heap ~1 TiB) conservé. |
| Définition de données | ~~`VARIABLE` n'ajoute pas de mot au dictionnaire, n'alloue pas une cellule alignée dans `HERE`, et ses adresses entrent en collision avec les chaînes et la source.~~ **✅ Corrigé Jour 29** : alloue 1 cellule dans `HERE` (init 0, borné `MAX_MEM`), crée un mot dictionnaire `[Push(addr), Exit]`, garde la map en cache. ~~`CREATE` avance `HERE` trop tôt ; `DOES>` ajoute du code après un `Exit`, donc le code `does>` est inatteignable.~~ **✅ Corrigé Jour 31** : `CREATE` ne réserve plus (`data_addr = here`, comme `buffer:`), body `does>` inséré avant l'`Exit` final. |
| État / dictionnaire | ~~`STATE` retourne la valeur au lieu d'une adresse.~~ **✅ Corrigé Jour 16** : `state` pousse `MAX_MEM-2`, le tokenizer et `]`/`[`/`:`/`;` lisent/écrivent cette cellule → `state !` change réellement le mode. ~~`FIND` a une signature non standard.~~ **✅ Corrigé Jour 18** : `find` prend une chaîne comptée et rend `(c-addr 0)` / `(xt 1)` / `(xt -1)` avec flag immédiat (xt = index dictionnaire). |
| Arithmétique | `2/` **✅ corrigé Jour 9**, `RSHIFT` **✅ corrigé Jour 10** ; `*/` n'a pas de produit intermédiaire double ; `FM/MOD`, `SM/REM`, `UM*`, `UM/MOD` sont implémentés comme si les cellules faisaient 32 bits malgré `CELL = 8`. |
| Source / parsing | `S\"` consomme `HERE` (à corriger) ; `PARSE-NAME` **✅ corrigé Jour 19** (délimiteurs = espaces, c-addr dans la source, HERE inchangé) ; `PARSE` **✅ corrigé Jour 20** (ne saute plus les délimiteurs initiaux → champs vides u=0, c-addr dans la source, n'avance plus `>IN` ni `HERE`) ; `SOURCE` **✅ corrigé Jour 13** (adresse stable via `source_addr`, `HERE` inchangé) ; `REFILL` **✅ corrigé Jour 12** (ligne vide = vrai) ; `EVALUATE` ne sauvegarde pas/restaure pas l'entrée précédente. |
| Exception | `CATCH` standard est absent. `0 THROW` doit être un no-op, mais l'implémentation déclenche une exception. `TRY/CATCH/ENDTRY` est une extension distincte, pas le jeu Exception standard. |

### Core Extensions : non complet

Manquants notamment : `.(`, `.R`, `2R@`, `:NONAME`, `C\"`, `COMPILE,`, `DEFER!`, `DEFER@`, `HOLDS`, `PAD`, `ROLL`, `SAVE-INPUT`, `RESTORE-INPUT`, `S\\\"`, `SOURCE-ID`, `U.R`, `U>`, `UNUSED`, `WITHIN`, `[COMPILE]`.

`IF`, `DO`, `BEGIN`, `CREATE`, `TO`, `VALUE`, `DEFER`, `CASE`, etc. sont souvent traités directement par le parseur plutôt que comme des définitions normales du dictionnaire. Cela suffit pour certains programmes source, mais casse des usages de métaprogrammation tels que `FIND`, `'` et `POSTPONE` sur ces mots.

### Jeux optionnels

- **Exception** : non fourni (`CATCH` absent, `THROW` non conforme).
- **String** : non fourni (`/STRING`, `-TRAILING`, `CMOVE>`, `SLITERAL` absents ; `CMOVE` ne travaille pas dans l'espace Forth).
- **Double-Number** : non fourni.
- **Floating-Point** : non fourni dans son intégralité. Beaucoup de mots `f*` sont des extensions utiles, mais il manque entre autres `>FLOAT`, `D>F`, `F>D`, `FALIGN`, `FALIGNED`, `FCONSTANT`, `FDEPTH`, `FLITERAL`, `FLOAT+`, `FLOATS`, `FLOOR`, `FVARIABLE`, `REPRESENT`.
- **Locals** : non fourni. En plus, les branches `LocalGet`, `LocalSet`, `LocalsAlloc` et `LocalsFree` ne font pas `ip += 1`, donc elles rebouclent sur la même instruction.
- **Memory-Allocation** : non fourni (`ALLOCATE`, `FREE`, `RESIZE` absents ; `alloc` est une extension de signature différente — **✅ Jour 28** : réparé, réserve depuis `here`, borné `MAX_MEM`).
- **Search-Order** : non fourni sous la forme standard (`WORDLIST`, `GET-ORDER`, `SET-ORDER`, `SEARCH-WORDLIST`, etc. absents). Les vocabulaires actuels sont une extension de style ancien.

## Ordre conseillé des corrections

1. Remplacer le modèle `Vec<i64>` ambigu par un espace de données adressable en octets (`Vec<u8>`), avec lectures/écritures cellule 64 bits explicites. — **✅ Semaine 4 (J23-J28, partiel)** : modèle tranché (1 cellule = 1 unité d'adresse), fenêtre mémoire `MAX_MEM`, `,`/`C,`/`HERE`/`ALLOT` bornés, `@`/`!`/`C@`/`C!`/`W@`/`W!`/`L@`/`L!`/`FILL`/`CMOVE`/`MOVE`/`ERASE` cohérents, `alloc` réparé. Une séparation source/espace de données reste à faire.
2. Faire passer `@ ! C@ C! 2@ 2! MOVE FILL CMOVE ERASE , C, HERE ALLOT CREATE VARIABLE` par cet unique espace de données.
3. Ajouter les 21 mots Core absents, en priorité `BASE`, `KEY`, `ACCEPT`, `2@`, `2!`, `*/MOD`, `M*`, `S>D`, `U<`, `>NUMBER`, `ABORT`, `QUIT` et le groupe de sortie numérique `# #S <# #> HOLD SIGN`.
4. Corriger les flags (`-1`/`0`), `RSHIFT`, `2/`, l'arithmétique double avec `i128`/`u128`, et `STATE` (✅ Jour 16)/`FIND` (✅ Jour 18).
5. Réécrire `CREATE`/`DOES>` (**✅ Corrigé Jour 31**), puis `CATCH`/`THROW`. `VARIABLE` **✅ Corrigé Jour 29**.
6. Ajouter les tests de régression du jeu de tests Forth 2012 avant d'annoncer une compatibilité.

## Caveat

Un éventuel `BOOT.FTH` peut ajouter des mots absents écrits en Forth. Il ne peut toutefois pas, sans contourner les primitives existantes, corriger les problèmes fondamentaux d'adressage, de flags, de `STATE`, de `FIND`, de `DOES>` et d'arithmétique double décrits ci-dessus.
