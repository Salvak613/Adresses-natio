# Base de Données d'Adresses PostgreSQL - France

Projet de base de données relationnelle pour gérer les adresses en France, basé sur les données de la Base Adresse Nationale (BAN). Cette base de données contient **toutes les adresses des 109 départements français** (métropole + DOM-TOM).

## 📋 Table des matières

- [Installation et lancement](#-installation-et-lancement)
- [Architecture du projet](#-architecture-du-projet)
- [Données importées](#-données-importées)
- [Choix de modélisation](#-choix-de-modélisation)
- [Structure de la base de données](#-structure-de-la-base-de-données)
- [Exemples de requêtes](#-exemples-de-requêtes)
- [Scripts SQL disponibles](#-scripts-sql-disponibles)
- [Fonctionnalités avancées](#-fonctionnalités-avancées)
- [Maintenance et dépannage](#-maintenance-et-dépannage)

---

## 🚀 Installation et lancement

### Prérequis

- **Docker** et **Docker Compose** installés ([Télécharger Docker](https://www.docker.com/get-started))
- **DBeaver** ou tout autre client PostgreSQL ([Télécharger DBeaver](https://dbeaver.io/download/))
- Au moins **20 GB d'espace disque libre** (pour les données de tous les départements)
- **Connexion internet** pour télécharger les fichiers CSV depuis data.gouv.fr

### Étapes de lancement

#### 1. Cloner ou télécharger le projet

```bash
cd a:\www\ddb-postgre
```

#### 2. Lancer la construction et le démarrage

```bash
docker-compose up -d
```

Cette commande va :

- ✅ Construire l'image Docker avec PostgreSQL 15 + curl
- ✅ Créer le conteneur `ddb_postgre_natio`
- ✅ Télécharger automatiquement les CSV des **109 départements** depuis data.gouv.fr
- ✅ Importer toutes les données dans PostgreSQL
- ✅ Créer les tables normalisées
- ✅ Transformer et organiser les données

⚠️ **Attention** : Le premier lancement peut prendre **30 minutes à 2 heures** selon votre connexion internet (téléchargement de ~5-10 GB de données compressées).

#### 3. Suivre la progression

```bash
docker logs -f ddb_postgre_natio
```

Vous verrez :

- Le téléchargement des fichiers CSV département par département
- L'import des données dans la table brute `adresses`
- La création des tables normalisées
- La transformation des données

Pour arrêter l'affichage des logs : `Ctrl+C`

#### 4. Vérifier que le conteneur fonctionne

```bash
docker-compose ps
```

Vous devriez voir :

```
NAME                  STATUS        PORTS
ddb_postgre_natio     running      0.0.0.0:5433->5432/tcp
```

#### 5. Se connecter avec DBeaver

Paramètres de connexion :

- **Host** : `localhost`
- **Port** : `5433` (⚠️ Attention : pas 5432, pour éviter les conflits)
- **Database** : `adresses_natio`
- **Username** : `admin`
- **Password** : `admin123`

#### 6. Vérifier que les données sont bien importées

```sql
-- Compter le nombre total d'adresses
SELECT COUNT(*) FROM adresses;

-- Vérifier les départements importés
SELECT code_departement, nom_departement, COUNT(*) as nb_communes
FROM departement d
JOIN commune c ON c.id_departement = d.id
GROUP BY d.code_departement, d.nom_departement
ORDER BY d.code_departement;
```

### Redémarrer proprement

Si vous souhaitez repartir de zéro (par exemple après une modification des scripts SQL) :

```bash
# Arrêter et supprimer le conteneur + volumes
docker-compose down -v

# Relancer
docker-compose up -d
```

---

## 🏗️ Architecture du projet

### Structure des fichiers

```
ddb-postgre/
│
├── docker-compose.yml                  # Configuration Docker
├── Dockerfile                          # Image PostgreSQL personnalisée
│
├── urls.txt                            # Liste des 109 URLs de départements
├── download-all.sh                     # Script de téléchargement des CSV
│
├── 00-download.sql                     # Téléchargement des fichiers
├── 01-import-csv.sql                   # Import des CSV dans table brute
├── script-creation-tables              # Création du schéma normalisé
├── script-tranformation-données        # Transformation et normalisation
├── requête-avancée                     # Triggers et procédures stockées
│
└── jeu-essai                           # Données de test (commune d'Abeilhan)
```

### Ordre d'exécution automatique

Les scripts SQL sont exécutés automatiquement au premier démarrage dans l'ordre alphabétique des noms de fichiers montés dans `/docker-entrypoint-initdb.d/` :

1. **00-download.sql** → Télécharge tous les CSV depuis data.gouv.fr
2. **01-import.sql** → Importe les CSV dans la table `adresses` (brute)
3. **02-schema.sql** → Crée les tables normalisées (département, commune, voie, etc.)
4. **03-requete-avancee.sql** → Crée les triggers et procédures
5. **04-transformation.sql** → Transforme et normalise les données

### Particularités techniques

#### Gestion des fins de ligne (CRLF vs LF)

Le projet est développé sous Windows mais Docker utilise Linux. Les scripts shell doivent avoir des fins de ligne Unix (LF).

**Solution adoptée** : Le `Dockerfile` copie les scripts dans l'image et convertit automatiquement les fins de ligne :

```dockerfile
COPY download-all.sh /usr/local/bin/download-all.sh
COPY urls.txt /usr/local/bin/urls.txt
RUN sed -i 's/\r$//' /usr/local/bin/download-all.sh && \
    sed -i 's/\r$//' /usr/local/bin/urls.txt
```

#### Gestion des départements spéciaux

Le projet gère correctement :

- **Corse** : codes 2A (Corse-du-Sud) et 2B (Haute-Corse)
  - Format INSEE : `2A001`, `2B033`, etc.
- **DOM-TOM** : codes à 3 chiffres (971-989)
  - 971 : Guadeloupe
  - 972 : Martinique
  - 973 : Guyane
  - 974 : La Réunion
  - 975 : Saint-Pierre-et-Miquelon
  - 976 : Mayotte
  - 977 : Saint-Barthélemy
  - 978 : Saint-Martin
  - 984 : Terres australes et antarctiques françaises
  - 986 : Wallis-et-Futuna
  - 987 : Polynésie française
  - 988 : Nouvelle-Calédonie
  - 989 : Île de Clipperton

---

## 📊 Données importées

### Source

- **Base Adresse Nationale (BAN)**
- URL : https://adresse.data.gouv.fr/data/ban/adresses/latest/csv/
- Format : CSV compressé (.csv.gz)

### Couverture

- **109 départements français** (métropole + DOM-TOM)
- **~30-40 millions d'adresses** au total
- Mise à jour régulière par l'IGN et les collectivités

### Contenu des CSV

Chaque fichier CSV contient :

- Identifiant unique BAN
- Code INSEE de la commune
- Numéro et répétition (bis, ter, etc.)
- Nom de la voie et type
- Code postal
- Coordonnées GPS (longitude, latitude)
- Coordonnées Lambert 93 (x, y)
- Identifiant FANTOIR
- Métadonnées (source, certification, etc.)

---

## 🎯 Choix de modélisation

### 1. Architecture normalisée (3NF)

La base de données respecte la **3ème forme normale** pour :

- ✅ Éviter la redondance des données
- ✅ Faciliter la maintenance
- ✅ Assurer l'intégrité référentielle
- ✅ Optimiser les performances

### 2. Hiérarchie territoriale

```
Département (ex: 34 - Hérault, 75 - Paris, 2A - Corse-du-Sud, 971 - Guadeloupe)
    └── Commune (ex: Montpellier, Paris, Ajaccio)
            ├── Voie (ex: Rue de la République)
            │     └── Adresse (ex: 42 bis)
            │             └── Position GPS (lon, lat)
            └── Code Postal (ex: 34000, 75001)
```

### 3. Tables principales

#### **departement**

- Représente les départements français (métropole + DOM-TOM)
- Contrainte : format code département `^([0-9]{2}|[0-9]{3}|2[AB])$`
  - 2 chiffres : départements métropolitains (01-95)
  - 3 chiffres : DOM-TOM (971-989)
  - 2A/2B : Corse

#### **commune**

- Représente les communes françaises (~35 000 communes)
- Lien avec le département via clé étrangère
- Code INSEE unique pour chaque commune
- Contrainte : format code INSEE `^([0-9]{5}|2[AB][0-9]{3})$`
  - 5 chiffres : format standard (ex: 34172)
  - 2A/2B + 3 chiffres : Corse (ex: 2A004)

#### **code_postal**

- Représente les codes postaux (~6 000 codes postaux)
- **Contient le libellé d'acheminement** (ex: "MONTPELLIER", "PARIS", "LYON")
- Contrainte : exactement 5 chiffres

#### **desserte_postale**

- **Table de liaison** entre commune et code postal
- Permet la relation N-N (une commune peut avoir plusieurs codes postaux, un code postal peut desservir plusieurs communes)

#### **voie**

- Représente les rues, avenues, chemins, etc.
- Identifiant FANTOIR (référentiel national des voies)
- Nom normalisé (AFNOR) pour la recherche
- Lien avec la commune

#### **position**

- Coordonnées GPS (longitude, latitude)
- Coordonnées Lambert 93 (x, y)
- Type de position : `'entrée'`, `'bâtiment'`, `'segment'`, etc.
- Contraintes : lat [-90, 90], lon [-180, 180]

#### **adresse**

- Représente une adresse complète
- Numéro + répétition (ex: "42 bis")
- Identifiant BAN (Base Adresse Nationale)
- Lien avec voie et position
- Champs optionnels : parcelles cadastrales, lieu-dit, certifications

### 4. Décisions importantes de modélisation

#### ✅ Pourquoi une table `desserte_postale` ?

**Problème :** Relation N-N entre communes et codes postaux

- Une commune peut avoir plusieurs codes postaux (grandes villes)
- Un code postal peut couvrir plusieurs communes (zones rurales)

**Solution :** Table de liaison pour respecter la 3NF

#### ✅ Pourquoi séparer `position` de `adresse` ?

**Avantages :**

- Évite la duplication (plusieurs adresses peuvent avoir les mêmes coordonnées)
- Permet de gérer les adresses sans GPS
- Optimise le stockage

#### ✅ Contraintes et validations

- **CHECK constraints** : valider les formats (code postal 5 chiffres, coordonnées GPS, codes départements spéciaux)
- **UNIQUE constraints** : éviter les doublons (code INSEE, FANTOIR, coordonnées)
- **FOREIGN KEY avec CASCADE** : maintenir l'intégrité référentielle
- **NOT NULL** sur champs critiques : garantir la qualité des données

---

## 🗂️ Structure de la base de données

### Diagramme de relations

```
┌─────────────────┐
│  departement    │
│  - id (PK)      │◄─────┐
│  - code_dept    │      │
│  - nom_dept     │      │
└─────────────────┘      │
                         │
                    ┌────┴──────────┐
                    │  commune      │
                    │  - id (PK)    │◄─────┐
                    │  - code_insee │      │
                    │  - nom        │      │
                    │  - id_dept(FK)│      │
                    └───────┬───────┘      │
                            │              │
                    ┌───────┴───────┐      │
                    │  voie         │      │
                    │  - id (PK)    │      │
                    │  - id_fantoir │      │
                    │  - nom_voie   │      │
                    │  - id_com(FK) │      │
                    └───────┬───────┘      │
                            │              │
                    ┌───────┴───────┐      │
                    │  adresse      │      │
                    │  - id (PK)    │      │
                    │  - id_ban     │      │
                    │  - numero     │      │
                    │  - rep        │      │
                    │  - id_voie(FK)├──────┘
                    │  - id_pos(FK) │
                    └───────┬───────┘
                            │
                    ┌───────┴───────┐
                    │  position     │
                    │  - id (PK)    │
                    │  - lon, lat   │
                    │  - x, y       │
                    └───────────────┘

┌─────────────────┐       ┌──────────────────┐
│  code_postal    │       │ desserte_postale │
│  - id (PK)      │◄──────┤ - id_commune (FK)│
│  - code_postal  │       │ - id_cp (FK)     │
│  - libelle_ach  │       └──────────────────┘
└─────────────────┘
```

### Tables secondaires

- **commune_ancienne** : historique des fusions de communes
- **alias** : noms alternatifs des voies

---

## 📝 Exemples de requêtes

### Consultation de base

#### 1. Lister toutes les adresses d'une commune

```sql
SELECT
    CONCAT(a.numero, COALESCE(' ' || a.rep, '')) as numero_complet,
    v.nom_voie,
    c.nom_commune,
    cp.code_postal
FROM adresse a
JOIN voie v ON a.id_voie = v.id
JOIN commune c ON v.id_commune = c.id
JOIN desserte_postale dp ON c.id = dp.id_commune
JOIN code_postal cp ON dp.id_code_postal = cp.id
WHERE c.nom_commune = 'Paris'  -- ou 'Montpellier', 'Lyon', etc.
ORDER BY v.nom_voie, a.numero::INTEGER;
```

#### 2. Compter les adresses par département

```sql
SELECT
    d.code_departement,
    d.nom_departement,
    COUNT(a.id) as nb_adresses
FROM departement d
JOIN commune c ON c.id_departement = d.id
JOIN voie v ON v.id_commune = c.id
JOIN adresse a ON a.id_voie = v.id
GROUP BY d.code_departement, d.nom_departement
ORDER BY nb_adresses DESC;
```

#### 3. Rechercher des adresses dans les DOM-TOM

```sql
SELECT
    d.code_departement,
    d.nom_departement,
    c.nom_commune,
    COUNT(a.id) as nb_adresses
FROM departement d
JOIN commune c ON c.id_departement = d.id
JOIN voie v ON v.id_commune = c.id
JOIN adresse a ON a.id_voie = v.id
WHERE d.code_departement IN ('971', '972', '973', '974', '976', '977', '978', '984', '986', '987', '988', '989')
GROUP BY d.code_departement, d.nom_departement, c.nom_commune
ORDER BY d.code_departement, nb_adresses DESC;
```

#### 4. Rechercher une adresse par mot-clé

```sql
SELECT
    CONCAT(a.numero, COALESCE(' ' || a.rep, '')) as numero_complet,
    v.nom_voie,
    c.nom_commune,
    d.nom_departement,
    cp.code_postal
FROM adresse a
JOIN voie v ON a.id_voie = v.id
JOIN commune c ON v.id_commune = c.id
JOIN departement d ON c.id_departement = d.id
JOIN desserte_postale dp ON c.id = dp.id_commune
JOIN code_postal cp ON dp.id_code_postal = cp.id
WHERE v.nom_voie ILIKE '%République%'
ORDER BY d.code_departement, c.nom_commune, v.nom_voie;
```

### Analyses statistiques

#### Statistiques globales

```sql
SELECT
    (SELECT COUNT(*) FROM departement) as nb_departements,
    (SELECT COUNT(*) FROM commune) as nb_communes,
    (SELECT COUNT(*) FROM voie) as nb_voies,
    (SELECT COUNT(*) FROM adresse) as nb_adresses,
    (SELECT COUNT(*) FROM code_postal) as nb_codes_postaux;
```

#### Top 10 des communes avec le plus d'adresses

```sql
SELECT
    c.nom_commune,
    d.nom_departement,
    COUNT(a.id) as nb_adresses
FROM commune c
JOIN departement d ON c.id_departement = d.id
JOIN voie v ON v.id_commune = c.id
JOIN adresse a ON a.id_voie = v.id
GROUP BY c.nom_commune, d.nom_departement
ORDER BY nb_adresses DESC
LIMIT 10;
```

#### Distribution des adresses par région

```sql
SELECT
    CASE
        WHEN d.code_departement IN ('971', '972', '973', '974', '976') THEN 'DOM'
        WHEN d.code_departement IN ('975', '977', '978', '984', '986', '987', '988', '989') THEN 'COM/TOM'
        WHEN d.code_departement IN ('2A', '2B') THEN 'Corse'
        WHEN d.code_departement::INTEGER BETWEEN 75 AND 95 THEN 'Île-de-France'
        ELSE 'Autres métropole'
    END as region,
    COUNT(DISTINCT d.id) as nb_departements,
    COUNT(DISTINCT c.id) as nb_communes,
    COUNT(a.id) as nb_adresses
FROM departement d
LEFT JOIN commune c ON c.id_departement = d.id
LEFT JOIN voie v ON v.id_commune = c.id
LEFT JOIN adresse a ON a.id_voie = v.id
GROUP BY region
ORDER BY nb_adresses DESC;
```

---

## 📂 Scripts SQL disponibles

### Scripts d'initialisation (exécutés automatiquement)

| Fichier                          | Description                                                 |
| -------------------------------- | ----------------------------------------------------------- |
| **00-download.sql**              | Télécharge les 109 fichiers CSV depuis data.gouv.fr         |
| **01-import-csv.sql**            | Importe tous les CSV dans la table brute `adresses`         |
| **script-creation-tables**       | Création du schéma complet (tables, contraintes, index)     |
| **requête-avancée**              | Triggers et procédures stockées                             |
| **script-tranformation-données** | Transforme et normalise les données dans les tables finales |

### Scripts de requêtes (à exécuter manuellement)

| Fichier                       | Description                                            |
| ----------------------------- | ------------------------------------------------------ |
| **requête-consultation**      | Requêtes de consultation (lister, rechercher, compter) |
| **requête-insertion**         | Insertion/modification/suppression avec DO DECLARE     |
| **requête-detection-qualité** | Détection de doublons, anomalies, données manquantes   |
| **requête-analyse**           | Statistiques et agrégations                            |
| **jeu-essai**                 | Échantillon de test réaliste (commune d'Abeilhan)      |

---

## ⚙️ Fonctionnalités avancées

### 1. Procédure stockée : upsert_adresse()

Fonction pour insérer ou mettre à jour une adresse complète en une seule commande.

**Utilisation :**

```sql
SELECT upsert_adresse(
    '75056_test_001',       -- id_ban
    '75056',                -- code_insee
    'Paris',                -- nom_commune
    '75001',                -- code_postal
    'PARIS',                -- libelle_acheminement
    '75056_test1',          -- id_fantoir
    'Rue de Rivoli',        -- nom_voie
    'Rue',                  -- type_voie
    '10',                   -- numero
    NULL,                   -- rep
    2.352222,               -- lon
    48.856613,              -- lat
    652456.00,              -- x
    6862234.00              -- y
);
```

### 2. Trigger de validation

Validation automatique **avant insertion** :

- ✅ Latitude entre -90 et 90
- ✅ Longitude entre -180 et 180
- ✅ Code postal exactement 5 chiffres
- ✅ Codes départements valides (2 ou 3 chiffres, 2A/2B)
- ✅ Codes INSEE valides (5 chiffres ou 2A/2B + 3 chiffres)

### 3. Trigger de dates automatiques

Ajout automatique de `date_creation` et `date_maj` sur les tables :

- `adresse`
- `voie`
- `commune`

---

## 🔧 Maintenance et dépannage

### Commandes Docker utiles

```bash
# Voir les conteneurs en cours
docker-compose ps

# Voir les logs en temps réel
docker logs -f ddb_postgre_natio

# Arrêter le conteneur
docker-compose down

# Arrêter et supprimer les volumes (⚠️ efface toutes les données)
docker-compose down -v

# Redémarrer le conteneur
docker-compose restart

# Reconstruire l'image Docker
docker-compose build

# Se connecter au conteneur
docker exec -it ddb_postgre_natio bash

# Se connecter à PostgreSQL en ligne de commande
docker exec -it ddb_postgre_natio psql -U admin -d adresses_natio
```

### Problèmes courants

#### Le port 5432 est déjà utilisé

**Symptôme** : Erreur "port is already allocated"

**Solution** : Le projet utilise le port **5433** pour éviter les conflits avec PostgreSQL local. Vérifiez que vous vous connectez bien sur le port 5433.

#### L'import prend trop de temps

**Symptôme** : Le conteneur tourne depuis plusieurs heures

**Solution** : C'est normal pour le premier lancement avec les 109 départements. Le téléchargement + import peut prendre 1-2 heures. Suivez les logs avec `docker logs -f ddb_postgre_natio`.

#### Erreur "exit code 2" sur les scripts shell

**Symptôme** : Erreur lors de l'exécution de download-all.sh

**Solution** : Le Dockerfile convertit automatiquement les fins de ligne CRLF → LF. Assurez-vous que le conteneur est bien reconstruit avec `docker-compose build`.

#### La base est vide après le lancement

**Symptôme** : Les tables existent mais sont vides

**Solution** : Les scripts d'initialisation ne s'exécutent que si le volume est vide. Supprimez le volume et relancez :

```bash
docker-compose down -v
docker-compose up -d
```

### Vérifier l'état de l'import

```sql
-- Nombre total d'adresses brutes importées
SELECT COUNT(*) FROM adresses;

-- Nombre de départements transformés
SELECT COUNT(*) FROM departement;

-- Nombre de communes transformées
SELECT COUNT(*) FROM commune;

-- Vérifier s'il y a des erreurs
SELECT * FROM adresses WHERE code_insee IS NULL LIMIT 10;
```

---

## 📞 Support

Pour toute question ou problème :

1. Vérifiez les logs : `docker logs -f ddb_postgre_natio`
2. Consultez la section [Maintenance et dépannage](#-maintenance-et-dépannage)
3. Vérifiez que tous les scripts SQL sont bien montés dans le conteneur
