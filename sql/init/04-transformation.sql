
-- Vérifier l'import
SELECT COUNT(*) as nb_lignes_importees FROM adresses;
SELECT * FROM adresses LIMIT 5;

-- ============================================================================
-- ÉTAPE 2 : Préparation
-- ============================================================================

-- Table temporaire pour collecter les erreurs (recréée à chaque exécution)
DROP TABLE IF EXISTS erreurs_import;
CREATE TEMP TABLE erreurs_import (
    id_adresse TEXT,
    motif TEXT);

-- ============================================================================
-- ÉTAPE 3 : Transformation DEPARTEMENT (dérivé de code_insee)
-- ============================================================================

INSERT INTO departement (code_departement, nom_departement)
SELECT DISTINCT
    -- Extraire le code département : 2 caractères SAUF DOM-TOM (3 caractères) et Corse (2A/2B)
    CASE
        WHEN LEFT(code_insee::TEXT, 3) IN ('971', '972', '973', '974', '975', '976', '977', '978', '984', '986', '987', '988', '989') THEN LEFT(code_insee::TEXT, 3)
        WHEN LEFT(code_insee::TEXT, 2) IN ('2A', '2B') THEN LEFT(code_insee::TEXT, 2)
        ELSE LEFT(code_insee::TEXT, 2)
    END as code_departement,
    CASE 
        WHEN LEFT(code_insee::TEXT, 2) = '01' THEN 'Ain'
        WHEN LEFT(code_insee::TEXT, 2) = '02' THEN 'Aisne'
        WHEN LEFT(code_insee::TEXT, 2) = '03' THEN 'Allier'
        WHEN LEFT(code_insee::TEXT, 2) = '04' THEN 'Alpes-de-Haute-Provence'
        WHEN LEFT(code_insee::TEXT, 2) = '05' THEN 'Hautes-Alpes'
        WHEN LEFT(code_insee::TEXT, 2) = '06' THEN 'Alpes-Maritimes'
        WHEN LEFT(code_insee::TEXT, 2) = '07' THEN 'Ardèche'
        WHEN LEFT(code_insee::TEXT, 2) = '08' THEN 'Ardennes'
        WHEN LEFT(code_insee::TEXT, 2) = '09' THEN 'Ariège'
        WHEN LEFT(code_insee::TEXT, 2) = '10' THEN 'Aube'
        WHEN LEFT(code_insee::TEXT, 2) = '11' THEN 'Aude'
        WHEN LEFT(code_insee::TEXT, 2) = '12' THEN 'Aveyron'
        WHEN LEFT(code_insee::TEXT, 2) = '13' THEN 'Bouches-du-Rhône'
        WHEN LEFT(code_insee::TEXT, 2) = '14' THEN 'Calvados'
        WHEN LEFT(code_insee::TEXT, 2) = '15' THEN 'Cantal'
        WHEN LEFT(code_insee::TEXT, 2) = '16' THEN 'Charente'
        WHEN LEFT(code_insee::TEXT, 2) = '17' THEN 'Charente-Maritime'
        WHEN LEFT(code_insee::TEXT, 2) = '18' THEN 'Cher'
        WHEN LEFT(code_insee::TEXT, 2) = '19' THEN 'Corrèze'
        WHEN LEFT(code_insee::TEXT, 2) = '21' THEN 'Côte-d''Or'
        WHEN LEFT(code_insee::TEXT, 2) = '22' THEN 'Côtes-d''Armor'
        WHEN LEFT(code_insee::TEXT, 2) = '23' THEN 'Creuse'
        WHEN LEFT(code_insee::TEXT, 2) = '24' THEN 'Dordogne'
        WHEN LEFT(code_insee::TEXT, 2) = '25' THEN 'Doubs'
        WHEN LEFT(code_insee::TEXT, 2) = '26' THEN 'Drôme'
        WHEN LEFT(code_insee::TEXT, 2) = '27' THEN 'Eure'
        WHEN LEFT(code_insee::TEXT, 2) = '28' THEN 'Eure-et-Loir'
        WHEN LEFT(code_insee::TEXT, 2) = '29' THEN 'Finistère'
        WHEN LEFT(code_insee::TEXT, 2) = '30' THEN 'Gard'
        WHEN LEFT(code_insee::TEXT, 2) = '31' THEN 'Haute-Garonne'
        WHEN LEFT(code_insee::TEXT, 2) = '32' THEN 'Gers'
        WHEN LEFT(code_insee::TEXT, 2) = '33' THEN 'Gironde'
        WHEN LEFT(code_insee::TEXT, 2) = '34' THEN 'Hérault'
        WHEN LEFT(code_insee::TEXT, 2) = '35' THEN 'Ille-et-Vilaine'
        WHEN LEFT(code_insee::TEXT, 2) = '36' THEN 'Indre'
        WHEN LEFT(code_insee::TEXT, 2) = '37' THEN 'Indre-et-Loire'
        WHEN LEFT(code_insee::TEXT, 2) = '38' THEN 'Isère'
        WHEN LEFT(code_insee::TEXT, 2) = '39' THEN 'Jura'
        WHEN LEFT(code_insee::TEXT, 2) = '40' THEN 'Landes'
        WHEN LEFT(code_insee::TEXT, 2) = '41' THEN 'Loir-et-Cher'
        WHEN LEFT(code_insee::TEXT, 2) = '42' THEN 'Loire'
        WHEN LEFT(code_insee::TEXT, 2) = '43' THEN 'Haute-Loire'
        WHEN LEFT(code_insee::TEXT, 2) = '44' THEN 'Loire-Atlantique'
        WHEN LEFT(code_insee::TEXT, 2) = '45' THEN 'Loiret'
        WHEN LEFT(code_insee::TEXT, 2) = '46' THEN 'Lot'
        WHEN LEFT(code_insee::TEXT, 2) = '47' THEN 'Lot-et-Garonne'
        WHEN LEFT(code_insee::TEXT, 2) = '48' THEN 'Lozère'
        WHEN LEFT(code_insee::TEXT, 2) = '49' THEN 'Maine-et-Loire'
        WHEN LEFT(code_insee::TEXT, 2) = '50' THEN 'Manche'
        WHEN LEFT(code_insee::TEXT, 2) = '51' THEN 'Marne'
        WHEN LEFT(code_insee::TEXT, 2) = '52' THEN 'Haute-Marne'
        WHEN LEFT(code_insee::TEXT, 2) = '53' THEN 'Mayenne'
        WHEN LEFT(code_insee::TEXT, 2) = '54' THEN 'Meurthe-et-Moselle'
        WHEN LEFT(code_insee::TEXT, 2) = '55' THEN 'Meuse'
        WHEN LEFT(code_insee::TEXT, 2) = '56' THEN 'Morbihan'
        WHEN LEFT(code_insee::TEXT, 2) = '57' THEN 'Moselle'
        WHEN LEFT(code_insee::TEXT, 2) = '58' THEN 'Nièvre'
        WHEN LEFT(code_insee::TEXT, 2) = '59' THEN 'Nord'
        WHEN LEFT(code_insee::TEXT, 2) = '60' THEN 'Oise'
        WHEN LEFT(code_insee::TEXT, 2) = '61' THEN 'Orne'
        WHEN LEFT(code_insee::TEXT, 2) = '62' THEN 'Pas-de-Calais'
        WHEN LEFT(code_insee::TEXT, 2) = '63' THEN 'Puy-de-Dôme'
        WHEN LEFT(code_insee::TEXT, 2) = '64' THEN 'Pyrénées-Atlantiques'
        WHEN LEFT(code_insee::TEXT, 2) = '65' THEN 'Hautes-Pyrénées'
        WHEN LEFT(code_insee::TEXT, 2) = '66' THEN 'Pyrénées-Orientales'
        WHEN LEFT(code_insee::TEXT, 2) = '67' THEN 'Bas-Rhin'
        WHEN LEFT(code_insee::TEXT, 2) = '68' THEN 'Haut-Rhin'
        WHEN LEFT(code_insee::TEXT, 2) = '69' THEN 'Rhône'
        WHEN LEFT(code_insee::TEXT, 2) = '70' THEN 'Haute-Saône'
        WHEN LEFT(code_insee::TEXT, 2) = '71' THEN 'Saône-et-Loire'
        WHEN LEFT(code_insee::TEXT, 2) = '72' THEN 'Sarthe'
        WHEN LEFT(code_insee::TEXT, 2) = '73' THEN 'Savoie'
        WHEN LEFT(code_insee::TEXT, 2) = '74' THEN 'Haute-Savoie'
        WHEN LEFT(code_insee::TEXT, 2) = '75' THEN 'Paris'
        WHEN LEFT(code_insee::TEXT, 2) = '76' THEN 'Seine-Maritime'
        WHEN LEFT(code_insee::TEXT, 2) = '77' THEN 'Seine-et-Marne'
        WHEN LEFT(code_insee::TEXT, 2) = '78' THEN 'Yvelines'
        WHEN LEFT(code_insee::TEXT, 2) = '79' THEN 'Deux-Sèvres'
        WHEN LEFT(code_insee::TEXT, 2) = '80' THEN 'Somme'
        WHEN LEFT(code_insee::TEXT, 2) = '81' THEN 'Tarn'
        WHEN LEFT(code_insee::TEXT, 2) = '82' THEN 'Tarn-et-Garonne'
        WHEN LEFT(code_insee::TEXT, 2) = '83' THEN 'Var'
        WHEN LEFT(code_insee::TEXT, 2) = '84' THEN 'Vaucluse'
        WHEN LEFT(code_insee::TEXT, 2) = '85' THEN 'Vendée'
        WHEN LEFT(code_insee::TEXT, 2) = '86' THEN 'Vienne'
        WHEN LEFT(code_insee::TEXT, 2) = '87' THEN 'Haute-Vienne'
        WHEN LEFT(code_insee::TEXT, 2) = '88' THEN 'Vosges'
        WHEN LEFT(code_insee::TEXT, 2) = '89' THEN 'Yonne'
        WHEN LEFT(code_insee::TEXT, 2) = '90' THEN 'Territoire de Belfort'
        WHEN LEFT(code_insee::TEXT, 2) = '91' THEN 'Essonne'
        WHEN LEFT(code_insee::TEXT, 2) = '92' THEN 'Hauts-de-Seine'
        WHEN LEFT(code_insee::TEXT, 2) = '93' THEN 'Seine-Saint-Denis'
        WHEN LEFT(code_insee::TEXT, 2) = '94' THEN 'Val-de-Marne'
        WHEN LEFT(code_insee::TEXT, 2) = '95' THEN 'Val-d''Oise'
        WHEN LEFT(code_insee::TEXT, 3) = '971' THEN 'Guadeloupe'
        WHEN LEFT(code_insee::TEXT, 3) = '972' THEN 'Martinique'
        WHEN LEFT(code_insee::TEXT, 3) = '973' THEN 'Guyane'
        WHEN LEFT(code_insee::TEXT, 3) = '974' THEN 'La Réunion'
        WHEN LEFT(code_insee::TEXT, 3) = '975' THEN 'Saint-Pierre-et-Miquelon'
        WHEN LEFT(code_insee::TEXT, 3) = '976' THEN 'Mayotte'
        WHEN LEFT(code_insee::TEXT, 3) = '977' THEN 'Saint-Barthélemy'
        WHEN LEFT(code_insee::TEXT, 3) = '978' THEN 'Saint-Martin'
        WHEN LEFT(code_insee::TEXT, 3) = '984' THEN 'Terres australes et antarctiques françaises'
        WHEN LEFT(code_insee::TEXT, 3) = '986' THEN 'Wallis-et-Futuna'
        WHEN LEFT(code_insee::TEXT, 3) = '987' THEN 'Polynésie française'
        WHEN LEFT(code_insee::TEXT, 3) = '988' THEN 'Nouvelle-Calédonie'
        WHEN LEFT(code_insee::TEXT, 3) = '989' THEN 'Île de Clipperton'
        WHEN LEFT(code_insee::TEXT, 2) = '2A' THEN 'Corse-du-Sud'
        WHEN LEFT(code_insee::TEXT, 2) = '2B' THEN 'Haute-Corse'
        ELSE 'Département ' || LEFT(code_insee::TEXT, 2)
    END as nom_departement
