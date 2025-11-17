-- =========================================
-- Téléchargement de tous les fichiers CSV
-- =========================================

DO $$
BEGIN
    RAISE NOTICE '=========================================';
    RAISE NOTICE 'Téléchargement de tous les départements...';
    RAISE NOTICE '=========================================';
END $$;

-- Créer une table temporaire pour capturer la sortie du téléchargement
CREATE TEMP TABLE download_log (log_line TEXT);

-- Exécuter le script shell qui télécharge tous les fichiers
COPY download_log FROM PROGRAM '/usr/local/bin/download-all.sh';

-- Afficher le résultat
DO $$
DECLARE
    log_entry TEXT;
BEGIN
    FOR log_entry IN SELECT log_line FROM download_log LOOP
        RAISE NOTICE '%', log_entry;
    END LOOP;
    RAISE NOTICE '✓ Tous les fichiers CSV sont prêts pour l''import!';
    RAISE NOTICE '=========================================';
END $$;
