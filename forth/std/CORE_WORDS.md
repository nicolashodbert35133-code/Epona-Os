# CORE_WORDS.md — Signatures de pile des mots Core utilisés par les tests

> Créé le 2026-08-06 (Semaine 1, Jour 3).
> Source : `src/interpreter.rs` (exec_primitive + compile()) et Forth 2012.
> Convention : ✅ conforme / ⚠️ non conforme (à corriger) / 📝 implémenté hors
> norme (compilateur / variable) / ❌ absent.

## 1. Mots Core utilisés par les tests existants (forth/TESTS/)

| Mot | Signature Forth 2012 | Implémentation Epona | Statut |
|-----|----------------------|----------------------|--------|
| `abs` | `( n -- n )` | `v.abs()` idx 53 | ✅ |
| `and` | `( x1 x2 -- x3 )` | `a & b` idx 67 | ✅ |
| `c!` | `( ch addr -- )` | `mmio_write8(addr)` idx 74 | ⚠️ écrit en MMIO brut, pas dans l'espace Forth (`memory[]`) |
| `c,` | `( char -- )` | `HERE += 1` idx 315 | ⚠️ avance HERE de 1 octet mais `memory[]` est un `Vec<i64>` |
| `c@` | `( addr -- ch )` | `mmio_read8(addr)` idx 73 | ⚠️ lit en MMIO brut, pas dans l'espace Forth |
| `cr` | `( -- )` | `print_buffer += "\n"` idx 35 | ✅ |
| `constant` | `( x "name" -- )` | Op::ConstantCreate idx compilateur | 📝 voir constat C1 |
| `create` | `( "name" -- )` | Op::CreateDefining idx compilateur | ⚠️ avance HERE trop tôt (audit) |
| `do` | `( limit start -- )` | Op::Do idx compilateur | 📝 géré par le parseur, pas le dictionnaire |
| `drop` | `( x -- )` | pop idx 6 | ✅ |
| `dup` | `( x -- x x )` | push last idx 5 | ✅ |
| `fill` | `( addr u ch -- )` | `mmio_write8` en boucle idx 79 | ⚠️ remplit du MMIO, pas l'espace Forth |
| `here` | `( -- addr )` | variable compilateur | 📝 voir constat C2 |
| `i` | `( -- n )` | lit `loop_rstack` idx 114 | ✅ |
| `loop` | `( -- )` | Op::Loop idx compilateur | 📝 géré par le parseur |
| `mod` | `( n1 n2 -- n3 )` | `a % b` idx 4 | ✅ (tronqué, cohérent avec `/`) |
| `or` | `( x1 x2 -- x3 )` | `a \| b` idx 68 | ✅ |
| `r>` | `( -- x )` | pop `rstack` idx 117 | ✅ |
| `rot` | `( x1 x2 x3 -- x2 x3 x1 )` | remove(len-3) idx 9 | ✅ |
| `rshift` | `( x1 u -- x2 )` logique | `((v as u64) >> n)` idx 72 | ✅ |
| `swap` | `( x1 x2 -- x2 x1 )` | swap(len-1, len-2) idx 7 | ✅ |
| `type` | `( c-addr u -- )` | lit `memory[]` idx 119 | ⚠️ lit l'espace `memory[]` (1 octet/cell), PAS le MMIO → incohérent avec `c@` |
| `variable` | `( "name" -- )` | BTreeMap `variables` idx compilateur | 📝 voir constat C3 |

## 2. Mots Core Extension utilisés par les tests (flottants)

