# F1 Data Analytics 

## 1. Sujet et Contexte 
Ce projet consiste en la création d'une base de données relationnelle automatisée dédiée à l'analyse des performances en Formule 1 pour n'importe quel saison.

**Le problème résolu :**
Les données brutes de sport automobile sont souvent dispersées, volumineuses et difficiles à corréler (ex: lier une pénalité textuelle à un numéro de voiture ou comparer des temps de stands sur deux saisons). Cette base de données centralise ces informations pour permettre des analyses croisées entre les résultats de course, la rapidité des arrêts aux stands et la discipline des pilotes.

---

## 2. Utilisateurs Cibles
Cette base de données est conçue pour les personnes qui s'interesse à la formule 1 et qui souhaite suivre la saison de façon simplifié avec beaucoup d'information.

---

## 3. Sources de Données
Le projet utilise exclusivement des données réelles et officielles :
* **OpenF1 API** : Une API haute fidélité fournissant des données en temps réel sur les sessions, les pilotes, les temps au tour et les décisions de la FIA.
* **Extraction Python** : Un script sur mesure a été développé pour extraire, nettoyer et transformer les données JSON de l'API en format CSV.

---

## 4. Construction du Projet
Le projet est bâti sur une architecture de pipeline de données classique :

Voici le bloc complet pour ton fichier README.md. J'ai mis l'accent sur l'arborescence des dossiers et le rôle de chaque fichier SQL (Schema, Seed, Query, Analysis) comme demandé par ton professeur.

Markdown
# F1 Data Analytics Pipeline (Multi-Saisons)

## 1. Sujet et Contexte
Ce projet est un pipeline de données automatisé (ETL) conçu pour extraire, structurer et analyser les performances de la Formule 1. Le système est **dynamique** : il permet de choisir n'importe quelle saison via le script d'extraction pour générer des analyses comparatives fiables.

**Le problème résolu :**
La donnée brute de l'API OpenF1 est fragmentée. Ce projet automatise la centralisation de ces flux pour permettre des analyses croisées entre les résultats de course, la rapidité des arrêts aux stands et la discipline des pilotes, peu importe l'année choisie.

---

## 2. Utilisateurs Cibles
* **Analystes de données** : Pour comparer les évolutions de performances entre différentes ères.
* **Ingénieurs de stratégie** : Pour étudier les temps de stands moyens par écurie.
* **Journalistes et Fans** : Pour générer des classements historiques (ex: "Bad Boys" de la saison 2024 vs 2025).

---

## 3. Architecture du Projet et Liens

Le projet est organisé de manière modulaire pour séparer l'extraction, le stockage et l'analyse :

```text
.
├── data/                   # Données brutes et nettoyées (CSV)
│   ├── 2024/               # Fichiers de la saison 2024
│   └── 2025/               # Fichiers de la saison 2025
├── scripts/                
│   └── data.py.py       # Script de scrapping Python (API OpenF1 -> CSV)
├── sql/                    
│   ├── schema.sql          # Structure des tables et des views
│   ├── seed.sql            # Scripts d'importation des données CSV
│   ├── queries.sql         # Requêtes de manipulation de base
│   └── analysis.sql        # Vues analytiques et statistiques avancées
├── DESIGN.md               # Documentation de conception (ER)
└── README.md               # Présentation du projet
```
---

## 4. Installation Rapide
1. Installer les dépendances : `pip install -r requirements.txt`.
2. Lancer l'extraction : `python main.py` en choisissant l'année que vous voulez.
3. Initialiser la base : Exécuter `schema.sql` dans votre gestionnaire SQLite.
