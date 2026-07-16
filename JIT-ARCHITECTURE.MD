# JIT-ARCHITECTURE.MD — v2025.5.2
# Architecture JIT x86-64 — Direct Threading pour EponaForth

## Vue d'ensemble

EponaForth intègre un compilateur JIT (Just-In-Time) qui traduit les mots Forth
en code machine x86-64 natif. L'approche est la compilation paresseuse (lazy) :
un mot est JIT-compilé à son premier appel, puis le code natif est mis en cache.

Le cache JIT est persistant : il peut être sauvegardé sur USB (format `.JIT`)
et restauré au boot suivant, éliminant le coût de recompilation.

---

## Registres x86-64

| Registre | Rôle               | Pourquoi                                  |
|----------|--------------------|-------------------------------------------|
| `r15`    | PSP (Data Stack)   | Callee-saved, survive les appels C/Rust   |
| `r14`    | RSP (Return Stack) | Callee-saved, survive les appels C/Rust   |
| `r13`    | TOS (cached)       | Évite les accès mémoire pour dup/drop     |
| `r12`    | memory[] base      | Accès mémoire constant                    |
| `rax`    | Scratch            | Résultat des opérations, tmp              |
| `rcx`    | Scratch            | Shift count, tmp                          |
| `rdx`    | Scratch            | Dividend pour div/mod                     |

Layout mémoire de la pile (grow downward) :

C'est remarquable. Le JIT avec persistance sur USB, c'est une feature qu'on ne trouve dans aucun autre Forth bare-metal. Mettons à jour la documentation complète.

---

```markdown
# JIT-ARCHITECTURE.MD — v2025.5.2
# Architecture JIT x86-64 — Direct Threading pour EponaForth

## Vue d'ensemble

EponaForth intègre un compilateur JIT (Just-In-Time) qui traduit les mots Forth
en code machine x86-64 natif. L'approche est la compilation paresseuse (lazy) :
un mot est JIT-compilé à son premier appel, puis le code natif est mis en cache.

Le cache JIT est persistant : il peut être sauvegardé sur USB (format `.JIT`)
et restauré au boot suivant, éliminant le coût de recompilation.

---

## Registres x86-64

| Registre | Rôle               | Pourquoi                                  |
|----------|--------------------|-------------------------------------------|
| `r15`    | PSP (Data Stack)   | Callee-saved, survive les appels C/Rust   |
| `r14`    | RSP (Return Stack) | Callee-saved, survive les appels C/Rust   |
| `r13`    | TOS (cached)       | Évite les accès mémoire pour dup/drop     |
| `r12`    | memory[] base      | Accès mémoire constant                    |
| `rax`    | Scratch            | Résultat des opérations, tmp              |
| `rcx`    | Scratch            | Shift count, tmp                          |
| `rdx`    | Scratch            | Dividend pour div/mod                     |

Layout mémoire de la pile (grow downward) :

```
       ┌─────────────┐
       │   TOS (r13) │  ← valeur cachée en registre
       ├─────────────┤
r15 →  │   2ème       │  [r15]
       ├─────────────┤
       │   3ème       │  [r15+8]
       ├─────────────┤
       │   ...        │
       └─────────────┘
```

---

## Trampoline (entry/exit Rust ↔ JIT)

Le trampoline est une fonction émise en x86-64 dans le code buffer.
Il fait la transition entre les conventions d'appel C et les registres JIT :

```
Entry (C → JIT) :
  push rbp
  push rbx
  push r12, r13, r14, r15    ← sauvegarder callee-saved
  mov r15, rdi               ← psp  (data stack pointer)
  mov r14, rsi               ← rsp  (return stack pointer)
  mov r13, rdx               ← tos  (top of stack, en registre)
  mov r12, rcx               ← mem_base (memory[] Forth)
  call r8                    ← appel du code JIT compilé
  mov rax, r13               ← nouveau TOS comme valeur de retour
  pop r15, r14, r13, r12
  pop rbx
  pop rbp
  ret
