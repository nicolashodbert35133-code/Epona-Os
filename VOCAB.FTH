\ ═══════════════════════════════════════════════════════════════════
\  VOCAB.FTH — Tests du système de vocabulaires (namespaces)
\  EponaForth v2025.4
\ ═══════════════════════════════════════════════════════════════════

." ══ Tests VOCABULAIRES ══" cr

\ ── 1. Créer des vocabulaires ──────────────────────────────────
." 1. vocabulary ..." cr

vocabulary OUTILS
vocabulary MATH

."   OUTILS créé : " OUTILS . cr
."   MATH créé : " MATH . cr

\ ── 2. also / only / forth / definitions ────────────────────────
." 2. also / only / forth / definitions ..." cr

only
forth
also OUTILS
definitions

."   current_vocab = OUTILS : OK" cr

\ ── 3. Mots dans des vocabulaires ──────────────────────────────
." 3. Définition de mots dans des vocabs ..." cr

: .test-outils 100 . cr ; immediate
: .test-math 200 . cr ; immediate

."   .test-outils défini dans OUTILS" cr
."   .test-math défini dans MATH" cr

\ ── 4. search_order ────────────────────────────────────────────
." 4. search-order ..." cr

only
forth
also OUTILS
also MATH

."   Ordre: [FORTH OUTILS MATH]" cr

\ ── 5. Shadowing (MATH > OUTILS > FORTH) ──────────────────────
." 5. Shadowing ..." cr

only
forth

: dup . " DANS FORTH" cr ; immediate

\ Rédefine dans OUTILS
OUTILS definitions
: dup . " DANS OUTILS" cr ; immediate
forth definitions

\ Rédefine dans MATH
MATH definitions
: dup . " DANS MATH" cr ; immediate
forth definitions

only
forth
also OUTILS
also MATH

."   dup devrait afficher DANS MATH :" cr
dup

only
forth

\ ── 6. .vocabs ────────────────────────────────────────────────
." 6. .vocabs ..." cr
.vocabs

\ ── 7. search-order ───────────────────────────────────────────
." 7. search-order ..." cr
only
forth
also OUTILS
search-order

\ ── 8. Mots créés dans vocab ──────────────────────────────────
." 8. Mots dans vocab..." cr

MATH definitions
: carre ( n -- n*n ) dup * ;
forth definitions

OUTILS definitions
: greet . " Salut depuis OUTILS" cr ;
forth definitions

only
forth
also MATH
."   carre 5 = " 5 carre . cr

only
forth
also OUTILS
greet

\ ── 9. Reset to FORTH ────────────────────────────────────────
." 9. Retour à FORTH only ..." cr
only
."   search-order après only : " search-order cr

." ══ Fin tests VOCABULAIRES ══" cr
