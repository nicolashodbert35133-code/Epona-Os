# Planning de codage — Epona OS / Forth ISO 2012

> Durée : 12 semaines.
> Charge : 2 heures par jour, 7 jours sur 7.
> Total théorique : 168 heures.
> Objectif : socle Forth stable, documenté et utilisable par des agents et utilisateurs distants pour créer des applications et drivers `.fth`.
> Références : `rapport.md`, `forth_audit_2012.md`, `devguide_Forth_Iso_2012.md`, `DEV_GUIDE_AGENT.md`.

## 1. Ce que ce planning peut réellement produire

En 168 heures, l’objectif réaliste est :

- un sous-ensemble Forth 2012 Core clairement testé ;
- un modèle mémoire Forth cohérent pour les mots prioritaires ;
- une API Driver v1 documentée ;
- une API Application v1 documentée ;
- des exemples `.fth` exécutables ;
- une suite de tests de régression ;
- une VM interprétée utilisable sans JIT ;
- une validation x86_64 UEFI/QEMU ;
- une première préparation AArch64 sans promesse de support complet.

Ce planning ne garantit pas en 12 semaines :

- la conformité intégrale Forth 2012 Core + Extensions ;
- le support de toutes les architectures CPU ;
- tous les pilotes GPU, Wi-Fi et audio ;
- POSIX, ELF, Ring 3 et SMP complet ;
- une réécriture complète de toutes les 13 000 lignes de `interpreter.rs`.

## 2. Règle quotidienne des 2 heures

Chaque séance doit suivre la même structure :

| Durée | Activité |
|---:|---|
| 10 min | Lire la fiche du jour et vérifier le périmètre |
| 70 min | Coder une modification limitée |
| 25 min | Ajouter ou exécuter les tests Forth/Rust |
| 10 min | Compiler debug/release ou lancer le test ciblé |
| 5 min | Écrire le journal de séance et le prochain blocage |

Une séance ne doit pas commencer un nouveau domaine si le test de la séance précédente échoue.

## 3. Règles de l’agent codeur

1. Ne modifier qu’un seul sous-système par séance.
2. Lire `devguide_Forth_Iso_2012.md` avant toute modification de `interpreter.rs`.
3. Écrire la signature de pile avant le code.
4. Ne jamais ajouter un mot standard sans test.
5. Ne jamais modifier les indices propriétaires sans inventaire.
6. Ne pas toucher au shell ou au réseau pendant une phase Forth Core.
7. Préserver le fallback interprété si le JIT est indisponible.
8. Arrêter la séance si le modèle mémoire devient ambigu.
9. Ne pas annoncer la conformité ISO avant les tests de régression.
10. Chaque semaine se termine par une journée de stabilisation, pas par une nouvelle fonctionnalité.

## 4. Semaine 1 — Baseline, inventaire et contrat

**But : savoir exactement ce qui fonctionne avant de coder.**

### Jour 1 — Baseline Rust ✅ FAIT (2026-08-06)

- Lancer les builds debug et release.
- Enregistrer les erreurs et warnings de référence.
- Vérifier les tests existants dans `forth/TESTS/`.
- Créer `logs/planning/week01-day01.txt` si le dossier de logs existe.

