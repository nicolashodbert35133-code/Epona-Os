# Contribuer à Epona OS

Merci de votre intérêt ! Voici comment contribuer.

## Pour commencer

1. Forkez le repo
2. Créez une branche (`git checkout -b ma-feature`)
3. Commitez (`git commit -m "Ajout de ..."`)
4. Poussez (`git push origin ma-feature`)
5. Ouvrez une Pull Request

## Types de contributions

### 🟢 Facile (pas besoin de connaître Rust)
- Tester sur votre machine et ouvrir une Issue
- Écrire des programmes Forth (.FTH)
- Corriger des fautes dans la documentation
- Traduire en anglais

### 🟡 Moyen (Forth ou Rust basique)
- Écrire un jeu en Forth
- Écrire un driver en Forth
- Ajouter des tests dans le dossier fichiers FTH comme TESTS.FTH
- Créer un tutoriel

### 🔴 Avancé (Rust bare-metal)
- Ajouter des primitives matériel
- Améliorer le compilateur Forth
- Optimiser les drivers GPU
- Implémenter le JIT x86-64

## Convention de code

### Rust
- `cargo fmt` avant chaque commit
- Pas de `unsafe` sans commentaire justificatif
- Chaque primitive documentée avec stack effect

### Forth
- Stack effect obligatoire : `( avant -- après )`
- Noms en minuscules avec `:` pour les modules
- Tests pour chaque nouveau mot

## Rapporter un bug

Ouvrez une Issue avec :
- Votre matériel (CPU, GPU, carte mère)
- Ce que vous avez tapé
- Ce qui s'est passé
- Ce que vous attendiez
