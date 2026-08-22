\ ============================================================
\ TEST-DEBUG-FAILS.FTH — Isole les tests echoues de P1
\ ============================================================
cr ." ======== DEBUG FAILS ========" cr

variable ok  0 ok !
variable ko  0 ko !
: pass  1 ok +! ." OK " ;
: fail  1 ko +! ." FAIL " ;
: ?t ( n expected -- ) = if pass else fail then ;

\ ---- SORTIE . u. ----
cr ." [. et u.]" cr
." 42 . " 42 . cr
." 255 u. " 255 u. cr

\ ---- .r ----
cr ." [.r]" cr
." 42 8 .r = [" 42 8 .r ." ]" cr
." 255 8 u.r = [" 255 8 u.r ." ]" cr

\ ---- PNO basique ----
cr ." [PNO]" cr
." 42 0 <# #s #> type = [" 42 0 <# #s #> type ." ]" cr
." 1234 0 <# # # 44 hold #s #> type = [" 1234 0 <# # # 44 hold #s #> type ." ]" cr
." -5 abs sign: [" -5 dup abs 0 <# #s rot sign #> type ." ]" cr
." 42 holds: [" 42 0 <# s" eur" holds #s #> type ." ]" cr

\ ---- DIAGNOSTIC ----
cr ." [DIAG]" cr
." base " base @ . cr
." 42 0 <# #s #> type => [" 42 0 <# #s #> type ." ]" cr
." 42 0 <# # #s #> type => [" 42 0 <# # #s #> type ." ]" cr
." depth => " depth . cr

cr cr ." OK:" ok @ . ."  FAIL:" ko @ . cr
