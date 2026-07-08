\ Test multitâche préemptif
\ 3 tâches qui clignotent à des fréquences différentes
\ Utilisation: in> test-task.fth

\ Tâche 1 : bip aigu rapide
: tache1
  begin
    2000 50 beep
    100 ms
  again ;

\ Tâche 2 : bip medium
: tache2
  begin
    1000 100 beep
    200 ms
  again ;

\ Tâche 3 : bip grave lent
: tache3
  begin
    500 200 beep
    500 ms
  again ;

\ Enregistrer les tâches
." Creation des taches..." cr
' tache1 task .
." task1 #" . cr
' tache2 task .
." task2 #" . cr
' tache3 task .
." task3 #" . cr

." Liste des taches:" cr
tasks

\ La tâche principale continue
: principal
  begin
    ." ."                      \ tick visuel
    100 ms
  again ;
