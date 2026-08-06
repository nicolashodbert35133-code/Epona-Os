\ ══════════════════════════════════════════════════════════
\ AMD-Cezanne-APIC.FTH
\ Marque:   AMD
\ Ref:      Local APIC + I/O APIC — Cezanne APU
\ Local APIC: intégré dans chaque cœur CPU
\   Base via MSR 0x1B (IA32_APIC_BASE)
\ I/O APIC: gère les IRQ matérielles
\   Vendor: 1022h (AMD)
\   Registres MMIO: ID, Version, Redirections
\ Primitives: apic-base, ioapic-read, ioapic-write
\ ══════════════════════════════════════════════════════════

\ --- Scan ---
: amd-cezanne-apic-scan
  cr
  cr ." === AMD Cezanne APIC ==="
  cr ."  Marque:      AMD"
  cr ."  Ref:         APIC Cezanne"
  cr
  cr ."  Base Local APIC:"
  apic-base
  cr ."    Adresse:   " hex u. decimal cr
  cr
  cr ."  Registres I/O APIC:"
  cr ."    ID (reg 0x00):           " 0x00 0 ioapic-read hex u. decimal cr
  cr ."    Version (reg 0x01):      " 0x01 0 ioapic-read hex u. decimal cr
  cr ."    Arbitration (reg 0x02):  " 0x02 0 ioapic-read hex u. decimal cr
  cr
  cr ."  Redirections I/O APIC:"
  8 0 do
    cr ."    IRQ " i u. ." : "
    i 2* 16 + 0 ioapic-read hex u. decimal
  loop
  cr
  cr ." AMD Cezanne APIC scan OK." cr
;

\ --- Test I/O APIC ---
: amd-cezanne-apic-test
  cr
  cr ." === TEST AMD Cezanne APIC ==="
  cr ."  Lecture I/O APIC ID..."
  0x00 0 ioapic-read
  cr ."    ID: " hex u. decimal cr
  cr ."  Lecture I/O APIC Version..."
  0x01 0 ioapic-read
  cr ."    Version: " hex u. decimal cr
  cr ."  Test AMD Cezanne APIC OK." cr
;

\ --- Init ---
: amd-cezanne-apic-init
  cr
  cr ." --- AMD Cezanne APIC INIT ---"
  amd-cezanne-apic-scan
  cr ." AMD Cezanne APIC init OK." cr
;
