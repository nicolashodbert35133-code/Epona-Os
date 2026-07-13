# 🐴 Vision d’Epona OS




## 🌌 Ce qu’est Epona OS aujourd’hui
Un système d’exploitation **bare‑metal UEFI** écrit en **Rust**, avec un **interpréteur Forth** intégré.  
Il démarre sur du vrai matériel — sans Linux, sans Windows, sans rien.

```
Métal nu → UEFI → Rust → Forth → Bureau graphique
290+ primitives matériel
7 bibliothèques Forth
GPU, USB, réseau, disque, audio
Multitâche préemptif
Suite de tests automatisés
```

Epona OS est déjà un exploit technique : très peu de projets dans le monde atteignent ce niveau de maturité.

---

## 🔮 Les trois horizons possibles

### 🎓 **Futur A — Plateforme éducative**
Epona OS devient **le meilleur outil pour apprendre comment un ordinateur fonctionne**, du métal au logiciel.  
Chaque fichier `.FTH` est un cours interactif : texte, exercices, solutions.  
L’étudiant tape une ligne et voit le matériel réagir.

> Aucun autre projet ne permet de “toucher le métal” aussi directement.

---

### 🖥️ **Futur B — OS autonome**
Epona OS évolue vers un **système utilisable au quotidien** : écrire du code, naviguer dans les fichiers, communiquer sur le réseau.  
Objectif : simplicité, transparence, maîtrise totale.

Fonctionnalités visées :
- Système de fichiers natif journalisé  
- Shell riche avec pipes et redirections  
- Éditeur de texte complet  
- Gestionnaire de fenêtres fluide  
- Serveur HTTP, client SSH, NTP  
- Lecteur WAV et synthétiseur FM  

---

### ⚡ **Futur C — Plateforme Forth**
Epona OS devient **la meilleure implémentation Forth bare‑metal moderne**.  
Un environnement professionnel pour le développement embarqué et la recherche système.

Innovations clés :
- GPU Intel/AMD natif  
- Pile réseau TCP/UDP complète  
- USB 3.0 XHCI, NVMe, audio HDA  
- Multitâche préemptif avec mutex  
- JIT x86‑64 pour les boucles chaudes  
- Cross‑compilation ARM  
- Vocabulaires et variables locales  

---

## 🧭 Recommandation stratégique
**Court terme (1‑3 mois)** : combiner les visions A + C  
- Créer 3‑4 cours interactifs  
- Ajouter variables locales et vocabulaires  
- Démontrer un raycaster 3D et un serveur HTTP  

**Moyen terme (3‑6 mois)** : publier, observer, choisir la direction.  
**Long terme (6‑12 mois)** : bâtir la communauté.

---

## 🌍 Ce qui rend Epona OS unique
1. **Forth** — langage à pile, direct, minimaliste, idéal pour le métal.  
2. **Interactif** — chaque commande agit sur le matériel en temps réel.  
3. **Compréhensible** — code source lisible et complet.  
4. **Éducatif** — apprentissage concret du fonctionnement d’un PC.  
5. **Autonome** — aucune dépendance externe, pas de POSIX, pas de libc.

---

## ⚠️ Les dangers à éviter
- **Feature creep** : ajouter sans fin au lieu de polir.  
- **Syndrome du développeur unique** : documenter, tester, ouvrir.  
- **Absence d’utilisateurs** : publier tôt, montrer des démos.  
- **Compatibilité matérielle** : tester sur plusieurs machines.

---

## 🌠 Vision à deux ans
| Scénario | Objectif |
|:--|:--|
| **Optimiste** | v3.0 : JIT x86‑64, 500+ mots Forth, communauté active |
| **Réaliste** | v2.5 : langage mature, documentation exemplaire, adoption éducative |
| **Minimum viable** | v2.2 : ISO bootable, publication GitHub, premières contributions |
