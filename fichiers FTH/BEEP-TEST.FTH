\ Test PC Speaker beep
\ Usage: in> beep-test.fth

\ Bip simple 1000 Hz 200ms
." Bip 1000Hz 200ms" cr
1000 200 beep

\ Bip aigu 2000 Hz 100ms
." Bip 2000Hz 100ms" cr
2000 100 beep

\ Bip grave 500 Hz 300ms
." Bip 500Hz 300ms" cr
500 300 beep

\ Sonnerie 3 tons
." Sonnerie 3 tons" cr
800 150 beep
1000 150 beep
1200 150 beep

\ Frequence limite basse (40 Hz) 500ms
." Bip 40Hz 500ms" cr
40 500 beep

." beep-test termine" cr
