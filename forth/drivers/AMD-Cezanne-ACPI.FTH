\ ══════════════════════════════════════════════════════════
\ AMD-Cezanne-ACPI.FTH
\ Marque:   AMD
\ Ref:      Tables ACPI — Platform Cezanne
\ Tables:   RSDP, RSDT/XSDT, FADT, DSDT,
\           FACS, HPET, APIC, SSDT, MCFG
\ UEFI:     ACPI 6.x compatible
\ Primitives: acpi-rsdp, acpi-find, acpi-tables, acpi-hdr
\ ══════════════════════════════════════════════════════════

\ --- Scan ---
: amd-cezanne-acpi-scan
  cr
  cr ." === AMD Cezanne ACPI ==="
  cr ."  Marque:      AMD"
  cr ."  Ref:         Tables ACPI Cezanne"
  cr ."  UEFI:        ACPI 6.x"
  cr
  cr ."  Recherche RSDP..."
  acpi-rsdp
  cr ."    Adresse RSDP: " hex u. decimal cr
  cr
  cr ."  Tables ACPI détectées:"
  acpi-tables
  cr
  cr ." AMD Cezanne ACPI scan OK." cr
;

\ --- Détail ---
: amd-cezanne-acpi-detail
  cr
  cr ." === AMD Cezanne ACPI — Détail ==="
  cr
  cr ."  RSDT/XSDT:"
  "RSDT" acpi-find if
    cr ."    Trouvé: " hex u. decimal cr
    acpi-hdr
    cr ."    Taille: " u. ." octets" cr
  else
    cr ."    Non trouvé"
  then
  cr
  cr ."  DSDT:"
  "DSDT" acpi-find if
    cr ."    Trouvé: " hex u. decimal cr
    acpi-hdr
    cr ."    Taille: " u. ." octets" cr
  else
    cr ."    Non trouvé"
  then
  cr
  cr ."  FADT:"
  "FACP" acpi-find if
    cr ."    Trouvé: " hex u. decimal cr
    acpi-hdr
    cr ."    Taille: " u. ." octets" cr
  else
    cr ."    Non trouvé"
  then
  cr
  cr ."  MADT (APIC):"
  "APIC" acpi-find if
    cr ."    Trouvé: " hex u. decimal cr
    acpi-hdr
    cr ."    Taille: " u. ." octets" cr
  else
    cr ."    Non trouvé"
  then
  cr
  cr ."  HPET:"
  "HPET" acpi-find if
    cr ."    Trouvé: " hex u. decimal cr
  else
    cr ."    Non trouvé"
  then
  cr
;

\ --- Init ---
: amd-cezanne-acpi-init
  cr
  cr ." --- AMD Cezanne ACPI INIT ---"
  amd-cezanne-acpi-scan
  amd-cezanne-acpi-detail
  cr ." AMD Cezanne ACPI init OK." cr
;
