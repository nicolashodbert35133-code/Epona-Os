\ ============================================================================
\ forth/core2012/jour46.fth - >NUMBER
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 46
\ >number(409) ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) Core : convertit
\ c-addr1/u1 selon BASE (0-9, A-Z/a-z), accumule dans ud1 en u128
\ (wrapping au debordement, condition ambigue), s'arrete au premier
\ caractere non convertible -> ud2 + reste c-addr2/u2. Un signe en tete
\ n'est pas converti (gere avant). Convention double Epona ( lo hi )
\ hi au sommet. Section B30 : base 10, arret, reste multi-caracteres,
\ base 16, signe, accumulation double non nul, base 2.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour46.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B30 - base 10 : conversion complete (ud2 = 1234, u2 = 0)
\ ---------------------------------------------------------------------------
0 0 s" 1234" >number
0 = verif
2drop 1234 = verif

\ ---------------------------------------------------------------------------
\ B30 - arret sur caractere invalide (reste "ab", ud2 = 12)
\ ---------------------------------------------------------------------------
0 0 s" 12ab" >number
2 = verif
2drop 12 = verif

\ ---------------------------------------------------------------------------
\ B30 - base 16
\ ---------------------------------------------------------------------------
hex
0 0 s" FF" >number
0 = verif
decimal
2drop 255 = verif

\ ---------------------------------------------------------------------------
\ B30 - signe en tete non converti (reste "-5", ud2 = 0)
\ ---------------------------------------------------------------------------
0 0 s" -5" >number
2 = verif
2drop 0 = verif

\ ---------------------------------------------------------------------------
\ B30 - base 2
\ ---------------------------------------------------------------------------
2 base !
0 0 s" 101" >number
0 = verif
decimal
2drop 5 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 46
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour46.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
