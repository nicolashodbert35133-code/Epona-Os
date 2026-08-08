# Rapport prioritaire — Epona OS et socle Forth ISO 2012

> Plan de travail prioritaire pour l’agent codeur.
> Date : 2026-08-05.
> Références : `forth_audit_2012.md`, `devguide_Forth_Iso_2012.md`, `DEV_GUIDE_AGENT.md`, `DEV_GUIDE_DRIVERS.md`, `DEV_GUIDE_PRIMITIVES.md`, `DEV_GUIDE_MAIN.md` et `DEV_GUIDE_SHELL.md`.

## 1. Décision principale

Le projet contient trop de domaines simultanés : boot UEFI, mémoire, drivers, réseau, shell, GUI, JIT, Forth et multi-architecture.

Pour les 5–6 prochaines semaines, la priorité est unique :

> **Construire un socle Forth ISO 2012 suffisamment stable, documenté et testé pour qu’un agent codeur et un utilisateur situé à distance puissent créer des drivers et applications `.fth` de manière conventionnelle, sans modifier Rust.**

Le shell, le réseau, les GPU natifs, l’audio et la compatibilité de toutes les architectures sont secondaires tant que ce socle n’est pas fiable.

## 2. Objectif utilisateur concret

Un utilisateur distant doit pouvoir :

1. récupérer la documentation publique ;
2. connaître les mots Forth réellement disponibles ;
3. connaître les signatures de pile `( avant -- après )` ;
4. écrire un fichier `.fth` sans connaître `interpreter.rs` ;
5. tester son application ou son driver dans un environnement documenté ;
6. recevoir des erreurs compréhensibles ;
7. charger son fichier sans recompiler le noyau ;
8. savoir si son code utilise le Forth ISO ou une extension Epona ;
9. développer sur une machine distante différente de la machine cible ;
10. disposer d’un contrat d’API stable entre le noyau et les fichiers `.fth`.

L’agent codeur ne doit donc pas commencer par ajouter des fonctionnalités isolées. Il doit d’abord rendre le langage, les adresses, les piles et les contrats d’API prévisibles.

## 3. Périmètre de la release prioritaire

### 3.1 Dans le périmètre P0

- Forth 2012 Core prioritaire ;
- modèle de cellule et d’adresse documenté ;
- espace mémoire Forth cohérent ;
- tests Forth reproductibles ;
- signatures de pile vérifiées ;
- erreurs de pile et d’exécution contrôlées ;
- `BOOT.FTH` exécutable ;
- API driver `.fth` versionnée ;
- API application `.fth` versionnée ;
- documentation pour agent et utilisateur distant ;
- fallback interprété sans JIT obligatoire ;
- validation x86_64 UEFI et QEMU.

### 3.2 Hors périmètre immédiat

À ne pas traiter avant stabilisation du socle Forth :

- ajout de nouvelles commandes shell ;
- nouveaux protocoles réseau ;
- support de toutes les GPU natives ;
- Wi-Fi universel ;
- audio complet ;
- POSIX, ELF, WASM ;
- SMP multi-cœur complet ;
- Ring 0/Ring 3 ;
- RISC-V et BIOS legacy ;
- perfectionnement graphique ;
- nouvelle primitive propriétaire non indispensable à Forth Core ou à l’API driver.

## 4. Priorités de l’agent codeur

### Priorité P0-1 — Geler le contrat Forth

Avant toute modification de `interpreter.rs`, créer une fiche pour chaque mot concerné :

```text
Mot :
Statut : Core / Core Extension / extension Epona
Signature de pile :
Effet mémoire :
Effet de compilation :
Valeur vrai : -1
Valeur faux : 0
Erreur possible :
Test associé :
Compatibilité existante :
```

Les extensions Epona doivent être identifiées séparément des mots normalisés.

Règles obligatoires :

- aucun mot standard avec une signature implicite ;
- aucun vrai Forth retourné par `1` ;
- aucun accès MMIO caché derrière un mot mémoire standard ;
- aucun changement d’indice de primitive sans inventaire ;
- aucun doublon de nom dans le dictionnaire ;
- aucune annonce de conformité globale sans test.

