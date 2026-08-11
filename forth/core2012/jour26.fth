\ ============================================================================
\ forth/core2012/jour26.fth - @, !, C@, C!
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 26
\ Decision utilisateur "fenetre" : C@/C!/W@/W!/L@/L!/FILL/CMOVE
\ (prims 73-80) : si addr passe check_mem (< MAX_MEM) -> self.memory
\ via read_byte/write_byte/read_cell/write_cell (masques 8/16/32 bits,
\ fill/cmove bornes MAX_MEM avec clamp + chevauchement gere) ; sinon ->
\ MMIO natif (comportement anterieur). Buffers des apps coherents avec
\ @/!/allot. Section B12 : fenetre memoire C@ C! W@ W! L@ L!.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour26.fth   (dans qemu_img)
\
\ PERIMETRE : CORE / CORE EXT + extensions Epona marquees (w@/w!/l@/l!).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable wv

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B12 - C! / C@ (octet bas d'une cellule)
\ ---------------------------------------------------------------------------
0 wv !
65 wv c!
wv c@ 65 = verif
wv @ 65 = verif
-1 wv !
0 wv c!
wv c@ 0 = verif
wv @ -256 = verif

\ ---------------------------------------------------------------------------
\ B12 - W! / W@ (16 bits, extension Epona marquee)
\ ---------------------------------------------------------------------------
variable ww
0 ww !
4660 ww w!          \ 0x1234
ww w@ 4660 = verif

\ ---------------------------------------------------------------------------
\ B12 - L! / L@ (32 bits, extension Epona marquee)
\ ---------------------------------------------------------------------------
variable ll
0 ll !
305419896 ll l!    \ 0x12345678
ll l@ 305419896 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 26
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour26.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