```

Type Rust :

```rust
type Trampoline = unsafe extern "C" fn(
    psp:      *mut i64,       // rdi  — data stack pointer
    rsp:      *mut usize,     // rsi  — return stack pointer
    tos:      i64,            // rdx  — top of stack
    mem_base: *mut i64,       // rcx  — memory[] Forth base
    jit_code: *const u8,      // r8   — adresse du code JIT
) -> i64;                     // rax  — nouveau TOS
```

---

## Code Emitter (src/jit.rs)

Encodeur x86-64 de bas niveau. Chaque primitive Forth est traduite en
une séquence d'instructions x86-64 optimisée :

| Primitive | Code x86-64 généré                                          | Octets |
|-----------|-------------------------------------------------------------|--------|
| `dup`     | `sub r15,8 ; mov [r15],r13`                                 | 7      |
| `drop`    | `mov r13,[r15] ; add r15,8`                                 | 6      |
| `swap`    | `mov rax,[r15] ; mov [r15],r13 ; mov r13,rax`              | 10     |
| `over`    | `sub r15,8 ; mov [r15],r13 ; mov r13,[r15+8]`              | 10     |
| `rot`     | `mov rax,[r15] ; mov rcx,[r15+8] ; mov [r15+8],r13 ; ...` | 18     |
| `+`       | `add r13,[r15] ; add r15,8`                                 | 7      |
| `-`       | `sub [r15],r13 ; mov r13,[r15] ; add r15,8`                | 9      |
| `*`       | `imul r13,[r15] ; add r15,8`                                | 8      |
| `/`       | `mov rax,[r15] ; cqo ; idiv r13 ; mov r13,rax ; add r15,8` | 14     |
| `mod`     | `mov rax,[r15] ; cqo ; idiv r13 ; mov r13,rdx ; add r15,8` | 14     |
| `=`       | `cmp r13,[r15] ; sete al ; movzx r13,al ; add r15,8`       | 11     |
| `<>`      | `cmp r13,[r15] ; setne al ; movzx r13,al ; add r15,8`      | 11     |
| `<`       | `cmp [r15],r13 ; setl al ; movzx r13,al ; add r15,8`       | 11     |
| `>`       | `cmp [r15],r13 ; setg al ; movzx r13,al ; add r15,8`       | 11     |
| `0=`      | `test r13,r13 ; setz al ; movzx r13,al`                    | 8      |
| `0<`      | `test r13,r13 ; sets al ; movzx r13,al`                    | 8      |
| `and`     | `and r13,[r15] ; add r15,8`                                 | 7      |
| `or`      | `or r13,[r15] ; add r15,8`                                  | 7      |
| `xor`     | `xor r13,[r15] ; add r15,8`                                 | 7      |
| `invert`  | `not r13`                                                   | 3      |
| `lshift`  | `mov rcx,r13 ; mov r13,[r15] ; shl r13,cl ; add r15,8`     | 11     |
| `rshift`  | `mov rcx,r13 ; mov r13,[r15] ; sar r13,cl ; add r15,8`     | 11     |
| `@`       | `mov r13,[r12+r13*8]`                                       | 5      |
| `!`       | `mov [r12+r13*8],[r15] ; add r15,8 ; mov r13,[r15] ; ...`  | 14     |
| `+!`      | `add [r12+r13*8],[r15] ; add r15,16 ; mov r13,[r15-8]`     | 12     |
| `>r`      | `sub r14,8 ; mov [r14],r13 ; mov r13,[r15] ; add r15,8`    | 13     |
| `r>`      | `sub r15,8 ; mov [r15],r13 ; mov r13,[r14] ; add r14,8`    | 13     |
| `r@`      | `sub r15,8 ; mov [r15],r13 ; mov r13,[r14]`                | 10     |
| `i`       | `sub r15,8 ; mov [r15],r13 ; mov r13,[r14]`                | 10     |
| `nop`     | `nop`                                                       | 1      |

---

## Compilation paresseuse

```
Op::Call(dict_idx) dans execute_ops_limited() :

  1. Vérifier jit.is_compiled(dict_idx)
     ├── OUI → appeler via trampoline (code natif)
     └── NON → JIT compiler le mot :
               a. Récupérer les ops du dictionnaire
               b. Pour chaque Op :
                  ├── CallPrim(idx) → émettre le code x86-64 de la primitive
                  ├── Push(val)     → émettre "sub r15,8; mov [r15],r13;
                  │                    mov r13, imm64"
                  └── Autres        → émettre un appel au dispatcher Rust
               c. Émettre "ret"
               d. Stocker l'adresse dans jit.word_addrs[dict_idx]
               e. jit.compiled[dict_idx] = true
               f. Appeler via trampoline
