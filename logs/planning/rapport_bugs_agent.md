# Rapport de bugs — Epona OS 1.98 — Session 2026-08-17
## Pour l'agent codeur — à traiter le lendemain

> **Projet** : Interpréteur Forth 2012 embarqué dans un OS UEFI en Rust  
> **Fichier principal** : `src/interpreter.rs`  
> **Tests** : `qemu_img/forth/core2012/jour*.fth` (exec depuis le shell QEMU)  
> **Convention** : `NB-FAILS = 0` = succès total ; les lignes `0 <- ECHEC` indiquent les tests ratés.

---

## Résumé global des résultats de tests

| Fichier | NB-FAILS | Statut |
|---------|----------|--------|
| `jour23.fth` | 0 | ✅ OK |
| `jour24.fth` | 0 | ✅ OK |
| `jour25.fth` | 0 | ✅ OK (avec message `allot ? mémoire dépassée` attendu) |
| `jour26.fth` | 1 | ❌ ECHEC — Bug `C!` masque de bits |
| `jour27.fth` | 7 | ❌ ECHEC — Bug `FILL`/`CMOVE`/`ERASE`/`MOVE` sur `c@` |
| `jour28.fth` | 0 | ✅ OK |
| `jour29.fth` | à tester | |
| `jour30.fth` | 0 | ✅ OK |
| `jour31.fth` | 0 | ✅ OK |
| `jour32.fth` | 0 | ✅ OK |
| `jour33.fth` | 1 | ❌ ECHEC — Bug `S"` : comparaison d'adresse vs HERE |
| `jour34.fth` | 0 | ✅ OK |
| `jour35.fth` | 0 | ✅ OK |
| `jour36.fth` | Erreur | ❌ CRASH ligne 49 — `Mot inconnu en mode immediat : 16` |
| `jour37.fth` | Erreur | ❌ CRASH ligne 33 — `Mot inconnu en mode immediat : 2000` |
| `jour38.fth` | Erreur | ❌ CRASH ligne 38 — `Mot inconnu en mode immediat : 5` |
| `jour39.fth` | Erreur | ❌ CRASH ligne 33 — `Mot inconnu en mode immediat : -5` |
| `jour40.fth` | Erreur | ❌ CRASH ligne 38 — `Mot inconnu en mode immediat : 42` |
| `jour41.fth` | Erreur | ❌ CRASH ligne 37 — `Mot inconnu en mode immediat : -2` |
| `jour43.fth` | 1 | ❌ ECHEC ligne 46 — `Mot inconnu en mode immediat : 65` |

---

## Bug #1 — `jour26.fth` — `C!` : masque de bits incorrect (NB-FAILS = 1)

### Symptôme
```
-1 -1 -1 0 <- ECHEC
```
Le 4ème test échoue. Les 3 premiers passent.

### Test qui échoue (ligne 39-41 de `jour26.fth`)
```forth
-1 wv !      \ wv = -1 (0xFFFF_FFFF_FFFF_FFFF)
0 wv c!      \ écrire 0 dans l'octet bas → devrait donner 0xFFFF_FFFF_FFFF_FF00
wv c@ 0 = verif   \ OK (passe)
wv @ -256 = verif \ ECHEC : wv @ ne vaut pas -256
```

### Cause attendue dans `src/interpreter.rs`
La primitive `C!` (write_byte) doit :
1. Masquer l'octet bas avec `0xFF`
2. Conserver les bits supérieurs (bytes 1-7) en appliquant `& 0xFFFF_FFFF_FFFF_FF00`
3. Résultat = `(cellule_actuelle & !0xFF) | (valeur & 0xFF)`

Exemple : `-1 wv !` puis `0 wv c!` → `memory[wv] = (-1 & !0xFF) | 0 = -256`

**Chercher** `write_byte` ou la primitive `c!` dans `src/interpreter.rs` et vérifier que le masque préserve les bits supérieurs.

---

## Bug #2 — `jour27.fth` — `FILL`/`CMOVE`/`ERASE`/`MOVE` : NB-FAILS = 7

### Symptôme
```
-1 -1 0 <- ECHEC
0 <- ECHEC   (x6)
-1 -1
```

