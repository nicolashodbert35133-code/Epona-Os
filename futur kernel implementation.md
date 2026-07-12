

# Roadmap Langage EponaForth — Les 20 mots à ajouter

Classés par **ordre d'implémentation** : chaque mot débloque les suivants.

---

## Phase 1 — Fondations manquantes (les plus urgents)

### 1. `see`

**Pourquoi en premier :** c'est l'outil de diagnostic #1 pour les utilisateurs. Sans `see`, on ne peut pas comprendre comment un mot est compilé, ni déboguer les problèmes de compilation.

```forth
\ Utilisation :
see carre
\ Affiche :
\ : carre
\   [0] Push(0) — VariableAddr ou dup
\   [1] CallPrim(5) — dup
\   [2] CallPrim(2) — *
\   [3] Exit
\ ;

\ Implémentation dans compile(), mode immédiat :
"see" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant apres see"); }
    let name = tokens[i];
    if let Some(dict_idx) = self.dictionary.iter().position(
        |w| Self::word_name_eq(&w.name, name))
    {
        let w = &self.dictionary[dict_idx];
        use core::fmt::Write;
        if w.is_primitive {
            let _ = write!(&mut self.print_buffer,
                "{} est une primitive (idx={})\n",
                name, w.prim_idx);
        } else {
            let _ = write!(&mut self.print_buffer,
                ": {} \\ {} ops\n", name, w.ops.len());
            for (oi, op) in w.ops.iter().enumerate() {
                let _ = write!(&mut self.print_buffer,
                    "  [{:3}] {:?}\n", oi, op);
            }
            let _ = write!(&mut self.print_buffer, ";\n");
            if w.immediate {
                let _ = write!(&mut self.print_buffer,
                    "  (immediate)\n");
            }
            if w.is_defining {
                let _ = write!(&mut self.print_buffer,
                    "  (defining, does> {} ops)\n",
                    w.does_ops.len());
            }
        }
    } else {
        eerr!(i, "Mot inconnu : {}", name);
    }
}
```

**Difficulté :** faible — lecture seule du dictionnaire.

---

### 2. `value` / `to`

**Pourquoi :** les variables Forth classiques sont lourdes (`variable x  0 x !  x @`). `value` est le pattern le plus utilisé en Forth moderne.

```forth
\ Utilisation :
10 value largeur
largeur .          \ → 10
20 to largeur
largeur .          \ → 20

\ Comportement :
\ value crée un mot qui empile sa valeur (comme constant)
\ to modifie la valeur stockée

\ Implémentation :
\ value = constant mais avec modification possible
\ Stocke la valeur dans memory[here] au lieu de dans l'Op
```

```rust
// Nouveau Op :
Op::ValueAddr(usize),  // adresse en mémoire de la valeur

// Dans compile(), mode immédiat :
"value" => {
    if let Some(val) = self.stack.pop() {
        i += 1;
        if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
        let vname = tokens[i].to_lowercase();
        let addr = self.here;
        self.here += 1;
        if self.here > self.memory.len() {
            self.memory.resize(self.here + 16, 0);
        }
        self.memory[addr] = val;
        self.dictionary.push(Word {
            name: Self::encode_name(&vname),
            is_primitive: false, prim_idx: 0,
            // Empile la valeur a l'adresse
            ops: vec![Op::ValueAddr(addr)],
            immediate: false, create_data: addr,
            is_defining: false, does_ops: vec![],
        });
    }
}

// Dans execute_ops_limited :
Op::ValueAddr(addr) => {
    if *addr < self.memory.len() {
        self.stack.push(self.memory[*addr]);
    }
    ip += 1;
}

// "to" en mode immédiat :
"to" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    if let Some(dict_idx) = self.dictionary.iter().position(
        |w| Self::word_name_eq(&w.name, tokens[i]))
    {
        let addr = self.dictionary[dict_idx].create_data;
        if let Some(val) = self.stack.pop() {
            if addr < self.memory.len() {
                self.memory[addr] = val;
            }
        }
    }
}

// "to" en mode compilation :
"to" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    if let Some(dict_idx) = self.dictionary.iter().position(
        |w| Self::word_name_eq(&w.name, tokens[i]))
    {
        let addr = self.dictionary[dict_idx].create_data;
        // Compile : Pop → store dans memory[addr]
        self.compiling_ops.push(Op::ToValue(addr));
    }
}

// Nouveau Op :
Op::ToValue(usize),

// Dans execute_ops_limited :
Op::ToValue(addr) => {
    if let Some(val) = self.stack.pop() {
        if *addr < self.memory.len() {
            self.memory[*addr] = val;
        }
    }
    ip += 1;
}
```