FROM adresses
WHERE code_insee IS NOT NULL
  AND TRIM(code_insee::TEXT) != ''
ORDER BY code_departement
ON CONFLICT (code_departement) DO NOTHING;

-- Vérifier
SELECT * FROM departement ORDER BY code_departement;

-- ============================================================================
-- ÉTAPE 4 : Transformation COMMUNE
-- ============================================================================

INSERT INTO commune (code_insee, nom_commune, nom_afnor, id_departement)
SELECT DISTINCT ON (ab.code_insee::TEXT)
    ab.code_insee::TEXT,
    ab.nom_commune,
    COALESCE(NULLIF(ab.nom_afnor, ''), UPPER(ab.nom_commune)) as nom_afnor,
    d.id
FROM adresses ab
JOIN departement d ON
    CASE
        WHEN LEFT(ab.code_insee::TEXT, 3) IN ('971', '972', '973', '974', '975', '976', '977', '978', '984', '986', '987', '988', '989') THEN LEFT(ab.code_insee::TEXT, 3)
        WHEN LEFT(ab.code_insee::TEXT, 2) IN ('2A', '2B') THEN LEFT(ab.code_insee::TEXT, 2)
        ELSE LEFT(ab.code_insee::TEXT, 2)
    END = d.code_departement
WHERE ab.code_insee IS NOT NULL
  AND TRIM(ab.code_insee::TEXT) != ''