### Tests qui échouent
```forth
src27 4 7 fill
src27 c@ 7 = verif       \ ✅ OK
src27 3 + c@ 7 = verif   \ ❌ ECHEC

dst27 4 0 fill
src27 4 dst27 4 cmove
dst27 c@ 7 = verif       \ ❌ ECHEC
dst27 3 + c@ 7 = verif   \ ❌ ECHEC

dst27 2 0 erase
dst27 c@ 0 = verif       \ ❌ ECHEC
dst27 1 + c@ 0 = verif   \ ❌ ECHEC
dst27 2 + c@ 7 = verif   \ ❌ ECHEC
```

### Cause attendue
Les mots `FILL`, `CMOVE`, `ERASE`, `MOVE` travaillent sur **des cellules** (indices `memory[]`) mais l'arithmétique d'adresse `addr + n` avance d'une **unité = 1 cellule** (Jour 23, contrat adressage 1 AU = 1 cellule i64).

**Problème probable** : dans l'implémentation Rust de `FILL`/`CMOVE`/`ERASE`/`MOVE`, le nombre `u` est interprété comme un nombre d'octets au lieu d'un nombre de cellules. Donc `src27 4 7 fill` remplit 4 cases mémoire, mais la case `src27 + 3` (3 cellules plus loin) n'est jamais touchée.

**Fix attendu** : vérifier dans `src/interpreter.rs` que les primitives 79 (`fill`), 80 (`cmove`), 158 (`move`), 159 (`erase`) utilisent `u` comme nombre de **cellules** et non d'**octets**, car `1 AU = 1 cellule i64` (Jour 23).

---

## Bug #3 — `jour33.fth` — `S"` compilé : adresse vs HERE (NB-FAILS = 1)

### Symptôme
```
-1 0 <- ECHEC
-1 -1 -1
```
Le 2ème test échoue.

### Test qui échoue (ligne 41)
```forth
s33c drop here > verif   \ ECHEC : l'adresse renvoyée n'est pas < HERE
```

où `s33c` est défini avec `s" hello"` compilé.

### Cause attendue
Le test vérifie que l'adresse de la chaîne est **strictement inférieure à HERE** (la chaîne est stockée avant HERE). Si `s"` en mode compilé renvoie une adresse égale ou supérieure à HERE, ce test échoue.

**Fix attendu** : vérifier que la primitive `S"` en mode compilation (`Op::PushStrAddr(addr, len)`) stocke la chaîne à l'adresse **au moment de la compilation** (avant que HERE avance), et non à l'adresse courante de HERE au moment de l'exécution.

---

## Bug #4 — `jour36.fth` à `jour41.fth` — `Mot inconnu en mode immediat : N`

### Symptôme général (identique pour tous)
```
Erreur: *** ERREUR ligne XX *** Mot inconnu en mode immediat : N
```
où `N` est un **nombre entier** (`16`, `2000`, `5`, `-5`, `42`, `-2`).

### Cause racine COMMUNE

