# 🎓 Tutoriel Débutant : La Puissance du SDK C-Épona

Bienvenue dans le guide d'apprentissage de **C-Épona**, le langage Orienté Objet à syntaxe C compilé en JIT natif bare-metal sur le noyau Forth d'Épona OS 1.98.

ATTENTION NE PAS EXECUTER CE COMPILATEUR C JUSTE POUR INFO JUSTE UNE VISION DU FUTUR TANT QUE LA RELEASE 1.98 N'EST PAS TERMINER !!!!!
---

## 🎯 Objectif de ce Tutoriel

- **Tutoriel A : Version Réaliste (Epona OS 1.98 RC)**  
  → uniquement ce qui existe *vraiment* dans ton OS aujourd’hui  
  → GUI GOP, boutons, fenêtres, fichiers, JIT, classes, OOF, C‑RUN, C‑BUILD  
  → zéro promesse impossible

- **Tutoriel B : Version Futuriste (Epona OS 2.0 / 2027)**  
  → tout ce que tu veux atteindre  
  → PNG/JPG, alpha-blending, réseau HTTP, IA locale, multitâche, sockets  
  → un document visionnaire pour attirer les devs et les IA



---

# 🟢 **TUTORIEL A — C‑Épona (Version Réaliste, Epona OS 1.98 RC)**  
**Ce tutoriel correspond EXACTEMENT aux capacités actuelles de ton OS.**

## 🎓 Tutoriel Débutant : C‑Épona pour Epona OS 1.98 RC  
Langage Orienté Objet à syntaxe C → compilé en Forth ISO 2012 → JIT x86_64.

---

## 🚀 Étape 1 — Votre premier programme C‑Épona

Créez `hello.cep` :

```c
int main() {
    draw_string_utf8(50, 50, "Bonjour depuis C-Épona !", 0x00FF00);
    return 0;
}
```

### Exécution immédiate (JIT)
```forth
INCLUDE c-epona/c_epona.fth
C-RUN hello.cep
```

---

## 🎨 Étape 2 — Fenêtre & GUI 60 FPS (GOP)

```c
class Fenetre : Window {
    Button btn;
    int compteur;

    void init() {
        this.super("Ma Fenêtre", 640, 480);
        this.compteur = 0;
        this.btn = new Button("Cliquez-moi", 50, 80, 150, 40);
        this.add(this.btn);
    }

    void onRender() {
        this.renderWindow();
        draw_string_utf8(50, 150, "Compteur :", 0xFFFFFF);
    }
}

int main() {
    Fenetre f = new Fenetre();
    f.init();
    f.show();
    return 0;
}
```

---

## 📁 Étape 3 — Fichiers (EponaFS)

```c
class Save {
    File f;

    void writeScore() {
        this.f = new File();
        if (this.f.open(O_WRITE | O_CREATE, "score.txt")) {
            this.f.write("Score: 42", 10);
            this.f.close();
        }
    }
}
```

---

## 🔧 Étape 4 — Compilation en binaire `.EPA`

```forth
C-BUILD hello.cep hello.epa
```

Le fichier `.epa` peut être placé dans `/EFI/EPONA/`.

---

## 🎉 Fin du tutoriel réaliste  
Vous savez maintenant :

- créer une fenêtre  
- afficher du texte  
- utiliser un bouton  
- écrire un fichier  
- compiler en binaire autonome  

---

# 🔵 **TUTORIEL B — C‑Épona (Version Futuriste, Epona OS 2.0 / 2027)**  
**Ce tutoriel est visionnaire. Il montre ce que C‑Épona deviendra.**

---

# 🎓 Tutoriel Avancé : Le SDK C‑Épona 2.0  
GUI 60 FPS, PNG/JPG, réseau HTTP, IA locale, multitâche.

---

## 🚀 Étape 1 — Affichage PNG/JPG avec Alpha-Blending

```c
class AppImage : Window {
    Image logo;

    void init() {
        this.super("Images C-Épona", 800, 600);
        this.logo = new Image();
        this.logo.load("logo.png");
    }

    void onRender() {
        this.renderWindow();
        this.logo.drawAlpha(100, 100);
    }
}
```

---

## 🌐 Étape 2 — HTTP GET via EponaNet

```c
class Web {
    Socket s;

    void fetch() {
        this.s = new Socket();
        if (this.s.connect(80, "epona-os.org")) {
            this.s.send("GET /status HTTP/1.1\r\nHost: epona-os.org\r\n\r\n");
        }
    }
}
```

---

## 🤖 Étape 3 — IA Locale (modèle embarqué)

```c
class Assistant {
    LocalAI ai;

    void ask(string q) {
        this.ai = new LocalAI();
        this.ai.prompt(q);
    }
}
```

---

## 🔀 Étape 4 — Multithreading

```c
class Worker {
    Thread t;

    void startJob() {
        this.t = new Thread();
        this.t.run(() => {
            computeHeavyTask();
        });
    }
}
```

---

## 📦 Étape 5 — Compilation en `.EPA` signé

```forth
C-BUILD app.cep app.epa
```

---

# 🧠 Résultat : deux tutoriels parfaitement distincts

## 🟢 Tutoriel A (Réel, Epona OS 1.98 RC)
- GUI GOP  
- boutons  
- fenêtres  
- fichiers  
- JIT  
- compilation `.EPA`  
- classes C‑Épona  
- OOF Forth  

## 🔵 Tutoriel B (Futuriste, Epona OS 2.0)
- PNG/JPG  
- alpha-blending  
- sockets HTTP  
- IA locale  
- multitâche  
- threads  
- réseau complet  

---