ORDER BY ab.code_insee::TEXT
ON CONFLICT (code_insee) DO NOTHING;

-- Vérifier
SELECT c.*, d.nom_departement 
FROM commune c 
JOIN departement d ON c.id_departement = d.id 
LIMIT 10;

-- ============================================================================
-- ÉTAPE 5 : Transformation CODE_POSTAL
-- ============================================================================

INSERT INTO code_postal (code_postal, libelle_acheminement)
SELECT DISTINCT
    code_postal::TEXT,
    MAX(libelle_acheminement) as libelle_acheminement
FROM adresses
WHERE code_postal IS NOT NULL
  AND TRIM(code_postal::TEXT) != ''
  AND code_postal::TEXT ~ '^[0-9]{5}$'
GROUP BY code_postal::TEXT
ON CONFLICT (code_postal) DO NOTHING;

-- Vérifier
SELECT * FROM code_postal LIMIT 10;

-- ============================================================================
-- ÉTAPE 6 : Transformation DESSERTE_POSTALE
-- ============================================================================

INSERT INTO desserte_postale (id_commune, id_code_postal)
SELECT DISTINCT
    c.id,
    cp.id
FROM adresses ab
JOIN commune c ON c.code_insee = ab.code_insee::TEXT
JOIN code_postal cp ON cp.code_postal = ab.code_postal::TEXT
WHERE ab.code_insee IS NOT NULL
  AND ab.code_postal IS NOT NULL
  AND TRIM(ab.code_insee::TEXT) != ''
  AND TRIM(ab.code_postal::TEXT) != ''
ON CONFLICT (id_commune, id_code_postal) DO NOTHING;

-- Vérifier
SELECT COUNT(*) FROM desserte_postale;

-- ============================================================================
-- ÉTAPE 7 : Transformation VOIE
-- ============================================================================