**Difficulté :** moyenne — 2 nouveaux Op, gestion compilation + immédiat.

---

### 3. `defer` / `is`

**Pourquoi :** indispensable pour les callbacks, hooks, drivers. C'est le mécanisme de polymorphisme de Forth.

```forth
\ Utilisation :
defer afficheur
: aff-default  ." default" ;
' aff-default is afficheur
afficheur              \ → "default"

: aff-custom  ." custom" ;
' aff-custom is afficheur
afficheur              \ → "custom"

\ Parfait pour :
\   - hooks d'événements UI
\   - drivers avec init/probe/read/write
\   - callbacks réseau
\   - personnalisation du boot
```

```rust
// Implémentation :
// defer crée un mot avec ops = [Op::CallDeferred(addr)]
// L'adresse pointe vers un slot en mémoire qui contient
// l'index du mot à appeler (ou -1 si non assigné)

// Nouveau Op :
Op::CallDeferred(usize),  // addr dans memory[]

// Dans compile(), mode immédiat :
"defer" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    let dname = tokens[i].to_lowercase();
    let addr = self.here;
    self.here += 1;
    if self.here > self.memory.len() {
        self.memory.resize(self.here + 16, 0);
    }
    self.memory[addr] = -1; // non assigné
    self.dictionary.push(Word {
        name: Self::encode_name(&dname),
        is_primitive: false, prim_idx: 0,
        ops: vec![Op::CallDeferred(addr)],
        immediate: false, create_data: addr,
        is_defining: false, does_ops: vec![],
    });
}

// "is" : assigne un xt (index dictionnaire) au defer
"is" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    if let Some(dict_idx) = self.dictionary.iter().position(
        |w| Self::word_name_eq(&w.name, tokens[i]))
    {
        let addr = self.dictionary[dict_idx].create_data;
        if let Some(xt) = self.stack.pop() {
            if addr < self.memory.len() {
                self.memory[addr] = xt;
            }
        }
    }
}

// Dans execute_ops_limited :
Op::CallDeferred(addr) => {
    let xt = self.memory[*addr];
    if xt >= 0 && (xt as usize) < self.dictionary.len() {
        let idx = xt as usize;
        if self.dictionary[idx].is_primitive {
            self.exec_primitive(self.dictionary[idx].prim_idx);
        } else {
            call_stack.push(CallFrame { ... });
            current_ops = ...;
            ip = 0;
            continue;
        }
    } else {
        use core::fmt::Write;
        let _ = write!(&mut self.print_buffer,
            "defer non assigne\n");
    }
    ip += 1;
}
```

**Difficulté :** moyenne — 1 nouveau Op, gestion `is` en immédiat + compilé.

---

### 4. `case` / `of` / `endof` / `endcase`

**Pourquoi :** rend le code lisible pour les menus, parseurs de protocoles, state machines.

```forth
\ Utilisation :
: traiter ( code -- )
  case
    1 of ." un"     endof
    2 of ." deux"   endof
    3 of ." trois"  endof
    dup ." autre: " .
  endcase ;

3 traiter   \ → "trois"
99 traiter  \ → "autre: 99"
```