> **Résultat** : builds debug + release OK, 0 erreur, 413 warnings (référence).
> 15 fichiers de tests inventoriés dans `forth/TESTS/` (aucun test Core 2012 pour l'instant).
> Convention de test : `\ -1` = OK, `\ 0` = échec, mot auto-exécuté en fin de fichier, lancement via `exec <fichier>.fth`.
> Log détaillé : `logs/planning/week01-day01.txt`.

### Jour 2 — Inventaire Forth ✅ FAIT (2026-08-06)

- Extraire la liste des mots enregistrés.
- Les classer : Core, Core Extension, Epona propriétaire.
- Détecter les doublons de noms.
- Ne modifier aucun code.

> **Résultat** : 741 primitives (729 uniques) + ~68 mots-clés compilateur + 49 mots Forth
> = 833 mots effectifs. **Core présent : 103/133 (77 %)**. **Core manquants : 23**
> (les 21 de l'audit + `CHAR` + `IMMEDIATE` oubliés par l'audit). **Core Ext manquants : 37**.
> **12 doublons de noms** à nettoyer en Phase 4 (`mmio@/!`, `inb..outl`, `ahci:init/read/write`, `nvme:init`).
> Mots de contrôle gérés par le parseur, pas par le dictionnaire (confirme l'audit : `'`/`FIND`/`POSTPONE` cassés dessus).
> Log détaillé : `logs/planning/week01-day02.txt`.

### Jour 3 — Signatures de pile ✅ FAIT (2026-08-06)

- Documenter les mots Core déjà utilisés par les tests.
- Repérer les signatures absentes ou contradictoires.
- Commencer une table `forth/std/CORE_WORDS.md` si nécessaire.

> **Résultat** : `forth/std/CORE_WORDS.md` créé. 23 mots Core + 24 Core Ext utilisés
> par les tests. **11 conformes**, **7 non conformes** (`c@`/`c!`/`fill` → MMIO au lieu
> de l'espace Forth, `rshift` signé, `c,` HERE+=1 avec CELL=8, `create` HERE trop tôt),
> 5 hors norme (compilateur/variables). **Constat majeur C4** : deux mondes mémoire
> incompatibles (`c@`→MMIO vs `type`→`memory[]`) à unifier en Phase 4.
> Log détaillé : `logs/planning/week01-day03.txt`.

### Jour 4 — Tests de base

- Créer `forth/TESTS/core2012.fth`.
- Ajouter les tests pile, arithmétique et comparaison.
- Définir le format d’un test réussi/échoué.

> **FAIT (2026-08-06)** — `forth/TESTS/core2012.fth` créé (192 lignes, format Epona
> `\ -1`/`\ 0`, helper `verif` + compteur `NB-FAILS` auto-exécuté).
> **Section A (verte dès aujourd'hui)** : pile (`dup drop swap over rot nip 2dup
> 2drop 2swap 2over ?dup pick`), arithmétique (`+ - * / mod /mod 1+ 1- 2+ 2- 2* 2/
> abs negate min max`), logique (`and or xor invert lshift rshift` positif).
> **Section B (cible standard, rouge)** : comparaisons (`= <> < > <= >= 0= 0<>
> 0< 0>`, flags attendus `-1`, aujourd'hui 1), `rshift` logique, `2/` signé, plus
> 2 bugs **nouveaux** découverts en relisant `exec_primitive` :
> - `-rot` (idx 38) contient l'implémentation de `rot` → `1 2 3 -rot` donne `2 3 1`
>   au lieu de `3 1 2` ;
> - `tuck` (idx 40) copie le bas de pile → `1 2 tuck` donne `2 1 1` au lieu de
>   `2 1 2`.
> ⚠️ Exécution matérielle NON faite dans cette session : à lancer par
> `exec TESTS/core2012.fth` (Section A = `-1`/vert, Section B = NB-FAILS > 0).
> Log détaillé : `logs/planning/week01-day04.txt`.

### Jour 5 — Boot Forth

- Vérifier que `BOOT.FTH` est réellement compilé puis exécuté.
- Tester le mot d’entrée `principal` ou `main`.
- Documenter le comportement si aucun mot d’entrée n’existe.

> **FAIT (2026-08-06) — CONTREDIT LE JOUR 7 (correction d'une erreur
> d'analyse des Jours 4-5)** — le "BUG DE BOOT" n'existe pas. Le mode
> immédiat gère bien `."` : handler ligne 12465-12482 (la chaîne est
> analysée puis imprimée aussitôt). Il en va de même pour `abort"` (12441),
> `s"` (12483), `,"` (12512). `BOOT.FTH` racine + `forth/boot/BOOT.FTH`
> compilent et s'exécutent en ENTIER (idem `config/default.fth`,
> `drvlib.fth`, `pci_enum.fth`, `drvmap.fth`). Les points valides vérifiés
> ce jour :
> **1) Mot d'entrée** : `run()` (interpreter.rs:9662) et `run_slice()`
> (interpreter.rs:9690, via `current_entry_word`) cherchent `principal`.
> Le shell `exec` en mode runtime enveloppe un point d'entrée trouvé :
> `: principal begin <entree> again ;` (shell.rs:2061) ou `: principal <entree> ;`
> (shell.rs:2185), sinon tente `principal`/`bureau`/`main`.
> **2) Aucun mot d'entrée** : `run()` → "Erreur : le mot 'principal' n'est pas
> défini" ; `run_slice()` → RunResult::Error("entry not found") puis tâche
> marquée terminée ("[Programme termine]") ; shell → "compilée. Aucun point
> d'entrée." Après `exit-uefi`, aucune tâche Forth n'est lancée d'office
> (la boucle runtime main.rs:1103 ne lance que les tâches ajoutées par exec).
> **3) Robustesse réelle à corriger (Phase 2, Jour 12+) :** `sys:load`
> (interpreter.rs:12013-12025) affiche "ERR:" mais NE PROPAGE pas l'erreur
> au compile parent — un script chargé qui échoue n'est pas détecté par
> AUTO-BOOT ("[AUTO-BOOT] BOOT.FTH charge OK" même si un `sys:load` échoue).
> **4) Seule vraie limite de `."`/`s"`/`abort"`/`,"` :** la chaîne ne doit
> pas contenir `(` ni `)` (le stripping des commentaires `( ... )` s'applique
> à tous les tokens).
> Log détaillé : `logs/planning/week01-day05.txt` (+ correction en fin de log).

### Jour 6 — Contrat d’API

- Écrire la première version de `Driver API v1`.
- Écrire la première version de `Application API v1`.
- Distinguer clairement les mots ISO des mots `drv:*` et `epona:*`.

