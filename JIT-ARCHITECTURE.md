# Architecture JIT x86-64 — Direct Threading pour EponaForth

## Vue d'ensemble

EponaForth intègre un compilateur JIT (Just-In-Time) qui traduit les mots Forth
en code machine x86-64 natif. L'approche est la compilation paresseuse (lazy):
un mot est JIT-compilé à son premier appel, puis le code natif est mis en cache.

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

## Trampoline (entry/exit Rust ↔ JIT)

Le trampoline est une fonction émise en x86-64 dans le code buffer.
Il fait la transition entre les conventions d'appel C et les registres JIT :

```
Entry (C → JIT):
  push rbp / push rbx / push r12-r15    ← sauvegarder callee-saved
  mov r15, rdi     ← psp
  mov r14, rsi     ← rsp
  mov r13, rdx     ← tos
  mov r12, rcx     ← mem_base
  call r8          ← appel du code JIT
  mov rax, r13     ← nouveau TOS comme résultat
  pop r15-r12 / pop rbx / pop rbp       ← restaurer
  ret
```

Type Rust :
```rust
type Trampoline = unsafe extern "C" fn(
    psp: *mut i64,      // rdi
    rsp: *mut usize,    // rsi
    tos: i64,           // rdx
    mem: *mut i64,      // rcx
    jit_code: *const u8 // r8
) -> i64;               // rax = nouveau TOS
```

## Code Emitter (src/jit.rs)

Encodeur x86-64 de bas niveau. Chaque primitive Forth est traduite en
une séquence d'instructions x86-64 :

| Primitive | Code x86-64 généré |
|-----------|---------------------|
| `dup`     | `sub r15,8; mov [r15],r13` |
| `drop`    | `mov rax,r13; mov r13,[r15]; add r15,8` |
| `swap`    | `mov rax,[r15]; mov [r15],r13; mov r13,rax` |
| `+`       | `mov rax,r13; mov r13,[r15]; add r15,8; add r13,rax` |
| `-`       | `mov rax,r13; mov rcx,r13; mov r13,[r15]; add r15,8; sub r13,rcx` |
| `*`       | `mov rax,r13; mov r13,[r15]; add r15,8; imul r13,rax` |
| `/`       | `idiv` avec sign-extend |
| `@`       | `mov r13,[r13]` |
| `!`       | `mov rax,r13; pop; mov [rax],r13; pop` |
| `=`       | `cmp; sete; movzx` |
| `and`     | `and r13,rax` |
| `>r`      | `sub r14,8; mov [r14],r13; pop` |
| `r>`      | `push; mov r13,[r14]; add r14,8` |
| `i`       | `push; mov r13,[r14]` |

## Compilation paresseuse

```
Op::Call(dict_idx) dans compile_word():
  1. Si word compilé → émettre CALL rel32 direct (5 bytes)
  2. Sinon → émettre CALL rel32 placeholder + enregistrer dans pending_calls
  3. Après compilation → patch_pending_calls() résout les références

patch_pending_calls():
  Pour chaque (patch_at, dict_idx) dans pending_calls:
    Si le mot est maintenant compilé → écraser le CALL rel32 avec la bonne cible
```

## Chainage JIT récursif (Phase 4 — CALL rel32)

Les mots JIT-compilés s'appellent directement entre eux via `CALL rel32` (5 bytes)
au lieu de passer par l'interpréteur. Le chainage est résolu en deux temps :

1. **Compilation** : Si la cible est déjà compilée → CALL rel32 direct
   Sinon → CALL rel32 placeholder (E8 00000000) + enregistrement
2. **Patch** : Après chaque compilation, `patch_pending_calls()` résout les appels
   en écrasant les placeholders avec les bons offsets rel32.

Avant (Phase 1-3) :
  `MOV RAX, addr; CALL RAX`  → 12 bytes,间接调用

Maintenant (Phase 4) :
  `CALL rel32`               → 5 bytes, appel direct

## Primitives JIT supportées (Phase 1-6 — 39 + 8 non-JIT)

```
Stack:       dup drop swap over rot
Arithmetic:  + - * / mod 1+ 1-
Compare:     = <> < > 0= 0<
Logic:       and or xor invert lshift rshift
Memory:      @ ! +!
Return:      >r r> r@ i j
Loops:       DO ?DO LOOP +LOOP LEAVE
Control:     IF/ELSE/THEN (backpatching forward jumps)
```