-- Générer un id_fantoir temporaire si manquant
UPDATE adresses
SET id_fantoir = code_insee::TEXT || '_' || SUBSTRING(MD5(nom_voie), 1, 4)
WHERE id_fantoir IS NULL OR TRIM(id_fantoir::TEXT) = '';

INSERT INTO voie (id_fantoir, nom_voie, nom_afnor, type_voie, id_commune)
SELECT DISTINCT ON (ab.id_fantoir)
    ab.id_fantoir,
    ab.nom_voie,
    COALESCE(NULLIF(ab.nom_afnor, ''), UPPER(ab.nom_voie)) as nom_afnor,
    -- Extraction du type de voie
    CASE 
        WHEN ab.nom_voie ~* '^Rue ' THEN 'Rue'
        WHEN ab.nom_voie ~* '^Avenue ' THEN 'Avenue'
        WHEN ab.nom_voie ~* '^Boulevard ' THEN 'Boulevard'
        WHEN ab.nom_voie ~* '^Place ' THEN 'Place'
        WHEN ab.nom_voie ~* '^Chemin ' THEN 'Chemin'
        WHEN ab.nom_voie ~* '^Route ' THEN 'Route'
        WHEN ab.nom_voie ~* '^All[ée]e ' THEN 'Allée'
        WHEN ab.nom_voie ~* '^Impasse ' THEN 'Impasse'
        WHEN ab.nom_voie ~* '^Cours ' THEN 'Cours'
        WHEN ab.nom_voie ~* '^Quai ' THEN 'Quai'
        ELSE NULL
    END as type_voie,
    c.id
FROM adresses ab
JOIN commune c ON c.code_insee = ab.code_insee::TEXT
WHERE ab.id_fantoir IS NOT NULL
  AND TRIM(ab.id_fantoir::TEXT) != ''
  AND ab.nom_voie IS NOT NULL
  AND TRIM(ab.nom_voie) != ''
ORDER BY ab.id_fantoir
ON CONFLICT (id_fantoir) DO NOTHING;

-- Vérifier
SELECT v.*, c.nom_commune 
FROM voie v 
JOIN commune c ON v.id_commune = c.id 
LIMIT 10;

-- ============================================================================
-- ÉTAPE 8 : Transformation POSITION
-- ============================================================================

DROP TABLE IF EXISTS position_temp;

CREATE TEMP TABLE position_temp AS
SELECT DISTINCT ON (x, y, lon, lat)
    x, y, lon, lat, 
    -- Normaliser type_position pour correspondre aux valeurs de la contrainte
    CASE 
        WHEN type_position IS NULL OR TRIM(type_position) = '' THEN NULL
        WHEN type_position ILIKE '%cage%escalier%' THEN 'cage d''escalier'
        WHEN type_position ILIKE '%d%livrance%postal%' THEN 'délivrance postale'
        WHEN type_position ILIKE '%entr%e%' THEN 'entrée'
        WHEN type_position ILIKE '%b%timent%' THEN 'bâtiment'
        WHEN type_position ILIKE '%logement%' THEN 'logement'
        WHEN type_position ILIKE '%parcelle%' THEN 'parcelle'
        WHEN type_position ILIKE '%segment%' THEN 'segment'
        WHEN type_position ILIKE '%service%technique%' THEN 'service technique'
        ELSE NULL  -- Rejeter les valeurs non conformes
    END as type_position,
    ROW_NUMBER() OVER (ORDER BY x, y) as rn
FROM adresses
WHERE x IS NOT NULL
  AND y IS NOT NULL
  AND lon IS NOT NULL
  AND lat IS NOT NULL;

INSERT INTO position (x, y, lon, lat, type_position)
SELECT x, y, lon, lat, type_position
FROM position_temp
ORDER BY rn
ON CONFLICT (x, y, lon, lat) DO NOTHING;

-- Vérifier
SELECT COUNT(*) as nb_positions FROM position;
SELECT * FROM position LIMIT 10;

DROP TABLE position_temp;

-- ============================================================================
-- ÉTAPE 9 : Transformation ADRESSE
-- ============================================================================

-- Enregistrer les adresses avec lieu-dit trop long
INSERT INTO erreurs_import (id_adresse, motif)
SELECT 
    ab.id::TEXT,
    'Lieu-dit trop long (' || LENGTH(ab.nom_ld) || ' caractères) : ' || LEFT(ab.nom_ld, 50) || '...'
FROM adresses ab
WHERE ab.nom_ld IS NOT NULL 
  AND TRIM(ab.nom_ld) != ''
  AND LENGTH(ab.nom_ld) > 100;

INSERT INTO adresse (
    id_ban, numero, rep, nom_ld, cad_parcelles,
    certification_commune, source_position, source_nom_voie,
    id_voie, id_position
)
SELECT DISTINCT ON (ab.id)
    ab.id::TEXT as id_ban,
    CASE 
        WHEN ab.numero IS NULL THEN NULL
        WHEN TRIM(ab.numero::TEXT) = '' THEN NULL
        ELSE ab.numero::TEXT
    END as numero,
    NULLIF(TRIM(ab.rep), '') as rep,
    CASE 
        WHEN ab.nom_ld IS NULL THEN NULL
        WHEN TRIM(ab.nom_ld) = '' THEN NULL
        WHEN LENGTH(ab.nom_ld) > 100 THEN NULL  
        ELSE NULLIF(TRIM(ab.nom_ld), '')
    END as nom_ld,
    NULLIF(ab.cad_parcelles, '') as cad_parcelles,
    CASE 
        WHEN ab.certification_commune IS NULL THEN FALSE
        WHEN ab.certification_commune = 1 THEN TRUE
        ELSE FALSE
    END as certification_commune,
    CASE
        WHEN ab.source_position IN ('commune', 'cadastre', 'ign', 'arcep', 'laposte', 'inconnue') THEN ab.source_position
        ELSE NULL
    END as source_position,
    CASE
        WHEN ab.source_nom_voie IN ('commune', 'ign', 'cadastre', 'arcep', 'inconnue') THEN ab.source_nom_voie
        ELSE NULL
    END as source_nom_voie,
    v.id as id_voie,
    p.id as id_position
