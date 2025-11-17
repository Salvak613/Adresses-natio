-- =========================================
-- Import des données brutes depuis tous les CSV
-- =========================================

-- Créer la table pour recevoir les données brutes du CSV
CREATE TABLE IF NOT EXISTS adresses (
    id TEXT,
    id_fantoir TEXT,
    numero INTEGER,
    rep TEXT,
    nom_voie TEXT,
    code_postal TEXT,
    code_insee TEXT,
    nom_commune TEXT,
    code_insee_ancienne_commune TEXT,
    nom_ancienne_commune TEXT,
    x NUMERIC,
    y NUMERIC,
    lon NUMERIC,
    lat NUMERIC,
    type_position TEXT,
    alias TEXT,
    nom_ld TEXT,
    libelle_acheminement TEXT,
    nom_afnor TEXT,
    source_position TEXT,
    source_nom_voie TEXT,
    certification_commune INTEGER,
    cad_parcelles TEXT
);

-- Importer tous les fichiers CSV depuis /tmp
DO $$
DECLARE
    csv_file TEXT;
    nb_lignes_avant INTEGER;
    nb_lignes_apres INTEGER;
    nb_lignes_fichier INTEGER;
    total_fichiers INTEGER := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Import de tous les fichiers CSV...';
    RAISE NOTICE '========================================';

    -- Parcourir tous les fichiers CSV dans /tmp
    FOR csv_file IN
        SELECT '/tmp/' || filename
        FROM pg_ls_dir('/tmp') AS filename
        WHERE filename LIKE 'adresses-%.csv'
        ORDER BY filename
    LOOP
        SELECT COUNT(*) INTO nb_lignes_avant FROM adresses;

        -- Importer le fichier
        EXECUTE format('COPY adresses FROM %L WITH (FORMAT csv, HEADER true, DELIMITER %L, ENCODING %L, NULL %L)',
                      csv_file, ';', 'UTF8', '');

        SELECT COUNT(*) INTO nb_lignes_apres FROM adresses;
        nb_lignes_fichier := nb_lignes_apres - nb_lignes_avant;
        total_fichiers := total_fichiers + 1;

        RAISE NOTICE '[%] % : % lignes importées', total_fichiers, csv_file, nb_lignes_fichier;
    END LOOP;

    RAISE NOTICE '========================================';
    RAISE NOTICE '✓ Import terminé: % fichiers, % adresses totales', total_fichiers, nb_lignes_apres;
    RAISE NOTICE '========================================';
END $$;