```rust
// Implémentation purement au compilateur (pas de nouveau Op)
// case  → empile un marqueur sur compiling_stack
// of    → compile : over = JumpIfZero(endof) drop
// endof → compile : Jump(endcase) + patch JumpIfZero
// endcase → compile : drop + patch tous les Jump(endcase)

// Dans compile(), mode compilation :
"case" => {
    // Marqueur type=7, pas de placeholder
    self.compiling_stack.push((7, 0, 0));
}
"of" => {
    // Compile : over = if(drop) else(jump to endof)
    self.compiling_ops.push(Op::CallPrim(8));   // over
    self.compiling_ops.push(Op::CallPrim(37));  // =
    let jmp_idx = self.compiling_ops.len();
    self.compiling_ops.push(Op::JumpIfZero(0)); // → endof
    self.compiling_ops.push(Op::CallPrim(6));   // drop
    // Empile (8, jmp_idx) pour le of courant
    self.compiling_stack.push((8, jmp_idx, 0));
}
"endof" => {
    if let Some((8, of_jmp, _)) = self.compiling_stack.pop() {
        // Jump vers endcase (sera patché)
        let endof_jmp = self.compiling_ops.len();
        self.compiling_ops.push(Op::Jump(0));
        // Patch le JumpIfZero du of
        self.compiling_ops[of_jmp] =
            Op::JumpIfZero(self.compiling_ops.len());
        // Empile (9, endof_jmp) pour patch par endcase
        self.compiling_stack.push((9, endof_jmp, 0));
    } else {
        eerr!(i, "ENDOF sans OF");
    }
}
"endcase" => {
    // drop la valeur testée
    self.compiling_ops.push(Op::CallPrim(6));  // drop
    let end_idx = self.compiling_ops.len();
    // Patch tous les endof jumps + le case marker
    loop {
        match self.compiling_stack.pop() {
            Some((9, jmp_idx, _)) => {
                self.compiling_ops[jmp_idx] = Op::Jump(end_idx);
            }
            Some((7, _, _)) => break, // case marker
            _ => { eerr!(i, "ENDCASE sans CASE"); }
        }
    }
}
```

**Difficulté :** moyenne — zéro nouveau Op, logique compilateur uniquement.

---

### 5. `[char]` et `char`

**Pourquoi :** manipuler des caractères sans connaître leur code ASCII.

```forth
\ Utilisation :
char A .          \ → 65
[char] A emit     \ dans une définition : émet 'A'

\ Implémentation :
// Mode immédiat :
"char" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Caractere manquant"); }
    let ch = tokens[i].as_bytes()[0];
    self.stack.push(ch as i64);
}

// Mode compilation :
"[char]" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Caractere manquant"); }
    let ch = tokens[i].as_bytes()[0];
    self.compiling_ops.push(Op::Push(ch as i64));
}
```

**Difficulté :** triviale.

---

## Phase 2 — Confort développeur

### 6. `."` avec `\n` (séquences d'échappement)

**Pourquoi :** actuellement impossible d'avoir un retour à la ligne dans une chaîne.

```forth
\ Utilisation :
." Ligne 1\nLigne 2\n"
\ Affiche :
\ Ligne 1
\ Ligne 2
```

```rust
// Dans le parsing de ." et s" :
// Après avoir collecté le texte, remplacer les séquences :
let text = text
    .replace("\\n", "\n")
    .replace("\\t", "\t")
    .replace("\\\\", "\\")
    .replace("\\\"", "\"");
```

**Difficulté :** triviale.

---

### 7. `abort"` 

**Pourquoi :** arrêt conditionnel avec message d'erreur. Indispensable pour les drivers.

```forth
\ Utilisation :
: check-port ( port -- )
  dup 0 < abort" Port invalide !"
  dup 65535 > abort" Port trop grand !"
  drop ;

\ Syntaxe : flag abort" message"
\ Si flag est vrai → affiche le message et arrête l'exécution
```