### Priorité P0-2 — Créer la suite de tests Core

Créer :

```text
forth/TESTS/core2012.fth
forth/TESTS/core_memory.fth
forth/TESTS/core_input.fth
forth/TESTS/core_numeric.fth
forth/TESTS/core_dictionary.fth
```

Chaque test doit afficher un résultat déterministe ou utiliser un mécanisme de test commun. Les tests doivent couvrir progressivement :

- piles et arithmétique ;
- flags `-1/0` ;
- `RSHIFT` et `2/` ;
- mémoire cellule/caractère ;
- parsing et `>IN` ;
- `SOURCE`, `REFILL`, `EVALUATE` ;
- dictionnaire et `FIND` ;
- chaînes ;
- sortie numérique ;
- `CREATE`, `VARIABLE`, `DOES>` ;
- exceptions.

Un mot ne doit pas être déclaré stabilisé tant qu’il n’a pas un test positif, un test de limite et un test d’erreur.

### Priorité P0-3 — Corriger les incompatibilités immédiates

Traiter d’abord les corrections locales listées par `forth_audit_2012.md` :

1. flags de comparaison : vrai `-1`, faux `0` ; ✅ (Jour 8)
2. `RSHIFT` logique ; ✅ (Jour 10)
3. `2/` conforme pour les négatifs ; ✅ (Jour 9)
4. `SEARCH` avec sous-chaîne vide ; ✅ (Jour 11)
5. `REFILL` avec ligne vide valide ; ✅ (Jour 12)
6. `STATE` comme adresse modifiable ; ✅ (Jour 16, `MAX_MEM-2`)
7. `FIND` avec contrat standard ; ✅ (Jour 18, chaîne comptée)
 8. `PARSE` sans ignorer abusivement les séparateurs ; ✅ (Jour 20, champs vides + `>IN`/HERE stables)
9. `PARSE-NAME` conforme aux séparateurs ; ✅ (Jour 19, espaces + `>IN` + HERE stable)
10. `SOURCE` sans consommation incorrecte de `HERE`. ✅ (Jour 13)

Emplacements déjà identifiés dans `src/interpreter.rs` :

- `exec_primitive()` : ligne 1469 ;
- comparaisons : lignes 1814–1936 ;
- `2/` : ligne 1884 ;
- `RSHIFT` : lignes 1958–1961 ;
- `STATE` : ligne 2211 (✅ Jour 16 : cellule `MAX_MEM-2`) ;
- `FIND` : ligne 2254 (✅ Jour 18 : chaîne comptée, `(c-addr 0)`/`(xt 1)`/`(xt -1)`) ;
- `SEARCH` : lignes 4481–4514 ;
- `SOURCE`/parsing : lignes 4732–4867.

### Priorité P0-4 — Unifier l’espace mémoire Forth

Le problème le plus important pour les applications et drivers est l’incohérence d’adressage.

État actuel :

- `memory` est un `Vec<i64>` ;
- `@` et `!` adressent des cellules ;
- les chaînes utilisent des éléments comme des octets ;
- `,` et `C,` avancent actuellement de façon ambiguë ;
- `C@`, `C!`, `FILL` et `CMOVE` utilisent des accès MMIO ;
- `byte_mem` existe mais n’est pas l’espace de données Forth principal.

Cible : introduire un espace de données documenté et des helpers uniques :

```text
read_cell(addr) -> cell
write_cell(addr, value)
read_byte(addr) -> u8
write_byte(addr, value)
read_u16(addr) -> u16
write_u16(addr, value)
```

Puis faire passer par ce modèle :

```text
@ ! C@ C! W@ W! L@ L!
HERE ALLOT , C,
FILL CMOVE MOVE ERASE
VARIABLE CREATE CONSTANT VALUE
```

Ne pas corriger seulement `C@`/`C!` en laissant `HERE`, `,` et `VARIABLE` dans l’ancien modèle. Une migration partielle créerait une VM encore moins prévisible.

### Priorité P0-5 — Ajouter les mots Core manquants

