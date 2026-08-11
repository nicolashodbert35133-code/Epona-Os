# Epona OS — Fiche d'écriture d'un driver (utilisateur distant)

Contrat : **Driver API v1 — GELÉE** (`docs/API_V1.md`, Jour 55, 2026-08-11).
Cette fiche permet d'écrire un driver `.fth` **sans connaître Rust**.

## 1. Structure minimale d'un driver

```forth
s" mon-driver" drv:name!
0 1 0 drv:version!          \ maj min patch
s" MIT" drv:license!
s" Description courte" drv:desc!
0 drv:type!                 \ 0 Generic 1 Network 2 Audio 3 Storage 4 Input 5 Usb 6 Gpu

pci:add-id 0xVVVV 0xDDDD    \ vendor:device supportés (optionnel)

: drv:probe ( bar bus dev func -- ok? )  \ test rapide (optionnel)
  bar 0= if 0 else -1 then ;
: drv:init  ( bar bus dev func -- ok? )  \ init complète (recommandé)
  ... -1 ;                               \ -1 = OK, 0 = échec
: drv:fini  ( -- ) ... ;                 \ arrêt propre (optionnel)

drv:register               \ OBLIGATOIRE en fin de fichier
```

## 2. Règles d'or

1. **`drv:register` en dernier** — obligatoire, sinon le driver n'est pas chargé.
2. **Retour** : `-1` (vrai) = succès, `0` = échec. Jamais de `exit` dans un mot
   avec `{ locals }` (`Op::Exit` ne nettoie pas les locals).
3. **Mémoire persistante** : uniquement `create <nom> <n> allot` (espace
   `here`). **Ne pas** mélanger `variable` et `create` (chevauchement).
4. **Pas de `TRUE`/`FALSE`** : ces constantes n'existent pas, utiliser `-1`/`0`.
5. **BAR** : reçue en argument de `drv:init`/`drv:probe` — pas d'adresse fixe.
6. **Erreur** : jamais de crash — `s" ..." drv:err` puis `0`.
7. **Handler d'IRQ** : court, pas de `type`, pas d'allocation.

## 3. Mots disponibles (bas niveau, §2.6 du contrat)

- **MMIO** : `mmio@ ( addr -- val )`, `mmio!`, `mmio-w@/w!`, `mmio-b@/b!`.
- **Physique** : `phys@ ( addr -- val64 )`, `phys!`.
- **Port I/O** : `inb/outb/inw/outw/inl/outl`.
- **PCI config** : `pci@`, `pci!` ; `pci:list ( -- count )`, `pci:dev`,
  `pci:bar ( bus dev fn n -- addr size )`.
- **Mémoire** : `alloc`, `alloc-page`, `alloc-phys`, `mem:alloc-pages`.
- **Temps** : `ticks`, `attendre ( ms -- )`, `us-delay`, `ms-delay`.
- **Logging** : `drv:log`, `drv:warn`, `drv:err`, `drv:ok`.
- **État** : `drv:loaded? ( a l -- idx )`, `dev:register`.
- **Cycle de vie** : `drv:status ( -- id type etat )`, `drv:stop ( -- )`.

## 4. Exemple réel — `forth/drivers/TEMPLATE.fth`

Le fichier `forth/drivers/TEMPLATE.fth` est un driver fonctionnel prêt à copier
(en-tête boxé, métadonnées, `drv:probe`/`drv:init`/`drv:fini`, `drv:register`).
Guide détaillé : `docs/DEV_GUIDE_DRIVERS.md` §7 et
`docs/DEV_GUIDE_DRIVER_AGENT.md`.
