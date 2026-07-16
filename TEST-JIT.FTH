\ test-jit.fth — Tests des primitives JIT x86-64
\ Teste les 30 primitives supportées par le JIT
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

CR ." === JIT Prototype Tests ===" CR

CR ." test-constant: " test-constant . CR
CR ." test-add (3+4=7): " test-add . CR
CR ." test-mul (6*7=42): " test-mul . CR
CR ." test-sub (10-3=7): " test-sub . CR
CR ." test-stack (dup+ => 4+4=8): " 4 test-stack . CR
CR ." test-logic (0xFF AND 0x0F = 15): " test-logic . CR
CR ." test-shift (1<<8 = 256): " test-shift . CR
CR ." test-compare (5=5 => 1): " test-compare . CR
CR ." test-mem (! then @ => 42): " test-mem . CR

CR ." === All JIT tests done ===" CR
