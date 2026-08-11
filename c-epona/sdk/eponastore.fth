\ ==============================================================================
\ c-epona/sdk/eponastore.fth - Packaging & App Store (.EPA) pour C-Épona
\ ==============================================================================

INCLUDE c-epona/oof.fth

CLASS: AppPackage
    PTR-FIELD: Pkg.Name
    PTR-FIELD: Pkg.Version
    PTR-FIELD: Pkg.Author

: PKG-BUILD-EPA ( output-epa-path app-obj -- )
    >R
    CR ." [EPONA STORE] Génération du paquet .EPA signé..." CR
    BUILD-EPA-PACKAGE-NAT
    CR ." [EPONA STORE] Paquet d'application .EPA généré !" CR
    RDROP
;
