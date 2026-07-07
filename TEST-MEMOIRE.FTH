\ ============================================================
\ TEST-MEMOIRE.FTH
\ Tests des primitives : cell+, cells, aligned, char+, chars
\ ============================================================
\ sys:load TEST-MEMOIRE.FTH

cr ." ==========================" cr
cr ."   Tests cell+ cells aligned" cr
cr ."   char+ chars ?do leave" cr
cr ." ==========================" cr

\ ─── cell+ ──────────────────────────────────────────────────
cr ." --- cell+ ( addr -- addr+8 ) ---" cr

0
cr ." 0 cell+ = " dup cell+ . cr
drop
100
cr ." 100 cell+ = " dup cell+ . cr
8 = if ." OK" else ." ECHEC" then cr
drop

\ ─── cells ──────────────────────────────────────────────────
cr ." --- cells ( n -- n*8 ) ---" cr

1 cells
cr ." 1 cells = " dup . cr
8 = if ." OK" else ." ECHEC" then cr
drop

5 cells
cr ." 5 cells = " dup . cr
40 = if ." OK" else ." ECHEC" then cr
drop

\ ─── aligned ────────────────────────────────────────────────
cr ." --- aligned ( addr -- addr aligne ) ---" cr

0
cr ." 0 aligned = " dup aligned . cr
0 = if ." OK" else ." ECHEC" then cr
drop

1
cr ." 1 aligned = " dup aligned . cr
8 = if ." OK" else ." ECHEC" then cr
drop

7
cr ." 7 aligned = " dup aligned . cr
8 = if ." OK" else ." ECHEC" then cr
drop

15
cr ." 15 aligned = " dup aligned . cr
16 = if ." OK" else ." ECHEC" then cr
drop

\ ─── char+, chars ───────────────────────────────────────────
cr ." --- char+ / chars ---" cr

0 char+
cr ." 0 char+ = " dup . cr
1 = if ." OK" else ." ECHEC" then cr
drop

5 chars
cr ." 5 chars = " dup . cr
5 = if ." OK (identite)" else ." ECHEC" then cr
drop

\ ─── ?do ────────────────────────────────────────────────────
cr ." --- ?do (DO conditionnel) ---" cr

: test-?do ( n -- )
  0 ?do i . loop cr
;

cr ." test-?do 5 -> " 5 test-?do
cr ." test-?do 0 -> " 0 test-?do
cr ." (rien attendu si 0)" cr

\ ─── leave ──────────────────────────────────────────────────
cr ." --- leave (sortie de boucle) ---" cr

: test-leave ( n -- )
  0 do
    i 3 mod 0= if
      cr ." Premier multiple de 3: " i . cr
      leave
    then
  loop
;

cr ." test-leave 10 -> " 10 test-leave
cr ." test-leave 3  -> " 3 test-leave

\ ─── DO fix ─────────────────────────────────────────────────
cr ." --- DO fix (index correct) ---" cr

: test-do ( -- )
  cr ." 5 0 do i . loop -> "
  5 0 do i . loop cr
;

test-do
cr ." (attendu: 0 1 2 3 4)" cr

cr ." ==========================" cr
cr ."   Tests termines" cr
cr ." ==========================" cr