## Inlining de mots simples (Phase 5)

Les mots "simples" (uniques primitives + Push) sont inlinés directement
dans le code appelant au lieu d'émettre un CALL rel32.

**Critères d'inline :**
- Ops = uniquement Push, CallPrim, Nop (pas de control flow, pas de Call)
- Taille estimée ≤ 48 bytes
- Profondeur d'inline ≤ 4 (anti-récursion)

**Exemple :**
```forth
: double 2 * ;       \ Push(2), CallPrim(*), Exit → inliné
: square dup * ;     \ CallPrim(dup), CallPrim(*), Exit → inliné
: cube dup * * ;     \ 3 prims → inliné
```

Avant inlining : `CALL rel32` (5 bytes) + overhead trampoline
Après inlining : code natif direct (zéro overhead appel)

## Profiling + Optimisations (Phase 6)

### Profiling

4 primitives Forth pour mesurer les appels JIT :
- `jit-prof` : affiche les compteurs
- `jit-prof-reset` : réinitialise
- `jit-prof-on` / `jit-prof-off` : active/désactive

Le compteur `call_counts` (BTreeMap<usize, u64>) est incrémenté à chaque
appel JIT via `profile_call(dict_idx)` dans `exec_primitive()`.

### Constant Folding

Avant compilation, `constant_fold()` analyse les ops :
- `Push(a) Push(b) CallPrim(+)` → `Push(a + b)`
- `Push(a) Push(b) CallPrim(-)` → `Push(a - b)`
- `Push(a) Push(b) CallPrim(*)` → `Push(a * b)`
- `Dup` → `Push + Push`
- `Push(a) CallPrim(1+)` → `Push(a + 1)`
- `Push(a) CallPrim(1-)` → `Push(a - 1)`

### Tail Call Optimization

Si le dernier op est `Call(target)` et le mot n'est pas inlineable,
le JIT émet `JMP rel32` au lieu de `CALL rel32; RET` — élimine le
RET et le push/pop de l'adresse de retour.

## Limites du prototype

1. ~~**Pas de chaînage JIT récursif** :~~ ✅ **CALL rel32** entre mots JIT compilés (Phase 4)
2. ~~**Pas de control flow JIT** :~~ ✅ **IF/ELSE/THEN** compilé en natif (Phase 2)
3. ~~**Pas de boucles JIT** :~~ ✅ **DO/LOOP/+LOOP/?DO/LEAVE** compilé en natif (Phase 3)
4. ~~**Inlining de mots simples** :~~ ✅ Inlining automatique (Phase 5)
5. ~~**Profiling** :~~ ✅ Compteurs d'appels JIT (Phase 6)
6. ~~**Constant folding** :~~ ✅ Plie Push+Push+Prim → Push(result) (Phase 6)
7. ~~**Tail call optimization** :~~ ✅ Call→Exit → JMP rel32 (Phase 6)
8. ~~**BEGIN/WHILE/REPEAT** :~~ ✅ Compilé via Op::Jump/JumpIfZero (déjà supporté)

## Fichiers

| Fichier | Description |
|---------|-------------|
| `src/jit.rs` | CodeEmitter + JitEngine + trampoline + 39 primitives + inlining + profiling (Phase 1-6) |
| `src/interpreter.rs` | Intégration : `jit` field dans ForthVm, lazy compile dans Op::Call, backtrace, mémoire u8 |

## Performance attendue

- **Primitives simples** (dup, +, drop) : ~1-2 ns/op (1 instruction CPU)
- **Interpréteur actuel** : ~50-100 ns/op (dispatch Rust + clone Op)
- **Speedup estimé** : ×30-50 pour les boucles arithmétiques pures

## Prochaines étapes

1. ~~Control flow JIT (IF/ELSE/THEN avec backpatching)~~ ✅ Phase 2 terminée
2. ~~Boucles DO/LOOP JIT~~ ✅ Phase 3 terminée
3. ~~Chaînage JIT récursif (CALL rel32 entre mots JIT)~~ ✅ Phase 4 terminée
4. ~~Inlining de mots simples~~ ✅ Phase 5 terminée
5. ~~Profiling et optimisations~~ ✅ Phase 6 terminée
6. ~~BEGIN/WHILE/REPEAT + UNTIL/AGAIN~~ ✅ Déjà supporté via Jump/JumpIfZero