| Mot | Signature Forth 2012 | Implémentation Epona | Statut |
|-----|----------------------|----------------------|--------|
| `f!` | `( f addr -- )` | (groupe flottant) | ✅ |
| `f@` | `( addr -- f )` | (groupe flottant) | ✅ |
| `f.` | `( f -- )` | (groupe flottant) | ✅ |
| `f<` | `( f1 f2 -- flag )` | idx 905 | ✅ -1/0 |
| `f=` | `( f1 f2 -- flag )` | idx 907 | ✅ -1/0 |
| `f0<` | `( f -- flag )` | idx 911 | ✅ -1/0 |
| `f0=` | `( f -- flag )` | idx 910 | ✅ -1/0 |
| `fabs` | `( f -- |f| )` | idx 913 | ✅ |
| `facos` | `( f -- f )` | idx 944 libm | ✅ |
| `fasin` | `( f -- f )` | idx 943 libm | ✅ |
| `fatan` | `( f -- a )` | idx 956 libm | ✅ |
| `fatan2` | `( fy fx -- f )` | idx 920 libm | ✅ |
| `fceil` | `( f -- f )` | idx 926 libm | ✅ |
| `fcos` | `( f -- f )` | idx 918 libm | ✅ |
| `fdrop` | `( f -- )` | idx 936 (alias drop) | ✅ |
| `fexp` | `( f -- f )` | idx 921 libm | ✅ |
| `flog2` | `( f -- f )` | idx 923 libm | ✅ |
| `fnegate` | `( f -- -f )` | idx 912 | ✅ |
| `fround` | `( f -- f )` | idx 927 (ties-to-even) | ✅ |
| `fsin` | `( f -- f )` | idx 917 libm | ✅ |
| `fsincos` | `( f -- s c )` | idx 955 | ✅ |
| `fsqrt` | `( f -- f )` | idx 916 libm | ✅ |
| `ftan` | `( f -- f )` | idx 919 libm | ✅ |
| `s>f` | `( addr len -- f )` | idx 931 parse ASCII | ⚠️ signature non standard `( addr len -- f )` |

## 3. Constats

- **C1** `constant` : ne crée pas de mot au sens standard ; stocké comme une
  "variable à 1 cellule" via `create_data`. Adresses en collision avec les
  chaînes (audit §87).
- **C2** `here` : variable gérée par le compilateur ; l'adressage de `HERE`
  entre en collision avec les chaînes stockées et la source (audit §86-87).
- **C3** `variable` : n'ajoute PAS de mot au dictionnaire, n'alloue pas de
  cellule alignée dans `HERE`, adresses dans un `BTreeMap` séparé
  (`self.variables`), indexées différemment de `HERE` (audit §87).
- **C4** Incohérence mémoire majeure : `c@`/`c!`/`fill` vont en MMIO brut,
  alors que `type`/`find`/`s>f` lisent `memory[]` (l'espace Forth). Deux
  mondes incompatibles → toute chaîne écrite avec `c!` est illisible par
  `type`, et inversement.
- **C5** `rshift` (72) : ~~`wrapping_shr` sur `i64` = décalage arithmétique
  (bit de signe propagé).~~ **✅ Corrigé Jour 10** : `((v as u64) >> n)`
  interpréteur, aligné sur le JIT (SHR via `shr_cl`). Compte mod 64 =
  comportement hardware x86. `lshift` (71) : décalage gauche, logique par
  nature — conforme (inchangé).
- **C6** Flags : ~~`=` (37), `<` (59), `>` (60), `0=` (63) etc. retournent `1`
  au lieu de `-1` (tous les bits à 1). Impact direct sur les tests `\ -1`.~~
  **✅ Corrigé Jour 8** : les comparaisons renvoient `-1`/`0` (interpreter +
  JIT). Les prédicats de statut (`touche?`, `souris?`, probes) renvoient
  toujours `1` — hors périmètre Jour 8.
- **C7** `2/` (52) : ~~`v / 2` tronque vers zéro (divergence sur les entiers
  négatifs impairs).~~ **✅ Corrigé Jour 9** : `v >> 1` (shift arithmétique)
  interpréteur, aligné sur le JIT (SAR via `sar_imm8`). `-5 2/` = `-3`.
  `/`, `MOD`, `/MOD` vérifiés **conformes** (division symétrique ANS,
  Jour 9) — aucune réécriture nécessaire.

## 4. Mots Core utilisés par les tests mais ABSENTS
Aucun : les 23 mots Core utilisés par les tests existants sont tous
disponibles (certains non conformes, voir ci-dessus). Les 23 mots Core
manquants (Jour 2) ne sont PAS utilisés par les tests actuels.
