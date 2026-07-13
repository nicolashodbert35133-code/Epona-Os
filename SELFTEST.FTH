\ ============================================================
\ SELFTEST.FTH — Lance toute la batterie de tests Forth
\ ============================================================
\ Usage:  sys:load SELFTEST.FTH

cr ." ========================================" cr
cr ."   SELFTEST : lancement des tests" cr
cr ." ========================================" cr
cr ." " cr

sys:load TEST-CORE.FTH
cr ." " cr

sys:load TEST-LOOPS.FTH
cr ." " cr

sys:load TEST-EXCEPT.FTH
cr ." " cr

cr ." ========================================" cr
cr ."   TOUS LES TESTS TERMINES" cr
cr ." ========================================" cr
