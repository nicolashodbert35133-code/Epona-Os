\ TEST-P1-PNO.FTH — Section 3.11 PNO + 3.12 Entree
cr ." [3.11 PNO]" cr

variable ok  0 ok !
variable ko  0 ko !
: pass  1 ok +! ."  OK " ;
: fail  1 ko +! ."  FAIL " ;
: ?t ( n expected -- ) = if pass else fail then ;

\ PNO basique : <# #s #>
cr ." [PNO basique]" cr
." 42 0 <# #s #> => [" 42 0 <# #s #> type ." ]" cr

\ hold
cr ." [hold]" cr
." 1234 0 <# # # 44 hold #s #> => [" 1234 0 <# # # 44 hold #s #> type ." ]" cr

\ sign
cr ." [sign]" cr
." -5 abs => [" -5 dup abs 0 <# #s rot sign #> type ." ]" cr

\ holds
cr ." [holds]" cr
: holds-test 42 0 <# s" eur" holds #s #> ;
." holds-test => [" holds-test type ." ]" cr

\ Verification stack
42 0 <# #s #> s" 42" compare 0 = if -1 else 0 then pass cr

cr ." [3.12 Entree (non-bloquant)]" cr
." touche?  " touche? drop pass cr
." key?     " key? drop pass cr
." touche:inject " 65 touche:inject pass cr

cr ." PNO+Entree: OK:" ok @ . ." FAIL:" ko @ . cr