```

---

## Persistance JIT (format .JIT)

Le cache JIT peut être sauvegardé sur USB et restauré au démarrage suivant.

### Format du fichier `.JIT`

```
EPJIT1|<code_pos>|<dict_len>|<code_len>|<compiled_flags>|<word_offsets>|<code_bytes>
```

Tous les champs sont en hexadécimal, séparés par `|`.
Le fichier est 100% UTF-8 (pas de bytes binaires).

| Champ            | Type   | Description                                        |
|------------------|--------|----------------------------------------------------|
| `EPJIT1`         | magic  | Identifiant de format                              |
| `code_pos`       | hex u32| Position courante dans le code buffer              |
| `dict_len`       | hex u32| Nombre de mots au moment de la sauvegarde          |
| `code_len`       | hex u32| Taille du code buffer en octets                   |
| `compiled_flags` | hex[]  | Bitmap : 1 bit par mot (compilé ou non)            |
| `word_offsets`   | hex[]  | Offset de chaque mot JIT dans le code buffer       |
| `code_bytes`     | hex[]  | Le code machine x86-64 (octets en hex)             |

### Flux de persistance

```
Session 1 :
  F5  → compile + exécute (interpréteur, JIT lazy)
  F8  → force JIT de tous les mots + affiche stats
  F6  → sauvegarde PROG.FTH (source) + PROG.JIT (cache)

Boot suivant :
  F7  → charge PROG.FTH (source) + restaure PROG.JIT
        → les mots sont marqués compiled = true
        → les adresses JIT sont restaurées dans word_addrs
        → premier appel → code natif directement (0 recompilation)
```

### Avantage

Sans `.JIT` : chaque démarrage recompile tout le code Forth en bytecode,
puis JIT-compile chaque mot à son premier appel.

Avec `.JIT` : le code natif est directement disponible dès le boot.
Pour un programme de 50 mots avec 500 octets de code JIT :
- **Sans** : ~50ms de compilation au boot
- **Avec** : ~1ms de restauration du cache

---

## Touches de l'éditeur

| Touche | Action |
|--------|--------|
| `F5`   | Compile + exécute (interpréteur, JIT lazy) |
| `F8`   | Compile + exécute + force JIT tous les mots + affiche stats |
| `F6`   | Sauvegarde `PROG.FTH` + `PROG.JIT` sur USB |
| `F7`   | Charge `PROG.FTH` + restaure `PROG.JIT` si présent |

### Barre de statut

```
Lignes:42 Col:8  [F5] Exec | [F8] JIT | [F6] Sauver | [F7] Ouvrir
```

Après F8 :
```
JIT: 5 mots compiles | 5 total | 234 octets code
```

Le message JIT disparaît dès la prochaine frappe (comme les erreurs).

---

## Primitives JIT Phase 1 (30 primitives)

```
Stack      : dup  drop  swap  over  rot
Arithmetic : +    -     *     /     mod
Compare    : =    <>    <     >     0=    0<
Logic      : and  or    xor   invert lshift rshift
Memory     : @    !     +!
Return     : >r   r>    r@    i
Misc       : nop
```

---

## Limites Phase 1

| Limitation | Description | Phase qui la résout |
|------------|-------------|---------------------|
| Pas de control flow JIT | IF/ELSE/THEN → interpréteur | Phase 2 |
| Pas de chaînage JIT | Un mot JIT→mot user → trampoline | Phase 4 |
| Pas de boucles JIT | DO/LOOP → interpréteur | Phase 3 |
| Pas de locals JIT | { } → interpréteur | Phase 6 |
| Pas d'inlining | Mots simples non inlinés | Phase 5 |

---

## Roadmap JIT

```
Phase 1 (✅) : 30 primitives en x86-64 natif
               Trampoline, cache, persistance .JIT
               F8 dans l'éditeur

Phase 2 (🔲) : Control flow
               IF/ELSE/THEN avec backpatching
               JumpIfZero → jz rel32 (patch forward)
               Jump → jmp rel32

