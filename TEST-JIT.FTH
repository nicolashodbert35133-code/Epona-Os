\ test-jit.fth — Tests des primitives JIT x86-64
\ Teste les 30 primitives + IF/ELSE/THEN supportes par le JIT
\ Le JIT compile les mots au premier appel (lazy)

: test-constant 42 ;
: test-add 3 4 + ;
: test-mul 6 7 * ;
: test-sub 10 3 - ;
: test-stack dup + ;
: test-logic 0xFF 0x0F and ;
: test-shift 1 8 lshift ;
: test-compare 5 5 = ;
: test-mem 0 here ! 42 here @ ;

\ Tests IF/ELSE/THEN (Phase 2 JIT)
: test-if-true 1 if 99 else 0 then ;
: test-if-false 0 if 0 else 77 then ;
: test-if-nested 5 3 > if 10 2 > if 42 else 0 then else 0 then ;

CR ." === JIT Phase 1+2 Tests ===" CR

CR ." test-constant: " test-constant . CR
CR ." test-add (3+4=7): " test-add . CR
CR ." test-mul (6*7=42): " test-mul . CR
CR ." test-sub (10-3=7): " test-sub . CR
CR ." test-stack (dup+ => 4+4=8): " 4 test-stack . CR
CR ." test-logic (0xFF AND 0x0F = 15): " test-logic . CR
CR ." test-shift (1<<8 = 256): " test-shift . CR
CR ." test-compare (5=5 => 1): " test-compare . CR
CR ." test-mem (! then @ => 42): " test-mem . CR

CR ." --- Phase 2: IF/ELSE/THEN ---" CR
CR ." test-if-true (1 => 99): " test-if-true . CR
CR ." test-if-false (0 => 77): " test-if-false . CR
CR ." test-if-nested (5>3 && 3>2 => 42): " test-if-nested . CR

CR ." === All JIT tests done ===" CR