```rust
// Mode compilation :
"abort\"" => {
    i += 1;
    let mut text = String::new();
    while i < tokens.len() {
        if tokens[i].ends_with('"') {
            let t = &tokens[i][..tokens[i].len()-1];
            if !text.is_empty() { text.push(' '); }
            text.push_str(t);
            break;
        }
        if !text.is_empty() { text.push(' '); }
        text.push_str(tokens[i]);
        i += 1;
    }
    let (off, len) = self.store_str(&text);
    self.compiling_ops.push(Op::AbortQuote(off, len));
}

// Nouveau Op :
Op::AbortQuote(u32, u16),

// Dans execute_ops_limited :
Op::AbortQuote(off, len) => {
    if let Some(flag) = self.stack.pop() {
        if flag != 0 {
            let msg = self.get_str(*off, *len).to_string();
            use core::fmt::Write;
            let _ = write!(&mut self.print_buffer,
                "ABORT: {}\n", msg);
            return Err("abort");
        }
    }
    ip += 1;
}
```

**Difficulté :** faible.

---

### 8. `include` / `require`

**Pourquoi :** éviter les doublons de chargement. Essentiel pour les bibliothèques.

```forth
\ Utilisation :
include UTILS.FTH       \ Charge toujours
require UTILS.FTH       \ Charge seulement si pas déjà chargé
require UTILS.FTH       \ Ne fait rien la deuxième fois
```

```rust
// Ajouter dans ForthVm :
pub loaded_files: Vec<String>,

// Mode immédiat :
"include" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Fichier manquant"); }
    // Même code que sys:load
    // ...
}

"require" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Fichier manquant"); }
    let fname = tokens[i].to_lowercase();
    if self.loaded_files.iter().any(|f| f == &fname) {
        // Déjà chargé → skip
    } else {
        self.loaded_files.push(fname.clone());
        // Même code que sys:load
        // ...
    }
}
```

**Difficulté :** faible.

---

### 9. `[if]` / `[else]` / `[then]` (compilation conditionnelle)

**Pourquoi :** permet d'adapter le code à la plateforme ou à la config.

```forth
\ Utilisation :
1 [if]
  : salut ." Bonjour !" ;
[else]
  : salut ." Hello !" ;
[then]
```

```rust
// Implémentation dans compile() : 
// [if] lit un flag de la pile. Si faux, skip jusqu'à [else] ou [then]
// Tout se passe au niveau du tokeniseur, pas de nouveau Op

"[if]" => {
    if let Some(flag) = self.stack.pop() {
        if flag == 0 {
            // Skip jusqu'à [else] ou [then]
            let mut depth = 1;
            while i + 1 < tokens.len() && depth > 0 {
                i += 1;
                match tokens[i].to_lowercase().as_str() {
                    "[if]" => depth += 1,
                    "[else]" => if depth == 1 { depth = 0; },
                    "[then]" => depth -= 1,
                    _ => {}
                }
            }
        }
    }
}
"[else]" => {
    // Si on arrive ici, c'est qu'on a exécuté la branche [if]
    // Skip jusqu'à [then]
    let mut depth = 1;
    while i + 1 < tokens.len() && depth > 0 {
        i += 1;
        match tokens[i].to_lowercase().as_str() {
            "[if]" => depth += 1,
            "[then]" => depth -= 1,
            _ => {}
        }
    }
}
"[then]" => {
    // No-op — marqueur de fin
}
```

**Difficulté :** faible — logique au tokeniseur seulement.

---

### 10. `type` (afficher une chaîne depuis la mémoire)

**Pourquoi :** compagnon de `s"`. Sans `type`, on ne peut pas afficher les chaînes stockées.

```forth
\ Utilisation :
s" Bonjour" type      \ → Bonjour
\ Stack: ( addr len -- )
```

```rust
// Primitive ou mot compilé :
"type" => {
    // ( addr len -- )
    let len = self.stack.pop().unwrap_or(0) as usize;
    let addr = self.stack.pop().unwrap_or(0) as usize;
    use core::fmt::Write;
    for k in 0..len {
        if addr + k < self.memory.len() {
            let ch = (self.memory[addr + k] & 0xFF) as u8 as char;
            let _ = write!(&mut self.print_buffer, "{}", ch);
        }
    }
}
```

**Difficulté :** triviale.

---

## Phase 3 — Productivité utilisateur

### 11. `."` multi-ligne (`,\"` dans `create`)