> **FAIT (2026-08-06)** — `docs/API_V1.md` créé (contrat v1). Séparation
> stricte en 3 espaces de noms : **ISO 2012** (sous-ensemble garanti, 103/133
> Core ; manquants dans `CORE_WORDS.md`/audit), **`drv:*`** (framework driver
> existant, `drvlib.fth` + primitives vérifiées), **`epona:*`** (réservé,
> NON implémenté — proposition v1 de 10 mots). Le document contracte :
> - le cycle de vie driver (load → métadonnées → register → probe → init)
>   avec signatures exactes (`drv:name!`, `drv:register`, `drv:probe ( bar bus
>   dev func -- ok? )`, accesseurs autoloader...) et les 7 types (0..6) ;
> - le bas niveau autorisé (MMIO `mmio@/!`, port I/O `inb..outl`, PCI
>   `pci@/!`, `pci:list/dev/bar`, `alloc*`, `ticks`, `drv:log/warn/err/ok`,
>   `drv:loaded?`) ;
> - le contrat d'application (entrée `principal`, enveloppement shell
>   `fth_find_entry`, comportement sans entrée, sous-ensemble ISO garanti) ;
> - des **écarts doc/code relevés** : `writing-drivers.md` §6 liste des mots
>   inexistants (`port-io-wr/rd`, `boot-alloc`, `mmio-map`) ; `drv:log` existe
>   en double (primitive 840 + drvlib).
> Log détaillé : `logs/planning/week01-day06.txt`.

### Jour 7 — Revue semaine 1

- Refaire les builds.
- Rejouer les tests.
- Ne corriger que les régressions de la semaine.
- Produire une fiche de blocages et décider si la semaine 2 peut commencer.

> **FAIT (2026-08-06)** — **Builds** : debug + release OK, 0 erreur, 413
> warnings (baseline inchangée — aucun code Rust modifié en S1).
> **CORRECTION MAJEURE de la revue** : le « BUG DE BOOT » des Jours 4-5
> n'existe pas. `."` (et `s"`, `abort"`, `,"`) sont gérés en mode immédiat
> (interpreter.rs:12441/12465/12483/12512) : BOOT.FTH, config et stdlib
> (drvlib/pci_enum/drvmap) compilent et s'exécutent en entier. La conclusion
> des Jours 4-5 venait d'une lecture incomplète de la zone « mode immédiat »
> de `compile()`. Les références au pseudo-bug ont été corrigées dans le
> planning, les logs J4/J5/J6 et `docs/API_V1.md`.
> **Fiche de blocages S1 (ce qui bloque/à corriger)** :
> - **Rien ne bloque le boot.** Vrai bug de robustesse : `sys:load`
>   (interpreter.rs:12013-12025) affiche "ERR:" mais ne propage pas l'erreur
>   au compile parent → un script chargé qui échoue passe inaperçu.
> - **À corriger en Semaine 2 (priorité)** : flags `-1/0` (J8), `2/` signé
>   (J9), `rshift` logique (J10), + les bugs S1J4 `-rot` (idx 38) et `tuck`
>   (idx 40).
> - **Limite à documenter** : chaînes `."`/`s"`/`abort"`/`,"` sans `(`/`)`
>   (stripping commentaires sur tous les tokens).
> - **Exécution matérielle NON faite** (pas de capture dans cette session) :
>   à faire par l'utilisateur — `exec TESTS/core2012.fth` (Section A verte,
>   Section B NB-FAILS > 0) et boot réel (bannière + init-* + `principal`).
> Log détaillé : `logs/planning/week01-day07.txt`.

**Livrable :** baseline reproductible, inventaire Forth et contrats API initiaux.

## 5. Semaine 2 — Sémantique Core prioritaire

**But : corriger les divergences locales sans migration mémoire.**

### Jour 8 — Flags `-1/0`

- Corriger `=`, `<>`, `<`, `>`, `<=`, `>=`.
- Corriger `0=`, `0<>`, `0<`, `0>`.
- Ajouter les tests vrai/faux.

> **FAIT (2026-08-06)** — les 10 comparaisons renvoient maintenant `-1`/`0`.
> **Code** : interpreter.rs idx 37 + 58-66 (`push -1` si vrai) ET jit.rs
> prim_eq/ne/lt/gt/le/ge/zeroeq/zerone/zerolt/zerogt (`not_r` + `add_imm8(1)`
> après le `movzx` — les deux chemins sont alignés, le JIT étant actif par
> défaut). `true`/`false` existaient déjà (-1/0).
> **Sécurité vérifiée** : `JumpIfZero` teste le non-nul → `if`/`until`/
> `while`/`of` inchangés ; aucun script `.fth` ne lit le flag comme `1` ; les
> tests heap/ipc_adv/as/vm/time_adv/net_adv attendaient déjà `\ -1` (rouges
> → verts). Comparaisons flottantes (f< f= f0< f0=) déjà conformes.
> **Tests** : `core2012.fth` Section B0 « Vrai/Faux » ajoutée ; Section B1
> au vert (NB-FAILS = 0 attendu). B2/B2b/B2c restent rouges (rshift, 2/,
> -rot, tuck → J9-10+).
> **Builds** : debug + release OK, 0 erreur, 413 warnings (baseline).
> **Docs** : audit §19/§84, API_V1.md, CORE_WORDS.md (C6 résolu) mis à jour.
> Log détaillé : `logs/planning/week01-day08.txt`.