FROM adresses ab
LEFT JOIN voie v ON v.id_fantoir = ab.id_fantoir  -- LEFT JOIN pour supporter les lieux-dits sans voie
LEFT JOIN position p ON p.x::NUMERIC = ab.x::NUMERIC
                    AND p.y::NUMERIC = ab.y::NUMERIC
                    AND p.lon::NUMERIC = ab.lon::NUMERIC
                    AND p.lat::NUMERIC = ab.lat::NUMERIC
WHERE ab.id IS NOT NULL
  AND p.id IS NOT NULL  -- S'assurer qu'on a trouvé une position
  -- Respecter la contrainte chk_adresse_coherence avant insertion
  AND (
      (ab.numero IS NOT NULL AND v.id IS NOT NULL)
      OR (NULLIF(TRIM(ab.nom_ld), '') IS NOT NULL AND LENGTH(ab.nom_ld) <= 100)  -- Ignorer si lieu-dit trop long
  )
ORDER BY ab.id
ON CONFLICT (id_ban) DO NOTHING;
  -- Note: La contrainte chk_adresse_coherence sur la table vérifiera automatiquement
  -- que (numero IS NOT NULL AND id_voie IS NOT NULL) OR nom_ld IS NOT NULL

-- Vérifier
SELECT COUNT(*) as nb_adresses FROM adresse;
SELECT * FROM adresse LIMIT 10;

-- ============================================================================
-- ÉTAPE 10 : Statistiques et vérifications (La j'controle plus rien j'voulais juste avoir des stats)
-- ============================================================================

-- ============================================================================
-- ANALYSE DES DOUBLONS
-- ============================================================================

-- Vérifier si les doublons sont identiques ou différents
SELECT 
    'IDs avec doublons' as type_doublon,
    COUNT(*) as nb_ids
FROM (
    SELECT id
    FROM adresses
    WHERE id IS NOT NULL
    GROUP BY id
    HAVING COUNT(*) > 1
) doublons

UNION ALL

SELECT 
    'Doublons strictement identiques (toutes colonnes)',
    COUNT(DISTINCT id)
FROM (
    SELECT id, COUNT(*) as nb_occurrences, COUNT(DISTINCT (
        code_insee, nom_commune, code_postal, nom_voie, numero, rep, nom_ld, 
        x, y, lon, lat, id_fantoir, nom_afnor, libelle_acheminement, 
        type_position, cad_parcelles, source_position, source_nom_voie, 
        certification_commune
    )) as nb_variantes
    FROM adresses
    WHERE id IS NOT NULL
    GROUP BY id
    HAVING COUNT(*) > 1 AND COUNT(DISTINCT (
        code_insee, nom_commune, code_postal, nom_voie, numero, rep, nom_ld, 
        x, y, lon, lat, id_fantoir, nom_afnor, libelle_acheminement, 
        type_position, cad_parcelles, source_position, source_nom_voie, 
        certification_commune
    )) = 1
) vrais_doublons

UNION ALL

SELECT 
    'Doublons avec variantes (données différentes)',
    COUNT(DISTINCT id)
FROM (
    SELECT id, COUNT(*) as nb_occurrences, COUNT(DISTINCT (
        code_insee, nom_commune, code_postal, nom_voie, numero, rep, nom_ld, 
        x, y, lon, lat, id_fantoir, nom_afnor, libelle_acheminement, 
        type_position, cad_parcelles, source_position, source_nom_voie, 
        certification_commune
    )) as nb_variantes
    FROM adresses
    WHERE id IS NOT NULL
    GROUP BY id
    HAVING COUNT(*) > 1 AND COUNT(DISTINCT (
        code_insee, nom_commune, code_postal, nom_voie, numero, rep, nom_ld, 
        x, y, lon, lat, id_fantoir, nom_afnor, libelle_acheminement, 
        type_position, cad_parcelles, source_position, source_nom_voie, 
        certification_commune
    )) > 1
) doublons_avec_variantes;

-- Exemples de doublons avec variantes (si existants)
SELECT 
    'Exemples de doublons avec données différentes :' as titre;

SELECT 
    id,
    COUNT(*) as nb_occurrences,
    STRING_AGG(DISTINCT nom_voie, ' | ') as voies_differentes,
    STRING_AGG(DISTINCT numero::TEXT, ' | ') as numeros_differents,
    STRING_AGG(DISTINCT code_postal::TEXT, ' | ') as codes_postaux