**Pourquoi :** stocker des chaînes en mémoire facilement.

```forth
\ Utilisation :
create message ," Hello Epona !"
\ message pointe vers la chaîne en mémoire
\ Premier cell = longueur, puis les octets

\ Implémentation :
"," => {
    // Déjà implémenté pour les nombres
    // Ajouter ",\"" pour les chaînes :
}
",\"" => {
    i += 1;
    let mut text = String::new();
    // ... collecter la chaîne ...
    let bytes = text.as_bytes();
    // Stocker longueur puis octets
    self.memory[self.here] = bytes.len() as i64;
    self.here += 1;
    for &b in bytes {
        if self.here >= self.memory.len() {
            self.memory.resize(self.here + 64, 0);
        }
        self.memory[self.here] = b as i64;
        self.here += 1;
    }
}
```

**Difficulté :** faible.

---

### 12. `count` (chaîne comptée → addr len)

```forth
\ Utilisation :
create msg ," Hello"
msg count type       \ → Hello
\ count : ( addr -- addr+1 len )
```

```rust
self.add_primitive("count", 290, false);

// Implémentation :
290 => { // count ( addr -- addr+1 len )
    if let Some(addr) = self.stack.pop() {
        let a = addr as usize;
        if a < self.memory.len() {
            let len = self.memory[a];
            self.stack.push(addr + 1);
            self.stack.push(len);
        }
    }
}
```

**Difficulté :** triviale.

---

### 13. `compare` (comparaison de chaînes)

```forth
\ Utilisation :
s" hello" s" hello" compare .  \ → 0 (egal)
s" abc" s" def" compare .     \ → -1 (avant)
s" xyz" s" abc" compare .     \ → 1 (après)
```

```rust
self.add_primitive("compare", 291, false);

291 => { // compare ( addr1 len1 addr2 len2 -- n )
    let len2 = self.stack.pop().unwrap_or(0) as usize;
    let addr2 = self.stack.pop().unwrap_or(0) as usize;
    let len1 = self.stack.pop().unwrap_or(0) as usize;
    let addr1 = self.stack.pop().unwrap_or(0) as usize;
    let min_len = len1.min(len2);
    let mut result = 0i64;
    for k in 0..min_len {
        let a = if addr1+k < self.memory.len() {
            self.memory[addr1+k] & 0xFF } else { 0 };
        let b = if addr2+k < self.memory.len() {
            self.memory[addr2+k] & 0xFF } else { 0 };
        if a < b { result = -1; break; }
        if a > b { result = 1; break; }
    }
    if result == 0 {
        if len1 < len2 { result = -1; }
        else if len1 > len2 { result = 1; }
    }
    self.stack.push(result);
}
```

**Difficulté :** faible.

---

### 14. `search` (recherche de sous-chaîne)

```forth
\ Utilisation :
s" Hello World" s" World" search  \ → addr 5 -1 (trouvé)
s" Hello World" s" xyz" search    \ → addr 11 0 (pas trouvé)
```

**Difficulté :** moyenne.

---

### 15. `marker` (point de restauration du dictionnaire)

```forth
\ Utilisation :
marker ---clean---
: test 42 . ;
: test2 99 . ;
---clean---          \ Supprime test et test2
```

```rust
"marker" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    let mname = tokens[i].to_lowercase();
    let snap_dict = self.dictionary.len();
    let snap_here = self.here;
    let snap_vars = self.variables.len();
    // Crée un mot qui restaure l'état
    self.dictionary.push(Word {
        name: Self::encode_name(&mname),
        is_primitive: false, prim_idx: 0,
        ops: vec![
            Op::Push(snap_dict as i64),
            Op::Push(snap_here as i64),
            Op::Push(snap_vars as i64),
            Op::CallPrim(300), // prim: restore-marker
        ],
        immediate: false, create_data: 0,
        is_defining: false, does_ops: vec![],
    });
}

300 => { // restore-marker ( snap_dict snap_here snap_vars -- )
    let nv = self.stack.pop().unwrap_or(0) as usize;
    let nh = self.stack.pop().unwrap_or(0) as usize;
    let nd = self.stack.pop().unwrap_or(0) as usize;
    self.dictionary.truncate(nd);
    self.here = nh;
    // Nettoyer les variables ajoutées après le marker
    while self.variables.len() > nv {
        if let Some(last_key) = self.variables.keys()
            .last().cloned()
        {
            self.variables.remove(&last_key);
        } else { break; }
    }
}
```