### Jour 9 — Arithmétique signée

- Corriger `2/` pour les négatifs.
- Vérifier `/`, `MOD` et `/MOD` sans les réécrire inutilement.
- Ajouter les tests de valeurs limites.

> **FAIT (2026-08-06)** — `2/` signé corrigé.
> **Code** : interpreter.rs idx 52 `v / 2` → `v >> 1` (décalage arithmétique,
> arrondi vers moins l'infini — `-5 2/` = `-3`). JIT `prim_2slash` était déjà
> conforme : `shr_imm8` (émettant en fait SAR `0xC1 /7`) renommé en `sar_imm8`
> pour lever l'ambiguïté (appelants prim_2slash + prim_abs).
> **Vérification sans réécriture** : `/`, `MOD`, `/MOD` (Rust `/` et `%` =
> troncature vers zéro, reste = signe du dividende) sont **conformes** à la
> division symétrique ANS (`-7 3 /` = `-2`, `-7 3 MOD` = `-1`, `/MOD` quotient
> au sommet) — aucun changement. Bug latent corrigé au passage :
> `parse_number_with_base` utilisait `-(val as i64)` → panique en debug pour le
> littéral décimal MIN `-9223372036854775808` ; remplacé par `.wrapping_neg()`.
> **Tests** : Section B2b réécrite (bornes : MIN via `-1 63 lshift`, MIN+1,
> `-1`, `0`, `1`, `-3`, MAX littéral, positif) + nouvelle Section B2b2
> « division signée » (preuve `/ mod /mod` conformes). B2b/B2b2 doivent être
> vertes sur matériel (NB-FAILS = 0 attendu pour A/B0/B1/B2b/B2b2) ; B2 (rshift,
> Jour 10) et B2c (tuck/-rot) restent rouges.
> **Builds** : debug + release OK, 0 erreur, 413 warnings (baseline).
> **Docs** : audit l.21 résolu (l.89 : RSHIFT reste Jour 10), CORE_WORDS.md
> (C7 résolu), API_V1.md (bullet « Conforme Jour 9 » + `2/` retiré de la liste
> non conforme).
> Log détaillé : `logs/planning/week01-day09.txt`.

### Jour 10 — `RSHIFT`

- Implémenter le décalage logique.
- Tester valeurs positives, négatives et décalage nul.

> **FAIT (2026-08-06)** — `RSHIFT` logique corrigé.
> **Code** : interpreter.rs idx 72 : `v.wrapping_shr(n as u32)` →
> `((v as u64).wrapping_shr(n as u32)) as i64` (décalage logique ; compte
> mod 64 conservé, identique au SHR x86 et au JIT). JIT `prim_rshift`
> (via `shr_cl` = SHR) déjà conforme — aucun changement.
> **Vérifié** : `lshift` (décalage gauche) logique par nature — conforme.
> **Tests** : Section B2 réécrite — positifs (`16 2 rshift`=4, `1 4`=0,
> `1 0`=1), négatifs (`-16 2 rshift`=0x3FFFFFFFFFFFFFFC, `-1 63`=1,
> `-2 1`=MAX, `-16 4`=0x0FFFFFFFFFFFFFFF), décalage nul (`-16 0`=-16,
> `123 0`=123), ≥ 64 bits (`-1 64`=-1, `1 65`=1 — mod 64 aligné SHR).
> **Impact scripts** : audio.fth, AMD-Ryzen5-5500U.FTH, fmt.fth n'utilisent
> `rshift` que sur valeurs positives (arithmétique = logique) → aucun
> changement de comportement.
> **Builds** : debug + release OK, 0 erreur, 413 warnings (baseline).
> **Docs** : audit l.20/l.89 résolus, CORE_WORDS.md (table + C5 résolus,
> lshift conforme), API_V1.md (bullet « Conforme Jour 10 », `rshift` retiré
> de la liste non conforme).
> Log détaillé : `logs/planning/week01-day10.txt`.

### Jour 11 — `SEARCH`

- Corriger la sous-chaîne vide.
- Vérifier les effets de pile et le flag standard.

> **FAIT (2026-08-06)** — `SEARCH` corrigé.
> **Code** : interpreter.rs idx 292 : la condition excluait le cas `len2 == 0`
> (sous-chaîne vide → flag 0). Remplacée par `len2 == 0` → toujours trouvée
> (`addr3 = addr1`, `len3 = len1`, flag `-1`), conformément au devguide §4.4
> et à la suite de tests ANS. Les autres branches inchangées ; forme de pile
> `( addr1 len1 addr2 len2 -- addr3 len3 flag )` et flag `-1`/`0` vérifiés.
> **Tests** : Section B3 ajoutée à core2012.fth — trouvée en position 3
> (addr3 = addr1+3 vérifié via variable `S1`), début, fin, multi-occurrences,
> non trouvée (len3 = len1, addr3 = addr1), **sous-chaîne vide `0 0`** (la
> correction), len2 > len1. B3 doit être verte sur matériel (NB-FAILS = 0).
> **Builds** : debug + release OK, 0 erreur, 413 warnings (baseline).
> **Docs** : audit l.27 résolu ; rapport.md P0-3 (items 1-4 et séquence
> coches).
> Log détaillé : `logs/planning/week01-day11.txt`.

### Jour 12 — `REFILL`

- Distinguer ligne vide valide et absence d’entrée.
- Tester clavier, Escape, préemption et fin d’entrée.

> **FAIT (2026-08-06)** — `REFILL` corrigé.
> **Code** : interpreter.rs idx 331 : une ligne vide validée par Entrée
> retombait dans `line.is_empty()` → flag `0` (EOF). Ajout du booléen
> `cancelled` : Escape → `0` (annulation) ; sinon (ligne lue, même vide) →
> `source_buffer = line`, `>IN = 0`, flag `-1` (succès). Préemption et
> `emergency_break` inchangés (`0` = aucune entrée disponible).
> **Tests** : `TESTS/refill.fth` créé — 4 tests interactifs guidés (entrée
> non vide, **ligne vide** — la correction, backspace, Escape) + préemption
> documentée (non déclenchable à la main de façon fiable). NB-FAILS compté
> automatiquement. Le test exige le clavier (naturel pour `REFILL`).
> **Builds** : debug + release OK, 0 erreur, 413 warnings (baseline).
> **Docs** : audit l.41/l.90 résolus, GUIDE.txt (l.695, l.1061-1064),
> primitive md l.778, rapport.md (item 5 + séquence coches).
> Log détaillé : `logs/planning/week01-day12.txt`.

### Jour 13 — `SOURCE` et `>IN`

- Empêcher `SOURCE` de consommer abusivement `HERE`.
- Vérifier que `>IN` reste modifiable.

> **FAIT (2026-08-06)** — `SOURCE` corrigé, `>IN` vérifié modifiable.
> **Code** : `SOURCE` (idx 328) copiait la source dans `memory[HERE..]` et
> avançait `HERE` à **chaque appel**. Ajout du champ `source_addr` + méthode
> `set_source()` : la source est copiée **une seule fois par ligne**
> (compile/refill/evaluate), l'adresse est mémorisée, puis `SOURCE` retourne
> `(source_addr, len)` sans toucher à `HERE`. `compile()` et `refill`
> utilisent désormais `set_source` (qui reset aussi `>IN`).
> **`>IN`** : déjà une adresse mémoire modifiable (`to_in_addr = MAX_MEM-1`),
> lu/écrit par `@`/`!` et par `PARSE-NAME`/`PARSE`. Prouvé par test (avec une
> valeur modeste pour ne pas court-circuiter le tokenizer qui saute les
> tokens dont l'offset < `>IN`).
> **Tests** : Section B4 ajoutée à core2012.fth — `here source 2drop here - .`
> → `0` (SOURCE n'avance plus HERE), `s" src-len" evaluate` → `7` (contenu),
> `>in 5 ! >in @ .` → `5` (modifiable).
> **Builds** : debug + release OK, 0 erreur, 413 warnings (baseline).
> **Docs** : audit l.38/l.42/l.90 résolus, devguide 5.3, primitive md l.775,
> GUIDE.txt, rapport.md (item 10 + liste Semaine 2).
> Log détaillé : `logs/planning/week01-day13.txt`.

### Jour 14 — Revue semaine 2

- Rejouer tous les tests Core.
- Vérifier `BOOT.FTH` et les drivers existants.
- Mettre à jour `forth_audit_2012.md`.

> **FAIT (2026-08-06)** — Revue statique complète (pas d'exécution matérielle possible).
> **Tests Core** : relecture section par section de `core2012.fth` (B0/B1/B2/B2b/
> B2b2/B3/B4) ; toutes les valeurs recalculées sont cohérentes sauf **une
> erreur d'attente corrigée** : `1 65 rshift` attendait `1`, or `wrapping_shr`
> masque le compte mod 64 → `1 >> 1 = 0`. Le cas `-1 64 rshift = -1` était
> correct.
> **BOOT.FTH / drivers** : relu `forth/boot/BOOT.FTH` — aucun usage des mots
> corrigés S2 (comparaisons, `2/`, `rshift`, `search`, `source`, `>in`,
> `refill`) ; `AUTO-EXIT-UEFI if` teste le non-nul, insensible aux flags
> `-1`/`0`. grep sur `forth/` : `source`/`evaluate`/`>in`/`refill` hors
> `TESTS/` uniquement → aucune régression. `rshift` n'est utilisé que sur
> valeurs positives (audio.fth, AMD-Ryzen5-5500U.FTH, fmt.fth).
> **Audit** : section « Revue Semaine 2 » ajoutée ; référence erronée
> « (Jour 14) » pour PARSE/PARSE-NAME/S\" retirée (corrections à faire en S3).
> Log détaillé : `logs/planning/week01-day14.txt`.

**Livrable :** sémantique Core prioritaire corrigée et régressions identifiées.

## 6. Semaine 3 — `STATE`, `FIND` et parsing

**But : rendre le dictionnaire et le parsing utilisables par du code conventionnel.**

### Jour 15 — Analyse de `STATE`

- Définir l’adresse standard de `STATE`.
- Vérifier sa compatibilité avec `@` et `!`.
- Écrire le test avant le changement.

### Jour 16 — Correction de `STATE`

- Implémenter l’adresse modifiable.
- Tester interprétation, compilation et modification indirecte.

### Jour 17 — Analyse de `FIND`

- Documenter le format de chaîne actuel.
- Comparer avec `( c-addr -- c-addr 0 | xt 1 | xt -1 )`.
- Ne pas casser `lookup_word()`.

### Jour 18 — Correction de `FIND`

- Implémenter le contrat retenu.
- Tester mot trouvé, mot absent et mot compilable.

### Jour 19 — `PARSE-NAME`

- Corriger les séparateurs non standards.
- Tester parenthèses, espaces, ligne vide et `>IN`.

### Jour 20 — `PARSE`

- Corriger le traitement du délimiteur initial.
- Tester champs vides et délimiteurs consécutifs.

### Jour 21 — Revue semaine 3

- Rejouer parsing, dictionnaire et tests de boot.
- Documenter toute incompatibilité conservée.

**Livrable :** dictionnaire et parsing suffisamment prévisibles pour la bibliothèque Forth.

## 7. Semaine 4 — Conception mémoire Forth

**But : décider le modèle mémoire avant d’écrire les mots manquants.**

### Jour 22 — Inventaire mémoire

- Lister tous les usages de `self.memory`.
- Lister `here`, `variables`, `string_pool`, `source_buffer`, `to_in_addr`.
- Identifier les usages cellule, octet, MMIO et pointeur natif.

### Jour 23 — Contrat d’adressage

- Choisir l’unité d’adresse Forth.
- Définir `CELL`, `CHAR`, alignement et endianness.
- Écrire les invariants dans `devguide_Forth_Iso_2012.md`.

### Jour 24 — Helpers mémoire

- Ajouter ou concevoir `read_cell` et `write_cell`.
- Ajouter ou concevoir `read_byte` et `write_byte`.
- Ajouter les tests limites sans migrer tous les mots.

### Jour 25 — `HERE`, `ALLOT`, `,`, `C,`

- Corriger leur relation avec l’unité d’adresse choisie.
- Tester alignement, incrément et dépassement.

### Jour 26 — `@`, `!`, `C@`, `C!`

- Faire passer les mots standard par l’espace Forth.
- Interdire l’utilisation implicite du MMIO.

### Jour 27 — `FILL`, `CMOVE`, `MOVE`, `ERASE`

- Migrer vers les helpers mémoire.
- Tester chevauchement, longueur nulle et limites.

### Jour 28 — Revue semaine 4

- Décider si la migration est suffisamment stable pour continuer.
- En cas de régression grave, restaurer la branche et isoler le problème.
- Ne pas ajouter `CREATE`/`DOES>` si l’adressage n’est pas cohérent.

**Livrable :** contrat mémoire et premiers mots mémoire Forth cohérents.

## 8. Semaine 5 — Variables, données et chaînes

**But : permettre aux applications `.fth` de stocker des données de façon fiable.**

### Jour 29 — `VARIABLE`

- Allouer une cellule correctement alignée.
- Ajouter un vrai mot dictionnaire ou un mécanisme équivalent documenté.
- Tester `VARIABLE`, `@`, `!` et plusieurs variables.

### Jour 30 — `CONSTANT` et `VALUE`

- Vérifier les adresses et les valeurs.
- Tester `TO` si déjà présent.

### Jour 31 — `CREATE`

- Définir l’adresse produite et le moment de l’allocation.
- Tester `CREATE` avec données et `ALLOT`.

### Jour 32 — `DOES>`

- Analyser le flux d’exécution actuel.
- Corriger uniquement si un test minimal peut être garanti.
- Sinon documenter le blocage et ne pas introduire de demi-correction.

### Jour 33 — Chaînes compilées

- Vérifier `S"`, `COUNT`, `TYPE` et la durée de vie des chaînes.
- Empêcher une consommation infinie de `HERE` à chaque exécution.

### Jour 34 — `EVALUATE`

- Sauvegarder/restaurer source et `>IN`.
- Tester évaluation imbriquée et erreur de compilation.

### Jour 35 — Revue semaine 5

- Tests mémoire, variables, chaînes et boot.
- Vérification des drivers Forth existants.

**Livrable :** données et chaînes utilisables par des applications Forth.

## 9. Semaine 6 — Mots Core manquants simples

**But compléter le noyau utile sans se disperser.**

### Jour 36 — `BASE` et `ALIGN`

- Implémenter les adresses standard.
- Tester changement de base et alignement.

### Jour 37 — `2@` et `2!`

- Définir l’ordre des cellules.
- Tester valeurs positives, négatives et zéro.

### Jour 38 — `U<` et `S>D`

- Tester les limites signées/non signées.
- Vérifier les flags `-1/0`.

### Jour 39 — `M*` et `*/MOD`

- Utiliser `i128/u128` si compatible avec la cible.
- Tester overflow, signe et diviseur nul.

### Jour 40 — `SIGN` et sortie numérique

- Ajouter `SIGN` et les tests de signe.
- Préparer `<#`, `#`, `#S`, `HOLD`, `#>`.

### Jour 41 — Sortie numérique

- Finaliser le groupe de conversion numérique.
- Tester base 10, base 16, zéro, négatif et double-cellule.

### Jour 42 — Revue semaine 6

- Refaire les builds.
- Comparer l’inventaire avant/après.
- Décider si les mots plus complexes peuvent entrer dans le cycle suivant.

**Livrable :** noyau numérique et mémoire double utilisables.

## 10. Semaine 7 — Entrée et contrôle d’exécution

### Jour 43 — `KEY`

- Brancher `key_queue` proprement.
- Définir comportement bloquant et interruption.

### Jour 44 — `ACCEPT`

- Lire une ligne limitée.
- Gérer entrée vide, backspace, longueur maximale et fin de ligne.

### Jour 45 — `WORD`

- Définir le buffer et la durée de vie.
- Tester séparateurs et entrée vide.

### Jour 46 — `>NUMBER`

- Tester base courante, signe, arrêt sur caractère invalide et overflow.

### Jour 47 — `ABORT`

- Définir l’état des piles, source et sortie après abort.
- Tester un abort contrôlé.

### Jour 48 — `QUIT`

- Définir son effet sur l’interpréteur et le compilateur.
- Ne pas faire un simple `return` sans restauration d’état.

### Jour 49 — Revue semaine 7

- Tests entrée, erreurs et sortie du compilateur.
- Vérifier que le shell reste utilisable.

**Livrable :** boucle d’interprétation/entrée suffisante pour les applications et scripts.

## 11. Semaine 8 — API Driver v1

### Jour 50 — Contrat driver

- Finaliser signatures `drv:probe`, `drv:init`, `drv:stop`, `drv:status`.
- Définir version, dépendances et capacités.

### Jour 51 — Probe non destructif

- Tester matériel présent, absent et inattendu.
- Garantir qu’un probe absent retourne `0` sans crash.

### Jour 52 — API PCI et MMIO

- Documenter accès BAR, PCI, MMIO et permissions.
- Séparer mots ISO et mots matériels.

### Jour 53 — Driver virtio/QEMU

- Écrire un driver de référence minimal ou stabiliser un driver existant.
- Tester sans matériel réel.

### Jour 54 — Driver de stockage ou réseau

- Choisir un seul exemple reproductible.
- Ne pas tenter plusieurs pilotes à la fois.

### Jour 55 — Chargement et erreurs

- Tester fichier absent, syntaxe invalide, dépendance absente et version incompatible.

### Jour 56 — Revue semaine 8

- Figer Driver API v1.
- Publier une fiche d’écriture pour utilisateur distant.

**Livrable :** un tiers peut écrire un driver `.fth` sans connaître Rust.

## 12. Semaine 9 — API Application v1

### Jour 57 — Bibliothèque Core

- Créer ou organiser `forth/std/core.fth`.
- Documenter les mots utilisables sans matériel.

### Jour 58 — Fichiers et chemins

- Documenter l’API fichier et les erreurs.
- Ajouter un exemple d’application qui lit un fichier.

### Jour 59 — Console et sortie

- Documenter entrée/sortie, `TYPE`, `EMIT`, erreurs et codes.
- Ajouter une application texte minimale.

### Jour 60 — Application graphique

- Documenter le fallback GOP et les fonctions graphiques disponibles.
- Ajouter une démo sans GPU natif.

### Jour 61 — Événements

- Documenter clavier, souris optionnelle et temporisation.
- Ajouter une application interactive minimale.

### Jour 62 — Packaging

- Définir structure d’un paquet `.fth`.
- Ajouter métadonnées, version et dépendances.

### Jour 63 — Revue semaine 9

- Tester les exemples sur QEMU.
- Vérifier qu’ils n’utilisent pas de détails internes de la VM.

**Livrable :** une application Forth distante peut être écrite, testée et empaquetée.

## 13. Semaine 10 — Portabilité contrôlée

### Jour 64 — Dépendances x86_64

- Inventorier `x86_64`, `_rdtsc`, `asm!`, CR3, APIC et JIT.
- Marquer les modules non portables.

### Jour 65 — Fallback timing

- Créer une interface de temps abstraite.
- Garder `rdtsc` derrière une implémentation x86_64.

### Jour 66 — Fallback JIT

- Vérifier que l’interpréteur fonctionne sans `jit.rs`.
- Ajouter un mode explicite `--no-jit` ou équivalent si possible.

### Jour 67 — Fallback graphique

- Vérifier que GOP suffit sans i915/amdgpu.
- Tester format RGB, BGR et BitMask.

### Jour 68 — Fallback périphériques

- Tester absence réseau, audio, souris, disque interne et GPU natif.
- Aucun de ces absents ne doit empêcher le shell.

### Jour 69 — AArch64 préparatoire

- Définir les traits ou modules nécessaires.
- Ne pas prétendre compiler entièrement si la chaîne n’est pas prête.

### Jour 70 — Revue semaine 10

- Refaire QEMU x86_64 et builds.
- Documenter les limites de portabilité.

**Livrable :** Forth et applications mieux isolés des détails x86_64.

## 14. Semaine 11 — Qualification et documentation distante

### Jour 71 — Tests propres

- Nettoyer et organiser les tests Core.
- Ajouter les résultats attendus dans chaque fichier.

### Jour 72 — Test agent distant

- Demander à un agent de créer une application `.fth` uniquement avec la documentation.
- Corriger les ambiguïtés documentaires.

### Jour 73 — Test utilisateur distant

- Simuler un utilisateur sans accès au code Rust.
- Vérifier installation, compilation/interprétation et chargement.

### Jour 74 — Test driver distant

- Faire écrire un driver `probe` minimal avec l’API v1.
- Vérifier les erreurs et la documentation.

### Jour 75 — Test compatibilité

- Tester anciennes applications et drivers `.fth`.
- Lister les mots incompatibles ou dépréciés.

### Jour 76 — Documentation finale

- Mettre à jour `README.md`, `DEV_GUIDE_AGENT.md`, `DEV_GUIDE_DRIVERS.md` et `devguide_Forth_Iso_2012.md`.
- Ajouter exemples et conventions de version.

### Jour 77 — Revue semaine 11

- Refaire tous les tests et builds.
- Geler la liste des corrections bloquantes.

**Livrable :** documentation utilisable par un agent et un utilisateur éloignés.

## 15. Semaine 12 — Release candidate

### Jour 78 — Baseline finale

- Build debug/release.
- Tests Core.
- Tests boot.
- Tests applications et drivers.

### Jour 79 — QEMU

- QEMU/OVMF sans réseau.
- QEMU virtio.
- QEMU e1000.
- QEMU avec stockage virtuel.

### Jour 80 — Intel réel

- Boot sur PC Intel.
- Test clé USB, clavier, GOP et shell.
- Journaliser chaque problème.

### Jour 81 — AMD réel

- Boot sur PC AMD.
- Test clé USB, clavier, GOP et shell.
- Vérifier watchdog et runtime.

### Jour 82 — Recovery

- `BOOT.FTH` absent.
- Fichier Forth invalide.
- Driver invalide.
- Périphérique absent.
- Réseau absent.

### Jour 83 — Packaging

- Construire l’arborescence USB.
- Vérifier les fichiers `.fth`, exemples, tests et documentation.
- Générer les sommes de contrôle.

### Jour 84 — Décision finale

- Corriger uniquement les bloqueurs.
- Publier une release candidate si les critères passent.
- Sinon reporter la version et documenter les écarts.

**Livrable :** release candidate Forth x86_64 UEFI utilisable et documentée.

## 16. Règle de dépassement de planning

Si une tâche prend plus de deux séances sans résultat testable :

1. arrêter l’implémentation ;
2. écrire le blocage ;
3. isoler le problème dans un test minimal ;
4. repousser la fonctionnalité ;
5. continuer sur la prochaine tâche indépendante.

Ne jamais sacrifier la stabilité mémoire ou la compatibilité Forth pour respecter artificiellement une date.

## 17. Critères de fin des 12 semaines

Le planning est réussi si :

- les tests Forth Core prioritaires passent ;
- le modèle mémoire utilisé par les mots stabilisés est documenté ;
- `BOOT.FTH` est réellement exécuté ;
- les applications `.fth` fonctionnent sans connaître Rust ;
- un driver `.fth` de référence fonctionne dans QEMU ;
- Driver API v1 et Application API v1 sont figées ;
- le JIT n’est pas obligatoire pour utiliser le système ;
- QEMU, Intel x86_64 et AMD x86_64 sont validés ;
- les builds debug et release passent ;
- les limitations Forth et multi-architecture sont publiées.

La conformité complète Forth 2012 reste un programme ultérieur si les Core Extensions, les jeux optionnels et la suite de tests officielle ne sont pas tous couverts.