Après stabilisation mémoire, ajouter par groupes testés :

```text
BASE ALIGN 2@ 2!
U< S>D M* */MOD
SIGN <# # #S HOLD #>
KEY ACCEPT WORD >NUMBER
ABORT QUIT ENVIRONMENT?
```

Les mots doivent recevoir une signature et une fiche avant ajout. Les primitives standard peuvent utiliser une plage d’indices dédiée libre après vérification des doublons.

### Priorité P0-6 — Stabiliser le compilateur

Les applications et drivers distants ont besoin d’un compilateur prévisible.

À vérifier :

- compilation/interprétation de `:` et `;` ;
- mots immédiats ;
- `IF ELSE THEN` ;
- `BEGIN UNTIL AGAIN WHILE REPEAT` ;
- `DO LOOP +LOOP LEAVE` ;
- `CREATE DOES>` ;
- `VARIABLE`, `CONSTANT`, `VALUE`, `TO` ;
- `EXECUTE`, `'`, `FIND`, `LITERAL`, `POSTPONE` ;
- gestion des erreurs de compilation ;
- restauration de l’état après erreur.

Ne pas ajouter de nouvelles structures de contrôle propriétaires si les structures Core équivalentes ne sont pas testées.

## 5. Contrat API pour les drivers `.fth`

### 5.1 Versionnement

Créer un contrat `Driver API v1` clairement séparé du Forth ISO.

Un driver doit déclarer :

```text
Nom
Version
Auteur
Licence
Vendor ID / Device ID
Classe PCI éventuelle
Dépendances
Mot de probe
Mot d’initialisation
Mot d’arrêt
Capacités exposées
```

Exemple de cycle de vie :

```text
drv:probe   ( pci-address -- flag )
drv:init    ( pci-address -- flag )
drv:stop    ( -- )
drv:status  ( -- flag )
```

Les noms exacts doivent être arrêtés dans un document d’API et ne plus changer sans version majeure.

### 5.2 Séparation standard/propriétaire

Un fichier driver peut utiliser :

- le sous-ensemble Forth ISO documenté ;
- l’API Driver v1 ;
- les extensions matérielles explicitement marquées `epona-*` ou `drv:*`.

Il ne doit pas supposer que `@`, `!`, `C@` ou `C!` donnent accès à du MMIO. Les accès matériel doivent passer par l’API driver dédiée :

```text
mmio@ / mmio!
pci@
pci!
inb / outb
irq:attach
mem:alloc
```

Les accès dangereux doivent être refusés ou signalés en `secure_mode`.

### 5.3 Compatibilité distante

Un utilisateur à l’autre bout du monde doit pouvoir développer un driver sans disposer du même PC. Pour cela :

- fournir des drivers génériques virtio et QEMU ;
- fournir une simulation ou un mode `probe-only` ;
- documenter les valeurs attendues et les erreurs ;
- tester `drv:probe` sur matériel absent ;
- garantir que l’absence de matériel retourne `0` sans crash ;
- ne jamais demander au driver de dépendre d’une adresse physique fixe ;
- utiliser les IDs PCI, BAR et capacités fournies par l’API.

## 6. Contrat API pour les applications `.fth`

Créer une bibliothèque standard ouverte, séparée du noyau :

```text
forth/std/core.fth
forth/std/strings.fth
forth/std/files.fth
forth/std/graphics.fth
forth/std/drivers.fth
forth/std/testing.fth
```

Une application doit pouvoir utiliser :

- entrée/sortie standard ;
- fichiers ;
- chaînes ;
- temporisation ;
- mémoire allouée ;
- affichage GOP/GUI via API documentée ;
- événements clavier/souris ;
- codes d’erreur ;
- version de l’API.

Les applications ne doivent pas appeler directement des détails de `interpreter.rs`.

## 7. Plan sur 6 semaines centré Forth

### Semaine 1 — Contrat, baseline et tests

- geler les index et noms existants ;
- faire les builds debug/release ;
- inventorier les mots disponibles ;
- créer les tests Core ;
- corriger l’exécution réelle de `BOOT.FTH` ;
- définir `Driver API v1` et `Application API v1` ;
- produire une première table des signatures de pile.