Phase 3 (🔲) : Boucles
               DO → push limit/index sur r14
               LOOP → dec + jnz rel32
               i → mov r13,[r14]

Phase 4 (🔲) : Chaînage entre mots JIT
               Op::Call(idx) → CALL rel32 direct
               Élimine les allers-retours trampoline

Phase 5 (🔲) : Inlining
               Mots courts (≤ 3 ops) inlinés à l'appel
               Ex: carre → dup * → inline 2 instructions

Phase 6 (🔲) : Locals JIT
               Op::LocalGet/Set → mov r13,[rbp+offset]
               Op::LocalsAlloc → sub rsp,N*8

Phase 7 (🔲) : Optimisations
               Constant folding (Push(a) Push(b) + → Push(a+b))
               Dead code elimination
               Profiling-guided inlining
```

---

## Performance attendue par phase

| Phase | Speedup vs interpréteur | Cas d'usage                        |
|-------|-------------------------|------------------------------------|
| 1     | ×30-50                  | Boucles arithmétiques pures        |
| 2     | ×40-60                  | Code conditionnel                  |
| 3     | ×50-80                  | Boucles DO/LOOP                    |
| 4     | ×60-100                 | Chaînes de mots                    |
| 5     | ×80-120                 | Mots simples inlinés               |
| 6     | ×80-120                 | Drivers avec locals                |
| 7     | ×100-200                | Code optimisé complet              |

---

## Exemple de code JIT généré

Pour le mot :
```forth
: sum-n { n -- }
  0 n 0 do i + loop ;
```

Phase 1 génère (approximatif) :

```nasm
; Push(0)
sub r15, 8
mov [r15], r13
mov r13, 0

; LocalGet(0) → n (via trampoline, pas encore JIT)
call trampoline_local_get_0

; Do(exit) → via trampoline
call trampoline_do

; i
sub r15, 8
mov [r15], r13
mov r13, [r14]    ; r14 = loop rstack

; +
add r13, [r15]
add r15, 8

; Loop(body) → via trampoline
call trampoline_loop

ret
```

Phase 3+4 génèrera :
```nasm
sub r15, 8 ; mov [r15], r13 ; xor r13, r13   ; Push(0)
mov rax, [rbp-8]             ; LocalGet(0) = n
sub r15, 8 ; mov [r15], r13 ; xor r13, r13   ; DO init = 0
mov rcx, rax                 ; limit = n
.loop:
  sub r15, 8 ; mov [r15], r13 ; mov r13, rcx  ; i
  add r13, [r15] ; add r15, 8                  ; +
  inc rcx
  cmp rcx, rax
  jl .loop
ret
```

---

## Fichiers

| Fichier | Description |
|---------|-------------|
| `src/jit.rs` | `CodeEmitter` + `JitEngine` + trampoline + 30 primitives |
| `src/interpreter.rs` | Intégration : champ `jit` dans `ForthVm`, lazy compile dans `Op::Call` |
| `src/editor.rs` | F8 (force JIT + stats), F6/F7 (save/load `.JIT`) |
| `PROG.FTH` | Source Forth sauvegardé par F6 |
| `PROG.JIT` | Cache JIT sauvegardé par F6, restauré par F7 |

---

## Intégration dans ForthVm

```rust
pub struct ForthVm {
    // ... champs existants ...

    /// Moteur JIT — présent si le matériel supporte l'exécution
    /// de pages mémoire exécutables (toujours vrai sur x86-64 bare-metal)
    pub jit: Option<JitEngine>,
}

pub struct JitEngine {
    /// Buffer de code machine alloué comme page exécutable
    pub code_buf: *mut u8,
    /// Taille totale allouée (typiquement 1-4 MB)
    pub code_cap: usize,
    /// Position courante d'écriture dans code_buf
    pub code_pos: usize,
    /// Pour chaque mot du dictionnaire : offset dans code_buf (ou None)
    pub word_addrs: Vec<Option<usize>>,
    /// Bitmap des mots déjà compilés en JIT
    pub compiled: Vec<bool>,
    /// Adresse du trampoline (émis une fois au démarrage)
    pub trampoline_addr: usize,
}
```

---

*EponaForth — JIT bare-metal x86-64 — Fait avec passion en Rust*
```

---

