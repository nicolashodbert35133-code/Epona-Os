\ TESTS/vm.fth - Primitives mémoire virtuelle / pagination (700-705, 714-717)
\ Valeurs attendues en commentaire. Mot : test-vm (auto-exécuté en fin de fichier).
\ Prérequis : mem-info doit tourner AVANT exit_boot_services (le bitmap allocator
\ physique lit la carte UEFI via get_memory_map, indisponible après EBS).
\ En debug loop (pré-EBS) c'est le cas ici ; en mode runtime sans mem-info préalable,
\ vm:init renvoie 0 et vm:alloc échoue (page-alloc sans bitmap = 0) — comportement sûr.

\ ---------- Prérequis : bitmap allocator physique ----------
mem-info . . .   \ total free used (informations, non testées)

\ ---------- Tests ----------
: test-vm
  \ --- vm:init ( -- ok? ) : map identité 0..max_phys (2 Mo) + bascule CR3 ---
  \ -1 si la self-check passe (CR3 basculé) ; 0 si refusé (tables firmware conservées)
  vm:init dup .
  constant VM-OK

  \ --- cr3@ ( -- pml4 ) : toujours non nul ---
  cr3@ dup . 0<> .   \ <pml4> + -1

  \ --- tlb:flush-all / tlb:flush (ne doit pas crasher) ---
  tlb:flush-all
  0x1000 tlb:flush

  \ --- vm:alloc ( pages -- vaddr ) : 4 pages physiques contiguës mappées en VA ---
  4 vm:alloc dup .      \ <vaddr> aligné page
  constant VA

  \ --- vm:virt->phys ( vaddr -- paddr? ) : traduction dans l'espace courant ---
  VA vm:virt->phys dup .   \ <paddr> physique réel de la 1re page
  constant PA
  PA 0<> .                 \ -1 : page mappée
  VA PA <> .               \ -1 : la VA est au-dessus de la RAM identité (≠ phys)

  \ --- Écriture/lecture via la VA (prouve que le mapping fonctionne) ---
  0xCAFEBABE VA 0 l!   VA 0 l@ 0xCAFEBABE = .   \ -1 : RAM accessible via la VA

  \ --- vm:free ( vaddr pages -- ) : libère la plage ---
  VA 4 vm:free
  VA vm:virt->phys 0= .    \ -1 : démapée

  \ --- vm:map / vm:unmap explicite (vaddr paddr flags -- ) ---
  page-alloc constant PPHYS
  4 vm:alloc constant VA2
  VA2 PPHYS 1 vm:map         \ 1 = write
  VA2 vm:virt->phys PPHYS = .   \ -1 : map OK (traduction = paddr demandé)
  0xDEAD VA2 0 l!  VA2 0 l@ 0xDEAD = .   \ -1 : RAM accessible
  VA2 vm:unmap
  VA2 vm:virt->phys 0= .     \ -1 : démapée
  VA2 4 vm:free
  PPHYS page-free
;

test-vm