**Livrable :** un agent distant sait quels mots il peut utiliser et comment lancer un test.

### Semaine 2 — Core sémantique

- flags `-1/0` ✅ (J8) ;
- `RSHIFT` ✅ (J10) ;
- `2/` ✅ (J9) ;
- `SEARCH` ✅ (J11) ;
- `REFILL` ✅ (J12) ;
- `STATE` ✅ (J16) ;
- `FIND` ✅ (J18) ;
- `SOURCE` ✅ (J13), `PARSE` ✅ (J20), `PARSE-NAME` ✅ (J19) ;
- revue S3 (J21) : modèle source = fichier complet + `>IN` global documenté ; tests de parsing en source contrôlée (`evaluate`).
- tests de régression.

**Livrable :** comportement de base cohérent et documenté.

### Semaine 3 — Mémoire Forth

- J22 : inventaire mémoire (278 usages classés ; `c@..cmove` = MMIO natif, pas `memory` ; 9 ambiguïtés structurelles listées) ;
- J23 : contrat d'adressage (1 cellule = 1 unité ; `cell`/`char`=1 ; `cells`/`aligned`/`cell+` corrigés) ;
- J24 : helpers mémoire `read_cell`/`write_cell`/`read_byte`/`write_byte` + `@`/`!`/`+!` migrés + tests bornes (B10) ;
- J25 : bornage `MAX_MEM` de `here`/`allot`/`,`/`c,`/`create` (fini le wrap 64 bits/OOM sur `allot` négatif) + tests B11 ;
- J26 : fenêtre mémoire (validée) — `c@`/`c!`/`w@`/`w!`/`l@`/`l!`/`fill`/`cmove` sur `memory` si < 4096, MMIO natif au-delà (buffers des apps cohérents avec `@`/`!`) + tests B12 ;
- J27 : `move`/`erase` migrés en fenêtre (u cellules, chevauchement géré, clamp MAX_MEM) + tests B13 ;
- J28 : revue S4 — `MAX_MEM` 4096→65536 (la source stockée à 1 octet/cellule dépassait 4096 → bornages J25-J27 inopérants), `alloc` réparé (réserve depuis `here`) + tests B14 ;
- J29 : `variable` alloue dans `HERE` (init 0, borné MAX_MEM) + mot dictionnaire (visible de `'`/`FIND`), map conservée en cache compat + tests B15 ;
- J30 : `value` compilé ajouté (`Op::ValueCreate`, borné MAX_MEM) — avant tout `value` en définition échouait ; `value` interprété borné ; sérialisation JIT + `forget` complétés + tests B16 ;
 - J31 : `create` ne réserve plus (standard, `data_addr = here` comme `buffer:`) ; body `does>` inséré avant l'`Exit` final (avant : ajouté après → inatteignable) + tests B17 ;
 - J33 : `S"` compilé copie la chaîne une fois à la compilation (`Op::PushStrAddr` pousse `(addr,len)` sans avancer HERE) — avant, recopie à chaque exécution (consommation infinie en boucle) + tests B18 ;
- décider et implémenter l’espace de données ;
- helpers d’accès cellule/octets ;
- `@`, `!`, `C@`, `C!`, `HERE`, `ALLOT`, `,`, `C,` ;
- `FILL`, `CMOVE`, `MOVE`, `ERASE` ;
- `VARIABLE`, `CREATE` ;
- tests mémoire et limites.

**Livrable :** les buffers Forth ont des adresses et unités cohérentes.

### Semaine 4 — Core manquant et compilateur

- `2@`, `2!`, `ALIGN`, `BASE`, `U<` ;
- arithmétique double ;
- sortie numérique ;
- `KEY`, `ACCEPT`, `WORD`, `>NUMBER` ;
- `ABORT`, `QUIT` ;
- contrôle de compilation et erreurs ;
- début des Core Extensions seulement si le Core est stable.

**Livrable :** bibliothèque Forth de base exploitable par des applications.