Le compilateur Epona gère les nombres entiers en mode **compilation** (à l'intérieur de `: ... ;`) mais semble les rejeter dans certains **contextes d'exécution immédiat** impliquant la pile de retour ou les mots de compilation spéciaux.

#### Détail par fichier

**`jour36.fth` ligne 49** — `16 base !`
```forth
16 base !    \ changer base en hexadécimal
```
Le nombre littéral `16` est rejeté en mode immédiat. Cela implique que le contexte au moment de l'exécution de cette ligne est en mode "compilation" non voulu, ou que le parser ne reconnaît pas les nombres à cet endroit du fichier.

> **Probable cause** : après certaines définitions ou `evaluate`, `STATE` reste à 1 (mode compilation) alors qu'il devrait être revenu à 0.

**`jour37.fth` ligne 33** — `1000 2000 d37 2!`
```forth
1000 2000 d37 2!   \ stocker 2 cellules
```
Les nombres `1000` et `2000` sont rejetés.

> **Probable cause** : idem — STATE = 1 résiduel, ou `2!` / `2@` produit une erreur préalable qui corrompent l'état.

**`jour38.fth` ligne 38** — `5 5 u< 0 = verif`
```forth
5 5 u< 0 = verif   \ 5 u< 5 → false
```
Le nombre `5` est rejeté.

**`jour39.fth` ligne 33** — `-5 3 m*`
```forth
-5 3 m*   \ produit signé double
```
Le nombre `-5` est rejeté.

**`jour40.fth` ligne 38** — `42 s>d <# #s #> s" 42" compare 0 = verif`
```forth
42 s>d <# #s #> s" 42" compare 0 = verif
```
Le nombre `42` est rejeté.

**`jour41.fth` ligne 37** — `-2 2 -1 d.`
```forth
-2 2 -1 d.
```
Le nombre `-2` est rejeté.

### Piste de débogage recommandée

Avant chaque test qui échoue, vérifier la valeur de `STATE`. Si `STATE ≠ 0` à ce point, le compilateur est en mode compilation et rejette les nombres comme "mots inconnus en mode immédiat".

**Chercher dans `src/interpreter.rs`** :
1. La gestion de `STATE` après un `evaluate` imbriqué.
2. La restauration de `STATE` dans `eval_source()`.
3. Si un mot compilé laisse `STATE = 1` sans le restaurer.

---

## Bug #5 — `jour43.fth` — `KEY` : `Mot inconnu en mode immediat : 65` (NB-FAILS = 1)

### Symptôme
```
-1 -1 0 <- ECHEC
Erreur: *** ERREUR ligne 46 *** Mot inconnu en mode immediat : 65
```

### Contexte
```
VALIDATION CLAVIER
Appuie sur la touche 'A' puis Entree
pour valider le test du fichier :
```
Le test attend que l'utilisateur tape `A` (code ASCII 65) et valide avec Entrée. 
Mais ensuite, le nombre `65` est rejeté comme "mot inconnu en mode immédiat".

### Cause probable
Même cause que Bug #4 : `STATE` résiduel à 1 après l'interaction clavier (`KEY`/`REFILL`). Vérifier la restauration de `STATE` dans le mot `KEY` et `REFILL`.

---

## Récapitulatif des actions à faire

| Priorité | Action | Fichier |
|----------|--------|---------|
| 🔴 1 | Corriger `C!` (write_byte) : masquer l'octet bas ET préserver les bits supérieurs `(cell & !0xFF) \| (val & 0xFF)` | `src/interpreter.rs` — prim c! |
| 🔴 2 | Corriger `FILL`/`CMOVE`/`MOVE`/`ERASE` : utiliser `u` comme **nombre de cellules** (pas d'octets) | `src/interpreter.rs` — prims 79,80,158,159 |
| 🔴 3 | Corriger bug `STATE` résiduel après `evaluate` / `key` / certains mots — rend les nombres illisibles en mode immédiat | `src/interpreter.rs` — `eval_source()` et `STATE` |
| 🟡 4 | Corriger `S"` compilé : l'adresse retournée doit être `< HERE` | `src/interpreter.rs` — `PushStrAddr` |
| 🟢 5 | Après corrections, recompiler : `cargo build --release --target x86_64-unknown-uefi` | — |
| 🟢 6 | Déployer `target/.../rust_os.efi` → `qemu_img/EFI/BOOT/BOOTX64.efi` et `Z:\EFI\BOOT\BOOTX64.efi` | — |
| 🟢 7 | Copier `forth/` → `qemu_img/forth/` et `Z:\forth/` | — |

---

## Informations de contexte importantes

- **Contrat d'adressage (Jour 23)** : `1 unité d'adresse = 1 cellule i64`. Donc `addr + 1` = cellule suivante. Toutes les primitives de copie mémoire doivent utiliser des offsets en cellules, pas en octets.
- **Mémoire** : `memory: Vec<i64>`, taille MAX_MEM = 131072. `C@`/`C!` = octet bas de la cellule i64 (`memory[addr] & 0xFF`).
- **`FILL` ( a-addr u char -- )** : remplit `u` cellules à partir de `a-addr` avec la valeur `char`.
- **`CMOVE` ( c-addr1 c-addr2 u -- )** : copie `u` cellules de `c-addr1` vers `c-addr2` (de gauche à droite).
- **`ERASE` ( a-addr u -- )** : remplit `u` cellules avec 0.
- **`MOVE` ( addr1 addr2 u -- )** : copie `u` cellules avec gestion du chevauchement.
