\ ============================================================
\ MUTEX.FTH  —  Mutex simple pour EponaForth (scheduler préemptif)
\ ============================================================
\ Dépendances : critical-begin / critical-end (runtime Rust)
\ ============================================================

\ ─── Structure du mutex ─────────────────────────────────────
\ Chaque mutex est un buffer de 3 cellules :
\   0: lock     (0=libre, 1=pris)
\   1: owner    (task_id du propriétaire, ou -1)
\   2: depth    (compteur de réentrance)

struct mutex-slot
  field .lock
  field .owner
  field .depth
end-struct

\ ─── Création d'un mutex ────────────────────────────────────
: mutex:create ( -- addr )
  mutex-slot buffer: _mx
  _mx
;

\ ─── Lock ───────────────────────────────────────────────────
: mutex:lock ( mx -- )
  begin
    critical-begin
    dup .lock @ 0= if
      \ Libre → on prend
      -1 .lock !         \ lock=1 (toute valeur != 0)
      -1 .owner !        \ owner (sera mis à jour)
      1 .depth !
      critical-end
      drop
      exit
    then
    critical-end
  again
;

\ ─── Unlock ─────────────────────────────────────────────────
: mutex:unlock ( mx -- )
  critical-begin
  0 swap .lock !
  critical-end
;

\ ─── Test simple ────────────────────────────────────────────
cr ." MUTEX.FTH charge" cr
cr ." Exemple :" cr
cr ."   mutex:create constant mon-mutex" cr
cr ."   mon-mutex mutex:lock" cr
cr ."   ... section critique ..." cr
cr ."   mon-mutex mutex:unlock" cr