### Semaine 5 — API drivers/applications et exemples

- figer Driver API v1 ;
- figer Application API v1 ;
- écrire un driver virtio ou QEMU de référence ;
- écrire une application Forth de référence ;
- écrire un driver matériel générique avec `probe` non destructif ;
- ajouter tests hors matériel ;
- documenter chargement, erreurs et permissions.

**Livrable :** un utilisateur distant peut développer, tester et charger un `.fth`.

### Semaine 6 — Qualification et compatibilité

- QEMU/OVMF x86_64 ;
- PC Intel x86_64 ;
- PC AMD x86_64 ;
- mode sans réseau ;
- mode sans disque interne ;
- mode sans GPU natif avec GOP ;
- test de drivers absents ou invalides ;
- test d’applications `.fth` ;
- documentation finale et release candidate.

**Livrable :** un socle Forth documenté et utilisable sur x86_64 UEFI, avec limites clairement publiées.

## 8. Architecture et portabilité

La priorité n’est pas de rendre immédiatement tout le noyau compatible avec toutes les architectures. La priorité est de rendre la **VM Forth, les tests et les fichiers `.fth` aussi indépendants de l’architecture que possible**.

### Cible production

- Intel x86_64 UEFI ;
- AMD x86_64 UEFI ;
- QEMU/OVMF x86_64 ;
- GOP UEFI ;
- FAT32 USB ;
- interpréteur Forth sans JIT obligatoire.

### Cible expérimentale

AArch64 UEFI pourra être étudié après séparation :

- des instructions x86 ;
- des registres CR/APIC ;
- de `rdtsc` ;
- du contexte de tâche ;
- du JIT x86_64 ;
- des accès PCI/interruptions spécifiques.

RISC-V, BIOS legacy et support universel de tous les périphériques sont reportés.

## 9. Ce que l’agent codeur doit faire demain

Ordre obligatoire :

1. lire `devguide_Forth_Iso_2012.md` ;
2. lire `forth_audit_2012.md` ;
3. produire une fiche pour la phase choisie ;
4. lancer les builds baseline ;
5. modifier un seul groupe de mots ;
6. ajouter les tests correspondants ;
7. vérifier `BOOT.FTH` et les tests existants ;
8. relancer debug et release ;
9. mettre à jour l’audit ;
10. arrêter si le modèle mémoire doit être changé sans fiche dédiée.

La première tâche recommandée est :

```text
Flags -1/0 ✅ (J8) → RSHIFT ✅ (J10) → 2/ ✅ (J9) → SEARCH ✅ (J11) → REFILL ✅ (J12)
```

Ne pas commencer par le réseau, le shell, le GPU ou le multi-architecture.

## 10. Critères de réussite

Le socle Forth sera considéré prêt pour les développeurs distants lorsque :

- les mots documentés ont une signature vérifiée ;
- les flags suivent `-1/0` ;
- les adresses et cellules ont une unité explicite ;
- les buffers Forth ne sont pas du MMIO par accident ;
- les erreurs de pile sont détectables ;
- les tests Core passent ;
- `BOOT.FTH` est réellement exécuté ;
- un driver `.fth` générique peut être écrit sans Rust ;
- une application `.fth` peut être écrite sans connaître les détails internes ;
- l’API driver et l’API application sont versionnées ;
- le mode interprété fonctionne sans JIT ;
- QEMU, Intel x86_64 et AMD x86_64 sont testés ;
- les limitations sont publiées honnêtement.

## 11. Verdict

La priorité d’Epona OS n’est pas d’ajouter encore des fonctionnalités. C’est de construire une **plateforme Forth fiable et conventionnelle**.

Une VM Forth conforme, des signatures stables, une mémoire cohérente, une API driver versionnée et des tests reproductibles permettront ensuite à des agents et utilisateurs distants de créer des applications et des drivers `.fth` sans toucher aux 13 000 lignes de `interpreter.rs`.

La compatibilité matérielle universelle viendra ensuite par les fallbacks et les drivers. Elle ne doit pas retarder la stabilisation du langage et de son contrat développeur.
