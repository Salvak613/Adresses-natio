# Architecture du Projet

## 📁 Organisation des Dossiers

### `/config` - Configuration Docker et Scripts Système

Contient tous les fichiers de configuration Docker et les scripts système :
- **Dockerfile** : Image PostgreSQL personnalisée avec curl pour télécharger les données
- **download-all.sh** : Script bash qui télécharge tous les fichiers CSV depuis data.gouv.fr
- **urls.txt** : Liste des URLs des fichiers CSV à télécharger (un par département)

### `/sql` - Scripts SQL

#### `/sql/init` - Scripts d'Initialisation

Scripts exécutés automatiquement au premier démarrage du conteneur PostgreSQL (ordre alphabétique) :

1. **00-download.sql** : Appelle le script `download-all.sh` pour télécharger les données
2. **01-import-csv.sql** : Importe les données CSV brutes dans une table temporaire
3. **02-schema.sql** : Crée les tables normalisées selon le MLD
4. **04-transformation.sql** : Transforme et normalise les données de la table temporaire vers les tables finales

#### `/sql/queries` - Requêtes SQL

Requêtes SQL prêtes à l'emploi pour diverses opérations :
- **jeu-essai** : Données de test pour valider le schéma
- **requête-analyse** : Analyses statistiques et agrégations
- **requête-avancée** : Requêtes complexes avec jointures multiples
- **requête-consultation** : Consultations simples des données
- **requête-detection-qualité** : Détection d'anomalies et problèmes de qualité
- **requête-insertion** : Insertion de nouvelles données

#### `/sql/scripts` - Scripts Utilitaires

Scripts SQL pour la maintenance :
- **script-vidage-tables** : Nettoie toutes les tables (TRUNCATE)

### `/data` - Données

Stockage des fichiers CSV téléchargés :
- Les fichiers CSV volumineux sont ignorés par Git (voir `.gitignore`)
- Contient les données brutes avant import dans PostgreSQL

### `/docs` - Documentation

Documentation complète du projet :
- **MCD-MLD-MPD-Dico.md** : Documentation des modèles de données
- **Sans-titre-2025-03-11-1826.svg** : Diagramme visuel des modèles
- **README-original.md** : Documentation originale du projet
- **adressToCheck.md** : Notes techniques sur les adresses
- **ARCHITECTURE.md** : Ce fichier

## 🔄 Flux de Données

```
1. Téléchargement
   ├─> download-all.sh lit urls.txt
   └─> Télécharge les CSV dans /tmp

2. Import
   ├─> 01-import-csv.sql crée table temporaire
   └─> Charge tous les CSV dans cette table

3. Transformation
   ├─> 02-schema.sql crée les tables finales
   └─> 04-transformation.sql normalise les données

4. Utilisation
   └─> Requêtes dans /sql/queries
```

## 🐳 Configuration Docker

### docker-compose.yml

Définit le service PostgreSQL avec :
- Port exposé : 5433 (au lieu de 5432 pour éviter les conflits)
- Volume persistant pour les données
- Montage des scripts SQL dans `/docker-entrypoint-initdb.d/`
- Healthcheck pour vérifier la disponibilité

### Dockerfile

Basé sur `postgres:15` avec :
- Installation de `curl` pour télécharger les données
- Copie des scripts de téléchargement
- Conversion des fins de ligne (CRLF → LF)

## 🔧 Bonnes Pratiques

### Nomenclature des Fichiers

- Scripts d'init : Préfixe numérique (00-, 01-, 02-...) pour l'ordre d'exécution
- Scripts SQL : Nom descriptif en français
- Pas d'espaces dans les noms de fichiers (utiliser `-` ou `_`)

### Gestion des Données

- Les CSV volumineux sont ignorés par Git
- Les données sont stockées dans un volume Docker persistant
- Reconstruction possible à tout moment depuis les sources

### Sécurité

- Les credentials sont dans `docker-compose.yml` (dev uniquement)
- Pour la production, utiliser des variables d'environnement (`.env.local`)
- Port personnalisé (5433) pour éviter les conflits

## 📊 Modèle de Données

Voir [MCD-MLD-MPD-Dico.md](./MCD-MLD-MPD-Dico.md) pour :
- Modèle Conceptuel de Données (MCD)
- Modèle Logique de Données (MLD)
- Modèle Physique de Données (MPD)
- Dictionnaire de données complet
