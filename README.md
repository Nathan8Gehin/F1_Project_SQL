# F1 Data Analytics Pipeline (2024-2025)

## 1. Sujet et Contexte
Ce projet consiste en la création d'une base de données relationnelle automatisée dédiée à l'analyse des performances en Formule 1 pour les saisons **2024 et 2025**.

**Le problème résolu :**
Les données brutes de sport automobile sont souvent dispersées, volumineuses et difficiles à corréler (ex: lier une pénalité textuelle à un numéro de voiture ou comparer des temps de stands sur deux saisons). Cette base de données centralise ces informations pour permettre des analyses croisées entre les résultats de course, la rapidité des arrêts aux stands et la discipline des pilotes.

---

## 2. Utilisateurs Cibles
Cette base de données est conçue pour :
* **Analystes de données sportives** : Pour identifier des tendances de performance sur le long terme.
* **Ingénieurs de stratégie** : Pour comparer les temps de pit-stop moyens entre les écuries.
* **Journalistes spécialisés** : Pour extraire rapidement des statistiques fiables (ex: classement des "Bad Boys" les plus pénalisés).
* **Développeurs d'applications F1** : Comme backend pour des tableaux de bord (Dashboards) de visualisation.

---

## 3. Sources de Données
Le projet utilise exclusivement des données réelles et officielles :
* **OpenF1 API** : Une API haute fidélité fournissant des données en temps réel sur les sessions, les pilotes, les temps au tour et les décisions de la FIA.
* **Extraction Python** : Un script sur mesure a été développé pour extraire, nettoyer et transformer les données JSON de l'API en formats exploitables (CSV/SQL).

---

## 4. Construction du Projet
Le projet est bâti sur une architecture de pipeline de données classique :

### Architecture Technique
1. **Extraction (Python)** : Utilisation de la bibliothèque `requests` pour interroger l'API. Gestion du nettoyage des données (notamment l'extraction des numéros de pilotes dans les rapports de pénalités via Regex).
2. **Stockage (SQLite)** : Choix d'un moteur SQL léger et performant pour gérer les relations entre les circuits, les courses, les pilotes et les écuries.
3. **Transformation (SQL Views)** : Implémentation d'une couche de "Business Logic" via des Vues SQL pour corriger dynamiquement les transferts de pilotes (ex: Hamilton chez Mercedes en 2024 et Ferrari en 2025) sans altérer les données brutes.

### Structure des Dossiers
* `/data` : Contient les exports CSV par saison.
* `/scripts` : Scripts Python d'automatisation de l'extraction.
* `schema.sql` : Script de création des tables, des contraintes d'intégrité et des vues analytiques.
* `DESIGN.md` : Documentation technique détaillée de l'architecture.

---

## 5. Installation Rapide
1. Installer les dépendances : `pip install -r requirements.txt`
2. Lancer l'extraction : `python main.py`
3. Initialiser la base : Exécuter `schema.sql` dans votre gestionnaire SQLite (ex: DB Browser for SQLite).
