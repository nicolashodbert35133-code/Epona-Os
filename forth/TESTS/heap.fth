\ TESTS/heap.fth - Heap POSIX : mmap/munmap/mprotect/brk/sbrk (706-710)
\ Valeurs attendues en commentaire. Mot : test-heap (auto-execute en fin de fichier).
\ Prerequis : mem-info (bitmap) puis vm:init (bascule CR3) - comme TESTS/vm.fth.
\ La zone heap (1 TiB) et les mapping mmap vivent dans les tables de pages
\ actives (les siennes si vm:init a bascule, sinon celles du firmware).
\ ATTENTION : les adresses brk/mmap sont de VRAIES adresses virtuelles (RAM
\ via page tables), PAS la memoire scratch self.memory. On y accede en c!/l!/fill.

mem-info . . .                    \ total free used (informations, non testees)
vm:init dup . constant VM-OK      \ -1 si la self-check passe (sinon tables firmware)

\ Constantes POSIX (a definir cote Forth, cf. DEV_GUIDE_PRIMITIVES.md 5.2)
1 constant PROT-READ
2 constant PROT-WRITE
4 constant PROT-EXEC
1 constant MAP-SHARED
2 constant MAP-PRIVATE
16 constant MAP-FIXED
32 constant MAP-ANON

\ ---------- Tests ----------
: test-heap
  \ --- brk ( addr -- newbrk ) : 0 = requete du break courant ---
  0 brk dup . constant HEAP0      \ break initial (1 TiB = 0x10000000000)
  HEAP0 0<> .                     \ -1 : jamais 0

  \ --- brk : extension de 1 octet (-> 1 page) ; break reel = demande ---
  HEAP0 1 + brk dup . constant HEAP1   \ HEAP0+1
  HEAP1 HEAP0 1 + = .             \ -1

  \ --- brk : nouvelle requete -> inchange ---
  0 brk HEAP1 = .                 \ -1

  \ --- brk : adresse sous la base -> refusee (break inchange) ---
  0 brk constant CB               \ break courant
  CB 4096 - brk CB = .            \ -1 : refuse (sous la base du heap)

  \ --- sbrk ( n -- oldbrk ) : renvoie l'ANCIEN break ---
  CB sbrk dup . constant SB0      \ CB
  4096 sbrk dup . constant SB1    \ CB (ancien)
  0 brk SB1 4096 + = .            \ -1 : le break a avance de 4096

  \ --- sbrk negatif : shrink ---
  -4096 sbrk dup . constant SB2   \ SB1+4096 (ancien)
  0 brk SB2 -4096 + = .           \ -1 : revenu

  \ --- acces reel aux pages du heap via l! / l@ / c! / c@ ---
  HEAP1 0x12345678 l!             \ ecrit 32 bits dans la 1re page du heap
  HEAP1 l@ .                      \ 0x12345678
  HEAP1 10 + 0xAB c!              \ ecrit un octet
  HEAP1 10 + c@ .                 \ 0xAB

  \ --- mmap ( addr len prot flags fd offset -- addr ) ---
  0 8192 PROT-READ PROT-WRITE OR MAP-PRIVATE MAP-ANON OR -1 0 mmap dup . constant M
  M 0<> .                         \ -1 : mappe
  M vm:virt->phys 0<> .           \ -1 : la page physique est traduite
  M 0xCAFE l!  M l@ .             \ 0xCAFE : ecrit/lit via l!/l@
  M 2048 + 0x55 c!  M 2048 + c@ . \ 0x55 : octet dans la 1re page
  0 4096 PROT-READ MAP-PRIVATE MAP-ANON OR -1 0 mmap dup . constant M2
  M2 M <> .                       \ -1 : allocations VMA distinctes

  \ --- mprotect ( addr len prot -- ok? ) ---
  M 8192 PROT-READ mprotect .     \ -1 : ok
  M 8192 PROT-READ PROT-WRITE OR mprotect .   \ -1 : ok
  M 8192 0 mprotect .             \ -1 : ok (prot 0 = no access)
  -1 4096 PROT-READ mprotect .    \ 0 : adresse invalide -> refuse

  \ --- munmap ( addr len -- ok? ) ---
  M 8192 munmap .                 \ -1
  M vm:virt->phys 0= .            \ -1 : demappe (traduction -> 0)
  M2 4096 munmap .                \ -1

  \ --- mmap MAP_FIXED sur adresse haute alignee (64 TiB, canonique) ---
  0x400000000000 4096 PROT-READ PROT-WRITE OR MAP-PRIVATE MAP-ANON OR MAP-FIXED OR -1 0 mmap dup . constant MF
  MF 0x400000000000 = .           \ -1 : mappe exactement la
  MF l@ .                         \ 0 : pages zeroees par mmap
  MF 4096 munmap .                \ -1 : cleanup

  \ --- mmap MAP_FIXED sur adresse non alignee -> 0 ---
  0x400000000001 4096 PROT-READ MAP-PRIVATE MAP-ANON OR MAP-FIXED OR -1 0 mmap .   \ 0

  \ --- mmap sans MAP_ANON -> 0 (pas de backing fichier) ---
  0 4096 PROT-READ MAP-PRIVATE -1 0 mmap .   \ 0

  \ --- mmap len 0 -> 0 ---
  0 0 PROT-READ MAP-PRIVATE MAP-ANON OR -1 0 mmap .   \ 0
;
\ Le heap n'est pas detruit en fin de fichier (global au systeme, comme vm:alloc).
test-heap