**Difficulté :** moyenne.

---

## Phase 4 — Écosystème drivers/apps

### 16. `buffer:` (allocation de buffer nommé)

```forth
\ Utilisation :
512 buffer: secteur
\ Crée un mot "secteur" qui empile l'adresse d'un buffer
\ de 512 cellules en mémoire Forth

secteur 512 erase          \ Met à zéro
0 0 1 secteur ahci:read .  \ Lit un secteur dedans
```

```rust
// Implémentation : combinaison de create + allot
"buffer:" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    if let Some(size) = self.stack.pop() {
        let bname = tokens[i].to_lowercase();
        let addr = self.here;
        self.here += size as usize;
        if self.here > self.memory.len() {
            self.memory.resize(self.here + 16, 0);
        }
        // Mettre à zéro
        for k in addr..self.here {
            self.memory[k] = 0;
        }
        self.dictionary.push(Word {
            name: Self::encode_name(&bname),
            is_primitive: false, prim_idx: 0,
            ops: vec![Op::Push(addr as i64)],
            immediate: false, create_data: addr,
            is_defining: false, does_ops: vec![],
        });
    }
}
```

**Difficulté :** triviale.

---

### 17. `struct` / `field` (structures de données)

```forth
\ Utilisation :
struct point
  field .x
  field .y
end-struct

point buffer: mon-point
42 mon-point .x !
99 mon-point .y !
mon-point .x @ .     \ → 42
```

```rust
// Implémentation :
// struct empile 0 (offset courant)
// field crée un mot qui ajoute l'offset à l'adresse
// end-struct crée un mot qui empile la taille totale

"struct" => {
    i += 1;
    // Nom optionnel (ignoré ou utilisé pour la taille)
    self.stack.push(0); // offset initial
}

"field" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    let fname = tokens[i].to_lowercase();
    if let Some(offset) = self.stack.pop() {
        // Crée un mot qui ajoute offset
        self.dictionary.push(Word {
            name: Self::encode_name(&fname),
            is_primitive: false, prim_idx: 0,
            ops: vec![Op::Push(offset), Op::CallPrim(0)], // + (add)
            immediate: false, create_data: 0,
            is_defining: false, does_ops: vec![],
        });
        self.stack.push(offset + 1); // prochaine cellule
    }
}

"end-struct" => {
    // La taille totale est sur la pile
    // On peut l'utiliser avec buffer:
}
```

**Difficulté :** moyenne.

---

### 18. `enum` (énumérations)

```forth
\ Utilisation :
0 enum ROUGE
  enum VERT
  enum BLEU
  enum JAUNE
drop

ROUGE .    \ → 0
BLEU .     \ → 2
```

```rust
"enum" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    if let Some(val) = self.stack.pop() {
        let ename = tokens[i].to_lowercase();
        self.dictionary.push(Word {
            name: Self::encode_name(&ename),
            is_primitive: false, prim_idx: 0,
            ops: vec![Op::Push(val)],
            immediate: false, create_data: 0,
            is_defining: false, does_ops: vec![],
        });
        self.stack.push(val + 1);
    }
}
```

**Difficulté :** triviale.

---

### 19. `[defined]` / `[undefined]` (test d'existence)

```forth
\ Utilisation :
[defined] gpu:init [if]
  ." GPU disponible" cr
  gpu:init drop
[then]

[undefined] uart:init [if]
  ." Pas de UART" cr
[then]
```

