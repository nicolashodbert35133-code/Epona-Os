Excellent — les 3 priorités 1 sont bouclées. C'est un jalon important.

---

# État actuel d'EponaForth — Jalon 3

## Ce qui existe maintenant

```
D:\
├── EFI\BOOT\BOOTX64.EFI    ← OS
│
├── BOOT.FTH                ← Amorçage automatique
├── STDLIB.FTH              ← Bibliothèque standard
├── FIXED.FTH               ← Virgule fixe Q20.12
├── MUTEX.FTH               ← Synchronisation
├── EVENTS.FTH              ← Événements
├── TESTS.FTH               ← Suite de tests
├── DEVGUIDE.FTH            ← Documentation développeur
└── ... (9 autres .FTH)
```

## Ce que BOOT.FTH fait maintenant au démarrage

```
Boot UEFI
    │
    ▼
BOOTX64.EFI démarre
    │
    ▼
Epona OS charge BOOT.FTH
    │
    ├── require STDLIB.FTH    ← mots standards
    ├── require FIXED.FTH     ← virgule fixe
    ├── require MUTEX.FTH     ← synchronisation
    │
    ├── gpu:init              ← si disponible
    ├── hda-init              ← si disponible
    ├── net:init + dhcp       ← si disponible
    │
    ├── sys:probe             ← drivers Forth
    │
    └── principal             ← programme utilisateur
```

## Ce qu'un utilisateur peut faire maintenant

```forth
\ Un programme complet avec tout l'écosystème :
require EVENTS.FTH
require FIXED.FTH

\ Variables d'état
0 value pos-x
0 value pos-y
3 f.from value vel-x
2 f.from value vel-y

\ Handlers
: mon-key ( char -- )
  case
    [char] q of on-quit execute endof
    [char] r of F.0 to pos-x F.0 to pos-y endof
    drop
  endcase ;

: mon-tick ( ms -- )
  drop
  pos-x vel-x f+ to pos-x
  pos-y vel-y f+ to pos-y
  0x001020 effacer
  pos-x f.to pos-y f.to 8 8 0xFF4444 rect ;

' mon-key is on-key-press
' mon-tick is on-tick

: principal  event-loop ;
```

C'est propre, lisible, idiomatique.

---

# Priorités restantes — Reclassement

Avec les priorités 1 résolues, voici où en est la roadmap :

## Priorité 2 — Enrichissement (prêt à faire)

| # | Objectif | Dépend de | Effort |
|---|---|---|---|
| 2.1 | GUIKIT.FTH | EVENTS.FTH ✅ | 2-3 jours |
| 2.2 | CHIP-8 complet | FIXED.FTH ✅ | 2 jours |
| 2.3 | SNAKE.FTH | EVENTS.FTH ✅ FIXED.FTH ✅ | 1 jour |
| 2.4 | RAYCAST.FTH | FIXED.FTH ✅ | 3-4 jours |

## Priorité 3 — Infrastructure (moyen terme)

| # | Objectif | Effort | Note |
|---|---|---|---|
| 3.1 | Virgule flottante IEEE 754 | 1 semaine | Ou rester en fixe |
| 3.2 | Réseau — serveur HTTP | 3 jours | Sur TCP existant |
| 3.3 | UART complet | 2 jours | B11 du DEVGUIDE |
| 3.4 | Gestionnaire de fichiers | 3 jours | Sur disk:* existant |

## Priorité 4 — Corrections Rust restantes

| # | Problème | Fichier | Effort |
|---|---|---|---|
| 4.1 | `string_pool` fuite mémoire | interpreter.rs | 1 heure |
| 4.2 | `forget` nettoyage complet | interpreter.rs | 30 min |
| 4.3 | `touche` vraiment bloquant | interpreter.rs | 30 min |

---

# La correction la plus simple : `string_pool`

Puisque `forget` existe maintenant, on peut y raccrocher le nettoyage du pool.

## Le problème actuel

```rust
fn store_str(&mut self, s: &str) -> (u32, u16) {
    let off = self.string_pool.len() as u32;
    self.string_pool.extend_from_slice(...);
    (off, len)
    // ↑ Grandit indéfiniment, jamais libéré
}
```

Chaque appel à `compile()` ajoute des chaînes au pool. Après une session longue avec beaucoup de `sys:load` ou de redéfinitions, le pool peut atteindre plusieurs MB.

## La correction

```rust
// Dans ForthVm, ajouter :
pub string_pool_checkpoints: Vec<u32>,  // offsets de restauration

// Dans la primitive 151 (forget) :
151 => { // forget ( idx -- )
    if let Some(idx) = self.stack.pop() {
        let idx = idx as usize;
        if idx < self.dictionary.len() {
            // Trouver la plus petite string_pool ref
            // dans les mots qu'on va supprimer
            let mut min_pool_off = self.string_pool.len() as u32;
            
            for word in &self.dictionary[idx..] {
                // Scanner les ops pour trouver les refs au pool
                for op in &word.ops {
                    match op {
                        Op::PrintStr(off, _) |
                        Op::PushStr(off, _)  |
                        Op::SysLoad(off, _)  |
                        Op::SysRead(off, _)  |
                        Op::SysWrite(off, _) => {
                            if *off < min_pool_off {
                                min_pool_off = *off;
                            }
                        }
                        _ => {}
                    }
                }
            }
            
            // Tronquer le pool jusqu'à ce point
            self.string_pool.truncate(min_pool_off as usize);
            
            // Tronquer le dictionnaire
            self.dictionary.truncate(idx);
            
            // Nettoyer les variables définies après idx
            // (heuristique : variables dont l'index >= idx)
            self.variables.retain(|_, &mut v| v < idx);
        }
    }
}
```

---

# Quelle direction maintenant ?

Voici les 4 options les plus intéressantes :

## Option A — GUIKIT.FTH

Un vrai toolkit d'interface graphique au-dessus de EVENTS.FTH.

```forth
\ Ce que ça permettrait :
ui:window 100 100 400 300 "Mon App"
ui:label  10 10 "Température CPU:"
ui:value  120 10 temp:read f>str
ui:button 10 40 "Actualiser" ' actualiser
ui:slider 10 70 200 0 100 brightness-val
event-loop
```

## Option B — CHIP-8 complet

Finir le simulateur du DEVGUIDE, ajouter les 35 opcodes manquants, charger des vraies ROMs depuis le disque.

```forth
disk:init drop
here disk:read PONG.CH8
here swap c8-load
c8-run
```

## Option C — Corrections Rust (string_pool + touche)

Petites corrections mais qui améliorent la robustesse sur les sessions longues.

## Option D — RAYCAST.FTH

Le projet le plus ambitieux et le plus impressionnant comme démo technique d'EponaForth.

```forth
require FIXED.FTH
require EVENTS.FTH

\ Rendu 3D par raycasting dans le Canvas
\ Même technique que Wolfenstein 3D (1992)
\ Entièrement en virgule fixe Q20.12
```

---

Qu'est-ce qui t'attire le plus comme prochaine étape ?