FROM adresses
WHERE id IN (
    SELECT id
    FROM adresses
    WHERE id IS NOT NULL
    GROUP BY id
    HAVING COUNT(*) > 1 AND COUNT(DISTINCT (
        code_insee, nom_commune, code_postal, nom_voie, numero, rep, nom_ld, 
        x, y, lon, lat, id_fantoir
    )) > 1
)
GROUP BY id
LIMIT 10;

-- ============================================================================
-- STATISTIQUES GÉNÉRALES
-- ============================================================================

-- Diagnostic détaillé des pertes d'adresses
SELECT 
    'Total source (avec id)' as etape,
    COUNT(*) as nb_adresses
FROM adresses
WHERE id IS NOT NULL

UNION ALL

SELECT 
    'IDs distincts dans source',
    COUNT(DISTINCT id)
FROM adresses
WHERE id IS NOT NULL

UNION ALL

SELECT 
    'IDs dupliqués (doublons)',
    COUNT(*) - COUNT(DISTINCT id)
FROM adresses
WHERE id IS NOT NULL

UNION ALL

SELECT 
    'Avec position trouvée',
    COUNT(*)
FROM adresses ab
LEFT JOIN position p ON p.x::NUMERIC = ab.x::NUMERIC
                    AND p.y::NUMERIC = ab.y::NUMERIC
                    AND p.lon::NUMERIC = ab.lon::NUMERIC
                    AND p.lat::NUMERIC = ab.lat::NUMERIC
WHERE ab.id IS NOT NULL
  AND p.id IS NOT NULL

UNION ALL

SELECT 
    'Sans position (JOIN échoué)',
    COUNT(*)
FROM adresses ab
LEFT JOIN position p ON p.x::NUMERIC = ab.x::NUMERIC
                    AND p.y::NUMERIC = ab.y::NUMERIC
                    AND p.lon::NUMERIC = ab.lon::NUMERIC
                    AND p.lat::NUMERIC = ab.lat::NUMERIC
WHERE ab.id IS NOT NULL
  AND p.id IS NULL

UNION ALL

SELECT 
    'Avec voie trouvée',
    COUNT(*)
FROM adresses ab
LEFT JOIN voie v ON v.id_fantoir = ab.id_fantoir
WHERE ab.id IS NOT NULL

UNION ALL

SELECT 
    'Sans voie (lieu-dit potentiel)',
    COUNT(*)
FROM adresses ab
LEFT JOIN voie v ON v.id_fantoir = ab.id_fantoir
WHERE ab.id IS NOT NULL
  AND v.id IS NULL

UNION ALL

SELECT 
    'Contrainte OK (numero+voie OU nom_ld)',
    COUNT(*)
FROM adresses ab
LEFT JOIN voie v ON v.id_fantoir = ab.id_fantoir
WHERE ab.id IS NOT NULL
  AND (
      (ab.numero IS NOT NULL AND v.id IS NOT NULL)
      OR (NULLIF(TRIM(ab.nom_ld), '') IS NOT NULL AND LENGTH(ab.nom_ld) <= 100)
  )

UNION ALL

SELECT 
    'Contrainte KO (ni numero+voie ni lieu-dit)',
    COUNT(*)
FROM adresses ab
LEFT JOIN voie v ON v.id_fantoir = ab.id_fantoir
WHERE ab.id IS NOT NULL
  AND NOT (
      (ab.numero IS NOT NULL AND v.id IS NOT NULL)
      OR (NULLIF(TRIM(ab.nom_ld), '') IS NOT NULL AND LENGTH(ab.nom_ld) <= 100)
  )

UNION ALL

SELECT 
    'Lieu-dit trop long (> 100 car)',
    COUNT(*)
FROM adresses ab
WHERE ab.id IS NOT NULL
  AND ab.nom_ld IS NOT NULL 
  AND TRIM(ab.nom_ld) != ''
  AND LENGTH(ab.nom_ld) > 100

UNION ALL

SELECT 
    'Finalement insérées',
    COUNT(*)
FROM adresse;

-- Tables
SELECT 'departement' as table_name, COUNT(*) as nb_lignes FROM departement
UNION ALL
SELECT 'commune', COUNT(*) FROM commune
UNION ALL
SELECT 'code_postal', COUNT(*) FROM code_postal
UNION ALL
SELECT 'desserte_postale', COUNT(*) FROM desserte_postale
UNION ALL
SELECT 'voie', COUNT(*) FROM voie
UNION ALL
SELECT 'position', COUNT(*) FROM position
UNION ALL
SELECT 'adresse', COUNT(*) FROM adresse
ORDER BY table_name;

-- Afficher quelques exemples d'adresses complètes
SELECT 
    a.id_ban,
    CONCAT(a.numero, COALESCE(' ' || a.rep, '')) as numero_complet,
    v.nom_voie,
    c.nom_commune,
    d.nom_departement,
    cp.code_postal,
    ROUND(p.lat::numeric, 6) as latitude,
    ROUND(p.lon::numeric, 6) as longitude,
    a.certification_commune
FROM adresse a
JOIN voie v ON a.id_voie = v.id
JOIN commune c ON v.id_commune = c.id
JOIN departement d ON c.id_departement = d.id
JOIN position p ON a.id_position = p.id
LEFT JOIN desserte_postale dp ON c.id = dp.id_commune
LEFT JOIN code_postal cp ON dp.id_code_postal = cp.id
LIMIT 20;