```rust
"[defined]" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    let exists = self.dictionary.iter().any(
        |w| Self::word_name_eq(&w.name, tokens[i]));
    self.stack.push(if exists { -1 } else { 0 });
}

"[undefined]" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    let exists = self.dictionary.iter().any(
        |w| Self::word_name_eq(&w.name, tokens[i]));
    self.stack.push(if exists { 0 } else { -1 });
}
```

**Difficulté :** triviale.

---

### 20. `word-info` (inspection du dictionnaire)

```forth
\ Utilisation :
word-info carre
\ Affiche :
\ carre : mot compile, 3 ops, non-immediat
\ word-info net:init
\ net:init : primitive #200, non-immediat
```

```rust
"word-info" => {
    i += 1;
    if i >= tokens.len() { eerr!(i-1, "Nom manquant"); }
    if let Some(dict_idx) = self.dictionary.iter().position(
        |w| Self::word_name_eq(&w.name, tokens[i]))
    {
        let w = &self.dictionary[dict_idx];
        use core::fmt::Write;
        let _ = write!(&mut self.print_buffer,
            "{} : idx={}", tokens[i], dict_idx);
        if w.is_primitive {
            let _ = write!(&mut self.print_buffer,
                " primitive #{}", w.prim_idx);
        } else {
            let _ = write!(&mut self.print_buffer,
                " compile ({} ops)", w.ops.len());
        }
        if w.immediate {
            let _ = write!(&mut self.print_buffer, " IMMEDIATE");
        }
        if w.is_defining {
            let _ = write!(&mut self.print_buffer,
                " DEFINING (does> {} ops)", w.does_ops.len());
        }
        if w.create_data != 0 {
            let _ = write!(&mut self.print_buffer,
                " data_addr={}", w.create_data);
        }
        let _ = write!(&mut self.print_buffer, "\n");
    } else {
        eerr!(i, "Mot inconnu : {}", tokens[i]);
    }
}
```

**Difficulté :** triviale.

---

## Tableau récapitulatif

| # | Mot | Phase | Difficulté | Nouveaux Op | Impact |
|---|---|---|---|---|---|
| 1 | `see` | 1 | Faible | 0 | Diagnostic |
| 2 | `value` / `to` | 1 | Moyenne | 2 | Confort langage |
| 3 | `defer` / `is` | 1 | Moyenne | 1 | Callbacks/drivers |
| 4 | `case/of/endof/endcase` | 1 | Moyenne | 0 | Lisibilité |
| 5 | `[char]` / `char` | 1 | Triviale | 0 | Confort |
| 6 | `\n` dans `."` | 2 | Triviale | 0 | Chaînes |
| 7 | `abort"` | 2 | Faible | 1 | Sécurité drivers |
| 8 | `include` / `require` | 2 | Faible | 0 | Modules |
| 9 | `[if]` / `[then]` | 2 | Faible | 0 | Portabilité |
| 10 | `type` | 2 | Triviale | 0 | Chaînes |
| 11 | `,"` | 3 | Faible | 0 | Données |
| 12 | `count` | 3 | Triviale | 0 | Chaînes |
| 13 | `compare` | 3 | Faible | 0 | Chaînes |
| 14 | `search` | 3 | Moyenne | 0 | Chaînes |
| 15 | `marker` | 3 | Moyenne | 0 | Dev cycle |
| 16 | `buffer:` | 4 | Triviale | 0 | Drivers |
| 17 | `struct` / `field` | 4 | Moyenne | 0 | Structures |
| 18 | `enum` | 4 | Triviale | 0 | Clarté |
| 19 | `[defined]` | 4 | Triviale | 0 | Conditionnement |
| 20 | `word-info` | 4 | Triviale | 0 | Diagnostic |

---

## Ordre d'implémentation recommandé

```
Semaine 1 :  see, char, [char], type, word-info
Semaine 2 :  value/to, enum, buffer:, [defined]
Semaine 3 :  case/of/endof/endcase, abort"
Semaine 4 :  defer/is, include/require, [if]/[then]
Semaine 5 :  ,", count, compare, search
Semaine 6 :  marker, struct/field, \n dans ."
```

Chaque semaine ajoute une couche cohérente, testable avec ton `TESTS.FTH`.
