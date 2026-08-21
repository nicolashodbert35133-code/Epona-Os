\ ============================================================================
\ forth/TESTS/debug_assert.fth - Test des primitives Debug Jour 63
\ ============================================================================

-1 assert
42 42 assert=

: test-assert-fail  0 assert ;
' test-assert-fail catch
-256 = if ." [PASS] assert echoue sur 0" cr
else ." [FAIL]" cr then

: test-assert=-fail  1 2 assert= ;
' test-assert=-fail catch
-256 = if ." [PASS] assert= detecte 1<>2" cr
else ." [FAIL]" cr then

vm:dict-stats
depth 3 = if ." [PASS] vm:dict-stats depth=3" cr else ." [FAIL]" cr then
2drop drop

3 log:level!
s" test trace" log:trace
2 log:level!
s" test info"  log:info
1 log:level!
s" test error" log:error
0 log:level!
s" invisible"  log:trace
." [PASS] log:* OK" cr
