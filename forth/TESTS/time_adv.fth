\ TESTS/time_adv.fth - Temps avance : timers periodiques (605/615), usleep
\ (606), uptime (607), ticks:us (608), delay-cycles (609), time:format (613),
\ perf:counter (614).
\ Valeurs attendues en commentaire. Mot : test-time-adv (auto-execute).
\ Conventions : usleep pompe le step_callback (tick_alarms) : on l'utilise
\ pour laisser les timers periodiques se declencher.

: test-time-adv
  \ --- uptime ( -- s ) : croissant ---
  uptime dup . constant U0
  U0 0 >= .                        \ -1
  uptime U0 >= .                  \ -1 : monotone (croissant ou egal)

  \ --- ticks:us ( -- us ) : croissant, resolution us ---
  ticks:us dup . constant T0
  T0 0> .                         \ -1 : positif
  ticks:us T0 >= .                \ -1 : monotone

  \ --- perf:counter ( -- tsc ) : non recale, croissant ---
  perf:counter dup . constant P0
  perf:counter P0 >= .            \ -1 : tsc avance

  \ --- delay-cycles ( n -- ) : no-op sur 0, sans crash sinon ---
  0 delay-cycles
  1000000 delay-cycles
  perf:counter P0 > .             \ -1 : le tsc a avance

  \ --- usleep ( us -- ) : mesure approximative ---
  ticks:us dup . constant T1
  5000 usleep
  ticks:us dup . constant T2
  T2 T1 - .                      \ ~5000 us (+/- granularite)
  T2 T1 - 3000 > .               \ -1 : au moins ~3 ms ecoules

  \ --- time:format ( s buf -- len ) : ISO 8601 ---
  here 32 0 fill
  1700000000 here time:format .  \ 19  (2023-11-14 22:13:20 UTC)
  here 19 type cr
  here 4 type cr                 \ "2023"

  \ --- periodic:new ( ms xt -- tid ) + periodic:cancel (615) ---
  variable p-count
  0 p-count !
  : on-tick  1 p-count +! ;
  2 on-tick periodic:new dup . constant TID
  TID 0<> .                      \ -1 : cree
  20000 usleep                    \ pompe step_callback ~20 ms -> le timer tire
  p-count @ .                    \ > 0  (periode 2 ms -> ~10 ticks)
  TID periodic:cancel
  20000 usleep
  p-count @ .                    \ stable (plus de ticks apres cancel)
  0 periodic:cancel              \ no-op, sans crash
;
test-time-adv