-- ============================================================================
-- Message de fin
-- ============================================================================

DO $$
DECLARE
    nb_departements INTEGER;
    nb_communes INTEGER;
    nb_voies INTEGER;
    nb_adresses INTEGER;
    nb_erreurs INTEGER;
    nb_ids_rejetes INTEGER;
    nb_source_total INTEGER;
    nb_ids_distincts INTEGER;
    nb_doublons INTEGER;
    nb_ids_doublons INTEGER;
    nb_vrais_doublons INTEGER;
    nb_doublons_variantes INTEGER;
    nb_source_departements INTEGER;
    nb_source_communes INTEGER;
    nb_source_voies INTEGER;
    nb_positions_source INTEGER;
    nb_positions_cible INTEGER;
    nb_sans_position INTEGER;
    nb_sans_voie INTEGER;
    nb_contrainte_ko INTEGER;
    erreur RECORD;
BEGIN
    -- Compteurs cibles
    SELECT COUNT(*) INTO nb_departements FROM departement;
    SELECT COUNT(*) INTO nb_communes FROM commune;
    SELECT COUNT(*) INTO nb_voies FROM voie;
    SELECT COUNT(*) INTO nb_adresses FROM adresse;
    SELECT COUNT(*) INTO nb_erreurs FROM erreurs_import;
    SELECT COUNT(DISTINCT id_adresse) INTO nb_ids_rejetes FROM erreurs_import;
    
    -- Compteurs sources
    SELECT COUNT(*) INTO nb_source_total FROM adresses WHERE id IS NOT NULL;
    SELECT COUNT(DISTINCT id) INTO nb_ids_distincts FROM adresses WHERE id IS NOT NULL;
    nb_doublons := nb_source_total - nb_ids_distincts;
    
    -- Analyse des doublons
    SELECT COUNT(*) INTO nb_ids_doublons
    FROM (SELECT id FROM adresses WHERE id IS NOT NULL GROUP BY id HAVING COUNT(*) > 1) d;
    
    SELECT COUNT(DISTINCT id) INTO nb_vrais_doublons
    FROM (
        SELECT id
        FROM adresses WHERE id IS NOT NULL
        GROUP BY id 
        HAVING COUNT(*) > 1 
          AND COUNT(DISTINCT (code_insee, nom_commune, code_postal, nom_voie, numero, rep, nom_ld, x, y, lon, lat, id_fantoir)) = 1
    ) vd;
    
    SELECT COUNT(DISTINCT id) INTO nb_doublons_variantes
    FROM (
        SELECT id
        FROM adresses WHERE id IS NOT NULL
        GROUP BY id 
        HAVING COUNT(*) > 1 
          AND COUNT(DISTINCT (code_insee, nom_commune, code_postal, nom_voie, numero, rep, nom_ld, x, y, lon, lat, id_fantoir)) > 1
    ) dv;
    
    SELECT COUNT(DISTINCT
        CASE
            WHEN LEFT(code_insee::TEXT, 3) IN ('971','972','973','974','975','976','977','978','984','986','987','988','989') THEN LEFT(code_insee::TEXT, 3)
            WHEN LEFT(code_insee::TEXT, 2) IN ('2A','2B') THEN LEFT(code_insee::TEXT, 2)
            ELSE LEFT(code_insee::TEXT, 2)
        END
    ) INTO nb_source_departements FROM adresses WHERE code_insee IS NOT NULL;
    
    SELECT COUNT(DISTINCT code_insee::TEXT) INTO nb_source_communes 
    FROM adresses WHERE code_insee IS NOT NULL;
    
    SELECT COUNT(DISTINCT id_fantoir) INTO nb_source_voies 
    FROM adresses WHERE id_fantoir IS NOT NULL AND TRIM(id_fantoir::TEXT) != '';
    
    SELECT COUNT(DISTINCT (x, y, lon, lat)) INTO nb_positions_source 
    FROM adresses WHERE x IS NOT NULL AND y IS NOT NULL;
    
    SELECT COUNT(*) INTO nb_positions_cible FROM position;
    
    -- Diagnostics des pertes
    SELECT COUNT(*) INTO nb_sans_position
    FROM adresses ab
    LEFT JOIN position p ON p.x::NUMERIC = ab.x::NUMERIC
                        AND p.y::NUMERIC = ab.y::NUMERIC
                        AND p.lon::NUMERIC = ab.lon::NUMERIC
                        AND p.lat::NUMERIC = ab.lat::NUMERIC
    WHERE ab.id IS NOT NULL AND p.id IS NULL;
    
    SELECT COUNT(*) INTO nb_sans_voie
    FROM adresses ab
    LEFT JOIN voie v ON v.id_fantoir = ab.id_fantoir
    WHERE ab.id IS NOT NULL AND v.id IS NULL;
    
    SELECT COUNT(*) INTO nb_contrainte_ko
    FROM adresses ab
    LEFT JOIN voie v ON v.id_fantoir = ab.id_fantoir
    WHERE ab.id IS NOT NULL
      AND NOT (
          (ab.numero IS NOT NULL AND v.id IS NOT NULL)
          OR (NULLIF(TRIM(ab.nom_ld), '') IS NOT NULL AND LENGTH(ab.nom_ld) <= 100)
      );
    
    RAISE NOTICE '============================================';
    RAISE NOTICE '✅ Transformation terminée avec succès !';
    RAISE NOTICE '============================================';
    
    IF nb_doublons > 0 THEN
        RAISE NOTICE '📋 Source : % lignes totales, % IDs uniques (% doublons)', nb_source_total, nb_ids_distincts, nb_doublons;
        RAISE NOTICE '   • % IDs avec doublons dont :', nb_ids_doublons;
        RAISE NOTICE '     - % vrais doublons (données identiques)', nb_vrais_doublons;
        RAISE NOTICE '     - % doublons avec variantes (données différentes)', nb_doublons_variantes;
        RAISE NOTICE '--------------------------------------------';
    END IF;
    
    RAISE NOTICE 'Départements : % / % source', nb_departements, nb_source_departements;
    RAISE NOTICE 'Communes : % / % source', nb_communes, nb_source_communes;
    RAISE NOTICE 'Voies : % / % source', nb_voies, nb_source_voies;
    RAISE NOTICE 'Positions : % / % source', nb_positions_cible, nb_positions_source;
    RAISE NOTICE 'Adresses : % / % IDs uniques', nb_adresses, nb_ids_distincts;
    IF nb_ids_rejetes > 0 THEN
        RAISE NOTICE '           (% ID(s) avec % occurrence(s) rejetées)', nb_ids_rejetes, nb_erreurs;
    END IF;
    RAISE NOTICE '============================================';
    
    -- Vérifications d'intégrité
    IF nb_departements != nb_source_departements THEN
        RAISE WARNING '⚠️  Différence détectée sur les départements !';
    END IF;
    
    IF nb_communes != nb_source_communes THEN
        RAISE WARNING '⚠️  Différence détectée sur les communes !';
    END IF;
    
    IF nb_positions_cible != nb_positions_source THEN
        RAISE WARNING '⚠️  Différence détectée sur les positions !';
    END IF;
    
    IF (nb_adresses + nb_ids_rejetes) != nb_ids_distincts THEN
        RAISE WARNING '⚠️  Il manque % adresses (sur % IDs uniques) !', (nb_ids_distincts - nb_adresses - nb_ids_rejetes), nb_ids_distincts;
        RAISE NOTICE '--------------------------------------------';
        RAISE NOTICE '📊 DIAGNOSTIC DES PERTES :';
        RAISE NOTICE '--------------------------------------------';
        RAISE NOTICE '  • Adresses sans position trouvée (JOIN échoué) : %', nb_sans_position;
        RAISE NOTICE '  • Adresses sans voie (lieu-dit sans rue) : %', nb_sans_voie;
        RAISE NOTICE '  • Adresses ne respectant pas la contrainte : %', nb_contrainte_ko;
        RAISE NOTICE '    (ni numero+voie ni lieu-dit valide)';
        RAISE NOTICE '--------------------------------------------';
    ELSIF nb_doublons > 0 THEN
        RAISE NOTICE '--------------------------------------------';
        RAISE NOTICE 'ℹ️  Tous les IDs uniques ont été traités avec succès';
        RAISE NOTICE '   • % doublons fusionnés (DISTINCT ON) :', nb_doublons;
        RAISE NOTICE '     - % vrais doublons (100%% identiques)', nb_vrais_doublons;
        IF nb_doublons_variantes > 0 THEN
            RAISE NOTICE '     - % doublons avec variantes (première occurrence gardée)', nb_doublons_variantes;
        END IF;
        IF nb_ids_rejetes > 0 THEN
            RAISE NOTICE '   • % ID(s) rejeté(s) pour non-conformité', nb_ids_rejetes;
        END IF;
        RAISE NOTICE '--------------------------------------------';
    END IF;
    
    IF nb_erreurs > 0 THEN
        RAISE NOTICE '--------------------------------------------';
        RAISE NOTICE '⚠️  Détail des adresses ignorées :';
        RAISE NOTICE '--------------------------------------------';
        FOR erreur IN SELECT DISTINCT id_adresse, motif FROM erreurs_import LOOP
            RAISE NOTICE 'ID % : %', erreur.id_adresse, erreur.motif;
        END LOOP;
        RAISE NOTICE '============================================';
    END IF;
    
    IF nb_doublons_variantes > 0 THEN
        RAISE NOTICE '--------------------------------------------';
        RAISE NOTICE '⚠️  IDs avec variantes (première occurrence gardée) :';
        RAISE NOTICE '--------------------------------------------';
        FOR erreur IN 
            SELECT id
            FROM adresses 
            WHERE id IS NOT NULL
            GROUP BY id 
            HAVING COUNT(*) > 1 
              AND COUNT(DISTINCT (code_insee, nom_commune, code_postal, nom_voie, numero, rep, nom_ld, x, y, lon, lat, id_fantoir)) > 1
            ORDER BY id
            LIMIT 50
        LOOP
            RAISE NOTICE '  %', erreur.id;
        END LOOP;
        IF nb_doublons_variantes > 50 THEN
            RAISE NOTICE '  ... et % autres IDs', (nb_doublons_variantes - 50);
        END IF;
        RAISE NOTICE '============================================';
    END IF;
END $$;
